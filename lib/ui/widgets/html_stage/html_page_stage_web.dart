// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import '../../../models/slide_model.dart';
import '../../../services/model_asset_service.dart';
import '../../../services/remote_image_sources.dart';
import '../../../services/remote_model_sources.dart';
import 'html_stage_document.dart';

const String _modelViewerScriptMarker = 'data-sutol-model-viewer-loader';

void _ensureModelViewerLoaded() {
  final existing = html.document.querySelector(
    'script[$_modelViewerScriptMarker], '
    'script[src="$sutolModelViewerScriptUrl"]',
  );
  if (existing != null) return;
  final script = html.ScriptElement()
    ..type = 'module'
    ..src = sutolModelViewerScriptUrl
    ..setAttribute(_modelViewerScriptMarker, 'true');
  (html.document.head ?? html.document.body)?.append(script);
}

class HtmlPageTransitionStage extends StatefulWidget {
  const HtmlPageTransitionStage({
    super.key,
    required this.from,
    required this.to,
    required this.kind,
    required this.durationMs,
    this.onReady,
  });

  final PresentationPage from;
  final PresentationPage to;
  final PresentationTransitionKind kind;
  final int durationMs;
  final VoidCallback? onReady;

  @override
  State<HtmlPageTransitionStage> createState() =>
      _HtmlPageTransitionStageState();
}

class _HtmlPageTransitionStageState extends State<HtmlPageTransitionStage> {
  static int _viewCounter = 0;
  late final String _viewType;
  late final html.IFrameElement _iframe;
  StreamSubscription<html.Event>? _loadSubscription;

  @override
  void initState() {
    super.initState();
    _viewType = 'sutol-html-transition-${_viewCounter++}';
    _iframe = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.right = '0'
      ..style.bottom = '0'
      ..style.left = '0'
      ..style.border = '0'
      ..style.pointerEvents = 'none'
      ..setAttribute('scrolling', 'no');
    _loadSubscription = _iframe.onLoad.listen((_) => widget.onReady?.call());
    _render();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
    // Safety fallback: ensure onReady fires even if onLoad doesn't trigger for srcdoc
    Timer.run(() {
      if (mounted) {
        widget.onReady?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HtmlPageTransitionStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.from != widget.from ||
        oldWidget.to != widget.to ||
        oldWidget.kind != widget.kind ||
        oldWidget.durationMs != widget.durationMs) {
      _render();
    }
  }

  void _render() {
    _iframe.srcdoc = buildHtmlPageTransitionDocument(
      from: widget.from,
      to: widget.to,
      kind: widget.kind,
      durationMs: widget.durationMs,
      modelSourcesById: RemoteModelSources.all,
      imageSourcesById: RemoteImageSources.all,
    );
  }

  @override
  void dispose() {
    unawaited(_loadSubscription?.cancel());
    _iframe.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}

class HtmlPageStage extends StatefulWidget {
  const HtmlPageStage({
    super.key,
    required this.page,
    this.selectedTextBlockId,
    this.inlineEditingTextBlockId,
    this.selectedComponentBlockId,
    this.visibleRevealStep,
    this.showBadge = true,
    this.showBackground = true,
    this.renderMode = HtmlStageRenderMode.full,
    this.onTap,
    this.cssTransform = 'none',
    this.cssOpacity = 1,
    this.cssClipPath,
    this.cssTransformOrigin = 'center center',
    this.tourPointPlacementEnabled = false,
    this.tourSurfacePickPosition,
    this.tourSurfacePickGeneration = 0,
    this.onTourSurfacePointPicked,
    this.onTourSurfacePickMissed,
    this.onTourInteraction,
    this.onTourHotspot,
    this.tourInteractionEnabled = false,
    this.tourCameraTheta,
    this.tourCameraPhi,
    this.tourCameraTargetX,
    this.tourCameraTargetY,
    this.tourCameraTargetZ,
    this.tourCameraZoom,
    this.tourCameraRevision = 0,
  });

  final PresentationPage page;
  final String? selectedTextBlockId;
  final String? inlineEditingTextBlockId;
  final String? selectedComponentBlockId;
  final int? visibleRevealStep;
  final bool showBadge;
  final bool showBackground;
  final HtmlStageRenderMode renderMode;
  final VoidCallback? onTap;
  final String cssTransform;
  final double cssOpacity;
  final String? cssClipPath;
  final String cssTransformOrigin;
  final bool tourPointPlacementEnabled;
  final Offset? tourSurfacePickPosition;
  final int tourSurfacePickGeneration;
  final ValueChanged<ModelTourSurfacePoint>? onTourSurfacePointPicked;
  final VoidCallback? onTourSurfacePickMissed;
  final VoidCallback? onTourInteraction;
  final ValueChanged<String>? onTourHotspot;
  final bool tourInteractionEnabled;
  final double? tourCameraTheta;
  final double? tourCameraPhi;
  final double? tourCameraTargetX;
  final double? tourCameraTargetY;
  final double? tourCameraTargetZ;
  final double? tourCameraZoom;
  final int tourCameraRevision;

  @override
  State<HtmlPageStage> createState() => _HtmlPageStageState();
}

/// Renders the selected scene directly instead of through a nested `srcdoc`
/// iframe. The editor uses this layer so every browser paints the chosen
/// background immediately.
class HtmlLiveBackground extends StatefulWidget {
  const HtmlLiveBackground({
    super.key,
    required this.kind,
    this.animationEnabled = true,
    this.animationSpeed = 1,
    this.colorsInverted = false,
  });

  final PresentationBackgroundKind kind;
  final bool animationEnabled;
  final double animationSpeed;
  final bool colorsInverted;

  @override
  State<HtmlLiveBackground> createState() => _HtmlLiveBackgroundState();
}

class _HtmlLiveBackgroundState extends State<HtmlLiveBackground> {
  static int _viewCounter = 0;

  late final String _viewType;
  late final html.DivElement _hostElement;
  html.IFrameElement? _currentIframe;
  html.IFrameElement? _pendingIframe;
  StreamSubscription<html.Event>? _pendingLoadSubscription;
  Timer? _readinessTimer;
  int _renderGeneration = 0;

  @override
  void initState() {
    super.initState();
    _viewType = 'sutol-live-background-${_viewCounter++}';
    _hostElement = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..style.overflow = 'hidden'
      ..style.pointerEvents = 'none'
      ..style.backgroundColor = 'transparent';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _hostElement,
    );
    _queueDocument();
  }

  html.IFrameElement _createIframe() => html.IFrameElement()
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.position = 'absolute'
    ..style.top = '0'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.left = '0'
    ..style.border = '0'
    ..style.pointerEvents = 'none'
    ..style.backgroundColor = 'transparent'
    ..style.opacity = '0'
    ..style.visibility = 'hidden'
    ..setAttribute('scrolling', 'no')
    // The scene documents are bundled, trusted application HTML. Same-origin
    // access lets us verify that the new frame is actually painted before the
    // previous one is removed.
    ..setAttribute('sandbox', 'allow-scripts allow-same-origin');

  void _queueDocument() {
    _renderGeneration += 1;
    final generation = _renderGeneration;

    final previousSubscription = _pendingLoadSubscription;
    if (previousSubscription != null) {
      unawaited(previousSubscription.cancel());
    }
    _pendingLoadSubscription = null;
    _readinessTimer?.cancel();
    _readinessTimer = null;
    _pendingIframe?.remove();

    final nextIframe = _createIframe();
    _pendingIframe = nextIframe;
    var document = buildHtmlBackgroundSceneDocument(
      widget.kind,
      animationEnabled: widget.animationEnabled,
      animationSpeed: widget.animationSpeed,
      colorsInverted: widget.colorsInverted,
    );
    final marker =
        '<meta name="sutol-render-generation" content="$generation">';
    document = document.contains('</head>')
        ? document.replaceFirst('</head>', '$marker</head>')
        : '$marker$document';

    bool isReady() {
      try {
        final frameDocument =
            (nextIframe.contentWindow as dynamic).document as html.Document?;
        if (frameDocument == null || frameDocument.readyState != 'complete') {
          return false;
        }
        return frameDocument
                .querySelector('meta[name="sutol-render-generation"]')
                ?.getAttribute('content') ==
            '$generation';
      } catch (_) {
        return false;
      }
    }

    void commitWhenPainted({bool loaded = false}) {
      if (!mounted ||
          generation != _renderGeneration ||
          _pendingIframe != nextIframe ||
          (!loaded && !isReady())) {
        return;
      }
      // A completed document can still be one compositor frame away from
      // appearing. Two animation frames keep Chrome's unpainted grey surface
      // permanently hidden behind the previous background.
      html.window.requestAnimationFrame((_) {
        html.window.requestAnimationFrame((_) {
          if (!mounted ||
              generation != _renderGeneration ||
              _pendingIframe != nextIframe) {
            return;
          }
          _readinessTimer?.cancel();
          _readinessTimer = null;
          final subscription = _pendingLoadSubscription;
          _pendingLoadSubscription = null;
          if (subscription != null) {
            unawaited(subscription.cancel());
          }
          nextIframe.style
            ..visibility = 'visible'
            ..opacity = '1';
          final previousIframe = _currentIframe;
          _currentIframe = nextIframe;
          _pendingIframe = null;
          previousIframe?.remove();
        });
      });
    }

    _pendingLoadSubscription = nextIframe.onLoad.listen(
      (_) => commitWhenPainted(loaded: true),
    );
    _hostElement.children.add(nextIframe);
    nextIframe.srcdoc = document;

    // Some Chrome versions miss `load` for rapidly replaced srcdoc frames.
    // Poll the generation marker, but never expose an unready iframe. If the
    // candidate fails, the last good frame remains visible.
    var checks = 0;
    _readinessTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (!mounted ||
            generation != _renderGeneration ||
            _pendingIframe != nextIframe) {
          timer.cancel();
          return;
        }
        checks += 1;
        if (isReady()) {
          timer.cancel();
          commitWhenPainted();
          return;
        }
        if (checks < 200) return;
        timer.cancel();
        final subscription = _pendingLoadSubscription;
        _pendingLoadSubscription = null;
        if (subscription != null) {
          unawaited(subscription.cancel());
        }
        nextIframe.remove();
        if (_pendingIframe == nextIframe) _pendingIframe = null;
        _readinessTimer = null;
      },
    );
  }

