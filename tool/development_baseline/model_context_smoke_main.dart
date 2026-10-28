// Local, web-only GPU recovery fixture. Never expose as a production route.
// Requires /models/qa-context/rigged-wind-turbine-lite.glb in the QA build only.
// Uses public DOM, WebGL and model camera APIs. No Firebase or auth requests.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/material.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/remote_model_sources.dart';
import 'package:sutol/ui/widgets/html_stage/html_page_stage.dart';

final errors = ValueNotifier<List<String>>([]);
const modelId = 'sutols-wind-turbine';
const cameraKey = 'context-smoke:wind';

void main() {
  FlutterError.onError = (details) {
    errors.value = [...errors.value.take(7), details.exceptionAsString()];
  };
  RemoteModelSources.registerAll({
    modelId: '/models/qa-context/rigged-wind-turbine-lite.glb',
  });
  runApp(const MaterialApp(home: _ContextSmoke()));
}

class _ContextSmoke extends StatefulWidget {
  const _ContextSmoke();
  @override
  State<_ContextSmoke> createState() => _ContextSmokeState();
}

class _ContextSmokeState extends State<_ContextSmoke> {
  String phase = 'Waiting for the rigged model';
  ModelViewerCameraPose? before, after;
  bool nativeLoss = false, nativeRestore = false;
  bool? lostBefore, lostDuring, lostAfter;
  Timer? poll, lossTimer, restoreTimer, verifyTimer;
  StreamSubscription<html.Event>? lossSubscription, restoreSubscription;
  int attempts = 0;
  double clipTime = 1.5;
  bool animationEnabled = false;
  final Map<String, Object?> animationChecks = {};
  final Map<String, Object?> longSession = {};
  int sceneIndex = 0;
  bool showModel = true;
  String get sceneCameraKey =>
      sceneIndex == 0 ? cameraKey : '$cameraKey:$sceneIndex';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pollModel());
  }

  void _phase(String next) {
    if (mounted) setState(() => phase = next);
  }

  void _pollModel() {
    if (!mounted) return;
    final model = html.document.querySelector('model-viewer');
    final canvas = model?.shadowRoot?.querySelector('canvas#webgl-canvas');
    final pose = HtmlModelCanvas.cameraPoseFor(cameraKey, modelId: modelId);
    if (canvas == null || pose == null) {
      if (++attempts > 80) {
        _phase('FAILED: model or its public WebGL canvas did not become ready');
      } else {
        poll = Timer(const Duration(milliseconds: 250), _pollModel);
      }
      return;
    }
    _phase('Ready: native context loss starts after camera stabilization');
    lossTimer = Timer(const Duration(seconds: 2), () => _lose(canvas));
  }

  void _lose(html.Element canvasElement) {
    if (!mounted) return;
    try {
      final canvas = canvasElement as JSObject;
      final context =
          canvas.callMethod<JSObject?>('getContext'.toJS, 'webgl2'.toJS);
      final extension = context?.callMethod<JSObject?>(
          'getExtension'.toJS, 'WEBGL_lose_context'.toJS);
      if (context == null || extension == null) {
        _phase('SKIPPED: WEBGL_lose_context is unavailable');
        return;
      }
      before = HtmlModelCanvas.cameraPoseFor(cameraKey, modelId: modelId);
      lostBefore = context.callMethod<JSBoolean>('isContextLost'.toJS).toDart;
      final element = canvasElement as html.CanvasElement;
      lossSubscription = element.on['webglcontextlost'].listen((_) {
        nativeLoss = true;
        lostDuring = context.callMethod<JSBoolean>('isContextLost'.toJS).toDart;
        _phase(
            'NATIVE CONTEXT LOST: poster should be visible; edits remain intact');
      });
      restoreSubscription = element.on['webglcontextrestored'].listen((_) {
        nativeRestore = true;
        _phase('NATIVE CONTEXT RESTORED: checking camera and clip');
        verifyTimer = Timer(const Duration(milliseconds: 1800), () {
          if (!mounted) return;
          after = HtmlModelCanvas.cameraPoseFor(cameraKey, modelId: modelId);
          lostAfter =
              context.callMethod<JSBoolean>('isContextLost'.toJS).toDart;
          final passed = nativeLoss &&
              nativeRestore &&
              lostBefore == false &&
              lostDuring == true &&
              lostAfter == false &&
              _samePose(before, after) &&
              _samePose(
                  before,
                  const ModelViewerCameraPose(
                      theta: 32,
                      phi: 67,
                      radius: 4,
                      targetX: 0,
                      targetY: .5,
                      targetZ: 0,
                      fieldOfView: 51,
                      turntableRotation: .7,
                      animationTime: 1.5,
                      animationName: 'RotorSpin'));
          if (passed) unawaited(_checkAnimationControls());
          _phase(passed
              ? 'PASS: native loss/restore; camera, turntable and paused clip preserved'
              : 'FAILED: native recovery or camera/clip differs');
        });
      });
      extension.callMethod<JSAny?>('loseContext'.toJS);
      restoreTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) extension.callMethod<JSAny?>('restoreContext'.toJS);
      });
    } catch (error) {
      _phase('FAILED: $error');
    }
  }

  Future<void> _checkAnimationControls() async {
    setState(() => clipTime = 2.5);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final sought = HtmlModelCanvas.cameraPoseFor(cameraKey, modelId: modelId);
    animationChecks['seekTime'] = sought?.animationTime;
    animationChecks['seekPassed'] =
        sought != null && (sought.animationTime - 2.5).abs() < .00001;
    setState(() => animationEnabled = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final running = HtmlModelCanvas.cameraPoseFor(cameraKey, modelId: modelId);
    animationChecks['playingTime'] = running?.animationTime;
    animationChecks['playPassed'] =
        running != null && (running.animationTime - 2.5).abs() > .1;
    setState(() => animationEnabled = false);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    final paused = HtmlModelCanvas.cameraPoseFor(cameraKey, modelId: modelId);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final stable = HtmlModelCanvas.cameraPoseFor(cameraKey, modelId: modelId);
    animationChecks['pausedTime'] = paused?.animationTime;
    animationChecks['stableTime'] = stable?.animationTime;
    animationChecks['pausePassed'] = paused != null &&
        stable != null &&
        (paused.animationTime - stable.animationTime).abs() < .00001;
    _phase(animationChecks['seekPassed'] == true &&
            animationChecks['playPassed'] == true &&
            animationChecks['pausePassed'] == true
        ? 'PASS: native GPU recovery + explicit seek, play and pause'
        : 'FAILED: animation seek/play/pause synchronization');
    if (animationChecks['seekPassed'] == true &&
        animationChecks['playPassed'] == true &&
        animationChecks['pausePassed'] == true) {
      unawaited(_checkLongSession());
    }
  }

  Future<void> _checkLongSession() async {
    var maximumConnected = 0;
    for (var index = 1; index <= 50; index++) {
      if (!mounted) return;
      setState(() {
        sceneIndex = index;
        phase = 'Long session: rebuilding scene $index / 50';
      });
      ModelViewerCameraPose? pose;
      for (var wait = 0; wait < 80; wait++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        pose = HtmlModelCanvas.cameraPoseFor(sceneCameraKey, modelId: modelId);
        if (pose != null && (pose.animationTime - clipTime).abs() < .00001)
          break;
      }
      final connected = html.document.querySelectorAll('model-viewer').length;
      if (connected > maximumConnected) maximumConnected = connected;
      if (pose == null ||
          connected != 1 ||
          (pose.animationTime - clipTime).abs() >= .00001 ||
          (pose.fieldOfView - 51).abs() >= .00001 ||
          (pose.radius - 4).abs() >= .00001) {
        longSession.addAll({
          'completed': index - 1,
          'failedAt': index,
          'connectedViewers': connected,
          'pose': _poseJson(pose)
        });
        _phase('FAILED: long-session scene lifecycle');
        return;
      }
      longSession['completed'] = index;
    }
    setState(() => showModel = false);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final remaining = html.document.querySelectorAll('model-viewer').length;
    longSession.addAll({
      'maximumConnectedViewers': maximumConnected,
      'remainingAfterDispose': remaining,
      'passed': remaining == 0 && maximumConnected == 1
    });
    _phase(remaining == 0 && maximumConnected == 1
        ? 'PASS: native recovery, animation controls and 50 scene disposals'
        : 'FAILED: viewer retained after final disposal');
  }

  bool _samePose(ModelViewerCameraPose? a, ModelViewerCameraPose? b) {
    if (a == null || b == null || a.animationName != b.animationName)
      return false;
    final first = [
      a.theta,
      a.phi,
      a.radius,
      a.targetX,
      a.targetY,
      a.targetZ,
      a.fieldOfView,
      a.turntableRotation,
      a.animationTime
    ];
    final second = [
      b.theta,
      b.phi,
      b.radius,
      b.targetX,
      b.targetY,
      b.targetZ,
      b.fieldOfView,
      b.turntableRotation,
      b.animationTime
    ];
    for (var i = 0; i < first.length; i++) {
      if (!(first[i] - second[i]).abs().isFinite ||
          (first[i] - second[i]).abs() > .00001) return false;
    }
    return true;
  }

  Map<String, Object?>? _poseJson(ModelViewerCameraPose? pose) => pose == null
      ? null
      : {
          'theta': pose.theta,
          'phi': pose.phi,
          'radius': pose.radius,
          'targetX': pose.targetX,
          'targetY': pose.targetY,
          'targetZ': pose.targetZ,
          'fov': pose.fieldOfView,
          'turntable': pose.turntableRotation,
          'clipTime': pose.animationTime,
          'clip': pose.animationName,
        };

  @override
  void dispose() {
    poll?.cancel();
    lossTimer?.cancel();
    restoreTimer?.cancel();
    verifyTimer?.cancel();
    unawaited(lossSubscription?.cancel());
    unawaited(restoreSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text(
                'Local GPU context recovery — original rigged pilot')),
        body: SingleChildScrollView(
            child: Center(
                child: SizedBox(
                    width: 760,
                    child: Column(children: [
                      Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(phase,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold))),
                      SizedBox(
                          width: 620,
                          height: 400,
                          child: showModel
                              ? HtmlModelCanvas(
                                  key: ValueKey(sceneIndex),
                                  modelId: modelId,
                                  cameraStateKey: sceneCameraKey,
                                  animationEnabled: animationEnabled,
                                  animationTime: clipTime,
                                  animationName: 'RotorSpin',
                                  autoRotate: false,
                                  rotationSpeed: 30,
                                  zoom: 1,
                                  cameraRadius: 4,
                                  turntableRotation: .7,
                                  fieldOfView: 51,
                                  exposure: 1.2,
                                  environmentImage: null,
                                  orbitEnabled: false,
                                  tourEnabled: true,
                                  tourInteractive: false,
                                  orbitTheta: 32,
                                  orbitPhi: 67,
                                  targetX: 0,
                                  targetY: .5,
                                  targetZ: 0,
                                )
                              : const Center(child: Text('Scene disposed'))),
                      Text(const JsonEncoder.withIndent('  ').convert({
                        'nativeLoss': nativeLoss,
                        'nativeRestore': nativeRestore,
                        'contextLostBefore': lostBefore,
                        'contextLostDuring': lostDuring,
                        'contextLostAfter': lostAfter,
                        'before': _poseJson(before),
                        'after': _poseJson(after),
                        'animationControls': animationChecks,
                        'longSession': longSession,
                      })),
                      ValueListenableBuilder<List<String>>(
                          valueListenable: errors,
                          builder: (_, values, __) => Text(values.isEmpty
                              ? 'No Flutter runtime errors'
                              : values.join('\n'))),
                      const Text(
                          'Controlled WebGL extension test; no physical driver failure or GPU energy claim.'),
                    ])))),
      );
}
