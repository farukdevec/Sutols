from pathlib import Path
import re
from docx import Document
from docx.shared import Mm, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT=Path(r'C:\sutol\Sutols'); OUT=ROOT/'output'/'Yiğido_ANKA_FDR_Bolum_3_1_2_Hava_Araci_Boyut_Guncellemeleri.docx'
CAD=ROOT/'_fdr_source'/'cad'/'YigidoAnka_İHA_Bilgileri'/'05_Teknik_Resimler_ve_Görseller'
ASSEMBLY=ROOT/'_fdr_source'/'extracted_docx_media'/'image1.png'
TAIL_EVIDENCE=ROOT/'_fdr_source'/'rapor_revize_foto_20260914'
USER_WHATSAPP=ROOT/'_fdr_source'/'user_whatsapp_20260914'

def E(tag, **attrs):
    x=OxmlElement('w:'+tag)
    for k,v in attrs.items(): x.set(qn('w:'+k),str(v))
    return x
def shade(c,fill): c._tc.get_or_add_tcPr().append(E('shd',fill=fill))
def borders(c):
    b=E('tcBorders')
    for s in ('top','left','bottom','right','insideH','insideV'): b.append(E(s,val='single',sz='4',color='D9D9D9'))
    c._tc.get_or_add_tcPr().append(b)
def cell_margin(c):
    m=E('tcMar')
    for s in ('top','start','bottom','end'): m.append(E(s,w='90',type='dxa'))
    c._tc.get_or_add_tcPr().append(m)
def repeat(r): r._tr.get_or_add_trPr().append(E('tblHeader',val='true'))
def keep(p): p._p.get_or_add_pPr().append(E('keepNext'))
def page(p):
    p.add_run('Sayfa '); p._p.append(E('fldSimple',instr='PAGE'))

d=Document(); s=d.sections[0]
s.top_margin=Mm(25.4); s.bottom_margin=Mm(25.4); s.left_margin=Mm(25.4); s.right_margin=Mm(25.4); s.header_distance=Mm(10); s.footer_distance=Mm(10)
for n in ('Normal','Title','Heading 1','Heading 2','Heading 3'):
    st=d.styles[n]; st.font.name='Arial'; st._element.rPr.rFonts.set(qn('w:ascii'),'Arial'); st._element.rPr.rFonts.set(qn('w:hAnsi'),'Arial'); st.font.color.rgb=RGBColor(0,0,0)
d.styles['Normal'].font.size=Pt(10.2); d.styles['Normal'].paragraph_format.line_spacing=1.15; d.styles['Normal'].paragraph_format.space_after=Pt(7)
for n,pt in [('Title',16),('Heading 1',15),('Heading 2',14.5),('Heading 3',11)]: d.styles[n].font.size=Pt(pt); d.styles[n].font.bold=True
d.styles['Heading 1'].paragraph_format.space_before=Pt(18); d.styles['Heading 1'].paragraph_format.space_after=Pt(10)
d.styles['Heading 2'].paragraph_format.space_before=Pt(17); d.styles['Heading 2'].paragraph_format.space_after=Pt(8)
d.styles['Heading 3'].paragraph_format.space_before=Pt(10); d.styles['Heading 3'].paragraph_format.space_after=Pt(5)
s.header.paragraphs[0].text=''
s.footer.paragraphs[0].text=''

def H(x,l=1):
    p=d.add_paragraph(x,style=f'Heading {l}'); keep(p); return p
def P(x='',lead=None):
    p=d.add_paragraph(); p.paragraph_format.first_line_indent=Mm(0 if lead else 6)
    if lead: r=p.add_run(lead); r.bold=True
    p.add_run(x); return p
KEEP_IMAGES={
    ASSEMBLY,
    CAD/'SağKanatYerleşim_Bilgileri.png',
    CAD/'SağAileronYerleşim_Bilgileri.png',
    CAD/'GövdeYerleşim_Bilgileri.png',
    CAD/'ElevatorYerleşim_Bilgileri.png',
    CAD/'MotorİçiYerleşim_Bilgileri.png',
    CAD/'BataryaYerleşim_Bilgileri01.png',
    CAD/'Parachute_ReleaseYerleşim_Bilgileri01.png',
    USER_WHATSAPP/'YatayKuyrukPlanformOlcumu.jpeg',
    TAIL_EVIDENCE/'3.jpeg',
    TAIL_EVIDENCE/'4.jpeg',
    TAIL_EVIDENCE/'5.jpeg',
}
FIG=0
def F(path,cap,w=135):
    global FIG
    if Path(path) not in KEEP_IMAGES:
        return
    FIG += 1
    cap=re.sub(r'^Şekil 3\.1\.2\.\d+\.',f'Şekil 3.1.2.{FIG}.',cap)
    w=min(w,135)
    p=d.add_paragraph(); p.alignment=WD_ALIGN_PARAGRAPH.CENTER; p.add_run().add_picture(str(path),width=Mm(w))
    c=d.add_paragraph(cap); c.alignment=WD_ALIGN_PARAGRAPH.LEFT; c.runs[0].bold=True; c.runs[0].font.size=Pt(9.3)
def T(head,rows,widths=None,font=8.3):
    t=d.add_table(rows=1,cols=len(head)); t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.style='Table Grid'; repeat(t.rows[0])
    for j,x in enumerate(head):
        c=t.rows[0].cells[j]; c.text=str(x); shade(c,'B7B7B7'); borders(c); cell_margin(c); c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
        for r in c.paragraphs[0].runs: r.font.name='Arial'; r.font.size=Pt(font); r.font.bold=True; r.font.color.rgb=RGBColor(0,0,0)
    for i,row in enumerate(rows):
        for j,x in enumerate(row):
            c=t.add_row().cells[j] if j==0 else t.rows[-1].cells[j]
            c.text=str(x); borders(c); cell_margin(c); c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
            if i%2: shade(c,'F2F2F2')
            for p in c.paragraphs:
                for r in p.runs: r.font.name='Arial'; r.font.size=Pt(font)
    if widths:
        for row in t.rows:
            for j,w in enumerate(widths): row.cells[j].width=Mm(w)
    for row in t.rows:
        row._tr.get_or_add_trPr().append(E('cantSplit'))
    d.add_paragraph().paragraph_format.space_after=Pt(2)
def PB(): d.add_page_break()

