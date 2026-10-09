"""Run with Blender --background --python this_file.
Original schematic teaching models; no external assets or textures.
"""
import bpy, math, json, hashlib, pathlib, sys
from mathutils import Vector
ROOT = pathlib.Path(__file__).resolve().parents[2]
MODELS = ROOT/'web/models/original-v1'
THUMBS = ROOT/'web/model_thumbnails/original-v1'
MODELS.mkdir(parents=True, exist_ok=True); THUMBS.mkdir(parents=True, exist_ok=True)
COLORS = {'teal':(0.03,.55,.49,1),'navy':(.035,.075,.17,1),'gold':(1,.55,.10,1),
          'white':(.8,.88,.94,1),'red':(.85,.08,.12,1),'blue':(.08,.3,.9,1)}
quality = 'lite'; mats = {}

def material(name):
    if name in mats:return mats[name]
    m=bpy.data.materials.new(name);m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=COLORS[name]
    p.inputs['Roughness'].default_value=.34;p.inputs['Metallic'].default_value=.35 if name in ['navy','gold'] else .05
    mats[name]=m;return m

def finish(obj,name,color):
    obj.name=name;obj.data.materials.append(material(color))
    if obj.type=='MESH':
        for f in obj.data.polygons:f.use_smooth=True
    return obj

def sphere(name,p,r,color):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20 if quality=='lite' else 32,ring_count=10 if quality=='lite' else 16,radius=r,location=p)
    return finish(bpy.context.object,name,color)

def box(name,p,scale,color,bevel=.04):
    bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=finish(bpy.context.object,name,color);o.scale=scale
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        m=o.modifiers.new('Soft edges','BEVEL');m.width=bevel;m.segments=2 if quality=='lite' else 3
        o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    return o

def rod(name,a,b,r,color):
    delta=Vector(b)-Vector(a)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16 if quality=='lite' else 24,radius=r,depth=delta.length,location=(Vector(a)+Vector(b))/2)
    o=finish(bpy.context.object,name,color);o.rotation_euler=delta.to_track_quat('Z','Y').to_euler();return o

def ring(name,p,r,thickness,color,rotation=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=40 if quality=='lite' else 64,minor_segments=8 if quality=='lite' else 12,major_radius=r,minor_radius=thickness,location=p,rotation=rotation)
    return finish(bpy.context.object,name,color)

def cone(name,p,r1,r2,depth,color):
    bpy.ops.mesh.primitive_cone_add(vertices=24 if quality=='lite' else 40,radius1=r1,radius2=r2,depth=depth,location=p)
    return finish(bpy.context.object,name,color)

def water():
    sphere('Oxygen',(0,0,0),.42,'red')
    for i,x in enumerate([-1,1]):
        p=(x*.68,0,.5);rod('O-H bond',(0,0,0),p,.09,'white');sphere('Hydrogen '+str(i),p,.25,'white')

def carbon():
    sphere('Carbon',(0,0,0),.37,'navy')
    for x in [-1,1]:
        rod('Double bond A',(0,.10,0),(x*.85,.10,0),.05,'white')
        rod('Double bond B',(0,-.10,0),(x*.85,-.10,0),.05,'white')
        sphere('Oxygen',(x*1.05,0,0),.40,'red')

def atom():
    sphere('Nucleus',(0,0,0),.24,'gold')
    for i in range(3):
        rotation=(math.pi/2,0,i*math.pi/3)
        ring('Schematic orbit',(0,0,0),1.0,.025,'teal',rotation)
    sphere('Electron',(1,0,0),.09,'blue')

def gear():
    ring('Gear rim',(0,0,0),.68,.20,'teal');ring('Hub',(0,0,0),.22,.07,'gold')
    for i in range(16):
        a=i*2*math.pi/16;o=box('Tooth '+str(i),(math.cos(a)*.86,math.sin(a)*.86,0),(.24,.18,.28),'navy',.015);o.rotation_euler.z=a
    for a in [0,math.pi/2,math.pi,3*math.pi/2]:
        rod('Spoke',(math.cos(a)*.22,math.sin(a)*.22,0),(math.cos(a)*.65,math.sin(a)*.65,0),.06,'gold')

