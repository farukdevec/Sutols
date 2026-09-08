"""Measure this uncompressed glTF pilot without importing/exporting model data."""
import sys,json,struct,hashlib,io
from pathlib import Path
import numpy as np
from PIL import Image

def inspect(file):
 b=Path(file).read_bytes();size=struct.unpack_from('<I',b,12)[0];g=json.loads(b[20:20+size]);buf=b[28+size:]
 def accessor(i):
  a=g['accessors'][i];assert 'sparse' not in a
  v=g['bufferViews'][a['bufferView']];d={5120:'i1',5121:'u1',5122:'<i2',5123:'<u2',5125:'<u4',5126:'<f4'}[a['componentType']];n={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']];return np.ndarray((a['count'],n),dtype=d,buffer=buf,offset=v.get('byteOffset',0)+a.get('byteOffset',0),strides=(v.get('byteStride',np.dtype(d).itemsize*n),np.dtype(d).itemsize)).copy()
 def matrix(n):
  if 'matrix' in n:return np.array(n['matrix']).reshape(4,4,order='F')
  x,y,z,w=n.get('rotation',[0,0,0,1]);r=np.array([[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],[2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],[2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]])
  m=np.eye(4);m[:3,:3]=r@np.diag(n.get('scale',[1,1,1]));m[:3,3]=n.get('translation',[0,0,0]);return m
 world={}
 def visit(i,parent):
  world[i]=parent@matrix(g['nodes'][i])
  for child in g['nodes'][i].get('children',[]):visit(child,world[i])
 for i in g['scenes'][g.get('scene',0)]['nodes']:visit(i,np.eye(4))
 def bounds(overrides={}):
  lo=np.full(3,np.inf);hi=-lo
  for i,m in world.items():
   n=g['nodes'][i]
   if 'mesh' not in n:continue
   mesh=g['meshes'][n['mesh']]
   for p in mesh['primitives']:
    v=accessor(p['attributes']['POSITION']).astype(float)
    for w,t in zip(overrides.get(i,n.get('weights',mesh.get('weights',[]))),p.get('targets',[])):
     if 'POSITION' in t:v+=w*accessor(t['POSITION'])
    v=v@m[:3,:3].T+m[:3,3];lo=np.minimum(lo,v.min(axis=0));hi=np.maximum(hi,v.max(axis=0))
  return {'min':lo.tolist(),'max':hi.tolist(),'dimensions':(hi-lo).tolist(),'center':((hi+lo)/2).tolist(),'baseHeight':float(lo[1])}
 motion=[]
 if g.get('animations'):
  a=g['animations'][0];ts=sorted(set(float(t) for s in a['samplers'] for t in accessor(s['input'])[:,0]))
  for time in ts:
   weights={}
   for ch in a['channels']:
    assert ch['target']['path']=='weights'
    samp=a['samplers'][ch['sampler']];assert samp.get('interpolation','LINEAR')=='LINEAR'
    times=accessor(samp['input'])[:,0];values=accessor(samp['output']).reshape(len(times),-1)
    weights[ch['target']['node']]=[float(np.interp(time,times,values[:,i])) for i in range(values.shape[1])]
   motion.append(bounds(weights))
 motion_bounds=None
 if motion:
  low=np.min([x['min'] for x in motion],axis=0);high=np.max([x['max'] for x in motion],axis=0)
  motion_bounds={'min':low.tolist(),'max':high.tolist(),'dimensions':(high-low).tolist(),'method':'All key times of first clip; exact extrema for this linear morph-only animation with fixed node transforms','keyTimesEvaluated':len(motion)}
 clips=[]
 for a in g.get('animations',[]):
  clips.append({'name':a['name'],'channels':len(a['channels']),'samplers':[{'start':float(accessor(s['input'])[0,0]),'end':float(accessor(s['input'])[-1,0]),'samples':len(accessor(s['input'])),'interpolation':s.get('interpolation','LINEAR')} for s in a['samplers']]})
 imgs=[]
 for im in g.get('images',[]):
  v=g['bufferViews'][im['bufferView']];start=v.get('byteOffset',0);pic=Image.open(io.BytesIO(buf[start:start+v['byteLength']]));w,h=pic.size;imgs.append({'name':im.get('name'),'width':w,'height':h,'decodedRgbaBytes':w*h*4,'estimatedRgbaWithMipmapsBytes':round(w*h*4*4/3)})
 triangles=0
 for mesh in g['meshes']:
  for p in mesh['primitives']:
   assert p.get('mode',4)==4
   triangles+=g['accessors'][p.get('indices',p['attributes']['POSITION'])]['count']//3
 result={'file':file,'sha256':hashlib.sha256(b).hexdigest(),'byteSize':len(b),'uniqueMeshTriangles':triangles,'nodes':len(g['nodes']),'meshes':len(g['meshes']),'primitives':sum(len(m['primitives']) for m in g['meshes']),'scenePrimitiveInstances':sum(len(g['meshes'][g['nodes'][i]['mesh']]['primitives']) for i in world if 'mesh' in g['nodes'][i]),'materials':len(g.get('materials',[])),'images':imgs,'skins':len(g.get('skins',[])),'morphMeshes':sum(any(p.get('targets') for p in m['primitives']) for m in g['meshes']),'animations':clips,'extensionsUsed':g.get('extensionsUsed',[]),'extensionsRequired':g.get('extensionsRequired',[]),'externalResources':[x['uri'] for k in ['buffers','images'] for x in g.get(k,[]) if 'uri'in x],'bounds':bounds(),'rootTransforms':[{'node':i,'matrix':world[i].tolist()} for i in g['scenes'][g.get('scene',0)]['nodes']],'origin':[0,0,0],'animationBounds':motion_bounds,'gpuFrameTime':None}
 return result
if __name__=='__main__':
 Path(sys.argv[2]).write_text(json.dumps(inspect(sys.argv[1]),indent=2)+'\n')
