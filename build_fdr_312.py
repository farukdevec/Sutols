from pathlib import Path
from docx import Document
from docx.shared import Mm, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.section import WD_SECTION
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(r"C:\sutol\Sutols")
OUT = ROOT / "output" / "Yiğido_ANKA_FDR_Bolum_3_1_2_Hava_Araci_Boyut_Guncellemeleri.docx"
SRC = ROOT / "_fdr_source"
CAD = SRC / "cad" / "YigidoAnka_İHA_Bilgileri" / "05_Teknik_Resimler_ve_Görseller"
IMG_ASSEMBLY = SRC / "extracted_docx_media" / "image1.png"

def shade(cell, fill):
    tcPr = cell._tc.get_or_add_tcPr(); shd = OxmlElement('w:shd'); shd.set(qn('w:fill'), fill); tcPr.append(shd)
def border(cell, color='D9D9D9'):
    tcPr = cell._tc.get_or_add_tcPr(); b = OxmlElement('w:tcBorders')
    for k in ('top','left','bottom','right','insideH','insideV'):
        x=OxmlElement('w:'+k); x.set(qn('w:val'),'single'); x.set(qn('w:sz'),'4'); x.set(qn('w:color'),color); b.append(x)
    tcPr.append(b)
def set_cell_margins(cell, top=90, start=90, bottom=90, end=90):
    tc = cell._tc; tcPr=tc.get_or_add_tcPr(); mar=tcPr.first_child_found_in('w:tcMar')
    if mar is None: mar=OxmlElement('w:tcMar'); tcPr.append(mar)
    for side,val in [('top',top),('start',start),('bottom',bottom),('end',end)]:
        node=mar.find(qn('w:'+side))
        if node is None: node=OxmlElement('w:'+side); mar.append(node)
        node.set(qn('w:w'),str(val)); node.set(qn('w:type'),'dxa')
def set_repeat_table_header(row):
    trPr=row._tr.get_or_add_trPr(); el=OxmlElement('w:tblHeader'); el.set(qn('w:val'),'true'); trPr.append(el)
def keep(p):
    pPr=p._p.get_or_add_pPr(); x=OxmlElement('w:keepNext'); pPr.append(x)
def add_page_field(p):
    r=p.add_run('Sayfa '); fld=OxmlElement('w:fldSimple'); fld.set(qn('w:instr'),'PAGE'); p._p.append(fld)

doc=Document()
sec=doc.sections[0]
sec.top_margin=Mm(20); sec.bottom_margin=Mm(18); sec.left_margin=Mm(22); sec.right_margin=Mm(18)
sec.header_distance=Mm(10); sec.footer_distance=Mm(10)
styles=doc.styles
styles['Normal'].font.name='Arial'; styles['Normal']._element.rPr.rFonts.set(qn('w:ascii'),'Arial'); styles['Normal']._element.rPr.rFonts.set(qn('w:hAnsi'),'Arial'); styles['Normal'].font.size=Pt(10.5)
styles['Normal'].paragraph_format.line_spacing=1.18; styles['Normal'].paragraph_format.space_after=Pt(7)
for nm,size in [('Title',16),('Heading 1',13),('Heading 2',11.5),('Heading 3',10.8)]:
    s=styles[nm]; s.font.name='Arial'; s._element.rPr.rFonts.set(qn('w:ascii'),'Arial'); s._element.rPr.rFonts.set(qn('w:hAnsi'),'Arial'); s.font.size=Pt(size); s.font.color.rgb=RGBColor(0,0,0)
    s.font.bold=True
styles['Heading 1'].paragraph_format.space_before=Pt(14); styles['Heading 1'].paragraph_format.space_after=Pt(8)
styles['Heading 2'].paragraph_format.space_before=Pt(11); styles['Heading 2'].paragraph_format.space_after=Pt(6)

header=sec.header.paragraphs[0]; header.alignment=WD_ALIGN_PARAGRAPH.RIGHT; header.add_run('Yiğido ANKA | FDR | Bölüm 3.1.2').font.size=Pt(8)
footer=sec.footer.paragraphs[0]; footer.alignment=WD_ALIGN_PARAGRAPH.CENTER; add_page_field(footer); footer.runs[0].font.size=Pt(8)

def h(text, level=1):
    p=doc.add_paragraph(text, style=f'Heading {level}'); keep(p); return p