  @override
  void didUpdateWidget(covariant HtmlLiveBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind ||
        oldWidget.animationEnabled != widget.animationEnabled ||
        oldWidget.animationSpeed != widget.animationSpeed ||
        oldWidget.colorsInverted != widget.colorsInverted) {
      _queueDocument();
    }
  }

  @override
  void dispose() {
    _renderGeneration += 1;
    final subscription = _pendingLoadSubscription;
    if (subscription != null) unawaited(subscription.cancel());
    _readinessTimer?.cancel();
    _hostElement.children.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}

class HtmlBackgroundPreview extends StatefulWidget {
  const HtmlBackgroundPreview({
    super.key,
    required this.kind,
    required this.onTap,
  });

  final PresentationBackgroundKind kind;
  final VoidCallback onTap;

  @override
  State<HtmlBackgroundPreview> createState() => _HtmlBackgroundPreviewState();
}

class HtmlComponentPreview extends StatefulWidget {
  const HtmlComponentPreview({
    super.key,
    required this.kind,
  });

  final PresentationComponentKind kind;

  @override
  State<HtmlComponentPreview> createState() => _HtmlComponentPreviewState();
}

/// Editör tuvalinde bir 3B modeli iframe oluşturmadan, doğrudan şeffaf bir
/// `<model-viewer>` platform öğesinde gösterir. Böylece iframe'in beyaz belge
/// yüzeyi slayt arka planını kapatmaz.
class HtmlModelCanvas extends StatefulWidget {
  const HtmlModelCanvas({
    super.key,
    required this.modelId,
    required this.animationEnabled,
    required this.autoRotate,
    required this.rotationSpeed,
    required this.zoom,
    this.cameraRadius,
    this.turntableRotation = 0,
    this.fieldOfView = 45,
    this.cameraStateKey,
    required this.exposure,
    required this.environmentImage,
    required this.orbitEnabled,
    required this.tourEnabled,
    required this.tourInteractive,
    required this.orbitTheta,
    required this.orbitPhi,
    required this.targetX,
    required this.targetY,
    required this.targetZ,
    this.pickSurfacePosition = false,
    this.onSurfacePositionPicked,
    this.onSurfacePickMissed,
  });

  final String modelId;
  final bool animationEnabled;
  final bool autoRotate;
  final double rotationSpeed;
  final double zoom;
  final double? cameraRadius;
  final double turntableRotation;
  final double fieldOfView;
  final String? cameraStateKey;
  final double exposure;
  final String? environmentImage;
  final bool orbitEnabled;
  final bool tourEnabled;
  final bool tourInteractive;
  final double orbitTheta;
  final double orbitPhi;
  final double targetX;
  final double targetY;
  final double targetZ;
  final bool pickSurfacePosition;
  final ValueChanged<ModelTourSurfacePoint>? onSurfacePositionPicked;
  final VoidCallback? onSurfacePickMissed;

  /// Returns the exact, currently painted model-viewer camera for the visible
  /// editor canvas. Preview thumbnails never register a key, so they cannot
  /// overwrite the authoritative editor pose.
  static ModelViewerCameraPose? cameraPoseFor(String cameraStateKey) =>
      _HtmlModelCanvasState.cameraPoseFor(cameraStateKey);

  @override
  State<HtmlModelCanvas> createState() => _HtmlModelCanvasState();
}

class _HtmlModelCanvasState extends State<HtmlModelCanvas> {
  static final Map<String, _ModelCanvasGeometry> _geometryByModelId =
      <String, _ModelCanvasGeometry>{};
  static final Map<String, _HtmlModelCanvasState> _statesByCameraKey =
      <String, _HtmlModelCanvasState>{};
  static final Map<String, ModelViewerCameraPose> _posesByCameraKey =
      <String, ModelViewerCameraPose>{};

  static ModelViewerCameraPose? cameraPoseFor(String cameraStateKey) {
    final state = _statesByCameraKey[cameraStateKey];
    return state?._captureCameraPose() ?? _posesByCameraKey[cameraStateKey];
  }

  html.Element? _modelViewer;
  StreamSubscription<html.Event>? _modelLoadSubscription;
  StreamSubscription<html.Event>? _modelErrorSubscription;
  StreamSubscription<html.MouseEvent>? _surfacePickSubscription;
  html.ResizeObserver? _resizeObserver;
  final List<Timer> _cameraRestoreTimers = <Timer>[];
  double _modelWidth = 1;
  double _modelHeight = 1;
  double _modelDepth = 1;
  double _modelCenterX = 0;
  double _modelCenterY = 0;
  double _modelCenterZ = 0;
  bool _modelGeometryReady = false;
  bool _preserveLiveTurntableUntilCaptured = false;

  void _restoreCachedGeometry() {
    final geometry = _geometryByModelId[widget.modelId];
    if (geometry == null) return;
    _modelWidth = geometry.width;
    _modelHeight = geometry.height;
    _modelDepth = geometry.depth;
    _modelCenterX = geometry.centerX;
    _modelCenterY = geometry.centerY;
    _modelCenterZ = geometry.centerZ;
    _modelGeometryReady = true;
  }

  String get _savedCameraOrbit {
    final exactRadius = widget.cameraRadius;
    final radiusText = exactRadius != null &&
            exactRadius.isFinite &&
            exactRadius > 0
        ? '${exactRadius.toStringAsFixed(7)}m'
        : '${(100 / widget.zoom.clamp(0.5, 10.0)).clamp(10, 200).toStringAsFixed(2)}%';
    return '${widget.orbitTheta.toStringAsFixed(5)}deg '
        '${widget.orbitPhi.toStringAsFixed(5)}deg $radiusText';
  }

  bool get _hasExactCameraPose {
    final radius = widget.cameraRadius;
    return widget.tourEnabled &&
        radius != null &&
        radius.isFinite &&
        radius > 0;
  }

  bool _refreshingExpiredSource = false;
  bool _hasRetriedLoadError = false;

  void _setAttribute(String name, String value) {
    final element = _modelViewer;
    if (element == null || element.getAttribute(name) == value) return;
    element.setAttribute(name, value);
  }

  void _removeAttribute(String name) {
    final element = _modelViewer;
    if (element == null || !element.attributes.containsKey(name)) return;
    element.attributes.remove(name);
  }

  @override
  void initState() {
    super.initState();
    _ensureModelViewerLoaded();
    _registerCameraState();
    RemoteModelSources.revision.addListener(_applyAttributes);
  }

