import assert from 'node:assert/strict';
import { test } from 'node:test';
import fs from 'node:fs';
import vm from 'node:vm';
const source = fs.readFileSync(new URL('../lib/ui/widgets/html_stage/model_render_budget_script.dart', import.meta.url), 'utf8').split("r'''")[1].split("'''")[0];
function budget(floor, defined = Promise.resolve()) {
  const events = new Map();
  class ModelViewer { static minimumRenderScale = .5; }
  const document = { addEventListener: (name, cb) => events.set(name, cb), removeEventListener: name => events.delete(name) };
  const window = { customElements: { get: () => ModelViewer, whenDefined: () => defined },
    addEventListener: (name, cb) => events.set(name, cb), removeEventListener: name => events.delete(name) };
  vm.runInNewContext(source.replace('MINIMUM_RENDER_SCALE', String(floor)), { window, document });
  return { window, events, ModelViewer };
}
test('definition applies budget without scheduling another render loop', async () => {
  for (const floor of [.4, .5, .79]) {
    const s = budget(floor);
    await Promise.resolve();
    assert.equal(s.ModelViewer.minimumRenderScale, floor);
    assert.equal(s.window.SutolModelRenderBudget.snapshot().minimumRenderScale, floor);
  }
});
test('render-scale telemetry is bounded and rejects invalid event details', async () => {
  const s = budget(.4); await Promise.resolve();
  const event = { target: { localName: 'model-viewer' }, detail: {
    renderedDpr: 1, pixelWidth: 320, pixelHeight: 180, reason: 'GPU throttling' } };
  s.events.get('render-scale')(event);
  const copy = s.window.SutolModelRenderBudget.snapshot();
  assert.equal(copy.lastScale.pixelWidth, 320);
  copy.lastScale.pixelWidth = 0;
  assert.equal(s.window.SutolModelRenderBudget.snapshot().lastScale.pixelWidth, 320);
  s.events.get('render-scale')({ ...event, detail: { renderedDpr: NaN } });
  assert.equal(s.window.SutolModelRenderBudget.snapshot().lastScale.pixelWidth, 320);
});
test('BFCache keeps policy while disposal cleans listeners and ignores late definition', async () => {
  let resolve;
  const definition = new Promise(r => resolve = r);
  const s = budget(.79, definition);
  s.events.get('pagehide')({ persisted: true });
  assert.equal(s.window.SutolModelRenderBudget.snapshot().disposed, false);
  s.events.get('pagehide')({ persisted: false });
  resolve(); await Promise.resolve();
  assert.equal(s.ModelViewer.minimumRenderScale, .5);
  assert.equal(s.events.size, 0);
  assert.equal(s.window.SutolModelRenderBudget.snapshot().disposed, true);
});