def p(text='', boldlead=None):
    para=doc.add_paragraph()
    if boldlead:
        r=para.add_run(boldlead); r.bold=True
    para.add_run(text)
    para.paragraph_format.first_line_indent=Mm(6) if not boldlead else Mm(0)
    return para
def bullet(text):
    para=doc.add_paragraph(style='List Bullet'); para.add_run(text); return para
def figure(path, caption, width=155):
    par=doc.add_paragraph(); par.alignment=WD_ALIGN_PARAGRAPH.CENTER; par.add_run().add_picture(str(path), width=Mm(width))
    cap=doc.add_paragraph(caption); cap.alignment=WD_ALIGN_PARAGRAPH.CENTER; cap.runs[0].italic=True; cap.runs[0].font.size=Pt(9)
def table(headers, rows, widths=None, font=8.5):
    t=doc.add_table(rows=1, cols=len(headers)); t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.style='Table Grid'; set_repeat_table_header(t.rows[0])
    for j,txt in enumerate(headers):
        c=t.rows[0].cells[j]; c.text=str(txt); shade(c,'1F4E78'); border(c); set_cell_margins(c); c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
        for r in c.paragraphs[0].runs: r.font.color.rgb=RGBColor(255,255,255); r.font.bold=True; r.font.size=Pt(font); r.font.name='Arial'
    for i,row in enumerate(rows):
        cells=t.add_row().cells
        for j,txt in enumerate(row):
            c=cells[j]; c.text=str(txt); border(c); set_cell_margins(c); c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
            if i%2: shade(c,'EAF2F8')
            for pp in c.paragraphs:
                for r in pp.runs: r.font.name='Arial'; r.font.size=Pt(font)
    if widths:
        for row in t.rows:
            for i,w in enumerate(widths): row.cells[i].width=Mm(w)
    doc.add_paragraph().paragraph_format.space_after=Pt(2)
    return t
def eq(text):
    para=doc.add_paragraph(); para.alignment=WD_ALIGN_PARAGRAPH.CENTER; r=para.add_run(text); r.bold=True; r.font.name='Cambria Math'; r.font.size=Pt(11); return para
def pb(): doc.add_page_break()

doc.add_paragraph('Bölüm 3.1.2 Hava Aracı Boyut Güncellemeleri', style='Title')
p("Bu bölüm, Yiğido ANKA sabit kanatlı İHA'nın DDR sonrasında RevC nihai CAD montajında kilitlenen kanat, gövde ve T-kuyruk geometrisini sunmaktadır. Nihai montaj zarfı 1501,102 mm uzunluk, 2400,051 mm açıklık ve 523,565 mm yüksekliktir. Değişiklik, yalnızca çizim ölçeğinin güncellenmesi değildir; kanat planformu, gövde iç yerleşimi ve kuyruk moment kolu aynı sayısal CAD referansında yeniden birleştirilmiştir. Bu nedenle FDR değerleri, sonraki kütle-denge, yapısal analiz ve kontrol yüzeyi doğrulamalarında kullanılacak konfigürasyon kontrol değerleridir.")
p('DDR’deki kavramsal boyutlar, analitik ilk boyutlandırma için yararlı bir başlangıç noktası sağlamıştır. FDR’de ise parça modelinin gerçek sınırlandırma kutusu, montaj ara yüzleri ve CAD kütle özellikleri esas alınmıştır. Bu yaklaşım, farklı bölümlerde birbiriyle çelişen açıklık, alan, kütle merkezi ve moment kolu kullanılmasını önlemek amacıyla uygulanmıştır. CAD ölçüleri Fusion 360 Properties çıktısından; açıklık ve yerleşim kontrolü ise nihai montaj görüntüsünden izlenebilir biçimde alınmıştır.')
figure(IMG_ASSEMBLY, 'Şekil 3.1.2.1. RevC nihai CAD montajı ve Fusion 360 sınırlandırma kutusu: uzunluk 1501,102 mm, genişlik/açıklık 2400,051 mm, yükseklik 523,565 mm.')
h('3.1.2.1 Veri Kaynağı, Referans Sistemi ve Revizyon Yönetimi',2)
p('Bu bölümde “boyut” ifadesi üç farklı kavram için ayrı ayrı kullanılmaktadır: (i) montaj zarfı, bütün hava aracının dış sınırını verir; (ii) planform alanı, aerodinamik referans alanıdır; (iii) parça zarf veteri, ilgili STL/CAD parçasının x-yönündeki en büyük mesafesidir. Bu ayrım özellikle 0,266 m ifadesinin yanlışlıkla MAC olarak yorumlanmasını önler. Nihai CAD’de ana kanat parçasının zarf veteri 266,560 mm’dir; bu değer yerel kök/uç veterleriyle ve aerodinamik referans alanıyla birlikte aşağıda ayrıca tanımlanmıştır.')
table(['Veri seti','Revizyon / kapsam','Bu bölümdeki kullanım'],[
['DDR','Detay değerlendirme raporu, kavramsal geometri','Eski değer ve değişim karşılaştırması'],
['RevC nihai CAD montajı','Fusion 360 montaj sınırlandırma kutusu','FDR zarf ölçüleri ve CoG bağlantısı'],
['RevC kanat STL/mesh','Sağ/sol kanat, açıklık 1203 mm/parça','Kanat zarf veteri ve mesh izdüşüm kontrolü'],
['RevC kuyruk/kontrol yüzeyi STL','Elevator ve rudder gövde ara yüzleri','Kuyruk ve kontrol yüzeyi boyutları'],
['Bölüm 3.1.1','Nihai kütle ve denge','Geometri-kütle merkezi etkisi']
],[35,52,79])