  @override
  void didUpdateWidget(covariant HtmlModelCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoRotate && !widget.autoRotate && widget.tourEnabled) {
      _preserveLiveTurntableUntilCaptured = true;
    } else if (_preserveLiveTurntableUntilCaptured &&
        (oldWidget.modelId != widget.modelId ||
            oldWidget.turntableRotation != widget.turntableRotation ||
            oldWidget.cameraRadius != widget.cameraRadius)) {
      _preserveLiveTurntableUntilCaptured = false;
    }
    if (oldWidget.cameraStateKey != widget.cameraStateKey) {
      _unregisterCameraState(oldWidget.cameraStateKey);
      _registerCameraState();
    }
    if (oldWidget.modelId != widget.modelId) {
      _modelGeometryReady = false;
      _restoreCachedGeometry();
    }
    _applyAttributes();
    if (oldWidget.modelId != widget.modelId ||
        oldWidget.orbitTheta != widget.orbitTheta ||
        oldWidget.orbitPhi != widget.orbitPhi ||
        oldWidget.targetX != widget.targetX ||
        oldWidget.targetY != widget.targetY ||
        oldWidget.targetZ != widget.targetZ ||
        oldWidget.zoom != widget.zoom ||
        oldWidget.cameraRadius != widget.cameraRadius ||
        oldWidget.turntableRotation != widget.turntableRotation ||
        oldWidget.fieldOfView != widget.fieldOfView) {
      _jumpCameraToSavedPose();
    }
  }

  void _registerCameraState() {
    final key = widget.cameraStateKey;
    if (key != null && key.isNotEmpty) _statesByCameraKey[key] = this;
  }

  void _unregisterCameraState([String? key]) {
    final resolvedKey = key ?? widget.cameraStateKey;
    if (resolvedKey != null && _statesByCameraKey[resolvedKey] == this) {
      _statesByCameraKey.remove(resolvedKey);
    }
  }

  ModelViewerCameraPose? _captureCameraPose() {
    final element = _modelViewer;
    final key = widget.cameraStateKey;
    if (element == null || key == null || key.isEmpty) return null;
    try {
      final viewer = element as JSObject;
      final orbit = viewer.callMethod<JSObject>('getCameraOrbit'.toJS);
      final target = viewer.callMethod<JSObject>('getCameraTarget'.toJS);
      final fieldOfView =
          viewer.callMethod<JSNumber>('getFieldOfView'.toJS).toDartDouble;
      final turntableRotationValue =
          viewer.getProperty<JSAny?>('turntableRotation'.toJS);
      if (turntableRotationValue is! JSNumber) {
        return _posesByCameraKey[key];
      }
      final pose = ModelViewerCameraPose(
        theta: _jsCoordinate(orbit, 'theta') * 180 / math.pi,
        phi: _jsCoordinate(orbit, 'phi') * 180 / math.pi,
        radius: _jsCoordinate(orbit, 'radius'),
        targetX: _jsCoordinate(target, 'x'),
        targetY: _jsCoordinate(target, 'y'),
        targetZ: _jsCoordinate(target, 'z'),
        turntableRotation: turntableRotationValue.toDartDouble,
        fieldOfView: fieldOfView,
      );
      if (!pose.theta.isFinite ||
          !pose.phi.isFinite ||
          !pose.radius.isFinite ||
          pose.radius <= 0 ||
          !pose.targetX.isFinite ||
          !pose.targetY.isFinite ||
          !pose.targetZ.isFinite ||
          !pose.turntableRotation.isFinite ||
          !pose.fieldOfView.isFinite ||
          pose.fieldOfView <= 0 ||
          pose.fieldOfView >= 180) {
        return _posesByCameraKey[key];
      }
      _posesByCameraKey[key] = pose;
      return pose;
    } catch (_) {
      return _posesByCameraKey[key];
    }
  }

  void _setBooleanAttribute(String name, bool enabled) {
    final element = _modelViewer;
    if (element == null) return;
    if (enabled) {
      if (!element.attributes.containsKey(name)) element.setAttribute(name, '');
    } else {
      _removeAttribute(name);
    }
  }

  void _applyAttributes() {
    final element = _modelViewer;
    if (element == null) return;
    element.style.pointerEvents = widget.pickSurfacePosition ? 'auto' : 'none';
    element.style.cursor = widget.pickSurfacePosition ? 'crosshair' : 'default';
    element.style.touchAction = widget.tourEnabled ? 'none' : 'auto';
    final source = RemoteModelSources.sourceFor(widget.modelId);
    if (source == null || source.isEmpty) {
      _removeAttribute('src');
    } else {
      // `src`yi aynı değerle tekrar yazmak model-viewer'ın GLB'yi yeniden
      // değerlendirmesine ve büyük modellerde sürüklemenin takılmasına yol
      // açabiliyor. Yalnızca kaynak gerçekten değiştiğinde güncelle.
      if (element.getAttribute('src') != source) {
        if (!_geometryByModelId.containsKey(widget.modelId)) {
          _modelGeometryReady = false;
        }
        _setAttribute('src', source);
      }
    }
    _setAttribute('alt', widget.modelId);
    _setAttribute('camera-orbit', _savedCameraOrbit);
    _setAttribute(
      'min-camera-orbit',
      widget.tourEnabled ? 'auto 42deg 5%' : 'auto auto 1%',
    );
    _setAttribute(
      'max-camera-orbit',
      widget.tourEnabled ? 'auto 89deg 250%' : 'auto auto 250%',
    );
    _setAttribute(
      'data-sutol-tour-ground',
      widget.tourEnabled ? 'true' : 'false',
    );
    _applyCameraTarget();
    _setAttribute('interaction-prompt', 'none');
    _setAttribute('orbit-sensitivity', widget.tourEnabled ? '0.78' : '1');
    _setAttribute('zoom-sensitivity', widget.tourEnabled ? '0.72' : '1');
    _setAttribute('loading', 'eager');
    _setAttribute('reveal', 'auto');
    _setAttribute('shadow-intensity', '1');
    _setAttribute('shadow-softness', '0.8');
    _setAttribute('tone-mapping', 'neutral');
    _setAttribute('exposure', widget.exposure.toStringAsFixed(4));
    _setAttribute(
      'field-of-view',
      '${widget.fieldOfView.clamp(1.0, 179.0).toStringAsFixed(5)}deg',
    );
    _setAttribute(
      'rotation-per-second',
      '${widget.rotationSpeed.toStringAsFixed(1)}deg',
    );
    final environmentImage = widget.environmentImage;
    if (environmentImage == null || environmentImage.isEmpty) {
      _removeAttribute('environment-image');
    } else {
      _setAttribute('environment-image', environmentImage);
    }
    _setBooleanAttribute('autoplay', widget.animationEnabled);
    _setBooleanAttribute('auto-rotate', widget.autoRotate);
    // Tur modu da sahne içinde doğrudan keşif gerektirir. Bu nitelik yalnızca
    // "Manuel Kontrol" açıkken verildiğinde, kaydedilmiş bir sanal tur
    // paylaşım/önizleme ekranında hareketsiz kalıyordu.
    _setBooleanAttribute(
      'camera-controls',
      (widget.orbitEnabled || widget.tourInteractive) &&
          !widget.pickSurfacePosition,
    );
    _setBooleanAttribute('disable-pan', widget.tourEnabled);
    if (widget.autoRotate) {
      _setAttribute('auto-rotate-delay', '0');
    } else {
      _removeAttribute('auto-rotate-delay');
    }
  }

  Future<void> _refreshSourceAfterLoadError() async {
    // `sourceFor` deliberately rejects an expired signed URL. For renewal we
    // still need its object key, which is retained by `sourceForRefresh`.
    final source = RemoteModelSources.sourceForRefresh(widget.modelId);
    if (source == null || source.isEmpty || _refreshingExpiredSource) return;

    // A signed URL can expire while this editor stays open. Retry once with a
    // fresh authorization; do not turn a corrupt GLB into an endless loop.
    if (_hasRetriedLoadError) return;
    _hasRetriedLoadError = true;
    _refreshingExpiredSource = true;
    try {
      final refreshed = await ModelAssetService.generateSignedUrl(
        source,
        forceRefresh: true,
      );
      if (refreshed != null && refreshed.trim().isNotEmpty) {
        RemoteModelSources.registerAll(<String, String>{
          widget.modelId: refreshed.trim(),
        });
      }
    } catch (_) {
      // Keep the editor usable; a subsequent hydration can retry normally.
    } finally {
      _refreshingExpiredSource = false;
    }
  }

  void _refreshModelGeometry() {
    final element = _modelViewer;
    if (element == null) return;
    try {
      // `model-viewer` bir Web Component olduğu için özel metotları
      // dart:html'ın statik Element API'sinde bulunmuyor. Açık JS interop
      // kullanmak, özellikle release derlemesinde dinamik çağrının sessizce
      // başarısız olup kamera hedefini merkezde bırakmasını önler.
      final viewer = element as JSObject;
      final dimensions = viewer.callMethod<JSObject>('getDimensions'.toJS);
      final center = viewer.callMethod<JSObject>(
        'getBoundingBoxCenter'.toJS,
      );
      _modelWidth = _jsCoordinate(dimensions, 'x');
      _modelHeight = _jsCoordinate(dimensions, 'y');
      _modelDepth = _jsCoordinate(dimensions, 'z');
      _modelCenterX = _jsCoordinate(center, 'x');
      _modelCenterY = _jsCoordinate(center, 'y');
      _modelCenterZ = _jsCoordinate(center, 'z');
      _modelGeometryReady = _modelWidth.isFinite &&
          _modelHeight.isFinite &&
          _modelDepth.isFinite &&
          _modelWidth > 0 &&
          _modelHeight > 0 &&
          _modelDepth > 0;
      if (_modelGeometryReady) {
        _geometryByModelId[widget.modelId] = _ModelCanvasGeometry(
          width: _modelWidth,
          height: _modelHeight,
          depth: _modelDepth,
          centerX: _modelCenterX,
          centerY: _modelCenterY,
          centerZ: _modelCenterZ,
        );
      }
      _applyCameraTarget();
      _jumpCameraToSavedPose();
      _captureCameraPose();
    } catch (_) {
      _modelGeometryReady = false;
    }
  }

  void _jumpCameraToSavedPose() {
    final element = _modelViewer;
    if (element == null) return;
    try {
      // model-viewer GLB yüklenince kısa süreliğine kendi ideal kamerasına
      // dönebilir. Kayıtlı orbit/target değerini anında hedefe uygulamak ana
      // tuval, küçük resim ve sayfaya geri dönüş görünümünü aynı tutar.
      _applyCameraGoalProperties();
      (element as JSObject).callMethod<JSAny?>(
        'jumpCameraToGoal'.toJS,
      );
      _captureCameraPose();
    } catch (_) {
      // Eski model-viewer sürümlerinde metot bulunmayabilir; attribute tabanlı
      // kamera uygulaması çalışmaya devam eder.
    }
  }

  void _scheduleSavedCameraRestore() {
    for (final timer in _cameraRestoreTimers) {
      timer.cancel();
    }
    _cameraRestoreTimers.clear();

    // Web component'in yükseltilmesi, GLB load olayı ve bounding-box hesabı
    // aynı anda tamamlanmayabilir. Özellikle sayfadan çıkıp geri girerken ilk
    // deneme erken kalırsa model ideal/uzak kamerada görünüyordu. Birkaç kısa
    // doğrulama geçişiyle son kaydedilen kamera kesin olarak geri yüklenir.
    for (final delay in const <Duration>[
      Duration.zero,
      Duration(milliseconds: 50),
      Duration(milliseconds: 150),
      Duration(milliseconds: 350),
      Duration(milliseconds: 750),
      Duration(milliseconds: 1200),
    ]) {
      _cameraRestoreTimers.add(Timer(delay, () {
        if (!mounted || _modelViewer == null) return;
        _applyAttributes();
        _refreshModelGeometry();
      }));
    }
  }

  double _jsCoordinate(JSObject vector, String axis) {
    final value = vector.getProperty<JSAny?>(axis.toJS);
    if (value is! JSNumber) {
      throw StateError('model-viewer $axis koordinatı sayı değil');
    }
    return value.toDartDouble;
  }

  void _applyCameraTarget() {
    if (!_modelGeometryReady) {
      _setAttribute('camera-target', 'auto auto auto');
      return;
    }
    // Sanal tur hedefleri modelin gerçek yerel metre koordinatlarıdır. Normal
    // model görünümündeki hedefler ise eski proje uyumluluğu için bounding-box
    // yüzdesi olarak tutulur. Turdan çıkarken metre değerlerini yeniden yüzde
    // gibi ölçeklemek kamerayı bambaşka bir noktaya sıçratıyordu.
    final tourInsetX = math.min(_modelWidth * .08, .75);
    final tourInsetZ = math.min(_modelDepth * .08, .75);
    final tourHalfX = math.max(.125, _modelWidth / 2 - tourInsetX);
    final tourHalfZ = math.max(.125, _modelDepth / 2 - tourInsetZ);
    // Once a rendered pose has been captured, its radius and target are all
    // absolute model-space values. Recomputing only Y from the bounding box (or
    // clamping X/Z again) changes the point the camera orbits around and makes
    // the presentation open on a visibly different part of the same model.
    // A null radius marks legacy/percentage-based poses, which still need the
    // original ground and safe-bounds calculation until their first capture.
    final x = _hasExactCameraPose
        ? widget.targetX
        : widget.tourEnabled
            ? widget.targetX
                .clamp(_modelCenterX - tourHalfX, _modelCenterX + tourHalfX)
                .toDouble()
            : _modelCenterX + _modelWidth * widget.targetX / 100;
    final y = _hasExactCameraPose
        ? widget.targetY
        : widget.tourEnabled
            ? _modelCenterY - _modelHeight / 2
            : _modelCenterY + _modelHeight * widget.targetY / 100;
    final z = _hasExactCameraPose
        ? widget.targetZ
        : widget.tourEnabled
            ? widget.targetZ
                .clamp(_modelCenterZ - tourHalfZ, _modelCenterZ + tourHalfZ)
                .toDouble()
            : _modelCenterZ + _modelDepth * widget.targetZ / 100;
    final cameraTarget = '${x.toStringAsFixed(5)}m ${y.toStringAsFixed(5)}m '
        '${z.toStringAsFixed(5)}m';
    _setAttribute('camera-target', cameraTarget);
    _applyCameraGoalProperties(cameraTarget: cameraTarget);
  }

  void _applyCameraGoalProperties({String? cameraTarget}) {
    final element = _modelViewer;
    if (element == null) return;
    try {
      final viewer = element as JSObject;
      // Attribute yansıtması yükleme döngüsünde gecikebilir. Public kamera
      // property'lerine de doğrudan yazmak, geri dönülen sayfanın kayıtlı
      // pozunu model-viewer için kesin hedef haline getirir.
      viewer.setProperty('cameraOrbit'.toJS, _savedCameraOrbit.toJS);
      final target = cameraTarget ?? element.getAttribute('camera-target');
      if (target != null && target.isNotEmpty) {
        viewer.setProperty('cameraTarget'.toJS, target.toJS);
      }
      viewer.setProperty(
        'fieldOfView'.toJS,
        '${widget.fieldOfView.clamp(1.0, 179.0).toStringAsFixed(5)}deg'.toJS,
      );
      if (!_preserveLiveTurntableUntilCaptured && !widget.autoRotate) {
        final turntable =
            widget.turntableRotation.isFinite ? widget.turntableRotation : 0.0;
        viewer.callMethod<JSAny?>(
          'resetTurntableRotation'.toJS,
          turntable.toJS,
        );
      }
    } catch (_) {
      // Attribute tabanlı uygulama eski model-viewer sürümleri için yedektir.
    }
  }

  @override
  void dispose() {
    _captureCameraPose();
    _unregisterCameraState();
    RemoteModelSources.revision.removeListener(_applyAttributes);
    final modelLoadSubscription = _modelLoadSubscription;
    if (modelLoadSubscription != null) {
      unawaited(modelLoadSubscription.cancel());
    }
    unawaited(_modelErrorSubscription?.cancel());
    unawaited(_surfacePickSubscription?.cancel());
    for (final timer in _cameraRestoreTimers) {
      timer.cancel();
    }
    _cameraRestoreTimers.clear();
    _resizeObserver?.disconnect();
    _resizeObserver = null;
    _modelViewer?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'model-viewer',
      onElementCreated: (element) {
        final modelViewer = element as html.Element;
        _restoreCachedGeometry();
        _modelViewer = modelViewer
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'block'
          ..style.backgroundColor = 'transparent'
          ..style.pointerEvents = widget.pickSurfacePosition ? 'auto' : 'none'
          ..style.setProperty('contain', 'strict')
          ..style.setProperty('--poster-color', 'transparent');
        _resizeObserver = html.ResizeObserver((_, __) {
          if (!mounted || _modelViewer == null) return;
          final bounds = modelViewer.getBoundingClientRect();
          if (bounds.width <= 0 || bounds.height <= 0) return;
          // İlk sunum sayfası route/fullscreen yerleşimi tamamlanırken yeniden
          // boyutlanır. model-viewer bu sırada ideal kameraya dönebildiği için
          // kayıtlı hedefi her gerçek boyut değişiminden sonra tekrar uygula.
          _scheduleSavedCameraRestore();
        })
          ..observe(modelViewer);
        _modelLoadSubscription = modelViewer.on['load'].listen((_) {
          _scheduleSavedCameraRestore();
          _hasRetriedLoadError = false;
          _refreshModelGeometry();
        });
        _modelErrorSubscription = modelViewer.on['error'].listen((_) {
          unawaited(_refreshSourceAfterLoadError());
        });
        _surfacePickSubscription =
            modelViewer.onClick.listen(_pickSurfacePoint);
        _applyAttributes();
        _scheduleSavedCameraRestore();
      },
    );
  }

  void _pickSurfacePoint(html.MouseEvent event) {
    if (!widget.pickSurfacePosition || !_modelGeometryReady) return;
    final element = _modelViewer;
    if (element == null) return;
    try {
      final rect = element.getBoundingClientRect();
      final viewer = element as JSObject;
      final point = viewer.callMethod<JSObject?>(
        'positionAndNormalFromPoint'.toJS,
        (event.client.x - rect.left).toJS,
        (event.client.y - rect.top).toJS,
      );
      if (point == null) {
        widget.onSurfacePickMissed?.call();
        return;
      }
      final position = point.getProperty<JSObject?>('position'.toJS);
      if (position == null) {
        widget.onSurfacePickMissed?.call();
        return;
      }
      final x = _jsCoordinate(position, 'x');
      final y = _jsCoordinate(position, 'y');
      final z = _jsCoordinate(position, 'z');
      if (!x.isFinite || !y.isFinite || !z.isFinite) return;
      widget.onSurfacePositionPicked?.call(ModelTourSurfacePoint(
        x: x.clamp(-500.0, 500.0).toDouble(),
        y: y.clamp(-500.0, 500.0).toDouble(),
        z: z.clamp(-500.0, 500.0).toDouble(),
      ));
    } catch (_) {
      widget.onSurfacePickMissed?.call();
    }
  }
}