d.add_paragraph('Bölüm 3.1.2 Hava Aracı Boyut Güncellemeleri',style='Title')
P('Bu bölüm, Yiğido ANKA sabit kanatlı İHA’nın DDR aşamasındaki başlangıç geometrisinden FDR RevC CAD montajına geçişini parça bazında tanımlar. FDR konfigürasyonu; ana taşıyıcı yüzeyleri, gövde kabuğunu, T-kuyruk takımını, itki sistemini, enerji-aviyonik yerleşimini ve paraşüt kurtarma düzeneklerini aynı montaj referansında birleştirir. Bu nedenle aşağıdaki değerler, yalnızca görsel model ölçüsü değildir; ağırlık ve denge, aerodinamik performans, kontrol, yapısal analiz ve üretim resimleri için ortak konfigürasyon girdileridir.')
P('DDR’deki her ölçü FDR ile doğrudan karşılaştırılabilir değildir. Örneğin DDR’de 600 mm olarak verilen değer gövde parçasının zarfını temsil ederken, FDR’de 1501,102 mm pervane ve T-kuyruğu içeren tam montaj zarfıdır. Bu bölümde karşılaştırma yapılırken ölçüm kapsamı açıkça belirtilmiş, eşdeğer olmayan büyüklükler için yapay yüzde değişimi üretilmemiştir.')
P('RevC konfigürasyonu, görev icra simülasyonunda tanımlı uçuş senaryosunu başarıyla tamamlamıştır. Bu sonuç; burada tanımlanan boyutsal yerleşim, kontrol yüzeyi limitleri ve sistem mimarisinin simülasyon ortamındaki birlikte çalışabilirliğini gösterir. Bölüm 3.1.4, 3.1.5 ve 3.1.6’da kullanılan aerodinamik, kararlılık ve performans girdileri bu bölümde sabitlenen aynı RevC geometri setine bağlanmıştır.')
F(ASSEMBLY,'Şekil 3.1.2.1. RevC nihai CAD montajı. Fusion 360 Properties çıktısında tam montaj uzunluğu 1501,102 mm, açıklık 2400,051 mm ve yükseklik 523,565 mm olarak görülmektedir.',150)
H('3.1.2.1 Konfigürasyon Kontrolü ve Veri Kaynağı',2)
P('FDR’deki geometri değerleri, RevC montajının Fusion 360 Properties ekranları, STL parça zarf raporu ve nihai montaj yerleşim görsellerinden alınmıştır. Ölçüler mm, alanlar m² ve kütleler g veya kg cinsindendir. Boyutların kaynağı bir CAD zarfı ise “zarf boyutu” olarak; aerodinamik hesapta kullanılan alan ise “brüt planform alanı” olarak adlandırılmıştır. Böylece parça dış sınırı, mesh izdüşümü ve aerodinamik referans alanı aynı nicelikmiş gibi kullanılmamıştır.')
PB()
T(['Veri kümesi','Kapsam','Bu bölümdeki işlev'],[
['DDR geometri tanımı','Başlangıç kanat, gövde, kuyruk ve kontrol yüzeyi değerleri','Eski değer ve tasarım niyeti'],
['RevC CAD montajı','Tam araç ve tüm alt sistem yerleşimi','FDR nihai zarfı, arayüzler ve CoG bağlantısı'],
['RevC STL parça paketi','Yapısal ve hareketli parçaların tekil zarfı','Parça bazlı ölçü ve görsel kanıt'],
['CAD kütle özellikleri','Tam montaj fiziksel özellikleri','Bölüm 3.1.1 ve 3.2.1 ile ortak girdi']
],[38,55,73])
H('3.1.2.2 DDR FDR Ana Geometri Karşılaştırması',2)
P('Tablo 3.1.2.1, DDR’de tanımlanan temel hava aracı geometrisi ile FDR’de hesap ve çizimlerde kullanılacak RevC değerlerini karşılaştırır. FDR kanat alanı için sabit-veterli brüt planform kabulü kullanılmıştır. STL mesh üstten izdüşüm alanı yaklaşık 0,6093 m² olup; gövde altında kalan bölge ve kesilmiş konturlar nedeniyle 0,639758 m² brüt referans alanından farklıdır.')
T(['Parametre','DDR','FDR RevC','Fark','Değişim','Teknik açıklama'],[
['Tam montaj uzunluğu','—','1501,102 mm','—','—','FDR tam montaj sınırlandırma kutusu'],
['Gövde uzunluğu','600,000 mm','1450,000 mm parça zarfı','+850,000 mm','+141,67%','Kapsam ve iç yerleşim olgunluğu farklıdır'],
['Tam montaj yüksekliği','—','523,565 mm','—','—','Pervane ve T-kuyruk dahil'],
['Kanat açıklığı b','2120,000 mm','2400,051 mm','+280,051 mm','+13,21%','Nihai sağ-sol kanat montajı'],
['Kök veter','467,000 mm','266,560 mm','-200,440 mm','-42,92%','FDR STL kanat zarfı'],
['Uç veter','382,000 mm','266,560 mm','-115,440 mm','-30,22%','FDR sabit-veterli taşıyıcı bölge'],
['Brüt kanat alanı S','0,900000 m²','0,639758 m²','-0,260242 m²','-28,92%','S=[(croot+ctip)/2]b'],
['Açıklık oranı AR','4,994','9,004','+4,010','+80,30%','AR=b²/S, aynı brüt alan tanımı']
],[26,26,33,27,24,58],7.6)
P('Kanat açıklığındaki artış ve brüt alanın azalması, FDR’de kanat yüklemesi ile düşük hız performansının yeniden hesaplanmasını gerektirir. Bu bağ Bölüm 3.1.6’da sayısal olarak ele alınmıştır. Kanat kök bağlantısı, gövde-kuyruk bağlantısı ve kontrol yüzeyi menteşe çizgileri ise Bölüm 3.2.1’deki yapısal yük durumlarında RevC geometri ile yeniden kurulmalıdır.')

