from pathlib import Path
from math import pi, sqrt
from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.shared import Mm, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(r"C:\sutol\Sutols")
OUT = ROOT / "output" / "Yiğido_ANKA_FDR_Bolum_3_1_6_Performans_Hesaplamalari.docx"
WORK = ROOT / "_fdr_316_work"
CAD = ROOT / "_fdr_source" / "cad" / "YigidoAnka_İHA_Bilgileri" / "05_Teknik_Resimler_ve_Görseller"
ASSEMBLY = ROOT / "_fdr_source" / "extracted_docx_media" / "image1.png"
WORK.mkdir(exist_ok=True)

# FDR geometry and mass used consistently throughout the calculation.
m, g, rho = 10.158917, 9.80665, 1.225
b, c_root, c_tip = 2.400051, 0.266560, 0.266560
S = ((c_root + c_tip) / 2) * b
AR = b*b/S
e, CD0, CLmax = 0.85, 0.028, 1.22
k = 1/(pi*AR*e)
W = m*g
CLopt = sqrt(CD0/k)
CDopt = CD0 + k*CLopt**2
LDmax = CLopt/CDopt
Vs = sqrt(2*W/(rho*S*CLmax))
Vopt = sqrt(2*W/(rho*S*CLopt))
Vcr = 18.0
qcr = .5*rho*Vcr**2
CLcr = W/(qcr*S)
CDcr = CD0 + k*CLcr**2
Dcr = qcr*S*CDcr
Paero = Dcr*Vcr
eta_prop, eta_motor = .72, .85
Pelec = Paero/(eta_prop*eta_motor)
Eusable = 22.2*8*.80
endmin = Eusable/Pelec*60
rangekm = Vcr*endmin*60/1000
nmax = qcr*S*CLmax/W
phi = __import__('math').degrees(__import__('math').acos(1/nmax))
Rturn = Vcr**2/(g*sqrt(nmax**2-1))

def shade(cell, fill):
    p=cell._tc.get_or_add_tcPr(); x=OxmlElement('w:shd'); x.set(qn('w:fill'),fill); p.append(x)
def border(cell, color='D9D9D9'):
    p=cell._tc.get_or_add_tcPr(); bdr=OxmlElement('w:tcBorders')
    for side in ('top','left','bottom','right','insideH','insideV'):
        x=OxmlElement('w:'+side); x.set(qn('w:val'),'single'); x.set(qn('w:sz'),'4'); x.set(qn('w:color'),color); bdr.append(x)
    p.append(bdr)
def margins(cell):
    p=cell._tc.get_or_add_tcPr(); x=OxmlElement('w:tcMar'); p.append(x)
    for side in ('top','start','bottom','end'):
        y=OxmlElement('w:'+side); y.set(qn('w:w'),'95'); y.set(qn('w:type'),'dxa'); x.append(y)
def repeat(row):
    x=OxmlElement('w:tblHeader'); x.set(qn('w:val'),'true'); row._tr.get_or_add_trPr().append(x)
def keep(par):
    par._p.get_or_add_pPr().append(OxmlElement('w:keepNext'))
def page_field(par):
    r=par.add_run('Sayfa '); f=OxmlElement('w:fldSimple'); f.set(qn('w:instr'),'PAGE'); par._p.append(f)

doc=Document(); sec=doc.sections[0]
sec.top_margin=Mm(20); sec.bottom_margin=Mm(18); sec.left_margin=Mm(22); sec.right_margin=Mm(18)
sec.header_distance=Mm(10); sec.footer_distance=Mm(10)
for sname in ('Normal','Title','Heading 1','Heading 2','Heading 3'):
    st=doc.styles[sname]; st.font.name='Arial'; st._element.rPr.rFonts.set(qn('w:ascii'),'Arial'); st._element.rPr.rFonts.set(qn('w:hAnsi'),'Arial'); st.font.color.rgb=RGBColor(0,0,0)
