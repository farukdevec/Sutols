import 'dart:convert';
import 'dart:math' as math;

import '../../../models/slide_model.dart';
import 'background_scene_sources.dart';

enum HtmlStageRenderMode {
  full,
  preview,
  snapshot,
}

const String sutolModelViewerScriptUrl =
    'https://ajax.googleapis.com/ajax/libs/model-viewer/4.3.1/model-viewer.min.js';

const String sutolModelViewerScriptTag =
    '<script type="module" src="$sutolModelViewerScriptUrl"></script>';

String get sutolHtmlStageStyles => _stageStyles;
String get sutolHtmlStageBackgroundScript => _backgroundScript;
String get sutolHtmlStageComponentScript => _stageComponentScript;
String get sutolHtmlStagePatchScript => _stagePatchScript;

String sutolHtmlBackgroundScene(PresentationBackgroundKind kind) =>
    presentationBackgroundSceneHtml(kind);

String buildHtmlStageDocument({
  required PresentationPage page,
  String? selectedTextBlockId,
  String? selectedComponentBlockId,
  int? visibleRevealStep,
  bool showBadge = true,
  HtmlStageRenderMode renderMode = HtmlStageRenderMode.full,
  Map<String, String> modelSourcesById = const <String, String>{},
}) {
  final buffer = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="tr">')
    ..writeln('<head>')
    ..writeln('<meta charset="utf-8">')
    ..writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1">')
    ..writeln(
      page.componentBlocks.any((block) => block.modelAssetId != null)
          ? sutolModelViewerScriptTag
          : '',
    )
    ..writeln('<style>')
    ..writeln(sutolHtmlStageStyles)
    ..writeln('</style>')
    ..writeln('</head>')
    ..writeln('<body>')
    ..writeln(
      buildHtmlStageMarkup(
        page: page,
        selectedTextBlockId: selectedTextBlockId,
        selectedComponentBlockId: selectedComponentBlockId,
        visibleRevealStep: visibleRevealStep,
        showBadge: showBadge,
        renderMode: renderMode,
        modelSourcesById: modelSourcesById,
      ),
    )
    ..writeln('<script>')
    ..writeln(sutolHtmlStageBackgroundScript)
    ..writeln(sutolHtmlStageComponentScript)
    ..writeln(sutolHtmlStagePatchScript)
    ..writeln('</script>')
    ..writeln('</body>')
    ..writeln('</html>');

  return buffer.toString();
}

String buildHtmlStageMarkup({
  required PresentationPage page,
  String? selectedTextBlockId,
  String? selectedComponentBlockId,
  int? visibleRevealStep,
  bool showBadge = true,
  String? extraStageClass,
  HtmlStageRenderMode renderMode = HtmlStageRenderMode.full,
  Map<String, String> modelSourcesById = const <String, String>{},
  bool deferEmbeddedAssets = false,
}) {
  final renderModeName = _renderModeName(renderMode);
  final stageClasses = <String>[
    'sutol-html-stage',
    _backgroundStageClass(page.backgroundKind),
    'sutol-stage-mode-$renderModeName',
    if (_isDarkBackground(page.backgroundKind)) 'theme-dark',
    if (extraStageClass != null && extraStageClass.trim().isNotEmpty)
      extraStageClass.trim(),
  ].join(' ');

  final buffer = StringBuffer()
    ..writeln(
      '<div class="$stageClasses" data-sutol-render-mode="$renderModeName">',
    )
    ..writeln(
      _backgroundInnerMarkup(
        page.backgroundKind,
        renderMode,
        deferEmbeddedAssets: deferEmbeddedAssets,
      ),
    );

  if (page.textBlocks.isEmpty && page.componentBlocks.isEmpty) {
    buffer.writeln('<div class="sutol-html-empty">Metin ekleyin</div>');
  }

  for (final block in page.textBlocks) {
    if (!_isVisibleAtRevealStep(block.revealStep, visibleRevealStep)) {
      continue;
    }
    final classes = <String>[
      'sutol-html-block',
      _typeClass(block.type),
      _textStyleClass(block.textStyle),
      _textAnimationClass(block.textAnimation),
      if (block.glowIntensity <= 0) 'is-glow-off',
      if (block.id == selectedTextBlockId) 'is-selected',
    ].join(' ');
    final hotspotAttr = block.hotspotTargetPageId == null
        ? ''
        : ' data-hotspot-target="${_escapeAttribute(block.hotspotTargetPageId!)}"';
    final displayText = block.text.trim().isEmpty ? 'Metin kutusu' : block.text;
    final typewriterCycle = _typewriterCycleSeconds(displayText);
    buffer.writeln(
      '<div class="$classes" data-sutol-text-id="${_escapeAttribute(block.id)}" data-reveal-step="${block.revealStep}"$hotspotAttr style="left:${_pct(block.position.dx)}%;top:${_pct(block.position.dy)}%;width:${_pct(block.widthFactor)}%;--sutol-left:${_pct(block.position.dx)}%;--sutol-top:${_pct(block.position.dy)}%;--base-font-size:${(block.fontSize / 10).toStringAsFixed(2)}cqw;--sutol-glow:${block.glowIntensity.toStringAsFixed(2)};--sutol-type-cycle:${typewriterCycle.toStringAsFixed(2)}s;${block.textColorHex == null ? '' : 'color:${_escapeAttribute(block.textColorHex!)};--sutol-text-color:${_escapeAttribute(block.textColorHex!)};'}">${_textBlockMarkup(displayText, block.textAnimation)}</div>',
    );
  }

  for (final block in page.componentBlocks) {
    if (!_isVisibleAtRevealStep(block.revealStep, visibleRevealStep)) {
      continue;
    }
    final is3D = block.modelAssetId != null;
    final catalogModel = is3D ? findPresentation3DModelAsset(block.modelAssetId!) : null;
    final remoteSource = is3D ? modelSourcesById[block.modelAssetId!] : null;
    final resolvableSource = catalogModel != null
        ? modelSourcesById[catalogModel.id] ?? _flutterWebModelAssetPath(catalogModel)
        : remoteSource;
    final has3D = resolvableSource != null;
    final componentHtml =
        has3D ? '' : presentationComponentHtml(block.kind);
    final hasHtmlComponent = has3D || componentHtml.trim().isNotEmpty;
    final classes = <String>[
      'sutol-html-component',
      if (!is3D) 'component-${_componentDomKindName(block.kind)}',
      if (is3D) 'component-3d-model',
      if (hasHtmlComponent) 'has-html-component',
      if (block.id == selectedComponentBlockId) 'is-selected',
    ].join(' ');
    final hotspotAttr = block.hotspotTargetPageId == null
        ? ''
        : ' data-hotspot-target="${_escapeAttribute(block.hotspotTargetPageId!)}"';
    final componentInner = has3D
        ? _model3DMarkup(
            catalogModel?.label ?? block.modelAssetId!,
            resolvableSource,
            id: block.modelAssetId!,
            hasAnimations: catalogModel?.hasAnimations ?? false,
            animationEnabled: block.modelAnimationEnabled,
            orbitTheta: block.modelOrbitTheta,
            orbitPhi: block.modelOrbitPhi,
            deferSource: deferEmbeddedAssets,
          )
        : componentHtml.trim().isEmpty
            ? '<span class="sutol-component-shape"></span>'
            : '<div class="sutol-html-component-inner">$componentHtml</div>';
    final label = catalogModel?.label ?? block.modelAssetId ?? '';
    final modelAttr = !is3D
        ? ''
        : ' data-sutol-model-id="${_escapeAttribute(block.modelAssetId!)}" data-sutol-orbit-theta="${block.modelOrbitTheta.toStringAsFixed(2)}" data-sutol-orbit-phi="${block.modelOrbitPhi.toStringAsFixed(2)}"';
    buffer.writeln(
      '<div class="$classes" data-sutol-component-id="${_escapeAttribute(block.id)}"$modelAttr data-reveal-step="${block.revealStep}" aria-label="${_escapeAttribute(label)}"$hotspotAttr style="left:${_pct(block.position.dx)}%;top:${_pct(block.position.dy)}%;width:${_pct(block.size.width)}%;height:${_pct(block.size.height)}%;">$componentInner</div>',
    );
  }

  if (showBadge) {
    buffer.writeln('<div class="sutol-html-badge">HTML SAHNE</div>');
  }

  buffer.writeln('</div>');
  return buffer.toString();
}

String _model3DMarkup(
  String label,
  String source, {
  required String id,
  required bool hasAnimations,
  required bool animationEnabled,
  required double orbitTheta,
  required double orbitPhi,
  bool deferSource = false,
}) {
  final animationMarkup = hasAnimations && animationEnabled ? ' autoplay' : '';
  final cameraOrbit =
      '${orbitTheta.toStringAsFixed(2)}deg ${orbitPhi.toStringAsFixed(2)}deg auto';
  final sourceMarkup = deferSource
      ? 'data-sutol-model-source-id="${_escapeAttribute(id)}"'
      : 'src="${_escapeAttribute(source)}"';
  return '''
<div class="sutol-html-component-inner sutol-3d-model-inner">
  <model-viewer class="sutol-3d-model-viewer" $sourceMarkup alt="${_escapeAttribute(label)}" camera-controls$animationMarkup camera-orbit="$cameraOrbit" interaction-prompt="none" shadow-intensity="1" shadow-softness="0.8" exposure="1" loading="eager" reveal="auto"></model-viewer>
</div>
''';
}

String _flutterWebModelAssetPath(Presentation3DModelAsset model) {
  return 'assets/${model.assetPath}';
}

String _escape(String value) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(value);

String _escapeAttribute(String value) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(value);

String _textBlockMarkup(
  String text,
  PresentationTextAnimation animation,
) {
  if (animation != PresentationTextAnimation.daktilo) {
    return _escape(text);
  }

  final buffer = StringBuffer();
  var wordIndex = 0;
  for (final match in RegExp(r'\S+|\s+').allMatches(text)) {
    final token = match.group(0)!;
    if (token.trim().isEmpty) {
      buffer.write(_escape(token));
      continue;
    }
    buffer.write(
      '<span class="sutol-typewriter-word" style="--sutol-word-index:$wordIndex">${_escape(token)}</span>',
    );
    wordIndex += 1;
  }
  return buffer.toString();
}

double _typewriterCycleSeconds(String text) {
  final wordCount = RegExp(r'\S+').allMatches(text).length;
  return math.max(4.8, (wordCount * 0.46) + 2.8);
}

bool _isVisibleAtRevealStep(int itemStep, int? visibleRevealStep) {
  return visibleRevealStep == null || itemStep <= visibleRevealStep;
}