PB(); H('3.1.2.3 Ana Kanat Takımı',2)
P('Ana kanat, kaldırma üretimi ile birlikte batarya, faydalı yük ve gövde kütlesinden kaynaklanan eğilme yüklerini gövdeye aktaran ana taşıyıcı gruptur. DDR’de trapezoidal ve konik planform tanımlanmışken, FDR’de sağ ve sol kanat için aynı 266,560 mm x 1203,000 mm zarfı taşıyan simetrik bir modüler geometri kullanılmıştır. Bu değişiklik, iki yarı kanadın üretim, montaj ve yedek parça yönetiminde aynı referansla kontrol edilmesine imkân verir.')
H('3.1.2.3.1 Sağ Kanat',3)
P('Sağ kanat STL zarfı 266,560 mm veter, 1203,000 mm yarı açıklık ve 36,041 mm azami kalınlıktır. Sol kanatla birlikte teorik açıklık 2406,000 mm oluşturmasına rağmen, tam montajdaki ara yüz ve referans düzlemleri nedeniyle Fusion 360 sınırlandırma kutusunda 2400,051 mm okunur. FDR analizlerinde tam montaj ölçüsü esas alınmalıdır; parça zarfı iki ile çarpılarak ayrı bir montaj ölçüsü üretilmemelidir.')
F(CAD/'SağKanatYerleşim_Bilgileri.png','Şekil 3.1.2.2. Sağ kanadın RevC montaj içindeki konumu ve CAD özellik ekranı.',150)
H('3.1.2.3.2 Sol Kanat',3)
P('Sol kanat zarfı 266,560 mm x 1203,000 mm x 35,983 mm’dir. Sağ ve sol kanadın veter ile yarı açıklık değerlerinin eşit olması, geometrik simetriyi korur. Kalınlıktaki 0,058 mm fark CAD/STL çözünürlüğü ve kontur kapanışından kaynaklanan zarf farkıdır; aerodinamik açıdan asimetrik bir profil tercihi olarak yorumlanmamalıdır.')
F(CAD/'SolKanatYerleşim_Bilgileri.png','Şekil 3.1.2.3. Sol kanadın RevC montaj yerleşimi. Sağ-sol geometrik eşleşme ayrı bir montaj kontrol maddesidir.',150)
H('3.1.2.3.3 Planform Alanı MAC ve Açıklık Oranı',3)
P('FDR ana kanat için kök ve uç veterleri eşit kabul edildiğinden koniklik oranı lambda=1,000 ve ortalama aerodinamik veter MAC=266,560 mm’dir. Bu değer, bir mesh alanı veya ıslak yüzey alanı değildir. Brüt planform alanı, açıklık ve veterin aynı referans tanımıyla elde edilir; aerodinamik yük, performans ve kuyruk hacim hesaplarında bu referans korunmalıdır.')
T(['Hesap adımı','FDR değeri','Açıklama'],[
['S=[(croot+ctip)/2]b','[(0,266560+0,266560)/2] x 2,400051 = 0,639758 m²','Brüt planform alanı'],
['AR=b²/S','(2,400051)²/0,639758 = 9,004','Brüt alanla açıklık oranı'],
['lambda=ctip/croot','1,000','Sabit-veterli ana taşıyıcı bölüm'],
['MAC','266,560 mm','lambda=1 için croot değerine eşittir'],
['STL mesh izdüşüm alanı','yaklaşık 0,6093 m²','Geometri kontrol verisi; brüt S yerine geçmez']
],[52,55,85])
P('DDR’deki 0,900 m² alan ve 4,994 AR; FDR’deki 0,639758 m² alan ve 9,004 AR ile değiştirilmiştir. Bu değişikliğin indüklenmiş sürükleme, stall hızı ve seyir gücü üzerindeki etkisi Bölüm 3.1.6’da; kanat kökü yükü ve eğilme gerilmesi üzerindeki etkisi Bölüm 3.2.1’de RevC geometri setiyle değerlendirilmiştir.')
H('3.1.2.3.4 Kuyruk Referans Planform ve Konum Verileri',3)
P('FDR konfigürasyonunda kanat ve kuyruk aynı CAD Origin referansında tanımlanmıştır. X ekseni boylamsal, Y ekseni açıklık doğrultusu ve Z ekseni düşey doğrultudur. Sağ ve sol kanat CAD Properties kayıtlarıyla elde edilen merkez koordinatlarının ortalaması, kuyruk yerleşiminin boylamsal referansını oluşturur. Bu referansla elde edilen kollar ve planform alanları, Bölüm 3.1.6’daki aerodinamik performans modelinin doğrudan geometrik girdileridir.')
T(['Geometrik parametre','FDR RevC değeri','CAD temeli','Tasarımda kullanımı'],[
['Kanat MAC','266,560 mm','croot=ctip=266,560 mm','Ana taşıyıcı referans veteri'],
['Yatay kuyruk alanı Sh','0,115714454 m²','57.857,227+57.857,227 mm²','Pitch stabilite ve kontrol yüzeyi planformu'],
['Dikey kuyruk alanı Sv','0,095860436 m²','45.035,813+50.824,623 mm²','Yaw stabilite ve kontrol yüzeyi planformu'],
['Sağ kanat geometrik merkezi','(542,376; +613,035; 3,424) mm','Nihai STL ölçek-normalize ölçü seti','Sağ yarı-kanat yerleşimi'],
['Sol kanat geometrik merkezi','(540,954; −608,535; 3,437) mm','Nihai STL ölçek-normalize ölçü seti','Sol yarı-kanat yerleşimi'],
['Kanat boylamsal referansı Xref,w','541,665 mm','(542,376+540,954)/2','Ortak kanat-kuyruk datum değeri'],
['Elevator geometrik merkezi','(1.375,284; 0,001; −0,004) mm','Nihai STL ölçek-normalize ölçü seti','Yatay kuyruk boylamsal referansı'],
['Rudder geometrik merkezi','(1.334,502; 2,816; 155,557) mm','Nihai STL ölçek-normalize ölçü seti','Dikey kuyruk boylamsal referansı'],
['Yatay referans kolu lh,ref','833,620 mm','1.375,284−541,665','Yatay kuyruk yerleşim kolu'],
['Dikey referans kolu lv,ref','792,837 mm','1.334,502−541,665','Dikey kuyruk yerleşim kolu']
],[44,42,45,60],7.0)
P('Yatay ve dikey kuyruk hacim göstergeleri aynı CAD referansında Vh,ref=Sh·lh,ref/(S·MAC)=0,5656 ve Vv,ref=Sv·lv,ref/(S·b)=0,04950 olarak elde edilmiştir. Hesapta S=0,639758 m², b=2,400051 m ve MAC=0,266560 m kullanılmıştır. Böylece planform alanı, kanat-kuyruk konumu ve boyutsal ölçek tek bir RevC geometri setinde birleştirilmiştir.')
P('FDR alan farkları aynı tanımlı planform yüzeyleri esas alır. DDR’ye göre Sh 0,005714454 m² (%5,195) ve Sv 0,035860436 m² (%59,767) artmıştır. 0,266 m ifadesi alan değil, metre cinsinden MAC’tir: 0,266560 m = 266,560 mm. RevC ana kanadında croot=ctip=266,560 mm olduğundan kanat alanı hesabında bu iki değer kullanılmıştır.')

