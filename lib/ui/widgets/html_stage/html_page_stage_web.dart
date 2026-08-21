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
  final HtmlStageRenderMode renderMode;
  final VoidCallback? onTap;
  final String cssTransform;
  final double cssOpacity;
  final String? cssClipPath;
  final String cssTransformOrigin;

  @override
  State<HtmlPageStage> createState() => _HtmlPageStageState();
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
    _iframeElement = _createIframe()..style.opacity = '1';
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
    final pendingLoadSubscription = _pendingLoadSubscription;
    if (pendingLoadSubscription != null) {
      unawaited(pendingLoadSubscription.cancel());
    }
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
      renderMode: widget.renderMode,
      modelSourcesById: RemoteModelSources.all,
      imageSourcesById: RemoteImageSources.all,
    );

    // İlk sahnede değiştirecek eski bir kare yoktur; doğrudan yükle.
    if (!_hasRendered) {
      _hasRendered = true;
      _iframeElement.style.pointerEvents =
          widget.renderMode == HtmlStageRenderMode.full ? 'auto' : 'none';
      _iframeElement.style.opacity = '1';
      _iframeElement.srcdoc = document;
      return;
    }

    // Slayt değişiminde mevcut iframe'i boşaltmak gri bir ara kare üretir.
    // Yeni belgeyi görünmez ikinci iframe'de hazırla; load tamamlandığında
    // eskisini tek seferde değiştir. Hızlı art arda seçimlerde yalnızca en son
    // oluşturulan belge sahneye alınır.
    _renderGeneration += 1;
    final generation = _renderGeneration;
    final previousPending = _pendingLoadSubscription;
    if (previousPending != null) {
      unawaited(previousPending.cancel());
    }
    _pendingIframeElement?.remove();

    final nextIframe = _createIframe()
      ..style.position = 'absolute'
      ..style.left = '0'
      ..style.top = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.pointerEvents = 'none'
      ..style.opacity = '0.001';
    _pendingIframeElement = nextIframe;
    _pendingLoadSubscription = nextIframe.onLoad.listen((_) {
      if (!mounted || generation != _renderGeneration) return;
      final previousIframe = _iframeElement;
      nextIframe.style.opacity = '1';
      nextIframe.style.pointerEvents =
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
    nextIframe.srcdoc = document;
    _hostElement.children.add(nextIframe);
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