String _pct(double value) => (value * 100).toStringAsFixed(2);

String _typeClass(PresentationTextType type) {
  switch (type) {
    case PresentationTextType.title:
      return 'is-title';
    case PresentationTextType.subtitle:
      return 'is-subtitle';
    case PresentationTextType.body:
      return 'is-body';
  }
}

String _textStyleClass(PresentationTextStyle style) {
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
  }
}

String _textAnimationClass(PresentationTextAnimation animation) {
  return 'text-animation-${_enumValueName(animation)}';
}

String _componentDomKindName(PresentationComponentKind kind) {
  return presentationComponentDomName(kind);
}

String _enumValueName(Enum kind) {
  return kind.name.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (match) => '-${match.group(1)!.toLowerCase()}',
  );
}

String _renderModeName(HtmlStageRenderMode mode) {
  switch (mode) {
    case HtmlStageRenderMode.full:
      return 'full';
    case HtmlStageRenderMode.preview:
      return 'preview';
    case HtmlStageRenderMode.snapshot:
      return 'snapshot';
  }
}

bool _isDarkBackground(PresentationBackgroundKind kind) {
  return presentationBackgroundIsDark(kind);
}

String _backgroundStageClass(PresentationBackgroundKind kind) {
  return 'bg-${_enumValueName(kind)}';
}

String _backgroundInnerMarkup(
  PresentationBackgroundKind kind,
  HtmlStageRenderMode renderMode, {
  bool deferEmbeddedAssets = false,
}) {
  if (deferEmbeddedAssets) {
    return '''
<div class="sutol-stage-bg sutol-bg-imported" aria-hidden="true">
  <iframe class="sutol-bg-scene-frame" data-sutol-background-kind="${kind.name}" tabindex="-1"></iframe>
</div>
''';
  }
  final scene = _escapedBackgroundScenes.putIfAbsent(
    kind,
    () => _escapeAttribute(presentationBackgroundSceneHtml(kind)),
  );
  return '''
<div class="sutol-stage-bg sutol-bg-imported" aria-hidden="true">
  <iframe class="sutol-bg-scene-frame" srcdoc="$scene" tabindex="-1"></iframe>
</div>
''';
}

final Map<PresentationBackgroundKind, String> _escapedBackgroundScenes =
    <PresentationBackgroundKind, String>{};