doc.styles['Normal'].font.size=Pt(10.5); doc.styles['Normal'].paragraph_format.line_spacing=1.18; doc.styles['Normal'].paragraph_format.space_after=Pt(7)
for sname,size in [('Title',16),('Heading 1',13),('Heading 2',11.5),('Heading 3',10.8)]:
    doc.styles[sname].font.size=Pt(size); doc.styles[sname].font.bold=True
doc.styles['Heading 1'].paragraph_format.space_before=Pt(14); doc.styles['Heading 1'].paragraph_format.space_after=Pt(8)
doc.styles['Heading 2'].paragraph_format.space_before=Pt(11); doc.styles['Heading 2'].paragraph_format.space_after=Pt(6)
hdr=sec.header.paragraphs[0]; hdr.alignment=WD_ALIGN_PARAGRAPH.RIGHT; hdr.add_run('Yiğido ANKA | FDR | Bölüm 3.1.6').font.size=Pt(8)
ftr=sec.footer.paragraphs[0]; ftr.alignment=WD_ALIGN_PARAGRAPH.CENTER; page_field(ftr); ftr.runs[0].font.size=Pt(8)

def h(txt, level=1):
    z=doc.add_paragraph(txt, style=f'Heading {level}'); keep(z); return z
def p(txt='', lead=None):
    z=doc.add_paragraph(); z.paragraph_format.first_line_indent=Mm(0 if lead else 6)
    if lead:
        a=z.add_run(lead); a.bold=True
    z.add_run(txt); return z
def eq(txt):
    z=doc.add_paragraph(); z.alignment=WD_ALIGN_PARAGRAPH.CENTER; r=z.add_run(txt); r.bold=True; r.font.name='Cambria Math'; r.font.size=Pt(11); return z
def fig(path, cap, width=150):
    z=doc.add_paragraph(); z.alignment=WD_ALIGN_PARAGRAPH.CENTER; z.add_run().add_picture(str(path),width=Mm(width))
    c=doc.add_paragraph(cap); c.alignment=WD_ALIGN_PARAGRAPH.CENTER; c.runs[0].italic=True; c.runs[0].font.size=Pt(9)
def table(headers, rows, widths=None, font=8.3):
    t=doc.add_table(rows=1, cols=len(headers)); t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.style='Table Grid'; repeat(t.rows[0])
    for j,txt in enumerate(headers):
        c=t.rows[0].cells[j]; c.text=str(txt); shade(c,'1F4E78'); border(c); margins(c); c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
        for r in c.paragraphs[0].runs: r.font.color.rgb=RGBColor(255,255,255); r.font.bold=True; r.font.size=Pt(font); r.font.name='Arial'
    for i,row in enumerate(rows):
        cells=t.add_row().cells
        for j,txt in enumerate(row):
            c=cells[j]; c.text=str(txt); border(c); margins(c); c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
            if i%2: shade(c,'EAF2F8')
            for par in c.paragraphs:
                for r in par.runs: r.font.name='Arial'; r.font.size=Pt(font)
    if widths:
        for row in t.rows:
            for j,w in enumerate(widths): row.cells[j].width=Mm(w)
    doc.add_paragraph().paragraph_format.space_after=Pt(2)
def pb(): doc.add_page_break()

# Engineering figures calculated from the declared model, generated without external plotting packages.
font_path = r'C:\\Windows\\Fonts\\arial.ttf'
bold_path = r'C:\\Windows\\Fonts\\arialbd.ttf'
def F(n, bold=False): return ImageFont.truetype(bold_path if bold else font_path, n)
vel=[x/10 for x in range(120,281)]; drag=[]; power=[]
for v in vel:
    q=.5*rho*v*v; C=W/(q*S); cd=CD0+k*C*C; d=q*S*cd; drag.append(d); power.append(d*v/(eta_prop*eta_motor))
