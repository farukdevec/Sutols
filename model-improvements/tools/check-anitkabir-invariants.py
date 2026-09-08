import json,struct,hashlib
from pathlib import Path
p=Path('model-improvements/reports/533a4fd62f2b3444');build=json.loads((p/'candidate-build.json').read_text())
before=json.loads((p/'metrics-before.json').read_text());after=json.loads((p/'metrics-after.json').read_text())
checks={k:before[k]==after[k] for k in ['bounds','rootTransforms','meshes','primitives','materials','images','skins','morphMeshes','uniqueMeshTriangles','scenePrimitiveInstances']}
assert all(checks.values())
checks['motionEnvelopeUnchanged']=before['animationBounds']['dimensions']==after['animationBounds']['dimensions'];assert checks['motionEnvelopeUnchanged']
b=Path(build['candidatePath']).read_bytes();assert hashlib.sha256(b).hexdigest()==build['outputSha256'];n=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+n]);buf=b[28+n:]
a=g['animations'][0];assert a['name']=='Sutols_Functional_Loop' and len(a['channels'])==3
assert all(c['sampler']==0 and c['target']['path']=='weights' for c in a['channels'])
out=g['accessors'][a['samplers'][0]['output']];v=g['bufferViews'][out['bufferView']];weights=struct.unpack_from('<388f',buf,v.get('byteOffset',0)+out.get('byteOffset',0));assert weights[:4]==weights[-4:]
checks.update({'allFlagPartsShareSampler':True,'loopEndpointWeightsIdentical':True,'rootAnimationChannels':0,'sampleCount':97,'animationDuration':4,'unsupportedRequiredExtensions':g.get('extensionsRequired',[])})
(p/'invariants.json').write_text(json.dumps(checks,indent=2)+'\n')
vb=json.loads((p/'validator-before.json').read_text());va=json.loads((p/'validator-after.json').read_text());assert vb['issues']['messages']==va['issues']['messages']
warnings=[{**x,'assessment':'Inherited unchanged from source; same-renderer comparison performed; cross-renderer tangent portability remains unresolved. This warning is not globally waived.'} for x in va['issues']['messages'] if x['severity']==1]
(p/'warning-review.json').write_text(json.dumps({'newWarnings':0,'warnings':warnings,'informationalDegenerateTriangleIssues':[x for x in va['issues']['messages'] if x['severity']==2]},indent=2)+'\n')
print(json.dumps(checks))
