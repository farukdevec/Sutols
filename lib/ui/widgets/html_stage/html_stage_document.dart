import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show Offset;

import '../../../models/slide_model.dart';
import '../../../services/local_google_fonts_css.dart';
import '../../../services/model_asset_service.dart';
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

String get sutolHtmlStageStyles =>
    '$_stageStyles\n\n$sutolCombinedTemplatesCSS\n\n$_transparentComponentOverrides';

String sutolHtmlStageStylesForPages(Iterable<PresentationPage> pages) {
  final families = <String>{};
  for (final page in pages) {
    for (final block in page.textBlocks) {
      final styleClass = _textStyleClass(block.textStyle);
      final baseFamily = _fontFamilyFromRule('.sutol-html-block.$styleClass');
      final titleFamily = block.type == PresentationTextType.title
          ? _fontFamilyFromRule(
              '.sutol-html-block.$styleClass.is-title',
            )
          : null;
      final effectiveFamily = titleFamily ?? baseFamily;
      if (effectiveFamily != null) families.add(effectiveFamily);
    }
  }
  final filteredFonts = sutolLocalGoogleFontsCssForFamilies(families);
  final withoutGoogleImport = _stageStyles.replaceFirst(
    RegExp(r"@import url\('https://fonts\.googleapis\.com/[^']+'\);\s*"),
    '',
  );
  final filteredStageStyles = withoutGoogleImport.replaceFirst(
    sutolLocalGoogleFontsCss,
    filteredFonts,
  );
  return '$filteredStageStyles\n\n$sutolCombinedTemplatesCSS\n\n$_transparentComponentOverrides';
}

String? _fontFamilyFromRule(String selector) {
  final rule = RegExp(
    '${RegExp.escape(selector)}\\s*\\{([^}]*)\\}',
  ).firstMatch(_stageStyles);
  if (rule == null) return null;
  return RegExp(
    r'''font-family:\s*['"]?([^,'";]+)''',
  ).firstMatch(rule.group(1)!)?.group(1)?.trim();
}

String get sutolHtmlStageBackgroundScript => _backgroundScript;
String get sutolHtmlStageComponentScript => _stageComponentScript;
String get sutolHtmlStagePatchScript => _stagePatchScript;

/// Bileşen kütüphanesindeki küçük kartlar için hafif ve etkileşimsiz belge.
/// Tam sahne CSS'i ve arka plan iframe'i özellikle eklenmez.
String buildHtmlComponentPreviewDocument(PresentationComponentKind kind) {
  final component = _normalizeCatalogComponentScripts(
    presentationComponentHtml(kind),
  );
  return '''<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<style>
html,body{margin:0;width:100%;height:100%;overflow:hidden;background:transparent}
body{pointer-events:none;user-select:none}
.sutol-component-preview{position:relative;width:100%;height:100%;overflow:hidden;container-type:inline-size}
.sutol-component-preview>*{position:absolute!important;inset:0!important;width:100%!important;height:100%!important;max-width:none!important;max-height:none!important;margin:0!important}
*,*::before,*::after{animation:none!important;transition:none!important}
</style>
<script>
(function(){
  let frames=0;
  const nativeRaf=window.requestAnimationFrame.bind(window);
  window.requestAnimationFrame=function(callback){
    if(frames++>=4)return 0;
    return nativeRaf(callback);
  };
  window.setInterval=function(){return 0;};
})();
</script></head><body><div class="sutol-component-preview">$component</div></body></html>''';
}

const String _transparentComponentOverrides = '''
/* Template themes may style generic component placeholders as cards. Real
   catalog/media components must keep only their own artwork. */
.sutol-html-stage .sutol-html-component.has-html-component:not(.component-uploaded-image):not(.component-3d-model) {
  background: transparent !important;
  border: none !important;
  border-color: transparent !important;
  border-radius: 0 !important;
  box-shadow: none !important;
  backdrop-filter: none !important;
}
.sutol-html-stage .sutol-html-component.has-html-component:not(.component-uploaded-image):not(.component-3d-model)::before,
.sutol-html-stage .sutol-html-component.has-html-component:not(.component-uploaded-image):not(.component-3d-model)::after {
  display: none !important;
  content: none !important;
}
''';

String sutolHtmlBackgroundScene(PresentationBackgroundKind kind) =>
    presentationBackgroundSceneHtml(kind);

String buildHtmlBackgroundSceneDocument(
  PresentationBackgroundKind kind, {
  bool animationEnabled = true,
  double animationSpeed = 1,
  bool colorsInverted = false,
}) {
  var document = animationEnabled
      ? sutolHtmlBackgroundScene(kind)
      : buildHtmlBackgroundPreviewDocument(kind);
  if (colorsInverted) {
    final resultIsDark = presentationBackgroundVariantIsDark(
      kind,
      colorsInverted: true,
    );
    final variantStyle = '''
<style data-sutol-background-color-variant="inverted">
html { background: ${resultIsDark ? '#09111F' : '#F7F9FC'} !important; }
body { filter: invert(1) hue-rotate(180deg); }
</style>
''';
    document = document.contains('</head>')
        ? document.replaceFirst('</head>', '$variantStyle</head>')
        : '$variantStyle$document';
  }
  if (!animationEnabled) return document;
  final speed = animationSpeed.clamp(0.25, 2.0).toDouble();
  if ((speed - 1).abs() < 0.001) return document;
  final speedText = speed.toStringAsFixed(2);
  final speedScript = '''
<script data-sutol-background-animation-speed="$speedText">
(function () {
  const rate = $speedText;
  function applyPlaybackRate() {
    document.getAnimations().forEach(function (animation) {
      animation.playbackRate = rate;
    });
  }
  window.addEventListener('load', function () {
    applyPlaybackRate();
    requestAnimationFrame(applyPlaybackRate);
    window.setTimeout(applyPlaybackRate, 120);
  });
})();
</script>
''';
  document = document.contains('</body>')
      ? document.replaceFirst('</body>', '$speedScript</body>')
      : '$document$speedScript';
  return document;
}

String buildHtmlBackgroundPreviewDocument(PresentationBackgroundKind kind) {
  var document = sutolHtmlBackgroundScene(kind);
  const previewStyles = '''
<style data-sutol-background-preview>
html, body { width: 100% !important; height: 100% !important; margin: 0 !important; overflow: hidden !important; }
body { pointer-events: none !important; user-select: none !important; }
/* Preset grids can contain many iframes. Keep previews static from the first
   paint so opening the picker does not briefly animate every card at once. */
*, *::before, *::after {
  animation-play-state: paused !important;
  transition: none !important;
}
</style>
''';
  const freezeScript = '''
<script data-sutol-background-preview-freeze>
window.addEventListener('load', function () {
  window.setTimeout(function () {
    document.getAnimations().forEach(function (animation) { animation.pause(); });
    document.querySelectorAll('svg').forEach(function (svg) {
      if (typeof svg.pauseAnimations === 'function') svg.pauseAnimations();
    });
    window.requestAnimationFrame = function () { return 0; };
  }, 0);
});
</script>
''';

  document = document.contains('</head>')
      ? document.replaceFirst('</head>', '$previewStyles</head>')
      : '$previewStyles$document';
  return document.contains('</body>')
      ? document.replaceFirst('</body>', '$freezeScript</body>')
      : '$document$freezeScript';
}

String buildHtmlPageTransitionDocument({
  required PresentationPage from,
  required PresentationPage to,
  required PresentationTransitionKind kind,
  required int durationMs,
  Map<String, String> modelSourcesById = const <String, String>{},
  Map<String, String> imageSourcesById = const <String, String>{},
}) {
  final fromMarkup = buildHtmlStageMarkup(
    page: from,
    showBadge: false,
    renderMode: HtmlStageRenderMode.preview,
    modelSourcesById: modelSourcesById,
    imageSourcesById: imageSourcesById,
  );
  final toMarkup = buildHtmlStageMarkup(
    page: to,
    showBadge: false,
    renderMode: HtmlStageRenderMode.preview,
    modelSourcesById: modelSourcesById,
    imageSourcesById: imageSourcesById,
  );
  final names = _htmlTransitionAnimationNames(kind);
  final needsModelViewer = from.componentBlocks.any(
        (block) => block.modelAssetId != null,
      ) ||
      to.componentBlocks.any((block) => block.modelAssetId != null);
  return '''<!doctype html><html><head><meta charset="utf-8">${needsModelViewer ? sutolModelViewerScriptTag : ''}<style>
$sutolHtmlStageStyles
html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#000}
.sutol-transition-frame{position:absolute;inset:0;overflow:hidden;will-change:transform,opacity,clip-path;animation-duration:${durationMs}ms;animation-timing-function:cubic-bezier(.65,0,.35,1);animation-fill-mode:both;animation-play-state:paused}
body.sutol-transition-playing .sutol-transition-frame{animation-play-state:running}
.sutol-transition-frame>.sutol-html-stage{position:absolute!important;inset:0!important;width:100%!important;height:100%!important}
.sutol-transition-out{z-index:${kind == PresentationTransitionKind.uncover ? 2 : 1};animation-name:${names.$1}}
.sutol-transition-in{z-index:${kind == PresentationTransitionKind.uncover ? 1 : 2};animation-name:${names.$2}}
@keyframes sutolOutFade{from{opacity:1}to{opacity:0}}
@keyframes sutolInFade{from{opacity:0}to{opacity:1}}
@keyframes sutolOutPush{from{transform:translateX(0)}to{transform:translateX(-100%)}}
@keyframes sutolInPush{from{transform:translateX(100%)}to{transform:translateX(0)}}
@keyframes sutolStay{from{transform:none;opacity:1}to{transform:none;opacity:1}}
@keyframes sutolOutUncover{from{transform:translateX(0)}to{transform:translateX(-100%)}}
@keyframes sutolInWipe{from{clip-path:inset(0 100% 0 0)}to{clip-path:inset(0)}}
@keyframes sutolInSplit{from{clip-path:inset(0 50%)}to{clip-path:inset(0)}}
@keyframes sutolInReveal{from{transform:translateY(100%);box-shadow:0 -20px 40px #0008}to{transform:translateY(0);box-shadow:0 0 0 #0000}}
@keyframes sutolOutCube{from{transform:perspective(1400px) rotateY(0);opacity:1}to{transform:perspective(1400px) rotateY(-90deg);opacity:0}}
@keyframes sutolInCube{from{transform:perspective(1400px) rotateY(90deg);opacity:0}to{transform:perspective(1400px) rotateY(0);opacity:1}}
@keyframes sutolOutZoom{from{transform:scale(1);opacity:1}to{transform:scale(1.18);opacity:0}}
@keyframes sutolInZoom{from{transform:scale(.82);opacity:0}to{transform:scale(1);opacity:1}}
@keyframes sutolOutConvex{from{transform:scale(1);opacity:1}to{transform:scale(0.84);opacity:0}}
@keyframes sutolInConvex{from{transform:scale(1.18);opacity:0}to{transform:scale(1);opacity:1}}
@keyframes sutolOutConcave{from{transform:scale(1);opacity:1}to{transform:scale(1.18);opacity:0}}
@keyframes sutolInConcave{from{transform:scale(0.84);opacity:0}to{transform:scale(1);opacity:1}}
@keyframes sutolOutMorph{from{transform:scale(1);filter:blur(0px);opacity:1}to{transform:scale(1.08);filter:blur(12px);opacity:0}}
@keyframes sutolInMorph{from{transform:scale(0.92);filter:blur(12px);opacity:0}to{transform:scale(1);filter:blur(0px);opacity:1}}
@keyframes sutolOutParallax{from{transform:translateX(0);opacity:1}to{transform:translateX(-35%);opacity:0.35}}
@keyframes sutolInParallax{from{transform:translateX(100%);opacity:0}to{transform:translateX(0);opacity:1}}
@keyframes sutolOutElastic{from{transform:scale(1);opacity:1}to{transform:scale(0.88);opacity:0}}
@keyframes sutolInElastic{0%{transform:scale(0.78);opacity:0}70%{transform:scale(1.04);opacity:1}100%{transform:scale(1);opacity:1}}
@keyframes sutolOutGlitch{0%{transform:translate(0);opacity:1}30%{transform:translate(-8px,4px);filter:hue-rotate(90deg)}60%{transform:translate(8px,-4px);filter:hue-rotate(-90deg)}100%{transform:translate(0);opacity:0}}
@keyframes sutolInGlitch{0%{transform:translate(6px,-4px);opacity:0;filter:hue-rotate(180deg)}50%{transform:translate(-4px,2px);opacity:0.8;filter:hue-rotate(45deg)}100%{transform:translate(0);opacity:1;filter:none}}
@keyframes sutolInRadialWipe{from{clip-path:circle(0% at 50% 50%)}to{clip-path:circle(100% at 50% 50%)}}
@keyframes sutolOutRotateZoom{from{transform:scale(1) rotate(0deg);opacity:1}to{transform:scale(0.4) rotate(-14deg);opacity:0}}
@keyframes sutolInRotateZoom{from{transform:scale(1.4) rotate(14deg);opacity:0}to{transform:scale(1) rotate(0deg);opacity:1}}
</style></head><body>
<div class="sutol-transition-frame sutol-transition-out">$fromMarkup</div>
<div class="sutol-transition-frame sutol-transition-in">$toMarkup</div>
<script>$sutolHtmlStageBackgroundScript\n$sutolHtmlStageComponentScript</script>
<script>
function __sutolStartTransition(){
  requestAnimationFrame(function(){
    requestAnimationFrame(function(){
      document.body.classList.add('sutol-transition-playing');
    });
  });
}
if(document.readyState==='complete'||document.readyState==='interactive'){
  __sutolStartTransition();
}else{
  window.addEventListener('DOMContentLoaded',__sutolStartTransition);
  window.addEventListener('load',__sutolStartTransition);
}
</script>
</body></html>''';
}

