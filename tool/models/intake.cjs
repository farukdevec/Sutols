// Offline model admission. It never writes to the live catalog or Firestore.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const validator = require('gltf-validator');
const root = path.resolve(__dirname, '../..');
const MAX_GLB = 8 * 1024 * 1024;
const MAX_PNG = 2 * 1024 * 1024;
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const writeJson = (file, value) => fs.writeFileSync(file, JSON.stringify(value, null, 2) + '\n');
function readBounded(file, maximum) {
  const stat = fs.statSync(file);
  if (!stat.isFile() || stat.size > maximum) throw Error('File exceeds admission limit: ' + file);
  return fs.readFileSync(file);
}
function metadata(raw) {
  const required = ['id', 'name', 'category', 'license', 'source', 'author'];
  for (const key of required) {
    if (typeof raw[key] !== 'string' || !raw[key].trim() || raw[key].length > 2000)
      throw Error('Missing or invalid metadata: ' + key);
  }
  if (!/^[a-z][a-z0-9-]{2,79}$/.test(raw.id)) throw Error('Invalid stable model ID');
  const result = Object.fromEntries(required.map(k => [k, raw[k].trim()]));
  for (const key of ['tags', 'tagsEn', 'excludeTags']) {
    const values = raw[key] ?? [];
    if (!Array.isArray(values) || values.length > 40 ||
        values.some(v => typeof v !== 'string' || !v.trim() || v.length > 100))
      throw Error('Invalid tag list: ' + key);
    result[key] = [...new Set(values.map(v => v.trim()))];
  }
  if (!result.tags.length) throw Error('At least one concrete Turkish tag is required');
  return result;
}
function embeddedGlb(bytes) {
  if (bytes.length < 20 || bytes.readUInt32LE(0) !== 0x46546c67 ||
      bytes.readUInt32LE(4) !== 2 || bytes.readUInt32LE(8) !== bytes.length ||
      bytes.readUInt32LE(16) !== 0x4e4f534a)
    throw Error('Expected a complete GLB 2.0');
  const jsonLength = bytes.readUInt32LE(12);
  if (jsonLength > bytes.length - 20) throw Error('Truncated GLB JSON');
  const gltf = JSON.parse(bytes.subarray(20, 20 + jsonLength).toString('utf8'));
  // No download callbacks: all resources must be contained in this GLB.
  for (const resource of [...(gltf.buffers ?? []), ...(gltf.images ?? [])]) {
    if (resource.uri != null) throw Error('External or data-URI resources require an embedded GLB');
  }
}
function png(bytes) {
  if (bytes.length < 33 || bytes.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a' ||
      bytes.subarray(12, 16).toString('ascii') !== 'IHDR') throw Error('PNG thumbnail required');
  const width = bytes.readUInt32BE(16), height = bytes.readUInt32BE(20);
  if (width < 128 || height < 128 || width > 2048 || height > 2048)
    throw Error('Thumbnail dimensions must be 128–2048px');
  return {width, height};
}
async function inspect(glb, thumbnail) {
  embeddedGlb(glb);
  const thumbnailDimensions = png(thumbnail);
  const report = await validator.validateBytes(new Uint8Array(glb), {
    uri: 'model.glb', maxIssues: 1000,
  });
  const triangles = report.info?.totalTriangleCount;
  const blockers = [];
  if (report.issues.numErrors) blockers.push('Khronos validation errors');
  if (!report.info?.hasDefaultScene || !report.info?.drawCallCount) blockers.push('Renderable default scene required');
  if (!Number.isFinite(triangles) || triangles > 50000) blockers.push('Triangle budget exceeded or unknown');
  return {report, blockers, thumbnailDimensions, triangles};
}
async function submit(metadataFile, modelFile, thumbnailFile, directory) {
  const meta = metadata(JSON.parse(readBounded(metadataFile, 65536).toString('utf8')));
  const glb = readBounded(modelFile, MAX_GLB), thumbnail = readBounded(thumbnailFile, MAX_PNG);
  const inspected = await inspect(glb, thumbnail);
  const digest = sha(glb);
  const destination = path.join(directory, 'quarantine', meta.id, digest);
  fs.mkdirSync(path.dirname(destination), {recursive: true});
  fs.mkdirSync(destination); // Existing submissions are immutable, never overwritten.
  fs.writeFileSync(path.join(destination, 'model.glb'), glb);
  fs.writeFileSync(path.join(destination, 'thumbnail.png'), thumbnail);
  writeJson(path.join(destination, 'metadata.json'), meta);
  writeJson(path.join(destination, 'validation.json'), inspected.report);
  const receipt = {
    schema: 1, state: inspected.blockers.length ? 'rejected' : 'awaiting-review',
    submittedAt: new Date().toISOString(), metadata: meta,
    modelSha256: digest, thumbnailSha256: sha(thumbnail),
    metadataSha256: sha(fs.readFileSync(path.join(destination, 'metadata.json'))),
    bytes: glb.length, triangles: inspected.triangles,
    thumbnailDimensions: inspected.thumbnailDimensions,
    blockers: inspected.blockers, warnings: inspected.report.issues.numWarnings,
    publicationStatus: 'local-quarantine-only',
  };
  writeJson(path.join(destination, 'receipt.json'), receipt);
  return {destination, receipt};
}
async function approve(submission, directory, reviewer, visualReviewed, warningsReviewed, licenseReviewed) {
  if (!reviewer?.trim() || reviewer.length > 200 || !visualReviewed || !licenseReviewed)
    throw Error('Approval requires a named reviewer and explicit visual review and license review');
  const receipt = JSON.parse(readBounded(path.join(submission, 'receipt.json'), 65536));
  if (receipt.state !== 'awaiting-review') throw Error('Submission is not awaiting review');
  const glb = readBounded(path.join(submission, 'model.glb'), MAX_GLB);
  const thumbnail = readBounded(path.join(submission, 'thumbnail.png'), MAX_PNG);
  const metadataBytes = readBounded(path.join(submission, 'metadata.json'), 65536);
  if (sha(glb) !== receipt.modelSha256 || sha(thumbnail) !== receipt.thumbnailSha256 ||
      sha(metadataBytes) !== receipt.metadataSha256) throw Error('Submission changed after validation');
  const meta = metadata(JSON.parse(metadataBytes.toString('utf8')));
  if (JSON.stringify(meta) !== JSON.stringify(metadata(receipt.metadata)))
    throw Error('Receipt metadata does not match the verified model');
  const inspected = await inspect(glb, thumbnail); // Never trust an edited validation.json.
  if (inspected.blockers.length) throw Error(inspected.blockers.join('; '));
  if (inspected.report.issues.numWarnings && !warningsReviewed)
    throw Error('Validation warnings must be reviewed explicitly');
  const destination = path.join(directory, 'approved', meta.id, receipt.modelSha256);
  fs.mkdirSync(path.dirname(destination), {recursive: true});
  fs.mkdirSync(destination);
  for (const name of ['model.glb', 'thumbnail.png', 'metadata.json'])
    fs.copyFileSync(path.join(submission, name), path.join(destination, name));
  const approval = {...receipt, metadata: meta, bytes: glb.length, triangles: inspected.triangles,
    thumbnailDimensions: inspected.thumbnailDimensions, warnings: inspected.report.issues.numWarnings,
    state: 'approved', reviewer: reviewer.trim(),
    approvedAt: new Date().toISOString(), visualReviewed: true, licenseReviewed: true,
    warningsReviewed: !!warningsReviewed, publicationStatus: 'local-approved-unpublished'};
  writeJson(path.join(destination, 'validation.json'), inspected.report);
  writeJson(path.join(destination, 'approval.json'), approval);
  // Quarantine receipt remains an immutable audit record.
  return {destination, approval};
}
async function applyReview(reviewFile, submission, directory) {
  const review = JSON.parse(readBounded(reviewFile, 65536).toString('utf8'));
  const receipt = JSON.parse(readBounded(path.join(submission, 'receipt.json'), 65536));
  if (review.schema !== 1 || review.id !== receipt.metadata?.id ||
      !['accept', 'reject'].includes(review.decision) ||
      typeof review.reviewer !== 'string' || !review.reviewer.trim() ||
      review.reviewer.length > 200 || typeof review.notes !== 'string' || review.notes.length > 4000)
    throw Error('Invalid review decision');
  for (const key of ['modelSha256', 'thumbnailSha256', 'metadataSha256'])
    if (review[key] !== receipt[key]) throw Error('Decision belongs to a different submission');
  if (review.decision === 'accept') {
    const result = await approve(submission, directory, review.reviewer,
      review.visualReviewed === true, review.warningsReviewed === true, review.licenseReviewed === true);
    writeJson(path.join(result.destination, 'review.json'), review);
    return result;
  }
  const destination = path.join(directory, 'reviews', receipt.metadata.id, receipt.modelSha256);
  fs.mkdirSync(destination, {recursive: true});
  const file = path.join(destination, sha(fs.readFileSync(reviewFile)) + '.json');
  fs.writeFileSync(file, JSON.stringify({...review, publicationStatus: 'local-rejected-unpublished'}, null, 2), {flag: 'wx'});
  return {destination: file, decision: 'reject', publicationStatus: 'local-rejected-unpublished'};
}
module.exports = {submit, approve, metadata, embeddedGlb, png, applyReview};
if (require.main === module) {
  (async () => {
    const {positionals, values} = require('node:util').parseArgs({
      allowPositionals: true,
      options: {directory: {type: 'string'},
        'visual-reviewed': {type: 'boolean'}, 'warnings-reviewed': {type: 'boolean'}, 'license-reviewed': {type: 'boolean'}},
    });
    const [command, ...args] = positionals;
    const directory = path.resolve(values.directory || path.join(root, 'build/model-intake'));
    let result;
    if (command === 'submit' && args.length === 3) {
      result = await submit(args[0], args[1], args[2], directory);
      if (result.receipt.state === 'rejected') process.exitCode = 1;
    } else if (command === 'approve' && args.length === 2) {
      result = await approve(path.resolve(args[0]), directory, args[1],
          values['visual-reviewed'], values['warnings-reviewed'], values['license-reviewed']);
    } else if (command === 'review' && args.length === 2) {
      result = await applyReview(args[0], path.resolve(args[1]), directory);
    } else throw Error('Usage: node intake.cjs submit metadata.json model.glb thumbnail.png [--directory path]\n' +
        '       node intake.cjs approve submission reviewer --visual-reviewed --license-reviewed [--directory path] [--warnings-reviewed]\n' + '       node intake.cjs review decision.json submission [--directory path]');
    console.log(JSON.stringify(result, null, 2));
  })().catch(e => { console.error(e.message); process.exitCode = 1; });
}