h('3.1.2.2 DDR FDR Geometri Karşılaştırması',2)
p('Karşılaştırma, DDR’de açıkça tanımlanan kavramsal değerler ile FDR RevC CAD verilerinin aynı birime çevrilmesiyle hazırlanmıştır. “Değişim” işareti FDR eksi DDR farkını, yüzde ise DDR değerine göre değişimi gösterir. DDR’de yüzey alanı veya moment kolu açıkça belirtilmeyen kalemler için yüzde değişim hesaplanmamış; bu durum “n/a” olarak gösterilmiştir. Bu tercih, belirsiz eski veriden görünürde kesin bir oran üretmemek içindir.')
table(['Parametre','DDR','FDR RevC','Değişim','%','Teknik gerekçe'],[
['Montaj uzunluğu','600,000 mm (gövde zarfı)','1501,102 mm (tam montaj)','+901,102 mm','+150,18','DDR gövde parçası yerine motor-pervane ve T-kuyruğu içeren tam montajın izlenmesi'],
['Montaj yüksekliği','60,000 mm (gövde zarfı)','523,565 mm (tam montaj)','+463,565 mm','+772,61','Dikey stabilize, T-kuyruk ve pervane zarfının dahil edilmesi'],
['Kanat açıklığı b','2120,000 mm','2400,051 mm','+280,051 mm','+13,21','Nihai CAD kanatları ve montaj ara yüzleri'],
['Kök veter croot','467,000 mm','266,560 mm','-200,440 mm','-42,92','DDR ilk boyutlandırması yerine nihai kanat parçası zarfı'],
['Uç veter ctip','382,000 mm','266,560 mm','-115,440 mm','-30,22','RevC kanat dış konturu; sabit veterli ana taşıyıcı bölge'],
['Brüt kanat alanı S','0,90000 m²','0,63975 m²','-0,26025 m²','-28,92','Sabit veterli planform, S = c × b'],
['Açıklık oranı AR','4,99','9,00','+4,01','+80,36','Açıklığın büyümesi ve alanın küçülmesi'],
['Mesh izdüşüm alanı','n/a','yaklaşık 0,6093 m²','n/a','n/a','Açıkta kalan STL mesh izdüşümü; brüt referans alan yerine kullanılmaz'],
['Yatay kuyruk hareketli yüzeyi','n/a','170,000 × 820,000 mm','n/a','n/a','Nihai elevator parçası CAD zarfı'],
['Dikey kuyruk hareketli yüzeyi','n/a','180,657 × 350,000 mm','n/a','n/a','Nihai rudder parçası CAD zarfı']
],[25,28,31,28,16,53],8)
p('Tablo 3.1.2.1’deki “gövde” satırında mutlak bir geometrik büyüme varmış izlenimi oluşmamalıdır. DDR’de verilen 600 mm, yalnızca gövde parçasının zarfıdır; FDR’deki 1501,102 mm ise pervane düzleminden kuyruk sonuna kadar bütün montajın zarfıdır. Bu nedenle iki değer, konfigürasyon olgunluğundaki farkı gösterir; tek başına aerodinamik gövdenin 150% uzatıldığı anlamına gelmez.')