H('3.1.2.4 Aileronlar ve Kanat Kontrol Arayüzleri',2)
P('Aileronlar ana kanatla birlikte ele alınmalıdır; çünkü aileronun boyutu, menteşe konumu ve sapma limiti doğrudan kanat firar kenarı geometrisine bağlıdır. DDR’de 50-55 mm veter ve 350 mm açıklıkla tanımlanan kontrol yüzeyleri, FDR’de daha uzun açıklıklı ayrı sağ ve sol CAD parçaları olarak modellenmiştir. Bu değişim, sadece yüzey alanını değil, servo yükünü, menteşe çizgisini ve maksimum dönme zarfını da değiştirir.')
T(['Yüzey','DDR geometri','FDR zarfı','FDR menteşe origin','FDR limit','Yorum'],[
['Sağ aileron','50-55 mm x 350 mm','51,270 x 550,000 x 26,335 mm','(0,640; +0,822981; 0,045) m','±15°','Dış kanat bölgesinde'],
['Sol aileron','50-55 mm x 350 mm','53,629 x 550,000 x 27,505 mm','(0,640; -0,822432; 0,045) m','±15°','Karşı yüzeyle eşleşir']
],[28,34,45,48,20,32],7.7)
H('3.1.2.4.1 Sağ Aileron',3)
P('Sağ aileronun 550 mm açıklığı, DDR başlangıç değerine göre daha geniş bir kontrol şeridi oluşturur. FDR’deki 51,270 mm veter, kanat zarf veterinin yaklaşık %19,23’üne karşılık gelir. Bu geometri; 18 m/s seyir koşulundaki menteşe momenti, servo torku ve sapma sırasında aileron-kanat çarpışma zarfı değerlendirmesinde kullanılan RevC kontrol arayüzünü tanımlar. Görev icra simülasyonunda aileron komutları bu sınırlar içerisinde uygulanmıştır.')
F(CAD/'SağAileronYerleşim_Bilgileri.png','Şekil 3.1.2.4. Sağ aileronun kanat firar kenarındaki yerleşimi ve parça özellikleri.',150)
H('3.1.2.4.2 Sol Aileron',3)
P('Sol aileron 53,629 mm veter ve 550,000 mm açıklıkla modellenmiştir. Sağ ve sol aileron kütleleri sırasıyla 0,163740 kg ve 0,209103 kg’dır. Bu fark, yerel CAD kütle özelliğinin yanı sıra bağlantı ayrıntılarından kaynaklanabilir; nihai montaj öncesi sağ-sol yüzeylerin donanım, servo ve bağlantı elemanları dahil kütle eşleştirmesi Bölüm 3.1.1’de kontrol edilmelidir.')
H('3.1.2.4.3 Hitec D954SW Kontrol Yüzeyi Servoları',3)
P('Bölüm 7 nihai BOM’unda dört adet Hitec D954SW 32-bit dijital geniş gerilimli servo tanımlanmıştır. Her servo için üretici kütlesi 65 g ve dış boyut 40 mm x 20 mm x 37 mm’dir; dört servonun ekipman kütlesi 260 g’dır. Servo kütlesi aileron, elevator ve rudder kontrol yüzeylerine dağıtılmadan uçuş ağırlık merkezi kapanışı yapılamaz. Bu nedenle her servo için nihai montaj deliği, kol/bağlantı mekanizması ve kablo kütlesi master CAD’de tanımlanmalı; servo tekil ağırlığı, hareketli yüzey kütlesine doğrudan eklenmemelidir.')
F(CAD/'SolAileronYerleşim_Bilgileri.png','Şekil 3.1.2.5. Sol aileronun RevC yerleşimi. Sağ-sol hareketli yüzeylerin birbirine çarpma ve sapma zarfı kontrol edilmelidir.',150)

H('3.1.2.5 Gövde Kabuk İç Yerleşim ve Kapak',2)
P('FDR gövde, kanat ve kuyruk arasındaki yapısal omurganın yanında enerji, uçuş kontrol, görev bilgisayarı, kamera, GNSS ve kurtarma mekanizması için tanımlı yerleşim hacmidir. Gövde STL zarfı 1450,000 mm uzunluk, 205,868 mm genişlik ve 249,514 mm yüksekliktir. Bu değer, DDR’deki 600,000 mm x 50,000 mm x 60,000 mm başlangıç gövde zarfından farklı bir kapsamı temsil eder; FDR modelinde iç alt sistemler ve arka gövde ara yüzleri aynı ana parçada modellenmiştir.')
F(CAD/'GövdeYerleşim_Bilgileri.png','Şekil 3.1.2.6. Gövde ana çerçevesi ve kanat-kuyruk-alt sistem yerleşim ilişkisi.',150)
P('Gövde uzunluğundaki büyüme tek başına aerodinamik gövdenin uzatıldığı anlamına gelmez. CAD’de motor, kuyruk, batarya ve görev ekipmanlarının montaj datumları aynı ortamda tanımlandığı için FDR gövde zarfı, DDR parça zarfından daha geniş bir entegrasyon kapsamı taşır. Bu nedenle aerodinamik gövde ıslak alanı veya parazit sürükleme, yalnızca dış zarf boyutları kullanılarak çıkarılmamalıdır.')
H('3.1.2.5.1 Gövde Kapağı ve Bakım Arayüzü',3)
P('Gövde kapağı; batarya değişimi, elektronik erişimi ve kablo denetimi için açılabilir arayüz olarak CAD montajında ayrı tanımlanmıştır. Kapak etrafındaki boşluklar, montajdan sonra yüzey sürekliliği ve su/toz girişine karşı kontrol edilmelidir. Kapak, hava yükü taşıyan ana eleman gibi kabul edilmemeli; kapak kilitleri ve kabuk çevresindeki yerel yükler Bölüm 3.2.1’in ilgili sınır koşullarında değerlendirilmelidir.')
F(CAD/'GövdeKapağıYerleşim_Bilgileri.png','Şekil 3.1.2.7. Gövde kapağının RevC montajındaki konumu ve bakım erişim bölgesi.',150)
T(['Metrik','DDR','FDR','Karşılaştırma notu'],[
['Gövde uzunluğu','600,000 mm','1450,000 mm zarf','FDR sistem zarfı; mekanik ve aviyonik entegrasyonunu kapsar'],
['Gövde maksimum genişliği','50,000 mm','205,868 mm zarf','İç yerleşim ve kabuk ara yüzleri içerir'],
['Gövde maksimum yüksekliği','60,000 mm','249,514 mm zarf','Kanat-kuyruk-alt sistem entegrasyonu içerir'],
['Tam montaj zarfı','—','1501,102 x 2400,051 x 523,565 mm','FDR ana konfigürasyon değeri']
],[42,35,44,76])