class _ModelCanvasGeometry {
  const _ModelCanvasGeometry({
    required this.width,
    required this.height,
    required this.depth,
    required this.centerX,
    required this.centerY,
    required this.centerZ,
  });

  final double width;
  final double height;
  final double depth;
  final double centerX;
  final double centerY;
  final double centerZ;
}

class _HtmlComponentPreviewState extends State<HtmlComponentPreview> {
  html.IFrameElement? _iframe;

  void _applyDocument() {
    _iframe?.srcdoc = buildHtmlComponentPreviewDocument(widget.kind);
  }

  @override
  void didUpdateWidget(covariant HtmlComponentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind) _applyDocument();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (element) {
        final iframe = element as html.IFrameElement
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = '0'
          ..style.pointerEvents = 'none'
          ..style.backgroundColor = 'transparent'
          ..setAttribute('loading', 'lazy')
          ..setAttribute('scrolling', 'no')
          ..setAttribute('sandbox', 'allow-scripts');
        _iframe = iframe;
        _applyDocument();
      },
    );
  }
}

class _HtmlBackgroundPreviewState extends State<HtmlBackgroundPreview> {
  static int _viewCounter = 0;

  late final String _viewType;
  late final html.DivElement _hostElement;
  late final html.IFrameElement _iframeElement;
  late final html.DivElement _tapOverlayElement;
  late final StreamSubscription<html.MouseEvent> _tapSubscription;

