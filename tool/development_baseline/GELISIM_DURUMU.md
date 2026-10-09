# Sutols gelişim durumu — 8 Ekim 2026

Yerel proje geliştirildi. Konu/metinden düzenlenebilir 2D/3D sunum üretme amacı
korundu. A0–A10 planı bütünü henüz tamamlanmadı. 9 Ekim 2026 tarihinde
`8d06ba0` main dalına push edildi ve Firebase Hosting yayını tamamlandı.
Canlı test bulguları ve açık kabul koşulları `CANLI_TEST_RAPORU_2026-10-09.md`
dosyasındadır; hesapla manuel test kullanıcı girişini bekliyor.

## Uygulanan değişiklikler

- Görünmeyen sahnelerde RAF, CSS, SVG SMIL ve model hareketi durur; etkin sahne
  kaldığı durumdan sürer. Export yalnızca etkin slayta çalışma izni gönderir.
- Editör, önizleme ve export kamera/animasyon klibi-zamanı verisini taşır.
  Dengeli/Tasarruf/Yüksek render tercihi projede saklanır.
- Bulut sunumlarında 1,8 saniye gecikmeli otomatik kayıt, sıralı kayıt kuyruğu,
  hesap ve sunum ID'sine özel yerel kurtarma ve görünür kayıt durumu vardır.
- TR harf/çekim normalizasyonu, içerik değişiminde indeks yenileme, negatif
  ifadeler ve sabit eşitlik sırası eklendi. Manuel arama kısmi adları ve uzun
  kelimedeki tek yazım hatasını destekler; her sorgu terimi sonuçla eşleşmelidir.
- Model paneli yerel katalogla anında açılır. Bulut hatası yerel modelleri
  gizlemez. Gerçek kategori filtreleri, favoriler ve 30 son kullanılan model
  aynı sanallaştırılmış kütüphanede bulunur. Favoriye basmak slayta model eklemez.
- Açık slaydın başlık/metniyle en fazla 6 güçlü model önerilir. “Slayta uygun”
  filtresi eşleşen kelimeleri bilgi simgesinde açıklar; kullanılan modeller
  öneriden çıkarılır. Metin değişince liste yenilenir, slayt sessizce değişmez.
- Yerel model kabul aracı gömülü GLB/Khronos denetimi, dosya/üçgen bütçesi,
  lisans/kaynak/etiket kaydı ve SHA-256 ile karantina oluşturur. Adı belirtilen
  inceleyenin görsel kontrol beyanı sonrası yayımlanmamış onaylı paket üretir.
  Admin panelinde rapor inceleme ve karar dosyası indirme vardır; uzak yayın
  bağlantısı henüz yoktur.
- 11 kategoride 100 özgün şematik model: 200 hafif/kaliteli GLB ve 100 gerçek
  thumbnail. Toplam GLB boyutu 11,161,612 bayt; thumbnail toplamı 16,115,848 bayt.
  Bu yerel aday paket için insan görsel/öğretimsel kabulü henüz alınmadı.
- 18 eksik tema fontu yerel dosya ve aile lisanslarıyla tamamlandı (yaklaşık
  679 KB yeni font). Mobil küçük düzenleme alanı seçili font/ağırlığı korur.
- Sakin/Standart/Etkileyici render presetleri tek undo adımıyla uygulanır.
  Kullanıcının ve işletim sisteminin hareket azaltma tercihi sahnede gözetilir.
- Metin panelindeki “Okunurluğu kontrol et” düğmesi uzun metin, 18px referans
  tabanının altındaki yazı, dar kutu ve sahne dışına taşan kutu için öneri verir.
  Geometri kontrolü 1000px referansa ve Flutter ölçümüne dayanır; HTML font ve
  satır kırılımlarının tam eşdeğerlik garantisi değildir. Metin veya yerleşim
  değiştirilmez, font yüklemesi/resize için her frame kontrol eklenmez.
- Admin panelinde karantina raporunun kaynak, lisans, boyut/üçgen ve uyarıları
  incelenir. Görsel/lisans/uyarı kontrolü ve inceleyen adı sonrası karar dosyası
  indirilir. Yerel araç üç dosya kimliğini bağlar, değiştirilmiş rapor adını
  reddeder ve Khronos denetimini tekrar yapar. Ret kararı ayrı inceleme kaydıdır.
- Kaynak/assets/build hash manifesti, dar feature flag'ler ve manifestten tekrar
  üretilebilen model kontrol sayfası eklendi.

## Doğrulama

| Kontrol | Başlangıç | Son çalıştırma |
|---|---:|---:|
| Başarılı Flutter test | 412 | 565 |
| Başarısız test (failure + error) | 29 | 3 |
| Atlanan test | 2 | 2 |
| Ayrı tutulan üretim servis dosyası | 6 | 6 |
| Flutter analiz hatası | 0 | 0 |
| Mevcut analiz uyarısı / bilgi | 8 / 1 | 8 / 1 |
| Functions TS hatası | 15 | 15 |
| Web release | Başarılı | Başarılı |

Functions başlangıç ve son logları aynıdır: 15 TypeScript tanısı. Önceki
rapordaki 16 sayımı düzeltildi; backend hatası çözülmüş sayılmadı.

Son kontrollü çalıştırma 90 test dosyasıdır. Yeni başarısız test adı yoktur.
Yeni arama, favori, kayıt kuyruğu/kurtarma, kalite ve model entegrasyon testleri
bu çalıştırmaya dahildir. Görsel referanslar yenilenmedi; fark PNG'leri çalışma
raporu için korundu. 6 canlı servis dosyası kota/ağ bağımlılığından ayrı tutuldu;
onlar çalıştırılmış veya başarılı sayılmış değildir.

Khronos denetimi: 100 model / 200 GLB, 0 hata ve 0 uyarı. Bilgi seviyesinde
kullanılmayan UV nesneleri ayrıca raporda tutulur. Gerçek tarayıcıda bütün
varyantların yükleme sonucu **ve gösterilen kaynak dosya yolu** doğrulandı;
100 thumbnail açıldı. Güncel 200 yolun listesi `SUTOLS_100_MODEL_TARAYICI_DOGRULAMASI.json`.

Yerel release ana sayfası gerçek tarayıcıda açıldı; başlangıç konsolunda hata
bulunmadı. Editör giriş koruması nedeniyle oturum gerektirir; tam bulut kayıt ve
export birleşik tarayıcı akışı henüz bu doğrulamanın kapsamında değildir.

Kontrol sahnesi durdurulduğunda sayaç 7'de kaldı, sürdürme sonrası 9'a ilerledi.
Bu GPU güç tüketimi ölçümü değildir; tasarruf yüzdesi iddia edilmiyor. Önceki
geçici kontrol sayfasındaki kaynağı belirlenmemiş MutationObserver hatası
ayrı takip notudur; üretim editörü hatası olarak sınıflandırılmadı.

## Test beklentilerinin güncellenmesi ve kalan görsel farklar

Üretim politikası GPT-OSS proxy rotası kullanırken eski test kendi Super-first
router'ını simüle ediyordu; provider sırası da gerçek akıştan farklıydı.
`ai_routing_test.dart` artık üretim yapılandırmasının rota, timeout, hata sınıfı
ve challenger politikasını doğrudan sınar. Gerçek HTTP aday failover testi
`nvidia_presentation_service_test.dart` içinde MockClient ile korunur; bu test
bulut sağlayıcıların tamamının birleşik E2E testi olarak sunulmaz.