H('3.1.2.6 T Kuyruk Takımı',2)
P('FDR T-kuyruk takımı, elevator ve rudder parçalarının ana gövdeye farklı eksenlerde bağlandığı birleşik bir geometridir. DDR’de yatay kuyruk için yaklaşık 0,11 m² alan ve 0,60 m moment kolu, dikey kuyruk için yaklaşık 0,06 m² alan ve 0,35 m yükseklik verilmiştir. RevC CAD Measure kayıtları planform yüzeylerini doğrudan verir; bu yüzden alan doğrulamasında sınırlandırma kutusu çarpımları değil, seçilmiş yüzey alanları kullanılmıştır.')
H('3.1.2.6.1 Planform Alanlarının CAD Ölçümü',3)
P('Yatay kuyruk görüntüsünde iki simetrik seçili planform yüzü ayrı ayrı 57.857,227 mm² okunmaktadır. Yüzeyler merkez hattın iki yanında eş olduğundan toplam yatay kuyruk planform alanı, Sh=57.857,227+57.857,227=115.714,454 mm²=0,115714454 m² olarak kaydedilmiştir. Bu sonuç, modelin yukarıdan görünüşünde ölçülen iki yarı yüzün toplamıdır; çift taraflı katı-model yüzey alanı veya elevatorın sınırlandırma kutusu alanı değildir.')
F(USER_WHATSAPP/'YatayKuyrukPlanformOlcumu.jpeg','Şekil 3.1.2.9. RevC yatay kuyruk planformunda iki simetrik seçili yüz için CAD Measure sonucu (her bir yüz: 57.857,227 mm²).',135)
P('Dikey kuyruk görüntüsünde iki seçili planform yüzü sırasıyla 45.035,813 mm² ve 50.824,623 mm²’dir. Buna göre dikey kuyruk toplam planform alanı Sv=45.035,813+50.824,623=95.860,436 mm²=0,095860436 m²’dir. İki alanın farklı olması, görüntüde iki ayrı dikey planform bölgesi ölçüldüğünü gösterir; değerler üst ve alt yüzeyin mükerrer sayımı olarak toplanmamıştır.')
F(TAIL_EVIDENCE/'3.jpeg','Şekil 3.1.2.10. RevC dikey kuyrukta seçili iki planform yüzünün CAD Measure sonuçları (45.035,813 mm² ve 50.824,623 mm²).',135)
P('Nihai STL ölçü seti RevC master montajının mm datumuna normalize edildiğinde elevator geometrik merkezi (1.375,284; 0,001; −0,004) mm, rudder geometrik merkezi ise (1.334,502; 2,816; 155,557) mm’dir. Sağ ve sol kanat geometrik merkezlerinden oluşturulan Xref,w=541,665 mm boylamsal referansı ile bu konumlar, T-kuyruk yerleşiminin uçak eksen takımındaki sayısal tarifini verir. Bu koordinat seti, kontrol yüzeyi kollarının, yapısal yük uygulama noktalarının ve aerodinamik modelin aynı montaj datumunda kurulmasını sağlar.')
H('3.1.2.6.2 Elevator',3)
P('Elevator parça zarfı 170,000 mm veter, 820,000 mm açıklık ve 17,468 mm kalınlıktır. Menteşe origin’i (1,350; 0,000; 0,050) m, dönüş ekseni ise y eksenidir. ±25 derece limit, pitch kontrolü için çizimsel sınırı tanımlar. Bu limitte elevatorın dikey stabilize, gövde kapağı ve arka gövdeyle olan zarf çakışması montaj testinde kontrol edilmelidir.')
F(TAIL_EVIDENCE/'5.jpeg','Şekil 3.1.2.11. Elevatorın CAD Properties penceresindeki yerleşim kaydı.',135)
F(CAD/'ElevatorYerleşim_Bilgileri.png','Şekil 3.1.2.8. Elevator ve T-kuyruk bağlantısı. Görsel, arka gövde ile hareketli yatay yüzeyin konum ilişkisini gösterir.',150)
H('3.1.2.6.3 Rudder',3)
P('Rudder parça zarfı 180,657 mm veter, 14,789 mm genişlik ve 350,000 mm yüksekliktir. CAD menteşe origin’i (1,400; 0,000; 0,180) m ve sapma limiti ±20 derecedir. Rudderın 350 mm dikey boyutu, DDR’de kullanılan 0,35 m dikey kuyruk yüksekliğiyle aynı mertebededir; ancak biri hareketli yüzey zarfı, diğeri başlangıç aerodinamik kuyruk modeli olduğundan iki değer aynı alan tanımı gibi kullanılmamalıdır.')
F(TAIL_EVIDENCE/'4.jpeg','Şekil 3.1.2.12. Rudderın CAD Properties penceresindeki yerleşim kaydı.',135)
F(CAD/'RudderYerleşim_Bilgileri.png','Şekil 3.1.2.9. Rudderın dikey kuyruk üzerinde konumu ve arka gövde ile olan mekanik arayüzü.',150)
T(['Hareketli yüzey','FDR zarfı','Kütle','Menteşe origin','Limit'],[
['Elevator','170,000 x 820,000 x 17,468 mm','0,624138 kg','(1,350; 0,000; 0,050) m','±25°'],
['Rudder','180,657 x 14,789 x 350,000 mm','0,056607 kg','(1,400; 0,000; 0,180) m','±20°']
],[36,54,30,50,25])
P('T-kuyruk geometrisi, Sh=0,115714454 m², Sv=0,095860436 m², lh,ref=833,620 mm ve lv,ref=792,837 mm değerleriyle RevC konfigürasyonuna bağlanmıştır. Elevator ve rudder menteşe hatlarındaki yerel yükler ile T-bağlantısındaki burulma Bölüm 3.2.1’de bu geometri üzerinden değerlendirilir; propwash ve downwash etkileri ise Bölüm 3.1.6’daki uçuş modeli içinde ele alınır.')

H('3.1.2.7 İtki Sistemi ve Pervane Yerleşimi',2)
P('İtki grubu, motor gövdesi, motorun iç bağlantı elemanları ve sağ-sol pervane tanımlarıyla CAD montajına dahil edilmiştir. Pervaneler için ayrı sağ ve sol STL parçalarının kullanılması, dönüş yönü ve montaj konumunun açıkça kontrol edilmesini sağlar. DDR’de itki sistemi için tekil CAD zarf boyutları verilmediğinden, bu alt başlıkta FDR değerleri yeni konfigürasyon bilgisi olarak sunulmuştur.')
H('3.1.2.7.1 Motor ve İç Bağlantı Bölgesi',3)
P('Nihai BOM’da itki motoru T-MOTOR AT4120 Long Shaft 560KV olarak tanımlanmıştır. Üretici verisinde kablo dâhil kütle 300 g, besleme 6S, 180 s tepe akımı 80 A ve azami güç 1800 W’tır. Bu değerler, CAD’deki 54,892 g temsili motor kütlesiyle eşdeğer değildir; motorun gerçek kütlesi, montaj braketi ve pervane adaptörü ile birlikte ana CAD montajına işlenmeden tam araç atalet hesabı kapatılmamalıdır.')
P('FLAME 80A 12S V2.0 ESC, AT4120 tahrik zincirinin elektronik hız kontrolcüsüdür. 6S-12S çalışma aralığı, 80 A sürekli akım sınıfı ve 109 g üretici kütlesi ile tanımlanır. Motor-ESC kablosu kısa ve güç kablolarından ayrık güzergâhta tutulmalı; ESC, gövde içindeki ısıyı doğrudan kabuğa veya kontrollü hava akımına aktaracak biçimde yerleştirilmelidir. Motor bağlantısı için statik itki, maksimum akım ve titreşim testi Bölüm 3.1.6 ile birlikte yürütülmelidir.')
F(CAD/'MotorİçiYerleşim_Bilgileri.png','Şekil 3.1.2.11. Motorun gövde içi yerleşimi. Kablo ve taşıyıcı arayüzler montaj doğrulamasında ayrıca kontrol edilmelidir.',150)
H('3.1.2.7.2 Sağ ve Sol Pervaneler',3)
P('Sağ ve sol pervane STL zarfı aynı olup 4,000 mm x 199,993 mm x 53,152 mm’dir. 199,993 mm boyut, pervane parçasının CAD y-zarfındaki dış sınırıdır. Tek başına üretici katalog çapı veya hatve değeri olarak raporlanmamalıdır. Pervane seçimi, motorla birlikte statik itki, ileri hız itki kaybı, akım ve titreşim ölçümüyle doğrulanmalıdır.')
F(CAD/'SağPervaneYerleşim_Bilgileri.png','Şekil 3.1.2.12. Sağ pervanenin motor ve gövdeyle konum ilişkisi. Karşı yönlü pervane, aynı CAD zarfıyla ayrı konfigürasyon parçası olarak tanımlanmıştır.',150)

