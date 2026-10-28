"""Original Sutols Republic Day motion design and instrumental, no stock media.

Requires Pillow, NumPy and imageio-ffmpeg (build/video-tools is supported).
Usage: python tool/render_republic_day_video.py
"""
from pathlib import Path
import sys, math, subprocess, wave, json
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'build/video-tools'))
import imageio_ffmpeg

OUT = ROOT/'deliverables/29-ekim-2026'
OUT.mkdir(parents=True, exist_ok=True)
W,H,FPS,DURATION = 1080,1920,30,20
WHITE=(255,248,237)
GOLD=(244,209,158)
FONTS={}
def font(size, bold=True):
    key=(size,bold)
    if key not in FONTS:
        FONTS[key]=ImageFont.truetype('C:/Windows/Fonts/'+('arialbd.ttf' if bold else 'arial.ttf'),size)
    return FONTS[key]

def ease(v):
    v=max(0,min(1,v));return v*v*(3-2*v)

def opacity(t,start,end):
    return ease((t-start)/.7)*ease((end-t)/.6)

def label(im,text,y,size,color=WHITE,alpha=1,spacing=0,bold=True):
    layer=Image.new('RGBA',im.size)
    d=ImageDraw.Draw(layer); f=font(size,bold)
    if spacing:
        widths=[d.textlength(c,font=f) for c in text]
        x=(W-sum(widths)-spacing*(len(text)-1))/2
        for c,width in zip(text,widths):
            d.text((x,y),c,font=f,fill=(*color,round(255*alpha)))
            x+=width+spacing
    else:
        d.text((W/2,y),text,font=f,anchor='mt',fill=(*color,round(255*alpha)),stroke_width=0)
    im.alpha_composite(layer)

def flag_texture():
    im=Image.new('RGB',(900,600),(227,10,23))
    mask=Image.new('L',im.size);d=ImageDraw.Draw(mask)
    d.ellipse((150,150,450,450),fill=255)
    d.ellipse((217.5,180,457.5,420),fill=0)
    pts=[]
    for i in range(10):
        a=-math.pi/2+math.pi/10+i*math.pi/5
        r=75 if i%2==0 else 28.65
        pts.append((516+math.cos(a)*r,300+math.sin(a)*r))
    d.polygon(pts,fill=255)
    im.paste((255,255,255),mask=mask)
    return np.array(im,dtype=np.float32)

FLAG=flag_texture()
FY,FX=np.mgrid[0:600,0:900].astype(np.float32)
BY,BX=np.mgrid[0:480,0:270].astype(np.float32)
MODEL=Image.open(ROOT/'web/model_thumbnails/cumhuriyet-29-ekim.png').convert('RGBA')
LOGO=Image.open(ROOT/'assets/images/logo.png').convert('RGBA')
LOGO.thumbnail((155,155),Image.Resampling.LANCZOS)

