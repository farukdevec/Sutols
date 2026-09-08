"""Build revision 1 only from the verified original, without a Blender round trip."""
import copy,hashlib,json,struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=ROOT/'model-improvements/reports/533a4fd62f2b3444';b=(ROOT/'web/models/anitkabir.glb').read_bytes()
expected='15f5d50eb5dd9c433a458d77d09a55c40cc390134a67c018c070ff5ebf5348eb'
assert hashlib.sha256(b).hexdigest()==expected,'Base hash mismatch: do not build'
n=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+n]);before=copy.deepcopy(g);binary=bytearray(b[28+n:]);original_binary=bytes(binary)
a=g['animations'];assert len(a)==3
assert [c['channels'][0]['target'] for c in a]==[{'node':i,'path':'weights'} for i in [1998,1999,2000]]
assert all(c['samplers']==a[0]['samplers'] for c in a)
assert a[0]['samplers']==[{'input':0,'output':1,'interpolation':'LINEAR'}]
# The shared time accessor is used exclusively by these three clips.
assert all(0 not in p['attributes'].values() for m in g['meshes'] for p in m['primitives'])
acc=g['accessors'][0];view=g['bufferViews'][acc['bufferView']];offset=view.get('byteOffset',0)+acc.get('byteOffset',0)
assert acc['count']==97 and acc['componentType']==5126 and acc['type']=='SCALAR'
old=struct.unpack_from('<97f',binary,offset)
assert all(abs(t-(i+1)/24)<1e-6 for i,t in enumerate(old))
struct.pack_into('<97f',binary,offset,*[i/24 for i in range(97)])
acc['min']=[0.0];acc['max']=[4.0]
g['animations']=[{'name':'Sutols_Functional_Loop','samplers':a[0]['samplers'],'channels':[c['channels'][0] for c in a]}]
# The entire document except clips and time bounds stays identical.
check=copy.deepcopy(g);check['animations']=before['animations'];check['accessors'][0]=before['accessors'][0];assert check==before
assert binary[:offset]==original_binary[:offset] and binary[offset+388:]==original_binary[offset+388:]
j=json.dumps(g,separators=(',',':'),ensure_ascii=False).encode();j+=b' '*((-len(j))%4)
out=struct.pack('<III',0x46546c67,2,28+len(j)+len(binary))+struct.pack('<II',len(j),0x4e4f534a)+j+struct.pack('<II',len(binary),0x004e4942)+binary
h=hashlib.sha256(out).hexdigest();name=f'anitkabir-r1-{h}.glb';dest=p/name
if dest.exists():assert dest.read_bytes()==out
else:dest.write_bytes(out)
proof={'baseRevision':'baseline-sha256-'+expected,'candidateRevision':'r1','sourceSha256':expected,'outputSha256':h,'candidatePath':str(dest.relative_to(ROOT)),'bytesBefore':len(b),'bytesAfter':len(out),'byteDelta':len(out)-len(b),'nonAnimationJsonUnchanged':True,'binaryUnchangedExceptTimeAccessor':True,'modifiedBinaryRange':[offset,offset+388],'clipTargets':[1998,1999,2000],'durationSeconds':4,'liveDeployment':'not_performed'}
(p/'candidate-build.json').write_text(json.dumps(proof,indent=2)+'\n');print(json.dumps(proof))
