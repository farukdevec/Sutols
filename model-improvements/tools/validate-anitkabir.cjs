const fs=require('fs'),validator=require('/tmp/sutols-model-qa/node_modules/gltf-validator');
const root='model-improvements/reports/533a4fd62f2b3444/';
const build=JSON.parse(fs.readFileSync(root+'candidate-build.json'));
(async()=>{for(const [name,file] of [['before','web/models/anitkabir.glb'],['after',build.candidatePath]]){const r=await validator.validateBytes(new Uint8Array(fs.readFileSync(file)),{maxIssues:10000});fs.writeFileSync(root+'validator-'+name+'.json',JSON.stringify(r,null,2));console.log(name,JSON.stringify({errors:r.issues.numErrors,warnings:r.issues.numWarnings,messages:r.issues.messages.slice(0,4)}))}})();
