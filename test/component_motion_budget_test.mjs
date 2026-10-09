import assert from 'node:assert/strict';
import {test} from 'node:test';
import fs from 'node:fs';
import vm from 'node:vm';
const catalog = fs.readFileSync(new URL('../lib/models/presentation_component_catalog.dart', import.meta.url), 'utf8');
test('library preview forces reduced JS motion and retains unrelated media queries', () => {
  const dart = fs.readFileSync(new URL('../lib/ui/widgets/html_stage/html_stage_document.dart', import.meta.url), 'utf8');
  const preview = dart.split('String buildHtmlComponentPreviewDocument')[1].split('<script>')[1].split('</script>')[0];
  const frames = scheduler();
  const nativeQuery = {matches: false, native: true};
  const window = {requestAnimationFrame: frames.request, matchMedia: () => nativeQuery};
  const media = fs.readFileSync(new URL('../lib/ui/widgets/html_stage/reduced_motion_script.dart', import.meta.url), 'utf8').split("r'''")[1].split("'''")[0];
  vm.runInNewContext(preview.replace('$sutolReducedMotionMediaScript', media), {window});
  assert.equal(window.matchMedia('(prefers-reduced-motion: reduce)').matches, true);
  assert.equal(window.matchMedia('(prefers-reduced-motion: no-preference)').matches, false);
  assert.equal(window.matchMedia('(max-width: 500px)'), nativeQuery);
  let calls = 0;
  function draw() {calls++; window.requestAnimationFrame(draw);}
  window.requestAnimationFrame(draw);
  for (let i = 0; i < 10; i++) frames.frame(i);
  assert.equal(calls, 4);
});
function script(kind) {
  const definition = catalog.split(`kind: PresentationComponentKind.${kind},`)[1].split("html: r'''")[1].split("'''", 1)[0];
  return definition.match(/<script>([\s\S]*?)<\/script>/)[1];
}
function scheduler() {
  let sequence = 0;
  const pending = new Map();
  return {pending, request: callback => {const id = ++sequence; pending.set(id, callback); return id;},
    frame(time) {const batch = [...pending.values()]; pending.clear(); batch.forEach(cb => cb(time));}};
}
function galton(reduced = false) {
  const frames = scheduler(), animations = [];
  function node() {
    return {isConnected: true, children: [], attrs: {},
      setAttribute(key, value) {this.attrs[key] = value;},
      appendChild(child) {child.parentNode = this; this.children.push(child);},
      removeChild(child) {this.children.splice(this.children.indexOf(child), 1); child.parentNode = null;},
      querySelectorAll() {return this.children;},
      animate() {const animation = {}; animations.push(animation); return animation;}};
  }
  const pins = node(), bins = node(), balls = node();
  vm.runInNewContext(script('matematik39'), {
    window: {matchMedia: () => ({matches: reduced})},
    document: {querySelector: s => s.endsWith('pins') ? pins : s.endsWith('bins') ? bins : balls,
      createElementNS: node}, requestAnimationFrame: frames.request,
    setTimeout() {throw Error('unexpected independent timeout');},
    setInterval() {throw Error('unexpected independent interval');},
  });
  return {frames, animations, bins, balls};
}
test('Galton produces bounded balls on scene frames and cleans up on animation completion', () => {
  const s = galton();
  s.frames.frame(0); assert.equal(s.balls.children.length, 1);
  s.frames.frame(499); assert.equal(s.balls.children.length, 1);
  s.frames.frame(500); assert.equal(s.balls.children.length, 2);
  s.animations[0].onfinish(); assert.equal(s.balls.children.length, 1);
  // A delayed frame creates one ball, never an elapsed-time catch-up burst.
  s.frames.frame(50000); assert.equal(s.balls.children.length, 2);
  s.balls.isConnected = false; s.frames.frame(50500);
  assert.equal(s.frames.pending.size, 0);
});
test('reduced motion shows the Galton distribution without balls or repeating work', () => {
  const s = galton(true);
  assert.equal(s.bins.children.length, 7);
  assert.ok(s.bins.children.some(b => Number(b.attrs.height) > 0));
  assert.equal(s.balls.children.length, 0);
  assert.equal(s.frames.pending.size, 0);
});
test('reduced starfield draws once and only redraws on resize, coalescing resize events', () => {
  const frames = scheduler(); let draws = 0, resize;
  const ctx = {clearRect() {draws++;}, beginPath() {}, arc() {}, fill() {}};
  const canvas = {getContext: () => ctx};
  const root = {isConnected: true, querySelector: () => canvas,
    getBoundingClientRect: () => ({width: 400, height: 200})};
  class ResizeObserver {constructor(callback) {resize = callback;} observe() {}}
  vm.runInNewContext(script('astronomi04'), {
    window: {matchMedia: () => ({matches: true}), ResizeObserver}, ResizeObserver,
    document: {getElementById: () => root}, requestAnimationFrame: frames.request,
    setTimeout() {throw Error('unexpected reduced-motion timer');},
  });
  frames.frame(0); assert.equal(draws, 1); assert.equal(frames.pending.size, 0);
  resize(); resize(); assert.equal(frames.pending.size, 1);
  frames.frame(1000); assert.equal(draws, 2); assert.equal(frames.pending.size, 0);
});
