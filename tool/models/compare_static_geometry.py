"""Check world-space geometry/material invariance after merging static GLBs.
Usage: python3 compare_static_geometry.py before.zip after-web-directory report.json
This measures asset primitive instances, not GPU draw calls or power consumption.
"""
import json, math, struct, sys, zipfile
from pathlib import Path

def read_glb(raw):
    length=struct.unpack_from('<I',raw,12)[0]
    gltf=json.loads(raw[20:20+length]); binary=raw[28+length:]
    if gltf.get('animations') or gltf.get('skins'):raise ValueError('Only static GLBs supported')
    return gltf,binary

def matrix(node):
    if 'matrix' in node:
        a=node['matrix'];return [[a[c*4+r] for c in range(4)] for r in range(4)]
    x,y,z,w=node.get('rotation',[0,0,0,1]);scale=node.get('scale',[1,1,1]);t=node.get('translation',[0,0,0])
    m=[[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w),t[0]],
       [2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w),t[1]],
       [2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y),t[2]], [0,0,0,1]]
    for r in range(3):
        for c in range(3):m[r][c]*=scale[c]
    return m

def inventory(raw):
    g,binary=read_glb(raw);points=[];primitives=0;triangles=0
    def visit(index,parent):
        nonlocal primitives,triangles
        n=g['nodes'][index];local=matrix(n)
        world=[[sum(parent[r][k]*local[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
        if 'mesh' in n:
            for p in g['meshes'][n['mesh']]['primitives']:
                if p.get('targets'):raise ValueError('Morph targets cannot be merged as static geometry')
                if p.get('mode',4)!=4:raise ValueError('Triangle primitive required')
                primitives+=1;a=g['accessors'][p['attributes']['POSITION']]
                if a['componentType']!=5126 or a['type']!='VEC3':raise ValueError('Float VEC3 positions required')
                v=g['bufferViews'][a['bufferView']];offset=v.get('byteOffset',0)+a.get('byteOffset',0);stride=v.get('byteStride',12)
                triangles+=g['accessors'][p['indices']]['count']//3 if 'indices' in p else a['count']//3
                for i in range(a['count']):
                    xyz=struct.unpack_from('<3f',binary,offset+i*stride)
                    points.append(tuple(sum(world[r][c]*xyz[c] for c in range(3))+world[r][3] for r in range(3)))
        for child in n.get('children',[]):visit(child,world)
    identity=[[float(r==c) for c in range(4)] for r in range(4)]
    for n in g['scenes'][g.get('scene',0)]['nodes']:visit(n,identity)
    materials=sorted(json.dumps({k:v for k,v in m.items() if k!='name'},sort_keys=True) for m in g.get('materials',[]))
    return {'points':points,'primitives':primitives,'triangles':triangles,'materials':materials}

def unmatched(source,target,tolerance=1e-4):
    cells={}
    for p in target:cells.setdefault(tuple(math.floor(x/tolerance) for x in p),[]).append(p)
    count=0
    for p in source:
        key=tuple(math.floor(x/tolerance) for x in p);found=False
        for dx in [-1,0,1]:
            for dy in [-1,0,1]:
                for dz in [-1,0,1]:
                    for q in cells.get((key[0]+dx,key[1]+dy,key[2]+dz),[]):
                        if sum((p[i]-q[i])**2 for i in range(3))<=tolerance*tolerance:found=True;break
                    if found:break
                if found:break
            if found:break
        if not found:count+=1
    return count

before,after,destination=sys.argv[1:];records=[]
with zipfile.ZipFile(before) as archive:
    manifest=json.loads(archive.read('web/models/original-v1/manifest.json'))
    for model in manifest:
        for variant,asset in model['variants'].items():
            old=inventory(archive.read('web'+asset['path']));new=inventory((Path(after)/asset['path'].lstrip('/')).read_bytes())
            missing=unmatched(old['points'],new['points'])+unmatched(new['points'],old['points'])
            result={'id':model['id'],'variant':variant,'primitiveInstancesBefore':old['primitives'],
                    'primitiveInstancesAfter':new['primitives'],'trianglesBefore':old['triangles'],
                    'trianglesAfter':new['triangles'],'unmatchedWorldVertices':missing,
                    'materialDefinitionsUnchanged':old['materials']==new['materials']}
            records.append(result)
            if missing or old['triangles']!=new['triangles'] or old['materials']!=new['materials']:
                raise ValueError('Geometry/material mismatch: '+model['id']+' '+variant+' '+str(result))
Path(destination).write_text(json.dumps({'scope':'Static asset primitive instances; not measured GPU draw calls',
    'worldVertexTolerance':1e-4,'variants':records},indent=2))
print(json.dumps({'variants':len(records),'primitiveInstancesBefore':sum(r['primitiveInstancesBefore'] for r in records),
    'primitiveInstancesAfter':sum(r['primitiveInstancesAfter'] for r in records),'geometryAndMaterialsUnchanged':True}))