def solar():
    box('Panel frame',(0,0,.3),(2.0,1.4,.09),'navy')
    for x in range(4):
        for y in range(3):box('Photovoltaic cell',(x*.45-.675,y*.4-.4,.37),(.40,.35,.02),'blue',.012)
    rod('Stand',(-.7,0,-.45),(-.7,0,.26),.045,'white');rod('Stand',(.7,0,-.45),(.7,0,.26),.045,'white')
    box('Base',(0,0,-.48),(1.9,.8,.06),'teal')

def battery():
    box('Battery case',(0,0,0),(1.2,.65,1.5),'teal',.12)
    for x in [-.35,.35]:rod('Terminal',(x,0,.75),(x,0,.9),.10,'gold')
    box('Plus horizontal',(.0,-.335,.1),(.5,.02,.08),'white',.01)
    box('Plus vertical',(.0,-.335,.1),(.08,.02,.5),'white',.01)

def turbine():
    rod('Mast',(0,0,-1),(0,0,1),.065,'white');box('Foundation',(0,0,-1.05),(.6,.6,.1),'navy')
    sphere('Hub',(0,-.13,1),.13,'gold')
    for i in range(3):
        a=i*2*math.pi/3
        o=box('Blade',(math.sin(a)*.49,-.15,1+math.cos(a)*.49),(.12,.045,.88),'teal',.03);o.rotation_euler.y=a

def rocket():
    rod('Body',(0,0,-.55),(0,0,.55),.30,'white');cone('Nose',(0,0,.83),.30,0,.55,'teal')
    cone('Engine',(0,0,-.70),.23,.16,.3,'navy');ring('Body band',(0,0,.15),.30,.025,'gold')
    for i in range(3):
        a=i*2*math.pi/3;o=box('Fin',(math.cos(a)*.34,math.sin(a)*.34,-.45),(.36,.08,.45),'teal',.025);o.rotation_euler.z=a
    sphere('Window',(.0,-.295,.30),.11,'blue')

def temple():
    box('Platform',(0,0,-.5),(2.2,1.25,.18),'navy')
    for x in [-.8,-.27,.27,.8]:
        for y in [-.4,.4]:
            rod('Column',(x,y,-.4),(x,y,.45),.075,'white');box('Capital',(x,y,.45),(.21,.21,.1),'gold',.015)
    box('Entablature',(0,0,.55),(2.05,1.10,.13),'teal')
    verts=[(-1.1,-.6,.62),(1.1,-.6,.62),(0,-.6,1.02),(-1.1,.6,.62),(1.1,.6,.62),(0,.6,1.02)]
    mesh=bpy.data.meshes.new('Pediment mesh');mesh.from_pydata(verts,[],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)])
    o=bpy.data.objects.new('Pediment',mesh);bpy.context.collection.objects.link(o);finish(o,'Pediment','navy')
    for face in mesh.polygons:face.use_smooth=False

def microscope():
    box('Base',(0,0,-.9),(1.3,.9,.15),'navy',.09)
    rod('Support',(.3,0,-.85),(.3,0,.6),.09,'teal')
    box('Stage',(-.1,0,-.2),(.8,.65,.09),'navy')
    rod('Optical tube',(-.28,0,.25),(-.6,0,.9),.13,'white');rod('Eyepiece',(-.6,0,.9),(-.69,0,1.08),.09,'gold')
    rod('Objective',(-.28,0,.25),(-.28,0,.05),.06,'gold');sphere('Focus knob',(.4,-.18,.2),.13,'gold')


def solid_mesh(name, vertices, faces, color='teal'):
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update()
    obj=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(obj);finish(obj,name,color)
    for face in mesh.polygons:face.use_smooth=False
    return obj