İngilizce prompt etiketi `Presentation subject:` ile test beklentisi eşlendi.
Bölüm metni içeriği korunarak Unicode madde biçimi doğrulandı. 3D modelin
`modelAssetId`'si renderer'ı belirler; eski 2D `kind` kategorisi 3D alanını
kanıtlamaz. Test artık aynı slayta ayrıca 2D bileşen eklenmediğini doğrular.
Bu düzeltmeler için üretim AI veya slayt içeriği davranışı değiştirilmedi.

Kalanlar:

- login page desktop visual
- editor golden at 800x800
- editor golden at 390x844

Mobil editörün eski/şimdiki görüntüleri incelendi: sahne çerçevesi/konumu,
slayt küçük resmi ve toolbar yerleşimi farklı. Bunlar başlangıçtan beri vardı;
referansları toplu yenileyerek sonuç yeşile çevrilmedi. Ahem test fontu gerçek
fontlarla tarayıcı görsel kabulünün yerine geçmez. Karşılaştırmalar çalışma
klasöründe korunur; üç referans için görsel karar hâlâ açık.

Öneri + responsive kontrolü: **87 test başarılı**. Prompt/model/rota kontrolü:
**40 test başarılı**. Yerel model kabulünün 4 Node testi başarılı; görsel
inceleme olmadan onay, değişen metadata, hatalı/büyük dosya ve harici GLB
kaynakları sınandı. Öneri UI ekranı ayrıca gerçek harfler/ikonlarla Flutter
widget renderer'ında üretildi ve incelendi; küçük resim burada harf fallback'idir.
Bu ekran authenticated web editörü veya gerçek GLB yüklemesi iddiası değildir.

![Slayta uygun modeller — yerel widget görsel kontrolü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_SLAYTA_UYGUN_MODELLER.png)

## Tamamlanmayan işler

1. Eksik sutol-model-proxy kaynak deposunu ve gerçek Worker giriş noktasını
   doğrulamak; mevcut Functions/Worker karışıklığını giderip backend derlemek.
2. İnsan etiketli 200 TR/EN sorgu, kilitli değerlendirme ve Precision/Recall kabulü.
3. Android/iOS/ayrı GPU ölçümü; frame süresi, uzun oturum ve context kaybı testleri.
4. Rig/animasyon/saydam/ağır dokulu temsilî model pilotu ve insan görsel onayı.
5. 100 model adayının insan kabulü; admin inceleme kararını uzak yayın endpoint'ine
   bağlamak; pilot paketlerin insan görsel kabulü.
6. Kompozisyonların insan görsel kabulü, tarayıcı okunurluk ölçümüyle ön kontrol
   karşılaştırması ve 5–8 kişiyle görev testi. İlk kullanım rehberi ve düz
   zemin için kontrast uyarısı yerel olarak uygulandı.
7. Gerçek eski sunumla migration/geri dönüş, staging birleşik senaryo ve yayın.
8. Tinos lisans eksikliği kapatıldı: dört WOFF2 içindeki 2026 telif, 1.340
   sürüm ve OFL URL kaydı okundu; aynı telif metnini içeren sabit upstream
   commit lisansı eklendi. Font dosyaları değiştirilmedi.

Benzer model keşfi, ilk kullanım rehberi ve düz arka plan kontrast uyarısı
uygulandı. Sıradaki işler ortak sahne sözleşmesi, temsilî görünüm pilotu ve
kompozisyon profillerinin tamamlanmasıdır. Uzak model yayın endpoint'i eksik proxy
kaynağına bağlıdır. Dış doğrulama adımları
bu kod işlerinden ayrı takip edilir; tamamlandı olarak işaretlenmez.

## Kaynak / geri dönüş