(String, String) _htmlTransitionAnimationNames(
  PresentationTransitionKind kind,
) =>
    switch (kind) {
      PresentationTransitionKind.fade || PresentationTransitionKind.smooth => (
          'sutolOutFade',
          'sutolInFade'
        ),
      PresentationTransitionKind.slide => ('sutolOutPush', 'sutolInPush'),
      PresentationTransitionKind.cover => ('sutolStay', 'sutolInPush'),
      PresentationTransitionKind.uncover => ('sutolOutUncover', 'sutolStay'),
      PresentationTransitionKind.wipe => ('sutolStay', 'sutolInWipe'),
      PresentationTransitionKind.split => ('sutolStay', 'sutolInSplit'),
      PresentationTransitionKind.reveal => ('sutolStay', 'sutolInReveal'),
      PresentationTransitionKind.flip || PresentationTransitionKind.cube3d => (
          'sutolOutCube',
          'sutolInCube'
        ),
      PresentationTransitionKind.zoom => ('sutolOutZoom', 'sutolInZoom'),
      PresentationTransitionKind.convex => ('sutolOutConvex', 'sutolInConvex'),
      PresentationTransitionKind.concave => (
          'sutolOutConcave',
          'sutolInConcave'
        ),
      PresentationTransitionKind.morph => ('sutolOutMorph', 'sutolInMorph'),
      PresentationTransitionKind.parallax => (
          'sutolOutParallax',
          'sutolInParallax'
        ),
      PresentationTransitionKind.elastic => (
          'sutolOutElastic',
          'sutolInElastic'
        ),
      PresentationTransitionKind.glitch => ('sutolOutGlitch', 'sutolInGlitch'),
      PresentationTransitionKind.prism => ('sutolOutMorph', 'sutolInMorph'),
      PresentationTransitionKind.radialWipe => (
          'sutolStay',
          'sutolInRadialWipe'
        ),
      PresentationTransitionKind.rotateZoom => (
          'sutolOutRotateZoom',
          'sutolInRotateZoom'
        ),
      PresentationTransitionKind.none => ('sutolStay', 'sutolStay'),
    };

String buildHtmlStageDocument({
  required PresentationPage page,
  String? selectedTextBlockId,
  String? inlineEditingTextBlockId,
  String? selectedComponentBlockId,
  int? visibleRevealStep,
  bool showBadge = true,
  bool showBackground = true,
  HtmlStageRenderMode renderMode = HtmlStageRenderMode.full,
  Map<String, String> modelSourcesById = const <String, String>{},
  Map<String, String> imageSourcesById = const <String, String>{},
}) {
  final buffer = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="tr">')
    ..writeln('<head>')
    ..writeln('<meta charset="utf-8">')
    ..writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1">')
    ..writeln(
      renderMode != HtmlStageRenderMode.snapshot &&
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
        inlineEditingTextBlockId: inlineEditingTextBlockId,
        selectedComponentBlockId: selectedComponentBlockId,
        visibleRevealStep: visibleRevealStep,
        showBadge: showBadge,
        showBackground: showBackground,
        renderMode: renderMode,
        modelSourcesById: modelSourcesById,
        imageSourcesById: imageSourcesById,
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
  String? inlineEditingTextBlockId,
  String? selectedComponentBlockId,
  int? visibleRevealStep,
  bool showBadge = true,
  bool showBackground = true,
  String? extraStageClass,
  HtmlStageRenderMode renderMode = HtmlStageRenderMode.full,
  Map<String, String> modelSourcesById = const <String, String>{},
  Map<String, String> imageSourcesById = const <String, String>{},
  bool deferEmbeddedAssets = false,
}) {
  final animationTimeline = _buildEntranceAnimationTimeline(page);
  final renderModeName = _renderModeName(renderMode);
  final templateClass = (page.templateId != null && page.templateId!.isNotEmpty)
      ? 'sutol-template-${page.templateId}'
      : '';
  final templateAttr = (page.templateId != null && page.templateId!.isNotEmpty)
      ? ' data-sutol-template="${_escapeAttribute(page.templateId!)}"'
      : '';

  final stageClasses = <String>[
    'sutol-html-stage',
    if (templateClass.isNotEmpty) templateClass,
    _backgroundStageClass(page.backgroundKind),
    'sutol-stage-mode-$renderModeName',
    if (!showBackground) 'sutol-stage-without-background',
    if (_isDarkBackground(
      page.backgroundKind,
      colorsInverted: page.backgroundColorsInverted,
    ))
      'theme-dark',
    if (extraStageClass != null && extraStageClass.trim().isNotEmpty)
      extraStageClass.trim(),
  ].join(' ');

  final buffer = StringBuffer()
    ..writeln(
      '<div class="$stageClasses"$templateAttr data-sutol-render-mode="$renderModeName">',
    )
    ..writeln(
      showBackground
          ? _backgroundInnerMarkup(
              page.backgroundKind,
              renderMode,
              animationEnabled: page.backgroundAnimationEnabled,
              animationSpeed: page.backgroundAnimationSpeed,
              colorsInverted: page.backgroundColorsInverted,
              deferEmbeddedAssets: deferEmbeddedAssets,
            )
          : '',
    );

  if (page.textBlocks.isEmpty && page.componentBlocks.isEmpty) {
    buffer.writeln('<div class="sutol-html-empty">Metin ekleyin</div>');
  }

  for (final block in page.textBlocks) {
    final effectiveRevealStep =
        animationTimeline.revealSteps[block.id] ?? block.revealStep;
    final entranceEffect = _isEntranceEffect(block.entranceAnimation);
    final displayRevealStep =
        entranceEffect ? effectiveRevealStep : block.revealStep;
    if (!_isVisibleAtRevealStep(displayRevealStep, visibleRevealStep)) {
      continue;
    }
    final classes = <String>[
      'sutol-html-block',
      _typeClass(block.type),
      _textStyleClass(block.textStyle),
      _textAnimationClass(block.textAnimation),
      if (visibleRevealStep != null &&
          block.revealStep < visibleRevealStep &&
          block.textAnimation != PresentationTextAnimation.none)
        'is-text-animation-complete',
      _entranceAnimationClass(block.entranceAnimation),
      if (block.entranceAnimation != PresentationEntranceAnimation.none &&
          block.textGrouping != PresentationTextGrouping.asObject)
        'has-grouped-element-animation',
      if (!entranceEffect &&
          effectiveRevealStep > 0 &&
          ((visibleRevealStep != null &&
                  effectiveRevealStep > visibleRevealStep) ||
              (visibleRevealStep == null &&
                  renderMode == HtmlStageRenderMode.full)))
        'is-element-animation-pending',
      if (block.glowIntensity <= 0) 'is-glow-off',
      if (block.id == selectedTextBlockId) 'is-selected',
      if (block.id == inlineEditingTextBlockId) 'is-inline-editing',
    ].join(' ');
    final hotspotAttr = block.hotspotTargetPageId == null
        ? ''
        : ' data-hotspot-target="${_escapeAttribute(block.hotspotTargetPageId!)}"';
    final displayText = block.text.trim().isEmpty ? 'Metin kutusu' : block.text;
    final typewriterCycle = _typewriterCycleSeconds(displayText);
    final computedDelay =
        animationTimeline.delays[block.id] ?? block.animationDelay;
    final accessibilityAttr =
        block.textGrouping == PresentationTextGrouping.asObject
            ? ''
            : ' aria-label="${_escapeAttribute(displayText)}"';
    buffer.writeln(
      '<div class="$classes" data-sutol-text-id="${_escapeAttribute(block.id)}" data-reveal-step="$displayRevealStep" data-animation-step="$effectiveRevealStep"$accessibilityAttr$hotspotAttr style="left:${_pct(block.position.dx)}%;top:${_pct(block.position.dy)}%;width:${_pct(block.widthFactor)}%;${block.heightFactor == null ? '' : 'height:${_pct(block.heightFactor!)}%;'}--sutol-left:${_pct(block.position.dx)}%;--sutol-top:${_pct(block.position.dy)}%;--base-font-size:${(block.fontSize / 10).toStringAsFixed(2)}cqw;--sutol-glow:${block.glowIntensity.toStringAsFixed(2)};--sutol-type-cycle:${typewriterCycle.toStringAsFixed(2)}s;${_animationTimingStyle(block.animationDuration, computedDelay)}${_motionPathStyle(block.motionPathPoints)}${_textFormatStyles(block)}${block.textColorHex == null ? '' : 'color:${_escapeAttribute(block.textColorHex!)};--sutol-text-color:${_escapeAttribute(block.textColorHex!)};'}">${_textBlockMarkup(displayText, block.textAnimation, block.entranceAnimation, block.textGrouping, block.groupDelay, computedDelay)}</div>',
    );
  }

  for (final block in page.componentBlocks) {
    final effectiveRevealStep =
        animationTimeline.revealSteps[block.id] ?? block.revealStep;
    final entranceEffect = _isEntranceEffect(block.entranceAnimation);
    final displayRevealStep =
        entranceEffect ? effectiveRevealStep : block.revealStep;
    if (!_isVisibleAtRevealStep(displayRevealStep, visibleRevealStep)) {
      continue;
    }
    final legacyImageId = block.imageAssetId == null &&
            block.modelAssetId != null &&
            imageSourcesById[block.modelAssetId] != null
        ? block.modelAssetId
        : null;
    final imageId = block.imageAssetId ?? legacyImageId;
    final modelId = imageId == null ? block.modelAssetId : null;
    final is3D = modelId != null;
    final isImage = imageId != null;
    final remoteSource = is3D ? modelSourcesById[modelId] : null;
    final resolvableSource =
        (remoteSource != null && remoteSource.isNotEmpty) ? remoteSource : null;
    final has3D = resolvableSource != null;

    if (is3D) {
      final sourceHasToken = resolvableSource != null &&
          ModelAssetService.isSignedUrlValid(resolvableSource);
      final assetKey =
          ModelAssetService.extractKey(resolvableSource ?? modelId);
      final uri =
          resolvableSource != null ? Uri.tryParse(resolvableSource) : null;
      final host = uri?.host ?? '';
      final expires = uri?.queryParameters['expires'] ?? '';
      print(
          '[MODEL_DEBUG] modelId=$modelId assetKey=$assetKey authSuccess=${resolvableSource != null} signed=$sourceHasToken signedUrlExists=${resolvableSource != null} signedUrlHost=$host signedUrlExpiration=$expires rendererSrcHost=$host rendererSrcIsSigned=$sourceHasToken');
      print('[MODEL_RENDER] id=$modelId signed=$sourceHasToken');
    }

    final componentHtml = _normalizeCatalogComponentScripts(
      presentationComponentHtml(block.kind),
    );
    final hasHtmlComponent =
        has3D || isImage || componentHtml.trim().isNotEmpty;
    final classes = <String>[
      'sutol-html-component',
      _entranceAnimationClass(block.entranceAnimation),
      if (!entranceEffect &&
          effectiveRevealStep > 0 &&
          ((visibleRevealStep != null &&
                  effectiveRevealStep > visibleRevealStep) ||
              (visibleRevealStep == null &&
                  renderMode == HtmlStageRenderMode.full)))
        'is-element-animation-pending',
      if (isImage) 'component-uploaded-image',
      if (!is3D && !isImage) 'component-${_componentDomKindName(block.kind)}',
      if (is3D) 'component-3d-model',
      if (hasHtmlComponent) 'has-html-component',
      if (block.id == selectedComponentBlockId) 'is-selected',
    ].join(' ');
    final hotspotAttr = block.hotspotTargetPageId == null
        ? ''
        : ' data-hotspot-target="${_escapeAttribute(block.hotspotTargetPageId!)}"';
    final isSnapshot = renderMode == HtmlStageRenderMode.snapshot;
    final componentInner = isImage
        ? _uploadedImageMarkup(imageId, imageSourcesById[imageId] ?? '')
        : has3D && !isSnapshot
            ? _model3DMarkup(
                modelId ?? '',
                resolvableSource,
                id: modelId ?? '',
                hasAnimations: findPresentation3DModelAsset(modelId ?? '')
                        ?.hasAnimations ??
                    true,
                animationEnabled: block.modelAnimationEnabled,
                autoRotate: block.modelAutoRotate,
                rotationSpeed: block.modelRotationSpeed,
                orbitEnabled: block.modelOrbitEnabled,
                orbitTheta: block.modelOrbitTheta,
                orbitPhi: block.modelOrbitPhi,
                deferSource: deferEmbeddedAssets,
                fallbackHtml: block.kind == PresentationComponentKind.edebiyat01
                    ? ''
                    : componentHtml,
              )
            : has3D && componentHtml.trim().isNotEmpty
                ? '<div class="sutol-html-component-inner">$componentHtml</div>'
                : componentHtml.trim().isEmpty
                    ? '<span class="sutol-component-shape"></span>'
                    : '<div class="sutol-html-component-inner">$componentHtml</div>';
    final label = imageId ?? modelId ?? '';
    final modelAttr = !is3D
        ? ''
        : ' data-sutol-model-id="${_escapeAttribute(modelId)}" data-sutol-orbit-theta="${block.modelOrbitTheta.toStringAsFixed(2)}" data-sutol-orbit-phi="${block.modelOrbitPhi.toStringAsFixed(2)}"';
    buffer.writeln(
      '<div class="$classes" data-sutol-component-id="${_escapeAttribute(block.id)}"$modelAttr data-reveal-step="$displayRevealStep" data-animation-step="$effectiveRevealStep" aria-label="${_escapeAttribute(label)}"$hotspotAttr style="left:${_pct(block.position.dx)}%;top:${_pct(block.position.dy)}%;width:${_pct(block.size.width)}%;height:${_pct(block.size.height)}%;${_animationTimingStyle(block.animationDuration, animationTimeline.delays[block.id] ?? block.animationDelay)}${_motionPathStyle(block.motionPathPoints)}">$componentInner</div>',
    );
  }

  buffer.writeln('</div>');
  return buffer.toString();
}

