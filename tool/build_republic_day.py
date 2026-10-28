"""Run in Blender's Python console/MCP. Creates an isolated, exportable scene."""
import bpy
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path('C:/sutol/Sutols')
out = ROOT / 'web/models'
out.mkdir(parents=True, exist_ok=True)
scene = bpy.data.scenes.new('Sutols • 29 Ekim')
bpy.context.window.scene = scene

def material(name, color, metallic=0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    bs = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    bs.inputs['Base Color'].default_value = (*color, 1)
    bs.inputs['Metallic'].default_value = metallic
    bs.inputs['Roughness'].default_value = .33
    return mat

red = material('Cumhuriyet kırmızısı', (.64, .008, .025))
gold = material('Saten altın', (.83, .57, .22), .75)
white = material('Fildişi', (.97, .94, .86))
dark = material('Bordo mermer', (.045, .008, .015), .3)

def cube(name, loc, scale, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(mat)
    bevel = o.modifiers.new('Yumuşak kenarlar', 'BEVEL')
    bevel.width = .035
    bevel.segments = 3
    return o

cube('Anıt kaidesi', (0, 0, .15), (3.7, 1.1, .3), dark)
cube('Altın kuşak', (0, 0, .32), (3.6, 1.03, .045), gold)

def text(body, loc, size, mat):
    curve = bpy.data.curves.new(body, 'FONT')
    curve.body = body
    curve.align_x = 'CENTER'
    curve.size = size
    curve.extrude = .025
    curve.bevel_depth = .005
    obj = bpy.data.objects.new(body, curve)
    scene.collection.objects.link(obj)
    obj.location = loc
    obj.rotation_euler = (math.pi / 2, 0, 0)
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target='MESH')
    obj.select_set(False)

text('29 EKİM', (.5, -.12, .48), .48, gold)
text('CUMHURİYET', (.5, -.13, 1.04), .26, white)
text('1923', (.5, -.13, 1.39), .17, gold)

bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=.035, depth=3.3, location=(-1.5, 0, 1.98))
pole = bpy.context.object
pole.name = 'Bayrak direği'
pole.data.materials.append(gold)
bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=12, radius=.085, location=(-1.5, 0, 3.68))
bpy.context.object.data.materials.append(gold)

# Analytic flag texture: crescent is a true cutout, with a five-pointed star.
w, h = 768, 512
star = [(0.573 + math.cos(-math.pi/2 + math.pi/10 + i*math.pi/5) * (0.08333 if i%2 == 0 else .03183),
         .5 + math.sin(-math.pi/2 + math.pi/10 + i*math.pi/5) * (.125 if i%2 == 0 else .04775)) for i in range(10)]
def inside(x, y):
    hit = False
    j = 9
    for i in range(10):
        a, b = star[i], star[j]
        if ((a[1] > y) != (b[1] > y)) and x < (b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0]:
            hit = not hit
        j = i
    return hit
pixels = []
for row in range(h):
    y = row / h
    for col in range(w):
        x = col / w
        crescent = ((x-1/3)*1.5)**2+(y-.5)**2 <= .25**2 and ((x-.375)*1.5)**2+(y-.5)**2 > .2**2
        pixels.extend((1, 1, 1, 1) if crescent or (.48 < x < .67 and inside(x,y)) else (.89, .039, .09, 1))
image = bpy.data.images.new('Türk Bayrağı', width=w, height=h)
image.pixels = pixels
image.pack()
flagmat = material('Dokuma Türk bayrağı', (1, 1, 1))
nodes = flagmat.node_tree.nodes
tex = nodes.new('ShaderNodeTexImage')
tex.image = image
flagmat.node_tree.links.new(tex.outputs['Color'], next(n for n in nodes if n.type == 'BSDF_PRINCIPLED').inputs['Base Color'])
next(n for n in nodes if n.type == 'BSDF_PRINCIPLED').inputs['Roughness'].default_value = .8

