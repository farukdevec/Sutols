import 'dart:convert';

import '../models/slide_model.dart';
import '../ui/widgets/html_stage/html_stage_document.dart';

String buildPresentationExportHtml({
  required List<PresentationPage> pages,
  PresentationEffectSettings effectSettings =
      const PresentationEffectSettings(),
  String? title,
  Map<String, String> modelSourcesById = const <String, String>{},
  bool compact = true,
}) {
  final documentTitle = title ?? _resolvePresentationTitle(pages);
  final escapedDocumentTitle = _escapeHtml(documentTitle);
  final revealCounts = _revealCountsJson(pages);
  final embeddedAssetsScript = _embeddedAssetsBootstrap(
    pages: pages,
    modelSourcesById: modelSourcesById,
  );
  final slidesMarkup = StringBuffer();
  final dotsMarkup = StringBuffer();
  final zoomButtonMarkup = effectSettings.zoomEnabled
      ? '<button id="sutolZoomBtn" class="sutol-export-action sutol-export-icon-action" type="button" aria-label="Zoom" aria-pressed="false" title="Zoom">&#8853;</button>'
      : '';

  for (var index = 0; index < pages.length; index += 1) {
    final page = pages[index];
    slidesMarkup
      ..writeln(
        '<section class="sutol-export-slide${index == 0 ? ' is-active' : ''}" data-index="$index" data-page-id="${_escapeAttribute(page.id)}" aria-label="Slayt ${index + 1}" aria-hidden="${index == 0 ? 'false' : 'true'}">',
      )
      ..writeln('<div class="sutol-export-stage-frame">')
      ..writeln(
        buildHtmlStageMarkup(
          page: page,
          showBadge: false,
          extraStageClass: 'sutol-export-stage',
          renderMode: effectSettings.reducedMotion
              ? HtmlStageRenderMode.snapshot
              : HtmlStageRenderMode.full,
          modelSourcesById: modelSourcesById,
          deferEmbeddedAssets: true,
        ),
      )
      ..writeln('</div>')
      ..writeln('</section>');

    dotsMarkup.writeln(
      '<button class="sutol-export-dot${index == 0 ? ' is-active' : ''}" type="button" data-index="$index" aria-label="Slayt ${index + 1}" aria-current="${index == 0 ? 'true' : 'false'}"></button>',
    );
  }

  final document = '''
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$escapedDocumentTitle</title>
  ${pages.any((page) => page.componentBlocks.any((block) => block.modelAssetId != null)) ? sutolModelViewerScriptTag : ''}
  <style>
  $sutolHtmlStageStyles
  ${_exportStyles(effectSettings)}
  </style>
</head>
<body>
  <div class="sutol-export-shell ${_transitionShellClass(effectSettings.transitionKind)}${effectSettings.zoomEnabled ? ' allow-zoom' : ''}${effectSettings.reducedMotion ? ' reduce-motion' : ''}" style="--sutol-transition-duration:${effectSettings.transitionDurationMs}ms;--sutol-zoom-scale:${effectSettings.zoomScale.toStringAsFixed(2)};">
    <main class="sutol-export-deck">
      $slidesMarkup
    </main>

    <div class="sutol-export-nav">
      <button id="sutolPrevBtn" class="sutol-export-action sutol-export-arrow" type="button" aria-label="Onceki slayt" title="Onceki slayt">&#8592;</button>
      <div class="sutol-export-dots">
        $dotsMarkup
      </div>
      <button id="sutolNextBtn" class="sutol-export-action sutol-export-arrow primary" type="button" aria-label="Sonraki slayt" title="Sonraki slayt">&#8594;</button>
      $zoomButtonMarkup
      <button id="sutolFullscreenBtn" class="sutol-export-action sutol-export-icon-action" type="button" aria-label="Tam ekran" title="Tam ekran">&#9974;</button>
    </div>
  </div>

  <script>
  $embeddedAssetsScript
  $sutolHtmlStageBackgroundScript
  $sutolHtmlStageComponentScript

  ${_exportScript(
    zoomEnabled: effectSettings.zoomEnabled,
    revealCounts: revealCounts,
    smoothTransition:
        effectSettings.transitionKind == PresentationTransitionKind.smooth,
    transitionDurationMs: effectSettings.transitionDurationMs,
  )}
  </script>
</body>
</html>
''';
  return compact ? _compactHtml(document) : document;
}

