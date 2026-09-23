# Sutols Sorun ve Çözüm Günlüğü

Bu dosya, canlı sitede veya yerel geliştirme sırasında doğrulanan kullanıcıya
görünür sorunların kalıcı kaydıdır. Yeni oturumlarda önce bu dosya okunmalı;
çözüm tamamlandığında ilgili kayıt silinmemeli, durumu ve çözüm notları
güncellenmelidir.

## Durumlar

- `AÇIK`: Sorun doğrulandı, çözüm bekliyor.
- `ÇALIŞILIYOR`: Kod değişikliği sürüyor.
- `DOĞRULAMA`: Çözüm uygulandı, canlı veya yerel doğrulama bekliyor.
- `ÇÖZÜLDÜ`: Çözüm ve ilgili testler doğrulandı.
- `ERTELENDİ`: Bilinçli olarak sonraya bırakıldı; gerekçesi yazılmalı.

## Güncelleme kuralı

Her çözümde ilgili kayda şu bilgiler eklenir:

1. Durum ve tamamlanma tarihi.
2. Kök neden.
3. Değiştirilen dosyalar ve çözümün kısa açıklaması.
4. Çalıştırılan testler ve sonuçları.
5. Canlı siteye çıktıysa dağıtım ve canlı doğrulama sonucu.

---

## SUT-001 — Sunum başlığı girişinin kullanılmaması

- **Durum:** DOĞRULAMA
- **Öncelik:** Yüksek
- **Tespit tarihi:** 2026-09-21
- **Ortam:** `https://sutols.com`

### Belirti

Kullanıcının “Sunum Başlığı” alanına yazdığı değer oluşturulan sunumda,
Firestore kaydında, tarayıcı başlığında ve URL'de kullanılmıyor. Sistem uzun
açıklama/prompt metnini başlık olarak kaydediyor.

Canlı testte başlık `Yapay Zekânın Eğitimde Kullanımı` olarak girildi. Buna
rağmen URL ve tarayıcı başlığı açıklama metninden üretildi; editörde sunum adı
`Yapay Zekâ ve Ders Planlama` oldu.

### Kod kanıtı

- `lib/ui/home_page.dart`: `_generatePresentation()` yalnızca
  `_promptController` değerini okuyor; `_titleController` üretim akışına
  aktarılmıyor.
- `lib/services/presentation_service.dart`: Firestore `title` alanına `topic`
  yazılıyor.

### Tamamlanma ölçütü

- Girilen başlık sunumun adı, Firestore `title` alanı, tarayıcı başlığı ve URL
  slug'ı için kullanılır.
- Açıklama metni içerik üretim promptu olarak ayrı kalır.
- Boş başlık için açıkça tanımlanmış bir otomatik başlık yedeği bulunur.
- Başlık aktarımı için widget/servis testi eklenir.

### Çözüm notları

2026-09-22 itibarıyla çözüm kodda uygulanmıştır; üretim dağıtımı yapılmadığı
için kayıt DOĞRULAMA durumundadır.

- Kök neden: başlık alanı üretim çağrısına aktarılmıyor, `topic` hem içerik
  konusu hem de kullanıcıya görünen sunum adı olarak kullanılıyordu.
- `home_page.dart` başlık ve içerik konusunu ayrı gönderiyor; `presentation_service.dart`
  başlığı Firestore `title`, tarayıcı başlığı, URL slug'ı ve editör başlangıç
  adına taşıyor. `presentation_title.dart` boş başlık için konu metninden en
  fazla 80 karakterlik deterministik yedek üretiyor.
- Başlık formu ve resolver doğrulaması: 5/5 PASS. Hedef birleşik Flutter
  suite'i: 115/115 PASS.
- Üretim/Firestore canlı kaydı veya deploy doğrulaması yapılmadı; yalnızca kod
  ve yerel test kanıtı mevcut.

---

## SUT-002 — Alakasız ve aşırı büyük 3B model seçimi

- **Durum:** DOĞRULAMA
- **Öncelik:** Yüksek
- **Tespit tarihi:** 2026-09-21
- **Ortam:** Canlı site ve yerel testler