nx, nz = 48, 32
verts = [(-1.46 + i/nx*2.4, 0, 1.95+j/nz*1.6) for j in range(nz+1) for i in range(nx+1)]
faces = [(j*(nx+1)+i, j*(nx+1)+i+1, (j+1)*(nx+1)+i+1, (j+1)*(nx+1)+i) for j in range(nz) for i in range(nx)]
mesh = bpy.data.meshes.new('Dalgalanan kumaş')
mesh.from_pydata(verts, [], faces)
mesh.update()
flag = bpy.data.objects.new('Dalgalanan Türk Bayrağı', mesh)
scene.collection.objects.link(flag)
flag.data.materials.append(flagmat)
uv = mesh.uv_layers.new()
for polygon in mesh.polygons:
    polygon.use_smooth = True
    for loop_index in polygon.loop_indices:
        idx = mesh.loops[loop_index].vertex_index
        uv.data[loop_index].uv = ((idx % (nx+1))/nx, (idx // (nx+1))/nz)
flag.shape_key_add(name='Basis')
for k in range(4):
    key = flag.shape_key_add(name='Rüzgâr %d' % k)
    for idx, vert in enumerate(key.data):
        u = (idx % (nx+1))/nx
        v = (idx // (nx+1))/nz
        vert.co.y = .16*u*math.sin(u*math.pi*3+v*2+k*math.pi/2)
        vert.co.z -= .07*u*u
    for frame in (1, 21, 41, 61, 81):
        key.value = 1 if ((frame-1)//20)%4 == k else 0
        key.keyframe_insert('value', frame=frame)
scene.frame_start, scene.frame_end = 1, 81
scene.render.fps = 24
scene.frame_set(1)

bpy.ops.object.select_all(action='DESELECT')
for obj in scene.objects:
    if obj.type == 'MESH': obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(out/'cumhuriyet-29-ekim.glb'), export_format='GLB', use_selection=True, export_animations=True, export_morph=True)

world = bpy.data.worlds.new('Stüdyo')
world.use_nodes = True
next(n for n in world.node_tree.nodes if n.type == 'BACKGROUND').inputs[0].default_value = (.17, .17, .2, 1)
next(n for n in world.node_tree.nodes if n.type == 'BACKGROUND').inputs[1].default_value = .5
scene.world = world
for loc, power, size in [((1,-5,6), 900, 5), ((-4,-2,3), 600, 4), ((2,3,5), 1100, 3)]:
    data = bpy.data.lights.new('Softbox', 'AREA')
    data.energy, data.shape, data.size = power, 'DISK', size
    obj = bpy.data.objects.new('Softbox', data)
    scene.collection.objects.link(obj)
    obj.location = loc
    obj.rotation_euler = (Vector((0,0,1.7))-obj.location).to_track_quat('-Z','Y').to_euler()
data = bpy.data.cameras.new('Cumhuriyet Kamera')
cam = bpy.data.objects.new('Cumhuriyet Kamera', data)
scene.collection.objects.link(cam)
cam.location = (5,-10,5)
cam.rotation_euler = (Vector((0,0,1.9))-cam.location).to_track_quat('-Z','Y').to_euler()
data.type, data.ortho_scale = 'ORTHO', 5.3
scene.camera = cam
scene.render.engine = 'CYCLES'
scene.cycles.samples = 24
scene.render.resolution_x, scene.render.resolution_y, scene.render.resolution_percentage = 640, 640, 100
scene.render.film_transparent = True
thumb = ROOT/'web/model_thumbnails/cumhuriyet-29-ekim.png'
thumb.parent.mkdir(parents=True, exist_ok=True)
scene.render.filepath = str(thumb)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'model-improvements/cumhuriyet-29-ekim.blend'))
bpy.ops.render.render(write_still=True)
print('REPUBLIC_DAY_EXPORTED', (out/'cumhuriyet-29-ekim.glb').stat().st_size, thumb)