h('3.1.2.3 Ana Kanat Planformunun Güncellenmesi',2)
p('Ana kanat, görev süresi ve düşük hızlı seyir gereksinimini karşılayan temel kaldırma yüzeyidir. DDR’de 2,120 m açıklıklı, 0,900 m² alanlı ve belirgin koniklik oranına sahip bir başlangıç planformu kullanılmıştır. FDR’de kanat, üretilebilirlik, modüler sağ-sol simetrisi ve karbon seren kovanlarının tekrarlanabilir yerleşimi için 266,560 mm zarf veterine sahip sabit-veterli bir ana taşıyıcı bölge etrafında yeniden tanımlanmıştır. Bu seçim, uçak hızını artırmak için değil; imalat parametrelerini ve montaj arayüzlerini daha iyi kontrol edebilmek için yapılmıştır.')
figure(CAD / 'SağKanatYerleşim_Bilgileri.png', 'Şekil 3.1.2.2. Nihai CAD üst görünüşünde sağ kanat yerleşimi. Görüntü, kanat-kuyruk-gövde ilişkisini ve sağ/sol simetriyi göstermektedir.')
p('266,560 mm değeri aşağıdaki hesaplarda kök ve uçte eşit kabul edilen brüt geometrik veterdir. Ancak CAD paketinin mesh raporundaki yaklaşık 0,6093 m² değer, gövde altında kalan bölge, açıklıklar ve yüzey kırpımları nedeniyle elde edilen açıkta kalan üstten izdüşüm alanıdır. Aerodinamik referans alanı için brüt planform alanının kullanılması, açıklık ve veter tanımıyla izlenebilir bir ilişki kurar. Mesh alanını brüt alan yerine kullanmak AR’nin 9,45 görünmesine yol açar; bu sayının farklı bir yüzey tanımından geldiği raporda açıkça belirtilmiştir.')
h('Adım adım kanat alanı ve açıklık oranı hesabı',3)
eq('S = [(c_root + c_tip) / 2] × b')
eq('S = [(0,266560 + 0,266560) / 2] × 2,400051 = 0,639759 m² ≈ 0,63975 m²')
eq('AR = b² / S = (2,400051)² / 0,639759 = 9,003 ≈ 9,00')
p('Kanat açıklığı 2,400051 m ve brüt alan 0,63975 m² kullanıldığında nihai geometrik açıklık oranı 9,00’dır. Aynı açıklık mesh izdüşüm alanı 0,6093 m² ile bölünürse ARmesh yaklaşık 9,46 olur. FDR performans, kararlılık ve yük hesaplarında bu iki tanım karıştırılmamalıdır: AR = 9,00 brüt referans alanına dayalı tasarım değeri; ARmesh ≈ 9,46 ise CAD mesh doğrulama değeridir.')

