"""Blender CLI: --background --python this_file -- /absolute/pilot-directory.
Original, unpublished rig/animation/alpha/texture QA assets. Never changes v1.
See https://docs.blender.org/api/5.0/bpy.ops.export_scene.html
and https://docs.blender.org/manual/en/dev/addons/scene_gltf2.html.
"""
import bpy, math, sys, json, struct, hashlib
from pathlib import Path
from array import array
from mathutils import Vector

output = Path(sys.argv[sys.argv.index('--') + 1]).resolve()
output.mkdir(parents=True, exist_ok=True)
# Reuse geometry and calibrated CPU thumbnail helpers without running the v1 batch.
original = Path(__file__).with_name('build_original_models.py')
namespace = {'__file__': str(original)}
exec(compile(original.read_text().split('only = set(sys.argv')[0], str(original), 'exec'), namespace)
box, rod, sphere, finish = [namespace[n] for n in ['box', 'rod', 'sphere', 'finish']]

def reset(variant):
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
    for action in list(bpy.data.actions): bpy.data.actions.remove(action)
    namespace['mats'] = {}; namespace['quality'] = variant
    scene = bpy.context.scene; scene.frame_start = 1; scene.frame_end = 121; scene.render.fps = 30

def apply_bevels():
    for o in list(bpy.context.scene.objects):
        if o.type != 'MESH': continue
        bpy.context.view_layer.objects.active = o
        for modifier in list(o.modifiers):
            if modifier.type != 'ARMATURE': bpy.ops.object.modifier_apply(modifier=modifier.name)

def rotor():
    box('Tower', (0, .12, 1.05), (.20, .28, 2.1), 'white')
    box('Foundation', (0, .12, -.06), (1.0, .8, .12), 'navy')
    rod('Nacelle', (0, -.20, 2.12), (0, .42, 2.12), .18, 'navy')
    parts = [sphere('Hub', (0, -.28, 2.12), .16, 'gold')]
    for i in range(3):
        angle = i * 2 * math.pi / 3
        obj = box('Blade', (math.sin(angle)*.65, -.28, 2.12+math.cos(angle)*.65),
                  (.16, .075, 1.12), 'teal')
        obj.rotation_euler.y = angle; parts.append(obj)
    apply_bevels()
    bpy.ops.object.select_all(action='DESELECT')
    for obj in parts: obj.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join(); mesh = bpy.context.object; mesh.name = 'Skinned rotor'
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    data = bpy.data.armatures.new('WindRig'); arm = bpy.data.objects.new('WindRig', data)
    bpy.context.collection.objects.link(arm)
    bpy.ops.object.select_all(action='DESELECT'); arm.select_set(True)
    bpy.context.view_layer.objects.active = arm; bpy.ops.object.mode_set(mode='EDIT')
    root = data.edit_bones.new('Root'); root.head = (0,0,0); root.tail = (0,0,.2)
    bone = data.edit_bones.new('Rotor'); bone.head=(0,-.28,2.12); bone.tail=(0,.12,2.12); bone.parent=root
    bpy.ops.object.mode_set(mode='OBJECT')
    group = mesh.vertex_groups.new(name='Rotor'); group.add(list(range(len(mesh.data.vertices))), 1, 'REPLACE')
    mesh.modifiers.new('WindRig', 'ARMATURE').object = arm
    # A glTF skinned mesh stays a scene root; parent transforms are ignored by the spec.
    pose = arm.pose.bones['Rotor']; pose.rotation_mode = 'XYZ'
    for frame in range(1,122):
        pose.rotation_euler.y = (frame-1) * 2*math.pi/120
        pose.keyframe_insert(data_path='rotation_euler', frame=frame)
    arm.animation_data.action.name = 'RotorSpin'
    bpy.context.scene.frame_set(1)