  @override
  void initState() {
    super.initState();
    _viewType = 'sutol-background-preview-${_viewCounter++}';
    _hostElement = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..style.overflow = 'hidden';
    _iframeElement = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.border = '0'
      ..style.pointerEvents = 'none'
      ..setAttribute('loading', 'lazy')
      ..setAttribute('scrolling', 'no')
      ..srcdoc = buildHtmlBackgroundPreviewDocument(widget.kind);
    _tapOverlayElement = html.DivElement()
      ..setAttribute('aria-label', 'Arka planı seç')
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.right = '0'
      ..style.bottom = '0'
      ..style.left = '0'
      ..style.cursor = 'pointer'
      ..style.backgroundColor = 'transparent';
    _tapSubscription = _tapOverlayElement.onClick.listen((event) {
      event
        ..preventDefault()
        ..stopPropagation();
      widget.onTap();
    });
    _hostElement.children.addAll(<html.Element>[
      _iframeElement,
      _tapOverlayElement,
    ]);

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _hostElement,
    );
  }

  @override
  void didUpdateWidget(covariant HtmlBackgroundPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kind != widget.kind) {
      _iframeElement.srcdoc = buildHtmlBackgroundPreviewDocument(widget.kind);
    }
  }

  @override
  void dispose() {
    unawaited(_tapSubscription.cancel());
    _hostElement.children.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

class _HtmlPageStageState extends State<HtmlPageStage> {
  static int _viewCounter = 0;

  late final String _viewType;
  late final html.DivElement _hostElement;
  late html.IFrameElement _iframeElement;
  html.IFrameElement? _pendingIframeElement;
  StreamSubscription<html.Event>? _pendingLoadSubscription;
  Timer? _pendingLoadTimer;
  StreamSubscription<html.MouseEvent>? _tapSubscription;
  int _renderGeneration = 0;
  bool _hasRendered = false;
  StreamSubscription<html.Event>? _initialLoadSubscription;
  Timer? _initialLoadTimer;
  StreamSubscription<html.MessageEvent>? _tourMessageSubscription;

  bool _usesDirectModelCanvas(PresentationComponentBlock block) {
    final modelId = block.modelAssetId;
    return widget.renderMode == HtmlStageRenderMode.preview &&
        modelId != null &&
        block.imageAssetId == null &&
        (!block.modelTourEnabled || block.modelTourFrozen) &&
        RemoteImageSources.sourceFor(modelId) == null &&
        RemoteModelSources.hasSignedSource(modelId);
  }

  List<PresentationComponentBlock> get _directModelBlocks {
    final revealStep = widget.visibleRevealStep;
    return widget.page.componentBlocks
        .where(
          (block) =>
              _usesDirectModelCanvas(block) &&
              (revealStep == null || block.revealStep <= revealStep),
        )
        .toList(growable: false);
  }

  PresentationPage get _documentPage {
    final components = widget.page.componentBlocks
        .where((block) => !_usesDirectModelCanvas(block))
        .toList(growable: false);
    return components.length == widget.page.componentBlocks.length
        ? widget.page
        : widget.page.copyWith(componentBlocks: components);
  }

  PresentationComponentBlock? get _cameraTourBlock {
    PresentationComponentBlock? firstTour;
    for (final block in widget.page.componentBlocks) {
      if (!_usesDirectModelCanvas(block) || !block.modelTourEnabled) continue;
      firstTour ??= block;
      if (!block.modelTourFrozen) return block;
    }
    return firstTour;
  }

  bool _usesRuntimeTourCamera(PresentationComponentBlock block) =>
      _cameraTourBlock?.id == block.id &&
      widget.tourCameraTheta != null &&
      widget.tourCameraPhi != null &&
      widget.tourCameraTargetX != null &&
      widget.tourCameraTargetY != null &&
      widget.tourCameraTargetZ != null;

  @override
  void initState() {
    super.initState();
    RemoteModelSources.revision.addListener(_onRemoteSourcesChanged);
    _tourMessageSubscription = html.window.onMessage.listen(_handleTourMessage);
    _viewType = 'sutol-html-stage-${_viewCounter++}';
    _hostElement = html.DivElement()
      ..className = 'sutol-html-host'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..style.pointerEvents =
          _shouldAllowIframeInteraction || widget.onTap != null
              ? 'auto'
              : 'none'
      ..style.overflow = 'hidden'
      ..style.backgroundColor = 'transparent';
    _applyVisualStyle();
    _iframeElement = _createIframe()
      ..style.opacity = '0'
      ..style.visibility = 'hidden';
    _hostElement.children.add(_iframeElement);
    if (widget.onTap != null) {
      final overlay = html.DivElement()
        ..setAttribute('aria-label', 'Şablonu seç')
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.left = '0'
        ..style.zIndex = '2'
        ..style.cursor = 'pointer'
        ..style.backgroundColor = 'transparent';
      _tapSubscription = overlay.onClick.listen((event) {
        event
          ..preventDefault()
          ..stopPropagation();
        widget.onTap?.call();
      });
      _hostElement.children.add(overlay);
    }

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _hostElement,
    );

    _render();
  }

  void _onRemoteSourcesChanged() {
    if (mounted) {
      setState(() {});
      _render();
    }
  }

  void _setTourPointPlacement(bool enabled) {
    final targetWindow = _iframeElement.contentWindow;
    if (targetWindow == null) return;
    targetWindow.postMessage(
      jsonEncode(<String, Object?>{
        'type': 'sutol-tour-placement',
        'enabled': enabled,
      }),
      '*',
    );
  }

  void _requestTourSurfacePick(Offset position) {
    if (!widget.tourPointPlacementEnabled) return;
    final targetWindow = _iframeElement.contentWindow;
    if (targetWindow == null) {
      widget.onTourSurfacePickMissed?.call();
      return;
    }
    // Iframe pointer-events kapalı kalsa bile model-viewer'ın kendi yüzey
    // çözümleyicisi gerçek geometri noktasını bulabilir. Böylece platform
    // görünümü Flutter HUD ve diyaloglarının üstüne çıkmaz.
    targetWindow.postMessage(
      jsonEncode(<String, Object?>{
        'type': 'sutol-tour-surface-pick',
        'x': position.dx,
        'y': position.dy,
      }),
      '*',
    );
  }

  void _applyTourCamera() {
    final theta = widget.tourCameraTheta;
    final phi = widget.tourCameraPhi;
    final targetX = widget.tourCameraTargetX;
    final targetY = widget.tourCameraTargetY;
    final targetZ = widget.tourCameraTargetZ;
    final zoom = widget.tourCameraZoom;
    if (theta == null ||
        phi == null ||
        targetX == null ||
        targetY == null ||
        targetZ == null) {
      return;
    }
    final targetWindow = _iframeElement.contentWindow;
    if (targetWindow == null) return;
    targetWindow.postMessage(
      jsonEncode(<String, Object>{
        'type': 'sutol-tour-camera',
        'theta': theta,
        'phi': phi,
        'targetX': targetX,
        'targetY': targetY,
        'targetZ': targetZ,
        if (zoom != null) 'zoom': zoom,
      }),
      '*',
    );
  }

  /// `srcdoc` belgesi veya model kaynağı, Flutter'ın önceki kamera mesajından
  /// sonra hazır olabilir. Bu durumda model-viewer başlangıç attribute'larına
  /// döner. Sahne her yüklendiğinde son tur durumunu tekrar göndermek, WASD
  /// tuşu bırakıldığında görünen bu geri sıçramayı önler.
  void _restoreTourRuntimeState() {
    if (!mounted) return;
    _setTourPointPlacement(widget.tourPointPlacementEnabled);
    _applyTourCamera();
  }

  void _handleTourMessage(html.MessageEvent event) {
    // Bazı Flutter web derlemelerinde `srcdoc` iframe'inin Window nesnesi
    // olayda eşitlik karşılaştırmasını geçmiyor. Yalnızca dar, isim alanlı
    // tur protokolünü kabul ederek yüzey seçimini bu tarayıcılarda da
    // güvenilir kılıyoruz.
    dynamic raw = event.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return;
      }
    }
    if (raw is! Map) return;
    final type = raw['type']?.toString();
    if (type == null || !type.startsWith('sutol-tour-')) return;
    if (type == 'sutol-tour-interaction') {
      widget.onTourInteraction?.call();
      return;
    }
    if (type == 'sutol-tour-surface-miss') {
      widget.onTourSurfacePickMissed?.call();
      return;
    }
    if (type == 'sutol-tour-hotspot') {
      final targetPageId = raw['targetPageId']?.toString().trim();
      if (targetPageId != null && targetPageId.isNotEmpty) {
        widget.onTourHotspot?.call(targetPageId);
      }
      return;
    }
    if (type != 'sutol-tour-surface-point') return;
    final x = (raw['x'] as num?)?.toDouble();
    final y = (raw['y'] as num?)?.toDouble();
    final z = (raw['z'] as num?)?.toDouble();
    if (x == null || y == null || z == null) {
      widget.onTourSurfacePickMissed?.call();
      return;
    }
    // Platform iframe'leri bazı web oluşturucularında Flutter'ın modal
    // katmanının üzerinde kalır. Diyalog açılmadan önce iframe'i anında
    // pasifleştirmek, "3B metin ekle" akışının tüm ekranı tıklanamaz hale
    // getirmesini önler. Bir sonraki widget güncellemesi de bu durumu korur.
    _iframeElement.style.pointerEvents = 'none';
    _pendingIframeElement?.style.pointerEvents = 'none';
    widget.onTourSurfacePointPicked?.call(
      ModelTourSurfacePoint(x: x, y: y, z: z),
    );
  }

  html.IFrameElement _createIframe() {
    final iframe = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.border = '0'
      ..style.backgroundColor = 'transparent'
      // Preview/tour ekranında Flutter katmanı kontrollerin ve 3B yüzey
      // seçiminin sahibidir. Iframe'i pasif tutmak platform görünümünün HUD
      // ile diyalogların üstüne çıkıp tıklamaları yutmasını önler.
      ..style.pointerEvents = _shouldAllowIframeInteraction ? 'auto' : 'none'
      ..setAttribute('scrolling', 'no');
    if (widget.onTap != null) {
      iframe.setAttribute('loading', 'lazy');
    }
    return iframe;
  }

  @override
  void didUpdateWidget(covariant HtmlPageStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyVisualStyle();
    _iframeElement.style.pointerEvents =
        _shouldAllowIframeInteraction ? 'auto' : 'none';
    _pendingIframeElement?.style.pointerEvents =
        _shouldAllowIframeInteraction ? 'auto' : 'none';
    final shouldRequestSurfacePick = oldWidget.tourSurfacePickGeneration !=
            widget.tourSurfacePickGeneration &&
        widget.tourSurfacePickPosition != null;
    if (oldWidget.tourPointPlacementEnabled !=
        widget.tourPointPlacementEnabled) {
      _setTourPointPlacement(widget.tourPointPlacementEnabled);
      // Yüzey seçimi bir çalışma zamanı durumu; burada iframe'i yeniden
      // yazmak platform görünümünü Flutter diyaloğunun üstüne taşıyordu.
      // İlk belge zaten bu ayarı içerir, sonraki değişiklikler postMessage ile
      // güvenle uygulanır.
      if (!shouldRequestSurfacePick) return;
    }
    if (shouldRequestSurfacePick) {
      _requestTourSurfacePick(widget.tourSurfacePickPosition!);
      return;
    }
    if (oldWidget.tourCameraRevision != widget.tourCameraRevision) {
      _applyTourCamera();
      return;
    }
    // Sunucu HUD'ı (anlatım paneli, kontroller vb.) açılıp kapanırken aynı
    // sahneyi tekrar yamamak, model-viewer'ın kullanıcının sürükleyerek
    // seçtiği canlı kamera açısını başlangıç yörüngesine döndürüyordu.
    // Sayfa nesnesi ve görünür sahne ayarları değişmediyse iframe dokunulmaz.
    if (identical(oldWidget.page, widget.page) &&
        oldWidget.selectedTextBlockId == widget.selectedTextBlockId &&
        oldWidget.inlineEditingTextBlockId == widget.inlineEditingTextBlockId &&
        oldWidget.selectedComponentBlockId == widget.selectedComponentBlockId &&
        oldWidget.visibleRevealStep == widget.visibleRevealStep &&
        oldWidget.showBadge == widget.showBadge &&
        oldWidget.showBackground == widget.showBackground &&
        oldWidget.renderMode == widget.renderMode) {
      return;
    }
    if (oldWidget.showBackground != widget.showBackground ||
        (widget.showBackground &&
            (oldWidget.page.backgroundKind != widget.page.backgroundKind ||
                oldWidget.page.backgroundAnimationEnabled !=
                    widget.page.backgroundAnimationEnabled ||
                oldWidget.page.backgroundAnimationSpeed !=
                    widget.page.backgroundAnimationSpeed ||
                oldWidget.page.backgroundColorsInverted !=
                    widget.page.backgroundColorsInverted))) {
      _render();
      return;
    }
    if (!_patchInPlace(oldWidget)) {
      _render();
    }
  }

  void _applyVisualStyle() {
    final hasCompositedEffect = widget.cssTransform != 'none' ||
        widget.cssOpacity < 1 ||
        widget.cssClipPath != null;
    _hostElement.style
      ..transform = widget.cssTransform
      ..transformOrigin = widget.cssTransformOrigin
      ..opacity = widget.cssOpacity.clamp(0.0, 1.0).toString()
      ..clipPath = widget.cssClipPath ?? 'none'
      ..willChange =
          hasCompositedEffect ? 'transform, opacity, clip-path' : 'auto';
    _hostElement.style.pointerEvents =
        _shouldAllowIframeInteraction || widget.onTap != null ? 'auto' : 'none';
  }

  bool get _shouldAllowIframeInteraction =>
      widget.renderMode == HtmlStageRenderMode.full ||
      widget.tourInteractionEnabled;

  @override
  void dispose() {
    _renderGeneration += 1;
    RemoteModelSources.revision.removeListener(_onRemoteSourcesChanged);
    final pendingLoadSubscription = _pendingLoadSubscription;
    if (pendingLoadSubscription != null) {
      unawaited(pendingLoadSubscription.cancel());
    }
    _pendingLoadTimer?.cancel();
    final initialLoadSubscription = _initialLoadSubscription;
    if (initialLoadSubscription != null) {
      unawaited(initialLoadSubscription.cancel());
    }
    _initialLoadTimer?.cancel();
    unawaited(_tourMessageSubscription?.cancel());
    _pendingIframeElement?.remove();
    final tapSubscription = _tapSubscription;
    if (tapSubscription != null) {
      unawaited(tapSubscription.cancel());
    }
    _hostElement.children.clear();
    super.dispose();
  }

  void _render() {
    final directModelBlocks = _directModelBlocks;
    final document = buildHtmlStageDocument(
      // Sunumda 3B model editÃ¶rle aynÄ± doÄŸrudan model-viewer bileÅŸeninde
      // Ã§izilir. Iframe yalnÄ±zca metinleri ve diÄŸer HTML bileÅŸenlerini tutar;
      // aksi halde aynÄ± kayÄ±tlÄ± kamera iki farklÄ± renderer tarafÄ±ndan farklÄ±
      // yorumlanÄ±yor ve sunum ilk karesinde model baÅŸka bir aÃ§Ä±ya sÄ±Ã§rÄ±yordu.
      page: _documentPage,
      selectedTextBlockId: widget.selectedTextBlockId,
      inlineEditingTextBlockId: widget.inlineEditingTextBlockId,
      selectedComponentBlockId: widget.selectedComponentBlockId,
      visibleRevealStep: widget.visibleRevealStep,
      showBadge: widget.showBadge,
      showBackground: widget.showBackground && directModelBlocks.isEmpty,
      renderMode: widget.renderMode,
      modelSourcesById: RemoteModelSources.all,
      imageSourcesById: RemoteImageSources.all,
      tourPointPlacementEnabled: widget.tourPointPlacementEnabled,
    );

    // İlk sahnede değiştirecek eski bir kare yoktur; doğrudan yükle.
    if (!_hasRendered) {
      _hasRendered = true;
      _renderGeneration += 1;
      final generation = _renderGeneration;
      final initialIframe = _iframeElement;
      var markedDocument = document;
      final marker =
          '<meta name="sutol-stage-generation" content="$generation">';
      markedDocument = markedDocument.contains('</head>')
          ? markedDocument.replaceFirst('</head>', '$marker</head>')
          : '$marker$markedDocument';

      bool isInitialReady() {
        try {
          final frameDocument = (initialIframe.contentWindow as dynamic)
              .document as html.Document?;
          if (frameDocument == null || frameDocument.readyState != 'complete') {
            return false;
          }
          return frameDocument
                  .querySelector('meta[name="sutol-stage-generation"]')
                  ?.getAttribute('content') ==
              '$generation';
        } catch (_) {
          return false;
        }
      }

      void revealInitialWhenPainted({bool loaded = false}) {
        if (!mounted ||
            generation != _renderGeneration ||
            (!loaded && !isInitialReady())) {
          return;
        }
        html.window.requestAnimationFrame((_) {
          html.window.requestAnimationFrame((_) {
            if (!mounted || generation != _renderGeneration) return;
            _initialLoadTimer?.cancel();
            _initialLoadTimer = null;
            final subscription = _initialLoadSubscription;
            _initialLoadSubscription = null;
            if (subscription != null) unawaited(subscription.cancel());
            initialIframe.style
              ..visibility = 'visible'
              ..opacity = '1'
              ..pointerEvents = _shouldAllowIframeInteraction ? 'auto' : 'none';
          });
        });
      }

      _initialLoadSubscription = initialIframe.onLoad.listen((_) {
        _restoreTourRuntimeState();
        revealInitialWhenPainted(loaded: true);
      });
      initialIframe.srcdoc = markedDocument;
      var checks = 0;
      _initialLoadTimer = Timer.periodic(
        const Duration(milliseconds: 50),
        (timer) {
          if (!mounted || generation != _renderGeneration) {
            timer.cancel();
            return;
          }
          checks += 1;
          if (isInitialReady()) {
            timer.cancel();
            revealInitialWhenPainted();
            return;
          }
          if (checks < 200) return;
          timer.cancel();
          final subscription = _initialLoadSubscription;
          _initialLoadSubscription = null;
          if (subscription != null) unawaited(subscription.cancel());
          _initialLoadTimer = null;
        },
      );
      return;
    }

    // Structural edits (adding/removing a Pexels image, changing pages, etc.)
    // are rewritten inside the existing iframe. Keeping both the Flutter
    // platform view and iframe element stable prevents Chrome's grey surface
    // during iframe replacement. The freshly written document installs this
    // same listener again, so later edits remain patchable.
    if (_pendingIframeElement == null) {
      final targetWindow = _iframeElement.contentWindow;
      if (targetWindow != null) {
        targetWindow.postMessage(
          jsonEncode(<String, Object?>{
            'type': 'sutol-stage-replace',
            'document': document,
          }),
          '*',
        );
        // document.open()/close() ile yapılan yerinde yenilemede iframe'in
        // `load` olayı tarayıcıya göre atlanabilir. Yeni betik kurulduktan
        // sonraki görevde tur durumunu yeniden uygula.
        Timer.run(_restoreTourRuntimeState);
        return;
      }
    }

    // Slayt değişiminde mevcut iframe'i boşaltmak gri bir ara kare üretir.
    // Yeni belgeyi görünmez ikinci iframe'de hazırla; load tamamlandığında
    // eskisini tek seferde değiştir. Hızlı art arda seçimlerde yalnızca en son
    // oluşturulan belge sahneye alınır.
    _renderGeneration += 1;
    final generation = _renderGeneration;
    final initialSubscription = _initialLoadSubscription;
    _initialLoadSubscription = null;
    if (initialSubscription != null) {
      unawaited(initialSubscription.cancel());
    }
    _initialLoadTimer?.cancel();
    _initialLoadTimer = null;
    final previousPending = _pendingLoadSubscription;
    if (previousPending != null) {
      unawaited(previousPending.cancel());
    }
    _pendingLoadTimer?.cancel();
    _pendingLoadTimer = null;
    _pendingIframeElement?.remove();

    final nextIframe = _createIframe()
      ..style.position = 'absolute'
      ..style.left = '0'
      ..style.top = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.pointerEvents = 'none'
      ..style.opacity = '0'
      ..style.visibility = 'hidden';
    _pendingIframeElement = nextIframe;
    final marker = '<meta name="sutol-stage-generation" content="$generation">';
    final pendingDocument = document.contains('</head>')
        ? document.replaceFirst('</head>', '$marker</head>')
        : '$marker$document';

    bool isPendingReady() {
      try {
        final frameDocument =
            (nextIframe.contentWindow as dynamic).document as html.Document?;
        if (frameDocument == null || frameDocument.readyState != 'complete') {
          return false;
        }
        return frameDocument
                .querySelector('meta[name="sutol-stage-generation"]')
                ?.getAttribute('content') ==
            '$generation';
      } catch (_) {
        return false;
      }
    }

    void commitPendingIframe({bool loaded = false}) {
      if (!mounted ||
          generation != _renderGeneration ||
          _pendingIframeElement != nextIframe ||
          (!loaded && !isPendingReady())) {
        return;
      }
      html.window.requestAnimationFrame((_) {
        html.window.requestAnimationFrame((_) {
          if (!mounted ||
              generation != _renderGeneration ||
              _pendingIframeElement != nextIframe) {
            return;
          }
          _pendingLoadTimer?.cancel();
          _pendingLoadTimer = null;
          final previousIframe = _iframeElement;
          nextIframe.style
            ..visibility = 'visible'
            ..opacity = '1'
            ..pointerEvents = _shouldAllowIframeInteraction ? 'auto' : 'none';
          _iframeElement = nextIframe;
          _pendingIframeElement = null;
          final subscription = _pendingLoadSubscription;
          _pendingLoadSubscription = null;
          if (subscription != null) {
            unawaited(subscription.cancel());
          }
          previousIframe.remove();
          _restoreTourRuntimeState();
        });
      });
    }

    _pendingLoadSubscription = nextIframe.onLoad.listen(
      (_) => commitPendingIframe(loaded: true),
    );
    // Chrome, iç içe srcdoc iframe'lerinde srcdoc DOM'a bağlanmadan atanırsa
    // load olayını kimi güncellemelerde kaçırabiliyor. Önce iframe'i sahneye
    // bağla, ardından belgeyi ata.
    _hostElement.children.add(nextIframe);
    nextIframe.srcdoc = pendingDocument;

    // Chrome bazı srcdoc güncellemelerinde iframe load olayını kaçırabiliyor.
    // Önceki 250 ms'lik zorunlu geçiş, uzaktaki bir fotoğraf henüz yüklenirken
    // boyanmamış iframe yüzeyini görünür yapıp tüm sahneyi gri bırakıyordu.
    // Belgenin gerçekten tamamlandığını aynı-origin srcdoc üzerinden denetle;
    // hazır değilse çalışan eski iframe'i koru. On saniyede tamamlanmayan yeni
    // belge sessizce atılır ve bir sonraki düzenleme yeniden deneyebilir.
    var readinessChecks = 0;
    _pendingLoadTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (!mounted ||
            generation != _renderGeneration ||
            _pendingIframeElement != nextIframe) {
          timer.cancel();
          return;
        }

        readinessChecks += 1;
        try {
          if (isPendingReady()) {
            commitPendingIframe();
            return;
          }
        } catch (_) {
          // srcdoc normalde ana sayfayla aynı origin'dir. Tarayıcı erişimi
          // geçici olarak reddederse load olayını beklemeye devam et.
        }

        if (readinessChecks < 200) return;
        timer.cancel();
        final subscription = _pendingLoadSubscription;
        _pendingLoadSubscription = null;
        if (subscription != null) {
          unawaited(subscription.cancel());
        }
        nextIframe.remove();
        if (_pendingIframeElement == nextIframe) {
          _pendingIframeElement = null;
        }
        _pendingLoadTimer = null;
      },
    );
  }

  bool _patchInPlace(HtmlPageStage oldWidget) {
    if (_pendingIframeElement != null) {
      return false;
    }
    if (!_canPatchInPlace(oldWidget, widget)) {
      return false;
    }

    final targetWindow = _iframeElement.contentWindow;
    if (targetWindow == null) {
      return false;
    }

    final documentPage = _documentPage;
    final payload = <String, Object?>{
      'type': 'sutol-stage-patch',
      'components': documentPage.componentBlocks.map(
        (block) {
          final legacyImageId = block.imageAssetId == null &&
                  block.modelAssetId != null &&
                  RemoteImageSources.sourceFor(block.modelAssetId!) != null
              ? block.modelAssetId
              : null;
          final imageId = block.imageAssetId ?? legacyImageId;
          final modelId = imageId == null ? block.modelAssetId : null;
          final isImage = imageId != null;
          return <String, Object?>{
            'id': block.id,
            'className': <String>[
              'sutol-html-component',
              _entranceAnimationDomClass(block.entranceAnimation),
              if (isImage) 'component-uploaded-image',
              if (modelId == null && !isImage)
                'component-${_componentDomKindName(block.kind)}',
              if (modelId != null &&
                  RemoteModelSources.sourceFor(modelId) != null)
                'component-3d-model',
              if (modelId != null ||
                  isImage ||
                  presentationComponentHasHtml(block.kind))
                'has-html-component',
              if (block.id == widget.selectedComponentBlockId) 'is-selected',
            ].join(' '),
            'revealStep': block.revealStep,
            'hotspotTargetPageId': block.hotspotTargetPageId,
            'left': '${_pct(block.position.dx)}%',
            'top': '${_pct(block.position.dy)}%',
            'width': '${_pct(block.size.width)}%',
            'height': '${_pct(block.size.height)}%',
            'animationDuration': block.animationDuration.toStringAsFixed(2),
            'animationDelay': block.animationDelay.toStringAsFixed(2),
            'motionPathPoints': block.motionPathPoints
                .map((point) => <String, String>{
                      'x': '${_pct(point.dx)}cqw',
                      'y': '${_pct(point.dy)}cqh',
                    })
                .toList(growable: false),
            'modelOrbitTheta': isImage || modelId == null
                ? null
                : block.modelOrbitTheta.toStringAsFixed(2),
            'modelOrbitPhi': isImage || modelId == null
                ? null
                : block.modelOrbitPhi.toStringAsFixed(2),
            'modelAutoRotate':
                isImage || modelId == null ? null : block.modelAutoRotate,
            'modelRotationSpeed':
                isImage || modelId == null ? null : block.modelRotationSpeed,
            'modelZoom': isImage || modelId == null ? null : block.modelZoom,
            'modelCameraRadius':
                isImage || modelId == null ? null : block.modelCameraRadius,
            'modelTurntableRotation': isImage || modelId == null
                ? null
                : block.modelTurntableRotation,
            'modelFieldOfView':
                isImage || modelId == null ? null : block.modelFieldOfView,
            'modelTargetX':
                isImage || modelId == null ? null : block.modelTargetX,
            'modelTargetY':
                isImage || modelId == null ? null : block.modelTargetY,
            'modelTargetZ':
                isImage || modelId == null ? null : block.modelTargetZ,
            'modelOrbitEnabled':
                isImage || modelId == null ? null : block.modelOrbitEnabled,
            'modelTourEnabled':
                isImage || modelId == null ? null : block.modelTourEnabled,
            'modelTourInteractive': isImage || modelId == null
                ? null
                : block.modelTourEnabled && !block.modelTourFrozen,
            'modelAnimationEnabled':
                isImage || modelId == null ? null : block.modelAnimationEnabled,
          };
        },
      ).toList(growable: false),
      'texts': documentPage.textBlocks
          .map(
            (block) => <String, Object?>{
              'id': block.id,
              'className': <String>[
                'sutol-html-block',
                _textTypeDomClass(block.type),
                _textStyleDomClass(block.textStyle),
                _textAnimationDomClass(block.textAnimation),
                _textEffectDomClass(block.textEffect),
                _entranceAnimationDomClass(block.entranceAnimation),
                if (block.glowIntensity <= 0) 'is-glow-off',
                if (block.id == widget.selectedTextBlockId) 'is-selected',
                if (block.id == widget.inlineEditingTextBlockId)
                  'is-inline-editing',
              ].join(' '),
              'revealStep': block.revealStep,
              'hotspotTargetPageId': block.hotspotTargetPageId,
              'left': '${_pct(block.position.dx)}%',
              'top': '${_pct(block.position.dy)}%',
              'width': '${_pct(block.widthFactor)}%',
              'height': block.heightFactor == null
                  ? ''
                  : '${_pct(block.heightFactor!)}%',
              'baseFontSize': '${(block.fontSize / 10).toStringAsFixed(2)}cqw',
              'glowIntensity': block.glowIntensity.toStringAsFixed(2),
              'animationDuration': block.animationDuration.toStringAsFixed(2),
              'animationDelay': block.animationDelay.toStringAsFixed(2),
              'motionPathPoints': block.motionPathPoints
                  .map((point) => <String, String>{
                        'x': '${_pct(point.dx)}cqw',
                        'y': '${_pct(point.dy)}cqh',
                      })
                  .toList(growable: false),
              'textGrouping': block.textGrouping.name,
              'groupDelay': block.groupDelay.toStringAsFixed(2),
              'entranceAnimationClass':
                  _entranceAnimationDomClass(block.entranceAnimation),
              'textColor': block.textColorHex,
              'fontWeight': block.fontWeight,
              'textBold': block.textBold,
              'textItalic': block.textItalic,
              'textUnderline': block.textUnderline,
              'textAlign': block.textAlign.name,
              'isTypewriter':
                  block.textAnimation == PresentationTextAnimation.daktilo,
              'isWordReveal': block.textAnimation ==
                  PresentationTextAnimation.kelimeKelimeBelirme,
              'text': block.text.trim().isEmpty ? 'Metin kutusu' : block.text,
            },
          )
          .toList(growable: false),
    };

    targetWindow.postMessage(jsonEncode(payload), '*');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final directModelBlocks = _directModelBlocks;
    if (directModelBlocks.isEmpty) {
      return HtmlElementView(viewType: _viewType);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageWidth = constraints.maxWidth;
        final stageHeight = constraints.maxHeight;
        if (stageWidth <= 0 || stageHeight <= 0) {
          return const SizedBox.shrink();
        }
        final minWidth = math.min(54.0, stageWidth);
        final minHeight = math.min(44.0, stageHeight);

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            if (widget.showBackground)
              HtmlLiveBackground(
                kind: widget.page.backgroundKind,
                animationEnabled: widget.page.backgroundAnimationEnabled,
                animationSpeed: widget.page.backgroundAnimationSpeed,
                colorsInverted: widget.page.backgroundColorsInverted,
              ),
            for (final block in directModelBlocks)
              Positioned(
                left: block.position.dx * stageWidth,
                top: block.position.dy * stageHeight,
                width: math.max(minWidth, block.size.width * stageWidth),
                height: math.max(minHeight, block.size.height * stageHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: HtmlModelCanvas(
                    key: ValueKey<String>(
                      'preview-model-${widget.page.id}-${block.id}-${block.modelAssetId}',
                    ),
                    modelId: block.modelAssetId!,
                    animationEnabled: block.modelAnimationEnabled,
                    autoRotate: block.modelAutoRotate,
                    rotationSpeed: block.modelRotationSpeed,
                    zoom: _usesRuntimeTourCamera(block)
                        ? widget.tourCameraZoom ?? block.modelZoom
                        : block.modelZoom,
                    cameraRadius: block.modelCameraRadius,
                    turntableRotation: block.modelTurntableRotation,
                    fieldOfView: block.modelFieldOfView,
                    exposure: findPresentation3DModelAsset(
                          block.modelAssetId!,
                        )?.exposure ??
                        1,
                    environmentImage: findPresentation3DModelAsset(
                      block.modelAssetId!,
                    )?.environmentImage,
                    orbitEnabled: block.modelOrbitEnabled,
                    tourEnabled: block.modelTourEnabled,
                    tourInteractive:
                        block.modelTourEnabled && !block.modelTourFrozen,
                    orbitTheta: _usesRuntimeTourCamera(block)
                        ? widget.tourCameraTheta!
                        : block.modelOrbitTheta,
                    orbitPhi: _usesRuntimeTourCamera(block)
                        ? widget.tourCameraPhi!
                        : block.modelOrbitPhi,
                    targetX: _usesRuntimeTourCamera(block)
                        ? widget.tourCameraTargetX!
                        : block.modelTargetX,
                    targetY: _usesRuntimeTourCamera(block)
                        ? widget.tourCameraTargetY!
                        : block.modelTargetY,
                    targetZ: _usesRuntimeTourCamera(block)
                        ? widget.tourCameraTargetZ!
                        : block.modelTargetZ,
                    pickSurfacePosition: widget.tourPointPlacementEnabled &&
                        (widget.selectedComponentBlockId == null ||
                            widget.selectedComponentBlockId == block.id),
                    onSurfacePositionPicked: widget.onTourSurfacePointPicked,
                    onSurfacePickMissed: widget.onTourSurfacePickMissed,
                  ),
                ),
              ),
            // Metinler, fotoÄŸraflar ve diÄŸer HTML bileÅŸenleri modelin Ã¼stÃ¼nde
            // kalÄ±r. Belge arka planÄ± ÅŸeffaftÄ±r; gerÃ§ek arka plan yukarÄ±daki
            // canlÄ± katmanda Ã§izildiÄŸi iÃ§in model tamamen gÃ¶rÃ¼nÃ¼r kalÄ±r.
            HtmlElementView(viewType: _viewType),
          ],
        );
      },
    );
  }
}