String _resolvePresentationTitle(List<PresentationPage> pages) {
  for (final page in pages) {
    for (final block in page.textBlocks) {
      final value = block.text.trim();
      if (value.isNotEmpty) {
        return value.length > 64 ? value.substring(0, 64) : value;
      }
    }
  }
  return 'Sutol Demo Sunumu';
}

String _revealCountsJson(List<PresentationPage> pages) {
  return '[${pages.map(_revealStepCountForPage).join(',')}]';
}

int _revealStepCountForPage(PresentationPage page) {
  var maxStep = 0;
  for (final block in page.textBlocks) {
    if (block.revealStep > maxStep) {
      maxStep = block.revealStep;
    }
  }
  for (final block in page.componentBlocks) {
    if (block.revealStep > maxStep) {
      maxStep = block.revealStep;
    }
  }
  return maxStep;
}

String _escapeHtml(String value) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(value);

String _escapeAttribute(String value) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(value);

String _embeddedAssetsBootstrap({
  required List<PresentationPage> pages,
  required Map<String, String> modelSourcesById,
}) {
  final backgroundKinds = pages.map((page) => page.backgroundKind).toSet();
  final backgroundScenes = <String, String>{
    for (final kind in backgroundKinds)
      kind.name: _compactHtml(sutolHtmlBackgroundScene(kind)),
  };
  final usedModelIds = pages
      .expand((page) => page.componentBlocks)
      .map((block) => block.modelAssetId)
      .whereType<String>()
      .toSet();
  final modelSources = <String, String>{};
  for (final modelId in usedModelIds) {
    final model = findPresentation3DModelAsset(modelId);
    if (model == null) {
      continue;
    }
    modelSources[modelId] =
        modelSourcesById[modelId] ?? 'assets/${model.assetPath}';
  }

  return '''
const sutolBackgroundScenes = ${_scriptSafeJson(backgroundScenes)};
document.querySelectorAll('[data-sutol-background-kind]').forEach((frame) => {
  const source = sutolBackgroundScenes[frame.dataset.sutolBackgroundKind];
  if (source) frame.srcdoc = source;
});
const sutolModelSources = ${_scriptSafeJson(modelSources)};
document.querySelectorAll('[data-sutol-model-source-id]').forEach((model) => {
  const source = sutolModelSources[model.dataset.sutolModelSourceId];
  if (source) model.setAttribute('src', source);
});
''';
}

String _scriptSafeJson(Object value) => jsonEncode(value)
    .replaceAll('<', r'\u003C')
    .replaceAll('>', r'\u003E')
    .replaceAll('&', r'\u0026');

String _compactHtml(String source) => source
    .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '')
    .replaceAll(RegExp(r'>[ \t]*\r?\n[ \t]*<'), '><')
    .replaceAll(RegExp(r'\n[ \t]*\n+'), '\n')
    .trim();

String _transitionShellClass(PresentationTransitionKind kind) {
  switch (kind) {
    case PresentationTransitionKind.none:
      return 'transition-none';
    case PresentationTransitionKind.smooth:
      return 'transition-smooth';
    case PresentationTransitionKind.fade:
      return 'transition-fade';
    case PresentationTransitionKind.slide:
      return 'transition-slide';
    case PresentationTransitionKind.zoom:
      return 'transition-zoom';
    case PresentationTransitionKind.convex:
      return 'transition-convex';
    case PresentationTransitionKind.concave:
      return 'transition-concave';
    case PresentationTransitionKind.wipe:
      return 'transition-wipe';
    case PresentationTransitionKind.split:
      return 'transition-split';
    case PresentationTransitionKind.reveal:
      return 'transition-reveal';
    case PresentationTransitionKind.cover:
      return 'transition-cover';
    case PresentationTransitionKind.uncover:
      return 'transition-uncover';
    case PresentationTransitionKind.flip:
      return 'transition-flip';
  }
}

