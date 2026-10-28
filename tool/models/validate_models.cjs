// Run npm ci in this directory, then npm run validate.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const validator = require('gltf-validator');
const root = path.resolve(__dirname, '../..');
(async () => {
 const records = JSON.parse(fs.readFileSync(path.join(root, 'web/models/original-v1/manifest.json')));
 const ids = new Set(), hashes = new Set(), reports = [];
 for (const record of records) {
  if (!record.id || ids.has(record.id) || !record.label || !record.labelEn || !record.category || !record.tags.length || !record.license) throw Error('Invalid metadata: '+record.id);
  ids.add(record.id);
  if (!fs.existsSync(path.join(root,'web', record.thumbnail))) throw Error('Missing thumbnail: '+record.id);
  if (Object.keys(record.variants).sort().join(',') !== 'lite,quality') throw Error('Both LODs required: '+record.id);
  for (const [variant, asset] of Object.entries(record.variants)) {
   const file = path.join(root, 'web', asset.path);
   const bytes = fs.readFileSync(file);
   const hash = crypto.createHash('sha256').update(bytes).digest('hex');
   if (hash !== asset.sha256 || bytes.length !== asset.bytes) throw Error('Manifest does not match '+file);
   if (hashes.has(hash)) throw Error('Duplicate asset: '+file);
   hashes.add(hash);
   if (bytes.length > 8 * 1024 * 1024) throw Error('Download budget exceeded: '+file);
   if (bytes.readUInt32LE(0) !== 0x46546c67 || bytes.readUInt32LE(12 + 4) !== 0x4e4f534a) throw Error('Expected GLB JSON chunk: '+file);
   const document = JSON.parse(bytes.subarray(20,20+bytes.readUInt32LE(12)).toString('utf8'));
   const primitives = document.meshes.flatMap(mesh=>mesh.primitives);
   if (primitives.some(p=>(p.mode ?? 4)!==4)) throw Error('Originals require triangle topology: '+file);
   const triangles = primitives.reduce((n,p)=>n+document.accessors[p.indices ?? p.attributes.POSITION].count/3,0);
   if (triangles!==asset.triangles || triangles>50000) throw Error('Triangle metadata/budget mismatch: '+file);
   const report = await validator.validateBytes(new Uint8Array(bytes), {uri:path.basename(file)});
   reports.push({id:record.id,variant,bytes:bytes.length,triangles:asset.triangles,issues:report.issues});
  }
 }
 const output = process.argv[2] || path.join(root, 'build/model-validation.json');
 fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,JSON.stringify(reports,null,2));
 const errors = reports.reduce((n,r)=>n+r.issues.numErrors,0);
 const warnings = reports.reduce((n,r)=>n+r.issues.numWarnings,0);
 console.log(JSON.stringify({models:records.length,variants:reports.length,errors,warnings,report:output}));
 if (errors || warnings) process.exitCode=1;
})().catch(error=>{console.error(error.message);process.exitCode=1;});