def frame(t):
    # Broad silk folds move slowly; the flag's star/crescent deform with its cloth.
    light=.10*np.sin(BX/36+BY/79-t*.7)+.045*np.sin(BX/11-BY/64+t*.45)
    vignette=((BX-140)/250)**2+((BY-180)/650)**2
    base=np.empty((480,270,3),dtype=np.float32)
    for i,c in enumerate((142,12,32)):
        base[:,:,i]=c*(1+light-vignette*.35)+light*35
    im=Image.fromarray(np.uint8(np.clip(base,0,255))).resize((W,H),Image.Resampling.BICUBIC).convert('RGBA')
    wave_phase=FX/110+FY/230-t*1.7
    source_y=np.clip(FY+np.sin(FX/140-t*1.6)*16*(FX/900),0,599).astype(np.int32)
    source_x=np.clip(FX+np.sin(FY/170+t)*5,0,899).astype(np.int32)
    cloth=FLAG[source_y,source_x]*(.88+.12*np.cos(wave_phase))[:,:,None]
    flag=Image.fromarray(np.uint8(np.clip(cloth,0,255))).convert('RGBA')
    flag.putalpha(245)
    # Soft black drop shadow, safe margins for social platform UI.
    shadow=Image.new('RGBA',(940,640),(0,0,0,0))
    ImageDraw.Draw(shadow).rectangle((20,20,920,620),fill=(30,0,0,110))
    shadow=shadow.filter(ImageFilter.GaussianBlur(24))
    top=205+round(9*math.sin(t*.7))
    im.alpha_composite(shadow,(70,top-4))
    im.alpha_composite(flag,(90,top))
    d=ImageDraw.Draw(im)
    d.line((135,144,945,144),fill=(*GOLD,100),width=1)
    # Broadcast masthead appears throughout, away from platform controls.
    label(im,'29 EKİM 2026',92,24,GOLD,spacing=5)

    a=opacity(t,0,5)
    if a:
        y=910+round((1-ease(t/1.2))*55)
        label(im,'BİR MİLLETİN',y,66,alpha=a)
        label(im,'SONSUZ IŞIĞI',y+90,74,alpha=a)
        label(im,'1923’TEN SONSUZA',y+225,27,GOLD,a,spacing=4)
        label(im,'Cumhuriyetin ışığında, birlikte.',y+330,31,WHITE,a,bold=False)
    a=opacity(t,4.7,10.5)
    if a:
        label(im,'29',850,270,WHITE,a)
        label(im,'EKİM',1130,95,WHITE,a,spacing=15)
        label(im,'CUMHURİYETİN 103. YILI',1300,31,GOLD,a,spacing=2)
        label(im,'İlelebet, aynı gururla.',1410,34,WHITE,a,bold=False)
    a=opacity(t,10.2,17)
    if a:
        label(im,'CUMHURİYET',845,68,WHITE,a)
        label(im,'BAYRAMIMIZ',930,68,WHITE,a)
        label(im,'KUTLU OLSUN',1020,67,GOLD,a)
        width=round(645+25*ease((t-10.2)/6))
        model=MODEL.resize((width,width),Image.Resampling.LANCZOS)
        model.putalpha(model.getchannel('A').point(lambda x:round(x*a)))
        im.alpha_composite(model,((W-width)//2,1110+round(8*math.sin(t))))
    a=opacity(t,16.7,21)
    if a:
        logo=LOGO.copy()
        logo.putalpha(logo.getchannel('A').point(lambda x:round(x*a)))
        im.alpha_composite(logo,((W-logo.width)//2,940))
        label(im,'SUTOLS',1130,79,WHITE,a,spacing=8)
        label(im,'Geleceği birlikte tasarlıyoruz.',1260,34,WHITE,a,bold=False)
        label(im,'sutols.com',1410,34,GOLD,a,spacing=3)
    # Fixed small anniversary footer and a quiet gold sweep.
    label(im,'1923  —  SONSUZA DEK',1740,22,GOLD,.8,spacing=3)
    endfade=1-ease((t-19.35)/.65)
    if endfade<1:
        im=Image.blend(Image.new('RGBA',(W,H),(40,3,10,255)),im,endfade)
    return im.convert('RGB')

def score():
    """Original C-major/A-minor instrumental: warm harmonics and soft percussion."""
    sr=48000
    audio=np.zeros((DURATION*sr,2),np.float64)
    rng=np.random.default_rng(1923)
    def note(start,duration,midi,volume=.1,pan=0):
        length=min(int(duration*sr),len(audio)-int(start*sr))
        if length<=0:return
        tt=np.arange(length)/sr
        frequency=440*2**((midi-69)/12)
        env=(1-np.exp(-tt*20))*np.exp(-tt/max(.2,duration*.6))
        wave=(np.sin(2*np.pi*frequency*tt)+.26*np.sin(4*np.pi*frequency*tt)+.09*np.sin(6*np.pi*frequency*tt))*env*volume
        offset=int(start*sr)
        audio[offset:offset+length,0]+=wave*math.sqrt((1-pan)/2)
        audio[offset:offset+length,1]+=wave*math.sqrt((1+pan)/2)
    chords=[(48,55,60,64),(45,52,57,60),(41,48,53,57),(43,50,55,59)]
    for bar in range(8):
        start=bar*2.5
        for n in chords[bar%4]:note(start,3.4,n,.085,(n%3-1)*.35)
        # Original rising, hopeful arpeggio; no quotation of any anthem/song.
        for beat,n in enumerate(chords[bar%4]+(chords[bar%4][2]+12,)):
            note(start+beat*.5,1.1,n+12,.095,math.sin(beat)*.3)
        if bar>=2:
            for beat in range(4):
                at=int((start+beat*.625)*sr)
                length=min(int(.25*sr),len(audio)-at)
                if length<=0:continue
                tt=np.arange(length)/sr
                drum=.10*np.sin(2*np.pi*(62*tt-35*tt**2))*np.exp(-tt*25)
                noise=rng.normal(0,1,length)*np.exp(-tt*60)*.018
                audio[at:at+length]+=((drum+noise)[:,None])
    # A short room echo and restrained master fade, avoiding abrupt endpoints.
    delay=int(.16*sr)
    audio[delay:]+=audio[:-delay]*.18
    times=np.arange(len(audio))/sr
    envelope=np.minimum(1,times/1.0)*np.clip((DURATION-times)/1.6,0,1)
    audio*=envelope[:,None]
    audio=np.tanh(audio*1.4)*.8
    path=OUT/'original-instrumental.wav'
    with wave.open(str(path),'wb') as f:
        f.setnchannels(2);f.setsampwidth(2);f.setframerate(sr)
        f.writeframes((audio*32767).astype('<i2').tobytes())
    return path

if __name__=='__main__':
    music=score()
    ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
    output=OUT/'Sutols-29-Ekim-2026-Reels-Shorts.mp4'
    cmd=[ffmpeg,'-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24','-s',f'{W}x{H}',
         '-r',str(FPS),'-i','-','-i',str(music),'-c:v','libx264','-preset','fast','-crf','18',
         '-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-ar','48000','-movflags','+faststart',
         '-t',str(DURATION),str(output)]
    with (OUT/'render.log').open('w') as log:
        proc=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=log,stderr=log)
        for idx in range(FPS*DURATION):
            im=frame(idx/FPS)
            proc.stdin.write(im.tobytes())
            if idx in (60,210,390,555):im.save(OUT/f'preview-{idx//FPS:02d}s.jpg',quality=94)
            if idx%90==0:print('FRAME',idx,'/',FPS*DURATION,flush=True)
        proc.stdin.close()
        if proc.wait()!=0:raise RuntimeError('FFmpeg failed; inspect render.log')
    subprocess.run([ffmpeg,'-y','-i',str(output),'-an','-c:v','copy',str(OUT/'Sutols-29-Ekim-2026-Sessiz.mp4')],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True)
    (OUT/'PAYLASIM.txt').write_text('''29 Ekim Cumhuriyet Bayramımız kutlu olsun! 🇹🇷
1923’ten sonsuza, aynı gururla.
Cumhuriyetimizin 103. yılında geleceği birlikte tasarlıyoruz.

Sutols • sutols.com
#29Ekim #CumhuriyetBayramı #Cumhuriyet #Sutols

Video: 1080×1920, 9:16, 30 fps, 20 saniye, H.264 MP4.
Müzik: Bu video için sentezlenmiş özgün enstrümantal.
Sessiz sürüm: Platformun müzik kütüphanesinden ayrıca müzik eklemek için.
Grafikler, bayrak animasyonu ve 3D model bu proje için oluşturulmuştur.
''',encoding='utf-8')
    print('VIDEO_READY',output,output.stat().st_size,flush=True)