String _exportStyles(PresentationEffectSettings effectSettings) => '''
html, body {
  width: 100%;
  height: 100%;
  margin: 0;
  overflow: hidden;
  background: #000;
  color: #f8fbff;
  font-family: "Trebuchet MS", sans-serif;
}

body {
  display: block;
}

.sutol-export-shell {
  --sutol-transition-duration: ${effectSettings.transitionDurationMs}ms;
  --sutol-zoom-scale: ${effectSettings.zoomScale.toStringAsFixed(2)};
  position: fixed;
  inset: 0;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  box-sizing: border-box;
  background: #000;
}

.sutol-export-deck {
  position: fixed;
  inset: 0;
  display: grid;
  place-items: center;
  overflow: hidden;
  perspective: 1800px;
}

.sutol-export-slide {
  display: none;
  width: 100%;
  height: 100%;
  place-items: center;
}

.sutol-export-slide.is-active {
  display: grid;
  animation-duration: var(--sutol-transition-duration);
  animation-timing-function: cubic-bezier(.22, 1, .36, 1);
  animation-fill-mode: both;
}

.sutol-export-shell.transition-none .sutol-export-slide.is-active {
  animation-name: none;
}

.sutol-export-shell.transition-smooth .sutol-export-slide.is-active {
  position: relative;
  z-index: 2;
  animation-name: sutolTransitionSmoothIn;
}

.sutol-export-shell.transition-smooth .sutol-export-slide.is-leaving {
  position: absolute;
  inset: 0;
  z-index: 1;
  display: grid;
  pointer-events: none;
  animation: sutolTransitionSmoothOut var(--sutol-transition-duration)
    cubic-bezier(.45, 0, .55, 1) both;
}

.sutol-export-shell.transition-fade .sutol-export-slide.is-active {
  animation-name: sutolTransitionFade;
}

.sutol-export-shell.transition-slide .sutol-export-slide.is-active {
  animation-name: sutolTransitionSlide;
}

.sutol-export-shell.transition-zoom .sutol-export-slide.is-active {
  animation-name: sutolTransitionZoom;
}

.sutol-export-shell.transition-convex .sutol-export-slide.is-active {
  animation-name: sutolTransitionConvex;
}

.sutol-export-shell.transition-concave .sutol-export-slide.is-active {
  animation-name: sutolTransitionConcave;
}

.sutol-export-shell.transition-wipe .sutol-export-slide.is-active {
  animation-name: sutolTransitionWipe;
}

.sutol-export-shell.transition-split .sutol-export-slide.is-active {
  animation-name: sutolTransitionSplit;
}

.sutol-export-shell.transition-reveal .sutol-export-slide.is-active {
  animation-name: sutolTransitionReveal;
}

.sutol-export-shell.transition-cover .sutol-export-slide.is-active {
  animation-name: sutolTransitionCover;
}

.sutol-export-shell.transition-uncover .sutol-export-slide.is-active {
  animation-name: sutolTransitionUncover;
}

.sutol-export-shell.transition-flip .sutol-export-slide.is-active {
  animation-name: sutolTransitionFlip;
}

.sutol-export-shell.reduce-motion .sutol-export-slide.is-active {
  animation-name: none;
}

.sutol-export-stage-frame {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  transform-origin: var(--sutol-zoom-origin-x, 50%) var(--sutol-zoom-origin-y, 50%);
  transition:
    transform 320ms cubic-bezier(.22, 1, .36, 1);
}

.sutol-export-stage {
  border: 0;
  border-radius: 0;
}

.sutol-export-stage [data-reveal-step] {
  transition:
    opacity 220ms ease,
    transform 220ms cubic-bezier(.22, 1, .36, 1);
}

.sutol-export-stage [data-reveal-step]:not([data-reveal-step="0"]):not(.is-reveal-visible),
.sutol-export-stage [data-reveal-step].is-reveal-hidden {
  opacity: 0;
  transform: translateY(10px) scale(0.985);
  pointer-events: none;
}

.sutol-export-stage [data-reveal-step].is-reveal-visible {
  opacity: 1;
  transform: none;
  pointer-events: auto;
}

.sutol-export-stage [data-hotspot-target] {
  cursor: pointer;
}

.sutol-export-stage [data-hotspot-target].is-hotspot-active {
  outline: 3px solid rgba(103, 232, 249, 0.46);
  outline-offset: 5px;
}

.sutol-export-shell.allow-zoom .sutol-export-slide.is-active .sutol-export-stage-frame {
  cursor: zoom-in;
}

.sutol-export-shell.allow-zoom.is-zoomed .sutol-export-slide.is-active .sutol-export-stage-frame {
  cursor: zoom-out;
  transform: scale(var(--sutol-zoom-scale));
}

.sutol-export-shell.reduce-motion .sutol-export-stage-frame,
.sutol-export-shell.reduce-motion .sutol-export-action,
.sutol-export-shell.reduce-motion .sutol-export-dot,
.sutol-export-shell.reduce-motion .sutol-export-stage [data-reveal-step] {
  transition: none;
}

.sutol-export-nav {
  position: fixed;
  z-index: 100;
  left: 50%;
  bottom: max(18px, env(safe-area-inset-bottom));
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.65rem;
  max-width: calc(100vw - 24px);
  padding: 0.55rem 0.7rem;
  border-radius: 999px;
  background: rgba(3, 7, 18, 0.58);
  border: 1px solid rgba(255, 255, 255, 0.16);
  backdrop-filter: blur(16px);
  box-shadow: 0 10px 36px rgba(0, 0, 0, 0.28);
}

.sutol-export-dots {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 0.5rem;
  max-width: min(68vw, 760px);
}

.sutol-export-dot {
  width: 0.7rem;
  height: 0.7rem;
  border: 0;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.22);
  cursor: pointer;
  transition: transform 180ms ease, background 180ms ease;
}

.sutol-export-dot.is-active {
  background: #67e8f9;
  transform: scale(1.28);
}

.sutol-export-action {
  appearance: none;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.08);
  color: #f8fbff;
  border-radius: 999px;
  padding: 0.8rem 1.2rem;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  transition: transform 180ms ease, background 180ms ease;
}

.sutol-export-arrow,
.sutol-export-icon-action {
  display: grid;
  place-items: center;
  width: 2.65rem;
  height: 2.65rem;
  padding: 0;
  font-size: 1.35rem;
  line-height: 1;
}

.sutol-export-icon-action {
  width: 2.35rem;
  height: 2.35rem;
  font-size: 1.05rem;
}

.sutol-export-action.primary {
  background: #0b7bff;
  border-color: #0b7bff;
}

.sutol-export-action:hover {
  transform: translateY(-1px);
  background: rgba(255, 255, 255, 0.14);
}

.sutol-export-action.primary:hover {
  background: #0a6fe6;
}

@keyframes sutolTransitionFade {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes sutolTransitionSmoothIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes sutolTransitionSmoothOut {
  from { opacity: 1; }
  to { opacity: 0; }
}

@keyframes sutolTransitionSlide {
  from { opacity: 0; transform: translateY(22px) scale(0.985); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

@keyframes sutolTransitionZoom {
  from { opacity: 0; transform: scale(0.88); filter: blur(4px); }
  to { opacity: 1; transform: scale(1); filter: blur(0); }
}

@keyframes sutolTransitionConvex {
  from {
    opacity: 0;
    transform: rotateY(-18deg) translateX(44px) scale(0.96);
    transform-origin: left center;
  }
  to {
    opacity: 1;
    transform: rotateY(0) translateX(0) scale(1);
    transform-origin: left center;
  }
}

@keyframes sutolTransitionConcave {
  from {
    opacity: 0;
    transform: rotateY(18deg) translateX(-44px) scale(0.96);
    transform-origin: right center;
  }
  to {
    opacity: 1;
    transform: rotateY(0) translateX(0) scale(1);
    transform-origin: right center;
  }
}

@keyframes sutolTransitionWipe {
  from { clip-path: inset(0 100% 0 0); }
  to { clip-path: inset(0 0 0 0); }
}

@keyframes sutolTransitionSplit {
  from { clip-path: inset(0 50% 0 50%); }
  to { clip-path: inset(0 0 0 0); }
}

@keyframes sutolTransitionReveal {
  from { opacity: 0; transform: translateY(12%); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes sutolTransitionCover {
  from { transform: translateX(100%); }
  to { transform: translateX(0); }
}

@keyframes sutolTransitionUncover {
  from { opacity: 0; transform: translateX(-18%); }
  to { opacity: 1; transform: translateX(0); }
}

@keyframes sutolTransitionFlip {
  from { opacity: 0; transform: perspective(1400px) rotateY(-40deg); }
  to { opacity: 1; transform: perspective(1400px) rotateY(0); }
}

@media (max-width: 920px) {
  .sutol-export-nav {
    bottom: max(10px, env(safe-area-inset-bottom));
    gap: 0.4rem;
    padding: 0.45rem 0.55rem;
  }
}

@media (prefers-reduced-motion: reduce) {
  .sutol-export-slide.is-active {
    animation-name: none !important;
  }

  .sutol-export-stage-frame,
  .sutol-export-action,
  .sutol-export-dot,
  .sutol-export-stage [data-reveal-step] {
    transition: none !important;
  }
}
''';

