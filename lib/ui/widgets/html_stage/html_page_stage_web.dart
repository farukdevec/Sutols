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
  });

  final PresentationPage page;
  final String? selectedTextBlockId;
  final String? inlineEditingTextBlockId;
  final String? selectedComponentBlockId;
  final int? visibleRevealStep;
  final bool showBadge;
  final HtmlStageRenderMode renderMode;
  final VoidCallback? onTap;

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
  late final html.IFrameElement _iframeElement;
  StreamSubscription<html.MouseEvent>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _viewType = 'sutol-html-stage-${_viewCounter++}';
    _hostElement = html.DivElement()
      ..className = 'sutol-html-host'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative'
      ..style.pointerEvents = widget.onTap == null ? 'none' : 'auto'
      ..style.overflow = 'hidden';
    _iframeElement = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0'
      ..style.border = '0'
      ..style.pointerEvents = 'none'
      ..setAttribute('scrolling', 'no');
    if (widget.onTap != null) {
      _iframeElement.setAttribute('loading', 'lazy');
    }
    _hostElement.children.add(_iframeElement);
    if (widget.onTap != null) {
      final overlay = html.DivElement()
        ..setAttribute('aria-label', 'Şablonu seç')
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.left = '0'
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

  @override
  void didUpdateWidget(covariant HtmlPageStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_patchInPlace(oldWidget)) {
      _render();
    }
  }

  @override
  void dispose() {
    final tapSubscription = _tapSubscription;
    if (tapSubscription != null) {
      unawaited(tapSubscription.cancel());
    }
    _hostElement.children.clear();
    super.dispose();
  }

  void _render() {
    _iframeElement.srcdoc = buildHtmlStageDocument(
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
  }

  bool _patchInPlace(HtmlPageStage oldWidget) {
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
              'textColor': block.textColorHex,
              'textBold': block.textBold,
              'textItalic': block.textItalic,
              'textUnderline': block.textUnderline,
              'textAlign': block.textAlign.name,
              'isTypewriter':
                  block.textAnimation == PresentationTextAnimation.daktilo,
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
