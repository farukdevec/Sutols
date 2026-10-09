const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const validator = require('gltf-validator');
(async () => {
  if (!process.argv[2]) throw Error('Usage: node validate_visual_pilots.cjs pilot-directory');
  const directory = path.resolve(process.argv[2]);
  const manifest = JSON.parse(fs.readFileSync(path.join(directory, 'pilot-manifest.json')));
  const records = [];
  for (const model of manifest) for (const [variant, asset] of Object.entries(model.variants)) {
    if (path.basename(asset.file) !== asset.file) throw Error('Asset must be inside pilot directory');
    const bytes = fs.readFileSync(path.join(directory, asset.file));
    if (bytes.length !== asset.bytes || crypto.createHash('sha256').update(bytes).digest('hex') !== asset.sha256)
      throw Error('Manifest identity differs: ' + asset.file);
    const report = await validator.validateBytes(new Uint8Array(bytes), {uri: asset.file});
    const gltf = JSON.parse(bytes.subarray(20, 20 + bytes.readUInt32LE(12)).toString('utf8'));
    const actual = {animations: (gltf.animations || []).length, skins: (gltf.skins || []).length,
      textures: (gltf.textures || []).length,
      alphaBlendMaterials: (gltf.materials || []).filter(m => m.alphaMode === 'BLEND').length};
    for (const key of Object.keys(actual)) if (asset[key] !== actual[key]) throw Error('Feature count differs: ' + asset.file);
    if (model.id === 'rigged-wind-turbine' && (actual.skins !== 1 || actual.animations !== 1))
      throw Error('Expected exactly one skin and animation');
    if (model.id === 'alpha-texture-laboratory' && (actual.textures !== 1 || actual.alphaBlendMaterials !== 1))
      throw Error('Expected one texture and one blended material');
    records.push({id: model.id, variant, asset, issues: report.issues});
  }
  fs.writeFileSync(path.join(directory, 'pilot-validation.json'), JSON.stringify(records, null, 2));
  const result = {files: records.length, errors: records.reduce((n,r) => n+r.issues.numErrors,0),
    warnings: records.reduce((n,r) => n+r.issues.numWarnings,0)};
  console.log(JSON.stringify(result));
  if (result.errors || result.warnings) process.exitCode = 1;
})().catch(error => {console.error(error.message); process.exitCode = 1;});