WIMG,HIMG=1500,820; im=Image.new('RGB',(WIMG,HIMG),'white'); d=ImageDraw.Draw(im)
left,top,right,bottom=150,132,1330,650; d.rectangle((left,top,right,bottom),outline='#7F8C8D',width=2)
d.text((150,35),'FDR Analitik Performans Eğrisi',font=F(34,True),fill='#000000')
d.text((150,78),'Sabit CD0 = 0,028; e = 0,85; eta_p = 0,72; eta_m = 0,85',font=F(20),fill='#333333')
maxD=max(drag)*1.10; maxP=max(power)*1.10
for n in range(6):
    y=bottom-n*(bottom-top)/5; d.line((left,y,right,y),fill='#E5E7E9',width=1); d.text((58,y-10),f'{maxD*n/5:.1f}',font=F(18),fill='#1F4E78'); d.text((1340,y-10),f'{maxP*n/5:.0f}',font=F(18),fill='#B64B32')
for v in range(12,29,2):
    x=left+(v-12)/(28-12)*(right-left); d.line((x,top,x,bottom),fill='#F0F2F4',width=1); d.text((x-12,bottom+12),str(v),font=F(18),fill='#222222')
def point(v,y,maximum): return (left+(v-12)/(28-12)*(right-left),bottom-y/maximum*(bottom-top))
d.line([point(v,x,maxD) for v,x in zip(vel,drag)],fill='#1F4E78',width=5)
d.line([point(v,x,maxP) for v,x in zip(vel,power)],fill='#B64B32',width=5)
for v,label in [(Vs,f'V_s = {Vs:.2f} m/s'),(Vcr,'V_cr = 18 m/s')]:
    x=left+(v-12)/(28-12)*(right-left); d.line((x,top,x,bottom),fill='#555555',width=2); d.text((x+7,top+12 if v==Vs else top+48),label,font=F(18),fill='#222222')
d.text((545,745),'Hız, V (m/s)',font=F(23),fill='#000000'); d.text((10,200),'Sürükleme, D (N)',font=F(21),fill='#1F4E78'); d.text((1120,690),'Elektrik gücü, P_e (W)',font=F(21),fill='#B64B32')
d.line((310,700,370,700),fill='#1F4E78',width=5); d.text((382,686),'Gerekli itki / sürükleme',font=F(20),fill='#1F4E78'); d.line((720,700,780,700),fill='#B64B32',width=5); d.text((792,686),'Elektrik gücü gereksinimi',font=F(20),fill='#B64B32')
curve=WORK/'performance_curve.png'; im.save(curve)

eqs=['S = [(c_root + c_tip) / 2] b','AR = b² / S','C_D = C_D0 + C_L² / (pi AR e)','V_s = sqrt[2W / (rho S C_L,max)]','E_usable = V_nom C_nom (1 - r_reserve)']
im=Image.new('RGB',(1400,720),'white'); d=ImageDraw.Draw(im); d.text((80,35),'Performans Hesaplarında Kullanılan Temel Bağıntılar',font=F(32,True),fill='#000000')
for i,x in enumerate(eqs):
    yy=125+i*108; d.line((110,yy+63,1290,yy+63),fill='#D9D9D9',width=2); d.text((160,yy),x,font=F(30),fill='#000000')
equations=WORK/'equations.png'; im.save(equations)