h('3.1.2.4 MAC Tanımı ve Kanat Alanı Belirsizliğinin Giderilmesi',2)
p('DDR incelemesinde “0,266 m” ifadesinin tanımsız bırakıldığı görülmüştür. FDR’de bu belirsizlik giderilmiştir: 0,266560 m, nihai ana kanat parçasının CAD x-zarf veteridir; MAC ile aynı sayısal değere eşit olmasının nedeni, kabul edilen brüt planformun sabit-veterli olmasıdır. Bu değer, DDR’deki 0,426 m MAC ile aynı değildir ve iki rapor arasında doğrudan aktarılmamalıdır.')
h('Ortalama aerodinamik veter hesabı',3)
p('Trapez planform için ortalama aerodinamik veter aşağıdaki ifade ile hesaplanır. Nihai koniklik oranı λ = ctip/croot = 1,000 olduğundan, ifade sabit-veter durumunda doğrudan croot değerine indirgenir.')
eq('λ = c_tip / c_root = 0,266560 / 0,266560 = 1,000')
eq('MAC = (2/3) c_root [(1 + λ + λ²)/(1 + λ)]')
eq('MAC = (2/3)(0,266560)[(1 + 1 + 1)/(1 + 1)] = 0,266560 m = 266,560 mm')
p('Bu eşitlik, 0,266560 m’nin rastgele yuvarlanmış bir “ortalama” olmadığını gösterir. CAD zarfındaki kök ve uç kesitleri aynı tasarım veterini koruduğu için geometrik ortalama veter ve MAC aynı değerdedir. Eğer daha sonraki CAD revizyonunda uç kesitte taper, winglet veya kesik uç uygulanırsa MAC yeniden hesaplanmalı; bu bölümdeki değer sabit kabul edilmemelidir.')
table(['Alan tanımı','Değer','Kullanım amacı','Kullanılmaması gereken yer'],[
['Brüt planform alanı','0,63975 m²','AR, MAC, kanat yüklemesi ve kuyruk hacim katsayıları','Mesh yüzey kalite/üretim kontrolü'],
['Üstten mesh izdüşüm alanı','≈0,6093 m²','STL/CAD şekil doğrulaması, açıkta kalan yüzey karşılaştırması','Brüt S gerektiren analitik boyutlandırma'],
['Kanat parçası zarf veteri','266,560 mm','Kök/uç geometrisi ve imalat zarfı','Tek başına gerçek ıslak alan veya profil alanı']
],[45,28,58,43])
p('Bu ayrımın fiziksel önemi vardır. Kanat yüklemesi W/S ve kuyruk hacim katsayıları, aynı S referansı ile hesaplanmalıdır. Bir denklemde 0,63975 m², diğerinde 0,6093 m² kullanılması; gerçekte tasarım değişmeden, stabilite veya performansın değişmiş gibi görünmesine neden olur. Bu nedenle Bölüm 3.1.4-3.1.7’de FDR referans alanı olarak 0,63975 m² korunmalıdır.')

pb(); h('3.1.2.5 Gövde Geometrisi ve İç Yerleşim Güncellemesi',2)
p('FDR gövde güncellemesi, bir dış kabuk ölçekleme çalışması değildir. Nihai montajda batarya tepsisi, Cube Orange+, Jetson Orin Nano, GPS/RTK, kamera, ESC, paraşüt bırakma mekanizması ve itki arayüzü aynı CAD ana referansı üzerinde yerleştirilmiştir. Bu yaklaşım, parça zarfını, kablo geçişlerini ve bakım erişimini kütle merkezi analiziyle birlikte değerlendirmeyi mümkün kılar. Gövde boyunca bileşenlerin konumu özellikle boylamsal denge açısından kritik olduğundan, boyut değişikliği Bölüm 3.1.1’deki nihai CoG ile birlikte okunmalıdır.')
figure(CAD / 'GövdeYerleşim_Bilgileri.png', 'Şekil 3.1.2.3. Nihai CAD’de gövde ve kanat-kuyruk yerleşimi. Yerleşim, montaj geometrisi ile aviyonik/kütle dağılımı arasındaki fiziksel ilişkiyi göstermektedir.')
table(['Gövde / montaj metrikleri','DDR tanımı','FDR RevC tanımı','Mühendislik yorumu'],[
['Boyuna referans','600,000 mm gövde zarfı','1501,102 mm tam montaj zarfı','Farklı ölçüm kapsamları açıkça ayrılmıştır'],
['Yükseklik referansı','60,000 mm gövde zarfı','523,565 mm tam montaj zarfı','T-kuyruk ve pervane zarfı dahil'],
['Genişlik / açıklık','Kanat açıklığı 2120,000 mm','2400,051 mm','Montaj CAD ölçüsü ile doğrulanmıştır'],
['Toplam kütle merkezi','DDR: x=13,392 mm','FDR: x=666,818 mm, y=-2,703 mm, z=15,348 mm','Koordinat başlangıcı değişmiştir; x farkı “fiziksel kayma” olarak yorumlanmaz']
],[38,39,50,47])
p('Bölüm 3.1.1’deki kütle merkezi karşılaştırması, DDR ve FDR koordinat başlangıçlarının farklı olduğunu göstermektedir. Bu nedenle xCG’de görülen +653,426 mm fark doğrudan bir trim değişimi değildir. FDR koordinat takımı tam montajın CAD dünya referansına göre tanımlanmıştır. FDR’de güvenilir boylamsal denge değerlendirmesi için CoG, ana kanat MAC’inin hücum kenarına göre ayrıca raporlanmalı; bir sonraki revizyonda bu dönüşüm çizim üzerinde sabit bir datumla gösterilmelidir.')