const String _stageStyles = '''
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Bungee&family=Caveat:wght@400;600;700&family=Chakra+Petch:wght@600;700&family=Cinzel:wght@600;700;800;900&family=Cormorant+Garamond:wght@400;600&family=Exo+2:wght@700;900&family=IBM+Plex+Mono:wght@400;500&family=Inter:wght@400;500&family=JetBrains+Mono:wght@400;500;600;700;800&family=Manrope:wght@400;500&family=Marcellus&family=Michroma&family=Mulish:wght@400;500&family=Nunito+Sans:wght@400;500&family=Orbitron:wght@500;700;900&family=Oswald:wght@400;700&family=Playfair+Display:wght@400;700;800&family=Poppins:wght@500;600;700&family=Rajdhani:wght@400;600&family=Righteous&family=Share+Tech+Mono&family=Sora:wght@500;700&family=Space+Grotesk:wght@400;500;700&family=Space+Mono:wght@400;700&family=Syne:wght@700;800&family=Titillium+Web:wght@400;600&family=Unbounded:wght@400;700&display=swap');

html, body {
  margin: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  background: transparent;
  font-family: Arial, sans-serif;
}

body {
  display: block;
}

.sutol-html-stage {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  box-sizing: border-box;
  border: 1px solid #E3E9F2;
  background: #FFFFFF;
  container-type: inline-size;
  isolation: isolate;
}

.sutol-html-stage.theme-dark {
  border-color: rgba(255, 255, 255, 0.10);
}

.sutol-stage-mode-preview,
.sutol-stage-mode-snapshot {
  contain: layout paint style;
}

.sutol-stage-mode-preview {
  border: 0;
}

.sutol-stage-bg {
  position: absolute;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  isolation: isolate;
}

.sutol-bg-scene-frame {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  border: 0;
  pointer-events: none;
  background: transparent;
}

.sutol-stage-bg::before,
.sutol-stage-bg::after {
  content: "";
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.sutol-bg-canvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  z-index: 1;
}

.sutol-bg-glow,
.sutol-bg-ring,
.sutol-bg-accent {
  position: absolute;
  pointer-events: none;
  z-index: 2;
}

.sutol-bg-glow {
  width: 34cqw;
  height: 34cqw;
  border-radius: 50%;
  filter: blur(1.4cqw);
  opacity: 0.58;
  animation: sutolBgFloat 11s ease-in-out infinite alternate;
}

.sutol-stage-mode-preview .sutol-bg-glow,
.sutol-stage-mode-snapshot .sutol-bg-glow {
  filter: none;
  opacity: 0.32;
  animation: none;
}

.sutol-bg-ring {
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 50%;
  opacity: 0.55;
  animation: sutolBgSpin 22s linear infinite;
}

.sutol-stage-mode-preview .sutol-bg-ring,
.sutol-stage-mode-snapshot .sutol-bg-ring {
  animation: none !important;
}

.sutol-bg-accent {
  border-radius: 999px;
  opacity: 0.62;
}

.sutol-html-stage::before {
  content: "";
  position: absolute;
  inset: 0;
  z-index: 1;
  background-image:
    linear-gradient(to right, rgba(227, 233, 242, 0.68) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(227, 233, 242, 0.68) 1px, transparent 1px);
  background-size: calc(100% / 8) calc(100% / 8);
  opacity: 0.78;
  pointer-events: none;
}

.sutol-html-stage.theme-dark::before {
  background-image:
    linear-gradient(to right, rgba(255, 255, 255, 0.045) 1px, transparent 1px),
    linear-gradient(to bottom, rgba(255, 255, 255, 0.045) 1px, transparent 1px);
  opacity: 0.46;
}

.sutol-html-stage::after {
  content: "";
  position: absolute;
  inset: 0;
  z-index: 1;
  background:
    linear-gradient(to right, transparent 49.85%, rgba(215, 224, 238, 0.86) 50%, transparent 50.15%),
    linear-gradient(to bottom, transparent 49.85%, rgba(215, 224, 238, 0.86) 50%, transparent 50.15%);
  pointer-events: none;
}

.sutol-html-stage.theme-dark::after {
  background:
    linear-gradient(to right, transparent 49.85%, rgba(255, 255, 255, 0.055) 50%, transparent 50.15%),
    linear-gradient(to bottom, transparent 49.85%, rgba(255, 255, 255, 0.055) 50%, transparent 50.15%);
}

.sutol-html-block {
  position: absolute;
  z-index: 3;
  box-sizing: border-box;
  padding: clamp(8px, 1.4cqw, 18px);
  border-radius: 18px;
  color: #142033;
  font-size: clamp(12px, var(--base-font-size), 96px);
  font-weight: 600;
  line-height: 1.22;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  max-width: calc(100% - var(--sutol-left, 0%) - 3cqw);
  max-height: calc(100% - var(--sutol-top, 0%) - 3cqw);
  overflow: hidden;
}

.sutol-html-stage.theme-dark .sutol-html-block {
  color: #F8FBFF;
  text-shadow: 0 0.2cqw 1.2cqw rgba(0, 0, 0, 0.28);
}

.sutol-html-block.is-title {
  font-weight: 800;
  line-height: 1.06;
}

.sutol-html-block.is-subtitle {
  font-weight: 700;
  line-height: 1.12;
}

.sutol-html-block.is-body {
  font-weight: 600;
  line-height: 1.24;
}

/* Bilim / Mikro Evren - Dramatik */
.sutol-html-block.text-style-bilim-dramatik {
  font-family: 'Rajdhani', sans-serif;
  font-weight: 600;
  color: #e6fbff;
}

.sutol-html-block.text-style-bilim-dramatik.is-title {
  font-family: 'Orbitron', sans-serif;
  font-weight: 900;
  letter-spacing: 0.04em;
  text-shadow: 0 0 6px #22d3ee, 0 0 18px #22d3ee, 0 0 36px #0891b2, 0 0 60px #0891b2;
  animation: glowPulseBilimDramatik 3.2s ease-in-out infinite;
}

@keyframes glowPulseBilimDramatik {
  0%, 100% { text-shadow: 0 0 6px #22d3ee, 0 0 18px #22d3ee, 0 0 36px #0891b2, 0 0 60px #0891b2; }
  50% { text-shadow: 0 0 10px #67e8f9, 0 0 26px #22d3ee, 0 0 48px #0891b2, 0 0 80px #0891b2; }
}

/* Bilim / Mikro Evren - Temiz */
.sutol-html-block.text-style-bilim-temiz {
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  color: #f0fbfd;
}

.sutol-html-block.text-style-bilim-temiz.is-title {
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 700;
  letter-spacing: 0.01em;
  text-shadow: 0 0 4px #67e8f9, 0 0 14px #22d3ee;
  animation: glowPulseBilimTemiz 4s ease-in-out infinite;
}

@keyframes glowPulseBilimTemiz {
  0%, 100% { text-shadow: 0 0 4px #67e8f9, 0 0 14px #22d3ee; opacity: 1; }
  50% { text-shadow: 0 0 8px #67e8f9, 0 0 22px #22d3ee; opacity: 0.92; }
}

/* Bilim / Mikro Evren - Deneysel */
.sutol-html-block.text-style-bilim-deneysel {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 500;
  color: #dffcff;
}

.sutol-html-block.text-style-bilim-deneysel.is-title {
  font-family: 'Michroma', monospace;
  font-weight: 400;
  letter-spacing: 0.06em;
  text-shadow: 0 0 5px #22d3ee, 0 0 16px #0e7490, 0 0 32px #0e7490;
  animation: glitchGlowBilimDeneysel 2.6s steps(12) infinite;
}

@keyframes glitchGlowBilimDeneysel {
  0%, 88%, 100% { text-shadow: 0 0 5px #22d3ee, 0 0 16px #0e7490, 0 0 32px #0e7490; transform: translate(0, 0); }
  90% { text-shadow: 0 0 2px #67e8f9, -1px 0 12px #0891b2; transform: translate(-1px, 0); }
  92% { text-shadow: 0 0 9px #67e8f9, 1px 0 20px #0891b2; transform: translate(1px, 0); }
  94% { text-shadow: 0 0 5px #22d3ee, 0 0 16px #0e7490; transform: translate(0, 0); }
}

/* Güneş Enerjisi - Dramatik */
.sutol-html-block.text-style-gunes-dramatik {
  font-family: 'Cormorant Garamond', serif;
  font-weight: 600;
  color: #fde68a;
}

.sutol-html-block.text-style-gunes-dramatik.is-title {
  font-family: 'Cinzel', serif;
  font-weight: 700;
  letter-spacing: 0.03em;
  text-shadow: 0 0 8px #fbbf24, 0 0 20px #fbbf24, 0 0 42px #d97706, 0 0 80px #d97706;
  animation: sunGlowDramatic 3.2s ease-in-out infinite alternate;
}

@keyframes sunGlowDramatic {
  0% { text-shadow: 0 0 8px #fbbf24, 0 0 20px #fbbf24, 0 0 40px #d97706, 0 0 60px #d97706; }
  100% { text-shadow: 0 0 14px #fde68a, 0 0 32px #fbbf24, 0 0 64px #fbbf24, 0 0 110px #d97706; }
}

/* Güneş Enerjisi - Temiz */
.sutol-html-block.text-style-gunes-temiz {
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  color: #fef3c7;
}

.sutol-html-block.text-style-gunes-temiz.is-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 700;
  letter-spacing: 0.01em;
  text-shadow: 0 0 6px #fbbf24, 0 0 16px #f59e0b;
  animation: sunPulseClean 2.6s ease-in-out infinite;
}

@keyframes sunPulseClean {
  0%, 100% { text-shadow: 0 0 6px #fbbf24, 0 0 16px #f59e0b; }
  50% { text-shadow: 0 0 10px #fde68a, 0 0 26px #fbbf24; }
}

/* Güneş Enerjisi - Deneysel */
.sutol-html-block.text-style-gunes-deneysel {
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 500;
  color: #fde68a;
}

.sutol-html-block.text-style-gunes-deneysel.is-title {
  font-family: 'Righteous', sans-serif;
  font-weight: 400;
  letter-spacing: 0.015em;
  text-shadow: 0 0 6px #fb923c, 0 0 18px #eab308, 0 0 36px #fb923c;
  animation: sunFlareFlicker 1.8s steps(6) infinite;
}

@keyframes sunFlareFlicker {
  0% { text-shadow: 0 0 6px #fb923c, 0 0 18px #eab308, 0 0 36px #fb923c; }
  20% { text-shadow: 0 0 10px #fde68a, 0 0 24px #fb923c, 0 0 48px #eab308; }
  40% { text-shadow: 0 0 5px #fb923c, 0 0 14px #eab308, 0 0 28px #fb923c; }
  60% { text-shadow: 0 0 12px #fde68a, 0 0 30px #fb923c, 0 0 55px #eab308; }
  80% { text-shadow: 0 0 7px #fb923c, 0 0 20px #eab308, 0 0 40px #fb923c; }
  100% { text-shadow: 0 0 6px #fb923c, 0 0 18px #eab308, 0 0 36px #fb923c; }
}

/* Uzay Teknolojileri - Dramatik */
.sutol-html-block.text-style-uzay-dramatik {
  font-family: 'Cormorant Garamond', serif;
  font-weight: 600;
  color: #e9d5ff;
}

.sutol-html-block.text-style-uzay-dramatik.is-title {
  font-family: 'Cinzel', serif;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-shadow: 0 0 10px #a855f7, 0 0 24px #7c3aed, 0 0 48px #4c1d95, 0 0 90px #4c1d95;
  animation: cosmicDeepGlow 4s ease-in-out infinite alternate;
}

@keyframes cosmicDeepGlow {
  0% { text-shadow: 0 0 10px #a855f7, 0 0 24px #7c3aed, 0 0 46px #4c1d95, 0 0 80px #4c1d95; }
  100% { text-shadow: 0 0 16px #c4b5fd, 0 0 34px #a855f7, 0 0 70px #7c3aed, 0 0 120px #4c1d95; }
}

/* Uzay Teknolojileri - Temiz */
.sutol-html-block.text-style-uzay-temiz {
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  color: #ddd6fe;
}

.sutol-html-block.text-style-uzay-temiz.is-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 700;
  letter-spacing: 0.01em;
  text-shadow: 0 0 6px #8b5cf6, 0 0 18px #6d28d9;
  animation: orbitPulseClean 3s ease-in-out infinite;
}

@keyframes orbitPulseClean {
  0%, 100% { text-shadow: 0 0 6px #8b5cf6, 0 0 18px #6d28d9; }
  50% { text-shadow: 0 0 10px #c4b5fd, 0 0 28px #8b5cf6; }
}

/* Uzay Teknolojileri - Deneysel */
.sutol-html-block.text-style-uzay-deneysel {
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 500;
  color: #c4b5fd;
}

.sutol-html-block.text-style-uzay-deneysel.is-title {
  font-family: 'Orbitron', sans-serif;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-shadow: 0 0 8px #7c3aed, 0 0 22px #4c1d95, 0 0 44px #312e81;
  animation: orbitDrift 5s linear infinite;
}

@keyframes orbitDrift {
  0% { text-shadow: 0 0 8px #7c3aed, 0 0 22px #4c1d95, 0 0 44px #312e81; }
  25% { text-shadow: 0 0 12px #a855f7, 0 0 30px #7c3aed, 0 0 60px #312e81; }
  50% { text-shadow: 0 0 6px #7c3aed, 0 0 18px #4c1d95, 0 0 36px #312e81; }
  75% { text-shadow: 0 0 14px #c4b5fd, 0 0 34px #7c3aed, 0 0 66px #312e81; }
  100% { text-shadow: 0 0 8px #7c3aed, 0 0 22px #4c1d95, 0 0 44px #312e81; }
}

/* Optik - Dramatik */
.sutol-html-block.text-style-optik-dramatik {
  font-family: 'Marcellus', serif;
  font-weight: 400;
  color: #fdfdfe;
}

.sutol-html-block.text-style-optik-dramatik.is-title {
  font-family: 'Cinzel', serif;
  font-weight: 800;
  letter-spacing: 0.03em;
  text-shadow: 0 0 6px #ffffff, 0 0 18px #e5e7eb, 0 0 36px #a5b4fc, 0 0 60px #a5b4fc;
  animation: mirrorGlowOptikDramatik 3.6s ease-in-out infinite;
}

@keyframes mirrorGlowOptikDramatik {
  0%, 100% { text-shadow: 0 0 6px #ffffff, 0 0 18px #e5e7eb, 0 0 36px #a5b4fc, 0 0 60px #a5b4fc; }
  50% { text-shadow: 0 0 10px #ffffff, 0 0 26px #e5e7eb, 0 0 48px #a5b4fc, 0 0 80px #a5b4fc; }
}

/* Optik - Temiz */
.sutol-html-block.text-style-optik-temiz {
  font-family: 'Nunito Sans', sans-serif;
  font-weight: 500;
  color: #f7f9fc;
}

.sutol-html-block.text-style-optik-temiz.is-title {
  font-family: 'Poppins', sans-serif;
  font-weight: 600;
  letter-spacing: 0.01em;
  text-shadow: 0 0 4px #ffffff, 0 0 14px #c7d2fe;
  animation: softShineOptikTemiz 4.2s ease-in-out infinite;
}

@keyframes softShineOptikTemiz {
  0%, 100% { text-shadow: 0 0 4px #ffffff, 0 0 14px #c7d2fe; opacity: 1; }
  50% { text-shadow: 0 0 8px #ffffff, 0 0 22px #c7d2fe; opacity: 0.94; }
}

/* Optik - Deneysel */
.sutol-html-block.text-style-optik-deneysel {
  font-family: 'Manrope', sans-serif;
  font-weight: 500;
  color: #ffffff;
}

.sutol-html-block.text-style-optik-deneysel.is-title {
  font-family: 'Syne', sans-serif;
  font-weight: 800;
  letter-spacing: 0.02em;
  background: linear-gradient(90deg, #f87171, #fbbf24, #4ade80, #60a5fa, #c084fc);
  background-size: 300% 100%;
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  -webkit-text-fill-color: transparent;
  filter: drop-shadow(0 0 6px rgba(255, 255, 255, 0.55)) drop-shadow(0 0 18px rgba(96, 165, 250, 0.45));
  animation: prismShiftOptikDeneysel 5s linear infinite;
}

@keyframes prismShiftOptikDeneysel {
  0% { background-position: 0% 50%; }
  100% { background-position: 300% 50%; }
}

/* Fizik Laboratuvarı - Dramatik */
.sutol-html-block.text-style-fizik-dramatik {
  font-family: 'Titillium Web', sans-serif;
  font-weight: 600;
  color: #eaf3ff;
}

.sutol-html-block.text-style-fizik-dramatik.is-title {
  font-family: 'Exo 2', sans-serif;
  font-weight: 900;
  letter-spacing: 0.03em;
  text-shadow: 0 0 4px #93c5fd, 0 0 2px #93c5fd, 0 0 20px #3b82f6, 0 0 40px #3b82f6, 0 0 70px #1d4ed8;
  animation: flickerFizikDramatik 3.4s linear infinite;
}

@keyframes flickerFizikDramatik {
  0%, 19%, 21%, 23%, 54%, 56%, 100% {
    text-shadow: 0 0 4px #93c5fd, 0 0 2px #93c5fd, 0 0 20px #3b82f6, 0 0 40px #3b82f6, 0 0 70px #1d4ed8;
    opacity: 1;
  }
  20%, 22%, 55% { text-shadow: none; opacity: 0.55; }
}

/* Fizik Laboratuvarı - Temiz */
.sutol-html-block.text-style-fizik-temiz {
  font-family: 'Mulish', sans-serif;
  font-weight: 500;
  color: #f0f6ff;
}

.sutol-html-block.text-style-fizik-temiz.is-title {
  font-family: 'Sora', sans-serif;
  font-weight: 700;
  letter-spacing: 0.01em;
  text-shadow: 0 0 4px #93c5fd, 0 0 14px #3b82f6;
  animation: pulseFizikTemiz 4s ease-in-out infinite;
}

@keyframes pulseFizikTemiz {
  0%, 100% { text-shadow: 0 0 4px #93c5fd, 0 0 14px #3b82f6; }
  50% { text-shadow: 0 0 8px #93c5fd, 0 0 22px #3b82f6; }
}

/* Fizik Laboratuvarı - Deneysel */
.sutol-html-block.text-style-fizik-deneysel {
  font-family: 'IBM Plex Mono', monospace;
  font-weight: 500;
  color: #e3edff;
}

.sutol-html-block.text-style-fizik-deneysel.is-title {
  font-family: 'Chakra Petch', sans-serif;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-shadow: 0 0 5px #60a5fa, 0 0 16px #1e40af, 0 0 34px #1e40af;
  animation: pulseFizikDeneysel 3.8s ease-in-out infinite;
}

@keyframes pulseFizikDeneysel {
  0%, 100% {
    text-shadow: 0 0 5px #60a5fa, 0 0 16px #1e40af, 0 0 34px #1e40af;
    transform: scale(1);
  }
  50% {
    text-shadow: 0 0 9px #93c5fd, 0 0 24px #1e40af, 0 0 48px #1e40af;
    transform: scale(1.01);
  }
}

/* Teknoloji - Dramatik */
.sutol-html-block.text-style-teknoloji-dramatik {
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  color: #bbf7d0;
}

.sutol-html-block.text-style-teknoloji-dramatik.is-title {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 700;
  letter-spacing: 0.02em;
  text-shadow: 0 0 8px #22c55e, 0 0 22px #22c55e, 0 0 46px #15803d, 0 0 90px #15803d;
  animation: matrixDeepGlow 3.4s ease-in-out infinite alternate;
}

@keyframes matrixDeepGlow {
  0% { text-shadow: 0 0 8px #22c55e, 0 0 22px #22c55e, 0 0 44px #15803d, 0 0 80px #15803d; }
  100% { text-shadow: 0 0 14px #4ade80, 0 0 32px #22c55e, 0 0 66px #15803d, 0 0 120px #15803d; }
}

/* Teknoloji - Temiz */
.sutol-html-block.text-style-teknoloji-temiz {
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  color: #dcfce7;
}

.sutol-html-block.text-style-teknoloji-temiz.is-title {
  font-family: 'Space Mono', monospace;
  font-weight: 700;
  letter-spacing: 0.01em;
  text-shadow: 0 0 6px #4ade80, 0 0 16px #16a34a;
  animation: circuitPulseClean 2.4s ease-in-out infinite;
}

@keyframes circuitPulseClean {
  0%, 100% { text-shadow: 0 0 6px #4ade80, 0 0 16px #16a34a; }
  50% { text-shadow: 0 0 10px #bbf7d0, 0 0 26px #4ade80; }
}

/* Teknoloji - Deneysel */
.sutol-html-block.text-style-teknoloji-deneysel {
  font-family: 'Space Mono', monospace;
  font-weight: 400;
  color: #a7f3d0;
}

.sutol-html-block.text-style-teknoloji-deneysel.is-title {
  font-family: 'Share Tech Mono', monospace;
  font-weight: 400;
  letter-spacing: 0.03em;
  text-shadow: 0 0 6px #34d399, 0 0 18px #065f46, 0 0 36px #34d399;
  animation: dataGlitchFlicker 1.6s steps(8) infinite;
}

@keyframes dataGlitchFlicker {
  0% { text-shadow: 0 0 6px #34d399, 0 0 18px #065f46, 0 0 36px #34d399; }
  15% { text-shadow: 0 0 10px #6ee7b7, 0 0 24px #34d399, 0 0 48px #065f46; }
  30% { text-shadow: 0 0 4px #34d399, 0 0 12px #065f46, 0 0 24px #34d399; }
  50% { text-shadow: 0 0 12px #6ee7b7, 0 0 30px #34d399, 0 0 56px #065f46; }
  70% { text-shadow: 0 0 6px #34d399, 0 0 16px #065f46, 0 0 32px #34d399; }
  100% { text-shadow: 0 0 6px #34d399, 0 0 18px #065f46, 0 0 36px #34d399; }
}

@media (prefers-reduced-motion: reduce) {
  .sutol-html-block.text-style-bilim-dramatik.is-title {
    animation: none;
    text-shadow: 0 0 8px #22d3ee, 0 0 24px #0891b2;
  }
  .sutol-html-block.text-style-bilim-temiz.is-title {
    animation: none;
    text-shadow: 0 0 6px #67e8f9, 0 0 16px #22d3ee;
    opacity: 1;
  }
  .sutol-html-block.text-style-bilim-deneysel.is-title {
    animation: none;
    text-shadow: 0 0 6px #22d3ee, 0 0 18px #0e7490;
    transform: none;
  }
  .sutol-html-block.text-style-gunes-dramatik.is-title {
    animation: none;
    text-shadow: 0 0 10px #fbbf24, 0 0 30px #d97706;
  }
  .sutol-html-block.text-style-gunes-temiz.is-title {
    animation: none;
    text-shadow: 0 0 8px #fbbf24, 0 0 18px #f59e0b;
  }
  .sutol-html-block.text-style-gunes-deneysel.is-title {
    animation: none;
    text-shadow: 0 0 8px #fb923c, 0 0 20px #eab308;
  }
  .sutol-html-block.text-style-uzay-dramatik.is-title {
    animation: none;
    text-shadow: 0 0 12px #a855f7, 0 0 36px #4c1d95;
  }
  .sutol-html-block.text-style-uzay-temiz.is-title {
    animation: none;
    text-shadow: 0 0 8px #8b5cf6, 0 0 20px #6d28d9;
  }
  .sutol-html-block.text-style-uzay-deneysel.is-title {
    animation: none;
    text-shadow: 0 0 10px #7c3aed, 0 0 30px #312e81;
  }
  .sutol-html-block.text-style-optik-dramatik.is-title {
    animation: none;
    text-shadow: 0 0 8px #ffffff, 0 0 24px #a5b4fc;
  }
  .sutol-html-block.text-style-optik-temiz.is-title {
    animation: none;
    text-shadow: 0 0 6px #ffffff, 0 0 16px #c7d2fe;
    opacity: 1;
  }
  .sutol-html-block.text-style-optik-deneysel.is-title {
    animation: none;
    background-position: 0% 50%;
    filter: drop-shadow(0 0 8px rgba(255, 255, 255, 0.6)) drop-shadow(0 0 20px rgba(96, 165, 250, 0.5));
  }
  .sutol-html-block.text-style-fizik-dramatik.is-title {
    animation: none;
    opacity: 1;
    text-shadow: 0 0 4px #93c5fd, 0 0 20px #3b82f6, 0 0 44px #1d4ed8;
  }
  .sutol-html-block.text-style-fizik-temiz.is-title {
    animation: none;
    text-shadow: 0 0 6px #93c5fd, 0 0 18px #3b82f6;
  }
  .sutol-html-block.text-style-fizik-deneysel.is-title {
    animation: none;
    transform: none;
    text-shadow: 0 0 6px #60a5fa, 0 0 20px #1e40af;
  }
  .sutol-html-block.text-style-teknoloji-dramatik.is-title {
    animation: none;
    text-shadow: 0 0 10px #22c55e, 0 0 34px #15803d;
  }
  .sutol-html-block.text-style-teknoloji-temiz.is-title {
    animation: none;
    text-shadow: 0 0 8px #4ade80, 0 0 18px #16a34a;
  }
  .sutol-html-block.text-style-teknoloji-deneysel.is-title {
    animation: none;
    text-shadow: 0 0 8px #34d399, 0 0 20px #065f46;
  }
}

/* Distinct open-license typography additions.
   Source: Google Fonts. License: SIL Open Font License 1.1. */
.sutol-html-block.text-style-open-oswald {
  font-family: 'Oswald', sans-serif;
  font-weight: 400;
  letter-spacing: 0.015em;
}

.sutol-html-block.text-style-open-oswald.is-title {
  font-weight: 700;
  letter-spacing: 0.035em;
}

.sutol-html-block.text-style-open-playfair-display {
  font-family: 'Playfair Display', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-open-playfair-display.is-title {
  font-weight: 800;
  letter-spacing: 0.015em;
}

.sutol-html-block.text-style-open-bebas-neue {
  font-family: 'Bebas Neue', sans-serif;
  font-weight: 400;
  letter-spacing: 0.045em;
}

.sutol-html-block.text-style-open-bungee {
  font-family: 'Bungee', sans-serif;
  font-weight: 400;
  letter-spacing: 0.015em;
}

.sutol-html-block.text-style-open-caveat {
  font-family: 'Caveat', cursive;
  font-weight: 400;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-open-caveat.is-title {
  font-weight: 700;
  letter-spacing: 0.02em;
}

.sutol-html-block.text-style-open-unbounded {
  font-family: 'Unbounded', sans-serif;
  font-weight: 400;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-open-unbounded.is-title {
  font-weight: 700;
  letter-spacing: 0.025em;
}

/* Font presets above define typography only. Color, glow and motion are
   applied independently by the optional text effect controls below. */
.sutol-html-stage .sutol-html-block[class*="text-style-"] {
  color: #142033;
  text-shadow: none;
  animation: none;
  filter: none;
  background: none;
  -webkit-text-fill-color: currentColor;
}

.sutol-html-stage.theme-dark .sutol-html-block[class*="text-style-"] {
  color: #f8fbff;
}

.sutol-html-block[class*="text-animation-"] {
  --sutol-glow: 1;
  transform-origin: center;
  will-change: transform, opacity, filter, text-shadow, background-position;
}

.sutol-html-block.text-animation-bilim-dramatik { animation: sutolEffectDeepGlow 3.2s ease-in-out infinite alternate !important; }
.sutol-html-block.text-animation-bilim-temiz { animation: sutolEffectSoftPulse 4s ease-in-out infinite !important; }
.sutol-html-block.text-animation-bilim-deneysel { animation: sutolEffectGlitch 2.6s steps(12) infinite !important; }
.sutol-html-block.text-animation-gunes-dramatik { animation: sutolEffectSolarFlare 2.8s cubic-bezier(.22, 1, .36, 1) infinite !important; }
.sutol-html-block.text-animation-gunes-temiz { animation: sutolEffectSolarBreath 2.2s ease-in-out infinite !important; }
.sutol-html-block.text-animation-gunes-deneysel { animation: sutolEffectFlicker 1.35s steps(6) infinite !important; }
.sutol-html-block.text-animation-uzay-dramatik { animation: sutolEffectCosmicBloom 3.6s ease-in-out infinite alternate !important; }
.sutol-html-block.text-animation-uzay-temiz { animation: sutolEffectOrbitPulse 2.8s ease-in-out infinite !important; }
.sutol-html-block.text-animation-uzay-deneysel { animation: sutolEffectDrift 4.2s ease-in-out infinite !important; }
.sutol-html-block.text-animation-optik-dramatik { animation: sutolEffectMirrorFlash 2.8s ease-in-out infinite !important; }
.sutol-html-block.text-animation-optik-temiz { animation: sutolEffectShimmer 3.2s ease-in-out infinite !important; }
.sutol-html-block.text-animation-optik-deneysel {
  background: linear-gradient(90deg, var(--sutol-text-color, #60a5fa), #ffffff, var(--sutol-text-color, #60a5fa)) !important;
  background-size: 300% 100% !important;
  -webkit-background-clip: text !important;
  background-clip: text !important;
  color: transparent !important;
  -webkit-text-fill-color: transparent !important;
  animation: sutolEffectPrism 5s linear infinite !important;
}
.sutol-html-block.text-animation-fizik-dramatik { animation: sutolEffectElectricFlicker 2.2s linear infinite !important; }
.sutol-html-block.text-animation-fizik-temiz { animation: sutolEffectEnergyWave 2.8s ease-in-out infinite !important; }
.sutol-html-block.text-animation-fizik-deneysel { animation: sutolEffectScalePulse 2.6s ease-in-out infinite !important; }
.sutol-html-block.text-animation-teknoloji-dramatik { animation: sutolEffectMatrixGlow 2.8s ease-in-out infinite alternate !important; }
.sutol-html-block.text-animation-teknoloji-temiz { animation: sutolEffectCircuitScan 2s steps(10) infinite !important; }
.sutol-html-block.text-animation-teknoloji-deneysel { animation: sutolEffectDataGlitch 1.25s steps(8) infinite !important; }
.sutol-html-block.text-animation-metalik-parlama,
.sutol-html-block.text-animation-isik-taramasi {
  background-size: 320% 100% !important;
  -webkit-background-clip: text !important;
  background-clip: text !important;
  color: transparent !important;
  -webkit-text-fill-color: transparent !important;
}
.sutol-html-block.text-animation-metalik-parlama {
  background-image: linear-gradient(
    110deg,
    var(--sutol-text-color, #cbd5e1) 0%,
    #64748b 18%,
    #ffffff 34%,
    #94a3b8 46%,
    #ffffff 56%,
    var(--sutol-text-color, #cbd5e1) 78%
  ) !important;
  background-size: 320% 100% !important;
  -webkit-background-clip: text !important;
  background-clip: text !important;
  animation: sutolEffectMetallicShine 3.2s cubic-bezier(.4, 0, .2, 1) infinite !important;
}
.sutol-html-block.text-animation-yavas-belirme {
  animation: sutolEffectSlowReveal 5.4s cubic-bezier(.22, 1, .36, 1) infinite !important;
}
.sutol-html-block.text-animation-daktilo {
  animation: none !important;
}
.sutol-html-block.text-animation-daktilo .sutol-typewriter-word {
  display: inline-block;
  opacity: 0;
  clip-path: inset(0 100% 0 0);
  border-right: 0.07em solid transparent;
  animation: sutolEffectTypewriterWord var(--sutol-type-cycle) ease-in-out infinite both;
  animation-delay: calc(var(--sutol-word-index) * 0.46s);
}
.sutol-html-block.text-animation-bulaniktan-net {
  animation: sutolEffectBlurFocus 4.8s cubic-bezier(.22, 1, .36, 1) infinite !important;
}
.sutol-html-block.text-animation-uc-boyutlu-donus {
  transform-origin: center top;
  animation: sutolEffectFlip3d 4.6s cubic-bezier(.22, 1, .36, 1) infinite !important;
}
.sutol-html-block.text-animation-ziplayarak-giris {
  animation: sutolEffectBounceIn 4.4s cubic-bezier(.2, .9, .3, 1.2) infinite !important;
}
.sutol-html-block.text-animation-isik-taramasi {
  background-image: linear-gradient(
    100deg,
    var(--sutol-text-color, #f8fbff) 0%,
    var(--sutol-text-color, #f8fbff) 35%,
    #ffffff 48%,
    #ffffff 53%,
    var(--sutol-text-color, #f8fbff) 66%,
    var(--sutol-text-color, #f8fbff) 100%
  ) !important;
  background-size: 320% 100% !important;
  -webkit-background-clip: text !important;
  background-clip: text !important;
  animation: sutolEffectSpotlightSweep 2.8s linear infinite !important;
}
.sutol-html-block.text-animation-perde-acilisi {
  animation: sutolEffectCurtainReveal 4.8s cubic-bezier(.22, 1, .36, 1) infinite !important;
}
.sutol-html-block.text-animation-sinematik-yaklasma {
  animation: sutolEffectCinematicZoom 5.2s cubic-bezier(.16, 1, .3, 1) infinite !important;
}
.sutol-html-block.text-animation-yercekimsiz-suzulme {
  animation: sutolEffectZeroGravity 5.6s ease-in-out infinite !important;
}
.sutol-html-block.text-animation-neon-kontur {
  color: transparent !important;
  -webkit-text-fill-color: transparent !important;
  -webkit-text-stroke: 1.5px var(--sutol-text-color, #f8fbff);
  animation: sutolEffectNeonOutline 2.6s steps(8) infinite !important;
}
.sutol-html-block.text-animation-golge-ekstruzyonu {
  animation: sutolEffectLongShadow 3.8s ease-in-out infinite !important;
}
.sutol-html-block.text-animation-sivi-dalga {
  animation: sutolEffectLiquidWave 3.6s cubic-bezier(.45, .05, .55, .95) infinite !important;
}
.sutol-html-block.text-animation-kesik-sinyal {
  animation: sutolEffectSignalCut 2.2s steps(12) infinite !important;
}
.sutol-html-block.text-animation-holografik-dalga {
  background-image: linear-gradient(
    105deg,
    var(--sutol-text-color, #67e8f9) 0%,
    #ffffff 18%,
    #60a5fa 34%,
    #c084fc 52%,
    #4ade80 70%,
    #ffffff 84%,
    var(--sutol-text-color, #67e8f9) 100%
  ) !important;
  background-size: 360% 100% !important;
  -webkit-background-clip: text !important;
  background-clip: text !important;
  color: transparent !important;
  -webkit-text-fill-color: transparent !important;
  animation: sutolEffectHolographicWave 4s ease-in-out infinite !important;
}

@keyframes sutolEffectDeepGlow {
  0% { text-shadow: 0 0 calc(4px * var(--sutol-glow)) currentColor, 0 0 calc(14px * var(--sutol-glow)) currentColor; transform: scale(0.985); opacity: 0.82; }
  100% { text-shadow: 0 0 calc(12px * var(--sutol-glow)) currentColor, 0 0 calc(38px * var(--sutol-glow)) currentColor, 0 0 calc(72px * var(--sutol-glow)) currentColor; transform: scale(1.035); opacity: 1; }
}

@keyframes sutolEffectSoftPulse {
  0%, 100% { text-shadow: 0 0 calc(3px * var(--sutol-glow)) currentColor, 0 0 calc(10px * var(--sutol-glow)) currentColor; transform: scale(0.99); opacity: 0.86; }
  50% { text-shadow: 0 0 calc(9px * var(--sutol-glow)) currentColor, 0 0 calc(30px * var(--sutol-glow)) currentColor, 0 0 calc(52px * var(--sutol-glow)) currentColor; transform: scale(1.025); opacity: 1; }
}

@keyframes sutolEffectGlitch {
  0%, 72%, 100% { text-shadow: 0 0 calc(7px * var(--sutol-glow)) currentColor, 0 0 calc(22px * var(--sutol-glow)) currentColor; transform: translate(0, 0) skewX(0); opacity: 1; }
  76% { text-shadow: -5px 0 calc(4px * var(--sutol-glow)) currentColor, 5px 0 calc(12px * var(--sutol-glow)) #ffffff; transform: translate(-4px, 1px) skewX(-4deg); opacity: 0.72; }
  80% { text-shadow: 6px 0 calc(6px * var(--sutol-glow)) currentColor, -4px 0 calc(14px * var(--sutol-glow)) #ffffff; transform: translate(5px, -1px) skewX(5deg); opacity: 1; }
  84% { transform: translate(-2px, 0) skewX(-2deg); }
  88% { transform: translate(0, 0) skewX(0); }
}

@keyframes sutolEffectFlicker {
  0%, 14%, 20%, 42%, 48%, 74%, 100% { text-shadow: 0 0 calc(9px * var(--sutol-glow)) currentColor, 0 0 calc(30px * var(--sutol-glow)) currentColor, 0 0 calc(58px * var(--sutol-glow)) currentColor; transform: scale(1.02); opacity: 1; }
  16%, 44%, 76% { text-shadow: none; transform: scale(0.985); opacity: 0.38; }
  18%, 46% { text-shadow: 0 0 calc(16px * var(--sutol-glow)) currentColor, 0 0 calc(64px * var(--sutol-glow)) currentColor; opacity: 0.9; }
}

@keyframes sutolEffectDrift {
  0%, 100% { text-shadow: -8px 0 calc(16px * var(--sutol-glow)) currentColor, 0 0 calc(30px * var(--sutol-glow)) currentColor; transform: translateX(-4px) perspective(500px) rotateY(-2deg); opacity: 0.82; }
  50% { text-shadow: 8px 0 calc(34px * var(--sutol-glow)) currentColor, 0 0 calc(58px * var(--sutol-glow)) currentColor; transform: translateX(4px) perspective(500px) rotateY(2deg); opacity: 1; }
}

@keyframes sutolEffectScalePulse {
  0%, 100% { text-shadow: 0 0 calc(5px * var(--sutol-glow)) currentColor, 0 0 calc(16px * var(--sutol-glow)) currentColor; transform: scale(0.975); opacity: 0.8; }
  45% { text-shadow: 0 0 calc(14px * var(--sutol-glow)) currentColor, 0 0 calc(46px * var(--sutol-glow)) currentColor, 0 0 calc(76px * var(--sutol-glow)) currentColor; transform: scale(1.045); opacity: 1; }
  55% { transform: scale(1.015); }
}

@keyframes sutolEffectPrism {
  0% { background-position: 0% 50%; transform: skewX(-2deg) scale(0.99); filter: drop-shadow(-4px 0 calc(5px * var(--sutol-glow)) var(--sutol-text-color, #60a5fa)); }
  50% { transform: skewX(2deg) scale(1.035); filter: drop-shadow(4px 0 calc(18px * var(--sutol-glow)) var(--sutol-text-color, #60a5fa)); }
  100% { background-position: 300% 50%; transform: skewX(-2deg) scale(0.99); filter: drop-shadow(-4px 0 calc(5px * var(--sutol-glow)) var(--sutol-text-color, #60a5fa)); }
}

@keyframes sutolEffectSolarFlare {
  0%, 100% { text-shadow: -8px 0 calc(12px * var(--sutol-glow)) currentColor, 0 0 calc(24px * var(--sutol-glow)) currentColor; transform: scale(0.98); opacity: 0.8; }
  40% { text-shadow: 0 0 calc(18px * var(--sutol-glow)) #ffffff, 0 0 calc(48px * var(--sutol-glow)) currentColor, 12px 0 calc(82px * var(--sutol-glow)) currentColor; transform: scale(1.05); opacity: 1; }
  55% { transform: scale(1.015); }
}

@keyframes sutolEffectSolarBreath {
  0%, 100% { text-shadow: 0 0 calc(4px * var(--sutol-glow)) currentColor; transform: translateY(1px) scale(0.99); }
  50% { text-shadow: 0 0 calc(12px * var(--sutol-glow)) #ffffff, 0 0 calc(36px * var(--sutol-glow)) currentColor; transform: translateY(-2px) scale(1.03); }
}

@keyframes sutolEffectCosmicBloom {
  0% { text-shadow: 0 0 calc(8px * var(--sutol-glow)) currentColor, -10px 0 calc(28px * var(--sutol-glow)) currentColor; transform: perspective(600px) rotateX(3deg) scale(0.98); opacity: 0.72; }
  100% { text-shadow: 0 0 calc(18px * var(--sutol-glow)) #ffffff, 0 0 calc(48px * var(--sutol-glow)) currentColor, 10px 0 calc(86px * var(--sutol-glow)) currentColor; transform: perspective(600px) rotateX(-3deg) scale(1.045); opacity: 1; }
}

@keyframes sutolEffectOrbitPulse {
  0%, 100% { text-shadow: -6px 0 calc(12px * var(--sutol-glow)) currentColor; transform: translate(-3px, 1px) scale(0.99); }
  50% { text-shadow: 6px 0 calc(34px * var(--sutol-glow)) currentColor, 0 0 calc(54px * var(--sutol-glow)) currentColor; transform: translate(3px, -2px) scale(1.03); }
}

@keyframes sutolEffectMirrorFlash {
  0%, 100% { text-shadow: -10px 0 calc(10px * var(--sutol-glow)) currentColor; transform: skewX(-1deg); opacity: 0.78; }
  45% { text-shadow: 0 0 calc(16px * var(--sutol-glow)) #ffffff, 0 0 calc(42px * var(--sutol-glow)) currentColor; transform: skewX(1deg) scale(1.035); opacity: 1; }
  55% { text-shadow: 10px 0 calc(20px * var(--sutol-glow)) currentColor; }
}

@keyframes sutolEffectShimmer {
  0%, 100% { text-shadow: -6px 0 calc(8px * var(--sutol-glow)) currentColor; opacity: 0.75; transform: translateX(-2px); }
  50% { text-shadow: 6px 0 calc(26px * var(--sutol-glow)) #ffffff, 0 0 calc(38px * var(--sutol-glow)) currentColor; opacity: 1; transform: translateX(2px); }
}

@keyframes sutolEffectElectricFlicker {
  0%, 12%, 18%, 52%, 58%, 100% { text-shadow: -3px 0 calc(8px * var(--sutol-glow)) currentColor, 3px 0 calc(24px * var(--sutol-glow)) #ffffff, 0 0 calc(44px * var(--sutol-glow)) currentColor; transform: skewX(0); opacity: 1; }
  14%, 54% { text-shadow: none; transform: skewX(-5deg) translateX(-3px); opacity: 0.3; }
  16%, 56% { text-shadow: 5px 0 calc(34px * var(--sutol-glow)) currentColor; transform: skewX(4deg) translateX(3px); opacity: 0.92; }
}

@keyframes sutolEffectEnergyWave {
  0%, 100% { text-shadow: 0 5px calc(10px * var(--sutol-glow)) currentColor; transform: translateY(2px) scale(0.99); opacity: 0.78; }
  50% { text-shadow: 0 -5px calc(32px * var(--sutol-glow)) currentColor, 0 0 calc(52px * var(--sutol-glow)) currentColor; transform: translateY(-3px) scale(1.035); opacity: 1; }
}

@keyframes sutolEffectMatrixGlow {
  0% { text-shadow: 0 4px calc(8px * var(--sutol-glow)) currentColor; transform: scaleY(0.97); opacity: 0.68; }
  100% { text-shadow: 0 -4px calc(20px * var(--sutol-glow)) currentColor, 0 0 calc(56px * var(--sutol-glow)) currentColor; transform: scaleY(1.04); opacity: 1; }
}

@keyframes sutolEffectCircuitScan {
  0%, 100% { text-shadow: -8px 0 calc(8px * var(--sutol-glow)) currentColor; transform: translateX(-2px); opacity: 0.72; }
  50% { text-shadow: 8px 0 calc(30px * var(--sutol-glow)) currentColor, 0 0 calc(48px * var(--sutol-glow)) currentColor; transform: translateX(2px); opacity: 1; }
}

@keyframes sutolEffectDataGlitch {
  0%, 62%, 100% { text-shadow: 0 0 calc(9px * var(--sutol-glow)) currentColor, 0 0 calc(26px * var(--sutol-glow)) currentColor; transform: translate(0, 0) skewX(0); opacity: 1; }
  66% { text-shadow: -7px 0 calc(4px * var(--sutol-glow)) #ffffff, 5px 0 calc(16px * var(--sutol-glow)) currentColor; transform: translate(-5px, 2px) skewX(-7deg); opacity: 0.58; }
  72% { text-shadow: 7px 0 calc(8px * var(--sutol-glow)) currentColor, -5px 0 calc(18px * var(--sutol-glow)) #ffffff; transform: translate(6px, -2px) skewX(7deg); opacity: 1; }
  78% { transform: translate(-3px, 0) skewX(-3deg); }
  84% { transform: translate(0, 0) skewX(0); }
}

@keyframes sutolEffectMetallicShine {
  0% { background-position: 110% 50%; text-shadow: -4px 0 calc(4px * var(--sutol-glow)) #ffffff; transform: perspective(600px) rotateY(-2deg); }
  45% { background-position: 45% 50%; text-shadow: 0 0 calc(16px * var(--sutol-glow)) #ffffff, 0 0 calc(32px * var(--sutol-glow)) var(--sutol-text-color, #cbd5e1); transform: perspective(600px) rotateY(2deg) scale(1.025); }
  100% { background-position: -110% 50%; text-shadow: 4px 0 calc(4px * var(--sutol-glow)) #ffffff; transform: perspective(600px) rotateY(-2deg); }
}

@keyframes sutolEffectSlowReveal {
  0%, 12% { clip-path: inset(0 100% 0 0); transform: translateY(24px); filter: blur(12px); opacity: 0; }
  55%, 84% { clip-path: inset(0 0 0 0); transform: translateY(0); filter: blur(0); opacity: 1; text-shadow: 0 0 calc(18px * var(--sutol-glow)) currentColor; }
  100% { clip-path: inset(0 0 0 0); transform: translateY(-8px); filter: blur(3px); opacity: 0; }
}

@keyframes sutolEffectTypewriterWord {
  0%, 2% {
    clip-path: inset(0 100% 0 0);
    border-right-color: currentColor;
    transform: translateY(0.12em);
    opacity: 0;
  }
  5% {
    clip-path: inset(0 42% 0 0);
    border-right-color: currentColor;
    opacity: 1;
  }
  8%, 76% {
    clip-path: inset(0 0 0 0);
    border-right-color: transparent;
    transform: translateY(0);
    opacity: 1;
  }
  88%, 100% {
    clip-path: inset(0 0 0 0);
    border-right-color: transparent;
    opacity: 0;
  }
}

@keyframes sutolEffectBlurFocus {
  0%, 12% { filter: blur(16px); letter-spacing: 0.22em; transform: scale(1.12); opacity: 0; }
  48%, 82% { filter: blur(0); letter-spacing: 0.02em; transform: scale(1); opacity: 1; text-shadow: 0 0 calc(16px * var(--sutol-glow)) currentColor; }
  100% { filter: blur(8px); letter-spacing: 0.1em; transform: scale(0.96); opacity: 0; }
}

@keyframes sutolEffectFlip3d {
  0%, 10% { transform: perspective(700px) rotateX(-92deg) translateY(-22px); filter: blur(6px); opacity: 0; }
  42% { transform: perspective(700px) rotateX(12deg) translateY(3px); filter: blur(0); opacity: 1; text-shadow: 0 0 calc(24px * var(--sutol-glow)) currentColor; }
  56%, 84% { transform: perspective(700px) rotateX(0) translateY(0); opacity: 1; }
  100% { transform: perspective(700px) rotateX(78deg) translateY(16px); opacity: 0; }
}

@keyframes sutolEffectBounceIn {
  0%, 8% { transform: translateY(-46px) scale(0.72); opacity: 0; }
  32% { transform: translateY(12px) scale(1.08); opacity: 1; text-shadow: 0 0 calc(28px * var(--sutol-glow)) currentColor; }
  44% { transform: translateY(-7px) scale(0.96); }
  54% { transform: translateY(3px) scale(1.025); }
  64%, 86% { transform: translateY(0) scale(1); opacity: 1; }
  100% { transform: translateY(28px) scale(0.86); opacity: 0; }
}

@keyframes sutolEffectSpotlightSweep {
  0% { background-position: 120% 50%; filter: drop-shadow(-8px 0 calc(4px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff)); }
  50% { filter: drop-shadow(0 0 calc(20px * var(--sutol-glow)) #ffffff); transform: scale(1.02); }
  100% { background-position: -120% 50%; filter: drop-shadow(8px 0 calc(4px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff)); }
}

@keyframes sutolEffectCurtainReveal {
  0%, 10% { clip-path: inset(0 50% 0 50%); transform: scaleX(0.82); filter: blur(7px); opacity: 0; }
  48%, 84% { clip-path: inset(0 0 0 0); transform: scaleX(1); filter: blur(0); opacity: 1; text-shadow: 0 0 calc(18px * var(--sutol-glow)) currentColor; }
  100% { clip-path: inset(0 50% 0 50%); transform: scaleX(0.9); opacity: 0; }
}

@keyframes sutolEffectCinematicZoom {
  0%, 10% { transform: perspective(800px) translateZ(260px) scale(1.55); filter: blur(18px); opacity: 0; letter-spacing: 0.18em; }
  48%, 84% { transform: perspective(800px) translateZ(0) scale(1); filter: blur(0); opacity: 1; letter-spacing: 0.02em; text-shadow: 0 0 calc(20px * var(--sutol-glow)) currentColor; }
  100% { transform: perspective(800px) translateZ(-120px) scale(0.82); filter: blur(8px); opacity: 0; }
}

@keyframes sutolEffectZeroGravity {
  0%, 100% { transform: translate(-5px, 7px) rotate(-1.4deg) scale(0.99); text-shadow: -6px 8px calc(16px * var(--sutol-glow)) currentColor; opacity: 0.8; }
  35% { transform: translate(3px, -6px) rotate(1deg) scale(1.025); text-shadow: 4px -8px calc(28px * var(--sutol-glow)) currentColor; opacity: 1; }
  68% { transform: translate(6px, 3px) rotate(-0.5deg) scale(1.01); text-shadow: 8px 4px calc(22px * var(--sutol-glow)) currentColor; }
}

@keyframes sutolEffectNeonOutline {
  0%, 14%, 20%, 52%, 58%, 100% { -webkit-text-stroke-width: 1.5px; text-shadow: 0 0 calc(7px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff), 0 0 calc(24px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff); opacity: 1; }
  16%, 54% { -webkit-text-stroke-width: 0.5px; text-shadow: none; opacity: 0.28; }
  18%, 56% { -webkit-text-stroke-width: 2.4px; text-shadow: 0 0 calc(15px * var(--sutol-glow)) #ffffff, 0 0 calc(42px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff); opacity: 1; }
}

@keyframes sutolEffectLongShadow {
  0%, 100% { text-shadow: 1px 1px 0 currentColor, 2px 2px 0 currentColor, 3px 3px 0 currentColor, 5px 5px calc(8px * var(--sutol-glow)) currentColor; transform: translate(-2px, -2px); }
  50% { text-shadow: 2px 2px 0 currentColor, 4px 4px 0 currentColor, 6px 6px 0 currentColor, 8px 8px 0 currentColor, 12px 12px calc(24px * var(--sutol-glow)) currentColor; transform: translate(3px, 3px) scale(1.025); }
}

@keyframes sutolEffectLiquidWave {
  0%, 100% { transform: skewX(-5deg) rotateZ(-0.8deg) scaleY(0.96); text-shadow: -5px 3px calc(12px * var(--sutol-glow)) currentColor; }
  25% { transform: skewX(4deg) rotateZ(0.6deg) scaleY(1.04); text-shadow: 3px -4px calc(24px * var(--sutol-glow)) currentColor; }
  50% { transform: skewX(-2deg) rotateZ(0.8deg) scaleY(0.98); text-shadow: 6px 2px calc(34px * var(--sutol-glow)) currentColor; }
  75% { transform: skewX(5deg) rotateZ(-0.4deg) scaleY(1.03); text-shadow: -3px -3px calc(20px * var(--sutol-glow)) currentColor; }
}

@keyframes sutolEffectSignalCut {
  0%, 58%, 100% { clip-path: inset(0 0 0 0); transform: translate(0, 0) skewX(0); filter: contrast(1); opacity: 1; }
  62% { clip-path: polygon(0 0, 100% 0, 100% 35%, 4% 35%, 4% 58%, 100% 58%, 100% 100%, 0 100%); transform: translate(-6px, 0) skewX(-5deg); filter: contrast(1.8); text-shadow: 7px 0 calc(12px * var(--sutol-glow)) currentColor; }
  68% { clip-path: polygon(0 0, 96% 0, 96% 42%, 0 42%, 0 65%, 96% 65%, 96% 100%, 0 100%); transform: translate(7px, -1px) skewX(6deg); opacity: 0.62; }
  74% { clip-path: inset(0 0 0 0); transform: translate(-2px, 1px); opacity: 1; }
}

@keyframes sutolEffectHolographicWave {
  0%, 100% { background-position: 120% 50%; transform: perspective(700px) rotateY(-3deg) skewX(-1deg); filter: drop-shadow(-5px 0 calc(8px * var(--sutol-glow)) #60a5fa); }
  50% { background-position: -120% 50%; transform: perspective(700px) rotateY(3deg) skewX(1deg) scale(1.035); filter: drop-shadow(5px 0 calc(22px * var(--sutol-glow)) #c084fc); }
}

.sutol-html-block.is-glow-off {
  text-shadow: none !important;
  filter: none !important;
}

@media (prefers-reduced-motion: reduce) {
  .sutol-html-block[class*="text-animation-"] {
    animation: none !important;
    transform: none !important;
  }
  .sutol-html-block.text-animation-daktilo .sutol-typewriter-word {
    animation: none !important;
    clip-path: none;
    border-right-color: transparent;
    transform: none;
    opacity: 1;
  }
}

.sutol-html-block.is-selected {
  outline: 2px solid #0B7BFF;
  background: rgba(11, 123, 255, 0.08);
}

.sutol-html-stage.theme-dark .sutol-html-block.is-selected {
  outline-color: rgba(103, 232, 249, 0.86);
  background: rgba(103, 232, 249, 0.10);
}

.sutol-html-component {
  position: absolute;
  z-index: 2;
  box-sizing: border-box;
  overflow: hidden;
  border-radius: 18px;
  pointer-events: none;
  color: #F8FBFF;
}

.sutol-html-component::before,
.sutol-html-component::after,
.sutol-html-component .sutol-component-shape,
.sutol-html-component .sutol-component-shape::before,
.sutol-html-component .sutol-component-shape::after {
  content: "";
  position: absolute;
  box-sizing: border-box;
  pointer-events: none;
}

.sutol-html-component::before {
  inset: 0;
  border-radius: inherit;
  background: linear-gradient(135deg, #060914 0%, #11162A 66%, #273047 100%);
  border: 1px solid rgba(255, 255, 255, 0.16);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.05);
}

.sutol-html-component::after {
  inset: 12%;
  border-radius: 999px;
  border: 1px solid rgba(255, 209, 102, 0.42);
  transform: rotate(-16deg);
}

.sutol-html-component .sutol-component-shape,
.sutol-html-component-inner {
  inset: 0;
  z-index: 1;
}

.sutol-html-component-inner,
.sutol-html-component-inner > * {
  position: absolute;
  width: 100%;
  height: 100%;
}

.sutol-html-component-inner {
  overflow: hidden;
  border-radius: inherit;
}

.sutol-html-component-inner > * {
  inset: 0;
}

.sutol-html-component.component-3d-model {
  background: radial-gradient(circle at 50% 42%, rgba(42, 118, 196, 0.16), rgba(3, 8, 18, 0.04) 70%);
}

.sutol-3d-model-inner,
.sutol-3d-model-viewer {
  display: block;
  width: 100%;
  height: 100%;
  background: transparent;
  --poster-color: transparent;
}

.sutol-export-stage .sutol-html-component.component-3d-model,
.sutol-export-stage .sutol-3d-model-viewer {
  pointer-events: auto;
  cursor: grab;
}

.sutol-export-stage .sutol-3d-model-viewer:active {
  cursor: grabbing;
}

.sutol-html-component .sutol-component-shape::before {
  left: 50%;
  top: 50%;
  width: 14%;
  aspect-ratio: 1;
  border-radius: 50%;
  background: #FFD166;
  transform: translate(-50%, -50%);
  box-shadow:
    -22cqw -6cqw 0 -2cqw rgba(103, 232, 249, 0.82),
    18cqw 8cqw 0 -2cqw rgba(255, 126, 179, 0.82);
}

.sutol-html-component .sutol-component-shape::after {
  left: 20%;
  right: 20%;
  top: 50%;
  height: 1px;
  background: rgba(255, 255, 255, 0.44);
  transform: rotate(24deg);
}

.sutol-html-component.has-html-component::before,
.sutol-html-component.has-html-component::after {
  display: none;
}

.sutol-html-component.is-selected {
  outline: 2px solid #0B7BFF;
  outline-offset: 2px;
}

.sutol-html-stage.theme-dark .sutol-html-component.is-selected {
  outline-color: rgba(103, 232, 249, 0.90);
}

.sutol-html-component[class*="component-physics-"]::before {
  background: linear-gradient(135deg, #05070C 0%, #111827 68%, #16383A 100%);
}

.sutol-html-component[class*="component-physics-"]::after {
  border-color: rgba(94, 234, 212, 0.36);
}

.sutol-html-component[class*="component-physics-"] .sutol-component-shape::before {
  left: 16%;
  right: 16%;
  top: 54%;
  width: auto;
  height: 2px;
  aspect-ratio: auto;
  border-radius: 999px;
  background: #5EEAD4;
  transform: rotate(-10deg);
  box-shadow: 0 0 14px rgba(94, 234, 212, 0.34);
}

.sutol-html-component[class*="component-physics-"] .sutol-component-shape::after {
  left: 44%;
  top: 58%;
  width: 14%;
  height: 20%;
  border-left: 2px solid rgba(94, 234, 212, 0.76);
  border-bottom: 2px solid rgba(94, 234, 212, 0.76);
  background: transparent;
  transform: skewX(-12deg);
}

.component-physics-pulley .sutol-component-shape::before,
.component-physics-gears .sutol-component-shape::before {
  left: 28%;
  top: 25%;
  width: 24%;
  height: 24%;
  border: 2px solid #5EEAD4;
  border-radius: 50%;
  background: transparent;
  transform: none;
  box-shadow: 24cqw 18cqw 0 -1cqw rgba(94, 234, 212, 0.44);
}

.component-physics-pendulum .sutol-component-shape::before {
  left: 50%;
  top: 18%;
  width: 1px;
  height: 54%;
  background: #5EEAD4;
  transform: rotate(-14deg);
}

.component-physics-pendulum .sutol-component-shape::after {
  left: 56%;
  top: 68%;
  width: 14%;
  aspect-ratio: 1;
  border-radius: 50%;
  background: #5EEAD4;
  transform: none;
}

.sutol-html-component[class*="component-optics-"]::before {
  background: linear-gradient(135deg, #070716 0%, #17142F 64%, #2B1640 100%);
}

.sutol-html-component[class*="component-optics-"]::after {
  inset: 12% 48%;
  border-radius: 999px;
  border-color: rgba(255, 126, 179, 0.78);
  transform: none;
}

.sutol-html-component[class*="component-optics-"] .sutol-component-shape::before,
.sutol-html-component[class*="component-optics-"] .sutol-component-shape::after {
  left: 10%;
  right: 10%;
  top: 48%;
  width: auto;
  height: 2px;
  border-radius: 999px;
  background: linear-gradient(90deg, transparent, #7EFFF5, #FF7EB3, transparent);
  transform: rotate(20deg);
  box-shadow: 0 0 14px rgba(126, 255, 245, 0.36);
}

.sutol-html-component[class*="component-optics-"] .sutol-component-shape::after {
  transform: rotate(-16deg);
}

.sutol-html-component[class*="component-solar-"]::before {
  background: linear-gradient(180deg, #06111F 0%, #0D2B5E 62%, #07162B 100%);
}

.sutol-html-component[class*="component-solar-"]::after {
  right: 8%;
  top: 8%;
  left: auto;
  bottom: auto;
  width: 24%;
  aspect-ratio: 1;
  border-radius: 50%;
  border: 0;
  background: radial-gradient(circle, #FFF2B8 0%, #FFD23F 48%, rgba(255, 210, 63, 0) 72%);
  transform: none;
}

.sutol-html-component[class*="component-solar-"] .sutol-component-shape::before {
  left: 14%;
  right: 12%;
  top: 60%;
  width: auto;
  height: 22%;
  aspect-ratio: auto;
  border-radius: 4px;
  background:
    linear-gradient(90deg, transparent 31%, rgba(103, 232, 249, 0.48) 32%, transparent 33%, transparent 65%, rgba(103, 232, 249, 0.48) 66%, transparent 67%),
    linear-gradient(0deg, transparent 47%, rgba(103, 232, 249, 0.48) 48%, transparent 50%),
    rgba(14, 73, 132, 0.72);
  transform: perspective(30cqw) rotateX(58deg) rotateZ(-6deg);
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.22);
}

.sutol-html-component[class*="component-space-"] {
  border-radius: 12px;
}

.sutol-html-component[class*="component-space-"]::before {
  background: transparent;
  border: 0;
  box-shadow: none;
}

.sutol-html-component[class*="component-space-"]::after {
  display: none;
}

.component-space-star-sticker .sutol-component-shape::before {
  left: 18%;
  top: 12%;
  width: 64%;
  aspect-ratio: 1;
  clip-path: polygon(50% 0%, 61% 34%, 98% 35%, 68% 56%, 79% 91%, 50% 69%, 21% 91%, 32% 56%, 2% 35%, 39% 34%);
  border-radius: 0;
  background: linear-gradient(135deg, #FFF4BE, #FFD166 54%, #FF8F3D);
  transform: none;
  box-shadow: 0 0 22px rgba(255, 209, 102, 0.52);
}

.component-space-planet-sticker .sutol-component-shape::before {
  left: 26%;
  top: 26%;
  width: 48%;
  aspect-ratio: 1;
  border-radius: 50%;
  background: radial-gradient(circle at 30% 28%, #FFE0A3, #FFB347 54%, #FF7B72);
  transform: none;
  box-shadow: 0 0 18px rgba(103, 232, 249, 0.25);
}

.component-space-planet-sticker .sutol-component-shape::after {
  left: 12%;
  top: 46%;
  width: 76%;
  height: 14%;
  border: 2px solid rgba(103, 232, 249, 0.56);
  border-radius: 50%;
  background: transparent;
  transform: rotate(-12deg);
}

.component-space-rocket-sticker .sutol-component-shape::before {
  left: 40%;
  top: 12%;
  width: 22%;
  height: 58%;
  border-radius: 999px 999px 40% 40%;
  background: linear-gradient(180deg, #F5F7FB, #DDE5F3 60%, #9AA9C4);
  transform: rotate(-20deg);
  box-shadow: -12cqw 24cqw 0 -8cqw #FF4D6D, 12cqw 24cqw 0 -8cqw #FF4D6D;
}

.component-space-rocket-sticker .sutol-component-shape::after {
  left: 43%;
  top: 64%;
  width: 14%;
  height: 28%;
  border-radius: 50% 50% 42% 42%;
  background: linear-gradient(180deg, #FFF0A6, #FF9F43, rgba(255, 159, 67, 0));
  transform: rotate(-20deg);
}

.component-space-satellite-sticker .sutol-component-shape::before {
  left: 38%;
  top: 34%;
  width: 24%;
  height: 22%;
  border-radius: 8px;
  background: #2B6DA1;
  transform: rotate(10deg);
  box-shadow: -24cqw -4cqw 0 -4cqw #0F3054, 24cqw 4cqw 0 -4cqw #0F3054;
}

.component-space-satellite-sticker .sutol-component-shape::after {
  left: 46%;
  top: 48%;
  width: 8%;
  height: 36%;
  background: linear-gradient(180deg, rgba(255, 209, 102, 0.72), rgba(255, 209, 102, 0));
  transform: rotate(-12deg);
}

.component-micro-cell::before {
  background: linear-gradient(135deg, #060812 0%, #10203A 64%, #0D3534 100%);
}

.component-micro-cell::after {
  inset: 18% 28%;
  border-color: rgba(140, 224, 209, 0.52);
  border-radius: 48%;
  transform: rotate(14deg);
}

.sutol-html-empty {
  position: absolute;
  inset: 0;
  z-index: 3;
  display: grid;
  place-items: center;
  color: #667389;
  font-size: clamp(14px, 2.2cqw, 22px);
  font-weight: 700;
}

.sutol-html-stage.theme-dark .sutol-html-empty {
  color: rgba(255, 255, 255, 0.72);
}

.sutol-html-badge {
  position: absolute;
  right: 16px;
  bottom: 14px;
  z-index: 4;
  padding: 7px 10px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.88);
  border: 1px solid #DCE5F1;
  color: #667389;
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0;
}

.sutol-html-stage.theme-dark .sutol-html-badge {
  background: rgba(3, 6, 15, 0.72);
  border-color: rgba(255, 255, 255, 0.12);
  color: rgba(255, 255, 255, 0.78);
}

@media (prefers-reduced-motion: reduce) {
  .sutol-bg-glow,
  .sutol-bg-ring {
    animation: none !important;
  }
}

@keyframes sutolBgFloat {
  from { transform: translate3d(0, 0, 0) scale(1); }
  to { transform: translate3d(1.4cqw, -1.0cqw, 0) scale(1.06); }
}

@keyframes sutolBgSpin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

''';