Yeni fontların kaynakları Google Fonts API ve ailelerin kaynak lisans dosyalarıdır:
[Google Fonts kaynak deposu](https://github.com/google/fonts).
Özgün modellerin tarifi ve hak kaydı `tool/models/ORIGINAL_MODELS_LICENSE.md`.
Build kimliği `SUTOLS_YEREL_SURUM_MANIFESTI.json`; başlangıç commit'i
`f673c0411ae752e35da967314cffba756e4177da`. Kaynak yedeği ve başlangıç raporu korunuyor.
Dar feature flag'ler tam release geri dönüşünün yerine geçmez; staging ve
üretim geri dönüşü henüz denenmedi.

![25 özgün model ve gerçek model-viewer kontrolü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_MODEL_TARAYICI_KONTROLU.jpg)

## Son paket: okunurluk ve admin inceleme

11 yeni unit/widget testi ve mevcut 84 responsive test başarılı. Admin ekranı
320px/1200px genişlikte kaydırma, onay kapıları ve hatalı yeni raporda önceki
başvurunun temizlenmesiyle kontrol edildi. Okunurluk düğmesi dialogu açıp
kapatırken metinlerin aynen kaldığı doğrulandı. İlk genel analizde yeni test
fixture'ında bir tip çıkarım uyarısı bulundu; String tipi belirtildi ve analiz
tekrar 0 hata / 8 eski uyarı / 1 eski bilgiye döndü. İlk log ve yeniden kontrol
logu raporda ayrı tutulur.

Node: 7 model kabul/karar testi + 6 sahne testi = 13 başarılı. Python önizleme
aracı hash değişimi ve HTML metadata escaping kontrolünden geçti. Geçici
widget görsel kontrolündeki iki ekran da üretildi ve incelendi. Karantina
önizlemesi gerçek tarayıcıda GLB ve küçük resimle açıldı; dönüş başlat/durdur
ve “Yüklendi” sonucu doğrulandı, konsolda hata bulunmadı. Bu doğrulama admin
hesabı girişi veya dosya seçici/indirme akışının birleşik web E2E testi değildir.
Demo modeli karantinadadır; gerçek onay veya yayın yapılmadı.

Kullanım: Metin paneli → Okunurluğu kontrol et. Admin paneli → Model inceleme →
`receipt.json` aç → önizleme/lisans incelemesi → karar indir.
Yerel akış ve CLI adımları `tool/models/README.md` dosyasındadır.

![Model inceleme — widget görsel kontrolü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_MODEL_INCELEME.png)

![Okunurluk — widget görsel kontrolü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_OKUNURLUK_KONTROLU.png)

![Karantina GLB'si — gerçek tarayıcı kontrolü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_KARANTINA_ONIZLEME.jpg)

### Ek doğrulama: gerçek tarayıcı dosya akışı

Üretim AdminGate'ine dokunmadan ayrı yerel Flutter QA girişinde rapor dosyası
seçildi. Native dosya seçici tek dosya kabul etti; kaynak/lisans/üçgen bilgileri
UI'da açıldı. İnceleyen adı ve test notuyla **ret** kararı indirildi. Browser
connector'ının download event bekleyicisi timeout verdi; dosya Downloads
klasöründe gerçekten bulundu ve içeriği/hash'leri diskten doğrulandı. Bu nedenle
başarı yalnızca UI'nın “indirildi” metnine dayanmaz. İkinci indirmede inceleyen
adı ve notun ekranda korunması da görüldü.

Karar yerel `intake.cjs review` komutuyla uygulandı: ayrı ret inceleme kaydı
oluştu, katalog onayı/yayını yapılmadı. Görsel/lisans işaretleri false kaldı;
onay düğmesi kapalıydı. Sonuç JSON'u `SUTOLS_ADMIN_DOSYA_AKISI_DOGRULAMASI.json`.
Gerçek yetkili hesap + uzak sunucu yayın E2E senaryosu bunun kapsamı değildir.
Yerel gerçek uygulama release'i `web-final-5` ile tekrar derlendi; indirme
anchor'ı DOM'a ekleniyor ve Blob URL'si tarayıcıya süre tanıyarak temizleniyor.
Son 11 odaklı test tekrar başarılı; kaynak/build hash'i eşleşiyor.

![Gerçek tarayıcıdaki rapor ve karar akışı](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_MODEL_INCELEME_TARAYICI.jpg)

Güncel gerçek uygulama girişinin yerel `web-final-5` derlemesi 8801 portunda
ayrıca açıldı: fikirden sunum oluşturma ana ekranı ve başlık/konu/sayfa/Oluştur
kontrolleri mevcut; başlangıç konsolunda hata yok. Yerel QA girişinin üretim
bundle'ına karışmadığı görünür ana ekranla kontrol edildi. Güncel ana sayfa
kanıtı `SUTOLS_YEREL_ACILIS.jpg` dosyasıdır. Üretim sunum isteği gönderilmedi.

## Son paket: keşif, rehber, poster ve 50 model

- Model kartındaki “Benzerlerini göster” eylemi en az iki anlamlı ortak etiket
  gerektirir. Genel “şema/model” sözcükleri sayılmaz; kategori tek başına kanıt
  değildir. İki yöndeki negatif etiketler korunur. Bu eylem slaytı değiştirmez.
- Sutols menüsü ve mobil diğer işlemler içindeki beş adımlı Hızlı başlangıç
  rehberi isteğe bağlı açılır; kullanıcıyı zorunlu forma yönlendirmez.
- Düz beyaz/siyah zemindeki açıkça seçilmiş opak yazı renkleri için 4,5:1
  altındaki kontrast uyarılır. Hareketli arka planın pikselleri ölçülmedi; bu
  kontrol erişilebilirlik sertifikası değildir.
- Küçük slaytlarda canlı GLB yerine gerçek yerel poster veya kimlikli fallback
  kullanılır. HTML snapshot da ilgisiz eski 2D bileşen yerine model posterini
  gösterir ve model-viewer modülünü yüklemez.
- Kısa masaüstü ekranında modeller panelinin sınırsız yüksekliği giderildi.
  Gerçek tarayıcıdaki yerel editör QA sahnesinde benzer model akışı çalıştı ve
  canlı model-viewer sayısı ikiden bire indi. Üretim kimlik doğrulama kapısı
  korunuyor; QA giriş dosyası üretim lib/main.dart içine eklenmedi.
- Model URL yenilemesinde model/generation/kaynak kimliği kontrol edilir; eski
  yanıt yeni model seçimini ezemez. Yeni sig imzalı thumbnail adresleri de
  ortak süre/geçerlilik politikasıyla kabul edilir.
- model-viewer'ın kendi render scaler'ına Tasarruf 0,4; Dengeli 0,5; Yüksek
  0,79 alt sınırı verilir. Paylaşılan renderer etkin tüketicilerin en yüksek
  kalite ihtiyacını kullanır. İkinci RAF eklenmedi. Gerçek GPU güç ve cihaz
  karşılaştırması henüz yoktur. Dayanak:
  [model-viewer 4.3.1 renderer kaynağı](https://github.com/google/model-viewer/blob/v4.3.1/packages/model-viewer/src/three-components/Renderer.ts).
- 51 arka plan kaynağının statik envanteri çıkarıldı. Head etiketi olmayan
  fizik sahnesinde lifecycle betiğinin eklenmemesi düzeltildi. Envanter runtime
  üçüncü parti betiklerin veya GPU maliyetinin ölçümü değildir.

Genel Flutter kontrolü: **485 başarılı, 3 açık görsel fark, 2 atlanan**. Node:
**18 başarılı** (9 render/lifecycle + 7 model kabul + 2 model olay testi). 50 modelin 100 varyantı
Khronos'ta 0 hata/0 uyarı verdi; bütün varyantların gösterilen kaynak yolları
ve 50 thumbnail gerçek tarayıcıda doğrulandı. Önizleme kontrol sayfasında
kaynağı belirlenmemiş bir MutationObserver TypeError ayrıca kaydedildi; GLB
yüklemeleri başarılı olsa da bu hata çözülmüş sayılmaz.

![50 model — gerçek tarayıcı kontrolü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_50_MODEL_KONTROLU.jpg)

![İsteğe bağlı hızlı başlangıç](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_HIZLI_BASLANGIC.jpg)

![Benzer model akışı — yerel QA editörü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_BENZER_MODELLER.jpg)

### Yükleme olayları ve font lisansı ek kontrolü

HTML model hata handler'ındaki eksik ternary dalı düzeltildi; gerçek üretilen
handler JavaScript VM'de çalıştırılıp fallback görünürlüğü doğrulandı. Eski URL
için gelen load olayı kamerayı/animasyon zamanını uygulamaz; eşleşen olay uygular.
Doğrudan editör model renderer'ına da kaynak karşılaştırması eklendi. GPU context
kaybı artık token yenileme isteği sayılmaz; tam context kurtarma hâlâ açık.

Son değişiklik için export/model kaynak kontrolünde **20 odaklı Flutter testi**
ve **18 Node testi** başarılı; analiz 0 hata / 8 eski uyarı / 1 eski bilgi.
Genel 485 test çalıştırması bu iki son handler düzenlemesinden önceydi; odaklı
son kontrol genel çalıştırmanın yerine genişletilmiş başarı sayısı üretmez.

Tinos fontlarının metadata'sı resmi kaynağın telif bildirimiyle eşleşti;
[sabit sürüm OFL kaydı](https://github.com/googlefonts/tinos/blob/5df023370055d3fe8f05aa288fe0ba9a6928068a/OFL.txt)
ve dört değişmemiş binary SHA-256 değeri
`SUTOLS_TINOS_LISANS_DOGRULAMASI.json` dosyasındadır.


## Son paket: ortak sahne, bileşen hareketi ve baskı

- Sürümlü `PresentationSceneState` kalıcı page/block/model kimliğini yerel varlık
  SHA-256 kaydıyla ayırır. Ortak normalizasyon codec, HTML sahne/export, iframe
  patch ve doğrudan model renderer'ında kullanılır. Sonlu olmayan kamera/zaman
  değerleri güvenli varsayılan alır; geçerli açılar ve klip korunur. İmzalı URL,
  yükleme yüzdesi ve DOM handle'ı bu sözleşmeye eklenmez. Proje JSON'una geriye
  uyumlu `sceneStateVersion: 1` eklenir; işaret taşımayan eski veri açılır.
- Animasyon klibi `copyWith` üzerinden açıkça temizlenebilir. Kamera ve metin
  değiştirirken verilmemiş klip alanı korunur. 71 odaklı test bu paketi doğruladı.
- Galton bileşenindeki bağımsız interval/timeout kaldırıldı; üretim hızı sahne
  RAF zamanıyla yönetilir, tek gecikmiş karede birikmiş top üretimi yapılmaz.
  Top animasyonu bitince temizlenir. Hareket azaltmada dağılım statik gösterilir.
- Yıldız alanı hareket azaltmada ilk çizim/resize dışında sürekli çizmez.
  Beyaz sabit zeminde yıldız mürekkebi koyulaşır; şeffaf önizleme koyu zemin
  varsayımını korur. Bu bütün katalog için kontrast garantisi değildir.
- Gerçek tarayıcı kontrolü önce kök seçicisinin null kaldığı bir yıldız alanı
  hatası buldu. Seçiciler en yakın sahne/önizleme kapsayıcısına bağlandı; gerçek
  ancestor araması korunur. İki aynı bileşen bağımsız 640×576 tuval oluşturdu,
  konsolda null-root hatası kalmadı. Kaynağı atfedilemeyen ilk MutationObserver
  hatası ayrıca rapora yazıldı ve çözülmüş sayılmadı.
- Görünür Galton/yıldız sahneleri duraklatıldığında sayaçlar 438/436'da sabit
  kaldı; sürdürülünce 1557/1555'e ilerledi. Azaltılmış sahneler 1/3 callback ve
  sıfır bekleyen RAF'ta kaldı. Bu sayaçlar GPU güç tüketimi ölçümü değildir.
- Hareket azaltılmış HTML sunumu 3D etkileşimi korur; kamera kontrolleri kaldırılmaz.
  Baskı modeli canlı GLB yerine kimlikli posterle gösterir. Yerel poster baytları
  baskı blob'una gömülür; PDF yolu gereksiz GLB indirmez. Poster erişilemezse model
  kimliği görünür. Poster kamera pozu varsayılandır; kaydedilmiş kamera açısının
  birebir statik görüntüsü ve tam offline HTML sunumu hâlâ ayrı kabul maddesidir.
- Kısa masaüstünde kütüphane yüksekliği ekranla ölçeklenir (300–420px); sahneye
  daha fazla yer kalır. Bu son düzenleme 88 responsive testle doğrulandı.
- 250 TR/EN sorguluk **insan inceleme taslağı**, grup bazında sabit eğitim/test
  ayrımı ve write-once kilitleme aracı hazırlandı. CSV inceleyen kişi tarafından
  düzeltilip onaylanmadan gerçek benchmark sayılmaz. Dört Python kapı testi ve
  sentetik etiketli araç smoke testi geçti; kalite skoru olarak sunulmaz.
- Firestore yerel demo emülatöründe 30 slaytlık atomik kayıt, rollback, sahiplik,
  kota ve receipt testi geçti. Üretim veritabanına istek gönderilmedi.

Güncel genel kontrol: **491 başarılı / 3 açık golden farkı / 2 atlanan**,
analiz **0 hata / 8 uyarı / 1 bilgi**, Functions **15 açık TS tanısı**.
Yeni hareket/handler/scaler/kabul Node kontrolleri **22/22** geçti. Geniş Node
arama denemesinde iki ortam engeli çıktı: Firestore testi emülatörde ayrıca
geçti; eksik proxy kaynak dosyasını isteyen test hâlâ çalıştırılamıyor.
Bu sonuçlar A0–A10'un tamamlandığı veya yayına hazır olduğu anlamına gelmez.

![Gerçek bileşen hareket kontrolü](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_BILESEN_HAREKET_KONTROLU.jpg)


### Gelişmiş model pilotu ve 1280px stüdyo düzeni

Rigli türbin ve saydam/dokulu laboratuvar örneği ayrı, yayımlanmamış paket
olarak üretildi. Dört lite/quality GLB, iki thumbnail, özellik/hash manifesti,
tekrar üretim ve doğrulama araçları vardır. Rig bir skin ve RotorSpin klibi;
laboratuvar bir alpha-blend malzeme ve 1024/2048px özgün doku içerir.
Khronos **4 dosya / 0 hata / 0 uyarı**. Tarayıcıda dört kaynak yolu/yükleme ve
animasyon duraklama zamanı doğrulandı; konsolda hata yoktu. İlk skinned-mesh
parent uyarısı mesh'in sahne kökü olmasıyla giderildi. Her iki kalite modeli
intake karantinasında **awaiting-review**, sıfır blocker/uyarı ile bekliyor.
Onaylanmış veya ana katalogya eklenmiş değildir. Organik rig/human inceleme ve
cihaz/GPU matrisi açık kalır. Önizleme iki canlı viewer içeren QA sayfasıdır;
uygulamanın render bütçesi verimliliği bu sayfada ölçülmez.

1280×720 ekran stüdyo düzenine alınarak model kütüphanesi yana taşındı.
Geniş kontrolün 87 diğer testi geçti; eski kısa-ekran testinin panel-yüksekliği
beklentisi yeni yan düzen için değişti. Yeni test sahnenin 400px genişlik ve
220px yükseklik üzerinde kaldığını doğruladı (1/1). Bu son breakpoint sonrası
bütün genel testler yeniden çalıştırılmış gibi sayı artırılmadı.
Güncel `web-final-11` gerçek ana giriş bundle'ı yerel doğrulama için derlendi;
manifest bu kaynak durumuna aittir. Staging veya production yayını yoktur.

![Rig/animasyon ve saydamlık/doku — gerçek tarayıcı](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_GELISMIS_MODEL_PILOTU.jpg)


## Güncel paket — 100 model, statik geometri ve kompozisyon

100 özgün model, 11 kategori ve 200 LOD dosyası için kimlik/hash/boyut,
üçgen metadata'sı ve 8 MiB / 50.000 üçgen sınırı tekrar doğrulandı:
**0 glTF hata / 0 uyarı**. Yeni 50 modelde huni açık ağızla, cıvata altıgen
başla üretildi; tekrarlı uzay istasyonu kirişi ve kullanılmayan kristal
noktaları kaldırıldı. Eğri borular kesik silindirler yerine sürekli mesh
üretir. Küçük breadboard işaretleri 17.508/46.452 yerine 516/852 üçgendir.
Bunlar şematik eğitim modelleridir, fiziksel simülasyon değildir.

İlk 50 statik modelde parçalar malzemeye göre tek mesh içinde birleştirildi.
100 eski/yeni LOD karşılaştırmasında dünya koordinatındaki köşe noktaları,
üçgen sayıları ve malzeme tanımları değişmedi; primitive instance toplamı
**706 → 236**. Rig/animasyonlu varlıklar bu statik birleştirmeye alınmadı.
Bu sonuç ölçülmüş GPU draw-call, güç veya FPS kazancı değildir.
`SUTOLS_STATIK_MODEL_OPTIMIZASYONU.json` ayrıntıları korur.

Şablon paneline seçili slayt için **Tek odak, Karşılaştırma, Açıklamalı model,
Süreç ve Veri odağı** düzenleri eklendi. Bir başlık/en fazla dört açıklama
sınırı ve düzene göre model sayısı vardır. Desteklenmeyen düzen içerikleri
kesmez; düğmesi kapalıdır. Metin, font, açıklamalar, blok kimliği, kamera,
klip/zaman ve diğer sayfalar korunur. Düzen tek undo adımıdır; otomatik font
küçültme, metin silme veya okunurluk garantisi vermez. Kullanıcı okunurluk
kontrolünü ayrıca çalıştırır. TR/EN yeni düğme metinleri vardır.

1280px stüdyoda yerel taslak artık yanlış biçimde “Kaydedildi” göstermez.
Gerçek değişiklik bekleyen kayıt olarak belirtilir; eski tamamlanan bulut
isteği yeni değişiklikleri kaydedilmiş saymaz.

Genel baseline **503 başarılı / 3 golden farkı / 2 atlama**, 74 dosyadır.
Analiz 0 hata / 8 uyarı / 1 bilgi; Functions'ın 15 TS tanısı açık kalır.
Arama/kütüphane/kompozisyon/responsive paketi **111 test** geçti; son geometri
ve grid değişikliği için ek **9 sözleşme testi** geçti. Bunlar genel baseline
sayısına toplanmaz. Yeni kütüphanede çoğalan sonuçlar nedeniyle widget testleri
favori/benzer düğmesini hedef model kartına bağlar. Node kontrolleri **22/22**.

İnceleme taslağı artık **450 TR/EN sorgu** içerir. İnsan etiketli olmadığı için
kalite/Precision/Recall kabulü sayılmaz. Önceki 250 sorguluk taslak korunur.
web-final-13 yerel release kaynak SHA-256 kontrolüyle oluşturuldu. Daha sonraki
kaynak değişiklikleri için yeni derleme gereklidir. A0–A10 bütünü ve yayın kapıları açık kalır.

![Yeni 50 özgün model — gerçek Blender renderları](/Users/emodvc/Documents/Codex/2026-10-08/su/outputs/SUTOLS_YENI_50_MODEL_KONTROLU.jpg)

## Kamera açısı ve İngilizce nesne adları

Model-viewer varsayılan FOV sınırı, 45° kaydedilmiş görünümü dar bir editör
kutusunda 30° olarak uyguluyordu. Native sahne ve HTML/export aynı açık
1°–179° sınırını kullanır. Tarayıcı ölçümü aynı orbit/hedef/radius ile
30° → 45° sonucunu doğruladı; kamera verisi değiştirilmedi.
`SUTOLS_KAMERA_FOV_DOGRULAMASI.json` ölçümleri korur.

100 özgün modelin `labelEn` nesne adı katalog üretiminde korunur ve manuel
indekse katılır. Önceden eksik 10 İngilizce ad tamamlandı. Her 100 TR tam ad
ve 100 EN nesne adı için arama testi geçti; bu insan etiketli semantik
kalite ölçümü değildir. Güncel 450 sorguluk insan inceleme dosyası
`SUTOLS_450_ARAMA_INCELEME_V2.csv`; henüz inceleyen etiketi yoktur.

## Özellik filtreleri ve export önbelleği

Kütüphanedeki özellik menüsü küçük dosya (≤ 1 MB), animasyon ve sanal tur
kayıtlarına göre filtreler. Kategori/arama/favori/benzer/slayta uygun sonuçlarla
birlikte çalışır. Bilinmeyen metadata özellik kanıtı sayılmaz; boyut sıfır
olan uzak modeller küçük dosya filtresine girmez. Dosya boyutu GPU/FPS ölçümü
olarak sunulmaz. Etkin filtre tooltip’te belirtilir; boş sonuçta kaldırma
rehberi vardır. Search korunarak filtre temizlenmesi widget testiyle doğrulandı.

HTML dışa aktarma sadece sürüm hash’i bilinen yerel modelleri önbelleğe alır.
Anahtar kaynak yolu + varlık SHA-256’dır; en çok 16 kayıt ve 16 MiB base64
karakter bütçesiyle LRU tahliyesi yapılır. Bu toplam export belge belleği veya
GPU bellek sınırı değildir. Yetkili uzak model dosyaları hesaplar arası
süreç önbelleğinde tutulmaz; indirmelerde 30 saniye timeout vardır.

Son özellik/önbellek/responsive paketi **95 başarılı test**; export sözleşme
paketi **8 başarılı / 1 atlama**. Genel baseline 510 başarılı / 3 değişmeyen golden farkı / 2 atlamadır; odak
test sonuçları bu toplama eklenmez. Sunum geçişindeki boş ekranın nedeni
yeni iframe’in henüz oluşmayan contentWindow alanına erişilmesiydi. Etkinlik
mesajı güvenli gönderilir, iframe bağlandığında son durum yeniden uygulanır.
Gerçek web QA’da metin/model görünür; Escape ile editöre dönüş korunur.
Ayrı yerel smoke girişinde suspend/resume sonrası Flutter çalışma zamanı
hatası yoktur. Yetkili bulut kayıt/export birleşik akışı hâlâ doğrulanmadı.

## Son düzeltmeler

Sunum geçişi/responsive için 99; export kaynakları ve payload log temizliği
için 48; son okunurluk/kompozisyon/preview için 17 odak testi başarılıdır.
Model payload’ı artık konsola yazılmaz. HTML ve proje indirmesinde Blob URL
bir saniye sonra serbest bırakılır; gerçek HTML dosyasının teslimi tarayıcı
araç olayıyla henüz doğrulanamadı.

Düz zemin kontrast kontrolü metinle çakışmayan sabit bileşenlerin yanında
da çalışır. Hareketli, döndürülmüş, büyüyebilen veya sınırı belirsiz kutularda
bileşen rengi varsayılmaz. İçerik ve yerleşim otomatik değiştirilmez.

## Arka plan keşfi — son yerel değişiklik

Arka plan araması TR harf/büyük harf normalizasyonu ve katalog kimliğindeki
İngilizce kavramları kullanır. Birden çok sorgu kelimesinin tümü eşleşir;
arama tüm slaytı değiştirmez. Açık/koyu/tüm tonlar filtreleri aramayla birlikte
çalışır; boş sonuçta filtreyi kaldırma rehberi vardır. Ton bilgisi katalogdaki
özgün varyantı anlatır, GPU maliyeti veya hareket yoğunluğu değildir.

93 arama/responsive testi geçti. Üç dosyalık analizde 0 hata, mevcut editörün
5 uyarısı/1 bilgisi var. Genel baseline hâlâ 510/3/2 olarak ayrı tutulur; yeni
odak sonuçları bu toplama eklenmez. A8.1’in hareket ve cihaz maliyeti ölçümü
tamamlanmış sayılmaz.

Son web release `web-final-18` kaynak/assets SHA-256 kimliğiyle doğrulandı;
yerel adaydır. Arka plan araması/tone filtresi gerçek web QA’da kontrol edildi,
seçili slayt korunur. Bu sonuç bulut yetki veya üretim birleşik akış kabulü değildir.

## Model aydınlatmasının ortak durumu

Her model örneğinde isteğe bağlı `modelExposure` saklanır. Null katalog
aydınlatmasını korur; menüde katalog/daha yumuşak/daha aydınlık seçenekleri
vardır. Bu pozlama ayarıdır, yeni HDR ortam veya fiziksel ışık sistemi değildir.
Ortak sahne normalizasyonu geçersiz değeri katalog varsayılanına döndürür,
açık sayısal değeri 0.1–3 sınırında tutar. Eski JSON varsayılanı değişmez.

Codec, HTML/export markup, iframe canlı patch ve doğrudan model canvas aynı
değeri kullanır. Editör değişiklik kimliği bu alanı içerir. Ayar tek undo
adımıdır; kamera, animasyon zamanı, içerik ve başka model örneği korunur.
108 sahne/codec/responsive testi ve ayrı menü widget testi geçti. Tam analiz
0 hata / 8 mevcut uyarı / 1 bilgi; ilgili Node alt kümesi 15/15.
Gerçek QA20 web kontrolünde pozlama editör → sunum → editöre dönüşte
1.2000 olarak korundu. web-final-20 kaynak/build SHA-256 kontrolü geçti.
A2.1’in tam HDR/ışık profili ve cihaz/insan kabulü açık kalır.

## Güncel kapsamlı doğrulama

Baseline-24: 90 dosyada **565 başarılı / 3 değişmeyen golden farkı / 2 atlama**.
Arka plan keşfi, kontrast geometrisi ve model pozlama değişiklikleri bu genel
çalıştırmaya dahildir. Flutter analiz 0 hata / 8 mevcut uyarı / 1 bilgi;
Functions 15 eski TypeScript hatası açıktır. Golden beklentileri yenilenmedi,
yeni fark görselleri çalışma klasöründe korundu. Yerel frontend release-21
doğrulandı; staging, gerçek cihaz/insan ve yetkili birleşik senaryo açık kalır.

## Sürükleme ve geri alma gruplaması

Tuval pointer-down/up/cancel olayları controller'da takip edilir. Fare/dokunma
basılıyken kısa bekleme sürüklemeyi başka undo grubuna bölmez. İlk gerçek
hareket tek başlangıç snapshot'ı alır; sırf tıklamak undo eklemez. Birden çok
pointer son bırakılana kadar aynı grupta kalır. İptal, sayfa değişimi, geri alma
ve tuval/controller değişiminde grup temizlenir. Klavye nudge için önceki
180ms burst gruplaması korunur. Her hareket bütün belge snapshot'ı oluşturmaz.

120 controller/responsive testi ve ayrı gerçek pointer widget testi geçti.
Widget testinde fare basılıyken 600ms bekleyip devam edilen sürükleme tek undo
adımıdır. Bu A9.4'ün jest geçmişi alt adımıdır; büyük belge frame/cihaz
performans ölçümü ve tam kullanıcı kabulü ayrıca açıktır. web-final-21 kaynak/build kimliği doğrulandı. Baseline-15: 523 başarılı,
3 mevcut golden farkı, 2 atlama. Varsayılan eşzamanlılıkta yaşanan üç yükleme
zaman aşımı ayrı çalıştırmada (17 test) ve concurrency=2 genel çalıştırmada
tekrarlanmadı. Gerçek normal web modunda model 50px/40px taşındı; tek undo
başlangıç konumunu geri getirdi. Erişilebilirlik açık tarayıcı araç denemesi
konumu değiştirmedi; bu deneme erişilebilirlik kabulü sayılmıyor.

## Seçili metin için okunurluk yüzeyi

A8.3 yerel alt adımı: metin kutusuna isteğe bağlı açık/koyu düz yüzey
eklenir. Varsayılan yüzey yoktur; eski projeler değişmez. İçerik, konum,
font ve metin rengi korunur. Kullanıcı uygun rengi seçer; ön kontrol açık
yüzeyde beyaz gibi düşük kontrastlı açık renkleri uyarır. Blur/backdrop
filtresi veya yeni sürekli animasyon eklenmez. HTML, canlı iframe patch,
Flutter tuvali ve dışa aktarma ortak alanı kullanır. Seçim tek undo'dur;
aynı seçimi yeniden yapmak geçmişe eklenmez. Undo menü değerini de yeniler.

105 odak Flutter testi ve 15 Node yaşam döngüsü testi geçti. Analiz 0 hata,
8 mevcut uyarı, 1 bilgi. web-final-22 kaynak/build SHA-256 eşleşmesi doğrulandı. Gerçek QA22
tarayıcı kontrolünde koyu yüzey editör → sunum → dönüşte korundu; tek undo
yüzeyi kaldırdı, redo geri getirdi. Yakalanan tarayıcı hata/uyarı kaydı yok.
Baseline-16: 81 dosyada 527 başarılı test, 3 değişmeyen golden farkı,
2 atlama. Analiz 0 hata / 8 mevcut uyarı / 1 bilgi; Functions 15 eski
TypeScript hatası. Golden beklentileri değiştirilmedi; farklar work içinde
korundu. Tüm aşamalar veya üretim yayını tamamlanmış sayılmaz.
Tam A8, cihaz ve insan okunurluk kabulü hâlâ açık.

## Model önerisinde “Uygun değil” geri bildirimi

A5.7 alt adımı: yalnızca Slayta uygun koleksiyonunda öneri kartına
“Bu slayt için uygun değil” eylemi eklendi. Reddetme model/katalog etiketi
veya sunum içeriğini değiştirmez; yalnızca aynı kullanıcının, aynı slaytın
mevcut metniyle üretilen önerisinde gizler. Metin değişince yeni bağlamda
tekrar değerlendirilebilir. Genel kütüphane ve otomatik seçim etkilenmez.

Geri bildirim yalnızca controller oturumu boyunca tutulur; panel değişince
korunur, başka belge açılınca temizlenir. 32 bağlam / bağlam başına 200
model ile sınırlıdır. Öneri indeksinin aynı 20 metin/1000 karakter sınırı
kullanılır; ham metin dış servise, dosyaya veya loga yazılmaz. SnackBar
Geri al eylemi ve Gizlenen önerileri göster düğmesi kararı geri çevirir.
Katalog öğrenmesi veya insan etiketli değerlendirme tamamlandı sayılmaz.

104 odak test geçti: scope/kullanıcı/metin ayrımı, bellek sınırı, güvenli
adayların boş yeri doldurması, sunum JSON'unun değişmemesi, geri alma ve
öneri reseti. web-final-23 kaynak/build kimliği doğrulandı. QA23 tarayıcıda Bohr atom
önerisi 1 → gizleme 0 → geri getirme 1 olarak kontrol edildi; slayt
içeriği ve model korundu, tarayıcı hata/uyarı kaydı yok. Baseline-17:
82 dosyada 531 başarılı, 3 mevcut golden farkı, 2 atlama. Analiz 0 hata /
8 mevcut uyarı / 1 bilgi. Functions 15 eski TypeScript hatası hâlâ açık.
Gizlenen bütün önerilerde boş sonuç açıklaması sonraki adımda netleştirilecek.

## Gecikmiş model seçimi yanıtı

A2.5 yerel alt adımı: model kartı seçim isteği için son işlem kimliği ve
controller/sayfa nesnesi, seçili öğeler, hesap kapsamı tutulur. Yetkilendirme
sonucu, aynı kapsam ve hâlâ son istek ise kaynak kaydı/model ekleme yapar.
Daha yeni seçim, seçim/sayfa/belge değişimi, hesap değişimi, panel/controller
değişimi veya dispose eski isteği geçersiz kılar. Sayfadan ayrılıp geri dönmek
eski yanıtı yeniden geçerli yapmaz. Eski başarısız yanıtın hata mesajı da
yeni seçimin üzerinde gösterilmez. Yetki denetimi ve varlık kimlikleri korunur.

98 odak test geçti: ters sırada çözülen authorization benzeri Future'larda
yalnızca yenisi uygulanır; kapsam değişimi ve dönüş eski isteği reddeder;
responsive editör ve öneri akışları korunur. Bunlar kontrollü yerel testlerdir;
yavaş yetkili R2 ağında gerçek staging birleşik akışı hâlâ doğrulanmadı.
Analiz 0 hata / 8 mevcut uyarı / 1 bilgi. web-final-24 kaynak/build hash doğrulandı. Baseline-18: 83 dosyada
534 başarılı / 3 mevcut golden farkı / 2 atlama. QA24 tarayıcıda gizlenen
öneri açıklaması ve geri getirme doğrulandı; hata/uyarı kaydı yok.

Tüm öneriler kullanıcıca gizlendiğinde boş sonuç artık filtreler/gizlenen
öneriler bağlamını açıklar; eşleşme olmadığına dair yanlış iddia kurmaz.

## HTML export asset completeness

A9.6/A10 local step: before offering the HTML download, check embedded files
for every unique 3D model across all slides. Missing or empty files abort
the download request and show a retry message; edits remain unchanged.
Image blocks and legacy image IDs are excluded from model requirements.
Expired model URLs retain their source key for authorization renewal.
Repeated clicks cannot start overlapping HTML exports.

The success message reports that a download request was sent to the browser;
actual file delivery remains unverified. Fully offline model-viewer, fonts,
images and saved-pose PDF poster acceptance remain open.

107 focused tests passed: missing files, deduplication, image separation,
content preservation and unsupported-platform error UI. Analysis: zero
errors / 8 existing warnings / 1 info. web-final-25 source/build identity verified. Browser QA25 first loaded the
model, then a local no-store server returned 503 to the export request. The
missing-model message appeared, and the slide remained usable. Removing the
local failure marker allowed retry and a download-request message. Actual
downloaded-file delivery is still unverified. Baseline-19: 84 test files, 537 successes / 3 existing golden differences /
2 skips. Analysis zero errors / 8 existing warnings / 1 info. Functions 15
existing TypeScript errors remain. Golden expectations were not changed.

## PDF sekmesini hazırlama ve hata kurtarma — 9 Ekim 2026

A9.6/A10 yerel adım: PDF sekmesi, görselleri hazırlamak için ilk beklemeden
önce kullanıcı tıklaması sırasında ayrılır. Tarayıcı engellerse görsel indirmeleri
başlamaz ve editör açıklama gösterir. Hazırlama başarısızsa ayrılan sekme
kapatılır; kullanıcı hazırlama sırasında sekmeyi kapatırsa yeniden açılmaz.
PDF işlemleri üst üste başlamaz; başarısız işlemden sonra yeniden deneme açıktır.
Sunum içeriği ve proje şeması korunur. Sekme hazırlandı bildirimi, PDF dosyasının
kaydedildiğini iddia etmez.

108 odaklı test başarılı: geciken hazırlamadan önce sekme ayırma, engellenen
sekme, hata sonrası temizleme/yeniden deneme, kullanıcıca kapatılan sekme ve
desteklenmeyen platformda düzenlemelerin korunması. Analiz: 0 hata, 8 mevcut
uyarı, 1 bilgi. Web derlemesi ve gerçek tarayıcı doğrulaması devam ediyor.
Kaynak: https://developer.mozilla.org/en-US/docs/Web/API/Window/open

GPU context kaybında poster/kurtarma, gerçek cihaz ölçümü, insan değerlendirmesi
ve eksik üretim Worker kaynağı hâlâ açık kabul maddeleridir.

## Mobil menüler ve görünür kamera düzeltmesi — 9 Ekim 2026

A3/A9 yerel adım: mobil üst çubuktaki dışa aktarma ve diğer işlemler
menülerinin iç simge düğmeleri tıklamayı yakalıyordu. Görünüm korunarak
tıklama dıştaki menüye geçirildi. 390px ve 623px kontrolünde menü açma,
PDF hata mesajı ve proje kaydet/yükle seçenekleri test edildi.

Kamera düzeltme zamanlayıcıları artık görünür sahneye bağlıdır. Gizlenince
bekleyen denemeler iptal edilir; görünür olunca 1,2 saniyede en fazla altı
düzeltme çalışır. Tekrarlanan boyut değişimleri denemeleri çoğaltmaz.
Dispose sonrası yeniden başlatma engellenir. Gizli sahnede geometri/kamera
sıçrama çağrıları da ertelenir. Kamera ve proje verisi şeması değiştirilmedi.
Bu bir GPU enerji kazancı ölçümü değildir.

PDF/menü odaklı 110 test, kamera/sahne odaklı 9 test ve Node yaşam döngüsü
paketinde 6 test geçti. Yeni web derlemesi, genel regresyon ve tarayıcı
kamera/menü kabulü devam ediyor. Context kaybı kurtarması henüz kapanmadı.

web-final-27 kaynak/build kimliği doğrulandı. Baseline-20: 86 dosyada
548 başarılı, 3 mevcut golden farkı, 2 atlama; analiz 0 hata / 8 mevcut
uyarı / 1 bilgi. Functions 15 mevcut TypeScript hatası korunuyor.
Tarayıcıda 390px dışa aktarma menüsü açıldı, PDF sekmesi oluştu ve hazırlama
bildirimi görüldü. Blob sekmesi incelemesi HTTP/HTTPS güvenlik politikasıyla
engellendi; PDF görünümü/kaydı doğrulanmadı. Yazdırma başladıktan sonraki
diğer menü ve preview dönüş tarayıcı denemeleri sonuçlanmadı; yalnızca
390/623px widget menü kontrolleri başarılı kabul ediliyor.

## Uzun oturum sahne önbelleği — 9 Ekim 2026

Geometri önbelleği daha önce model kimliği sayısıyla sınırsız büyüyordu.
Artık en fazla 256 geometri ve 256 kamera pozu tutulur; en son kullanılan
kayıtlar korunur. Kamera önbelleğinin önceki 256 kayıt sınırı korunarak
FIFO yerine kullanım sırasına göre çıkarma yapılır. Etkin sahne kayıtları
kendi dispose akışında temizlenmeye devam eder. Çıkarılan geometri modelden
yeniden okunabilir; kaydedilmiş kamera/proje verisi silinmez. Bu önbellek
GLB/GPU dokusu içermez, dolayısıyla GPU belleği ya da watt tasarrufu iddiası yoktur.

10.000 benzersiz kayıtla sınır, sık kullanılan kaydın korunması, güncelleme,
eksik anahtar ve geçersiz kapasite test edildi. Önbellek/kamera/sahne odaklı
14 test başarılı. web-final-28 ve genel regresyon kontrolü devam ediyor.

Mobil menü simgeleri artık dekoratif: tıklama, odak ve erişilebilir eylem
dıştaki PopupMenuButton tarafından tek noktadan yönetilir. Menü içindeki
boş IconButton kaldırıldı. Gerçek Tab/Enter/Escape olaylarıyla odak turu
testi her menüde yalnızca bir çalışan klavye durağı buldu; menü seçenekleri
açıldı ve Escape ile kapandı. Genel baseline-21 ve web-final-29 kontrolü
sürüyor; GPU/context ve üretim kabul maddeleri açık kalıyor.

Baseline-21 tamamlandı: 87 dosyada 554 başarılı / 3 mevcut golden farkı /
2 atlama. Analiz 0 hata / 8 mevcut uyarı / 1 bilgi; Functions 15 mevcut
TypeScript hatası. Golden beklentileri değiştirilmedi. Kaynak-29 yerel
release derlemesi sürüyor. Kaydedilmiş Codex projeleri listesinde proxy
yok; GitHub depo aramasında sutol-model-proxy için eşleşme bulunmadı.

web-final-29 release tamamlandı; kaynak/build hash eşleşmesi doğrulandı.

## Model değişiminde kamera kimliği — 9 Ekim 2026

A2.5 yerel adım: kamera snapshot kaydı slayt/öğe kimliğiyle birlikte model
kimliğini de denetler. Renderer yeni src değerini aldığında önceki GLB hâlâ
yüklü olabilir. Kabul edilmiş load kaynağı ile mevcut src eşleşmeden canlı
kamera okunmaz. Farklı modelin önbellek pozu yeni modele verilmez; aynı
modelin URL yenilemesinde yalnızca önceki geçerli pozu kullanılabilir. Yeni
model yüklendiğinde snapshot yeni model kimliğiyle yerini alır. Geçici kaynak
URL'si renderer oturumunda kalır; proje dosyasına yeni alan eklenmez.

112 odaklı test başarılı: farklı model / geciken kaynak / URL yenilemesi /
yeni yükleme / sınırlandırma ve mevcut editör kamera kayıt akışları. Testler
kontrollü kaynak durumları içindir; gerçek yavaş ağ ile model değiştirme
birleşik tarayıcı kabulü henüz doğrulanmadı. web-final-30 ve genel testler sürüyor.

web-final-30 kaynak/build kimliği doğrulandı. Baseline-22: 558 başarılı,
3 mevcut golden farkı, 2 atlama (88 dosya). Analiz 0 hata / 8 mevcut uyarı /
1 bilgi; Functions 15 mevcut TypeScript hatası.

## GPU bağlantısı kurtarma ve animasyon zamanı — 9 Ekim 2026

A1/A2 yerel adım: doğrudan editör model canvas'ı WebGL bağlantı kaybında
çalışmayı durdurur ve düzenlemelerin korunduğunu bildiren poster gösterir.
Native canvas restore olayı geldiğinde geçici kamera, hedef, FOV, turntable
ve klip zamanı yeniden uygulanır. Tekrarlanan kayıp/eski callback/dispose,
yeni model ve kullanıcı düzenlemelerinin eski snapshot ile ezilmemesi altı
birim testiyle denetlendi. Bu geçici durum proje JSON'una yazılmaz.

Gerçek tarayıcıdaki WEBGL_lose_context denemesi klip zamanının ilk yüklemede
sıfırlanmasını ortaya çıkardı. Klip Lit updateComplete tamamlandıktan sonra
seek edilir; kaynak/model/revision kontrolü geciken işlemin yeni sahneyi
etkilemesini engeller. Aynı modelde klip/zaman değişiklikleri uygulanır.
Animasyon kapalı veya hareket azaltma etkin olduğunda public pause çağrılır.

Yerel tarayıcıda kamera 32°/67°, radius 4m, hedef (0,.5,0), FOV 51°,
turntable .7 ve RotorSpin 1.5s hem kesinti öncesi hem sonrası doğrulandı.
Kesinti ve kurtarma ekran görüntüleri outputs içinde tutuldu. Bu kontrollü
uzantı testi fiziksel sürücü arızası, watt ölçümü, mobil cihaz veya iframe /
HTML export kurtarma kabulü değildir. Seek/play/pause genişletilmiş tarayıcı
kontrolü, genel baseline-23 ve web-final-32 doğrulaması sürüyor.

Baseline-23: 89 dosyada 564 başarılı test, 3 mevcut golden farkı, 2 atlama.
Yeni başarısızlık yok; golden referansları değiştirilmedi. Analiz 0 hata /
8 mevcut uyarı / 1 bilgi; Functions 15 mevcut TS hatası. Tarayıcıda native
GPU kurtarma + aynı kaynakta 2.5s seek, play ve pause ölçümleri geçti.
Son durdurulmuş zaman 3.1999s, 700ms sonraki zaman yine 3.1999s.

## Önizleme ve HTML sahnesinde GPU kurtarma — 9 Ekim 2026

A3.7 yerel adım: generated preview/export belgesi aynı public SDK + native
canvas restore işleyicisini taşır. Context kaybında canvas DOM'dan kaldırılmaz;
kamera, hedef, radius, FOV, turntable, klip ve zaman geçici olarak tutulur.
Kaynak değişimi, yeni load, dispose ve geciken klip güncellemesi denetlenir.
Gizli sahne restore olduğunda eski oynatma/dönme tercihi ancak sahne tekrar
etkin olduğunda kullanılır. Normal yükleme hataları kendi hata akışında kalır.
Bağlantı kaybında yanıltıcı yükleme hatası yerine model posteri gösterilir.

15 Node runtime testi ve 9 odaklı Flutter testi başarılı; fixture üretimi
ayrıca 1 test. Native WEBGL_lose_context ile standalone generated HTML ve
iframe preview kamera/klip korunması geçti. İlk tabın logunda MutationObserver
hatası bulundu; sayfa error sensörlü temiz oturum tanısı sürüyor.
Baseline-24: 90 dosyada 565 başarılı / 3 mevcut golden farkı / 2 atlama.
Analiz 0 hata / 8 mevcut uyarı / 1 bilgi; Functions 15 mevcut TS hatası.
web-final-33 yerel release kaynak/build kimliği doğrulandı. Fiziksel sürücü,
Android/iOS/ayrı GPU, insan değerlendirmeleri ve production kabulü açık.

Temiz tekrar koşusunda ana belge ve iframe window error sensörleri boş;
native kurtarma ve kamera/klip eşitliği geçti. Tarayıcı aracının logunda
MutationObserver.observe kaydı yine var; kaynağı belirlenemedi ve çözülmüş
sayılmadı. Yerel kabul bu sınırlamayla raporlanır. Fiziksel cihaz/sürücü ve
insan kabul kapıları açık; tüm A0–A10 veya production yayını tamamlanmadı.

Son görsel düzenleme: context kaybı bildirimi modelin ortasından küçük alt
banda alındı. Poster daha az örtülür; restore/load sırasında geçici stiller
kaldırılır. 15 runtime testi ve 9 odaklı Flutter testi + 1 fixture üretimi
tekrar geçti. Native iframe replay kamera/klip eşitliği ve boş ana belge /
iframe error sensörlerini doğruladı. web-final-34 kaynak/build hash eşleşti.
Genel regresyonun son koşusu baseline-24 (565/3 mevcut/2 atlama); son alt bant
stili bundan sonra odaklı kontrollerle doğrulandı. Üretim yayını yapılmadı.

## 50 doğrudan sahne yaşam döngüsü — 9 Ekim 2026

A3.7/A10.3 yerel alt kontrol: native context kurtarma ve seek/play/pause
sonrasında aynı rigged GLB ile 50 yeni HtmlModelCanvas örneği kuruldu.
Her kabul edilen yüklemede kayıtlı FOV 51°, radius 4m ve durmuş klip 2.5s
kontrol edildi. En fazla 1 bağlı model-viewer görüldü; son dispose ardından
0 kaldı. Bu koşuda Flutter runtime hatası ve tarayıcı warn/error yok.
Kanıt: SUTOLS_50_SAHNE_GECISI_DOGRULAMASI.json ve ekran görüntüsü.

Bu ölçüm yalnızca DOM viewer yaşam döngüsüdür; driver/SDK cache/texture
belleği, watt/FPS veya 50 gerçek bulut projesi geçişini ölçmez. Aşamaların
cihaz, insan ve üretim kabul kapıları kapanmış sayılmaz. Production kaynak
web-final-34 ile eşleşir; fixture üretim rotası değildir, yayın yapılmadı.


## 9 Ekim 2026 — Canlı inceleme bulgularının düzeltmeleri

Boş konu uyarısı/odak, geri dönüşte sekme başlığı, şifre düğmesi etiketi,
TR/EN yardım metni ve katalog açıklaması düzeltildi. AI sayı kabulü,
korunan sunuma eksik bölüm tamamlama ve sınırlı revizyon/yeniden üretim eklendi.
Native TTF fontlar ve incelenmiş Linux/macOS görsel referanslarıyla CI düzeltildi.
Yerel ve Linux CI: 579 başarılı / 2 atlanan test; analiz temiz. Ayrı canlı
AI turu: 3 başarılı test (10, 7, 10 slayt). Hosting-only yayın ve canlı misafir
UI kontrolleri geçti. Ayrıntı: tool/development_baseline/DUZELTME_RAPORU_2026-10-09.md.
Hesapla kayıt/yeniden açma/indirme ve insan model kabulü hâlâ açık;
A0–A10 bütünü bu düzeltme ile tamamlandı sayılmaz.