### Belirti

Yapay zekâ, slayt konusuyla yeterince ilişkili olmayan 3B modeller seçebiliyor.
Canlı testte:

- `Faydalar ve Riskler` slaydına büyük bir `İFLAS` modeli yerleştirildi.
- `Etik İlkeler` slaydına etik hacker çalışma istasyonu yerleştirildi.
- Bazı 3B modeller slaytın büyük bölümünü kaplıyor veya kadrajdan taşıyor.

### Kod ve test kanıtı

- Eşleştirme: `lib/services/model_matching_service.dart`
- Üretim akışı: `lib/services/presentation_service.dart`
- Test: `test/model_matching_service_test.dart`
- 2026-09-21 hedefli test sonucu: 2 test başarısız.
  - `presentation-like GLB assets are never used as automatic 3D objects`
  - `context-only cooling terms do not select a cooling tower`

### Tamamlanma ölçütü

- Tek ve genel bir ortak kelime 3B model seçmek için yeterli olmaz.
- Konuya güvenilir model bulunamazsa fotoğraf, bileşen veya görselsiz düzen
  seçilir.
- Sunum bileşeni niteliğindeki GLB varlıkları otomatik nesne olarak seçilmez.
- Otomatik eklenen 3B model güvenli boyut ve kadraj sınırları içinde kalır.
- İlgili eşleştirme testlerinin tamamı geçer; canlı üretimde örnek sunumla
  görsel doğrulama yapılır.

### Çözüm notları

2026-09-22 itibarıyla çözüm kodda uygulanmıştır; üretim dağıtımı yapılmadığı
için kayıt DOĞRULAMA durumundadır.

- Kök neden: eski eşleştirme, tek ve genel ortak kelimeleri yeterli kanıt
  sayıyor; sunum bileşeni niteliğindeki GLB'ler de otomatik nesne adayı
  kalabiliyordu.
- `model_matching_service.dart` somut nesne kanıtı olmayan soyut başlıkları
  (`etik`, `risk`, `fayda` vb.) güçlü eşleşmeden çıkarıyor; sunum bileşeni
  işaretlilerini eliyor ve güvenli eşleşme yoksa 2B/fallback yolunu koruyor.
  Yerleşim sınırları da 3B nesnenin kadrajı taşırmamasını hedefliyor.
- Model eşleştirme: 8/8 PASS. Anıtkabir gerçek GLB'si yerel tarayıcıda yüklendi;
  gözlenen çerçeve left 69.5%, top 25%, width 26%, height 50%, camera 125%.
- Dağıtılmış uygulamadaki yeni akış veya canlı Firestore kaydı doğrulanmadı; GLB görsel
  doğrulaması yerel tarayıcı kapsamındadır.

---

## SUT-003 — Editörde çok satırlı başlığın kesilmesi

- **Durum:** DOĞRULAMA
- **Öncelik:** Yüksek
- **Tespit tarihi:** 2026-09-21
- **Ortam:** Canlı editör

### Belirti

`Kişiselleştirilmiş Öğrenme` gibi iki satıra geçen başlıkların alt satırı
editörde metin kutusunun dışında kalıyor ve kesiliyor. Aynı slayt sunum modunda
doğru görünebildiği için editör ile sunum çıktısı arasında görsel tutarsızlık
oluşuyor.

### İlgili alanlar

- `lib/models/slide_model.dart`
- `lib/state/presentation_controller.dart`
- `lib/ui/widgets/editor_shell.dart`
- `lib/ui/widgets/html_stage/`

Yerel çalışma ağacında metin kutusu davranışına ilişkin tamamlanmamış kullanıcı
değişiklikleri bulunuyor. Çözüm bu değişiklikler korunarak ilerletilmeli.

### Tamamlanma ölçütü

- Çok satırlı başlık editörde, önizlemede ve dışa aktarılan sunumda aynı görünür.
- Metin kutusu uygun biçimde büyür veya yazı boyutu tanımlı alt sınıra kadar
  küçülür; metin kesilmez.