def cube():box('Cube',(0,0,0),(1.4,1.4,1.4),'teal',.025)
def ball():sphere('Sphere',(0,0,0),.85,'teal')
def cylinder():rod('Cylinder',(0,0,-.7),(0,0,.7),.65,'teal')
def geometric_cone():cone('Cone',(0,0,0),.8,0,1.6,'teal')
def geometric_torus():ring('Torus',(0,0,0),.65,.25,'gold')
def tetrahedron():
    solid_mesh('Regular tetrahedron',[(1,1,1),(-1,-1,1),(-1,1,-1),(1,-1,-1)],[(0,2,1),(0,1,3),(0,3,2),(1,2,3)])
def pyramid():
    solid_mesh('Square pyramid',[(-.8,-.8,-.5),(.8,-.8,-.5),(.8,.8,-.5),(-.8,.8,-.5),(0,0,.9)],[(0,3,2,1),(0,1,4),(1,2,4),(2,3,4),(3,0,4)])
def triangular_prism():
    solid_mesh('Triangular prism',[(-.7,-.7,-.6),(.7,-.7,-.6),(0,-.7,.7),(-.7,.7,-.6),(.7,.7,-.6),(0,.7,.7)],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)],'gold')
def axes():
    for name,tip,color in [('X',(1.2,0,0),'red'),('Y',(0,1.2,0),'teal'),('Z',(0,0,1.2),'blue')]:
        rod(name+' axis',(0,0,0),tip,.035,color);sphere(name+' endpoint',tip,.08,color)
    sphere('Origin',(0,0,0),.09,'white')
def lever():
    solid_mesh('Fulcrum',[(-.3,-.3,-.55),(.3,-.3,-.55),(0,-.3,0),(-.3,.3,-.55),(.3,.3,-.55),(0,.3,0)],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)],'gold')
    box('Lever beam',(0,0,.05),(2.2,.25,.09),'teal')
    box('Load',(-.8,0,.3),(.3,.3,.4),'navy');rod('Effort marker',(.8,0,.35),(.8,0,.1),.04,'red')
def pulley():
    ring('Pulley wheel',(0,0,.25),.55,.08,'teal',rotation=(math.pi/2,0,0))
    rod('Axle',(0,-.2,.25),(0,.2,.25),.08,'gold')
    rod('Rope left',(-.6,0,.25),(-.6,0,-.8),.018,'white');rod('Rope right',(.6,0,.25),(.6,0,-.35),.018,'white')
    box('Load',(-.6,0,-.9),(.32,.32,.25),'navy')
def spring():
    count=120 if quality=='lite' else 240
    curve=bpy.data.curves.new('Helical spring','CURVE');curve.dimensions='3D';curve.bevel_depth=.04;curve.bevel_resolution=2 if quality=='lite' else 3
    spline=curve.splines.new('POLY');spline.points.add(count)
    for i,p in enumerate(spline.points):
        t=i/count;p.co=(.45*math.cos(t*math.pi*12),.45*math.sin(t*math.pi*12),t*1.8-.9,1)
    obj=bpy.data.objects.new('Spring',curve);bpy.context.collection.objects.link(obj);curve.materials.append(material('gold'))
    bpy.context.view_layer.objects.active=obj;obj.select_set(True);bpy.ops.object.convert(target='MESH');obj.select_set(False)
def pendulum():
    rod('Frame',(-.6,0,-1),(-.6,0,1),.045,'navy');rod('Support',(-.6,0,1),(.3,0,1),.045,'navy')
    rod('String',(.2,0,.97),(.55,0,-.6),.016,'white');sphere('Pendulum bob',(.55,0,-.6),.22,'gold');box('Foot',(-.6,0,-1),(.6,.5,.07),'teal')
def resistor():
    rod('Body',(-.6,0,0),(.6,0,0),.2,'gold')
    rod('Lead left',(-1.1,0,0),(-.6,0,0),.025,'white');rod('Lead right',(.6,0,0),(1.1,0,0),.025,'white')
    for x,color in [(-.32,'navy'),(-.16,'red'),(.0,'teal'),(.35,'white')]:ring('Color band',(x,0,0),.2,.018,color,rotation=(0,math.pi/2,0))