/// Catalog components are embedded as siblings inside a stage-owned wrapper.
/// Some imported snippets assume their script is inside the artwork element,
/// or immediately follows it. In practice a `<style>` element commonly sits
/// between the artwork and script, making those lookups return null and leaving
/// canvas/SVG components blank. Keep snippets self-contained while resolving
/// their artwork from the stage-owned wrapper.
String _normalizeCatalogComponentScripts(String html) {
  if (!html.contains('<script')) return html;

  var normalized = html.replaceAll(
    'document.currentScript.previousElementSibling',
    "document.currentScript.parentElement.querySelector(':scope > :not(style):not(script)')",
  );
  normalized = normalized.replaceAllMapped(
    RegExp(r'''document\.currentScript\.closest\((['"])([^'"]+)\1\)'''),
    (match) =>
        'document.currentScript.parentElement.querySelector(${match.group(1)}${match.group(2)}${match.group(1)})',
  );
  normalized = normalized.replaceAllMapped(
    RegExp(r'''\bscript\.closest\((['"])([^'"]+)\1\)'''),
    (match) =>
        'script.parentElement.querySelector(${match.group(1)}${match.group(2)}${match.group(1)})',
  );
  // Global selectors make duplicate copies of a component control only the
  // first matching node. Scope them to the current component instance.
  normalized = normalized.replaceAll(
    'document.getElementById(',
    'document.currentScript.parentElement.querySelector(\'#\' + ',
  );
  normalized = normalized.replaceAll(
    'document.querySelectorAll(',
    'document.currentScript.parentElement.querySelectorAll(',
  );
  normalized = normalized.replaceAll(
    'document.querySelector(',
    'document.currentScript.parentElement.querySelector(',
  );
  return normalized;
}

String _model3DMarkup(
  String label,
  String? source, {
  required String id,
  required bool hasAnimations,
  required bool animationEnabled,
  required bool autoRotate,
  required double rotationSpeed,
  required bool orbitEnabled,
  required double orbitTheta,
  required double orbitPhi,
  required String fallbackHtml,
  bool deferSource = false,
}) {
  final animationMarkup = hasAnimations && animationEnabled ? ' autoplay' : '';
  // auto-rotate-delay="0": model-viewer'ın varsayılan 3000 ms başlangıç
  // gecikmesini kaldırır; sunum modunda dönme anında başlar.
  final autoRotateMarkup = autoRotate
      ? ' auto-rotate auto-rotate-delay="0"'
          ' rotation-per-second="${rotationSpeed.toStringAsFixed(1)}deg"'
      : '';
  final cameraControlsMarkup = orbitEnabled ? ' camera-controls' : '';
  final cameraOrbit =
      '${orbitTheta.toStringAsFixed(2)}deg ${orbitPhi.toStringAsFixed(2)}deg auto';
  final sourceMarkup = deferSource
      ? 'data-sutol-model-source-id="${_escapeAttribute(id)}"'
      : source != null && source.isNotEmpty
          ? 'src="${_escapeAttribute(source)}"'
          : '';

  final fallbackMarkup = fallbackHtml.trim().isEmpty
      ? '''<div class="sutol-3d-fallback-card">
      <span class="sutol-3d-fallback-icon">🧊</span>
      <span class="sutol-3d-fallback-title">3B Model Yüklenemedi</span>
      <span class="sutol-3d-fallback-sub">Model kaynağına ulaşılamadı.</span>
    </div>'''
      : '<div class="sutol-html-component-inner">$fallbackHtml</div>';
  return '''
<div class="sutol-html-component-inner sutol-3d-model-inner">
  <model-viewer class="sutol-3d-model-viewer" crossorigin="anonymous" data-sutol-model-id="${_escapeAttribute(id)}" $sourceMarkup alt="${_escapeAttribute(label)}"$cameraControlsMarkup$animationMarkup$autoRotateMarkup camera-orbit="$cameraOrbit" interaction-prompt="none" shadow-intensity="1" shadow-softness="0.8" exposure="1" loading="eager" reveal="auto" onload="this.hidden=false;const status=this.nextElementSibling;if(status)status.hidden=true;const fallback=status?status.nextElementSibling:null;if(fallback)fallback.hidden=true;console.log('Sutols 3B model yüklendi',{modelId:this.dataset.sutolModelId})" onerror="const status=this.nextElementSibling;if(status)status.hidden=true;const fallback=status?status.nextElementSibling:null;if(fallback)fallback.hidden=false;this.hidden=true;console.error('Sutols 3B model yüklenemedi',{modelId:this.dataset.sutolModelId})"></model-viewer>
  <span class="sutol-3d-model-status">3B model yükleniyor…</span>
  <div class="sutol-3d-model-fallback" hidden>$fallbackMarkup</div>
</div>
''';
}

String _uploadedImageMarkup(String sourceId, String dataUrl) {
  return '''
<div class="sutol-html-component-inner sutol-uploaded-image-inner">
  <img class="sutol-uploaded-image-element" data-sutol-image-id="${_escapeAttribute(sourceId)}" src="${_escapeAttribute(dataUrl)}" alt="Yuklenen gorsel" draggable="false">
</div>
''';
}