- Dar, uzun ve Türkçe karakterli başlıklar için regresyon testi geçer.

### Çözüm notları

2026-09-22 itibarıyla çözüm kodda uygulanmıştır; üretim dağıtımı yapılmadığı
için kayıt DOĞRULAMA durumundadır.

- Kök neden: editör ve export farklı metin ölçüm/fit davranışı kullanıyor,
  özellikle dar başlıkta export runtime kök ölçümü eksik kalıyordu.
- `presentation_text_fit_script.dart` ortak runtime olarak editör ve export
  tarafından kullanılıyor; başlık taşması ölçülüyor, okunabilirlik alt sınırı
  korunuyor ve gerekirse kutu kontrollü büyütülüyor.
- Dar başlık export doğrulaması: `scrollHeight=clientHeight=99`, font
  `20.32px` (18px/1000 oranı). Hedef birleşik Flutter suite'i 115/115 PASS;
  render doğrulama testleri de yerelde hazır ve geçti.
- `flutter build web --release --no-pub` PASS. Üretim deploy'u ve canlı site
  doğrulaması yapılmadı.

---

## SUT-004 — Üretilen slayt metninin içerik kurallarına uymaması

- **Durum:** DOĞRULAMA
- **Öncelik:** Orta
- **Tespit tarihi:** 2026-09-21
- **Ortam:** Canlı site

### Belirti

Üretilen slaytlarda maddeler düz tirelerle ve uzun cümlelerle yazılıyor.
`.agents/rules/slayt_hazirlama_kurallari.md` içindeki kısa madde ve
`Vurgulu Başlık: Açıklama` biçimi uygulanmıyor.

### İlgili alanlar

- `lib/services/presentation_prompt_builder.dart`
- Sunum içerik kalite testleri ve değerlendirme kuralları

### Tamamlanma ölçütü

- Türkçe sunumlarda kısa ve taranabilir maddeler üretilir.
- Uygun slaytlarda her madde `Vurgulu Başlık: Açıklama` biçimini kullanır.
- İçerik tekrar etmez, eksik yüklem ve bozuk Türkçe içermez.
- İçerik kalite testleri ve en az bir canlı üretim örneği doğrulanır.

### Çözüm notları

2026-09-22 itibarıyla çözüm kodda uygulanmıştır; üretim dağıtımı yapılmadığı
için kayıt DOĞRULAMA durumundadır.

- Kök neden: eski proxy, `Konu:` + `İstenen Slayt Sayısı:` kalıbını yakalayıp
  yeni sözleşmeyi eski üç-madde promptuna dönüştürüyordu. Ayrıca normalize
  adımı vurgulu başlıkları silebiliyor, deterministic biçim ihlalleri yalnızca
  AI kalite puanıyla geçebiliyordu.
- `presentation_prompt_builder.dart` yeni istem başlıklarıyla sözleşmeyi
  koruyor; kısa `**Vurgulu Başlık:** Açıklama` maddelerini ve fiziksel görsel
  kanıtını istiyor. `presentation_content_quality.dart` normalizasyonu
  vurguyu koruyor; `presentation_judge_service.dart` biçim ihlalini
  deterministic olarak reddediyor.
- İçerik kuralları/render hedef birleşik suite'i: 115/115 PASS. Gerçek
  `sutols.online` backend'inde 5 slayt Türkçe eğitim üretimi PASS (yaklaşık
  40 sn); yerel HTML tarayıcıda vurgulu başlıklar görüldü.
- Geniş tarama ilk 140 pass / 8 fail verdi; sonradan güncellenen 2 stale test
  assert'i düzeltildi. Kalan 6 bulgu kapsam dışıdır: font URL'si, animasyon CSS'i,
  katalog etiketleri ve Fizik–Edebiyat beklentileri.
- Bu backend üretimi canlı deploy veya Firestore canlı kayıt doğrulaması
  değildir; üretim dağıtımı yapılmadı.

---

## 2026-09-22 doğrulama özeti

- Durum tüm SUT001–004 kayıtlarında `DOĞRULAMA`: kod ve yerel testler hazır,
  üretim deploy'u yapılmadı.
