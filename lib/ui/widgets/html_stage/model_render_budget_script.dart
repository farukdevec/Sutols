import '../../../models/slide_model.dart';
import '../../../services/model_render_budget.dart';

String modelRenderBudgetScript(PresentationRenderQuality quality) =>
    _modelBudgetScript.replaceAll(
        'MINIMUM_RENDER_SCALE', modelMinimumRenderScale(quality).toString());

// No additional RAF loop: model-viewer owns measurement and hysteresis.
const String _modelBudgetScript = r'''
(function () {
  if (window.SutolModelRenderBudget || !window.customElements) return;
  const floor = MINIMUM_RENDER_SCALE;
  let lastScale = null, disposed = false;
  function onScale(event) {
    if (!event.target || event.target.localName !== 'model-viewer') return;
    const d = event.detail || {};
    if (![d.renderedDpr, d.pixelWidth, d.pixelHeight].every(Number.isFinite)) return;
    lastScale = { renderedDpr: d.renderedDpr, pixelWidth: d.pixelWidth,
      pixelHeight: d.pixelHeight, reason: typeof d.reason === 'string' ? d.reason : '' };
  }
  document.addEventListener('render-scale', onScale, true);
  window.customElements.whenDefined('model-viewer').then(function () {
    if (disposed) return;
    const ModelViewer = window.customElements.get('model-viewer');
    if (ModelViewer && 'minimumRenderScale' in ModelViewer) {
      ModelViewer.minimumRenderScale = floor;
    }
  });
  function onHide(event) {
    if (event.persisted) return;
    disposed = true;
    document.removeEventListener('render-scale', onScale, true);
    window.removeEventListener('pagehide', onHide);
  }
  window.addEventListener('pagehide', onHide);
  window.SutolModelRenderBudget = {
    snapshot: function () { return { minimumRenderScale: floor,
      lastScale: lastScale && Object.assign({}, lastScale), disposed: disposed }; }
  };
})();
''';
