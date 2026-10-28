"""Second 50 original schematic teaching models. Geometry helpers supplied by the builder.
No external meshes, images, brands, rig, animation or textures. Not a simulation.
"""
import bpy, math
from mathutils import Vector

def additional_specs(h):
    box,rod,ring,sphere,finish = [h[k] for k in ['box','rod','ring','sphere','finish']]
    def resolution(lite,quality):return lite if h['quality']=='lite' else quality
    def cone(name,p,r1,r2,height,color):
        bpy.ops.mesh.primitive_cone_add(vertices=resolution(32,64),radius1=r1,radius2=r2,depth=height,location=p)
        return finish(bpy.context.object,name,color)
    def mesh(name,vertices,faces,color):
        data=bpy.data.meshes.new(name);data.from_pydata(vertices,[],faces);data.update()
        obj=bpy.data.objects.new(name,data);bpy.context.collection.objects.link(obj);return finish(obj,name,color)
    def path(name,points,r,color):
        curve=bpy.data.curves.new(name,'CURVE');curve.dimensions='3D'
        curve.bevel_depth=r;curve.bevel_resolution=resolution(2,3);curve.use_fill_caps=True
        spline=curve.splines.new('POLY');spline.points.add(len(points)-1)
        for vertex,point in zip(spline.points,points):vertex.co=(*point,1)
        obj=bpy.data.objects.new(name,curve);bpy.context.collection.objects.link(obj)
        bpy.ops.object.select_all(action='DESELECT');obj.select_set(True);bpy.context.view_layer.objects.active=obj
        bpy.ops.object.convert(target='MESH');finish(bpy.context.object,name,color)
    def shell(name,r,height,color,wall=.06):
        n=resolution(32,64);verts=[]
        for z,radius in [(0,r),(height,r),(0,r-wall),(height,r-wall)]:
            verts.extend([(radius*math.cos(i*2*math.pi/n),radius*math.sin(i*2*math.pi/n),z) for i in range(n)])
        faces=[]
        for i in range(n):
            j=(i+1)%n
            faces.extend([(i,j,n+j,n+i),(2*n+j,2*n+i,3*n+i,3*n+j),
                          (n+i,n+j,3*n+j,3*n+i),(j,i,2*n+i,2*n+j)])
        return mesh(name,verts,faces,color)
    def arch(center,radius,color,r=.09):
        cx,cy,cz=center;n=resolution(20,40)
        path('Arch',[(cx+radius*math.cos(i*math.pi/n),cy,cz+radius*math.sin(i*math.pi/n)) for i in range(n+1)],r,color)
    def build(key):
        if key=='hollow-tube':shell('Hollow cylinder',.65,1.5,'teal',.16)
        elif key=='conical-frustum':cone('Frustum',(0,0,.7),.8,.35,1.4,'gold')
        elif key=='sine-curve':
            rod('Axis',(-1.7,0,0),(1.7,0,0),.025,'navy')
            n=resolution(50,100);path('Sine',[(x,0,.55*math.sin(2*x)) for x in [-math.pi/2+i*math.pi/n for i in range(n+1)]],.04,'teal')
        elif key=='paraboloid':
            n=resolution(32,64);levels=resolution(10,16)
            verts=[(0,0,0)]
            for j in range(1,levels+1):
                r=j/levels;verts.extend([(r*math.cos(i*2*math.pi/n),r*math.sin(i*2*math.pi/n),r*r) for i in range(n)])
            faces=[(0,1+i,1+(i+1)%n) for i in range(n)]
            for j in range(levels-1):
                for i in range(n):a=1+j*n+i;b=1+j*n+(i+1)%n;faces.append((a,b,b+n,a+n))
            mesh('Paraboloid surface',verts,faces,'blue')
        elif key=='mobius-strip':
            n=resolution(64,128);verts=[]
            for i in range(n):
                t=i*2*math.pi/n
                for w in [-.23,.23]:verts.append(((1+w*math.cos(t/2))*math.cos(t),(1+w*math.cos(t/2))*math.sin(t),w*math.sin(t/2)))
            faces=[(2*i,2*i+1,2*i+3,2*i+2) for i in range(n-1)]+[(2*n-2,2*n-1,0,1)]
            mesh('Mobius strip',verts,faces,'gold')
        elif key=='horseshoe-magnet':
            arch((0,0,.35),.6,'red',.13);rod('North leg',(-.6,0,.35),(-.6,0,-.6),.13,'red');rod('South leg',(.6,0,.35),(.6,0,-.6),.13,'blue')
            rod('North tip',(-.6,0,-.6),(-.6,0,-.75),.13,'white');rod('South tip',(.6,0,-.6),(.6,0,-.75),.13,'white')
        elif key=='bar-magnet':
            box('North',(-.5,0,0),(1,.38,.38),'red');box('South',(.5,0,0),(1,.38,.38),'blue')
        elif key=='solenoid':
            rod('Core',(-1,0,0),(1,0,0),.23,'navy');n=resolution(96,160)
            path('Winding',[(-.8+1.6*i/n,.32*math.sin(i*12*math.pi/n),.32*math.cos(i*12*math.pi/n)) for i in range(n+1)],.035,'gold')
        elif key=='double-pulley':
            ring('Upper',(0,0,.85),.30,.075,'teal',(math.pi/2,0,0));ring('Lower',(.12,0,-.2),.30,.075,'gold',(math.pi/2,0,0))
            rod('Support',(-.7,0,1.3),(.7,0,1.3),.06,'navy');rod('Hanger',(0,0,1.3),(0,0,.85),.045,'navy')
            path('Rope',[(-.3,0,1.25),(-.3,0,.85),(-.18,0,-.2),(.42,0,-.2),(.3,0,.85),(.3,0,-.55)],.02,'white')
            box('Load',(.12,0,-.68),(.40,.35,.32),'red')
        elif key=='inclined-plane':
            mesh('Ramp',[(-1,-.5,0),(1,-.5,0),(1,-.5,.8),(-1,.5,0),(1,.5,0),(1,.5,.8)],[(0,2,1),(3,4,5),(0,1,4,3),(1,2,5,4),(2,0,3,5)],'navy')
            o=box('Block',(.3,0,.64),(.35,.4,.25),'gold');o.rotation_euler.y=-math.atan(.4)
        elif key=='conical-flask':
            cone('Flask body',(0,0,.55),.6,.20,1.1,'teal');shell('Neck',.2,.42,'white').location.z=1.05
        elif key=='round-flask':
            sphere('Flask body',(0,0,.6),.6,'teal');shell('Neck',.18,.65,'white').location.z=1.0
            ring('Stand',(0,0,-.01),.33,.045,'navy')
        elif key=='test-tube-rack':
            box('Rack base',(0,0,0),(1.6,.55,.12),'navy');box('Rack upper',(0,0,.75),(1.6,.55,.08),'gold')
            for x in [-.55,-.18,.18,.55]:
                rod('Test tube',(x,0,.15),(x,0,1.2),.1,'teal');sphere('Rounded bottom',(x,0,.15),.1,'teal')
        elif key=='laboratory-funnel':
            n=resolution(32,64);verts=[]
            for z,r in [(.3,.15),(1,.65),(.3,.10),(1,.60)]:
                verts.extend([(r*math.cos(i*2*math.pi/n),r*math.sin(i*2*math.pi/n),z) for i in range(n)])
            faces=[]
            for i in range(n):
                j=(i+1)%n;faces.extend([(i,j,n+j,n+i),(2*n+j,2*n+i,3*n+i,3*n+j),(n+i,n+j,3*n+j,3*n+i),(j,i,2*n+i,2*n+j)])
            mesh('Open funnel',verts,faces,'teal');shell('Stem',.09,.35,'white')
        elif key=='laboratory-beaker':
            shell('Open beaker',.6,1.1,'teal');cone('Bottom',(0,0,.025),.6,.6,.05,'teal')
            for z in [.25,.5,.75,1.0]:rod('Graduation',(-.18,-.605,z),(.18,-.605,z),.012,'white')
        elif key=='water-wheel':
            for y in [-.18,.18]:ring('Wheel rim',(0,y,0),.8,.07,'navy',(math.pi/2,0,0))
            rod('Axle',(0,-.45,0),(0,.45,0),.13,'gold')
            for i in range(12):
                a=i*2*math.pi/12;rod('Spoke',(0,0,0),(.76*math.sin(a),0,.76*math.cos(a)),.035,'gold')
                o=box('Paddle',(.8*math.sin(a),0,.8*math.cos(a)),(.24,.44,.14),'teal');o.rotation_euler.y=a
        elif key=='hydroelectric-dam':
            box('Dam wall',(0,0,.8),(2,.28,1.6),'navy');box('Water side',(0,.55,.3),(2,.8,.3),'blue')
            for x in [-.65,0,.65]:box('Gate',(x,-.16,.65),(.36,.1,.8),'teal');rod('Discharge',(x,-.22,.3),(x,-.6,.05),.07,'blue')
        elif key=='solar-array':
            for x in [-.55,.55]:
                for y in [-.5,.5]:
                    box('Panel',(x,y,.65),(.94,.85,.08),'navy')
                    for line in range(5):box('Cell divider',(x-.38+line*.19,y,.697),(.015,.82,.005),'teal',0)
                    rod('Leg',(x,y,.1),(x,y,.6),.04,'white')
        elif key=='radiator':
            for x in [-.6,-.3,0,.3,.6]:box('Radiator fin',(x,0,.65),(.18,.3,1.25),'white')
            for z in [.13,1.15]:rod('Header',(-.85,0,z),(.85,0,z),.055,'teal')
        elif key=='heat-exchanger':
            box('Frame',(0,0,.4),(1.7,.12,.9),'navy')
            for y,color in [(-.18,'red'),(.18,'blue')]:
                points=[]
                for i in range(6):x=-.75+i*.3;points.extend([(x,y,.1 if i%2==0 else .75),(x,y,.75 if i%2==0 else .1)])
                path('Separate fluid circuit',points,.045,color)
        elif key=='truss-bridge':
            box('Bridge deck',(0,0,0),(2.4,.75,.12),'navy')
            for y in [-.37,.37]:
                rod('Upper rail',(-1.2,y,.7),(1.2,y,.7),.035,'white')
                for i in range(5):
                    x=-1.2+i*.6;rod('Truss post',(x,y,0),(x,y,.7),.035,'teal')
                    if i<4:rod('Diagonal',(x,y,0),(x+.6,y,.7),.035,'gold')
        elif key=='hex-bolt':
            bpy.ops.mesh.primitive_cone_add(vertices=6,radius1=.35,radius2=.35,depth=.24,location=(0,0,1.1))
            head=finish(bpy.context.object,'Hex head','navy')
            for face in head.data.polygons:face.use_smooth=False
            rod('Shank',(0,0,0),(0,0,1),.15,'white')
            for z in [.08+i*.08 for i in range(10)]:ring('Thread',(0,0,z),.16,.018,'gold')
        elif key=='hex-nut':
            n=6;verts=[]
            for z,r in [(0,.7),(.45,.7),(0,.32),(.45,.32)]:verts.extend([(r*math.cos(i*2*math.pi/n),r*math.sin(i*2*math.pi/n),z) for i in range(n)])
            faces=[]
            for i in range(n):j=(i+1)%n;faces.extend([(i,j,n+j,n+i),(2*n+j,2*n+i,3*n+i,3*n+j),(n+i,n+j,3*n+j,3*n+i),(j,i,2*n+i,2*n+j)])
            nut=mesh('Hex nut',verts,faces,'gold')
            for face in nut.data.polygons:face.use_smooth=False
        elif key=='ball-bearing':
            ring('Outer race',(0,0,0),.85,.13,'navy');ring('Inner race',(0,0,0),.43,.10,'white')
            for i in range(10):a=i*2*math.pi/10;sphere('Bearing ball',(.65*math.cos(a),.65*math.sin(a),0),.105,'gold')
        elif key=='universal-joint':
            rod('Input',(-1,0,0),(-.45,0,0),.1,'white');rod('Output',(.45,0,0),(1,0,0),.1,'white')
            ring('Fork one',(-.35,0,0),.32,.07,'teal',(0,math.pi/2,0));ring('Fork two',(.35,0,0),.32,.07,'gold',(0,math.pi/2,0))
            rod('Cross',(0,-.3,0),(0,.3,0),.07,'navy');rod('Cross',(0,0,-.3),(0,0,.3),.07,'navy')
        elif key=='communications-satellite':
            box('Payload',(0,0,0),(.6,.5,.6),'gold')
            for x in [-.9,.9]:box('Solar wing',(x,0,0),(1,.08,.65),'navy');rod('Wing boom',(0,0,0),(x,0,0),.035,'white')
            ring('Dish',(0,-.35,.25),.22,.055,'white',(math.pi/2,0,0));rod('Antenna',(0,-.35,.25),(0,-.65,.25),.015,'white')
        elif key=='ringed-planet':
            sphere('Planet',(0,0,0),.6,'gold')
            for r in [.9,1.02,1.14]:ring('Planet ring',(0,0,0),r,.035,'white',(.22,0,0))
        elif key=='lunar-lander':
            box('Landing module',(0,0,.7),(.7,.65,.75),'gold');cone('Engine',(0,0,.18),.2,.1,.25,'navy')
            for x,y in [(-.65,-.65),(-.65,.65),(.65,-.65),(.65,.65)]:rod('Leg',(0,0,.55),(x,y,0),.035,'white');box('Foot',(x,y,0),(.25,.25,.06),'navy')
        elif key=='space-station':
            rod('Main module',(-.9,0,0),(.9,0,0),.25,'white');rod('Cross module',(0,-.65,0),(0,.65,0),.22,'white')
            for x in [-1.2,1.2]:
                for y in [-.55,.55]:box('Solar arrays',(x,y,0),(.55,.8,.055),'navy')
            rod('Solar boom',(-1.2,0,0),(1.2,0,0),.03,'gold')
        elif key=='astronomical-telescope':
            rod('Tube',(-.65,0,1.3),(.65,0,1.7),.18,'navy');ring('Objective',(.65,0,1.7),.18,.03,'gold',(0,math.pi/2,0))
            for x,y in [(-.6,-.4),(.6,-.4),(0,.6)]:rod('Tripod',(0,0,1.1),(x,y,0),.035,'white')
        elif key=='laptop':
            box('Keyboard deck',(0,0,0),(1.5,1,.08),'navy');box('Screen bezel',(0,.46,.55),(1.5,.08,1.1),'navy');box('Display',(0,.411,.58),(1.3,.014,.86),'teal',0)
            for x in [-.5,-.25,0,.25,.5]:
                for y in [-.1,.1]:box('Key',(x,y,.052),(.16,.12,.02),'white',0)
        elif key=='smartphone':
            box('Phone body',(0,0,0),(.72,.11,1.4),'navy');box('Display',(0,-.065,0),(.60,.015,1.18),'teal',0);sphere('Camera',(0,-.08,.63),.025,'white')
        elif key=='server-rack':
            box('Rack cabinet',(0,0,.85),(1,.7,1.7),'navy')
            for z in [.18,.45,.72,.99,1.26,1.53]:box('Server drawer',(0,-.37,z),(.86,.05,.20),'white');sphere('Indicator',(-.32,-.41,z),.025,'teal')
        elif key=='robotic-arm':
            box('Base',(0,0,0),(.8,.7,.12),'navy');sphere('Joint one',(0,0,.2),.18,'gold')
            rod('Lower arm',(0,0,.2),(.35,0,.95),.11,'teal');sphere('Elbow',(.35,0,.95),.16,'gold')
            rod('Upper arm',(.35,0,.95),(.95,0,1.2),.09,'teal');sphere('Wrist',(.95,0,1.2),.11,'gold')
            for y in [-.13,.13]:rod('Gripper',(.95,y,1.2),(1.2,y,1.2),.035,'white')
        elif key=='three-d-printer':
            box('Printer base',(0,0,0),(1.3,1.1,.13),'navy');box('Build plate',(0,0,.12),(.9,.85,.05),'teal')
            for x in [-.55,.55]:rod('Vertical rail',(x,0,.1),(x,0,1.4),.04,'white')
            rod('Gantry',(-.55,0,1),(.55,0,1),.04,'white');box('Print head',(0,0,.94),(.22,.22,.2),'gold');cone('Nozzle',(0,0,.78),.025,.065,.12,'gold')
        elif key=='breadboard':
            box('Breadboard',(0,0,0),(1.6,.9,.12),'white')
            for x in range(12):
                for y in [-.27,-.13,.13,.27]:
                    n=resolution(8,12);cx=-.66+x*.12
                    mesh('Contact marking',[(cx+.02*math.cos(i*2*math.pi/n),y+.02*math.sin(i*2*math.pi/n),.061) for i in range(n)],[tuple(range(n))],'navy')
            for y,color in [(-.38,'red'),(.38,'blue')]:rod('Power rail',(-.70,y,.065),(.70,y,.065),.012,color)
        elif key=='potentiometer':
            cone('Body',(0,0,.15),.35,.35,.3,'navy');rod('Shaft',(0,0,.3),(0,0,.85),.08,'white');cone('Knob',(0,0,.83),.19,.19,.2,'teal')
            for x in [-.22,0,.22]:rod('Terminal',(x,-.25,.13),(x,-.55,.13),.02,'gold')
        elif key=='toggle-switch':
            box('Switch body',(0,0,0),(.65,.45,.35),'navy');rod('Toggle',(0,0,.15),(.2,0,.7),.04,'white');sphere('Toggle cap',(.2,0,.7),.09,'teal')
            for x in [-.18,.18]:rod('Terminal',(x,0,-.15),(x,0,-.4),.02,'gold')
        elif key=='electronic-inductor':
            cone('Core',(0,0,.3),.22,.22,.6,'navy');n=resolution(80,120)
            path('Coil',[(.29*math.cos(i*10*math.pi/n),.29*math.sin(i*10*math.pi/n),.04+.52*i/n) for i in range(n+1)],.035,'gold')
            for x in [-.29,.29]:rod('Lead',(x,0,0),(x,0,-.35),.02,'white')
        elif key=='printed-circuit-board':
            box('PCB',(0,0,0),(1.6,1.1,.06),'teal')
            for x,y in [(-.4,-.2),(.35,.2)]:box('IC',(x,y,.1),(.42,.27,.13),'navy')
            for y in [-.40,-.30,0,.30,.40]:path('Copper trace',[(-.7,y,.036),(-.05,y,.036),(.15,y+.06,.036),(.7,y+.06,.036)],.012,'gold')
        elif key=='stone-arch':
            arch((0,0,.75),.8,'white',.17)
            for x in [-.8,.8]:box('Pier',(x,0,.35),(.34,.45,.7),'navy')
        elif key=='castle-tower':
            cone('Tower',(0,0,.8),.6,.6,1.6,'white')
            for i in range(8):a=i*2*math.pi/8;box('Battlement',(.52*math.cos(a),.52*math.sin(a),1.72),(.22,.22,.25),'navy')
            box('Door',(0,-.603,.3),(.24,.02,.55),'gold',0)
        elif key=='obelisk':
            mesh('Obelisk',[(-.22,-.22,0),(.22,-.22,0),(.22,.22,0),(-.22,.22,0),(-.14,-.14,1.5),(.14,-.14,1.5),(.14,.14,1.5),(-.14,.14,1.5),(0,0,1.85)],[(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(0,3,2,1),(4,5,8),(5,6,8),(6,7,8),(7,4,8)],'gold');box('Plinth',(0,0,-.08),(.65,.65,.16),'navy')
        elif key=='amphitheatre':
            for j in range(5):
                r=.55+j*.18;n=resolution(24,40)
                path('Seating tier',[(r*math.cos(i*math.pi/n),r*math.sin(i*math.pi/n),j*.14) for i in range(n+1)],.07,'white')
            box('Stage',(0,-.1,0),(.8,.3,.06),'gold')
        elif key=='aqueduct':
            for x in [-1,0,1]:arch((x,0,.65),.43,'white',.10)
            for x in [-1.43,-.5,.5,1.43]:box('Pier',(x,0,.3),(.14,.25,.6),'navy')
            box('Water channel',(0,0,1.16),(3.1,.3,.15),'teal')
        elif key=='mountain':
            mesh('Mountain',[(-1,-.6,0),(.8,-.7,0),(1,.6,0),(-.7,.8,0),(.05,.1,1.25)],[(0,1,4),(1,2,4),(2,3,4),(3,0,4),(0,3,2,1)],'navy')
            cone('Snow cap',(.05,.1,1.11),.15,0,.29,'white')
        elif key=='leaf':
            verts=[(0,-1,0),(0,1,0)]+[(s*.45*math.sin(i*math.pi/8),-1+i*.25,.04*math.sin(i*math.pi/8)) for s in [-1,1] for i in range(1,8)]
            faces=[]
            outline=[0]+list(range(2,9))+[1]+list(range(15,8,-1))
            mesh('Leaf blade',verts,[tuple(outline)],'teal');rod('Midrib',(0,-1.15,.025),(0,.96,.025),.025,'gold')
            for y in [-.6,-.3,0,.3,.6]:
                for side in [-1,1]:rod('Leaf vein',(0,y,.05),(side*.40*math.sin((y+1)*math.pi/2),y+.18,.05),.012,'white')
        elif key=='snowflake':
            for i in range(6):
                a=i*math.pi/3;end=(math.cos(a),math.sin(a),0);rod('Crystal arm',(0,0,0),end,.035,'white')
                for r in [.45,.7]:
                    start=(r*math.cos(a),r*math.sin(a),0)
                    for s in [-1,1]:rod('Crystal branch',start,(start[0]+.23*math.cos(a+s*math.pi/3),start[1]+.23*math.sin(a+s*math.pi/3),0),.025,'teal')
        elif key=='quartz-crystal':
            verts=[]
            for z,r in [(0,.42),(1.0,.42)]:verts.extend([(r*math.cos(i*math.pi/3),r*math.sin(i*math.pi/3),z) for i in range(6)])
            verts.append((0,0,1.38))
            faces=[(i,(i+1)%6,(i+1)%6+6,i+6) for i in range(6)]+[(i+6,(i+1)%6+6,12) for i in range(6)]+[(5,4,3,2,1,0)]
            mesh('Schematic crystal',verts,faces,'blue')
        elif key=='flower':
            rod('Stem',(0,0,-1),(0,0,0),.035,'teal');sphere('Center',(0,0,0),.19,'gold')
            for i in range(8):a=i*math.pi/4;o=sphere('Petal',(.36*math.cos(a),.36*math.sin(a),0),.22,'white');o.scale=(1,1,.35)
            for x in [-.25,.25]:o=sphere('Leaf',(x,0,-.5),.2,'teal');o.scale=(1,.3,.5)
        else:raise ValueError('Unknown extension '+key)
    rows=[
      ('hollow-tube','İçi Boş Silindir','Matematik',['içi boş silindir','silindir boru','hollow cylinder']),
      ('conical-frustum','Kesik Koni','Matematik',['kesik koni','conical frustum']),
      ('sine-curve','Sinüs Eğrisi','Matematik',['sinüs eğrisi','sine curve','trigonometri']),
      ('paraboloid','Paraboloit Yüzeyi','Matematik',['paraboloit','paraboloid','parabol yüzeyi']),
      ('mobius-strip','Möbius Şeridi','Matematik',['möbius şeridi','mobius strip','topoloji']),
      ('horseshoe-magnet','At Nalı Mıknatıs','Fizik',['at nalı mıknatıs','horseshoe magnet']),
      ('bar-magnet','Çubuk Mıknatıs','Fizik',['çubuk mıknatıs','bar magnet']),
      ('solenoid','Solenoid Şeması','Fizik',['solenoid','elektromıknatıs','electromagnet']),
      ('double-pulley','İki Makaralı Sistem Şeması','Fizik',['iki makaralı sistem','double pulley','makara sistemi']),
      ('inclined-plane','Eğik Düzlem Şeması','Fizik',['eğik düzlem','inclined plane','rampa']),
      ('conical-flask','Erlenmeyer Şeması','Kimya',['erlenmeyer','conical flask']),
      ('round-flask','Yuvarlak Balon Şeması','Kimya',['yuvarlak balon','round bottom flask','laboratuvar balonu']),
      ('test-tube-rack','Deney Tüpü Rafı','Kimya',['deney tüpü','test tube rack','tüp rafı']),
      ('laboratory-funnel','Laboratuvar Hunisi','Kimya',['laboratuvar hunisi','laboratory funnel','huni']),
      ('laboratory-beaker','Beher Şeması','Kimya',['beher','laboratory beaker','beaker']),
      ('water-wheel','Su Çarkı Şeması','Enerji',['su çarkı','water wheel','hidrolik enerji']),
      ('hydroelectric-dam','Hidroelektrik Baraj Şeması','Enerji',['hidroelektrik baraj','hydroelectric dam']),
      ('solar-array','Güneş Paneli Dizisi','Enerji',['güneş paneli dizisi','solar array','güneş santrali']),
      ('radiator','Radyatör Şeması','Enerji',['radyatör','radiator','ısıtma peteği']),
      ('heat-exchanger','Isı Eşanjörü Şeması','Enerji',['ısı eşanjörü','heat exchanger','iki akışkan']),
      ('truss-bridge','Kafes Köprü Şeması','Mühendislik',['kafes köprü','truss bridge']),
      ('hex-bolt','Cıvata Şeması','Mühendislik',['cıvata','bolt','bağlantı elemanı']),
      ('hex-nut','Altıgen Somun','Mühendislik',['altıgen somun','hex nut','somun']),
      ('ball-bearing','Bilyalı Rulman Şeması','Mühendislik',['bilyalı rulman','ball bearing']),
      ('universal-joint','Kardan Mafsalı Şeması','Mühendislik',['kardan mafsalı','universal joint']),
      ('communications-satellite','Haberleşme Uydusu Şeması','Uzay',['haberleşme uydusu','communications satellite','uydu']),
      ('ringed-planet','Halkalı Gezegen Şeması','Uzay',['halkalı gezegen','ringed planet','satürn']),
      ('lunar-lander','Ay İniş Aracı Şeması','Uzay',['ay iniş aracı','lunar lander']),
      ('space-station','Uzay İstasyonu Şeması','Uzay',['uzay istasyonu','space station']),
      ('astronomical-telescope','Astronomi Teleskobu Şeması','Uzay',['astronomi teleskobu','astronomical telescope','teleskop']),
      ('laptop','Dizüstü Bilgisayar','Teknoloji',['dizüstü bilgisayar','laptop','notebook']),
      ('smartphone','Akıllı Telefon','Teknoloji',['akıllı telefon','smartphone','cep telefonu']),
      ('server-rack','Sunucu Rafı','Teknoloji',['sunucu rafı','server rack','veri merkezi']),
      ('robotic-arm','Robot Kolu Şeması','Teknoloji',['robot kolu','robotic arm','robotik']),
      ('three-d-printer','3D Yazıcı Şeması','Teknoloji',['3d yazıcı','3b yazıcı','3d printer']),
      ('breadboard','Breadboard Şeması','Elektronik',['breadboard','deney devre tahtası']),
      ('potentiometer','Potansiyometre Şeması','Elektronik',['potansiyometre','potentiometer']),
      ('toggle-switch','Elektrik Anahtarı Şeması','Elektronik',['elektrik anahtarı','toggle switch']),
      ('electronic-inductor','Bobin Şeması','Elektronik',['bobin','electronic inductor','endüktör']),
      ('printed-circuit-board','Baskılı Devre Kartı Şeması','Elektronik',['baskılı devre kartı','printed circuit board','pcb']),
      ('stone-arch','Taş Kemer Şeması','Tarih ve Mimari',['taş kemer','stone arch','kemerli yapı']),
      ('castle-tower','Kale Kulesi Şeması','Tarih ve Mimari',['kale kulesi','castle tower']),
      ('obelisk','Dikilitaş Şeması','Tarih ve Mimari',['dikilitaş','obelisk']),
      ('amphitheatre','Amfitiyatro Şeması','Tarih ve Mimari',['amfitiyatro','amphitheatre']),
      ('aqueduct','Su Kemeri Şeması','Tarih ve Mimari',['su kemeri','aqueduct']),
      ('mountain','Dağ Şeması','Doğa',['dağ','mountain','dağ oluşumu']),
      ('leaf','Yaprak Şeması','Doğa',['yaprak','leaf','bitki yaprağı']),
      ('snowflake','Kar Tanesi Şeması','Doğa',['kar tanesi','snowflake','kar kristali']),
      ('quartz-crystal','Kristal Şeması','Doğa',['kristal','quartz crystal','kuvars']),
      ('flower','Çiçek Şeması','Doğa',['çiçek','flower','bitki çiçeği']),
    ]
    assert len(rows)==50 and len({row[0] for row in rows})==50
    return [(*row,lambda key=row[0]:build(key)) for row in rows]