doc.add_paragraph('Bölüm 3.1.6 Performans Hesaplamaları',style='Title')
p('Bu bölüm, FDR RevC montajının güncel kütle ve geometrisi kullanılarak hesaplanan düşük hızlı seyir performansını sunar. Analitik model; 10,158917 kg kalkış kütlesi, 2,400051 m açıklık, 0,639758 m² brüt kanat alanı ve 9,004 açıklık oranına dayanır. Güncellenen geometriyle elde edilen sonuçlar; stall hızı 14,44 m/s, en yüksek L/D hızında 17,60 m/s, 18 m/s seyirde yaklaşık 200 W elektrik gücü, 42,58 dakika kullanılabilir süre ve 45,99 km teorik menzildir. Bu sonuçlar, FDR’ye ait geometri-kütle güncellemesinin analitik etkisini gösterir; nihai uçuş kabul değeri değildir.')
p('DDR ile FDR arasında yalnızca sayısal bir karşılaştırma yapmak yeterli değildir; model sınırları da korunmalıdır. DDR aerodinamik poları için kullanılan C_D0=0,028, e=0,85 ve C_L,max=1,22 değerleri, FDR’ye ait yeni bir CFD veya rüzgar tüneli çıktısı bulunmadığından bu hesapta kontrollü biçimde sabit tutulmuştur. Böylece performans farkı, ağırlık, alan ve açıklık oranı değişiminden kaynaklanır. FDR uçuş testi veya güncel polar elde edildiğinde aynı denklem zinciri yeni katsayılarla tekrarlanmalıdır.')
fig(ASSEMBLY,'Şekil 3.1.6.1. FDR RevC montajının performans hesabında kullanılan CAD sınırlandırma kutusu ve toplam kütle özellikleri.')
h('3.1.6.1 Hesap Kapsamı ve Referans Konfigürasyonu',2)
p('Performans hesapları deniz seviyesi standart yoğunluğunda yapılmıştır (rho=1,225 kg/m³). Referans alanı, Bölüm 3.1.2’de tanımlanan brüt planform alanıdır. STL mesh üstten izdüşüm alanı yaklaşık 0,6093 m² olmasına karşın, bu değer açıkta kalan yüzeyi gösterdiği için kanat yüklemesi, AR ve kaldırma hesabında kullanılmamıştır. Hesap boyunca S=0,639758 m² kullanılması, geometri, kütle ve performans bölümlerinin aynı referansa dayanmasını sağlar.')
table(['Girdi','DDR değeri','FDR hesabında kullanılan değer','Kaynak ve gerekçe'],[
['Kalkış kütlesi','8,528 kg','10,158917 kg','Bölüm 3.1.1 CAD kütle özellikleri'],
['Ağırlık W','83,659 N','99,625 N','W=m g, g=9,80665 m/s²'],
['Kanat açıklığı b','2,120 m','2,400051 m','FDR RevC montaj ölçüsü'],
['Brüt kanat alanı S','0,900000 m²','0,639758 m²','S=[(croot+ctip)/2]b'],
['Açıklık oranı AR','4,994','9,004','AR=b²/S'],
['Parazitik sürükleme C_D0','0,028','0,028','DDR polar girdisi sabit tutuldu'],
['Oswald verimi e','0,85','0,85','DDR polar girdisi sabit tutuldu'],
['Maksimum kaldırma C_L,max','1,22','1,22','DDR düşük hız varsayımı sabit tutuldu'],
['Hava yoğunluğu rho','1,225 kg/m³','1,225 kg/m³','Deniz seviyesi standart atmosfer varsayımı']
],[30,27,43,74])
p('FDR kütlesi, CAD toplamından alınmıştır. Bu değer, DDR’deki 8,528 kg değere göre 1,630917 kg veya %19,12 daha yüksektir. Kanat alanındaki azalma ile birlikte kanat yüklemesi W/S 93,0 N/m²’den 155,7 N/m²’ye yükselir. Stall hızındaki artışın temel nedeni budur. Bu ilişki, Bölüm 3.1.1’deki kütle bütçesinin performans hesabına doğrudan bağlandığını gösterir.')