pb(); h('3.1.2.6 T Kuyruk Geometrisi ve Hacim Katsayıları',2)
p('FDR konfigürasyonu T-kuyruk düzenini korumaktadır. Bu karar, ana kanat iz akımından mümkün olduğunca uzak bir yatay kuyruk akımı sağlama, elevatör için yeterli moment kolu yaratma ve dikey stabilizenin üstünde simetrik bir yatay yüzey yerleştirme ihtiyacına dayanır. Konfigürasyon seçiminin tek başına “daha iyi” olduğu iddia edilmemiştir; burada amaç, sabit kanatlı görev, paraşüt geri kazanımı ve mevcut arka gövde arayüzü ile uyumlu bir çözümü korumaktır.')
figure(CAD / 'ElevatorYerleşim_Bilgileri.png', 'Şekil 3.1.2.4. Nihai CAD’de elevator/T-kuyruk yerleşimi ve arka gövde bağlantısı.')
figure(CAD / 'RudderYerleşim_Bilgileri.png', 'Şekil 3.1.2.5. Nihai CAD’de rudder/dikey kuyruk yerleşimi ve yanal-yönsel kontrol arayüzü.',145)
p('Nihai CAD parça zarfında elevator 170,000 mm veter ve 820,000 mm açıklığa; rudder ise 180,657 mm veter ve 350,000 mm yüksekliğe sahiptir. Bu zarf değerleri, hareketli yüzeyin dış boyutunu temsil eder. Hacim katsayısı hesabında tüm stabilizer alanı gerekiyorsa, üretim çiziminden sabit yüzey ile hareketli yüzey alanı ayrıştırılmalıdır. Aşağıdaki hesap, FDR’de CAD ile doğrudan doğrulanabilen hareketli yüzey zarfından elde edilen muhafazakâr geometrik kontrol değeridir; nihai statik stabilite sonucu değildir.')

h('Kuyruk hacim katsayılarının adım adım geometrik kontrolü',3)
p('Boyuna ve yönsel stabilite için klasik hacim katsayıları sırasıyla Vh = Sh lh/(S MAC) ve Vv = Sv lv/(S b) biçimindedir. Bu bölümde S=0,639759 m², b=2,400051 m ve MAC=0,266560 m kullanılmıştır. CAD menteşe referansları, ana kanat dış kontrol yüzeyi için x=0,640 m; elevator için x=1,350 m ve rudder için x=1,400 m vermektedir. Bu değerlerden yalnızca ön kontrol için moment kolları lh=0,710 m ve lv=0,760 m alınmıştır. Aerodinamik merkezler ile menteşe hatları aynı nokta olmadığından, bu katsayılar Bölüm 3.1.5’te XFLR5/kararlılık modeliyle yeniden doğrulanmalıdır.')
eq('S_h,geom = 0,170000 × 0,820000 = 0,139400 m²')
eq('V_h,geom = (0,139400 × 0,710000) / (0,639759 × 0,266560) = 0,582')
eq('S_v,geom = 0,180657 × 0,350000 = 0,063230 m²')
eq('V_v,geom = (0,063230 × 0,760000) / (0,639759 × 2,400051) = 0,0313')
p('Bu hesapta kullanılan Sh ve Sv yalnızca CAD’de tanımlı hareketli yüzey zarf alanlarıdır. Sabit stabilize alanının eklenmesiyle etkin Sh ve Sv artacaktır. Bu nedenle Vh,geom=0,582 ve Vv,geom=0,0313 değerleri, kuyruk sisteminin nihai aerodinamik hacim katsayıları olarak değil, geometri kontrolünün izlenebilir başlangıç değerleri olarak kullanılmalıdır. Bu sınırlama raporda açıkça korunmuştur; aksi hâlde hareketli yüzey alanı ile tüm kuyruk alanı karıştırılmış olur.')