String _escape(String value) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(value);

String _textFormatStyles(PresentationTextBlock block) {
  final buffer = StringBuffer();
  if (block.textBold) {
    buffer.write('font-weight:700;');
  }
  if (block.textItalic) {
    buffer.write('font-style:italic;');
  }
  if (block.textUnderline) {
    buffer.write('text-decoration:underline;');
  }
  switch (block.textAlign) {
    case PresentationTextAlign.left:
      break;
    case PresentationTextAlign.center:
      buffer.write('text-align:center;');
    case PresentationTextAlign.right:
      buffer.write('text-align:right;');
  }
  return buffer.toString();
}

String _escapeAttribute(String value) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(value);

String _textBlockMarkup(
  String text,
  PresentationTextAnimation animation,
  PresentationEntranceAnimation entranceAnimation,
  PresentationTextGrouping grouping,
  double groupDelay,
  double baseDelay,
) {
  if (entranceAnimation != PresentationEntranceAnimation.none &&
      grouping != PresentationTextGrouping.asObject) {
    final buffer = StringBuffer(
      '<span class="sutol-animation-visual" aria-hidden="true">',
    );
    var segmentIndex = 0;
    void segment(String value, {bool paragraph = false}) {
      final delay = baseDelay + segmentIndex * groupDelay;
      buffer.write(
        '<span class="sutol-animation-segment ${_entranceAnimationClass(entranceAnimation)}${paragraph ? ' is-paragraph-segment' : ''}" aria-hidden="true" style="--sutol-element-delay:${delay.toStringAsFixed(2)}s">${_escape(value)}</span>',
      );
      segmentIndex += 1;
    }

    if (grouping == PresentationTextGrouping.byParagraph) {
      final paragraphs = text.split('\n');
      for (var index = 0; index < paragraphs.length; index += 1) {
        if (paragraphs[index].isNotEmpty)
          segment(paragraphs[index], paragraph: true);
        if (index < paragraphs.length - 1)
          buffer.write('<br aria-hidden="true">');
      }
    } else if (grouping == PresentationTextGrouping.byWord) {
      for (final match in RegExp(r'\S+|\s+').allMatches(text)) {
        final token = match.group(0)!;
        token.trim().isEmpty ? buffer.write(_escape(token)) : segment(token);
      }
    } else {
      for (final rune in text.runes) {
        segment(String.fromCharCode(rune));
      }
    }
    buffer.write('</span>');
    return buffer.toString();
  }
  if (animation != PresentationTextAnimation.daktilo &&
      animation != PresentationTextAnimation.kelimeKelimeBelirme) {
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

String _animationTimingStyle(double duration, double delay) {
  return '--sutol-element-duration:${duration.clamp(.1, 5).toStringAsFixed(2)}s;'
      '--sutol-element-delay:${delay.clamp(0, 30).toStringAsFixed(2)}s;';
}

String _motionPathStyle(List<Offset> points) {
  final safe = points.length == 4
      ? points
      : const <Offset>[
          Offset.zero,
          Offset(.12, -.08),
          Offset(.24, .08),
          Offset(.36, 0)
        ];
  return List<String>.generate(safe.length, (index) {
    final point = safe[index];
    return '--sutol-motion-x$index:${_pct(point.dx)}cqw;'
        '--sutol-motion-y$index:${_pct(point.dy)}cqh;';
  }).join();
}

class _EntranceAnimationTimeline {
  const _EntranceAnimationTimeline(this.revealSteps, this.delays);

  final Map<String, int> revealSteps;
  final Map<String, double> delays;
}

class _EntranceAnimationItem {
  const _EntranceAnimationItem({
    required this.id,
    required this.revealStep,
    required this.animation,
    required this.trigger,
    required this.duration,
    required this.delay,
    required this.order,
    required this.fallbackOrder,
  });

  final String id;
  final int revealStep;
  final PresentationEntranceAnimation animation;
  final PresentationAnimationTrigger trigger;
  final double duration;
  final double delay;
  final int order;
  final int fallbackOrder;
}

_EntranceAnimationTimeline _buildEntranceAnimationTimeline(
  PresentationPage page,
) {
  var manualMaxStep = 0;
  for (final block in page.textBlocks) {
    manualMaxStep = math.max(manualMaxStep, block.revealStep);
  }
  for (final block in page.componentBlocks) {
    manualMaxStep = math.max(manualMaxStep, block.revealStep);
  }

  final revealSteps = <String, int>{};
  final delays = <String, double>{};
  var clickGroup = 0;
  var previousStart = 0.0;
  var previousEnd = 0.0;

  void add(
    String id,
    int revealStep,
    PresentationEntranceAnimation animation,
    PresentationAnimationTrigger trigger,
    double duration,
    double delay,
  ) {
    if (animation == PresentationEntranceAnimation.none) return;
    if (trigger == PresentationAnimationTrigger.onClick) {
      clickGroup += 1;
      previousStart = delay;
    } else if (trigger == PresentationAnimationTrigger.afterPrevious) {
      previousStart = previousEnd + delay;
    } else {
      previousStart += delay;
    }
    previousEnd = previousStart + duration;
    revealSteps[id] = clickGroup == 0
        ? revealStep
        : math.max(revealStep, manualMaxStep + clickGroup);
    delays[id] = previousStart;
  }

  var fallbackOrder = 0;
  final items = <_EntranceAnimationItem>[
    for (final block in page.textBlocks)
      _EntranceAnimationItem(
        id: block.id,
        revealStep: block.revealStep,
        animation: block.entranceAnimation,
        trigger: block.animationTrigger,
        duration: block.animationDuration,
        delay: block.animationDelay,
        order: block.animationOrder,
        fallbackOrder: fallbackOrder++,
      ),
    for (final block in page.componentBlocks)
      _EntranceAnimationItem(
        id: block.id,
        revealStep: block.revealStep,
        animation: block.entranceAnimation,
        trigger: block.animationTrigger,
        duration: block.animationDuration,
        delay: block.animationDelay,
        order: block.animationOrder,
        fallbackOrder: fallbackOrder++,
      ),
  ]..sort((a, b) {
      final aOrder = a.order > 0 ? a.order : 100000 + a.fallbackOrder;
      final bOrder = b.order > 0 ? b.order : 100000 + b.fallbackOrder;
      return aOrder.compareTo(bOrder);
    });
  for (final item in items) {
    add(
      item.id,
      item.revealStep,
      item.animation,
      item.trigger,
      item.duration,
      item.delay,
    );
  }
  return _EntranceAnimationTimeline(revealSteps, delays);
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

String _textAnimationClass(PresentationTextAnimation animation) {
  return 'text-animation-${_enumValueName(animation)}';
}

String _entranceAnimationClass(PresentationEntranceAnimation animation) {
  return 'entrance-animation-${_enumValueName(animation)}';
}

bool _isEntranceEffect(PresentationEntranceAnimation animation) {
  return <PresentationEntranceAnimation>{
    PresentationEntranceAnimation.none,
    PresentationEntranceAnimation.fadeIn,
    PresentationEntranceAnimation.flyInLeft,
    PresentationEntranceAnimation.flyInRight,
    PresentationEntranceAnimation.flyInTop,
    PresentationEntranceAnimation.flyInBottom,
    PresentationEntranceAnimation.zoomIn,
  }.contains(animation);
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

bool _isDarkBackground(
  PresentationBackgroundKind kind, {
  bool colorsInverted = false,
}) {
  return presentationBackgroundVariantIsDark(
    kind,
    colorsInverted: colorsInverted,
  );
}

String _backgroundStageClass(PresentationBackgroundKind kind) {
  return 'bg-${_enumValueName(kind)}';
}

String _backgroundInnerMarkup(
  PresentationBackgroundKind kind,
  HtmlStageRenderMode renderMode, {
  required bool animationEnabled,
  required double animationSpeed,
  required bool colorsInverted,
  bool deferEmbeddedAssets = false,
}) {
  if (deferEmbeddedAssets) {
    return '''
<div class="sutol-stage-bg sutol-bg-imported" aria-hidden="true">
  <iframe class="sutol-bg-scene-frame" data-sutol-background-kind="${kind.name}" tabindex="-1"></iframe>
</div>
''';
  }
  final scene = renderMode == HtmlStageRenderMode.snapshot || !animationEnabled
      ? _escapedSnapshotBackgroundScenes.putIfAbsent(
          '${kind.name}:$colorsInverted',
          () => _escapeAttribute(
            buildHtmlBackgroundSceneDocument(
              kind,
              animationEnabled: false,
              colorsInverted: colorsInverted,
            ),
          ),
        )
      : _escapedBackgroundScenes.putIfAbsent(
          '${kind.name}:${animationSpeed.toStringAsFixed(3)}:$colorsInverted',
          () => _escapeAttribute(
            buildHtmlBackgroundSceneDocument(
              kind,
              animationSpeed: animationSpeed,
              colorsInverted: colorsInverted,
            ),
          ),
        );
  return '''
<div class="sutol-stage-bg sutol-bg-imported" aria-hidden="true">
  <iframe class="sutol-bg-scene-frame" srcdoc="$scene" tabindex="-1"></iframe>
</div>
''';
}

final Map<String, String> _escapedBackgroundScenes = <String, String>{};
final Map<String, String> _escapedSnapshotBackgroundScenes = <String, String>{};

const String _stageStyles = '''
$sutolLocalGoogleFontsCss

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

.sutol-html-stage.sutol-stage-without-background {
  border: 0;
  background: transparent;
}

.sutol-html-stage.sutol-stage-without-background::before,
.sutol-html-stage.sutol-stage-without-background::after {
  content: none;
}

.sutol-html-stage.bg-plain-white {
  border-color: transparent;
  background: #FFFFFF;
}

.sutol-html-stage.bg-plain-white::before,
.sutol-html-stage.bg-plain-white::after {
  content: none;
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
  font-size: clamp(12px, var(--base-font-size), 320px);
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

/* Classic metric-compatible typography additions.
   Source: Google Fonts. License: Apache 2.0 / OFL 1.1. */
.sutol-html-block.text-style-klasik-tinos {
  font-family: 'Tinos', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-tinos.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-arimo {
  font-family: 'Arimo', sans-serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-arimo.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-cousine {
  font-family: 'Cousine', monospace;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-cousine.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-carlito {
  font-family: 'Carlito', sans-serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-carlito.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-caladea {
  font-family: 'Caladea', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-caladea.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-eb-garamond {
  font-family: 'EB Garamond', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-eb-garamond.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-libre-baskerville {
  font-family: 'Libre Baskerville', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-libre-baskerville.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-alegreya {
  font-family: 'Alegreya', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-alegreya.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-pt-serif {
  font-family: 'PT Serif', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-pt-serif.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-merriweather {
  font-family: 'Merriweather', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-merriweather.is-title {
  font-weight: 900;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-lora {
  font-family: 'Lora', serif;
  font-weight: 400;
  letter-spacing: 0.005em;
}

.sutol-html-block.text-style-klasik-lora.is-title {
  font-weight: 700;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-great-vibes {
  font-family: 'Great Vibes', cursive;
  font-weight: 400;
  letter-spacing: 0.015em;
}

.sutol-html-block.text-style-klasik-great-vibes.is-title {
  letter-spacing: 0.025em;
}

.sutol-html-block.text-style-klasik-dancing-script {
  font-family: 'Dancing Script', cursive;
  font-weight: 400;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-dancing-script.is-title {
  font-weight: 700;
  letter-spacing: 0.02em;
}

.sutol-html-block.text-style-klasik-pacifico {
  font-family: 'Pacifico', cursive;
  font-weight: 400;
  letter-spacing: 0.01em;
}

.sutol-html-block.text-style-klasik-lobster {
  font-family: 'Lobster', cursive;
  font-weight: 400;
  letter-spacing: 0.01em;
}

/* Google Fonts resmi katalog popülerliğine göre seçilen açık kaynak aileler. */
.sutol-html-block.text-style-google-roboto { font-family: 'Roboto', sans-serif; }
.sutol-html-block.text-style-google-open-sans { font-family: 'Open Sans', sans-serif; }
.sutol-html-block.text-style-google-inter { font-family: 'Inter', sans-serif; }
.sutol-html-block.text-style-google-montserrat { font-family: 'Montserrat', sans-serif; }
.sutol-html-block.text-style-google-poppins { font-family: 'Poppins', sans-serif; }
.sutol-html-block.text-style-google-noto-sans-jp { font-family: 'Noto Sans JP', sans-serif; }
.sutol-html-block.text-style-google-lato { font-family: 'Lato', sans-serif; }
.sutol-html-block.text-style-google-arimo { font-family: 'Arimo', sans-serif; }
.sutol-html-block.text-style-google-roboto-condensed { font-family: 'Roboto Condensed', sans-serif; }
.sutol-html-block.text-style-google-roboto-mono { font-family: 'Roboto Mono', monospace; }
.sutol-html-block.text-style-google-noto-sans { font-family: 'Noto Sans', sans-serif; }
.sutol-html-block.text-style-google-oswald { font-family: 'Oswald', sans-serif; }
.sutol-html-block.text-style-google-dm-sans { font-family: 'DM Sans', sans-serif; }
.sutol-html-block.text-style-google-nunito { font-family: 'Nunito', sans-serif; }
.sutol-html-block.text-style-google-raleway { font-family: 'Raleway', sans-serif; }
.sutol-html-block.text-style-google-nunito-sans { font-family: 'Nunito Sans', sans-serif; }
.sutol-html-block.text-style-google-playfair-display { font-family: 'Playfair Display', serif; }
.sutol-html-block.text-style-google-roboto-slab { font-family: 'Roboto Slab', serif; }
.sutol-html-block.text-style-google-rubik { font-family: 'Rubik', sans-serif; }
.sutol-html-block.text-style-google-archivo-black { font-family: 'Archivo Black', sans-serif; }
.sutol-html-block.text-style-google-ubuntu { font-family: 'Ubuntu', sans-serif; }
.sutol-html-block.text-style-google-noto-sans-kr { font-family: 'Noto Sans KR', sans-serif; }
.sutol-html-block.text-style-google-kanit { font-family: 'Kanit', sans-serif; }
.sutol-html-block.text-style-google-manrope { font-family: 'Manrope', sans-serif; }
.sutol-html-block.text-style-google-outfit { font-family: 'Outfit', sans-serif; }
.sutol-html-block.text-style-google-merriweather { font-family: 'Merriweather', serif; }
.sutol-html-block.text-style-google-work-sans { font-family: 'Work Sans', sans-serif; }
.sutol-html-block.text-style-google-lora { font-family: 'Lora', serif; }
.sutol-html-block.text-style-google-noto-sans-tc { font-family: 'Noto Sans TC', sans-serif; }
.sutol-html-block.text-style-google-prompt { font-family: 'Prompt', sans-serif; }

.sutol-html-block[class*="text-style-google-"] { font-weight: 400; letter-spacing: normal; }
.sutol-html-block[class*="text-style-google-"].is-title { font-weight: 700; }

/* Font presets above define typography only. Color, glow and motion are
   applied independently by the optional text effect controls below. */
.sutol-html-stage .sutol-html-block[class*="text-style-"] {
  color: #142033;
  text-shadow: none;
}

.sutol-html-stage.theme-dark .sutol-html-block[class*="text-style-"] {
  color: #f8fbff;
}

.sutol-html-block.text-animation-none {
  animation: none !important;
  filter: none;
  background: none;
  -webkit-text-fill-color: currentColor;
}

.sutol-html-block[class*="text-animation-"] {
  --sutol-glow: 1;
  transform-origin: center;
  will-change: transform, opacity, filter, text-shadow, background-position;
}

.sutol-html-block.text-animation-bilim-dramatik { animation: sutolEffectDeepGlow 3.2s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-bilim-temiz { animation: sutolEffectSoftPulse 4s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-bilim-deneysel { animation: sutolEffectGlitch 2.6s steps(12) 1 forwards !important; }
.sutol-html-block.text-animation-gunes-dramatik { animation: sutolEffectSolarFlare 2.8s cubic-bezier(.22, 1, .36, 1) 1 forwards !important; }
.sutol-html-block.text-animation-gunes-temiz { animation: sutolEffectSolarBreath 2.2s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-gunes-deneysel { animation: sutolEffectFlicker 1.35s steps(6) 1 forwards !important; }
.sutol-html-block.text-animation-uzay-dramatik { animation: sutolEffectCosmicBloom 3.6s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-uzay-temiz { animation: sutolEffectOrbitPulse 2.8s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-uzay-deneysel { animation: sutolEffectDrift 4.2s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-optik-dramatik { animation: sutolEffectMirrorFlash 2.8s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-optik-temiz { animation: sutolEffectShimmer 3.2s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-optik-deneysel {
  background: linear-gradient(90deg, var(--sutol-text-color, #60a5fa), #ffffff, var(--sutol-text-color, #60a5fa)) !important;
  background-size: 300% 100% !important;
  -webkit-background-clip: text !important;
  background-clip: text !important;
  color: transparent !important;
  -webkit-text-fill-color: transparent !important;
  animation: sutolEffectPrism 5s linear 1 forwards !important;
}
.sutol-html-block.text-animation-fizik-dramatik { animation: sutolEffectElectricFlicker 2.2s linear 1 forwards !important; }
.sutol-html-block.text-animation-fizik-temiz { animation: sutolEffectEnergyWave 2.8s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-fizik-deneysel { animation: sutolEffectScalePulse 2.6s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-teknoloji-dramatik { animation: sutolEffectMatrixGlow 2.8s ease-in-out 1 forwards !important; }
.sutol-html-block.text-animation-teknoloji-temiz { animation: sutolEffectCircuitScan 2s steps(10) 1 forwards !important; }
.sutol-html-block.text-animation-teknoloji-deneysel { animation: sutolEffectDataGlitch 1.25s steps(8) 1 forwards !important; }
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
  animation: sutolEffectMetallicShine 3.2s cubic-bezier(.4, 0, .2, 1) 1 forwards !important;
}
.sutol-html-block.text-animation-yavas-belirme {
  animation: sutolEffectSlowReveal 5.4s cubic-bezier(.22, 1, .36, 1) 1 forwards !important;
}
.sutol-html-block.text-animation-daktilo {
  animation: none !important;
}
.sutol-html-block.text-animation-daktilo .sutol-typewriter-word {
  display: inline-block;
  opacity: 0;
  clip-path: inset(0 100% 0 0);
  border-right: 0.07em solid transparent;
  animation: sutolEffectTypewriterWord var(--sutol-type-cycle) ease-in-out 1 both;
  animation-delay: calc(var(--sutol-word-index) * 0.46s);
}
.sutol-html-block.text-animation-bulaniktan-net {
  animation: sutolEffectBlurFocus 4.8s cubic-bezier(.22, 1, .36, 1) 1 forwards !important;
}
.sutol-html-block.text-animation-asagidan-yukselme {
  animation: sutolEffectRiseIn 1.15s cubic-bezier(.22, 1, .36, 1) 1 both !important;
}
.sutol-html-block.text-animation-soldan-kayma {
  animation: sutolEffectSlideFromLeft 1.1s cubic-bezier(.22, 1, .36, 1) 1 both !important;
}
.sutol-html-block.text-animation-kelime-kelime-belirme {
  animation: none !important;
}
.sutol-html-block.text-animation-kelime-kelime-belirme .sutol-typewriter-word {
  display: inline-block;
  opacity: 0;
  animation: sutolEffectWordReveal .55s cubic-bezier(.22, 1, .36, 1) 1 both;
  animation-delay: calc(var(--sutol-word-index) * .16s);
}
.sutol-html-block.text-animation-uc-boyutlu-donus {
  transform-origin: center top;
  animation: sutolEffectFlip3d 4.6s cubic-bezier(.22, 1, .36, 1) 1 forwards !important;
}
.sutol-html-block.text-animation-ziplayarak-giris {
  animation: sutolEffectBounceIn 4.4s cubic-bezier(.2, .9, .3, 1.2) 1 forwards !important;
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
  animation: sutolEffectSpotlightSweep 2.8s linear 1 forwards !important;
}
.sutol-html-block.text-animation-perde-acilisi {
  animation: sutolEffectCurtainReveal 4.8s cubic-bezier(.22, 1, .36, 1) 1 forwards !important;
}
.sutol-html-block.text-animation-sinematik-yaklasma {
  animation: sutolEffectCinematicZoom 5.2s cubic-bezier(.16, 1, .3, 1) 1 forwards !important;
}
.sutol-html-block.text-animation-yercekimsiz-suzulme {
  animation: sutolEffectZeroGravity 5.6s ease-in-out 1 forwards !important;
}
.sutol-html-block.text-animation-neon-kontur {
  color: transparent !important;
  -webkit-text-fill-color: transparent !important;
  -webkit-text-stroke: 1.5px var(--sutol-text-color, #f8fbff);
  animation: sutolEffectNeonOutline 2.6s steps(8) 1 forwards !important;
}
.sutol-html-block.text-animation-golge-ekstruzyonu {
  animation: sutolEffectLongShadow 3.8s ease-in-out 1 forwards !important;
}
.sutol-html-block.text-animation-sivi-dalga {
  animation: sutolEffectLiquidWave 3.6s cubic-bezier(.45, .05, .55, .95) 1 forwards !important;
}
.sutol-html-block.text-animation-kesik-sinyal {
  animation: sutolEffectSignalCut 2.2s steps(12) 1 forwards !important;
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
  animation: sutolEffectHolographicWave 4s ease-in-out 1 forwards !important;
}

.sutol-html-stage .entrance-animation-fade-in {
  animation: sutolEntranceFadeIn .8s ease-out 1 both !important;
}
.sutol-html-stage .entrance-animation-fly-in-left {
  animation: sutolEntranceFlyInLeft .8s cubic-bezier(.22, 1, .36, 1) 1 both !important;
}
.sutol-html-stage .entrance-animation-fly-in-right {
  animation: sutolEntranceFlyInRight .8s cubic-bezier(.22, 1, .36, 1) 1 both !important;
}
.sutol-html-stage .entrance-animation-fly-in-top {
  animation: sutolEntranceFlyInTop .8s cubic-bezier(.22, 1, .36, 1) 1 both !important;
}
.sutol-html-stage .entrance-animation-fly-in-bottom {
  animation: sutolEntranceFlyInBottom .8s cubic-bezier(.22, 1, .36, 1) 1 both !important;
}
.sutol-html-stage .entrance-animation-zoom-in {
  animation: sutolEntranceZoomIn .8s cubic-bezier(.22, 1, .36, 1) 1 both !important;
}

.sutol-html-stage .entrance-animation-pulse {
  animation: sutolEmphasisPulse .8s ease-in-out 1 both !important;
}
.sutol-html-stage .entrance-animation-shake {
  animation: sutolEmphasisShake .7s ease-in-out 1 both !important;
}
.sutol-html-stage .entrance-animation-grow-shrink {
  animation: sutolEmphasisGrowShrink .9s ease-in-out 1 both !important;
}
.sutol-html-stage .entrance-animation-spin {
  animation: sutolEmphasisSpin .9s ease-in-out 1 both !important;
}
.sutol-html-stage .entrance-animation-glow {
  animation: sutolEmphasisGlow 1s ease-in-out 1 both !important;
}
.sutol-html-stage .entrance-animation-fade-out {
  animation: sutolExitFadeOut .8s ease-in 1 none !important;
}
.sutol-html-stage .entrance-animation-fly-out-left {
  animation: sutolExitFlyOutLeft .8s cubic-bezier(.55, 0, 1, .45) 1 none !important;
}
.sutol-html-stage .entrance-animation-fly-out-right {
  animation: sutolExitFlyOutRight .8s cubic-bezier(.55, 0, 1, .45) 1 none !important;
}
.sutol-html-stage .entrance-animation-fly-out-top {
  animation: sutolExitFlyOutTop .8s cubic-bezier(.55, 0, 1, .45) 1 none !important;
}
.sutol-html-stage .entrance-animation-fly-out-bottom {
  animation: sutolExitFlyOutBottom .8s cubic-bezier(.55, 0, 1, .45) 1 none !important;
}
.sutol-html-stage .entrance-animation-shrink-out {
  animation: sutolExitShrinkOut .8s ease-in 1 none !important;
}
.sutol-html-stage .entrance-animation-zoom-out {
  animation: sutolExitZoomOut .8s ease-in 1 none !important;
}
.sutol-html-stage .entrance-animation-spin-out {
  animation: sutolExitSpinOut .9s ease-in 1 none !important;
}
.sutol-html-stage .entrance-animation-motion-line {
  animation: sutolMotionLine 1.4s ease-in-out 1 none !important;
}
.sutol-html-stage .entrance-animation-motion-circle {
  animation: sutolMotionCircle 1.8s linear 1 none !important;
}
.sutol-html-stage .entrance-animation-motion-wave {
  animation: sutolMotionWave 1.8s ease-in-out 1 none !important;
}
.sutol-html-stage .entrance-animation-motion-custom {
  animation: sutolMotionCustom 1.8s ease-in-out 1 none !important;
}
.sutol-html-stage [class*="entrance-animation-"]:not(.entrance-animation-none) {
  animation-duration: var(--sutol-element-duration, .8s) !important;
  animation-delay: var(--sutol-element-delay, 0s) !important;
  animation-iteration-count: 1 !important;
}

@keyframes sutolEntranceFadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
@keyframes sutolEntranceFlyInLeft {
  from { opacity: 0; transform: translate3d(-110cqw, 0, 0); }
  to { opacity: 1; transform: translate3d(0, 0, 0); }
}
@keyframes sutolEntranceFlyInRight {
  from { opacity: 0; transform: translate3d(110cqw, 0, 0); }
  to { opacity: 1; transform: translate3d(0, 0, 0); }
}
@keyframes sutolEntranceFlyInTop {
  from { opacity: 0; transform: translate3d(0, -110cqh, 0); }
  to { opacity: 1; transform: translate3d(0, 0, 0); }
}
@keyframes sutolEntranceFlyInBottom {
  from { opacity: 0; transform: translate3d(0, 110cqh, 0); }
  to { opacity: 1; transform: translate3d(0, 0, 0); }
}
@keyframes sutolEntranceZoomIn {
  from { opacity: 0; transform: scale(.55); }
  to { opacity: 1; transform: scale(1); }
}
.sutol-html-stage .has-grouped-element-animation {
  animation: none !important;
}
.sutol-animation-segment {
  display: inline-block;
  will-change: transform, opacity, filter;
}
.sutol-animation-segment.is-paragraph-segment {
  display: inline;
}
.sutol-html-stage .is-element-animation-pending {
  animation: none !important;
  transform: none !important;
  opacity: 1 !important;
  filter: none !important;
}
.sutol-html-stage .is-element-animation-pending .sutol-animation-segment {
  animation: none !important;
  transform: none !important;
  opacity: 1 !important;
  filter: none !important;
}
@keyframes sutolEmphasisPulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.13); }
}
@keyframes sutolEmphasisShake {
  0%, 100% { transform: translateX(0); }
  20% { transform: translateX(-12px) rotate(-1deg); }
  40% { transform: translateX(10px) rotate(1deg); }
  60% { transform: translateX(-7px); }
  80% { transform: translateX(5px); }
}
@keyframes sutolEmphasisGrowShrink {
  0%, 100% { transform: scale(1); }
  45% { transform: scale(1.2); }
  70% { transform: scale(.94); }
}
@keyframes sutolEmphasisSpin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
@keyframes sutolEmphasisGlow {
  0%, 100% { filter: brightness(1) drop-shadow(0 0 0 currentColor); }
  50% { filter: brightness(1.35) drop-shadow(0 0 16px currentColor); }
}
@keyframes sutolExitFadeOut {
  from { opacity: 1; }
  to { opacity: 0; }
}
@keyframes sutolExitFlyOutLeft {
  from { opacity: 1; transform: translate3d(0, 0, 0); }
  to { opacity: 0; transform: translate3d(-100px, 0, 0); }
}
@keyframes sutolExitFlyOutRight {
  from { opacity: 1; transform: translate3d(0, 0, 0); }
  to { opacity: 0; transform: translate3d(100px, 0, 0); }
}
@keyframes sutolExitFlyOutTop {
  from { opacity: 1; transform: translate3d(0, 0, 0); }
  to { opacity: 0; transform: translate3d(0, -80px, 0); }
}
@keyframes sutolExitFlyOutBottom {
  from { opacity: 1; transform: translate3d(0, 0, 0); }
  to { opacity: 0; transform: translate3d(0, 80px, 0); }
}
@keyframes sutolExitShrinkOut {
  from { opacity: 1; transform: scale(1); }
  to { opacity: 0; transform: scale(.05); }
}
@keyframes sutolExitZoomOut {
  from { opacity: 1; transform: scale(1); filter: blur(0); }
  to { opacity: 0; transform: scale(1.8); filter: blur(8px); }
}
@keyframes sutolExitSpinOut {
  from { opacity: 1; transform: rotate(0deg) scale(1); }
  to { opacity: 0; transform: rotate(540deg) scale(.1); }
}
@keyframes sutolMotionLine {
  from { transform: translate(var(--sutol-motion-x0), var(--sutol-motion-y0)); }
  to { transform: translate(var(--sutol-motion-x3), var(--sutol-motion-y3)); }
}
@keyframes sutolMotionCircle {
  0%, 100% { transform: translate(0, 0); }
  25% { transform: translate(8cqw, -8cqh); }
  50% { transform: translate(16cqw, 0); }
  75% { transform: translate(8cqw, 8cqh); }
}
@keyframes sutolMotionWave {
  0% { transform: translate(0, 0); }
  25% { transform: translate(9cqw, -7cqh); }
  50% { transform: translate(18cqw, 7cqh); }
  75% { transform: translate(27cqw, -7cqh); }
  100% { transform: translate(36cqw, 0); }
}
@keyframes sutolMotionCustom {
  0% { transform: translate(var(--sutol-motion-x0), var(--sutol-motion-y0)); }
  33% { transform: translate(var(--sutol-motion-x1), var(--sutol-motion-y1)); }
  66% { transform: translate(var(--sutol-motion-x2), var(--sutol-motion-y2)); }
  100% { transform: translate(var(--sutol-motion-x3), var(--sutol-motion-y3)); }
}

/* Bir sonraki gösterim adımında sahne yeniden kurulduğunda daha önce
   görünmüş metinler animasyona tekrar girmez. Animasyonu kaldırmak yerine
   son karesinde dondururuz; böylece parlama/gölge/renk etkisi korunur. */
.sutol-html-block.is-text-animation-complete {
  animation-delay: -9999s !important;
  animation-iteration-count: 1 !important;
  animation-fill-mode: forwards !important;
  animation-play-state: paused !important;
  opacity: 1 !important;
}

.sutol-html-block.is-text-animation-complete .sutol-typewriter-word {
  animation-delay: -9999s !important;
  animation-iteration-count: 1 !important;
  animation-fill-mode: both !important;
  animation-play-state: paused !important;
  opacity: 1 !important;
  border-right-color: transparent !important;
}

@keyframes sutolEffectDeepGlow {
  0% { text-shadow: 0 0 calc(4px * var(--sutol-glow)) currentColor, 0 0 calc(14px * var(--sutol-glow)) currentColor; transform: scale(0.985); opacity: 0.82; }
  100% { text-shadow: 0 0 calc(12px * var(--sutol-glow)) currentColor, 0 0 calc(38px * var(--sutol-glow)) currentColor, 0 0 calc(72px * var(--sutol-glow)) currentColor; transform: scale(1.035); opacity: 1; }
}

@keyframes sutolEffectSoftPulse {
  0% { text-shadow: 0 0 calc(3px * var(--sutol-glow)) currentColor, 0 0 calc(10px * var(--sutol-glow)) currentColor; transform: scale(0.99); opacity: 0; }
  50% { text-shadow: 0 0 calc(9px * var(--sutol-glow)) currentColor, 0 0 calc(30px * var(--sutol-glow)) currentColor, 0 0 calc(52px * var(--sutol-glow)) currentColor; transform: scale(1.025); opacity: 1; }
  100% { text-shadow: 0 0 calc(3px * var(--sutol-glow)) currentColor, 0 0 calc(10px * var(--sutol-glow)) currentColor; transform: scale(1); opacity: 1; }
}

@keyframes sutolEffectGlitch {
  0%, 72%, 100% { text-shadow: 0 0 calc(7px * var(--sutol-glow)) currentColor, 0 0 calc(22px * var(--sutol-glow)) currentColor; transform: translate(0, 0) skewX(0); opacity: 1; }
  76% { text-shadow: -5px 0 calc(4px * var(--sutol-glow)) currentColor, 5px 0 calc(12px * var(--sutol-glow)) #ffffff; transform: translate(-4px, 1px) skewX(-4deg); opacity: 1; }
  80% { text-shadow: 6px 0 calc(6px * var(--sutol-glow)) currentColor, -4px 0 calc(14px * var(--sutol-glow)) #ffffff; transform: translate(5px, -1px) skewX(5deg); opacity: 1; }
  84% { transform: translate(-2px, 0) skewX(-2deg); }
  88% { transform: translate(0, 0) skewX(0); }
}

@keyframes sutolEffectFlicker {
  0%, 14%, 20%, 42%, 48%, 74%, 100% { text-shadow: 0 0 calc(9px * var(--sutol-glow)) currentColor, 0 0 calc(30px * var(--sutol-glow)) currentColor, 0 0 calc(58px * var(--sutol-glow)) currentColor; transform: scale(1.02); opacity: 1; }
  16%, 44%, 76% { text-shadow: none; transform: scale(0.985); opacity: 1; }
  18%, 46% { text-shadow: 0 0 calc(16px * var(--sutol-glow)) currentColor, 0 0 calc(64px * var(--sutol-glow)) currentColor; opacity: 1; }
}

@keyframes sutolEffectDrift {
  0% { text-shadow: -8px 0 calc(16px * var(--sutol-glow)) currentColor, 0 0 calc(30px * var(--sutol-glow)) currentColor; transform: translateX(-4px) perspective(500px) rotateY(-2deg); opacity: 0; }
  50% { text-shadow: 8px 0 calc(34px * var(--sutol-glow)) currentColor, 0 0 calc(58px * var(--sutol-glow)) currentColor; transform: translateX(4px) perspective(500px) rotateY(2deg); opacity: 1; }
  100% { text-shadow: -8px 0 calc(16px * var(--sutol-glow)) currentColor, 0 0 calc(30px * var(--sutol-glow)) currentColor; transform: translateX(0) perspective(500px) rotateY(0); opacity: 1; }
}

@keyframes sutolEffectScalePulse {
  0% { text-shadow: 0 0 calc(5px * var(--sutol-glow)) currentColor, 0 0 calc(16px * var(--sutol-glow)) currentColor; transform: scale(0.975); opacity: 0; }
  45% { text-shadow: 0 0 calc(14px * var(--sutol-glow)) currentColor, 0 0 calc(46px * var(--sutol-glow)) currentColor, 0 0 calc(76px * var(--sutol-glow)) currentColor; transform: scale(1.045); opacity: 1; }
  55% { transform: scale(1.015); }
  100% { text-shadow: 0 0 calc(5px * var(--sutol-glow)) currentColor, 0 0 calc(16px * var(--sutol-glow)) currentColor; transform: scale(1); opacity: 1; }
}

@keyframes sutolEffectPrism {
  0% { background-position: 0% 50%; transform: skewX(-2deg) scale(0.99); filter: drop-shadow(-4px 0 calc(5px * var(--sutol-glow)) var(--sutol-text-color, #60a5fa)); }
  50% { transform: skewX(2deg) scale(1.035); filter: drop-shadow(4px 0 calc(18px * var(--sutol-glow)) var(--sutol-text-color, #60a5fa)); }
  100% { background-position: 300% 50%; transform: skewX(-2deg) scale(0.99); filter: drop-shadow(-4px 0 calc(5px * var(--sutol-glow)) var(--sutol-text-color, #60a5fa)); }
}

@keyframes sutolEffectSolarFlare {
  0% { text-shadow: -8px 0 calc(12px * var(--sutol-glow)) currentColor, 0 0 calc(24px * var(--sutol-glow)) currentColor; transform: scale(0.98); opacity: 0; }
  40% { text-shadow: 0 0 calc(18px * var(--sutol-glow)) #ffffff, 0 0 calc(48px * var(--sutol-glow)) currentColor, 12px 0 calc(82px * var(--sutol-glow)) currentColor; transform: scale(1.05); opacity: 1; }
  55% { transform: scale(1.015); }
  100% { text-shadow: -8px 0 calc(12px * var(--sutol-glow)) currentColor, 0 0 calc(24px * var(--sutol-glow)) currentColor; transform: scale(1); opacity: 1; }
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
  0% { text-shadow: -10px 0 calc(10px * var(--sutol-glow)) currentColor; transform: skewX(-1deg); opacity: 0; }
  45% { text-shadow: 0 0 calc(16px * var(--sutol-glow)) #ffffff, 0 0 calc(42px * var(--sutol-glow)) currentColor; transform: skewX(1deg) scale(1.035); opacity: 1; }
  55% { text-shadow: 10px 0 calc(20px * var(--sutol-glow)) currentColor; }
  100% { text-shadow: -10px 0 calc(10px * var(--sutol-glow)) currentColor; transform: none; opacity: 1; }
}

@keyframes sutolEffectShimmer {
  0% { text-shadow: -6px 0 calc(8px * var(--sutol-glow)) currentColor; opacity: 0; transform: translateX(-2px); }
  50% { text-shadow: 6px 0 calc(26px * var(--sutol-glow)) #ffffff, 0 0 calc(38px * var(--sutol-glow)) currentColor; opacity: 1; transform: translateX(2px); }
  100% { text-shadow: -6px 0 calc(8px * var(--sutol-glow)) currentColor; opacity: 1; transform: none; }
}

@keyframes sutolEffectElectricFlicker {
  0%, 12%, 18%, 52%, 58%, 100% { text-shadow: -3px 0 calc(8px * var(--sutol-glow)) currentColor, 3px 0 calc(24px * var(--sutol-glow)) #ffffff, 0 0 calc(44px * var(--sutol-glow)) currentColor; transform: skewX(0); opacity: 1; }
  14%, 54% { text-shadow: none; transform: skewX(-5deg) translateX(-3px); opacity: 1; }
  16%, 56% { text-shadow: 5px 0 calc(34px * var(--sutol-glow)) currentColor; transform: skewX(4deg) translateX(3px); opacity: 1; }
}

@keyframes sutolEffectEnergyWave {
  0% { text-shadow: 0 5px calc(10px * var(--sutol-glow)) currentColor; transform: translateY(2px) scale(0.99); opacity: 0; }
  50% { text-shadow: 0 -5px calc(32px * var(--sutol-glow)) currentColor, 0 0 calc(52px * var(--sutol-glow)) currentColor; transform: translateY(-3px) scale(1.035); opacity: 1; }
  100% { text-shadow: 0 5px calc(10px * var(--sutol-glow)) currentColor; transform: none; opacity: 1; }
}

@keyframes sutolEffectMatrixGlow {
  0% { text-shadow: 0 4px calc(8px * var(--sutol-glow)) currentColor; transform: scaleY(0.97); opacity: 0.68; }
  100% { text-shadow: 0 -4px calc(20px * var(--sutol-glow)) currentColor, 0 0 calc(56px * var(--sutol-glow)) currentColor; transform: scaleY(1.04); opacity: 1; }
}

@keyframes sutolEffectCircuitScan {
  0% { text-shadow: -8px 0 calc(8px * var(--sutol-glow)) currentColor; transform: translateX(-2px); opacity: 0; }
  50% { text-shadow: 8px 0 calc(30px * var(--sutol-glow)) currentColor, 0 0 calc(48px * var(--sutol-glow)) currentColor; transform: translateX(2px); opacity: 1; }
  100% { text-shadow: -8px 0 calc(8px * var(--sutol-glow)) currentColor; transform: none; opacity: 1; }
}

@keyframes sutolEffectDataGlitch {
  0%, 62%, 100% { text-shadow: 0 0 calc(9px * var(--sutol-glow)) currentColor, 0 0 calc(26px * var(--sutol-glow)) currentColor; transform: translate(0, 0) skewX(0); opacity: 1; }
  66% { text-shadow: -7px 0 calc(4px * var(--sutol-glow)) #ffffff, 5px 0 calc(16px * var(--sutol-glow)) currentColor; transform: translate(-5px, 2px) skewX(-7deg); opacity: 1; }
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
  100% { clip-path: inset(0 0 0 0); transform: translateY(0); filter: blur(0); opacity: 1; text-shadow: 0 0 calc(10px * var(--sutol-glow)) currentColor; }
}

@keyframes sutolEffectRiseIn {
  0% { transform: translateY(42px); filter: blur(5px); opacity: 0; }
  100% { transform: translateY(0); filter: blur(0); opacity: 1; }
}

@keyframes sutolEffectSlideFromLeft {
  0% { transform: translateX(-64px); filter: blur(3px); opacity: 0; }
  100% { transform: translateX(0); filter: blur(0); opacity: 1; }
}

@keyframes sutolEffectWordReveal {
  0% { transform: translateY(.7em) scale(.96); filter: blur(5px); opacity: 0; }
  100% { transform: translateY(0) scale(1); filter: blur(0); opacity: 1; }
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
    transform: translateY(0);
    opacity: 1;
  }
}

@keyframes sutolEffectBlurFocus {
  0%, 12% { filter: blur(16px); letter-spacing: 0.22em; transform: scale(1.12); opacity: 0; }
  48%, 82% { filter: blur(0); letter-spacing: 0.02em; transform: scale(1); opacity: 1; text-shadow: 0 0 calc(16px * var(--sutol-glow)) currentColor; }
  100% { filter: blur(0); letter-spacing: 0.02em; transform: scale(1); opacity: 1; text-shadow: 0 0 calc(8px * var(--sutol-glow)) currentColor; }
}

@keyframes sutolEffectFlip3d {
  0%, 10% { transform: perspective(700px) rotateX(-92deg) translateY(-22px); filter: blur(6px); opacity: 0; }
  42% { transform: perspective(700px) rotateX(12deg) translateY(3px); filter: blur(0); opacity: 1; text-shadow: 0 0 calc(24px * var(--sutol-glow)) currentColor; }
  56%, 84% { transform: perspective(700px) rotateX(0) translateY(0); opacity: 1; }
  100% { transform: perspective(700px) rotateX(0) translateY(0); filter: blur(0); opacity: 1; }
}

@keyframes sutolEffectBounceIn {
  0%, 8% { transform: translateY(-46px) scale(0.72); opacity: 0; }
  32% { transform: translateY(12px) scale(1.08); opacity: 1; text-shadow: 0 0 calc(28px * var(--sutol-glow)) currentColor; }
  44% { transform: translateY(-7px) scale(0.96); }
  54% { transform: translateY(3px) scale(1.025); }
  64%, 86% { transform: translateY(0) scale(1); opacity: 1; }
  100% { transform: translateY(0) scale(1); opacity: 1; }
}

@keyframes sutolEffectSpotlightSweep {
  0% { background-position: 120% 50%; filter: drop-shadow(-8px 0 calc(4px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff)); }
  50% { filter: drop-shadow(0 0 calc(20px * var(--sutol-glow)) #ffffff); transform: scale(1.02); }
  100% { background-position: -120% 50%; filter: drop-shadow(8px 0 calc(4px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff)); }
}

@keyframes sutolEffectCurtainReveal {
  0%, 10% { clip-path: inset(0 50% 0 50%); transform: scaleX(0.82); filter: blur(7px); opacity: 0; }
  48%, 84% { clip-path: inset(0 0 0 0); transform: scaleX(1); filter: blur(0); opacity: 1; text-shadow: 0 0 calc(18px * var(--sutol-glow)) currentColor; }
  100% { clip-path: inset(0 0 0 0); transform: scaleX(1); filter: blur(0); opacity: 1; }
}

@keyframes sutolEffectCinematicZoom {
  0%, 10% { transform: perspective(800px) translateZ(260px) scale(1.55); filter: blur(18px); opacity: 0; letter-spacing: 0.18em; }
  48%, 84% { transform: perspective(800px) translateZ(0) scale(1); filter: blur(0); opacity: 1; letter-spacing: 0.02em; text-shadow: 0 0 calc(20px * var(--sutol-glow)) currentColor; }
  100% { transform: perspective(800px) translateZ(0) scale(1); filter: blur(0); opacity: 1; letter-spacing: 0.02em; }
}

@keyframes sutolEffectZeroGravity {
  0% { transform: translate(-5px, 7px) rotate(-1.4deg) scale(0.99); text-shadow: -6px 8px calc(16px * var(--sutol-glow)) currentColor; opacity: 0; }
  35% { transform: translate(3px, -6px) rotate(1deg) scale(1.025); text-shadow: 4px -8px calc(28px * var(--sutol-glow)) currentColor; opacity: 1; }
  68% { transform: translate(6px, 3px) rotate(-0.5deg) scale(1.01); text-shadow: 8px 4px calc(22px * var(--sutol-glow)) currentColor; }
  100% { transform: none; text-shadow: -6px 8px calc(16px * var(--sutol-glow)) currentColor; opacity: 1; }
}

@keyframes sutolEffectNeonOutline {
  0%, 14%, 20%, 52%, 58%, 100% { -webkit-text-stroke-width: 1.5px; text-shadow: 0 0 calc(7px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff), 0 0 calc(24px * var(--sutol-glow)) var(--sutol-text-color, #f8fbff); opacity: 1; }
  16%, 54% { -webkit-text-stroke-width: 0.5px; text-shadow: none; opacity: 1; }
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
  68% { clip-path: polygon(0 0, 96% 0, 96% 42%, 0 42%, 0 65%, 96% 65%, 96% 100%, 0 100%); transform: translate(7px, -1px) skewX(6deg); opacity: 1; }
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

.sutol-stage-mode-snapshot [class*="entrance-animation-"] {
  animation: none !important;
  transform: none !important;
  opacity: 1 !important;
}

/* Scene-strip thumbnails are reference images, not miniature presentations.
   Stop every CSS effect so each visible thumbnail costs only a static paint. */
.sutol-stage-mode-snapshot *,
.sutol-stage-mode-snapshot *::before,
.sutol-stage-mode-snapshot *::after {
  animation: none !important;
  transition: none !important;
}

.sutol-html-block.is-selected {
  outline: 2px solid #0B7BFF;
  background: rgba(11, 123, 255, 0.08);
}

.sutol-html-stage.theme-dark .sutol-html-block.is-selected {
  outline-color: rgba(103, 232, 249, 0.86);
  background: rgba(103, 232, 249, 0.10);
}

.sutol-html-block.is-inline-editing {
  opacity: 0 !important;
  animation: none !important;
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
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}

.sutol-html-component.component-3d-model::before,
.sutol-html-component.component-3d-model::after {
  display: none !important;
}

.sutol-3d-model-inner,
.sutol-3d-model-viewer {
  display: block;
  width: 100%;
  height: 100%;
  background: transparent;
  --poster-color: transparent;
}

.sutol-3d-model-status {
  position: absolute;
  left: 50%;
  top: 50%;
  width: auto;
  height: auto;
  padding: 0.55em 0.8em;
  border-radius: 0.7em;
  color: rgba(226, 232, 240, 0.82);
  background: rgba(15, 23, 42, 0.66);
  font: 600 2.2cqw/1.2 Arial, sans-serif;
  transform: translate(-50%, -50%);
  white-space: nowrap;
  pointer-events: none;
}

.sutol-3d-model-status.is-error {
  color: #fff;
  background: rgba(153, 27, 27, 0.86);
}

.sutol-3d-model-fallback {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  border-radius: inherit;
}

.sutol-3d-model-fallback[hidden] {
  display: none;
}

.sutol-3d-fallback-card {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding: 12px;
  background: rgba(15, 23, 42, 0.85);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 12px;
  color: #f8fafc;
  text-align: center;
  user-select: none;
}

.sutol-3d-fallback-icon {
  font-size: 24px;
  line-height: 1;
}

.sutol-3d-fallback-title {
  font-size: 12px;
  font-weight: 600;
  color: #f1f5f9;
}

.sutol-3d-fallback-sub {
  font-size: 10px;
  color: #94a3b8;
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

/* Yuklenen yerel gorseller (data URL). */
.sutol-uploaded-image-inner {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.sutol-uploaded-image-inner:empty {
  background: rgba(128, 128, 128, 0.08);
  border: 1px dashed rgba(128, 128, 128, 0.45);
  border-radius: 12px;
}

.sutol-uploaded-image-element {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 6px;
  user-select: none;
  -webkit-user-drag: none;
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
    const previousAnimationClass = Array.from(element.classList).filter(function (name) {
      return name.indexOf('text-animation-') === 0 || name.indexOf('entrance-animation-') === 0;
    }).join('|');
    const nextAnimationClass = String(item.className || '').split(/\s+/).filter(function (name) {
      return name.indexOf('text-animation-') === 0 || name.indexOf('entrance-animation-') === 0;
    }).join('|');
    const animationChanged = previousAnimationClass !== nextAnimationClass;
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
    if (item.modelAutoRotate !== null && item.modelAutoRotate !== undefined) {
      const modelViewer = element.querySelector('model-viewer');
      if (modelViewer) {
        if (item.modelAutoRotate) {
          modelViewer.setAttribute('auto-rotate', '');
          modelViewer.setAttribute('auto-rotate-delay', '0');
        } else {
          modelViewer.removeAttribute('auto-rotate');
        }
      }
    }
    if (item.modelRotationSpeed !== null && item.modelRotationSpeed !== undefined) {
      const modelViewer = element.querySelector('model-viewer');
      if (modelViewer) {
        modelViewer.setAttribute(
          'rotation-per-second',
          String(item.modelRotationSpeed) + 'deg'
        );
      }
    }
    if (item.modelOrbitEnabled !== null && item.modelOrbitEnabled !== undefined) {
      const modelViewer = element.querySelector('model-viewer');
      if (modelViewer) {
        if (item.modelOrbitEnabled) {
          modelViewer.setAttribute('camera-controls', '');
        } else {
          modelViewer.removeAttribute('camera-controls');
        }
      }
    }
    if (item.modelAnimationEnabled !== null &&
        item.modelAnimationEnabled !== undefined) {
      const modelViewer = element.querySelector('model-viewer');
      if (modelViewer) {
        if (item.modelAnimationEnabled) {
          modelViewer.setAttribute('autoplay', '');
        } else {
          modelViewer.removeAttribute('autoplay');
        }
      }
    }
    if (item.textBold !== undefined) {
      element.style.fontWeight = item.textBold ? '700' : '';
    }
    if (item.textItalic !== undefined) {
      element.style.fontStyle = item.textItalic ? 'italic' : '';
    }
    if (item.textUnderline !== undefined) {
      element.style.textDecoration = item.textUnderline ? 'underline' : '';
    }
    if (item.textAlign !== undefined) {
      element.style.textAlign = item.textAlign || '';
    }
    if (item.baseFontSize !== undefined) {
      element.style.setProperty('--base-font-size', item.baseFontSize);
    }
    if (item.glowIntensity !== undefined) {
      element.style.setProperty('--sutol-glow', item.glowIntensity);
    }
    if (item.animationDuration !== undefined) {
      element.style.setProperty('--sutol-element-duration', item.animationDuration + 's');
    }
    if (item.animationDelay !== undefined) {
      element.style.setProperty('--sutol-element-delay', item.animationDelay + 's');
    }
    if (Array.isArray(item.motionPathPoints)) {
      item.motionPathPoints.slice(0, 4).forEach(function (point, index) {
        element.style.setProperty('--sutol-motion-x' + index, point.x);
        element.style.setProperty('--sutol-motion-y' + index, point.y);
      });
    }
    if (item.textColor === null || item.textColor === undefined) {
      element.style.removeProperty('color');
      element.style.removeProperty('--sutol-text-color');
    } else {
      element.style.color = item.textColor;
      element.style.setProperty('--sutol-text-color', item.textColor);
    }
    if (item.text !== undefined) {
      if (item.textGrouping && item.textGrouping !== 'asObject' &&
          item.entranceAnimationClass !== 'entrance-animation-none') {
        element.setAttribute('aria-label', String(item.text));
        const visual = document.createElement('span');
        visual.className = 'sutol-animation-visual';
        visual.setAttribute('aria-hidden', 'true');
        const baseDelay = Number(item.animationDelay || 0);
        const groupDelay = Number(item.groupDelay || .08);
        let tokens;
        if (item.textGrouping === 'byParagraph') {
          tokens = String(item.text).split('\n');
        } else if (item.textGrouping === 'byWord') {
          tokens = String(item.text).match(/\S+|\s+/g) || [];
        } else {
          tokens = Array.from(String(item.text));
        }
        let segmentIndex = 0;
        tokens.forEach(function (token, tokenIndex) {
          if (item.textGrouping === 'byWord' && token.trim().length === 0) {
            visual.appendChild(document.createTextNode(token));
            return;
          }
          const segment = document.createElement('span');
          segment.className = 'sutol-animation-segment ' + item.entranceAnimationClass +
            (item.textGrouping === 'byParagraph' ? ' is-paragraph-segment' : '');
          segment.setAttribute('aria-hidden', 'true');
          segment.style.setProperty(
            '--sutol-element-delay',
            (baseDelay + segmentIndex * groupDelay).toFixed(2) + 's'
          );
          segment.textContent = token;
          visual.appendChild(segment);
          segmentIndex += 1;
          if (item.textGrouping === 'byParagraph' && tokenIndex < tokens.length - 1) {
            visual.appendChild(document.createElement('br'));
          }
        });
        element.replaceChildren(visual);
      } else if (item.isTypewriter || item.isWordReveal) {
        element.removeAttribute('aria-label');
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
        element.removeAttribute('aria-label');
        element.textContent = item.text;
      }
    }
    if (animationChanged) {
      // Setting a different animation class during an in-place iframe patch is
      // not sufficient in every browser. Force a style boundary so the newly
      // selected effect visibly starts from its first frame.
      element.style.setProperty('animation', 'none', 'important');
      void element.offsetWidth;
      element.style.removeProperty('animation');
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