bool _canPatchInPlace(HtmlPageStage oldWidget, HtmlPageStage nextWidget) {
  if (oldWidget.page.id != nextWidget.page.id ||
      oldWidget.page.backgroundKind != nextWidget.page.backgroundKind ||
      oldWidget.visibleRevealStep != nextWidget.visibleRevealStep ||
      oldWidget.showBadge != nextWidget.showBadge ||
      oldWidget.renderMode != nextWidget.renderMode ||
      oldWidget.page.componentBlocks.length !=
          nextWidget.page.componentBlocks.length ||
      oldWidget.page.textBlocks.length != nextWidget.page.textBlocks.length) {
    return false;
  }

  for (var i = 0; i < nextWidget.page.componentBlocks.length; i += 1) {
    final oldBlock = oldWidget.page.componentBlocks[i];
    final nextBlock = nextWidget.page.componentBlocks[i];
    if (oldBlock.id != nextBlock.id ||
        oldBlock.kind != nextBlock.kind ||
        oldBlock.modelAssetId != nextBlock.modelAssetId ||
        oldBlock.imageAssetId != nextBlock.imageAssetId ||
        oldBlock.imageAspectRatio != nextBlock.imageAspectRatio ||
        oldBlock.revealStep != nextBlock.revealStep ||
        oldBlock.hotspotTargetPageId != nextBlock.hotspotTargetPageId ||
        !_sameModelTourHotspots(
          oldBlock.modelTourHotspots,
          nextBlock.modelTourHotspots,
        )) {
      return false;
    }
  }

  for (var i = 0; i < nextWidget.page.textBlocks.length; i += 1) {
    final oldBlock = oldWidget.page.textBlocks[i];
    final nextBlock = nextWidget.page.textBlocks[i];
    if (oldBlock.id != nextBlock.id ||
        oldBlock.revealStep != nextBlock.revealStep ||
        oldBlock.hotspotTargetPageId != nextBlock.hotspotTargetPageId) {
      return false;
    }
  }

  return true;
}

