import assert from 'node:assert/strict';
import { test } from 'node:test';
import fs from 'node:fs';
import vm from 'node:vm';

const source = fs.readFileSync(new URL('../lib/ui/widgets/html_stage/scene_lifecycle_script.dart', import.meta.url), 'utf8').split("r'''")[1].split("'''")[0];
function scene(hidden = false) {
  const callbacks = new Map(), events = new Map(), attrs = new Map();
  let time = 100, id = 0, intersection;
  const animation = { playState: 'running', pause() { this.playState = 'paused'; }, play() { this.playState = 'running'; } };
  const model = { isConnected: true, paused: false, currentTime: 3,
    hasAttribute: (key) => attrs.has(key),
    removeAttribute: (key) => attrs.delete(key), setAttribute: (key, value) => attrs.set(key, value),
    pause() { this.paused = true; }, play() { this.paused = false; } };
  attrs.set('auto-rotate', '');
  const listen = (name, fn) => events.set(name, fn);
  const document = { hidden, readyState: 'complete',
    documentElement: { setAttribute() {} },
    addEventListener: listen, removeEventListener: (name) => events.delete(name),
    getAnimations: () => [animation], querySelectorAll: (selector) => selector === 'model-viewer' ? [model] : [] };
  const window = { parent: {}, requestAnimationFrame: (fn) => { callbacks.set(++id, fn); return id; },
    cancelAnimationFrame: (key) => callbacks.delete(key), addEventListener: listen,
    removeEventListener: (name) => events.delete(name) };
  class IntersectionObserver { constructor(fn) { intersection = fn; } observe() {} disconnect() {} }
  vm.runInNewContext(source, { window, document, performance: { now: () => time }, IntersectionObserver });
  return { window, document, animation, model, attrs, callbacks,
    advance(amount) { time += amount; },
    frame() { const pending = [...callbacks.values()]; callbacks.clear(); pending.forEach(fn => fn(time)); },
    event(name, data) { events.get(name)?.(data); },
    intersection(value) { intersection([{ isIntersecting: value }]); } };
}

test('hidden scene stops drawing and resumes without a time jump', () => {
  const s = scene(), times = [];
  const draw = (time) => { times.push(time); s.window.requestAnimationFrame(draw); };
  s.window.requestAnimationFrame(draw); s.frame();
  s.document.hidden = true; s.event('visibilitychange');
  assert.equal(s.callbacks.size, 0);
  assert.equal(s.model.paused, true); assert.equal(s.animation.playState, 'paused');
  s.advance(5000); s.frame(); assert.equal(times.length, 1);
  s.document.hidden = false; s.event('visibilitychange'); s.advance(16); s.frame();
  assert.deepEqual(times, [100, 116]);
  assert.equal(s.model.currentTime, 3); assert.equal(s.model.paused, false);
  assert.equal(s.attrs.has('auto-rotate'), true);
});

test('cancellation while suspended does not replay a callback', () => {
  const s = scene(true);
  let called = false;
  const id = s.window.requestAnimationFrame(() => { called = true; });
  s.window.cancelAnimationFrame(id);
  s.document.hidden = false; s.event('visibilitychange'); s.frame();
  assert.equal(called, false); assert.equal(s.callbacks.size, 0);
});

test('offscreen observer and trusted parent controls cooperate', () => {
  const s = scene(); s.intersection(false);
  s.window.requestAnimationFrame(() => {}); assert.equal(s.callbacks.size, 0);
  s.event('message', { source: {}, data: { type: 'sutol-scene-active', active: true } });
  assert.equal(s.callbacks.size, 0);
  s.intersection(true); assert.equal(s.callbacks.size, 1);
  s.event('message', { source: s.window.parent, data: { type: 'sutol-scene-active', active: false } });
  assert.equal(s.callbacks.size, 0);
});

test('bfcache resumes; final unload disposes pending work', () => {
  const s = scene(); s.window.requestAnimationFrame(() => {});
  s.event('pagehide', { persisted: true }); assert.equal(s.callbacks.size, 0);
  s.event('pageshow', { persisted: true }); assert.equal(s.callbacks.size, 1);
  s.event('pagehide', { persisted: false }); assert.equal(s.callbacks.size, 0);
  assert.equal(s.window.SutolSceneLifecycle.snapshot().disposed, true);
});

test('user-paused animations are not resumed by lifecycle', () => {
  const s = scene(); s.model.paused = true; s.animation.playState = 'paused';
  s.intersection(false); s.intersection(true);
  assert.equal(s.model.paused, true); assert.equal(s.animation.playState, 'paused');
});


test('model loaded while suspended stays paused until scene resumes', () => {
  const s = scene(); s.model.paused = true;
  s.intersection(false);
  s.model.paused = false; s.attrs.set('auto-rotate','');
  s.event('load');
  assert.equal(s.model.paused,true); assert.equal(s.attrs.has('auto-rotate'),false);
  s.intersection(true);
  assert.equal(s.model.paused,false); assert.equal(s.attrs.has('auto-rotate'),true);
});

test('scene activation cannot restart a model while its context is lost', () => {
  const s = scene(); s.window.SutolSceneLifecycle.setActive(false);
  s.attrs.set('data-sutol-context-lost', 'true');
  s.window.SutolSceneLifecycle.setActive(true);
  assert.equal(s.model.paused, true); assert.equal(s.attrs.has('auto-rotate'), false);
});
test('model restored while hidden resumes its saved playing and rotation intent', () => {
  const s = scene(); s.model.paused = true; s.attrs.delete('auto-rotate');
  s.window.SutolSceneLifecycle.setActive(false);
  s.attrs.set('data-sutol-context-resume-playing', 'true');
  s.attrs.set('data-sutol-context-resume-rotating', 'true');
  s.window.SutolSceneLifecycle.setActive(true);
  assert.equal(s.model.paused, false); assert.equal(s.attrs.has('auto-rotate'), true);
  assert.equal(s.attrs.has('data-sutol-context-resume-playing'), false);
});