H('3.1.2.8 Enerji Depolama Dağıtım ve ESC',2)
P('Enerji alt sistemi; 6S 8000 mAh batarya, batarya tepsisi ve ESC’nin aynı gövde referansında yerleştirilmesiyle tanımlanmıştır. FDR’de enerji sistemi, performans hesabından bağımsız bir bileşen değildir. Bataryanın konumu ağırlık merkezini, ESC’nin konumu ise kablo güzergâhını, soğutma ihtiyacını ve elektromanyetik etkileşimi etkiler. Bu nedenle bu parçalar boyut güncellemesi içinde tek tek gösterilmiştir.')
H('3.1.2.8.1 6S 8000 mAh Batarya',3)
P('Bölüm 7 nihai BOM’unda tanımlanan enerji paketi GAONENG GNB80006S70AHV, 6S2P, 22,8 V LiHV, 8000 mAh, 70C ve XT90 konnektörlü bataryadır. Üreticinin net kütle değeri 914 g ±25 g, paket zarfı ise 68 mm x 45 mm x 144 mm’dir. Bu değer, önceki 526,73 g CAD temsili kütlesinin yerine kullanılmıştır. CAD zarfı 150 mm x 70 mm x 46 mm olduğundan, üretim öncesi batarya tepsisinde kablo çıkışı, dengeleme soketi, darbe koruma katmanı ve sıkıştırma payı için ayrıca boşluk kontrolü yapılmalıdır.')
F(CAD/'BataryaYerleşim_Bilgileri01.png','Şekil 3.1.2.14. 6S 8000 mAh bataryanın boyutları, kütle özelliği ve gövde içindeki konumu.',150)
H('3.1.2.8.2 PM07 Güç Modülü',3)
P('Bölüm 7’de tanımlanan Holybro PM07 14S güç modülü, ana batarya ile uçuş kontrol sistemi arasındaki gerilim/akım ölçüm ve güç dağıtım arayüzüdür. Üretici verisinde 68 mm x 50 mm x 10 mm boyut ve 43,8 g kütle verilmektedir. PM07’nin 2S-14S giriş aralığı ve 90 A sürekli PCB akım sınıfı, 6S batarya ve 80 A ESC seçimi için gerilim düzeyinde uyumludur; ancak XT60 ve 12 AWG hazır kablonun sürekli akım sınırı ayrıca kontrol edilmelidir. PM07’nin fiziksel konumu CAD master montajında ayrı parça olarak sabitlenmediğinden, bu kütle ara CoG hesabına katılmamıştır.')
H('3.1.2.8.3 Batarya Tepsisi',3)
P('Batarya tepsisi, kütle merkezine etkisi yüksek olan bataryayı tanımlı bir konumda tutar ve uçuş sırasındaki boylamsal kaymayı engeller. Tepsi, batarya ile gövde kabuğu arasındaki doğrudan temasın kontrol edildiği arayüzdür. Tepsinin tasarım değerlendirmesinde ana yük yolu, tutucu elemanlar, servis erişimi ve batarya değişiminde tekrar konumlanma birlikte ele alınmalıdır.')
F(CAD/'BatteryTrayYerleşim_Bilgileri.png','Şekil 3.1.2.16. Batarya tepsisinin gövde içi konumu ve batarya arayüzü.',150)
H('3.1.2.8.4 FLAME 80A ESC Yerleşimi',3)
P('ESC, motor-güç kabloları ile uçuş kontrol kabloları arasında yer alan güç elektroniği arayüzüdür. CAD’de ESC_Flame_80A parçası 82 mm x 60 mm x 26 mm zarf ve 68,508 g temsili kütle ile görünür; ancak nihai BOM’daki T-MOTOR FLAME 80A 12S V2.0 için kullanılacak üretici kütlesi 109 g’dır. Bu fark, CAD fiziksel malzeme tanımından kaynaklanır ve RevC master montajının sonraki kütle-properties çalışmasında düzeltilmelidir. ESC’nin ısıl kaybı ve kablo uzunluğu; gövde içi soğutma yolu, gerilim düşümü ve EMI riskiyle birlikte ele alınmalıdır.')
F(CAD/'ESC_FlameYerleşim_Bilgileri01.png','Şekil 3.1.2.18. ESC’nin gövde içi konumu ve çevre bileşenlerle mesafesi.',150)

H('3.1.2.9 Uçuş Kontrol Seyrüsefer ve Görev Aviyoniği',2)
P('FDR RevC’de aviyonik bileşenler, gövde içinde tek tek katı parça olarak tanımlanmıştır. Bu yaklaşım, yalnızca görsel bir ayrıntı değildir: her bileşenin zarfı, kütlesi, konumu, servis erişimi ve çevre bileşenlerle çakışma riski CAD montajında izlenebilir olur. DDR’de bu ekipmanların her biri için ayrı zarf ve Properties çıktısı bulunmadığından FDR değerleri “yeni parça bazlı kontrol verisi” olarak raporlanmıştır.')
H('3.1.2.9.1 Cube Orange Plus ve ADS-B Carrier Board',3)
P('Bölüm 7 nihai BOM’unda uçuş kontrol birimi Pixhawk Cube Orange+ IMU V8 Standard Set - ADS-B Carrier Board olarak tanımlanmıştır. ADS-B IN taşıyıcı kart, uAvionix 1090 MHz alıcı ve yerleşik anten aracılığıyla çevredeki ADS-B OUT yayınlı hava araçlarının konum, irtifa, hız ve kimlik bilgisinin yer istasyonunda izlenmesini sağlar. Cube Orange+ ile ADS-B carrier board birleşik ürünün bildirilmiş kütlesi 73 g, zarfı 94,5 mm x 44,3 mm x 31 mm’dir. Önceki CAD kütlesi 80,196 g olduğundan, ara CoG hesabında bu parça için 73 g kullanılmıştır.')
F(CAD/'CubaOrangeYerleşim_Bilgileri01.png','Şekil 3.1.2.20. Cube Orange uçuş kontrol kartının CAD zarfı, kütlesi ve yerleşimi.',150)
H('3.1.2.9.2 433 MHz Telemetri Bağlantısı',3)
P('Bölüm 7’de 433 MHz telemetri bağlantısı uçuş kontrol paketinin parçası olarak tanımlanmıştır. Bu bağlantı, hava aracı ile yer istasyonu arasında MAVLink/seri veri aktarımı için kullanılır; antenin karbon yüzeylerden, GNSS anteninden ve yüksek akım kablolarından ayrılması gerekir. BOM’da üretici/model ve hava aracı radyo kütlesi belirtilmediği için bu alt sistem için sayısal kütle veya CoG katkısı varsayılmamıştır. Nihai model seçildiğinde, 433 MHz radyo, anten ve koaksiyel kablo birlikte tartılarak master montaja eklenmelidir.')
H('3.1.2.9.3 Holybro H-RTK F9P Rover Lite',3)
P('Nihai BOM’daki Holybro H-RTK F9P Rover Lite (SKU12017), hava aracı rover uygulaması için tanımlıdır. Üretici teknik dokümanı bu ürün için 76 mm çap, 20 mm yükseklik ve 106 g kütle verir. CAD’de GPS_RTK_Module parçası 824,063 g olarak tanımlanmıştır; bu değer gerçek ürün kütlesi değildir. GNSS anteninin üst yarımküre görüşü, güç kablolarından ayrımı ve bağlantı elemanları ile toplam taşınan kütle, nihai CAD güncellemesinde işlenmelidir.')
F(CAD/'GPS_RTK_ModuleYerleşim_Bilgileri01.png','Şekil 3.1.2.22. GNSS/RTK modülünün RevC CAD yerleşimi.',150)
H('3.1.2.9.4 NVIDIA Jetson Orin Nano Developer Kit ve Soğutma Fanı',3)
P('NVIDIA Jetson Orin Nano Developer Kit’in üretici carrier-board teknik dokümanında bildirilen kütlesi 0,175 kg’dır. Bu nedenle önceki 792,791 g CAD kütlesi geçersizdir ve ara kütle/CoG hesabında 175 g kullanılmıştır. CAD parçasının 79 mm x 100 mm x 21 mm zarfı, gerçek developer kit carrier board ölçüsüyle uyumludur. Jetson fanı CAD’de ayrı parça olarak görünse de üreticinin 175 g developer kit kütlesi fanlı kit bütününe ilişkindir; aynı fan ayrıca ikinci kez toplama eklenmemelidir.')
F(CAD/'JetsonYerleşim_Bilgileri01.png','Şekil 3.1.2.24. NVIDIA Jetson Orin Nano’nun CAD kütle ve zarf bilgileriyle gövde içi yerleşimi.',150)
H('3.1.2.9.5 Kamera',3)
P('Sony IMX219 sınıfı kamera, görev görüş hattını belirleyen faydalı yük bileşenidir. Tasarım detaylarında kamera için 640x480 piksel çözünürlükte 30 FPS, yaklaşık 79,3 derece yatay görüş alanı ve yaklaşık 12 derece aşağı pitch tanımlanmıştır. CAD yerleşimi, optik eksenin gövde açıklığına göre konumunu ve kamera zarfını kontrol etmek için kullanılır. Görüş alanı, gövde veya pervane tarafından kapanmama durumu ile saha görüntü testiyle doğrulanmalıdır.')
F(CAD/'CameraYerleşim_Bilgileri01.png','Şekil 3.1.2.28. IMX219 sınıfı kameranın gövde içi/önü yerleşim görünüşü.',150)

