import assert from 'node:assert/strict';
import { test } from 'node:test';
import fs from 'node:fs';
import vm from 'node:vm';
const source = fs.readFileSync(new URL('../lib/ui/widgets/html_stage/model_context_recovery_script.dart', import.meta.url), 'utf8').split("r'''")[1].split("'''")[0];
function fixture() {
  const listeners = new Map(), windowEvents = new Map(), attrs = new Map([['src', 'model.glb'], ['auto-rotate', '']]);
  const poster = { hidden: true }, failure = { hidden: false };
  const fallback = { hidden: true, querySelector: selector => selector === '.sutol-3d-context-poster' ? poster : failure }, status = { hidden: true, nextElementSibling: fallback, style: {}, setAttribute() {} };
  const canvas = { addEventListener: (name, fn) => listeners.set(name, fn), removeEventListener: (name, fn) => { if (listeners.get(name) === fn) listeners.delete(name); } };
  const model = { isConnected: true, nextElementSibling: status, style: {}, dataset: { sutolAnimationTime: '1.5' },
    getAttribute: key => attrs.get(key), setAttribute: (key, value) => attrs.set(key, value),
    removeAttribute: key => attrs.delete(key), hasAttribute: key => attrs.has(key),
    getCameraOrbit: () => ({ theta: .5, phi: 1, radius: 4 }), getCameraTarget: () => ({ x: 1, y: .5, z: 2 }),
    getFieldOfView: () => 51, turntableRotation: .7, currentTime: 1.5, animationName: 'RotorSpin', paused: false,
    pause() { this.paused = true; }, play() { this.paused = false; },
    resetTurntableRotation(value) { this.turntableRotation = value; }, jumpCameraToGoal() { this.jumped = true; },
    updateComplete: Promise.resolve(true) };
  const document = { hidden: false };
  const window = { addEventListener: (name, fn) => windowEvents.set(name, fn), SutolSceneLifecycle: { snapshot: () => ({ active: !document.hidden }) } };
  vm.runInNewContext(source, { window, document, Promise, Number });
  const error = { detail: { type: 'webglcontextlost', sourceError: { target: canvas } } };
  return { model, attrs, status, fallback, poster, failure, document, listeners, windowEvents, api: window.SutolModelContextRecovery, error,
    restore: async () => { listeners.get('webglcontextrestored')?.(); await Promise.resolve(); await Promise.resolve(); } };
}

test('native restoration preserves live camera, clip and rotation', async () => {
  const f = fixture(); assert.equal(f.api.handle(f.model, f.error), true);
  assert.equal(f.model.paused, true); assert.equal(f.fallback.hidden, false); assert.equal(f.model.style.opacity, '0');
  assert.equal(f.poster.hidden, false); assert.equal(f.failure.hidden, true);
  f.model.currentTime = 0; await f.restore();
  assert.equal(f.model.currentTime, 1.5); assert.equal(f.model.cameraOrbit, '.5rad 1rad 4m'.replace('.5rad', '0.5rad'));
  assert.equal(f.model.cameraTarget, '1m 0.5m 2m'); assert.equal(f.model.fieldOfView, '51deg');
  assert.equal(f.model.turntableRotation, .7); assert.equal(f.model.paused, false);
  assert.equal(f.model.jumped, true); assert.equal(f.fallback.hidden, true); assert.equal(f.status.hidden, true); assert.equal(f.listeners.size, 0);
  assert.equal(f.poster.hidden, true); assert.equal(f.failure.hidden, false);
});
test('paused clip stays paused and duplicate loss retains first snapshot', async () => {
  const f = fixture(); f.model.paused = true;
  f.api.handle(f.model, f.error); f.model.currentTime = 0; f.api.handle(f.model, f.error);
  await f.restore(); assert.equal(f.model.currentTime, 1.5); assert.equal(f.model.paused, true);
});
test('changed source invalidates a pending restoration', async () => {
  const f = fixture(); f.api.handle(f.model, f.error); f.attrs.set('src', 'new.glb'); f.model.currentTime = 7;
  await f.restore(); assert.equal(f.model.currentTime, 7); assert.equal(f.model.jumped, undefined);
  f.api.loaded(f.model); assert.equal(f.listeners.size, 0); assert.equal(f.model.style.opacity, '');
});
test('new load supersedes a delayed clip seek', async () => {
  const f = fixture(); let resolve; f.model.updateComplete = new Promise(done => resolve = done);
  f.api.loaded(f.model); f.attrs.set('src', 'new.glb'); f.model.currentTime = 7;
  resolve(true); await Promise.resolve(); await Promise.resolve(); assert.equal(f.model.currentTime, 7);
});
test('restored hidden scene defers playing and rotation to lifecycle', async () => {
  const f = fixture(); f.api.handle(f.model, f.error); f.document.hidden = true;
  await f.restore(); assert.equal(f.model.paused, true); assert.equal(f.attrs.has('auto-rotate'), false);
  assert.equal(f.attrs.has('data-sutol-context-resume-playing'), true); assert.equal(f.attrs.has('data-sutol-context-resume-rotating'), true);
});
test('ordinary model error remains in original error flow', () => {
  const f = fixture(); assert.equal(f.api.handle(f.model, { detail: { type: 'loadfailure' } }), false); assert.equal(f.listeners.size, 0);
});
test('page disposal cancels native callbacks and pending seeks', async () => {
  const f = fixture(); f.api.handle(f.model, f.error); const stale = f.listeners.get('webglcontextrestored');
  f.windowEvents.get('pagehide')({ persisted: false }); stale(); await Promise.resolve();
  assert.equal(f.listeners.size, 0); assert.equal(f.model.jumped, undefined);
});