def chip():
    box('Microchip body',(0,0,0),(1.1,1.1,.18),'navy')
    for axis in [0,1]:
        for sign in [-1,1]:
            for i in range(6):
                p=[i*.16-.4,sign*.67,-.03]
                if axis:p[0],p[1]=p[1],p[0]
                scale=(.055,.28,.035) if not axis else (.28,.055,.035)
                box('Pin',p,scale,'gold',.005)
    box('Die marker',(0,0,.11),(.45,.45,.035),'teal',.01)


def octahedron():
    solid_mesh('Octahedron',[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(0,0,1.2),(0,0,-1.2)],[(4,0,2),(4,2,1),(4,1,3),(4,3,0),(5,2,0),(5,1,2),(5,3,1),(5,0,3)])
def icosahedron():
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1)
    o=finish(bpy.context.object,'Icosahedron','teal')
    for f in o.data.polygons:f.use_smooth=False
def cuboid():box('Rectangular cuboid',(0,0,0),(1.7,1,.7),'teal',.025)
def ellipsoid():
    o=sphere('Ellipsoid',(0,0,0),.8,'teal');o.scale=(1.5,.75,1)
def hemisphere():
    n=24 if quality=='lite' else 40;steps=8 if quality=='lite' else 14
    vertices=[(0,0,.9)]
    for j in range(1,steps+1):
        theta=j*math.pi/(2*steps)
        vertices += [(.9*math.sin(theta)*math.cos(i*2*math.pi/n),.9*math.sin(theta)*math.sin(i*2*math.pi/n),.9*math.cos(theta)) for i in range(n)]
    faces=[(0,1+i,1+(i+1)%n) for i in range(n)]
    for j in range(steps-1):
        a=1+j*n;b=a+n
        faces += [(a+i,b+i,b+(i+1)%n,a+(i+1)%n) for i in range(n)]
    faces.append(tuple(reversed(range(1+(steps-1)*n,1+steps*n))))
    solid_mesh('Hemisphere',vertices,faces)
def hexagonal_prism():
    vertices=[(.8*math.cos(i*math.pi/3),.8*math.sin(i*math.pi/3),z) for z in [-.6,.6] for i in range(6)]
    solid_mesh('Hexagonal prism',vertices,[tuple(reversed(range(6))),tuple(range(6,12))]+[(i,(i+1)%6,(i+1)%6+6,i+6) for i in range(6)])
def hexagonal_pyramid():
    vertices=[(.9*math.cos(i*math.pi/3),.9*math.sin(i*math.pi/3),-.6) for i in range(6)]+[(0,0,.9)]
    solid_mesh('Hexagonal pyramid',vertices,[tuple(reversed(range(6)))]+[(i,(i+1)%6,6) for i in range(6)])
def triangular_plane():
    solid_mesh('Right triangular plate',[(0,0,0),(1.5,0,0),(0,1.1,0),(0,0,.06),(1.5,0,.06),(0,1.1,.06)],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)])
def diatomic(color,count):
    for x in [-.5,.5]:sphere('Atom',(x,0,0),.36,color)
    for i in range(count):rod('Bond',(-.4,(i-(count-1)/2)*.14,0),(.4,(i-(count-1)/2)*.14,0),.045,'white')
def hydrogen():diatomic('white',1)
def oxygen():diatomic('red',2)
def nitrogen():diatomic('blue',3)
def methane():
    sphere('Carbon',(0,0,0),.35,'navy')
    for p in [(1,1,1),(-1,-1,1),(-1,1,-1),(1,-1,-1)]:
        v=Vector(p).normalized()*.95;rod('C-H bond',(0,0,0),v,.07,'white');sphere('Hydrogen',v,.23,'white')
def ammonia():
    sphere('Nitrogen',(0,0,.25),.35,'blue')
    for i in range(3):
        a=i*2*math.pi/3;p=(.8*math.cos(a),.8*math.sin(a),-.25)
        rod('N-H bond',(0,0,.25),p,.07,'white');sphere('Hydrogen',p,.23,'white')
def capacitor():
    rod('Capacitor body',(0,0,-.45),(0,0,.5),.4,'blue')
    for x in [-.2,.2]:rod('Lead',(x,0,-.45),(x,0,-1),.025,'gold')
    box('Polarity stripe',(.36,0,0),(.035,.2,.72),'white',0)