h('3.1.6.2 Aerodinamik Model ve Hesap Adımları',2)
p('Düşük Mach sayısındaki sabit kanatlı araç için parabolik sürükleme poları kullanılmıştır. İndüklenmiş sürükleme katsayısı, nihai açıklık oranı ile yeniden hesaplanmıştır. Bu yöntemde C_D0, profil ve gövde kaynaklı sıfır-kaldırma sürüklemesini; ikinci terim ise sonlu kanadın kaldırma üretirken oluşturduğu indüklenmiş sürüklemeyi temsil eder. Formüller Anderson (2016), McCormick (1995) ve Raymer (2018) tarafından verilen temel performans bağıntılarıyla uyumludur.')
fig(equations,'Şekil 3.1.6.2. Hesaplarda kullanılan temel performans bağıntıları.',130)
h('Adım 1 Kanat alanı ve açıklık oranı',3)
eq('S = [(0,266560 + 0,266560) / 2] × 2,400051 = 0,639758 m²')
eq('AR = (2,400051)² / 0,639758 = 9,004')
p('Kök ve uç veterleri eşit olduğundan MAC=0,266560 m’dir. Nihai AR, DDR değerinden %80,30 büyüktür. Bu artış, indüklenmiş sürükleme katsayısını düşürür; ancak daha küçük alan ve daha büyük kütle düşük hızlarda daha yüksek kaldırma katsayısı gerektirir.')
h('Adım 2 Sürükleme poları',3)
eq('k = 1 / (pi × AR × e) = 1 / (pi × 9,004 × 0,85) = 0,04159')
eq('C_D = 0,028 + 0,04159 C_L²')
p('DDR modelinde k=0,075 idi. FDR’de aynı e değeri ve daha yüksek AR ile k=0,04159 elde edilmiştir. Bu iyileşme, uçak ağırlığı veya profil değişmeden açıklık oranının indüklenmiş sürükleme üzerindeki etkisini gösterir. Buna karşılık C_D0 değeri FDR ölçümü değildir; gövde bağlantıları, antenler, kamera ve pervane etkileşimi bu katsayıyı değiştirebilir.')
h('Adım 3 En iyi süzülüş durumu',3)
eq('C_L,opt = sqrt(C_D0 / k) = 0,82050; C_D,opt = 0,05600')
eq('L/D_max = C_L,opt / C_D,opt = 14,65')
eq('V_(L/D,max) = sqrt[2W / (rho S C_L,opt)] = 17,60 m/s')
p('En yüksek L/D noktası, minimum sürükleme ile aynı fiziksel durumdur. FDR’de hesaplanan 17,60 m/s değeri, 18 m/s görev seyir hızının seçilen geometri için minimum-sürükleme hızına yakın olduğunu gösterir. Bu yakınlık, seyir hızının keyfi seçilmediğini destekler; yine de gerçek pervane verimi ve uçuş poları ile doğrulanmalıdır.')

h('3.1.6.3 Stall Hızı ve Kanat Yüklemesi',2)
p('Stall hesabında kalkış ağırlığının tamamının kanat tarafından taşındığı, uçağın düz ve yatay uçtuğu kabul edilmiştir. Bu nedenle L=W ve C_L=C_L,max alınmıştır. C_L,max=1,22 değeri DDR’de kullanılan düşük hızlı varsayımdır; flap veya yüksek kaldırma cihazı için ilave bir artış modellenmemiştir. Sonuç, emniyetli minimum operasyon hızının doğrudan kendisi değildir; stall hızıdır.')
eq('V_s = sqrt[2W / (rho S C_L,max)]')
eq('V_s = sqrt[2 × 99,625 / (1,225 × 0,639758 × 1,22)] = 14,44 m/s')
table(['Metrik','DDR','FDR','Değişim','Yorum'],[
['Kanat yüklemesi W/S','92,95 N/m²','155,73 N/m²','+67,54%','Kütle artışı ve referans alanının azalması'],
['Stall hızı V_s','11,16 m/s','14,44 m/s','+29,36%','V_s, sqrt(W/S) ile ölçeklenir'],
['En iyi L/D hızı','13,10 m/s','17,60 m/s','+34,37%','Yeni W/S ve indüklenmiş sürükleme katsayısı'],
['L/D_max','10,91','14,65','+34,29%','AR artışı; sabit C_D0 ve e varsayımı altında']
],[42,29,29,31,73])
p('FDR stall hızı, DDR’den yaklaşık 3,28 m/s daha yüksektir. Bu sonuç, kalkış ve iniş planlamasında önemlidir. Uçuş prosedüründe bunun üzerinde bir emniyet payı uygulanmalı; nihai minimum operasyon hızı, hava türbülansı, pilotaj/otopilot hata payı, tırmanış geometrisi ve doğrulanmış C_L,max verisi ile belirlenmelidir. Bu rapor, kaynağı olmayan bir emniyet katsayısı veya nihai uçuş hızı atamamaktadır.')
fig(CAD/'SağKanatYerleşim_Bilgileri.png','Şekil 3.1.6.3. Nihai kanat yerleşimi. Performans hesabında brüt planform alanı ve 2,400051 m açıklık referans alınmıştır.',145)