- Hedef birleşik Flutter suite'i 115/115 PASS; model matching 8/8; title
  form+resolver 5/5 PASS.
- Gerçek `sutols.online` backend'inde 5 slayt Türkçe eğitim üretimi yaklaşık
  40 saniyede PASS; HTML başlık vurguları yerel tarayıcıda doğrulandı.
- `flutter build web --release --no-pub` PASS.
- Değişen 23 dosyada `flutter analyze` sonucu `No issues found` PASS.
- HTML render hedefleri 6/6 PASS (başlık kesilmesi, önceki reveal, kalıcı
  yerleşim, dar Türkçe başlık, gövde kalınlığı, çok kelimeli animasyonlu
  vurgu). Kayıtlı gerçek cevapla replay testi, ek API çağrısı olmadan beş
  slaytı doğruladı (1/1 PASS);
  `education-live.html` güncel.
- `git diff --check` PASS. Ayrı mevcut `probe_grok.dart`/ortam uyarıları
  çalışma ağacının genel durum notu olarak izlenmektedir.
- Windows Atlas vault/path ile `powershell`/`pwsh` bu macOS ortamında yoktu.
  Commit ve deploy yapılmadı.

## 2026-09-21 canlı test özeti

- Giriş yapılmış hesapla 5 slaytlık sunum başarıyla üretildi.
- Üretim yaklaşık 30 saniyede tamamlandı.
- Beş slaydın tamamı oluştu ve otomatik kayıt çalıştı.
- Fotoğraf yükleme, 3B görüntüleme ve sunum modu çalıştı.
- Sunum modunda ileri/geri gezinme doğrulandı.
- Tarayıcı konsolunda üretim akışını durduran hata görülmedi.
- Test sunumu konusu: eğitimde yapay zekâ kullanımı.

## Sonraki çalışma sırası

1. Üretim dağıtımı sonrası SUT001–004 için canlı site ve Firestore kaydını
   ayrıca doğrula; doğrulama tamamlanırsa ilgili kayıtları `ÇÖZÜLDÜ` yap.
2. Kapsam dışı geniş tarama bulgularını (font URL, animasyon CSS, katalog
   etiketleri, Fizik–Edebiyat beklentileri) ayrı iş kalemleri olarak değerlendir.

---

## SUT-005 — Başarısız üretimin günlük hakkı tüketmesi

- **Durum:** DOĞRULAMA (2026-09-22; kod ve yerel testler tamamlandı, deploy yok)
- **Kök neden:** Üretim başlamadan sayaç artırılıyordu; AI veya kayıt hatası
  sonrasında güvenilir bir geri alma mekanizması yoktu.
- **Çözüm:** `presentation_service.dart` üretim öncesinde yalnızca kotayı okur.
  Yeni `presentation_persistence_service.dart`, kota artışını başarılı sunum
  kaydıyla aynı atomik commit'e taşır. Başarısız üretim/kayıt kota düşürmez.
  Son kayıt aşamasında kota yeniden okunur ve `updateTime` önkoşuluyla korunur.
- **Eşzamanlılık:** Ön kontrol rezervasyon değildir. Başka bir sekme son hakkı
  tüketirse son commit reddedilir; kota aşılmaz, bu sunum kaydedilmez.
- **Kanıt:** Kota ön kontrolü yalnızca GET yapar; sınır doluyken commit yoktur.
  Emülatörde hatalı slayt içeren commit hem sunumu hem kota artışını reddetti.

## SUT-006 — Yarım sunum ve kayıt tekrarında mükerrer işlem

- **Durum:** DOĞRULAMA (2026-09-22; üretim dağıtımı bekliyor)
- **Kök neden:** Ana belge ayrı POST, slayt/proje ikinci commit ile yazılıyordu.
  İlk adım başarılı, ikinci adım başarısız olduğunda yarım sunum kalabiliyordu.