def diode():
    rod('Axial body',(-.45,0,0),(.45,0,0),.23,'navy')
    rod('Cathode stripe',(.22,0,0),(.32,0,0),.235,'white')
    for a,b in [((-1,0,0),(-.45,0,0)),((.45,0,0),(1,0,0))]:rod('Lead',a,b,.035,'gold')
def led():
    sphere('Opaque LED lens',(0,0,.2),.35,'red')
    rod('LED body',(0,0,-.2),(0,0,.2),.35,'red')
    ring('Flange',(0,0,-.2),.34,.045,'red')
    for x,z in [(-.15,-.95),(.15,-1.2)]:rod('Lead',(x,0,-.2),(x,0,z),.03,'gold')
def transformer():
    box('Core',(0,0,0),(1.3,.45,1.15),'navy')
    for x,color in [(-.38,'gold'),(.38,'teal')]:
        for z in [-.4,-.2,0,.2,.4]:ring('Winding',(x,0,z),.32,.045,color)
def balance_scale():
    rod('Stand',(0,0,-.8),(0,0,.8),.06,'navy');box('Base',(0,0,-.85),(.6,.6,.1),'navy')
    rod('Beam',(-.8,0,.7),(.8,0,.7),.045,'gold')
    for x in [-.75,.75]:
        rod('Hanger',(x,0,.7),(x,0,-.15),.025,'gold');cone('Pan',(x,0,-.25),.25,.42,.12,'teal')
def piston():
    rod('Piston crown',(0,0,.25),(0,0,.7),.48,'white')
    for z in [.36,.55]:ring('Piston ring',(0,0,z),.485,.022,'navy')
    rod('Connecting rod',(0,0,.25),(0,0,-.95),.09,'gold');ring('Big end',(0,0,-1),.24,.08,'navy',(math.pi/2,0,0))
def archimedes_screw():
    rod('Shaft',(0,0,-1.1),(0,0,1.1),.1,'navy')
    count=100 if quality=='lite' else 180
    vertices=[]
    for i in range(count+1):
        a=i/count*6*math.pi;z=-1+i/count*2
        vertices.extend([(.12*math.cos(a),.12*math.sin(a),z),(.55*math.cos(a),.55*math.sin(a),z)])
    solid_mesh('Helical flight',vertices,[(2*i,2*i+1,2*i+3,2*i+2) for i in range(count)],'teal')
def newton_cradle():
    box('Base',(0,0,-.65),(1.8,1,.1),'navy')
    for y in [-.35,.35]:
        for x in [-.82,.82]:rod('Support',(x,y,-.6),(x,y,.95),.04,'gold')
        rod('Rail',(-.82,y,.95),(.82,y,.95),.04,'gold')
    for i in range(5):
        x=(i-2)*.29;sphere('Ball',(x,0,-.15),.145,'white')
        for y in [-.35,.35]:rod('Suspension',(x,y,.95),(x,0,-.04),.008,'navy')
def dna():
    count=24
    for i in range(count):
        a=i/(count-1)*4*math.pi;z=-1.4+i/(count-1)*2.8
        p=(.5*math.cos(a),.5*math.sin(a),z);q=(-p[0],-p[1],z)
        if i:
            rod('Backbone A',previousP,p,.055,'teal');rod('Backbone B',previousQ,q,.055,'gold')
        if i%2==0:rod('Schematic base pair',p,q,.035,'white')
        previousP=p;previousQ=q
def tree():
    rod('Trunk',(0,0,-.9),(0,0,.6),.14,'gold')
    for p,r in [((0,0,.8),.65),((-.45,0,.5),.48),((.45,.1,.55),.5),((0,.25,1.1),.4)]:sphere('Foliage',p,r,'teal')
def bacterium():
    o=sphere('Schematic bacterium',(0,0,0),.55,'teal');o.scale=(1.8,.8,.8)
    rod('Flagellum',(1,0,0),(1.5,.15,.1),.025,'gold');rod('Flagellum tip',(1.5,.15,.1),(1.9,-.05,.25),.025,'gold')
    for i in range(6):
        x=-.6+i*.24;rod('Surface projection',(x,-.42,0),(x,-.65,.1),.02,'white')