/// Tur noktaları model-viewer'ın içindeki slot öğeleridir. Bunlar değiştiğinde
/// sadece konum/stil yaması göndermek yeterli değildir; yeni iframe belgesi,
/// fiziksel 3B işaretçileri oluşturmalıdır.
bool _sameModelTourHotspots(
  List<ModelTourHotspot> first,
  List<ModelTourHotspot> second,
) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index += 1) {
    final a = first[index];
    final b = second[index];
    if (a.id != b.id ||
        a.label != b.label ||
        a.kind != b.kind ||
        a.description != b.description ||
        a.targetPageId != b.targetPageId ||
        a.x != b.x ||
        a.y != b.y ||
        a.z != b.z) {
      return false;
    }
  }
  return true;
}

String _componentDomKindName(PresentationComponentKind kind) {
  return presentationComponentDomName(kind);
}

String _textTypeDomClass(PresentationTextType type) {
  switch (type) {
    case PresentationTextType.title:
      return 'is-title';
    case PresentationTextType.subtitle:
      return 'is-subtitle';
    case PresentationTextType.body:
      return 'is-body';
  }
}

String _entranceAnimationDomClass(PresentationEntranceAnimation animation) {
  return 'entrance-animation-${animation.name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '-${match.group(1)!.toLowerCase()}')}';
}