const String _backgroundScript = r'''
(function () {
  window.SutolStageBackgrounds = window.SutolStageBackgrounds || {
    refresh: function () {}
  };
})();
''';

const String _stageComponentScript = r'''
(function () {
  if (window.SutolStageComponents) {
    window.SutolStageComponents.refresh();
    return;
  }

  function refresh() {
    document.querySelectorAll('.sutol-html-component').forEach(function (element) {
      element.dataset.sutolComponentReady = '1';
    });
  }

  window.SutolStageComponents = { refresh: refresh };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', refresh, { once: true });
  } else {
    refresh();
  }
})();
''';

const String _stagePatchScript = r'''
(function () {
  if (window.SutolStagePatcher) return;

  function selectorFor(attribute, id) {
    const safeId = String(id).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
    return '[' + attribute + '="' + safeId + '"]';
  }

  function setOptionalAttribute(element, name, value) {
    if (value === null || value === undefined) {
      element.removeAttribute(name);
    } else {
      element.setAttribute(name, String(value));
    }
  }

  function fitText(element) {
    // Metin kutusu sahnenin güvenli alanını aşarsa yazı boyutunu kademeli
    // olarak küçültür. CSS'teki min değer okunabilirlik sınırını korur.
    element.style.removeProperty('font-size');
    const baseSize = parseFloat(window.getComputedStyle(element).fontSize) || 12;
    let scale = 1;
    let attempts = 0;
    while (element.scrollHeight > element.clientHeight + 1 && scale > 0.46 && attempts < 18) {
      scale *= 0.92;
      element.style.fontSize = (baseSize * scale).toFixed(2) + 'px';
      attempts += 1;
    }
  }

  function fitAllText() {
    document.querySelectorAll('.sutol-html-block').forEach(fitText);
  }

  function patchElement(attribute, item) {
    const element = document.querySelector(selectorFor(attribute, item.id));
    if (!element) return false;
    element.className = item.className;
    element.setAttribute('data-reveal-step', String(item.revealStep));
    setOptionalAttribute(element, 'data-hotspot-target', item.hotspotTargetPageId);
    element.style.left = item.left;
    element.style.top = item.top;
    element.style.width = item.width;
    element.style.setProperty('--sutol-left', item.left);
    element.style.setProperty('--sutol-top', item.top);
    if (item.height !== undefined) element.style.height = item.height;
    if (item.modelOrbitTheta !== null && item.modelOrbitTheta !== undefined &&
        item.modelOrbitPhi !== null && item.modelOrbitPhi !== undefined) {
      const modelViewer = element.querySelector('model-viewer');
      if (modelViewer) {
        modelViewer.setAttribute(
          'camera-orbit',
          String(item.modelOrbitTheta) + 'deg ' +
            String(item.modelOrbitPhi) + 'deg auto'
        );
      }
    }
    if (item.baseFontSize !== undefined) {
      element.style.setProperty('--base-font-size', item.baseFontSize);
    }
    if (item.glowIntensity !== undefined) {
      element.style.setProperty('--sutol-glow', item.glowIntensity);
    }
    if (item.textColor === null || item.textColor === undefined) {
      element.style.removeProperty('color');
      element.style.removeProperty('--sutol-text-color');
    } else {
      element.style.color = item.textColor;
      element.style.setProperty('--sutol-text-color', item.textColor);
    }
    if (item.text !== undefined) {
      if (item.isTypewriter) {
        const tokens = String(item.text).match(/\S+|\s+/g) || [];
        const wordCount = tokens.filter(function (token) {
          return token.trim().length > 0;
        }).length;
        const cycle = Math.max(4.8, (wordCount * 0.46) + 2.8);
        element.style.setProperty('--sutol-type-cycle', cycle.toFixed(2) + 's');
        element.replaceChildren();
        let wordIndex = 0;
        tokens.forEach(function (token) {
          if (token.trim().length === 0) {
            element.appendChild(document.createTextNode(token));
            return;
          }
          const word = document.createElement('span');
          word.className = 'sutol-typewriter-word';
          word.style.setProperty('--sutol-word-index', String(wordIndex));
          word.textContent = token;
          element.appendChild(word);
          wordIndex += 1;
        });
      } else {
        element.textContent = item.text;
      }
    }
    if (element.classList.contains('sutol-html-block')) fitText(element);
    return true;
  }

  window.addEventListener('message', function (event) {
    let data = event.data;
    if (typeof data === 'string') {
      try { data = JSON.parse(data); } catch (_) { return; }
    }
    if (!data || data.type !== 'sutol-stage-patch') return;

    for (const item of data.texts || []) {
      patchElement('data-sutol-text-id', item);
    }
    for (const item of data.components || []) {
      patchElement('data-sutol-component-id', item);
    }
    if (window.SutolStageComponents) {
      window.SutolStageComponents.refresh();
    }
    fitAllText();
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fitAllText, { once: true });
  } else {
    fitAllText();
  }
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(fitAllText);
  }
  if (window.ResizeObserver) {
    const stage = document.querySelector('.sutol-html-stage');
    if (stage) new ResizeObserver(fitAllText).observe(stage);
  }
  window.SutolStagePatcher = true;
})();
''';