def neuron():
    sphere('Cell body',(-.6,0,0),.33,'teal');sphere('Nucleus',(-.65,-.25,.03),.11,'gold')
    for i in range(6):
        a=i*2*math.pi/6;p=(-.6+.65*math.cos(a),.65*math.sin(a),.1*math.sin(2*a))
        rod('Dendrite',(-.6,0,0),p,.035,'teal')
        rod('Branch',p,(p[0]+.15*math.cos(a+.5),p[1]+.2*math.sin(a+.5),p[2]+.12),.02,'teal')
    rod('Axon',(-.3,0,0),(1.2,0,0),.035,'gold')
    for x in [0,.3,.6,.9]:rod('Myelin segment',(x,0,0),(x+.18,0,0),.09,'white')
    for y in [-.25,0,.25]:rod('Axon terminal',(1.2,0,0),(1.45,y,.12),.025,'gold')

SPECS=[
 ('water-molecule','Su Molekülü — H₂O','Kimya',['su','molekül','h2o','water'],water),
 ('carbon-dioxide','Karbondioksit Molekülü — CO₂','Kimya',['karbondioksit','co2','carbon dioxide'],carbon),
 ('bohr-atom','Bohr Atom Şeması','Fizik',['atom','bohr','elektron','nucleus'],atom),
 ('spur-gear','Düz Dişli Çark','Mühendislik',['dişli','çark','gear','mekanik'],gear),
 ('solar-panel','Güneş Paneli','Enerji',['güneş paneli','fotovoltaik','solar panel'],solar),
 ('battery','Elektrik Bataryası','Enerji',['batarya','pil','battery'],battery),
 ('wind-turbine','Rüzgâr Türbini','Enerji',['rüzgar türbini','wind turbine'],turbine),
 ('rocket','Uzay Roketi','Uzay',['roket','uzay roketi','rocket'],rocket),
 ('classical-temple','Klasik Tapınak Şeması','Tarih ve Mimari',['tapınak','sütun','temple'],temple),
 ('microscope','Optik Mikroskop','Biyoloji',['mikroskop','microscope','optik'],microscope),
 ('cube','Küp','Matematik',['küp', 'cube', 'geometrik cisim'],cube),
 ('sphere','Küre','Matematik',['küre', 'sphere'],ball),
 ('cylinder','Silindir','Matematik',['silindir', 'cylinder'],cylinder),
 ('cone','Koni','Matematik',['koni', 'cone'],geometric_cone),
 ('torus','Torus','Matematik',['torus', 'halka yüzey'],geometric_torus),
 ('tetrahedron','Düzgün Dörtyüzlü','Matematik',['tetrahedron', 'dörtyüzlü'],tetrahedron),
 ('square-pyramid','Kare Piramit','Matematik',['kare piramit', 'square pyramid'],pyramid),
 ('triangular-prism','Üçgen Prizma','Matematik',['üçgen prizma', 'triangular prism'],triangular_prism),
 ('coordinate-axes','Üç Boyutlu Koordinat Eksenleri','Matematik',['koordinat eksenleri', 'coordinate axes'],axes),
 ('lever','Kaldıraç Şeması','Fizik',['kaldıraç', 'lever', 'basit makine'],lever),
 ('pulley','Sabit Makara Şeması','Fizik',['makara', 'pulley', 'basit makine'],pulley),
 ('helical-spring','Helisel Yay','Mühendislik',['helisel yay', 'helical spring', 'spring'],spring),
 ('pendulum','Basit Sarkaç','Fizik',['sarkaç', 'pendulum'],pendulum),
 ('resistor','Direnç Şeması','Elektronik',['elektrik direnci', 'resistor'],resistor),
 ('microchip','Mikroçip Şeması','Teknoloji',['mikroçip', 'microchip', 'entegre devre', 'integrated circuit'],chip),
 ('octahedron', 'Düzgün Sekizyüzlü', 'Matematik', ['oktahedron', 'sekizyüzlü', 'octahedron'],octahedron),
 ('icosahedron', 'Düzgün Yirmiyüzlü', 'Matematik', ['ikosahedron', 'yirmiyüzlü', 'icosahedron'],icosahedron),
 ('cuboid', 'Dikdörtgenler Prizması', 'Matematik', ['dikdörtgenler prizması', 'cuboid', 'rectangular prism'],cuboid),
 ('ellipsoid', 'Elipsoit', 'Matematik', ['elipsoit', 'ellipsoid'],ellipsoid),
 ('hemisphere', 'Yarım Küre', 'Matematik', ['yarım küre', 'hemisphere'],hemisphere),
 ('hexagonal-prism', 'Altıgen Prizma', 'Matematik', ['altıgen prizma', 'hexagonal prism'],hexagonal_prism),
 ('hexagonal-pyramid', 'Altıgen Piramit', 'Matematik', ['altıgen piramit', 'hexagonal pyramid'],hexagonal_pyramid),
 ('right-triangle', 'Dik Üçgen Plakası', 'Matematik', ['dik üçgen', 'pisagor', 'right triangle', 'pythagoras'],triangular_plane),
 ('hydrogen-molecule', 'Hidrojen Molekülü — H₂', 'Kimya', ['hidrojen', 'h2', 'hydrogen'],hydrogen),
 ('oxygen-molecule', 'Oksijen Molekülü — O₂', 'Kimya', ['oksijen', 'o2', 'oxygen'],oxygen),
 ('nitrogen-molecule', 'Azot Molekülü — N₂', 'Kimya', ['azot', 'n2', 'nitrogen'],nitrogen),
 ('methane-molecule', 'Metan Molekülü — CH₄', 'Kimya', ['metan', 'ch4', 'methane'],methane),
 ('ammonia-molecule', 'Amonyak Molekülü — NH₃', 'Kimya', ['amonyak', 'nh3', 'ammonia'],ammonia),
 ('capacitor', 'Kondansatör Şeması', 'Elektronik', ['kondansatör', 'kapasitör', 'capacitor'],capacitor),
 ('diode', 'Diyot Şeması', 'Elektronik', ['diyot', 'diode', 'doğrultma'],diode),
 ('led', 'LED Şeması', 'Elektronik', ['led', 'ışık yayan diyot', 'light emitting diode'],led),
 ('transformer', 'Transformatör Şeması', 'Elektronik', ['transformatör', 'trafo', 'transformer', 'indüksiyon'],transformer),
 ('balance-scale', 'Eşit Kollu Terazi', 'Fizik', ['terazi', 'denge', 'moment', 'balance scale'],balance_scale),
 ('piston', 'Piston ve Biyel Şeması', 'Mühendislik', ['piston', 'biyel', 'connecting rod'],piston),
 ('archimedes-screw', 'Arşimet Burgusu', 'Mühendislik', ['arşimet burgusu', 'archimedes screw', 'helisel vida'],archimedes_screw),
 ('newton-cradle', 'Newton Beşiği', 'Fizik', ['newton beşiği', 'newton cradle', 'momentum'],newton_cradle),
 ('dna-helix', 'DNA Çift Sarmal Şeması', 'Biyoloji', ['dna', 'çift sarmal', 'double helix', 'genetik'],dna),
 ('tree', 'Ağaç Şeması', 'Doğa', ['ağaç', 'tree', 'orman', 'forest'],tree),
 ('bacterium', 'Bakteri Şeması', 'Biyoloji', ['bakteri', 'bacterium', 'bacteria', 'mikroorganizma'],bacterium),
 ('neuron', 'Nöron Şeması', 'Biyoloji', ['nöron', 'neuron', 'sinir hücresi', 'nerve cell'],neuron),
]