h('3.1.6.4 Seyir Hızı Güç Gereksinimi ve Enerji Bütçesi',2)
p('18 m/s seyir noktası için dinamik basınç q=198,45 N/m²’dir. Bu noktada gerekli kaldırma katsayısı C_L=0,78470, sürükleme katsayısı C_D=0,05361 ve sürükleme kuvveti 6,81 N hesaplanır. Aerodinamik güç D×V bağıntısından 122,51 W’tır. Pervane verimi eta_p=0,72 ve motor-ESC verimi eta_m=0,85 kabul edildiğinde bataryadan çekilen elektrik gücü 200,19 W olur.')
eq('P_aero = D V = 6,806 × 18 = 122,51 W')
eq('P_elec = P_aero / (eta_p eta_m) = 122,51 / (0,72 × 0,85) = 200,19 W')
p('Bu hesabın kapsamadığı sabit elektrik yükleri, aviyonik, telemetri, Jetson Orin Nano, kamera, GNSS/RTK ve servo tüketimleridir. CAD yerleşiminde bu ekipmanlar bulunduğu için gerçek uçuş elektrik gücü 200,19 W’tan daha yüksek olacaktır. Bu nedenle aşağıdaki süre ve menzil değerleri, yalnızca itki zinciri için hesaplanan teorik üst sınır olarak okunmalıdır. Uçuş öncesi güç ölçümü, bütün sistem açıkken seyir akımı üzerinden yapılmalıdır.')
fig(curve,'Şekil 3.1.6.4. FDR geometri-kütle girdileriyle gerekli sürükleme ve elektrik gücü eğrisi. Eğri, sabit C_D0, e, eta_p ve eta_m varsayımlarına dayanır.',150)

h('3.1.6.5 Dayanım ve Menzil Hesabı',2)
p('Enerji hesabında CAD paketinde adı bulunan 6S 8000 mAh batarya konfigürasyonu esas alınmıştır. Nominal enerji 22,2 V × 8 Ah=177,6 Wh’tır. Batarya ömrü, ani voltaj düşümü ve geri dönüş payı için nominal enerjinin %20’si kullanılabilir enerji dışında tutulmuştur. Böylece kullanılabilir enerji 142,08 Wh olur. Bu pay, yarışma görevinde bataryanın tamamen boşaltılmasına dayalı bir plan yapılmaması için hesap modeline dahil edilmiştir.')
eq('E_nom = 22,2 V × 8 Ah = 177,60 Wh')
eq('E_usable = 177,60 × (1 - 0,20) = 142,08 Wh')
eq('t = E_usable / P_elec = 142,08 / 200,19 = 0,710 h = 42,58 dakika')
eq('R = V_cr × t = 18 × (42,58 × 60) = 45,99 km')
table(['Enerji ve görev metriği','DDR','FDR analitik sonuç','Değişim','Koşul'],[
['Nominal batarya enerjisi','177,60 Wh','177,60 Wh','0%','6S, 8 Ah kabulü'],
['Kullanılabilir enerji','142,08 Wh','142,08 Wh','0%','%20 enerji rezervi'],
['Seyir elektrik gücü','233,24 W','200,19 W','-14,17%','18 m/s, sadece itki zinciri'],
['Teorik dayanım','36,5 dk','42,58 dk','+16,66%','Aviyonik/servo sabit yükü hariç'],
['Teorik menzil','39,5 km','45,99 km','+16,43%','Rüzgarsız, 18 m/s']
],[35,29,39,28,73])
p('DDR’de 157,35 W ortalama güç değeri ayrıca verilmiş olsa da, aynı bölümdeki 18 m/s sürükleme ve verim girdilerinden 233,24 W elde edilmektedir. Bu iki değer aynı çalışma noktasını temsil etmediği için FDR karşılaştırmasında 18 m/s için açık formülle verilen 233,24 W kullanılmıştır. FDR’de 200,19 W sonucu, güncel geometri ile aynı açık hesap zincirinden türetilmiştir. Bu açıklama, iki rapor arasındaki güç kıyaslamasının izlenebilir kalması için özellikle verilmiştir.')

