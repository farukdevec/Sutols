// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import '../../../models/slide_model.dart';
import '../../../services/remote_image_sources.dart';
import '../../../services/remote_model_sources.dart';
import 'html_stage_document.dart';

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
  @override
  void initState() {
    super.initState();
    RemoteModelSources.revision.addListener(_onRemoteSourcesChanged);
    _viewType = 'sutol-html-stage-${_viewCounter++}';
    _hostElement = html.DivElement()
      ..className = 'sutol-html-host'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..style.pointerEvents = widget.onTap == null ? 'none' : 'auto'
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
      _render();
    }
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
      ..style.pointerEvents = 'none'
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
  }

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
    _pendingIframeElement?.remove();
    final tapSubscription = _tapSubscription;
    if (tapSubscription != null) {
      unawaited(tapSubscription.cancel());
    }
    _hostElement.children.clear();
    super.dispose();
  }

  void _render() {
    final document = buildHtmlStageDocument(
      page: widget.page,
      selectedTextBlockId: widget.selectedTextBlockId,
      inlineEditingTextBlockId: widget.inlineEditingTextBlockId,
      selectedComponentBlockId: widget.selectedComponentBlockId,
      visibleRevealStep: widget.visibleRevealStep,
      showBadge: widget.showBadge,
      showBackground: widget.showBackground,
      renderMode: widget.renderMode,
      modelSourcesById: RemoteModelSources.all,
      imageSourcesById: RemoteImageSources.all,
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
              ..pointerEvents = widget.renderMode == HtmlStageRenderMode.full
                  ? 'auto'
                  : 'none';
          });
        });
      }

      _initialLoadSubscription = initialIframe.onLoad.listen(
        (_) => revealInitialWhenPainted(loaded: true),
      );
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
            ..pointerEvents =
                widget.renderMode == HtmlStageRenderMode.full ? 'auto' : 'none';
          _iframeElement = nextIframe;
          _pendingIframeElement = null;
          final subscription = _pendingLoadSubscription;
          _pendingLoadSubscription = null;
          if (subscription != null) {
            unawaited(subscription.cancel());
          }
          previousIframe.remove();
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

    final payload = <String, Object?>{
      'type': 'sutol-stage-patch',
      'components': widget.page.componentBlocks.map(
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
            'modelOrbitEnabled':
                isImage || modelId == null ? null : block.modelOrbitEnabled,
            'modelAnimationEnabled':
                isImage || modelId == null ? null : block.modelAnimationEnabled,
          };
        },
      ).toList(growable: false),
      'texts': widget.page.textBlocks
          .map(
            (block) => <String, Object?>{
              'id': block.id,
              'className': <String>[
                'sutol-html-block',
                _textTypeDomClass(block.type),
                _textStyleDomClass(block.textStyle),
                _textAnimationDomClass(block.textAnimation),
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
    return HtmlElementView(viewType: _viewType);
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
        oldBlock.hotspotTargetPageId != nextBlock.hotspotTargetPageId) {
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

String _pct(double value) => (value * 100).toStringAsFixed(2);