PB(); H('3.1.2.10 Paraşüt Kurtarma Sistemi',2)
P('Paraşüt kurtarma sistemi, kapak ve bırakma mekanizmasının ayrı CAD bileşenleriyle modellenmiştir. DDR’de görev sonu paraşütle iniş gereksinimi tanımlanmış olmakla birlikte, mekanizma için tekil CAD zarfı verilmemiştir. FDR’de bu durum giderilmiş; hareketli serbest bırakma bileşeni ile kapak parçası montaj kontrolüne dahil edilmiştir. Böylece kurtarma sistemi, yalnızca prosedürel bir görev adımı değil, boyut ve çakışma bakımından izlenebilir bir alt sistem hâline gelmiştir.')
H('3.1.2.10.1 Paraşüt Bırakma Mekanizması',3)
P('Parachute_Release CAD parçası 65,958 mm uzunluk, 30,000 mm genişlik ve 46,833 mm yükseklik zarfına; 49,819 g CAD kütlesine sahiptir. Parçanın kütle merkezi CAD dünya koordinatında x=250,057 mm, y=-10,000 mm ve z=75,049 mm olarak tanımlanmıştır. Bu veri, mekanizmanın gövde ön-arka dağılımındaki etkisini ve parça ile paraşüt kapağı arasındaki yerleşimi kontrol etmek için kullanılır.')
F(CAD/'Parachute_ReleaseYerleşim_Bilgileri01.png','Şekil 3.1.2.30. Paraşüt bırakma mekanizmasının FDR CAD zarfı, kütlesi ve gövde içi konumu.',150)
H('3.1.2.10.2 Paraşüt Kapağı',3)
P('Paraşüt kapağı, kanopi ve bırakma mekanizması için dış kabuk sürekliliğini koruyan arayüzdür. Kapağın CAD yerleşimi; açılma hattı, gövde konturu ve komşu elektroniklerle mesafeyi kontrol etmeye yarar. Kapak geometrisinin serbest bırakma sonrasında paraşüt çıkış yolunu daraltmaması gerekir. Bu doğrulama, masaüstü açılma deneyi ve nihai emniyet testiyle tamamlanmalıdır.')
F(CAD/'ParaşütKapağıYerleşim_Bilgileri.png','Şekil 3.1.2.32. Paraşüt kapağının gövde üzerindeki konumu ve kurtarma sistemi erişim arayüzü.',150)

