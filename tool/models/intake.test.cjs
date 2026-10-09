const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {submit, approve, metadata, embeddedGlb, png} = require('./intake.cjs');
const root = path.resolve(__dirname, '../..');
const model = path.join(root, 'web/models/original-v1/bohr-atom-lite.glb');
const thumb = path.join(root, 'web/model_thumbnails/original-v1/bohr-atom.png');
function fixture(t) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'sutols-intake-'));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const file = path.join(directory, 'input.json');
  fs.writeFileSync(file, JSON.stringify({id: 'test-bohr', name: 'Bohr', category: 'Fizik',
      license: 'Test fixture only', source: 'Sutols original model', author: 'Sutols', tags: ['atom']}));
  return {directory, file};
}
test('valid asset remains in quarantine; explicit review creates an unpublished package', async t => {
  const {directory, file} = fixture(t);
  const result = await submit(file, model, thumb, directory);
  assert.equal(result.receipt.state, 'awaiting-review');
  assert.equal(result.receipt.triangles, 2640);
  assert.equal(fs.existsSync(path.join(directory, 'approved')), false);
  await assert.rejects(approve(result.destination, directory, 'Test reviewer', false, false), /visual review/);
  const accepted = await approve(result.destination, directory, 'Test reviewer', true, false, true);
  assert.equal(accepted.approval.publicationStatus, 'local-approved-unpublished');
  assert.equal(JSON.parse(fs.readFileSync(path.join(result.destination, 'receipt.json'))).state, 'awaiting-review');
  await assert.rejects(submit(file, model, thumb, directory), /EEXIST/);
});
test('changed model, thumbnail or metadata cannot reuse a validation receipt', async t => {
  const {directory, file} = fixture(t);
  const result = await submit(file, model, thumb, directory);
  fs.appendFileSync(path.join(result.destination, 'metadata.json'), ' ');
  await assert.rejects(approve(result.destination, directory, 'Reviewer', true, false, true), /changed after validation/);
});
test('missing rights metadata, traversal IDs, oversized or invalid files are rejected', async t => {
  assert.throws(() => metadata({id: '../escape'}), /metadata/);
  const {directory, file} = fixture(t);
  const raw = JSON.parse(fs.readFileSync(file));
  assert.throws(() => metadata({...raw, license: ''}), /license/);
  assert.throws(() => metadata({...raw, id: '../escape'}), /stable model ID/);
  assert.throws(() => embeddedGlb(Buffer.from('fake')), /GLB/);
  assert.throws(() => png(Buffer.from('fake')), /PNG/);
  const big = path.join(directory, 'oversized.glb');
  fs.writeFileSync(big, Buffer.alloc(8 * 1024 * 1024 + 1));
  await assert.rejects(submit(file, big, thumb, directory), /limit/);
});
test('GLB resources cannot trigger network or filesystem requests', () => {
  const json = Buffer.from(JSON.stringify({asset: {version: '2.0'},
      buffers: [{uri: 'https://example.com/model.bin', byteLength: 4}]}));
  const bytes = Buffer.alloc(20 + json.length);
  bytes.writeUInt32LE(0x46546c67, 0); bytes.writeUInt32LE(2, 4);
  bytes.writeUInt32LE(bytes.length, 8); bytes.writeUInt32LE(json.length, 12);
  bytes.writeUInt32LE(0x4e4f534a, 16); json.copy(bytes, 20);
  assert.throws(() => embeddedGlb(bytes), /resources/);
});
test('UI decisions bind to all asset hashes and require license review', async t => {
  const {applyReview} = require('./intake.cjs');
  const {directory, file} = fixture(t);
  const result = await submit(file, model, thumb, directory);
  const reviewFile = path.join(directory, 'review.json');
  const decision = {schema: 1, id: result.receipt.metadata.id, decision: 'accept',
      reviewer: 'Test reviewer', notes: 'Test fixture', visualReviewed: true,
      licenseReviewed: true, warningsReviewed: false,
      ...Object.fromEntries(['modelSha256', 'thumbnailSha256', 'metadataSha256']
          .map(k => [k, result.receipt[k]]))};
  fs.writeFileSync(reviewFile, JSON.stringify({...decision, licenseReviewed: false}));
  await assert.rejects(applyReview(reviewFile, result.destination, directory), /license review/);
  fs.writeFileSync(reviewFile, JSON.stringify({...decision, thumbnailSha256: 'bad'}));
  await assert.rejects(applyReview(reviewFile, result.destination, directory), /different submission/);
  fs.writeFileSync(reviewFile, JSON.stringify(decision));
  const accepted = await applyReview(reviewFile, result.destination, directory);
  assert.equal(accepted.approval.licenseReviewed, true);
  assert.equal(JSON.parse(fs.readFileSync(path.join(accepted.destination, 'review.json'))).decision, 'accept');
});
test('a rejection is an audit record and creates no approved asset', async t => {
  const {applyReview} = require('./intake.cjs');
  const {directory, file} = fixture(t);
  const result = await submit(file, model, thumb, directory);
  const reviewFile = path.join(directory, 'review.json');
  const decision = {schema: 1, id: result.receipt.metadata.id, decision: 'reject',
      reviewer: 'Test reviewer', notes: 'Visual rejected',
      ...Object.fromEntries(['modelSha256', 'thumbnailSha256', 'metadataSha256']
          .map(k => [k, result.receipt[k]]))};
  fs.writeFileSync(reviewFile, JSON.stringify(decision));
  const rejected = await applyReview(reviewFile, result.destination, directory);
  assert.equal(rejected.publicationStatus, 'local-rejected-unpublished');
  assert.equal(fs.existsSync(path.join(directory, 'approved')), false);
});
test('edited receipt labels cannot approve a different reviewed identity', async t => {
  const {directory, file} = fixture(t);
  const result = await submit(file, model, thumb, directory);
  const altered = {...result.receipt, metadata: {...result.receipt.metadata, name: 'Other object'}};
  fs.writeFileSync(path.join(result.destination, 'receipt.json'), JSON.stringify(altered));
  await assert.rejects(approve(result.destination, directory, 'Reviewer', true, false, true), /metadata does not match/);
});
