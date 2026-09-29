from pathlib import Path
import struct
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(r'C:\sutol\Sutols'); STL=ROOT/'_fdr_source'/'cad'/'YigidoAnka_İHA_Bilgileri'/'01_CAD_Dosyalari'; OUT=ROOT/'_fdr_cad_figures'; OUT.mkdir(exist_ok=True)
def mesh(name):
    b=(STL/name).read_bytes(); n=struct.unpack_from('<I',b,80)[0]; dt=np.dtype([('n','<f4',(3,)),('v','<f4',(3,3)),('a','<u2')])
    return np.frombuffer(b,dtype=dt,offset=84,count=n)['v'].reshape(-1,3)
def f(size,bold=False):
    p=Path(r'C:\Windows\Fonts\arialbd.ttf' if bold else r'C:\Windows\Fonts\arial.ttf')
    return ImageFont.truetype(p,size) if p.exists() else ImageFont.load_default()
F10,F13,F16,F22=f(18),f(22),f(26,True),f(32,True); BLUE=(35,88,145); DARK=(25,35,50); GRID=(220,225,230); RED=(185,35,35); GREY=(80,90,100)
def view(points,axes,title,dims,outname,labels=()):
    u,v=axes; p=points[:,[u,v]]; lo=p.min(0); hi=p.max(0); span=np.maximum(hi-lo,1e-8); W,H=1600,1000; L,T,R,B=150,110,150,145; scale=min((W-L-R)/span[0],(H-T-B)/span[1]); origin=np.array([L,H-B])
    def xy(a): return (origin+np.column_stack(((a[:,0]-lo[0])*scale,-(a[:,1]-lo[1])*scale))).astype(int)
    im=Image.new('RGB',(W,H),'white'); d=ImageDraw.Draw(im); d.rectangle((L,T,W-R,H-B),outline=BLUE,width=3)
    for k in range(1,10):
        x=L+(W-L-R)*k/10; y=T+(H-T-B)*k/8; d.line((x,T,x,H-B),fill=GRID); d.line((L,y,W-R,y),fill=GRID)
    q=xy(p[::max(1,len(p)//35000)])
    for x,y in q:
        if L<=x<=W-R and T<=y<=H-B: d.point((x,y),fill=DARK)
    d.text((L,35),title,fill=DARK,font=F22); d.text((L,75),'Kaynak: RevC STL CAD geometrisi | Ölçüler mm',fill=GREY,font=F10)
    for kind,text in dims:
        if kind=='h':
            y=H-B+42; x1=L; x2=W-R; d.line((x1,y,x2,y),fill=RED,width=3); d.polygon([(x1,y),(x1+15,y-7),(x1+15,y+7)],fill=RED); d.polygon([(x2,y),(x2-15,y-7),(x2-15,y+7)],fill=RED); bb=d.textbbox((0,0),text,font=F13); tx=(x1+x2-(bb[2]-bb[0]))/2; d.rectangle((tx-10,y-36,tx+bb[2]-bb[0]+10,y-4),fill='white'); d.text((tx,y-34),text,fill=RED,font=F13)
        elif kind=='v':
            x=L-52; y1=T; y2=H-B; d.line((x,y1,x,y2),fill=RED,width=3); d.polygon([(x,y1),(x-7,y1+15),(x+7,y1+15)],fill=RED); d.polygon([(x,y2),(x-7,y2-15),(x+7,y2-15)],fill=RED); d.text((12,(y1+y2)/2),text,fill=RED,font=F13)
    for xf,yf,t in labels:
        x=L+(W-L-R)*xf; y=T+(H-T-B)*yf; d.rounded_rectangle((x,y,x+310,y+42),radius=8,fill=(242,246,250),outline=BLUE,width=2); d.text((x+9,y+9),t,fill=DARK,font=F10)
    im.save(OUT/outname)
A=mesh('Yigido_ANKA_Nihai_Montaj.stl')
view(A,(0,1),'RevC Tam Montaj Üstten Görünüş',[('h','Kanat açıklığı b = 2400,051 mm')],'cad_01_planform.png',[(.06,.08,'Ana kanat planformu'),(.58,.13,'T-kuyruk')])
view(A,(0,2),'RevC Tam Montaj Yan Görünüş',[('h','Tam montaj uzunluğu = 1501,102 mm'),('v','Tam yükseklik = 523,565 mm')],'cad_02_side.png',[(.08,.22,'Burun/gövde'),(.56,.12,'Kanat'),(.72,.30,'Motor ve pervane'),(.80,.10,'T-kuyruk')])
view(np.vstack([mesh('SagKanat (1).stl'),mesh('SolKanat (1).stl')]),(0,1),'Ana Kanat Planform ve Simetri',[('h','b = 2400,051 mm')],'cad_03_wing_pair.png',[(.08,.10,'c_root = 266,560 mm'),(.70,.10,'c_tip = 266,560 mm'),(.45,.62,'Sabit-veterli ana taşıyıcı')])
view(mesh('Govde.stl'),(0,2),'Gövde Kabuk Yan Görünüş',[('h','Gövde zarf uzunluğu = 1450,000 mm')],'cad_04_fuselage.png',[(.06,.18,'Ön gövde'),(.43,.22,'Kanat arayüzü'),(.78,.25,'Arka gövde')])
view(np.vstack([mesh('Elevator.stl'),mesh('Rudder.stl')]),(0,2),'Kuyruk Takımı Hareketli Yüzey Detayı',[('h','Elevator açıklığı = 820,000 mm'),('v','Rudder yüksekliği = 350,000 mm')],'cad_05_tail.png',[(.12,.20,'Elevator: 170,000 mm veter'),(.62,.15,'Rudder: 180,657 mm veter')])
view(np.vstack([mesh('SagAileron.stl'),mesh('SolAileron.stl'),mesh('Elevator.stl'),mesh('Rudder.stl')]),(0,1),'Kontrol Yüzeyleri CAD Zarf Özeti',[('h','Aileron açıklığı = 550,000 mm')],'cad_06_controls.png',[(.08,.14,'Sağ aileron: 51,270 mm veter'),(.45,.14,'Sol aileron: 53,629 mm veter'),(.25,.60,'Elevator / rudder ayrı hareketli yüzeyler')])
view(np.vstack([mesh('motor.stl'),mesh('SagPervane.stl')]),(1,2),'İtki Grubu CAD Zarfı',[('h','Pervane zarf boyutu = 199,993 mm')],'cad_07_propulsion.png',[(.08,.18,'Motor'),(.61,.30,'Pervane')])
view(mesh('Parachute_Release.stl'),(0,2),'Paraşüt Bırakma Mekanizması CAD Zarfı',[('h','Uzunluk = 65,958 mm'),('v','Yükseklik = 46,833 mm')],'cad_08_parachute.png',[(.22,.18,'Parachute_Release')])
print('\n'.join(str(p) for p in OUT.glob('*.png')))