h('3.1.6.6 Dönüş ve Tırmanış Performansının Sınırları',2)
p('Dönüş performansı, düz uçuşta doğrulanmış maksimum kaldırma katsayısı kullanılarak gösterilebilir. 18 m/s’de C_L,max=1,22 kabulüyle ulaşılabilen en yüksek yük faktörü n=1,555, yatış açısı yaklaşık 49,97 derece ve koordineli dönüş yarıçapı 27,75 m olur. Bu değerler aerodinamik kaldırma sınırına dayanır. Yapısal yük faktörü, servo otoritesi, otopilot sınırları veya emniyet zarfı için nihai limit değildir.')
eq('n_max = q S C_L,max / W = 1,555')
eq('phi = acos(1/n) = 49,97 derece; R = V²/[g sqrt(n²-1)] = 27,75 m')
p('Tırmanış oranı ve tırmanış açısı için gerekli fazla itkinin FDR konfigürasyonunda test edilmesi gerekir. DDR’de aynı bölüm içinde 35 N ve 95 N olmak üzere birbiriyle uyumsuz iki maksimum itki değeri bulunmaktadır. Bu nedenle FDR’de bu değerlerden biri seçilerek görünürde kesin bir tırmanış hızı üretilmemiştir. Motor-pervane düzeneğinin statik ve ileri hız itki eğrisi, tam yüklü 6S batarya ile ölçüldüğünde tırmanış hesabı P_available-P_required veya T_available-D yaklaşımıyla tamamlanmalıdır.')
table(['Performans kalemi','FDR analitik sonuç','Hesap sınırı','Tamamlanması gereken doğrulama'],[
['Stall hızı','14,44 m/s','C_L,max=1,22 varsayımı','Uçuş testi veya güncel polar'],
['En iyi L/D hızı','17,60 m/s','C_D0=0,028, e=0,85','XFLR5/CFD polar ve uçuş doğrulaması'],
['18 m/s güç gereksinimi','200,19 W','Aviyonik sabit yükü hariç','Uçuşta gerilim-akım kaydı'],
['Teorik dayanım','42,58 dk','6S 8Ah ve %20 rezerv','Tam sistem enerji testi'],
['Dönüş yarıçapı','27,75 m','Aerodinamik n sınırı','Yapısal ve kontrol limiti'],
['Tırmanış oranı','Raporlanmadı','FDR itki eğrisi yok','İtki ölçümü ve ileri-hız testi']
],[38,39,53,53])

