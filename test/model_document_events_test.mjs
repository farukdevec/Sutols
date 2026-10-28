import assert from 'node:assert/strict';
import {test} from 'node:test';
import fs from 'node:fs';
import vm from 'node:vm';

const dart = fs.readFileSync(new URL('../lib/ui/widgets/html_stage/html_stage_document.dart', import.meta.url), 'utf8');
const handlers = dart.match(/<model-viewer[^\n]*?onload="([^"]+)" onerror="([^"]+)"/);
assert.ok(handlers, 'model handlers must remain inspectable');
const load = new vm.Script(`(function(event){${handlers[1]}})`);
const error = new vm.Script(`(function(event){${handlers[2]}})`);
function fixture() {
  const fallback = {hidden: true};
  const status = {hidden: false, nextElementSibling: fallback};
  const model = {hidden: false, currentTime: 0, nextElementSibling: status,
    dataset: {sutolModelId: 'current'}, getAttribute: () => '/current.glb'};
  let restores = 0;
  const context = vm.createContext({$safeAnimationTime: 2.5,
    window: {SutolRestoreModelCamera: () => restores++},
    console: {log() {}, error() {}}});
  return {model, status, fallback, context, restores: () => restores};
}
test('load failure handler is valid JavaScript and reveals its fallback', () => {
  const f = fixture();
  error.runInContext(f.context).call(f.model, {detail: {type: 'loadfailure'}});
  assert.equal(f.model.hidden, true);
  assert.equal(f.status.hidden, true);
  assert.equal(f.fallback.hidden, false);
});
test('late load event cannot restore the camera or hide the current status', () => {
  const f = fixture();
  load.runInContext(f.context).call(f.model, {detail: {url: '/previous.glb'}});
  assert.equal(f.restores(), 0);
  assert.equal(f.status.hidden, false);
  assert.equal(f.model.currentTime, 0);
  load.runInContext(f.context).call(f.model, {detail: {url: '/current.glb'}});
  assert.equal(f.restores(), 1);
  assert.equal(f.status.hidden, true);
  assert.equal(f.model.currentTime, 2.5);
});