def laboratory(variant):
    resolution = 1024 if variant == 'lite' else 2048
    image = bpy.data.images.new('Original QA calibration grid', width=resolution, height=resolution, alpha=False)
    pixels = array('f')
    colors = ((.03,.3,.5,1),(.04,.58,.52,1),(.80,.88,.94,1))
    for y in range(resolution):
        for x in range(resolution):
            grid = x % (resolution//16) < 3 or y % (resolution//16) < 3
            pixels.extend(colors[2] if grid else colors[((x//(resolution//4))+(y//(resolution//4)))%2])
    image.pixels.foreach_set(pixels); image.file_format='PNG'; image.pack()
    board = box('Calibration board', (0,.4,.7), (1.3,.05,1.4), 'navy', bevel=0)
    material = bpy.data.materials.new('Original grid texture'); material.use_nodes=True
    shader = material.node_tree.nodes.get('Principled BSDF'); texture=material.node_tree.nodes.new('ShaderNodeTexImage'); texture.image=image
    material.node_tree.links.new(texture.outputs['Color'], shader.inputs['Base Color']); shader.inputs['Roughness'].default_value=.6
    board.data.materials.clear(); board.data.materials.append(material)
    transparent = bpy.data.materials.new('Alpha glass QA'); transparent.use_nodes=True; transparent.surface_render_method='BLENDED'
    bsdf=transparent.node_tree.nodes.get('Principled BSDF'); bsdf.inputs['Base Color'].default_value=(.7,.92,1,1)
    bsdf.inputs['Alpha'].default_value=.22; bsdf.inputs['Roughness'].default_value=.12
    # Open cylinder walls: no opaque top covering the liquid.
    count = 32 if variant == 'lite' else 64
    verts = [(math.cos(i*2*math.pi/count)*.47, math.sin(i*2*math.pi/count)*.47, z)
             for z in [.05,1.15] for i in range(count)]
    faces = [(i,(i+1)%count,(i+1)%count+count,i+count) for i in range(count)]
    data=bpy.data.meshes.new('Glass walls'); data.from_pydata(verts,[],faces); data.materials.append(transparent)
    obj=bpy.data.objects.new('Open beaker glass',data); bpy.context.collection.objects.link(obj)
    for face in data.polygons: face.use_smooth=True
    bpy.ops.mesh.primitive_cylinder_add(vertices=count, radius=.445, depth=.50, location=(0,0,.30))
    finish(bpy.context.object,'Schematic liquid','blue')
    rod('Glass rim',(-.47,0,1.15),(.47,0,1.15),.012,'white')
    box('Display base',(0,.1,-.02),(1.5,1.1,.08),'navy')
    apply_bevels()

records=[]
for name,builder in [('rigged-wind-turbine',lambda v:rotor()),('alpha-texture-laboratory',laboratory)]:
    variants={}
    for variant in ['lite','quality']:
        reset(variant); builder(variant)
        path=output/f'{name}-{variant}.glb'
        bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',export_cameras=False,
          export_lights=False,export_animations=True,export_skins=True,export_def_bones=True,
          export_frame_range=True,export_texcoords=True)
        raw=path.read_bytes(); length=struct.unpack_from('<I',raw,12)[0]; gltf=json.loads(raw[20:20+length])
        variants[variant]={'file':path.name,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),
          'animations':len(gltf.get('animations',[])),'skins':len(gltf.get('skins',[])),
          'textures':len(gltf.get('textures',[])), 'alphaBlendMaterials':sum(m.get('alphaMode')=='BLEND' for m in gltf.get('materials',[]))}
        if variant=='quality': namespace['render_thumbnail'](output/f'{name}.png')
    records.append({'id':name,'variants':variants,'status':'unpublished visual QA pilot',
      'license':'Original procedural Sutols work; same source/license terms as original-v1',
      'textureDimensions':{'lite':1024,'quality':2048} if 'texture' in name else None})
(output/'pilot-manifest.json').write_text(json.dumps(records,indent=2))
print(json.dumps(records,indent=2))