# Load the extension by an explicit sibling path (also works under Blender CLI).
import importlib.util
_extension_spec=importlib.util.spec_from_file_location('sutols_extended_models',pathlib.Path(__file__).with_name('extended_original_models.py'))
_extension=importlib.util.module_from_spec(_extension_spec);_extension_spec.loader.exec_module(_extension)
SPECS.extend(_extension.additional_specs(globals()))
assert len({row[0] for row in SPECS})==len(SPECS)

def render_thumbnail(path):
    scene=bpy.context.scene
    scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.device='CPU'
    scene.render.resolution_x=512;scene.render.resolution_y=512;scene.render.resolution_percentage=100
    scene.render.film_transparent=True
    scene.world.color=(.3,.3,.3)
    corners=[o.matrix_world @ v.co for o in scene.objects if o.type=='MESH' for v in o.data.vertices]
    low=Vector([min(c[i] for c in corners) for i in range(3)]);high=Vector([max(c[i] for c in corners) for i in range(3)])
    center=(low+high)/2
    bpy.ops.object.camera_add(location=center+Vector((3.7,-5.5,3.2)));camera=bpy.context.object
    camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
    camera.data.type='ORTHO';basis=camera.rotation_euler.to_matrix().transposed()
    projected=[basis @ (c-center) for c in corners]
    camera.data.ortho_scale=max(max(c[i] for c in projected)-min(c[i] for c in projected) for i in [0,1])*1.22;scene.camera=camera
    for loc,energy,size in [((2,-3,5),450,5),((-3,-1,2),280,4),((1,4,4),600,3)]:
        bpy.ops.object.light_add(type='AREA',location=loc);light=bpy.context.object;light.data.energy=energy;light.data.shape='DISK';light.data.size=size
        light.rotation_euler=(-light.location).to_track_quat('-Z','Y').to_euler()
    scene.render.image_settings.file_format='PNG';scene.render.filepath=str(path)
    bpy.ops.render.render(write_still=True)