String _textStyleDomClass(PresentationTextStyle style) {
  final googleFontClass = presentationGoogleFontClass(style);
  if (googleFontClass != null) return googleFontClass;
  switch (style) {
    case PresentationTextStyle.standard:
      return 'text-style-standard';
    case PresentationTextStyle.bilimDramatik:
      return 'text-style-bilim-dramatik';
    case PresentationTextStyle.bilimTemiz:
      return 'text-style-bilim-temiz';
    case PresentationTextStyle.bilimDeneysel:
      return 'text-style-bilim-deneysel';
    case PresentationTextStyle.gunesDramatik:
      return 'text-style-gunes-dramatik';
    case PresentationTextStyle.gunesTemiz:
      return 'text-style-gunes-temiz';
    case PresentationTextStyle.gunesDeneysel:
      return 'text-style-gunes-deneysel';
    case PresentationTextStyle.uzayDramatik:
      return 'text-style-uzay-dramatik';
    case PresentationTextStyle.uzayTemiz:
      return 'text-style-uzay-temiz';
    case PresentationTextStyle.uzayDeneysel:
      return 'text-style-uzay-deneysel';
    case PresentationTextStyle.optikDramatik:
      return 'text-style-optik-dramatik';
    case PresentationTextStyle.optikTemiz:
      return 'text-style-optik-temiz';
    case PresentationTextStyle.optikDeneysel:
      return 'text-style-optik-deneysel';
    case PresentationTextStyle.fizikDramatik:
      return 'text-style-fizik-dramatik';
    case PresentationTextStyle.fizikTemiz:
      return 'text-style-fizik-temiz';
    case PresentationTextStyle.fizikDeneysel:
      return 'text-style-fizik-deneysel';
    case PresentationTextStyle.teknolojiDramatik:
      return 'text-style-teknoloji-dramatik';
    case PresentationTextStyle.teknolojiTemiz:
      return 'text-style-teknoloji-temiz';
    case PresentationTextStyle.teknolojiDeneysel:
      return 'text-style-teknoloji-deneysel';
    case PresentationTextStyle.openOswald:
      return 'text-style-open-oswald';
    case PresentationTextStyle.openPlayfairDisplay:
      return 'text-style-open-playfair-display';
    case PresentationTextStyle.openBebasNeue:
      return 'text-style-open-bebas-neue';
    case PresentationTextStyle.openBungee:
      return 'text-style-open-bungee';
    case PresentationTextStyle.openCaveat:
      return 'text-style-open-caveat';
    case PresentationTextStyle.openUnbounded:
      return 'text-style-open-unbounded';
    case PresentationTextStyle.klasikTinos:
      return 'text-style-klasik-tinos';
    case PresentationTextStyle.klasikArimo:
      return 'text-style-klasik-arimo';
    case PresentationTextStyle.klasikCousine:
      return 'text-style-klasik-cousine';
    case PresentationTextStyle.klasikCarlito:
      return 'text-style-klasik-carlito';
    case PresentationTextStyle.klasikCaladea:
      return 'text-style-klasik-caladea';
    case PresentationTextStyle.klasikEBGaramond:
      return 'text-style-klasik-eb-garamond';
    case PresentationTextStyle.klasikLibreBaskerville:
      return 'text-style-klasik-libre-baskerville';
    case PresentationTextStyle.klasikAlegreya:
      return 'text-style-klasik-alegreya';
    case PresentationTextStyle.klasikPTSerif:
      return 'text-style-klasik-pt-serif';
    case PresentationTextStyle.klasikMerriweather:
      return 'text-style-klasik-merriweather';
    case PresentationTextStyle.klasikLora:
      return 'text-style-klasik-lora';
    case PresentationTextStyle.klasikGreatVibes:
      return 'text-style-klasik-great-vibes';
    case PresentationTextStyle.klasikDancingScript:
      return 'text-style-klasik-dancing-script';
    case PresentationTextStyle.klasikPacifico:
      return 'text-style-klasik-pacifico';
    case PresentationTextStyle.klasikLobster:
      return 'text-style-klasik-lobster';
    default:
      return 'text-style-standard';
  }
}

String _textAnimationDomClass(PresentationTextAnimation animation) {
  final name = animation.name.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (match) => '-${match.group(1)!.toLowerCase()}',
  );
  return 'text-animation-$name';
}

String _textEffectDomClass(PresentationTextEffect effect) {
  final name = effect.name.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (match) => '-${match.group(1)!.toLowerCase()}',
  );
  return 'text-effect-$name';
}

String _pct(double value) => (value * 100).toStringAsFixed(2);