h('3.1.2.7 Geometri Kütle Merkezi ve Yapısal Analiz Etkileşimi',2)
p('Geometri revizyonu, kütle bütçesinden bağımsız değerlendirilemez. Bölüm 3.1.1’de nihai montajın CAD tabanlı toplam kütlesi 10,158917 kg ve kütle merkezi (666,818; -2,703; 15,348) mm olarak raporlanmıştır. Kanat açıklığındaki artış, kanat kütlesinin yanal eksen boyunca daha geniş dağılmasına; T-kuyruk ve arka gövde arayüzü ise yunuslama ve sapma eksenlerindeki atalet dağılımına doğrudan etki eder. Ancak FDR’deki CoG sayısı, DDR’den farklı CAD datumunda ölçüldüğü için bu bölümde sahte bir “CoG kayması” türetilmemiştir.')
table(['Bölüm 3.1.1 FDR CAD çıktısı','Değer','Boyut güncellemesiyle ilişkisi'],[
['Toplam montaj kütlesi','10,158917 kg','Nihai boyutlar, gerçek parça/aviyonik yerleşimi ile birlikte değerlendirilmiştir'],
['XCG','666,818 mm','Tam montaj datumunda; kanat MAC datumuna dönüşüm ayrıca kontrol edilmelidir'],
['YCG','-2,703 mm','Merkez hattına yakın değer; sağ-sol kanat simetrisi için izleme parametresi'],
['ZCG','15,348 mm','Gövde, kanat ve T-kuyruk yüksekliği ile birlikte dinamik analiz girdisi'],
['Ixx / Iyy / Izz','1,919 / 1,042 / 2,911 kg m²','Genişlik, boy ve kuyruk kütle dağılımının nihai CAD sonucudur']
],[47,35,83])
p('Yapısal analiz Bölüm 3.2.1’de, bu bölümde kilitlenen master geometri kullanılmalıdır. Özellikle kanat kökü-seren arayüzü, gövde-kanat geçişi, T-kuyruk bağlantısı ve mancınık/paraşüt ara yüzleri; güncel ölçüler üzerinden statik, burkulma ve modal analizlere yeniden bağlanmalıdır. Bu bölüm yapısal dayanım sonucu iddia etmez; analiz modelinin doğru geometri ile kurulduğunu ve DDR sonuçlarının yeni ölçülere otomatik olarak taşınmaması gerektiğini ortaya koyar.')

pb(); h('3.1.2.8 Kontrol Yüzeyleriyle Geometrik Uyum',2)
p('Kontrol yüzeyleri FDR şablonunda ayrı Bölüm 3.1.3 altında ayrıntılandırılacaktır. Bununla birlikte, kanat ve kuyruk boyut güncellemesi kontrol yüzeyi arayüzlerini doğrudan belirlediği için burada yalnızca geometrik uyum kontrolü verilmiştir. Bu alt başlık, kontrol yüzeyleri başlığının içeriksiz kalmaması ve aynı zamanda tork/menteşe analizini yanlış bölüme taşımaması için sınırlı tutulmuştur.')
table(['Yüzey','Nihai CAD zarfı','Menteşe referansı','Limit','Boyut güncellemesine bağlı kontrol'],[
['Sağ aileron','51,270 × 550,000 mm','x=0,640 m; y=+0,822981 m','±15°','Kanat dış bölgesinde moment kolu ve sağ-sol eşleşme'],
['Sol aileron','53,629 × 550,000 mm','x=0,640 m; y=-0,822432 m','±15°','Asimetri/tolerans ve montaj boşluğu'],
['Elevator','170,000 × 820,000 mm','x=1,350 m','±25°','T-kuyruk arka gövde ara yüzü ve pitch otoritesi'],
['Rudder','180,657 × 350,000 mm','x=1,400 m','±20°','Dikey stabilize bağlantısı ve yaw otoritesi']
],[25,42,43,18,51],8.2)
p('Aileron, elevator ve rudder zarf değerleri CAD parça sınırlarından alınmıştır. Bu değerler yalnızca kapalı/dönmemiş konfigürasyon için geçerlidir. Maksimum sapmalarda oluşan zarf, servo stroku, menteşe momenti, bağlantı elemanı dayanımı ve gövde/kuyruk çarpışma kontrolü Bölüm 3.1.3 ve Bölüm 3.2.1’de ayrı doğrulama girdileri olmalıdır. Böylece bu bölüm geometriyi tanımlar, kontrol tasarımı ise kendi doğrulama zincirinde kalır.')