only = set(sys.argv[sys.argv.index('--')+1:]) if '--' in sys.argv else set()
if only - {row[0] for row in SPECS}:raise ValueError('Unknown model keys: '+str(only - {row[0] for row in SPECS}))
records=json.loads((MODELS/'manifest.json').read_text()) if only else []
for key,label,category,tags,build in SPECS:
    if only and key not in only:continue
    variants={}
    for variant in ['lite','quality']:
        quality=variant;bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False);mats={}
        build()
        meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
        for o in meshes:
            bpy.context.view_layer.objects.active=o
            for modifier in list(o.modifiers):bpy.ops.object.modifier_apply(modifier=modifier.name)
        # Static originals have no skins/animation. Join geometry into one mesh
        # with a small material primitive set instead of one draw per object.
        if any(o.animation_data or o.data.shape_keys for o in meshes):
            raise RuntimeError('Static merge cannot process animation/morphs')
        bpy.ops.object.select_all(action='DESELECT')
        for o in meshes:o.select_set(True)
        bpy.context.view_layer.objects.active=meshes[0]
        if len(meshes)>1:bpy.ops.object.join()
        meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
        # No embedded lights/camera, so browser lighting remains calibrated.
        path=MODELS/f'{key}-{variant}.glb'
        bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',export_cameras=False,export_lights=False,export_animations=False)
        for o in meshes:o.data.calc_loop_triangles()
        data=path.read_bytes();variants[variant]={'path':'/models/original-v1/'+path.name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),
          'triangles':sum(len(o.data.loop_triangles) for o in meshes)}
        if variant=='quality':render_thumbnail(THUMBS/f'{key}.png')
    records=[r for r in records if r['id'] != 'sutols-'+key]
    records.append({'id':'sutols-'+key,'label':label,'labelEn':'3d printer' if key=='three-d-printer' else key.replace('-',' '),'category':category,'tags':tags,'variants':variants,
      'thumbnail':'/model_thumbnails/original-v1/'+key+'.png','license':'Original procedural Sutols asset; see ORIGINAL_MODELS_LICENSE.md',
      'description':'Şematik eğitim modeli; ölçek ve fiziksel ayrıntılar temsilidir.','version':1})
    (MODELS/'manifest.json').write_text(json.dumps(records,ensure_ascii=False,indent=2))
print('Generated',len(records),'original teaching models.')