String _exportScript({
  required bool zoomEnabled,
  required String revealCounts,
  required bool smoothTransition,
  required int transitionDurationMs,
}) =>
    '''
(() => {
  const zoomEnabled = $zoomEnabled;
  const revealCounts = $revealCounts;
  const smoothTransition = $smoothTransition;
  const transitionDurationMs = $transitionDurationMs;
  const shell = document.querySelector('.sutol-export-shell');
  const slides = Array.from(document.querySelectorAll('.sutol-export-slide'));
  const dots = Array.from(document.querySelectorAll('.sutol-export-dot'));
  const prevBtn = document.getElementById('sutolPrevBtn');
  const nextBtn = document.getElementById('sutolNextBtn');
  const fullscreenBtn = document.getElementById('sutolFullscreenBtn');
  const zoomBtn = document.getElementById('sutolZoomBtn');
  let index = 0;
  let fragmentStep = 0;
  let isZoomed = false;
  let leavingTimer = null;

  function orbitValue(element, key, fallback) {
    const value = Number(element?.dataset?.[key]);
    return Number.isFinite(value) ? value : fallback;
  }

  function beginSmoothTransition(fromIndex, toIndex) {
    if (!smoothTransition || fromIndex === toIndex) return;
    const outgoing = slides[fromIndex];
    const incoming = slides[toIndex];
    if (!outgoing || !incoming) return;

    slides.forEach((slide) => slide.classList.remove('is-leaving'));
    outgoing.classList.add('is-leaving');
    if (leavingTimer !== null) window.clearTimeout(leavingTimer);
    leavingTimer = window.setTimeout(() => {
      outgoing.classList.remove('is-leaving');
    }, transitionDurationMs + 80);

    const sourceGroups = new Map();
    outgoing.querySelectorAll('[data-sutol-model-id]').forEach((element) => {
      const id = element.dataset.sutolModelId;
      if (!sourceGroups.has(id)) sourceGroups.set(id, []);
      sourceGroups.get(id).push(element);
    });

    incoming.querySelectorAll('[data-sutol-model-id]').forEach((target) => {
      const matches = sourceGroups.get(target.dataset.sutolModelId) || [];
      const source = matches.shift();
      if (!source) return;

      const targetStyle = {
        left: target.style.left,
        top: target.style.top,
        width: target.style.width,
        height: target.style.height,
      };
      target.animate(
        [
          {
            left: source.style.left,
            top: source.style.top,
            width: source.style.width,
            height: source.style.height,
          },
          targetStyle,
        ],
        {
          duration: transitionDurationMs,
          easing: 'cubic-bezier(.65, 0, .35, 1)',
          fill: 'both',
        },
      );

      const viewer = target.querySelector('model-viewer');
      if (!viewer) return;
      const startTheta = orbitValue(source, 'sutolOrbitTheta', 0);
      const startPhi = orbitValue(source, 'sutolOrbitPhi', 75);
      const targetTheta = orbitValue(target, 'sutolOrbitTheta', 0);
      const targetPhi = orbitValue(target, 'sutolOrbitPhi', 75);
      const thetaDelta = ((targetTheta - startTheta + 540) % 360) - 180;
      const startedAt = performance.now();

      function animateOrbit(now) {
        const raw = Math.min(1, Math.max(0, (now - startedAt) / transitionDurationMs));
        const eased = raw < 0.5
          ? 4 * raw * raw * raw
          : 1 - Math.pow(-2 * raw + 2, 3) / 2;
        const theta = startTheta + thetaDelta * eased;
        const phi = startPhi + (targetPhi - startPhi) * eased;
        viewer.setAttribute('camera-orbit', theta.toFixed(2) + 'deg ' + phi.toFixed(2) + 'deg auto');
        if (raw < 1) requestAnimationFrame(animateOrbit);
      }

      viewer.setAttribute('camera-orbit', startTheta.toFixed(2) + 'deg ' + startPhi.toFixed(2) + 'deg auto');
      requestAnimationFrame(animateOrbit);
    });
  }

  function maxRevealFor(slideIndex) {
    return Number(revealCounts[slideIndex] || 0);
  }

  function activeFrame() {
    return slides[index]?.querySelector('.sutol-export-stage-frame') ?? null;
  }

  function renderZoomState() {
    shell?.classList.toggle('is-zoomed', zoomEnabled && isZoomed);
    if (zoomBtn) {
      const zoomLabel = isZoomed ? 'Zoomu kapat' : 'Zoom';
      zoomBtn.textContent = isZoomed ? '\u2296' : '\u2295';
      zoomBtn.setAttribute('aria-label', zoomLabel);
      zoomBtn.setAttribute('title', zoomLabel);
      zoomBtn.setAttribute('aria-pressed', isZoomed ? 'true' : 'false');
    }
  }

  function renderRevealState() {
    slides.forEach((slide, slideIndex) => {
      const active = slideIndex === index;
      const stepLimit = active ? fragmentStep : 0;
      const elements = Array.from(slide.querySelectorAll('[data-reveal-step]'));

      elements.forEach((element) => {
        const step = Number(element.dataset.revealStep || '0');
        const visible = step <= stepLimit;
        element.classList.toggle('is-reveal-visible', visible);
        element.classList.toggle('is-reveal-hidden', !visible);

        if (element.hasAttribute('data-hotspot-target')) {
          element.classList.toggle('is-hotspot-active', active && visible);
        }
      });

    });
  }

  function render() {
    if (slides.length === 0) {
      renderZoomState();
      return;
    }

    fragmentStep = Math.max(0, Math.min(fragmentStep, maxRevealFor(index)));

    slides.forEach((slide, slideIndex) => {
      const active = slideIndex === index;
      slide.classList.toggle('is-active', active);
      slide.setAttribute('aria-hidden', active ? 'false' : 'true');
    });
    dots.forEach((dot, dotIndex) => {
      const active = dotIndex === index;
      dot.classList.toggle('is-active', active);
      dot.setAttribute('aria-current', active ? 'true' : 'false');
    });
    renderRevealState();
    if (prevBtn) {
      const disabled = index === 0 && fragmentStep === 0;
      prevBtn.disabled = disabled;
      prevBtn.setAttribute('aria-disabled', disabled ? 'true' : 'false');
    }
    if (nextBtn) {
      const disabled = index >= slides.length - 1 && fragmentStep >= maxRevealFor(index);
      nextBtn.disabled = disabled;
      nextBtn.setAttribute('aria-disabled', disabled ? 'true' : 'false');
    }
    renderZoomState();
    window.SutolStageBackgrounds?.refresh?.();
    window.SutolStageComponents?.refresh?.();
  }

  function setZoomed(nextZoomed, clientX, clientY) {
    if (!zoomEnabled) return;
    const frame = activeFrame();
    isZoomed = Boolean(nextZoomed);

    if (frame && isZoomed && Number.isFinite(clientX) && Number.isFinite(clientY)) {
      const rect = frame.getBoundingClientRect();
      const originX = Math.max(0, Math.min(100, ((clientX - rect.left) / rect.width) * 100));
      const originY = Math.max(0, Math.min(100, ((clientY - rect.top) / rect.height) * 100));
      frame.style.setProperty('--sutol-zoom-origin-x', originX.toFixed(1) + '%');
      frame.style.setProperty('--sutol-zoom-origin-y', originY.toFixed(1) + '%');
    }

    renderZoomState();
  }

  function toggleZoom(clientX, clientY) {
    setZoomed(!isZoomed, clientX, clientY);
  }

  function goTo(nextIndex, revealStep = 0) {
    if (slides.length === 0) return;
    const next = Math.max(0, Math.min(nextIndex, slides.length - 1));
    if (next !== index) {
      setZoomed(false);
      beginSmoothTransition(index, next);
    }
    index = next;
    fragmentStep = Math.max(0, Math.min(revealStep, maxRevealFor(index)));
    render();
  }

  function goNext() {
    if (slides.length === 0) return;
    const maxStep = maxRevealFor(index);
    if (fragmentStep < maxStep) {
      fragmentStep += 1;
      setZoomed(false);
      render();
      return;
    }
    if (index < slides.length - 1) {
      goTo(index + 1);
    }
  }

  function goPrevious() {
    if (slides.length === 0) return;
    if (fragmentStep > 0) {
      fragmentStep -= 1;
      setZoomed(false);
      render();
      return;
    }
    if (index > 0) {
      const previousIndex = index - 1;
      goTo(previousIndex, maxRevealFor(previousIndex));
    }
  }

  function toggleFullscreen() {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen?.();
    } else {
      document.exitFullscreen?.();
    }
  }

  prevBtn?.addEventListener('click', goPrevious);
  nextBtn?.addEventListener('click', goNext);
  fullscreenBtn?.addEventListener('click', toggleFullscreen);
  zoomBtn?.addEventListener('click', () => toggleZoom(window.innerWidth / 2, window.innerHeight / 2));
  dots.forEach((dot) => {
    dot.addEventListener('click', () => goTo(Number(dot.dataset.index || '0'), 0));
  });
  document.querySelectorAll('[data-hotspot-target]').forEach((element) => {
    element.addEventListener('click', (event) => {
      const targetPageId = element.dataset.hotspotTarget;
      const slide = element.closest('.sutol-export-slide');
      const targetIndex = slides.findIndex((item) => item.dataset.pageId === targetPageId);

      event.preventDefault();
      event.stopPropagation();

      if (!slide?.classList.contains('is-active') ||
          element.classList.contains('is-reveal-hidden') ||
          targetIndex < 0) {
        return;
      }
      goTo(targetIndex, 0);
    });
  });
  slides.forEach((slide) => {
    const frame = slide.querySelector('.sutol-export-stage-frame');
    frame?.addEventListener('click', (event) => {
      if (!zoomEnabled || !slide.classList.contains('is-active')) return;
      toggleZoom(event.clientX, event.clientY);
    });
  });

  window.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowRight' || event.key === 'PageDown' || event.key === ' ' || event.code === 'Space') {
      event.preventDefault();
      goNext();
    }
    if (event.key === 'ArrowLeft' || event.key === 'PageUp' || event.key === 'Backspace') {
      event.preventDefault();
      goPrevious();
    }
    if (event.key.toLowerCase() === 'f') toggleFullscreen();
    if (event.key.toLowerCase() === 'z' || event.key === '+') {
      toggleZoom(window.innerWidth / 2, window.innerHeight / 2);
    }
    if (event.key === 'Escape') {
      setZoomed(false);
    }
  });

  render();
})();
''';