- **Çözüm:** Yerelde bir kez ID ayrılır; ana belge, tüm slaytlar, proje ve kota
  aynı create-only/CAS commit içindedir. Kayıt servisinin ağ tekrarları aynı
  ID'yi kullanır. Yanıt kaybından sonra ana belgenin varlığı başarı makbuzudur;
  tekrar kota düşülmez. Ağ isteklerine 30 saniye sınırı ve sınırlı tekrar eklendi.
- **Belirsiz sonuç:** Tüm tekrarlar ve makbuz okuması da başarısızsa başarı
  varsayılmaz; hata sunum kimliğini içerir. Kalıcı ağ kesintisinde bu kimlik
  kontrol edilmeden yeni bir üretim başlatılmamalıdır. Tarayıcı yeniden
  açılışları arasında otomatik işlem sürdürme bu değişikliğin kapsamında değil.
- **Kurallar:** `firestore.rules` alt belge oluştururken `getAfter` ile aynı
  commit'teki ebeveyn sahipliğini denetler. Doğrulanmış kullanıcı, henüz
  olmayan bir ID için makbuz kontrolü yapabilir; mevcut özel sunumlara erişim
  kısıtları korunur. Güncelleme/silme sahiplik kuralları değiştirilmedi.
- **Kanıt:** `test/presentation_persistence_service_test.dart` 12/12 PASS.
  Yerel Firestore emülatörü testi 30 slayt + proje + kota, bozuk slaytta atomik
  ret, yetkisiz kullanıcı, kayıp cevap sonrası tekrar, eski sürüm önkoşulu
  ve kota sınırı senaryolarını kapsar (1 birleşik test PASS). Kayıp cevap
  senaryosu HTTP mock ile; kurallar/atomik rollback emülatörle doğrulandı.
- **Dağıtım sırası:** Önce Firestore kuralları, sonra web uygulaması.

## SUT-007 — 1–2 slayt isteğinde geçersiz sınır hesabı

- **Durum:** DOĞRULAMA (2026-09-22; üretim dağıtımı bekliyor)
- **Kök neden:** `(slideCount - 1).clamp(3, slideCount)` ifadesinde alt sınır
  üst sınırdan büyüktü.
- **Çözüm:** `nvidia_presentation_service.dart` 1, 2 ve 3 slayt isteğinde
  kendi sayısını alt sınır alır; daha büyük isteklerde mevcut bir eksik slayt
  toleransı korunur.
- **Kanıt:** Sınır testi ve mock AI ile gerçek `generatePresentation` çağrısında
  1/2 slayt üretim testleri PASS.

## SUT-008 — Son model adayında kalite reddinin atlanması

- **Durum:** DOĞRULAMA (2026-09-22; üretim dağıtımı bekliyor)
- **Kök neden:** Puan 75 altındayken yalnızca son olmayan aday reddediliyordu.
  Çözülmemiş doğruluk/uygunluk sorunları da nihai kontrolden kaçabiliyordu.
- **Çözüm:** Son aday dahil 75 altındaki sonuç reddedilir. Denetçinin çözülmemiş
  ciddi sorun kategorileri yüksek genel puan olsa da kabul edilmez.
- **Kanıt:** 60 puanlı son aday reddediliyor; 95 puanlı ancak çözülmemiş
  `factual_accuracy` sorunu içeren aday da reddediliyor. NVIDIA testleri 10/10 PASS.

### SUT-005–008 birleşik doğrulama

- Sekiz hedef Flutter test dosyasında 54/54 PASS. Ücretli canlı AI çağrısı yok;
  HTTP mock ve yerel Firestore emülatörü kullanıldı.
- Değişen beş Dart dosyasında analiz temiz; `git diff --check` PASS.
- `flutter build web --release --no-pub` PASS (mevcut CupertinoIcons font
  uyarısı dışında derlemeyi engelleyen sorun yok).
- Windows Atlas kayıt komutu bu macOS ortamında yok (`powershell`/`pwsh`
  bulunamadı); oturum kaydı bu günlükte tutuldu.
- Commit ve üretim deploy'u yapılmadı. SUT-001–004'ün önceki doğrulama notları
  korunmuştur; eski kapsam dışı altı test bulgusu bu turda ele alınmadı.