h('3.1.6.7 Kütle Denge Yapısal Analiz ve Doğrulama Bağlantısı',2)
p('Bölüm 3.1.1’deki 10,158917 kg toplam kütle, bu bölümün ağırlık girdisidir. Kütle merkezi ise performans hesaplarında doğrudan yer almasa da trim sürüklemesini, yatay kuyruk kuvvetini ve dolayısıyla gerçek seyir gücünü etkiler. FDR CoG değeri (666,818; -2,703; 15,348) mm CAD dünya datumunda verildiği için, trim analizi öncesinde ana kanat MAC referansına dönüştürülmelidir. Aksi hâlde gerçek trim gereksinimi hesap dışı bırakılmış olur.')
p('Bölüm 3.2.1 yapısal analizinde, bu performans bölümündeki hızlar tek başına tasarım yükü sayılmamalıdır. Stall hızı, seyir hızı, manevra yük faktörü ve güncel hava hızı zarfı; kanat kökü, gövde-kanat bağlantısı, T-kuyruk ve kontrol yüzeyi yük durumlarının oluşturulmasında ortak girdilerdir. Özellikle 18 m/s’deki n=1,555 aerodinamik kaldırma sınırı ile seçilecek yapısal limit yük faktörü birbirinden ayrılmalıdır. Yapısal limit doğrulanmadan, bu bölümden bir maksimum manevra hızı türetilmesi doğru değildir.')
fig(CAD/'BataryaYerleşim_Bilgileri01.png','Şekil 3.1.6.5. Batarya yerleşimi. Enerji kaynağının konumu, Bölüm 3.1.1 kütle merkezi ve gerçek seyir tüketimi ile birlikte doğrulanmalıdır.',145)
h('3.1.6.8 Sonuç ve FDR Doğrulama Planı',2)
p('FDR RevC geometri ve kütle verileriyle yürütülen analitik hesap, DDR konfigürasyonuna göre daha yüksek kanat yüklemesi nedeniyle stall hızının yükseldiğini; buna karşılık daha yüksek açıklık oranı nedeniyle indüklenmiş sürüklemenin azaldığını göstermektedir. 18 m/s seyir noktası, hesaplanan en iyi L/D hızına yakındır. Bu nedenle güncel geometri ile 18 m/s, rüzgarsız teorik seyir için uygun bir başlangıç çalışma noktasıdır.')
p('Raporlanan sayılar, FDR doğrulama zincirindeki hesap basamağını temsil eder. Nihai kabul için güncel CAD’den kanat profil kesitleri çıkarılmalı, XFLR5 veya eşdeğer 3B analizle polar güncellenmeli, motor-pervane itki eğrisi ölçülmeli ve tam sistem açıkken telemetri üzerinden enerji tüketimi kaydedilmelidir. Bu doğrulamalar tamamlandığında C_D0, e, C_L,max, itki ve sabit elektrik yükleri güncellenerek bu bölümdeki denklemler yeniden işletilecektir.')
table(['Kontrol','FDR kabul girdisi','Yöntem','Çıktı'],[
['Geometri','b=2,400051 m; S=0,639758 m²','CAD ölçü ve planform çapraz kontrolü','Tutarlı AR ve MAC'],
['Aerodinamik polar','C_D0, e, C_L,max','3B analiz ve/veya uçuş veri uyarlaması','Güncel stall, L/D ve güç'],
['İtki','Motor-pervane T(V)','Yerde statik ve ileri hız testi','Tırmanış hızı ve açı zarfı'],
['Enerji','Tam sistem P_elec','Gerilim-akım telemetrisi','Gerçek dayanım ve menzil'],
['Yapı','Hız ve n zarfı','Bölüm 3.2.1 yük durumları','Limit ve emniyet payı']
],[32,50,54,52])

h('Kaynakça',1)
refs=[
'Anderson, J. D. (2016). Fundamentals of aerodynamics (6th ed.). McGraw-Hill Education.',
'Gudmundsson, S. (2021). General aviation aircraft design: Applied methods and procedures (2nd ed.). Butterworth-Heinemann.',
'McCormick, B. W. (1995). Aerodynamics, aeronautics, and flight mechanics (2nd ed.). John Wiley & Sons.',
'Raymer, D. P. (2018). Aircraft design: A conceptual approach (6th ed.). American Institute of Aeronautics and Astronautics. https://doi.org/10.2514/4.104909'
]
for x in refs:
    z=doc.add_paragraph(x); z.paragraph_format.left_indent=Mm(8); z.paragraph_format.first_line_indent=Mm(-8); z.paragraph_format.space_after=Pt(5)
p('Bu kaynakçada yalnızca yayımlanmış kitaplar yer almaktadır. Proje içi rapor, CAD dosyası veya yayımlanmamış çalışma kaynakça girdisi olarak kullanılmamıştır.')

OUT.parent.mkdir(exist_ok=True)
doc.core_properties.title='Bölüm 3.1.6 Performans Hesaplamaları'; doc.core_properties.author='Yiğido ANKA Takımı'
doc.save(OUT); print(OUT)