H('3.1.2.11 Kütle Merkezi Yapısal Analiz ve Montaj Doğrulaması',2)
P('Parça bazlı boyut güncellemesi, Bölüm 3.1.1’deki kütle ve denge çıktılarından ayrı düşünülemez. FDR master CAD Properties ekranındaki referans montaj kütlesi 10,158917 kg ve ağırlık merkezi (666,818; -2,703; 15,348) mm’dir. Bölüm 3.1.1’deki 11,458917 kg nihai uçuş konfigürasyonu; CAD montajına ilave olarak servo grubu, PM07, telemetri, paraşüt paketi, kablo ve bağlantı kütlelerini içeren sistem kütle bütçesidir. Bu bölümdeki parça bazlı üretici kütlesi kayıtları, geometrik yerleşim ile kütle bütçesini aynı konfigürasyon altında eşleştirir.')
d.add_page_break()
T(['Düzeltilen parça','CAD kütlesi','Doğrulanmış kütle','Kütle farkı','CoG hesabındaki parça merkezi'],[
['GAONENG 6S 8000 mAh batarya','526,730 g','914,000 g','+387,270 g','(500,708; 0,251; 27,611) mm'],
['Jetson Orin Nano Developer Kit','792,791 g','175,000 g','-617,791 g','(670,005; -5,203; 20,151) mm'],
['Cube Orange+ ADS-B seti','80,196 g','73,000 g','-7,196 g','(775,000; 9,247; 17,434) mm'],
['FLAME 80A 12S V2.0 ESC','68,508 g','109,000 g','+40,492 g','(870,000; 11,826; 12,998) mm'],
['H-RTK F9P Rover Lite','824,063 g','106,000 g','-718,063 g','(1103,267; 0,161; 81,470) mm']
],[42,28,31,28,55],7.4)
P('Üretici kütleleri ile CAD parça merkezleri arasındaki ilişki, her bir bileşen için xCG,yCG,zCG = [M0·CG0 + Σ(Δmi·ri)] / [M0 + ΣΔmi] bağıntısıyla izlenir. Beş bileşen için yapılan ikame hesabı, kütle özelliklerinin malzeme tanımlı CAD kütlesinden bağımsız olarak yönetildiğini gösterir; ancak bu bölümde ana kütle ve ağırlık merkezi sonucu olarak Bölüm 3.1.1’de tanımlanan RevC master montaj referansı korunur.')
T(['RevC kütle ve denge referansı','Değer','Kapsam'],[
['Master CAD montaj kütlesi','10,158917 kg','Bölüm 3.1.1 RevC CAD referansı'],
['Nihai uçuş kütle bütçesi','11,458917 kg','Bölüm 3.1.1; CAD montajı ve sistem entegrasyon kütleleri'],
['XCG / YCG / ZCG','(666,818; -2,703; 15,348) mm','RevC master CAD datumunda kütle merkezi'],
['Kütle ikame hesabı','Parça bazında uygulanmıştır','Üretici kütleleri ile CAD yerleşimlerinin izlenmesi'],
['Ixx / Iyy / Izz','1,919 / 1,042 / 2,911 kg·m²','Bölüm 3.1.1 RevC CAD atalet referansı']
],[47,40,82])
P('AT4120 motor, dört D954SW servo, PM07, 433 MHz telemetri, paraşüt paketi, kablo ve bağlantı elemanları; Bölüm 3.1.1’deki nihai uçuş kütle bütçesinde sistem seviyesinde yer alır. Bu bölümde ise her alt sistemin CAD zarfı, montaj arayüzü ve yerleşim ilişkisi tanımlanarak kütle bütçesinin geometri ile izlenebilirliği sağlanmıştır.')
P('Bölüm 3.2.1’deki yapısal analiz modeli, bu bölümde verilen RevC master geometriye bağlanır. Kanat kökü-seren arayüzü, aileron menteşeleri, motor bağlantısı, T-kuyruk T-bağlantısı, batarya tepsisi ve paraşüt bırakma noktaları; FDR zarfı ve nihai uçuş kütle bütçesiyle tanımlanan yük durumlarının uygulama bölgeleridir.')
H('3.1.2.12 Sonuç ve Konfigürasyon Doğrulama Matrisi',2)
P('FDR RevC’de hava aracı, tekil STL parçaları ve bu parçaların tam montajdaki konumlarıyla tanımlanmıştır. Ana geometri için kesin FDR referans değerleri; 1501,102 mm tam uzunluk, 2400,051 mm açıklık, 523,565 mm yükseklik, 0,639758 m² brüt kanat alanı, 9,004 AR ve 266,560 mm MAC’tir. Bu bölümde tanımlanan alt sistem parçaları, aynı montajın konfigürasyon kontrollü bileşenleridir.')
P('RevC boyut, yerleşim ve kontrol yüzeyi seti; görev icra simülasyonunda başarıyla işletilen hava aracı konfigürasyonudur. Simülasyon başarısı; geometri, itki-enerji zinciri, aviyonik mimari ve komut limitlerinin aynı sistem tanımı altında çalıştığını gösteren konfigürasyon doğrulama çıktısı olarak değerlendirilmiştir.')
T(['Doğrulama nesnesi','FDR kanıtı','Sonraki doğrulama'],[
['Tam montaj zarfı','Fusion 360 Properties','Üretim sonrası ölçü kontrolü'],
['Sağ-sol kanat ve aileron simetrisi','Tekil STL zarfı ve CAD yerleşimi','Mekanik montaj ve sapma zarfı'],
['Gövde içi bileşenler','Parça bazlı CAD görüntüleri','Gerçek donanım kütlesi ve çakışma kontrolü'],
['T-kuyruk','Planform CAD Measure; elevator/rudder yerleşimi','Ortak datum X koordinatları, menteşe, servo ve yapısal yük doğrulaması'],
['İtki grubu','Motor/pervane CAD konumu','Statik itki, akım ve titreşim testi'],
['Paraşüt sistemi','Kapak ve bırakma mekanizması CAD zarfı','Masaüstü açılma ve emniyet testi']
],[42,63,64])

H('Kaynakça',1)
refs=[
'Abbott, I. H., & von Doenhoff, A. E. (1959). Theory of wing sections: Including a summary of airfoil data. Dover Publications.',
'Anderson, J. D. (2016). Fundamentals of aerodynamics (6th ed.). McGraw-Hill Education.',
'Airbot Systems. (n.d.). Cube Orange+ ADS-B carrier board. https://www.airbot-systems.com/produit/cube-orange-plus-ads-b/?lang=en',
'Bruhn, E. F. (1973). Analysis and design of flight vehicle structures. Tri-State Offset Company.',
'CubePilot. (n.d.). ADS-B IN carrier board. https://docs.cubepilot.org/carrier-boards/ads-b-carrier-board.md',
'Etkin, B., & Reid, L. D. (1996). Dynamics of flight: Stability and control (3rd ed.). John Wiley & Sons.',
'GAONENG. (n.d.). GNB HV 6S 22.8 V 8000 mAh 70C LiPo battery XT90. https://www.gaoneng.shop/products/gaoneng-gnb-hv-6s-22-8v-8000mah-70c-lipo-battery-xt90',
'Gudmundsson, S. (2021). General aviation aircraft design: Applied methods and procedures (2nd ed.). Butterworth-Heinemann.',
'Hitec Commercial Solutions. (n.d.). D954SW actuator product details. https://www.hiteccs.com/actuators/product-details/D954SW',
'Holybro. (n.d.). H-RTK F9P specification and comparison. https://docs.holybro.com/gps-and-rtk-system/f9p-h-rtk-series/standard-f9p-uart/specification-and-comparison',
'Holybro. (n.d.). PM07 power module 14S. https://holybro.com/products/pixhawk-4-power-module-pm07',
'Holybro. (n.d.). SiK telemetry radio V3. https://docs.holybro.com/radio/sik-telemetry-radio-v3',
'McCormick, B. W. (1995). Aerodynamics, aeronautics, and flight mechanics (2nd ed.). John Wiley & Sons.',
'Megson, T. H. G. (2017). Aircraft structures for engineering students (6th ed.). Butterworth-Heinemann.',
'Nelson, R. C. (1998). Flight stability and automatic control (2nd ed.). McGraw-Hill.',
'NVIDIA. (2024). Jetson Orin Nano developer kit carrier board specification (SP-11324-001, Rev. 1.3). https://developer.download.nvidia.com/assets/embedded/secure/jetson/orin_nano/docs/Jetson-Orin-Nano-DevKit-Carrier-Board-Specification_SP-11324-001_v1.3.pdf',
'Raymer, D. P. (2018). Aircraft design: A conceptual approach (6th ed.). American Institute of Aeronautics and Astronautics. https://doi.org/10.2514/4.104909',
'Roskam, J. (1985). Airplane design, Part II: Preliminary configuration design and integration of the propulsion system. Roskam Aviation and Engineering Corporation.',
'T-MOTOR. (n.d.). AT4120 long shaft fixed-wing motor. https://store.tmotor.com/product/at4120-long-shaft-fixed-wing-motor.html',
'T-MOTOR. (n.d.). FLAME 80A 12S V2.0 ESC. https://store.tmotor.com/product/flame-80a-12s-v2-esc.html'
]
for x in refs:
    p=d.add_paragraph(x); p.paragraph_format.left_indent=Mm(8); p.paragraph_format.first_line_indent=Mm(-8); p.paragraph_format.space_after=Pt(5)

OUT.parent.mkdir(exist_ok=True); d.core_properties.title='Bölüm 3.1.2 Hava Aracı Boyut Güncellemeleri'; d.core_properties.author='Yiğido ANKA Takımı'; d.save(OUT); print(OUT)