pb(); h('3.1.2.9 Doğrulama, Konfigürasyon Kontrolü ve Sonuç',2)
p('FDR boyut güncellemesinin doğrulama yaklaşımı; CAD gözlemi, analitik çapraz kontrol ve izleyen disiplin analizlerine girdi sağlama olarak üç seviyede kurulmuştur. Birinci seviyede Fusion 360 montaj sınırlandırma kutusu ve parça özellikleri okunmuştur. İkinci seviyede brüt kanat alanı, AR, MAC ve hareketli yüzey zarf alanlarından türetilen kuyruk hacim kontrol değerleri adım adım hesaplanmıştır. Üçüncü seviyede ise sonuçların Bölüm 3.1.1’deki kütle/CoG verisine ve Bölüm 3.2.1’deki yapısal modele aktarılması gerekmektedir.')
table(['Doğrulama nesnesi','Yöntem','Kabul / izleme ölçütü','Durum'],[
['Tam montaj zarfı','CAD Properties ekranı','1501,102 × 2400,051 × 523,565 mm','CAD ile doğrulandı'],
['Kanat alanı ve AR','Analitik çapraz kontrol','S=0,63975 m²; AR=9,00','Hesap ile doğrulandı'],
['MAC','Trapez planform denklemi','MAC=266,560 mm; λ=1,000','Hesap ile doğrulandı'],
['Kuyruk zarfı','CAD parça özellikleri','Elevator 170×820 mm; rudder 180,657×350 mm','CAD ile doğrulandı'],
['Stabilite türevleri','XFLR5/3B model','Vh/Vv etkin yüzey ve AC ile güncellenecek','Bölüm 3.1.5 girdisi'],
['Yapısal sonuçlar','FEA / el hesabı','RevC master geometri ile tekrar bağlanacak','Bölüm 3.2.1 girdisi']
],[38,34,62,45])
p('Sonuç olarak, FDR konfigürasyonunda kullanılacak ana boyutlar 1501,102 mm montaj uzunluğu, 2400,051 mm açıklık, 523,565 mm yükseklik, 266,560 mm kök ve uç veter, 0,63975 m² brüt kanat alanı, 9,00 açıklık oranı ve 266,560 mm MAC’tir. CAD mesh üstten izdüşüm alanı yaklaşık 0,6093 m² olup ayrı bir doğrulama metriğidir. Bu iki alan tanımının rapor boyunca ayrıştırılması, sonraki aerodinamik, stabilite, yük ve yapısal analizlerin tutarlı olmasının ön koşuludur.')

pb(); h('Kaynakça',1)
refs=[
'Abbott, I. H., von Doenhoff, A. E., & Stivers, L. S., Jr. (1945). Summary of airfoil data (NACA Report No. 824). National Advisory Committee for Aeronautics. https://ntrs.nasa.gov/citations/19930090976',
'Anderson, J. D. (2016). Fundamentals of aerodynamics (6th ed.). McGraw-Hill Education.',
'Autodesk. (2026). Fusion 360 CAD model properties: Yiğido ANKA RevC final assembly [Unpublished CAD model and exported property screenshots].',
'Raymer, D. P. (2018). Aircraft design: A conceptual approach (6th ed.). American Institute of Aeronautics and Astronautics. https://doi.org/10.2514/4.104909',
'Roskam, J. (1985). Airplane design, Part II: Preliminary configuration design and integration of the propulsion system. Roskam Aviation and Engineering Corporation.',
'Yiğido ANKA Takımı. (2026a). Yiğido ANKA Detay Değerlendirme Raporu [Unpublished competition report].',
'Yiğido ANKA Takımı. (2026b). Yiğido ANKA nihai tasarım ve geometri raporu, RevC [Unpublished CAD/STL design data].'
]
for x in refs:
    q=doc.add_paragraph(x); q.paragraph_format.left_indent=Mm(8); q.paragraph_format.first_line_indent=Mm(-8); q.paragraph_format.space_after=Pt(5)
h('Ek A Hesaplama Özeti',2)
p('Bu bölümdeki hesaplar brüt kanat referans alanı üzerinden yapılmıştır: b=2,400051 m; croot=ctip=MAC=0,266560 m; S=0,639759 m²; AR=9,003. Kuyruk hacim kontrolünde hareketli yüzey zarf alanları kullanılmış, dolayısıyla Vh,geom=0,582 ve Vv,geom=0,0313 sonuçları tüm stabilizer alanına dayalı nihai aerodinamik değerler olarak yorumlanmamıştır.')

OUT.parent.mkdir(parents=True, exist_ok=True)
doc.core_properties.title='Bölüm 3.1.2 Hava Aracı Boyut Güncellemeleri'
doc.core_properties.author='Yiğido ANKA Takımı'
doc.save(OUT)
print(OUT)
