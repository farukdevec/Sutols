# Sutols — Ürün, Performans ve Model Kütüphanesi Geliştirme Planı

**Hazırlanma tarihi:** 8 Ekim 2026  
**Başlangıç sürümü:** `f673c0411ae752e35da967314cffba756e4177da`  
**Durum:** Uygulama devam ediyor. A0 kontrollü başlangıç hazır; A3 görünürlük altyapısı, A4 normalizasyon, A5 arama/indeks ve A6 özgün model pilotu uygulanıp doğrulanıyor. Tüm aşamalar tamamlanmış değildir.
**Amaç:** Daha akıcı, daha az GPU kullanan, görsel olarak tutarlı ve kolay kullanılan; doğru 3B modeli daha güvenilir bulan bir sunum platformu.

> Çalışma ilkesi: Önce ölç, sonra küçük bir değişiklik uygula, aynı senaryoyu yeniden ölç. Bir aşamanın kabul koşulları sağlanmadan ona bağımlı aşamaya geçme. Her oturumda tamamlanan adımlar, ölçüm sonuçları ve sıradaki iş bu dosyaya işlensin.

## 1. Kapsam ve ürün ilkeleri

1. **Akıcılık:** Kullanıcı yazarken, sürüklerken veya slayt değiştirirken uzun işlem beklememeli.
2. **Senkronizasyon:** Editör, önizleme ve sunum aynı kamera, model, ışık ve animasyon durumunu kullanmalı. İndirme yanıtları ve otomatik kayıtlar güncel işlemle eşleşmeli.
3. **Performans:** Ekranda görünmeyen veya kullanıcıya katkı sağlamayan sahne için sürekli çizim yapılmamalı.
4. **Görsel kalite:** Kaliteyi yalnızca daha yüksek çözünürlükle artırmak yerine doğru ışık, materyal, kamera, kompozisyon ve tipografi kullanılmalı.
5. **Doğru eşleştirme:** Alakasız 3B model otomatik eklenmemeli. Zayıf eşleşmede kullanıcıya seçenek veya uygun 2B düzen gösterilmeli.
6. **Ölçeklenebilir kütüphane:** Model sayısı büyüdükçe ilk açılış ve arama maliyeti aynı oranda büyümemeli.
7. **Kolay kullanım:** İyi varsayılanlar ön planda; ayrıntılı ayarlar ihtiyaç duyulduğunda açılmalı.
8. **Geriye uyumluluk:** Eski sunumlar açılmalı; kütüphane güncellemeleri eski sunumların görünümünü sessizce değiştirmemeli.

Bu plan uygulama, varlık hazırlama ve yayın doğrulamasını kapsar. Eşzamanlı çok kullanıcılı düzenleme, yeni ödeme sistemi ve tüm render motorunun değiştirilmesi ilk kapsamda değildir. Çok kullanıcılı çalışma ayrıca ele alınabilir.

## 2. Başlangıç bulguları ve ilgili kod alanları

| Alan | İncelemede görülen temel | Çalışma yönü |
|---|---|---|
| 3B sahne | `html_stage_document.dart` içinde model-viewer 4.3.1, eager yükleme ve gölge ayarları | Görünürlük, kaynak yaşam döngüsü, kalite profilleri |
| Küçük önizlemeler | Snapshot ve bazı animasyon durdurma mekanizmaları mevcut | Bütün önizleme türlerini kapsama ve doğrulama |
| Sahne durumu | Controller ve preview tarafında kamera yakalama/aktarma mevcut | Ortak sözleşme; mod değişiminde aynı sonucu koruma |
| Model deposu | `model_repository.dart`: oturum ve kalıcı önbellek, paylaşılan yükleme | Katalog sürümü, geçersizleştirme, sayfalama |
| Model erişimi | `model_asset_service.dart`: imzalı URL ve aynı isteği paylaşma | Süre dolumu, oturum değişimi, hata ve yeniden deneme |
| Eşleştirme | `model_matching_service.dart`: IDF, TR/EN etiketler, excludeTags, güven eşikleri | Veri kalitesi, kavram ayrımı, kararlı indeks, ölçümlü sıralama |
| Arka plan/metin | Sahne kaynakları, tasarım tokenları, `presentation_text_fit_script.dart` | Okunurluk, hareket bütçesi, responsive kompozisyon |
| Teknik borç | Proxy alt deposu eksik; functions derlemesi ve bazı testler başarısız | Önce güvenilir geliştirme ve yayın zemini |

**Araştırılacak hipotezler:** Eşleştirme indeksi liste kimliğine göre önbelleklenirken her çağrıda yeni birleşik liste oluşturulması indeksin tekrar kurulmasına yol açabilir. Negatif etiketlerin tam ifade karşılaştırması bazı çekimli/uzun sorguları kaçırabilir. Bunlar ölçüm ve örneklerle doğrulanmadan kesin hata kabul edilmeyecek.

## 3. Aşama sırası ve bağımlılıklar

| Aşama | İş paketi | Bağımlılık | Tamamlanma çıktısı |
|---|---|---|---|
| A0 | Güvenilir başlangıç ve teknik borç ayrımı | Yok | Baseline, hata envanteri, tekrar üretilebilir kurulum |
| A1 | Performans ve eşleştirme ölçümü | A0 | Benchmark seti ve başlangıç ölçümleri |
| A2 | Ortak sahne durumu ve yükleme senkronizasyonu | A1 | Sahne sözleşmesi ve tutarlılık testleri |
| A3 | Görünür sahne ve GPU optimizasyonu | A1, A2 | Sahne yaşam döngüsü ve kalite profilleri |
| A4 | Etiket, taksonomi ve katalog veri kalitesi | A1 | Sürümlü model şeması ve denetlenmiş örnek katalog |
| A5 | Arama, sıralama ve otomatik eşleştirme | A4 | Açıklanabilir arama/eşleştirme ve benchmark sonucu |
| A6 | Model hazırlama ve görsel kalite pilotu | A3, A4 | 10 modelin doğrulanmış hafif/kaliteli sürümleri |
| A7 | Kütüphaneyi büyütme ve yönetim araçları | A5, A6 | Kademeli model paketleri ve yönetim akışı |
| A8 | Arka plan, metin ve kompozisyon iyileştirmeleri | A2, A3 | Görsel profiller ve okunurluk testleri |
| A9 | Editör kullanım kolaylığı ve akıcılık | A5, A7, A8 | Test edilmiş temel kullanıcı akışları |
| A10 | Entegrasyon, kademeli yayın ve izleme | Önceki ilgili aşamalar | Sürüm, yayın raporu ve geri dönüş planı |

A4–A5, A2–A3 sonrasında ayrı iş paketleri olarak sürdürülebilir. Büyük refaktör, katalog veri göçü ve görsel yeniden tasarım tek değişiklik paketine konulmayacak. Takvim, A1 ölçümleri ve teknik borç kapsamı çıktıktan sonra belirlenecek.

## 4. Ölçüm ve kabul hedefleri

Aşağıdaki sayılar **başlangıç hedefidir; mevcut performans sonucu veya kazanç garantisi değildir**. A1 sonunda cihaz ve senaryo bazında kesinleştirilecek; hedef değişirse nedeni kaydedilecek.

| Ölçüt | İlk hedef / kontrol yöntemi |
|---|---|
| Gizli sahne çalışması | Uygulamanın yönettiği gizli sahnelerde sürekli RAF/animasyon yok; açık sahne etkilenmiyor |
| Akıcılık | Dengeli profilde temsilî masaüstünde 60 FPS hedefi, referans mobilde 30 FPS hedefi; p95 frame süresi ayrıca raporlanır |
| GPU yükü | Aynı cihaz, tarayıcı, sahne, çözünürlük ve süreyle önce/sonra ölçüm; mümkünse GPU süreç yükü ve bellek; FPS tek başına GPU ölçüsü değildir |
| Kamera tutarlılığı | Mod geçişlerinde hedef, orbit, görüş alanı ve model dönüşü tanımlanmış tolerans içinde eşit |
| Yerel arama | Isınmış indekste 1.000 kayıt için p95 <100 ms hedefi; DOM çizim süresi ayrıca ölçülür |
| Manuel arama doğruluğu | İnsan tarafından etiketlenmiş sette Recall@5 ≥%90 hedefi |
| Otomatik model seçimi | Precision ≥%95 hedefi; seçimsiz bırakma oranı ve doğru modeli kaçırma oranı da raporlanır |
| Kullanım kolaylığı | Pilot kullanıcıların temel görevleri yardım almadan tamamlama oranı ≥%90 hedefi |
| Görsel kalite | Referans sahnelerde taşma, okunamaz metin, yanlış kırpma ve beyaza patlayan materyal yok |
| Regresyon | İlgili testlerde yeni başarısızlık yok; eski başarısızlıkların durumu açıkça kayıtlı |

GPU ölçümleri ısınma süresi sonrasında en az üç tekrar içersin. İşletim sistemi bütünleşik GPU belleğini ayrı göstermiyorsa bellek tahmini ve gerçek ölçüm ayrı etiketlensin. Ham güç tüketimi ölçülemiyorsa enerji tasarrufu yüzdesi iddia edilmesin.

## A0 — Güvenilir başlangıç

- [x] A0.1 Mevcut commit, Git durumu, SDK/Node sürümleri, build komutları ve yapılandırma gereksinimlerini kaydet.
- [x] A0.2 Önceden başarısız testleri tekrarlanabilir biçimde sınıflandır: gerçek davranış hatası, güncel olmayan beklenti, platforma bağlı görsel fark, canlı servis bağımlılığı.
- [ ] A0.3 `sutol-model-proxy` kaynak adresini ve sahibini doğrula; eksik alt depo tanımını düzelt. İlgisiz gitlink ve rapor klasörlerini ayrı depo bakım işi olarak ele al.
- [ ] A0.4 Firebase Functions ile Cloudflare Worker sorumluluklarını ayır; doğru giriş noktası, ortam tipleri, build ve deployment yapılandırmasını oluştur.
- [x] A0.5 `EnvConfig` kullanan test için anahtar içermeyen örnek kurulum ve kontrollü test atlama/fixture stratejisi oluştur.
- [ ] A0.6 Bir eski sunum yedeği ve yayın geri dönüş noktası hazırla.

**Kabul:** Yerel test/build adımları tekrar üretilebilir. Yayına engel hatalar ile geliştirmeden bağımsız teknik borç ayrılmıştır. Hatalı testler sessizce devre dışı bırakılmaz. Eski sunum örneği açılabilir.

**A0 oturum sonucu (8 Ekim 2026):** 412 başarılı / 29 başarısız / 2 atlanan kontrollü test; 6 canlı dosya ayrı. Analizde 0 hata ve 9 uyarı/bilgi; web build başarılı. Kök neden sınıflandırmaları ön incelemedir. Ayrıntı: `tool/development_baseline/A0_BASLANGIC_RAPORU.md`. A0 bütünü henüz tamamlanmadı.

## A1 — Benchmark ve performans bütçesi

- [ ] A1.1 Senaryolar: 1 model; çok model; animasyonlu model; ağır doku; hareketli arka plan; uzun metin; 20 slayt; hızlı mod geçişi; yavaş ağ; sekme gizleme; süre dolmuş model URL'si.
- [ ] A1.2 Referans cihazları belirle: bütünleşik GPU'lu masaüstü, ayrı GPU'lu masaüstü, Android Chrome ve iOS Safari. DPR ve viewport kaydedilsin.
- [ ] A1.3 Ölç: frame süresi, uzun ana-thread görevleri, etkin sahne/iframe sayısı, yükleme/decode süresi, render çözünürlüğü, katalog/index süresi, çizim çağrıları ve üçgen sayısı erişilebildiği ölçüde.
- [ ] A1.4 En az 200 TR/EN sorgudan arama seti oluştur: tam ad, eşanlam, çekimli sözcük, yazım hatası, belirsizlik, konu dışı sorgu ve uygun modelin bulunmadığı sorgu.
- [ ] A1.5 Veri setini geliştirme ve kilitli değerlendirme olarak ayır; eşik ayarı değerlendirme setinde yapılmasın. Sonuçları kategori ve dil bazında raporla.
- [ ] A1.6 Her sahneye performans bütçesi tanımla; düşük kaliteli profilin okunurluk tabanını da belirle.

**Çıktı:** Senaryo tanımları, benchmark verisi, baseline raporu, kesinleşmiş hedefler. 30/100/1.000 katalog kaydıyla ölçek kontrolü.

## A2 — Ortak sahne durumu

- [ ] A2.1 Sürümlü `SceneState` sözleşmesi tasarla: pageId/blockId, modelId/assetVersion, kamera hedefi-orbit-radius-FOV, model yönü, ışık profili, animasyon klibi-zamanı-oynatma durumu ve tur durumu.
- [x] A2.2 Kalıcı sunum verisini geçici render verisinden ayır; imzalı URL, yükleme yüzdesi ve iframe handle'ı kalıcı sahne kimliği olmasın.
- [x] A2.3 Editör, preview ve export aynı normalizasyon/default kodunu kullansın; mevcut kamera taşıma mekanizması korunarak genişletilsin.
- [ ] A2.4 Kamera jestlerinin son değerini mod geçişinden önce commit et. Her pointer olayında bütün sunumu yeniden çizmekten kaçın.
- [ ] A2.5 İsteklere sürüm/işlem kimliği ekle; eski model yüklemesi veya AI sonucu sonradan gelip yeni seçimi ezmesin. Gerekirse sonuç yok sayılsın.
- [ ] A2.6 Otomatik kaydı debounce et; paralel kayıt yarışlarını ve bağlantı sonrası geri dönüşü işle. Kaydetme durumunu kullanıcıya açık göster.
- [ ] A2.7 Eski sunumlar için şema migration ve güvenli varsayılanlar ekle. Undo/redo kamera, model ve ışık değişimlerini tutarlı kapsasın.

**Kabul:** Editör→sunum→editör ve tur aç/kapat döngülerinde kamera sıçramaz. 20 hızlı slayt değişiminde son seçim doğru kalır. Kayıt sırasında bağlantı kesilmesi değişiklik kaybettirmez. Animasyon zamanı desteklenmeyen bir modelde kontrollü fallback uygulanır.

## A3 — Görünür sahne ve GPU yönetimi

- [ ] A3.1 Sahne durumları: unloaded, poster, loading, active, suspended, disposed, error. Her geçişte hangi kaynakların tutulacağı belirt.
- [x] A3.2 Küçük slayt/kütüphane kartlarında statik poster kullan; hover önizlemesi olacaksa sınırlı süreli ve tek etkin önizleme olsun.
- [ ] A3.3 Sayfa görünürlüğü ve ekran görünürlüğü sinyallerini birlikte kullan. Gizli arka plan, canvas, CSS/SVG ve model animasyonlarını kapsa; mevcut snapshot davranışını bozma.
- [ ] A3.4 Etkin sahneyi önceliklendir; sonraki slaydın dosyasını düşük öncelikle hazırla. Prefetch ile canlı render'ı birbirine bağlama.
- [ ] A3.5 Tasarruf/Dengeli/Yüksek profillerini çözünürlük, gölge, efekt ve animasyon bütçesine bağla. Cihazın gerçek frame süresine göre kaliteyi kademeli değiştir; sık gidip gelmeyi önleyen histerezis uygula.
- [ ] A3.6 Orbit veya animasyon yokken değişiklik gerektirmeyen çizimi durdur; renderer'ın kendi talebe göre çizimini gereksiz bir ikinci RAF döngüsüyle değiştirme.
- [ ] A3.7 Sahne kapanınca listener, timer, iframe ve model kaynaklarını uygun API ile bırak. Paylaşılan kaynakları referans sayısıyla koru; GPU context kaybında poster/hata kurtarma ekle.
- [ ] A3.8 Model-viewer 4.3.1'in gerçek desteklerini test et. Decoder/loader uyumluluğu doğrulanmadan varlık formatı değiştirme.

**Kabul:** Gizli sahneler sürekli uygulama animasyonu üretmez. 50 slayt geçişinde kaynak sayısı/bellek sürekli büyümez. Modeller görünür olduğunda aynı kamera ile devam eder. Önce/sonra ölçümü ve kalite karşılaştırması birlikte sunulur.

## A4 — Etiket ve katalog veri modeli

- [ ] A4.1 Kayıt şeması: id, sürüm, TR/EN ad-açıklama, kategori/alt kategori, kavram kimlikleri, nesne adları, eşanlamlar, negatif kavramlar, kaynak/lisans, performans ve görünüm metadata'sı.
- [ ] A4.2 “Enerji”, “gelişim”, “sistem” gibi geniş terimler ile “kompresör”, “embriyo”, “kahve çekirdeği” gibi somut nesneleri ayır; geniş terim tek başına otomatik seçim kanıtı sayılmasın.
- [x] A4.3 Türkçe I/İ/ı/i, Unicode, noktalama, birim ve çoğul varyasyonları için ortak normalizasyon yaz. Kök bulma özel adları ve teknik terimleri bozmamalı.
- [ ] A4.4 Belirsizlik sözlüğü: hücre, çekirdek, ağ, kök gibi kavramları bağlama göre ayır. Negatif etiketler ilgili bağlamı reddetsin; aşırı geniş yasak üretmesin.
- [ ] A4.5 İçe aktarma denetimi: boş/tekrarlı ID, kırık adres, çelişkili etiket, bilinmeyen kategori, eksik thumbnail/lisans ve aynı varlığın kopyaları.
- [ ] A4.6 Katalog sürümü ve asset hash ile indeks/cache geçersizleştirme tasarla. Oturum/yetki değişiminde eski erişim bilgilerini kullanma.

**Kabul:** Yeni kayıtlarda zorunlu alanlar doğrulanır. Negatif/pozitif kavram çakışmaları raporlanır. 10 pilot model elle onaylanmış etiketlere sahiptir. Eski kayıtlar migration ile çalışır.

## A5 — Arama ve otomatik eşleştirme

- [x] A5.1 Manuel arama ile otomatik yerleştirmeyi ayır: manuel arama keşfi desteklesin; otomatik seçim daha yüksek güven gerektirsin.
- [ ] A5.2 Aday üretim sırası: tam ad/ifade → kavram/eşanlam → ağırlıklı sözcük → kontrollü yazım hatası toleransı. Fuzzy eşleşme tek başına otomatik yerleştirme sebebi olmasın.
- [ ] A5.3 Adayları somut nesne kanıtı, başlık/metin bağlamı, kategori, negatif kanıt, cihaz bütçesi ve görsel uyuma göre sırala. IDF'yi mevcut katalog büyüklüğüne karşı test et.
- [x] A5.4 Kararlı indeks kullan: katalog sürümü + dil + erişim kapsamı. Her sorguda katalogyu ve indeksi tekrar kurma. Ağır indekslemeyi gerekirse worker'a taşı.
- [ ] A5.5 Semantik aramayı ikinci kademe deney olarak değerlendir. Model metadata embedding'leri önceden üretilebilir; istemciye büyük AI modeli yüklemek varsayılan olmasın. Remote hizmet için gecikme, maliyet, veri aktarımı ve fallback kararı ayrıca verilsin.
- [ ] A5.6 Karar: yüksek güven→otomatik model; orta güven→en iyi 3 seçenek; düşük güven→2B düzen veya sonuç yok. Skor doğrulanmadan “% güven” etiketi kullanma.
- [ ] A5.7 Kullanıcıya “Neden önerildi?” açıklaması: eşleşen kavram ve bağlam. “Uygun değil” geri bildirimi önce öneri olarak kaydedilsin; doğrudan canlı etiketleri değiştirmesin.
- [ ] A5.8 Sonuçlarda kategori, animasyon, tur desteği ve hafif model filtreleri; ilgili/recent/popüler sıralamaları ve boş sonuç rehberi.

**Kabul:** Kilitli benchmark hedefleri kategori/dil bazında sağlanır. “Kahve çekirdeği” ile biyolojik çekirdek, “bilgisayar ağı” ile balık ağı karışmaz. Uygun model yoksa zorla sonuç üretilmez. Anonim ve giriş yapmış kullanıcının erişim farkları bilinçli ve testlidir.

## A6 — Standart model hazırlama ve görünüm pilotu

- [ ] A6.1 Temsilî 10 model seç: organik, metalik, mimari, animasyonlu, saydam, eğitim/teknik kesit ve ağır dokulu örnekler.
- [ ] A6.2 Kaynak, lisans/atıf, model ölçeği, up-axis, merkez, bounding box, normaller, UV, doku renk uzayı ve materyalleri doğrula.
- [ ] A6.3 Blender ile gerektiğinde geometri/normaller/UV düzelt, birleşebilir parçaları birleştir, görünmeyen yüzeyleri kaldır ve aydınlatmayı düzenle. Rig, animasyon, hotspot ve kesit yapısı korunmalı.
- [x] A6.4 Blender MCP erişimi varsa hazırlama için kullan; yoksa Blender CLI/Python veya uygun glTF araçlarıyla tekrar üretilebilir süreç kur. MCP kurulumunu varsayma.
- [ ] A6.5 LOD/hafif-kaliteli sürümler üret; doku boyutu ve mesh sadeleştirmeyi birlikte yönet. Mesh sıkıştırması indirme boyutunu azaltır; daha az üçgen/draw call çizim yükünü azaltır. KTX2 GPU dokusu için ayrı değerlendirilir.
- [ ] A6.6 Model başına ışık/pozlama/ortam/gölge/kamera profili oluştur. Anıtkabir'in özel pozlama ihtiyacını genelleştirmeden mevcut kalibrasyonunu koru.
- [x] A6.7 Sabit sahnede thumbnail üret. Kullanıcıya gösterilen görsel gerçek model sürümünü ve materyalini temsil etsin.
- [ ] A6.8 glTF doğrulaması ve model-viewer testi: yükleme, animasyon, tur/hotspot koordinatları, materyal, cihaz uyumluluğu. Otomatik optimizasyonun görsel karşılaştırması insan tarafından onaylansın.

**Çıktı:** Orijinal kaynak + işlem tarifi + hafif/kaliteli GLB + thumbnail + metadata + önce/sonra boyut/performance/görünüm raporu. İlk model bütçeleri A1'den türetilir; yalnızca MB değerine göre kalite kararı verilmez.

## A7 — Kütüphane genişletme ve yönetim

- [ ] A7.1 Kategori kapsamını en çok kullanılan sunum konuları ve A5'in boş sonuçlarına göre seç. İlk aday hedef: 10 kategori, toplam 100 yeni doğrulanmış model.
- [ ] A7.2 Küçük paketlerle ilerle: 10 pilot → 25 → 50 → 100. Her paket A4/A6 kontrolünden geçsin; toplam sayı kaliteye üstün gelmesin.
- [ ] A7.3 Kaynak havuzu: uygun lisanslı Poly Haven/Kenney varlıkları, doğrulanmış diğer kaynaklar ve özgün Blender üretimleri. Kaynak ve lisans şartları model bazında kaydedilsin.
- [ ] A7.4 Admin akışı: içe aktar → doğrula → optimize et → thumbnail/etiket → önizle → onayla → yayımla. Başarısız varlıklar ayrı karantina durumunda tutulur.
- [ ] A7.5 Katalog sorgularına sayfalama, filtreler ve sanallaştırılmış liste ekle; arama sonucunda yalnızca gereken metadata/görseller indirilsin.
- [ ] A7.6 Favoriler, son kullanılanlar, tematik koleksiyonlar ve benzer model önerileri ekle. Aynı varlığı farklı ID ile çoğaltma.
- [ ] A7.7 Varlıklar sürümlü/değişmez adreslerle saklansın. İmzalı URL yenilemesi kimlikten ayrı olsun; eski sunumun kullandığı sürüm geri alınabilsin.

**Kabul:** Her paket lisans, yükleme ve eşleştirme denetimini geçer. 1.000 kayıt testinde ilk görünüm tüm modelleri canlı çizmez. Model sayısı paket sonunda doğrulanmış envanterden raporlanır.

## A8 — Arka plan, metin ve kompozisyon

- [ ] A8.1 Mevcut arka planları hareket yoğunluğu, renk, konu, metin alanı ve GPU maliyetine göre sınıflandır.
- [ ] A8.2 Sakin/Standart/Etkileyici görsel profiller oluştur. Etkileyici profil dahi metnin okunurluğunu ve cihaz bütçesini aşmasın.
- [ ] A8.3 Metnin arkasına gerektiğinde gradient/scrim veya temiz yüzey ekle; metin bölgesinde yüksek kontrastlı hareketi azalt. `prefers-reduced-motion` gözetilsin.
- [ ] A8.4 Başlık-gövde-açıklama tipografi ölçeği, satır uzunluğu, boşluk ve hizalama tokenlarını ortaklaştır. TR/EN karakterler ve font fallback'leri kontrol edilsin.
- [ ] A8.5 Metin sığdırma: önce yerleşim ve boşluk düzenle; sonra sınırlı font küçültme; okunurluk tabanının altında uyarı/bölme öner. Metni otomatik ve sessizce silme veya anlamını değiştirme.
- [x] A8.6 Model, metin ve arka plan için ortak kompozisyon şablonları: karşılaştırma, tek odak, açıklamalı model, süreç ve veri odaklı düzen.
- [ ] A8.7 Hareketi seçici uygula: sayfa başına sınırlı odak animasyonu; her öğeye ayrı sürekli efekt verme.
- [x] A8.8 Font yüklenmesi, resize ve gerçek metin değişiminde ölçümü yenile. Her frame'de tüm metin kutularını ölçme; layout okuma/yazma işlemlerini grupla.

**Kabul:** Uzun Türkçe başlık, tablo/listeler, uzun kelime, mobil ekran ve farklı fontlarda taşma yok. Etkileşimli UI kontrastında WCAG AA hedeflenir; sunum görsellerinde okunurluk ayrıca incelenir. Editör/preview/export aynı yerleşimi verir veya destek sınırı açıkça gösterilir.

## A9 — Kullanım kolaylığı ve editör akıcılığı

- [ ] A9.1 Öncelikli görevleri tanımla: sunum oluştur, model bul, modeli değiştir, metin düzenle, görünüm seç, önizle, kaydet ve dışa aktar.
- [ ] A9.2 Ana çalışma alanını sadeleştir: sık kullanılan eylemler görünür, ayrıntılı ayarlar seçili öğeye göre açılan panelde. Panel aç/kapat seçim ve kamera durumunu kaybettirmesin.
- [x] A9.3 Arama kutusuna yazarken debounce, önceki sorgu iptali/sonuç sürüm kontrolü ve kısa yükleme göstergesi uygula; eski sorgu yeni sonucu ezmesin.
- [ ] A9.4 Sürükleme sırasında yalnızca ilgili öğeyi güncelle. Büyük belge snapshot'ını her harekette oluşturma; undo işlemini tamamlanan jest bazında grupla.
- [ ] A9.5 Klavye kısayolları, odak yönetimi, erişilebilir etiketler ve mobil dokunma hedeflerini tamamla.
- [ ] A9.6 Yükleniyor, boş sonuç, çevrimdışı ve hata durumları net olsun. Kullanıcıya tekrar deneme, hafif sürüm veya değişiklikleri koruma seçeneği sun.
- [ ] A9.7 İlk kullanımda kısa görev odaklı rehber; örnek sunum ve tek tık görünüm seçenekleri. Karmaşık zorunlu başlangıç formu ekleme.
- [ ] A9.8 5–8 pilot kullanıcıyla görev testi yap; tamamlanma oranı, süre, yanlış tıklama ve yardım ihtiyacını kaydet. Sorunları gözlemlenen kanıta göre sırala.

**Kabul:** Kritik görevler fare/klavye ve referans mobilde tamamlanır. Yazma ve sürükleme sırasında girdiler kaybolmaz. Panel kapatma, model yüklenmesi ve kayıt durumları anlaşılırdır.

## A10 — Entegrasyon ve yayın

- [ ] A10.1 İlgili mevcut testleri güncelle; davranış testlerini uygulamayı birebir kopyalayan testlerle değiştirme. Görsel test farkları onaylanmadan referansları yenileme.
- [ ] A10.2 Birleşik senaryo: yavaş ağda arama → model seç → kamera değiştir → slayt değiştir → sunum → geri dön → kaydet → yeniden aç → export.
- [ ] A10.3 Uzun oturum, context kaybı, token/URL süresi dolumu, offline ve eski proje migration testleri.
- [ ] A10.4 Sürüme commit, build zamanı, katalog/şema sürümü ekle. Test edilen build ile yayımlanan build aynı artefact olsun.
- [ ] A10.5 Yeni render, eşleştirme ve katalog davranışlarını ayrı feature flag'lerle aç; geri dönüşte önceki varlık ve veri sürümleri kullanılabilsin.
- [ ] A10.6 Staging doğrulaması sonrası kademeli üretim yayını. Yayın kararı için değişiklik özeti, test sonucu, bilinen sorunlar ve geri dönüş adımları hazırlanır.
- [ ] A10.7 İzleme: model yükleme hatası, arama gecikmesi/boş sonuç, otomatik seçim reddi, frame süresi ve kayıt hatası. Ham sunum metinlerini varsayılan log olarak saklama.

**Kabul:** Performans, eşleştirme, görsel ve görev testleri birlikte değerlendirilmiştir. Kritik regresyon yoktur; bilinen sınırlamalar kayıtlıdır. Geri dönüş denenmiştir.

## 5. Riskler ve önlemler

| Risk | Önlem |
|---|---|
| Daha hafif modelin görünümünü bozmak | Orijinali koru, pilot ve görüntü karşılaştırması, model bazında onay |
| Render optimizasyonunun kamerayı/animasyonu sıfırlaması | A2 ortak durum; suspend/resume testleri |
| Etiket sayısı artırıldıkça yanlış eşleşmenin artması | Kavram ayrımı, negatif kanıt, kilitli benchmark |
| Çok yüksek eşikle hiç model önerilememesi | Precision ile birlikte kapsama ve seçimsiz bırakma oranını ölç |
| Katalog büyümesinin açılışı yavaşlatması | Sayfalama, sürümlü indeks, poster ve sanallaştırma |
| KTX2/mesh decoder uyumsuzluğu | Mevcut renderer/cihaz matrisi; doğrulanmış fallback |
| Eski sunumların görünümünün değişmesi | Şema migration, assetVersion ve değişmez varlık adresleri |
| Arka planların metni bastırması | Kontrast ve hareket bütçesi; metin alanı maskesi |
| CI'daki eski hataların yeni hataları gizlemesi | Başlangıç envanteri; yeni regresyon için ayrı kabul kapısı |

## 6. Her iş paketinin tamamlanma tanımı

Bir iş yalnızca kod yazıldığı için tamamlanmış sayılmaz:

- [ ] Problem, kapsam ve etkilenen kullanıcı akışı yazıldı.
- [ ] Küçük ve geri alınabilir değişiklik uygulandı.
- [ ] İlgili davranış/performance testleri geçti.
- [ ] Görsel değişiklikte önce/sonra ekranları incelendi.
- [ ] Eski sunum ve desteklenen cihazlarda kontrol edildi.
- [ ] Ölçüm sonucu, bilinen sınırlama ve geri dönüş adımı kaydedildi.
- [ ] Bu dosyadaki durum ve sıradaki iş güncellendi.

## 7. İlk uygulama oturumunun kesin kapsamı

**Başlangıç:** A0.1, A0.2, A1.1 ve A1.3.

1. Güncel projeyi ve kurulum komutlarını kaydet.
2. Var olan başarısız testleri sınıflandır; canlı servis çağıran testleri kontrollü testlerden ayır.
3. Temsilî bir model, bir ağır model, bir animasyonlu arka plan ve uzun metin içeren referans sunum hazırla.
4. Görünür/gizli sahne sayısını, animasyon yaşam döngüsünü ve frame sürelerini ölç.
5. İlk küçük performans değişikliğini seç; önerilen aday küçük resim/poster ve gizli sahne davranışıdır. Seçimi ölçüm belirlesin.
6. Aynı senaryoda tekrar ölç; sonuçları kaydet ve A2 sözleşmesine geç.

Bu ilk oturumda bütün renderer yeniden yazılmayacak, toplu model importu yapılmayacak ve geniş görsel tasarım değişikliğiyle ölçüm zemini karıştırılmayacak.

## 8. Oturum ve karar günlüğü

| Tarih | İş paketi | Yapılan / ölçüm | Karar ve sıradaki adım |
|---|---|---|---|
| 2026-10-08 | A0 başlangıç | Tekrarlanabilir kontrol aracı, test envanteri, ortam tabanlı Grok probe, kaynak yedeği ve başarılı yerel web build. Uygulama kaynakları korunuyor. | Proxy/Worker kaynak doğrulaması ve üretim geri dönüşü açık; A1 ölçümleri henüz alınmadı. |
| 2026-10-08 | Planlama | Güncel kaynak yapısı incelendi; aşamalar, bağımlılıklar ve kabul hedefleri tanımlandı. | Uygulama A0/A1 başlangıç paketinden ilerleyecek. |

### Uygulama güncellemesi — 8 Ekim 2026

- Arama artık ad, TR/EN etiket ve kategoriyi birlikte tarar; 150 ms debounce ve eski yükleme sonucu koruması eklendi. Manuel keşif ve yüksek güvenli otomatik seçim ayrı kalır.
- Eşleştirme indeksi liste kimliği yerine içerik imzasıyla yenilenir; Türkçe İ ve çekimli çok sözcüklü negatif etiket düzeltmeleri yapıldı. İlgili çekirdek pakette 51 test geçti. 1.000 sentetik kayıtta 15 ısınmış sorgunun en yavaş örneği ~19 ms; bu insan değerlendirmesi veya kesin GPU kazancı değildir.
- Sahneye özel RAF askıya alma, belge/viewport görünürlüğü, CSS/model/SVG durdurma ve bfcache geri dönüşü eklendi. 5 Node yaşam döngüsü testi geçti. Yerel tarayıcıda kare sayısı durdurmada 6'da sabit kaldı, sürdürmede 20'ye ilerledi.
- Tasarruf/Dengeli/Yüksek tercihi proje verisine eklendi; eski veride Dengeli varsayılanı ve undo test edildi. Otomatik cihaz kalitesi/histerezis henüz yapılmadı.
- Blender CLI ile 10 özgün şematik model, 20 GLB varyantı ve 10 gerçek thumbnail üretildi. Hafif sürümler 17–92 KB. Khronos glTF Validator 20 dosyada 0 hata / 0 uyarı bildirdi. Bu pilot animasyonlu/saydam/ağır dokulu model kapsamını tamamlamaz; 100 model hedefi açık.
- 37 proje/controller/kalite testi geçti; katalog entegrasyonunda 44 başarılı, başlangıçta var olan 2 başarısız beklenti devam ediyor. Yerel web release build geçti (mevcut CupertinoIcons uyarısı sürüyor).
- Proxy kaynak alt deposu, gerçek üretim Worker kaynağı, Android/iOS/ayrı GPU ölçümü, insan etiketli benchmark ve pilot kullanıcı testi dış doğrulama bekliyor. Bunlar tamamlandı olarak işaretlenmedi.

Yeni oturumlarda aşağıdaki şablon kullanılsın:

```text
Tarih / başlangıç commit'i:
İş paketi ve hedef:
Yapılan değişiklik:
Önce / sonra ölçümü:
Çalıştırılan testler ve sonuç:
Görsel kontrol:
Bilinen sınırlama:
Geri dönüş:
Tamamlanan checkbox'lar:
Sıradaki tek iş paketi:
```

Son kontrollü doğrulama: **472 başarılı / 3 başarısız / 2 atlanan**, 69 dosya;
6 canlı servis dosyası ayrı. Başlangıca göre yeni başarısız test adı yok.
Web release başarılı; Flutter analizinde 0 hata, 8 uyarı ve 1 bilgi.
Detaylı güncel rapor: `tool/development_baseline/GELISIM_DURUMU.md`.

## 8.1 Entegrasyon ilerleme kaydı — 8 Ekim 2026

Bu kayıt bir aşama kabulü veya üretim yayını değildir. Başlangıç verisi korunur;
ölçülemeyen hedefler tamamlandı işaretlenmez.

| Aşama | Uygulanan çalışma | Kalan kabul / bağımlılık |
|---|---|---|
| A0 | Kontrollü baseline, canlı servis dosyalarının açık ayrımı, kaynak yedeği | Eksik proxy alt deposu, Worker/Functions ayrımı, gerçek eski sunum ve üretim geri dönüşü |
| A1 | 1.000 kayıt eşleştirme ölçümü, yerel M1 cihaz kaydı, görünürlük kontrol sahnesi | İnsan etiketli 200 sorgu, kilitli değerlendirme, gerçek GPU/frame/device matrisi |
| A2 | Kamera/klip/zaman kaydı, ortak kalite ayarı, sıralı ve geciktirilmiş otomatik kayıt, hesap bazlı yerel kurtarma | Oturum geçişi ve yavaş/offline ağın tam birleşik canlı senaryosu |
| A3 | Sahne yerel RAF/CSS/SMIL/model duraklatma, iframe görünürlük ve route kontrolü, export slayt aktivasyonu | Tüm arka planların zamanlayıcı envanteri, uzun oturum/context kaybı, cihaz ölçümü |
| A4 | Hesap değişiminde imzalı URL yetki önbelleği temizliği; geç gelen URL cevabı korunması | Ortak decode belleği limiti, staging izin ve eski yayın sürümü geri çağırma |
| A5 | TR normalizasyon/çekim, negatif ifade, içerik bazlı indeks; manuel arama, kategori ve yazım toleransı; güçlü slayt önerileri ve kelime gerekçeleri | Kilitli insan değerlendirmesinde Precision/Recall hedefleri |
| A6 | Blender ile 25 özgün şematik model, 50 GLB, gerçek thumbnail, hash/üçgen metadata | Organik/rig/saydam/ağır dokulu temsilî pilot ve insan görsel onayı |
| A7 | 25 model paketi; cihazda hesabına özel favoriler ve 30 son kullanılan model; sanallaştırılmış kartlar; yerel GLB karantina/inceleme/onay aracı ve admin karar ekranı | 50/100 paket, uzak yayın bağlantısı, sayfalama ve benzer öneriler |
| A8 | Yerel tema fontları; ortak font ağırlığı; Sakin/Standart/Etkileyici render presetleri; hareket azaltma; uzun metin/kutu ölçüsü ön kontrolü | Kompozisyon ve kontrast profilleri, tarayıcı ölçüm karşılaştırması, insan görsel kontrolü |
| A9 | Debounce, yerel katalogla anında açılma, bulut hata rehberi, favori yıldızı, mobil font düzeltmesi | Pilot görev ölçümü, başlangıç rehberi ve tüm erişilebilirlik/klavye denetimi |
| A10 | Kaynak+asset/build hash manifesti ve dar feature flag'ler; test farklarının ayrımı | Yeşil regresyon kapısı, staging birleşik senaryo, üretim yayını ve geri dönüş denemesi |

**Varlık doğrulaması:** 25 model / 50 GLB için Khronos denetimi 0 hata ve 0 uyarı.
Tarayıcıda her hafif ve kaliteli sürüm için `load` sonucu görüldü; 25 thumbnail
başarıyla açıldı. Kontrol sayfası tek model-viewer kullanır. Durdurulmuş RAF sayacı
7'de kaldı, sürdürme sonrası 9'a ilerledi. Bu, GPU watt veya yüzde tasarruf ölçümü
sayılmaz. Kontrol sayfasında kaynağı belirlenmemiş MutationObserver konsol hatası
bulundu; tümleşik uygulama konsolu ayrıca incelenmelidir.

**Kütüphane:** Favoriye basmak slayta nesne eklemiyor; kullanıcı değişiminde
tercihler ve plan bilgisi yenileniyor. Favoriler en fazla 200, son kullanılanlar
30 stabil model ID'si tutar; imzalı adres veya sunum metni kaydetmez.

**Tipografi:** 18 tema ailesinin yerel font eksikliği giderildi. Yeni aileler
kendi lisans dosyalarıyla eklendi. Mevcut Tinos paketinin lisans kaydı eksikliği
eski teknik borçtur; tam yeniden indirme lisans doğrulaması olmadan tamamlanmaz.
Google Fonts kaynak ve lisans başvurusu: https://github.com/google/fonts.
2026 tarihli Tinos upstream OFL dosyası bulundu; eski paket fontunun lisans
metadata eşleşmesi yapılmadan dosya eski varlığa otomatik bağlanmadı.
`flutter pub get`, kurulu SDK'nın gerektirdiği meta/test_api kilitlerini güncelledi;
bu değişiklik nihai regresyon çalışmasına dahildir.

**Kayıt:** Bulut sunumları 1,8 saniye duraklama sonrası kaydedilir. Önce hesabı ve
sunum ID'siyle yerel checkpoint denenir. Cloud yazıları sıralıdır; eski başarılı
kayıt daha yeni checkpoint'i silmez. Yerel kota hatası cloud denemesini kesmez.
Kurtarma kullanıcıya görünürdür; açılışta sessiz veri değiştirilmez. Yerel
Preferences temizlenmesi, browser profil kaybı veya cihaz kaybı kurtarma garantisi
kapsamında değildir. Tam offline canlı doğrulama henüz yapılmadı.

## 9. Teknik başvuru kaynakları

Uygulama sırasında kurulu sürümün davranışı tekrar doğrulanmalı:

- Model-viewer API, poster/yükleme, cache ve çözünürlük: https://modelviewer.dev/docs/index.html
- Model-viewer yükleme ve sıkıştırılmış varlık örnekleri: https://modelviewer.dev/examples/loading/index.html
- KTX2 ve GPU dokuları: https://www.khronos.org/ktx/
- glTF Transform hazırlama/optimizasyon araçları: https://gltf-transform.dev/cli
- Poly Haven varlık lisansı: https://polyhaven.com/license
- Kenney lisans bilgisi: https://kenney.nl/support

Kaynaklar geliştirme kararlarını destekler; üçüncü taraf dosyalar, otomatik etiket önerileri ve araç sonuçları kalite kontrolü olmadan yayımlanmaz.

## 8.2 Slayt önerisi ve model kabul paketi — 8 Ekim 2026

Slayta uygun filtre en fazla 6 güçlü eşleşme ve kelime gerekçesi gösterir.
Metin değişimini izler; kullanılan modeli tekrar önermez. Manuel arama ve
kategori filtreleri öneri listesinde de uygulanır; otomatik ekleme yapılmaz.
Yerel model kabulü `tool/models/intake.cjs` ile karantina, Khronos denetimi,
8 MiB/50.000 üçgen bütçesi ve değişmez hash kaydına kavuştu. Görsel/lisans
incelemesi sonrası onaylı dosya paketi hâlâ yayımlanmamıştır. Firestore model
yazma kuralı değişmedi; admin paneli ve sunucu yayın endpoint'i eksiktir.

Son genel test: 461 başarılı, 3 görsel referans hatası, 2 atlanan. Yeni başarısız
test adı yoktur. Üç referans eski yerleşimden farklıdır; görsel karar bekler.
Görsel referanslar yenilenmedi. Web release derlendi; üretim yayını yapılmadı.
87 öneri/responsive testi ve 4 yerel kabul testi başarılı. UI görsel kontrolü
widget renderer'ındadır; gerçek authenticated web akışının yerine geçmez.
A0–A10 kabulü ve dış cihaz/insan testleri hâlâ tamamlanmış sayılmaz.

## 8.3 Okunurluk ve admin karar ekranı — 8 Ekim 2026

Metin panelinde isteğe bağlı okunurluk ön kontrolü eklendi. Uzun metin, küçük
yazı, dar kutu ve sahne dışı geometri gösterilir; metin/konum otomatik değişmez.
Flutter ölçümü HTML tarayıcının kesin sonucu değildir; bu sınır görünürdür.
Admin gate arkasındaki menüye Model inceleme eklendi. Rapor yükleme, inceleyen
adı, görsel/lisans/uyarı beyanları ve yerel onay/ret kararı indirme vardır.
Yerel kabul aracı kararın üç dosya hash'ini eşleştirir, değişen dosya/raporu
reddeder; dosyayı tekrar doğrular. Uzak katalog yayın endpoint'i hâlâ eksiktir.

69 dosyada 472 başarılı / 3 eski görsel referans hatası / 2 atlanan test.
13 Node ve 1 Python testi, 2 widget görsel kontrolü başarılı. Web release
başarılı; kaynak/build kimliği eşleşiyor. Gerçek karantina önizlemesi yükleme
ve dönüş kontrolleriyle incelendi. Tam authenticated admin upload/download
web E2E, insan cihaz/görsel pilotu, 50/100 paket ve üretim yayını tamamlanmadı.

**Dosya akışı ek kontrolü:** ayrı localhost QA girişinde rapor dosya seçiciden
alındı; ret kararı gerçekten indirildi ve hash'leri diskten doğrulandı. Yerel
araç kararı ret kaydına uyguladı; gerçek model onayı/yayını yapılmadı.
AdminGate korunur. Yetkili hesap/uzak yayın birleşik senaryosu hâlâ açık.
Son yerel release `web-final-5`; kaynak/build kimliği eşleşir.

## 8.4 Keşif, görünür sahne ve 50 model paketi — 8 Ekim 2026

Uygulandı: benzer model keşfi (iki anlamlı ortak etiket ve negatif bağlam
koruması), isteğe bağlı beş adımlı rehber, düz zemin kontrast uyarısı, küçük
slayt/HTML snapshot posterleri ve kısa masaüstü panelinin yerleşim düzeltmesi.
Model URL yenilemesi eski yanıtı yeni seçime yazmaz. model-viewer 4.3.1'in
kendi uyarlamalı çözünürlüğüne profillerin alt sınırı verildi; ek RAF yoktur.
51 arka planın statik kaynak envanteri çıktı; head olmayan kaynakta lifecycle
yerleştirme düzeltildi.

Kütüphane artık **50 özgün model / 100 GLB / 50 thumbnail** içeriyor. Yeni
kimya, biyoloji, matematik, elektronik ve mekanik modelleri şematiktir; organik
rig/animasyon/saydam/ağır doku pilotunun yerine geçmez. GLB doğrulama 0 hata/0
uyarı; tarayıcıda 100 kaynak yolu ve 50 görsel yüklendi. Kontrol sayfasındaki
MutationObserver hatasının kaynağı hâlâ açık ve doğrulama JSON'unda korunuyor.

Genel test: 485 başarılı / 3 görsel fark / 2 atlama; 6 üretim servis dosyası
çalıştırılmadı. Node 16 başarılı. Flutter analiz 0 hata, 8 mevcut uyarı/1 bilgi;
Functions'ın 15 mevcut TypeScript hatası açık. Alt adım A3.2 tamamlandı; A3.5
cihaz karşılaştırması, A6 insan görsel kabulü, A7'nin 100 model hedefi ve
A9'un kullanıcı görev testleri tamamlanmış sayılmıyor.

Sonraki öncelikler: sürümlü ortak sahne sözleşmesi; model yükleme/context
kaybı kurtarma; kompozisyon ve arka plan metadata'sı; insan etiketli arama
setinin hazırlanması; eksik proxy kaynağıyla backend/staging doğrulaması.

Ek kontrol: Tinos lisansı dört font binary name kaydıyla eşleştirilip sabit
upstream commit'ten eklendi. HTML model hata handler sözdizimi düzeltildi;
geç yükleme olayları kaynak kimliğiyle elenir. İki Node olay testi başarılı
(toplam 18); export/model kaynakları için son 20 Flutter testi başarılı.
Context kaybının token yenilemesi olmadığı ayırt edilir; tam kurtarma açık.


### Ortak sahne ve hareket paketi — 8 Ekim 2026

`PresentationSceneState` v1 kimlik/varlık sürümü ve ortak kamera-klip-zaman
normalizasyonu eklendi. Codec, HTML/patch ve doğrudan renderer aynı normalizasyonu
kullanır. Eski işaretsiz JSON ve klip temizleme testleri geçti. Bu gelişme A2.1–3
altyapısıdır; gerçek eski sunum/yavaş ağ/mod geçişi kabulü hâlâ açık.
Galton ve yıldız bileşenlerinin bağımsız zamanlayıcıları kaldırıldı. Bileşen kök
seçicileri yerel örneğe bağlandı; gerçek tarayıcıda duraklama/sürdürme ve iki kopya
kontrol edildi. Hareket azaltma 3D kontrollerini korur. Baskı yerel posterini
blob'a gömer ve GLB indirmez. Kaydedilmiş kamera açısına özel poster henüz yoktur.
250 sorguluk insan inceleme CSV'si ile write-once kilit/değerlendirme araçları
hazırlandı; insan doğruluğu ve Precision/Recall kabulü henüz tamamlanmadı.
Genel son kontrol 491 başarılı, 3 golden farkı, 2 atlama; ardından kısa ekran
paneli için 88 test geçti. Node 22/22 ve yerel Firestore atomik kayıt 1/1 geçti.
Eksik proxy kaynağı, cihaz/insan kabulü, temsilî rig/texture pilotu, 100 model
aday hedefi, kompozisyon ve staging/yayın kapıları açık kalır.


### Son uygulama kaydı — 100 model ve geri alınabilir düzenler

- A7'nin aday sayı hedefi: 11 kategoride 100 özgün model, 200 lite/quality GLB,
  100 gerçek thumbnail. Kimlik/hash, gerçek GLB üçgen sayısı, indirme/üçgen
  bütçesi ve Khronos doğrulaması geçti. İnsan görsel/öğretimsel kabulü ve uzak
  yayın akışı açık olduğundan A7.1–2 bütünü kapatılmadı.
- A6 statik optimizasyon: ilk 50 modelin 100 LOD'unda primitive instance 706'dan
  236'ya indi; köşe/üçgen/malzeme eşdeğerliği doğrulandı. Rig ayrı pilotta korunur.
  Gerçek GPU/FPS/cihaz ölçümü ayrıca gerekir.
- A8.6 beş seçili-slayt kompozisyonu uygulanır; içerik ve sahne verisini korur,
  desteklenmeyen kapasiteyi reddeder ve tek adımda geri alınır. Okunurluk ve insan
  görsel kabulü ayrı kapılardır. Veri odağında 3–4 açıklama iki sütun düzenlenir.
- A2.2–3 kalıcı/geçici kimlik ayrımı ve ortak render normalizasyonu uygulanıp
  kontrol edildi. A2.1'in tam ışık profili, birleşik canlı geçiş ve cihaz testleri
  açık kalır. Yerel/bulut kayıt durumu artık doğru sunulur.
- Son genel kontrol: 499 başarı / 3 golden farkı / 2 atlama; sonraki değişiklikler
  111 ve 9 odaklı testle kontrol edildi. 450 sorguluk taslak gerçek insan
  benchmark'ı değildir. Yeni kaynak için release doğrulaması sürüyor.
- Eksik proxy kaynağı, Functions/Worker ayrımı, insan/cihaz kabulü, gerçek eski
  proje, staging ve üretim yayını tamamlanmış değildir. Önceki 25/50 paket ve
  491 test kayıtları tarihsel sonuçtur; güncel durum bu kayıtla genişletilmiştir.

### Özellik filtresi / export bellek takibi

- Manuel model özellik filtresi ve sınırlı, sürümlü yerel GLB export önbelleği uygulandı; odak paketi 95 test geçti. A5.8 popüler sıralama ve uzak katalog capability metadata kabulü açık kaldığı için bütünü işaretlenmedi.
- Sunum geçişindeki boş ekran yeni iframe contentWindow yaşam döngüsüyle düzeltildi. Yerel web QA’da başlık/gövde/model görünür ve Escape ile içerik korunarak editöre dönülür. Bağımsız web smoke suspend/resume döngüsü Flutter hatası olmadan geçti. A2’nin yetkili kayıt/yavaş ağ birleşik kabulü açıktır.

### Son regresyon ve okunurluk kaydı

Genel baseline 77 dosyada 510 başarılı / 3 değişmeyen golden farkı / 2 atlama.
Sonraki export temizliği 48, okunurluk/kompozisyon/preview 17 odak testiyle
doğrulandı; sonuçlar baseline toplamına eklenmez. Metinle çakışmayan statik
bileşenlerin yanında düz zemin kontrast kontrolü çalışır; belirsiz geometri
ve hareket için renk tahmini yapılmaz. Model verisinin büyük base64 log’u
kaldırıldı; indirme Blob yaşam süresi uzatıldı. HTML dosyasının gerçek teslimi
araçtan henüz doğrulanmadı. İnsan, cihaz, eksik backend ve staging kapıları
açık tutulur; tüm aşamalar tamamlanmış veya yayımlanmış sayılmaz.

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

Arka plan TR arama + ton filtresi gerçek QA18 tarayıcısında doğrulandı;
son yerel release web-final-18 kaynak/build kimliği eşleşiyor.

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
Gerçek web görünüm karşılaştırması ve yeni kaynak release kontrolü sürüyor.
A2.1’in tam HDR/ışık profili ve cihaz/insan kabulü açık kalır.

### Güncel baseline ve pozlama kabulü

79 dosyada 518 başarılı / 3 değişmeyen golden farkı / 2 atlama. QA20 gerçek
tarayıcıda model pozlaması 1.0000 → 1.2000 oldu; sunum ve dönüşte 1.2000
korundu. Editörün ayrı canvas aydınlatma bağlantısı da testle doğrulanır.
Yerel web-final-20 kaynak/build kimliği eşleşiyor. Bu yerel alt adım kabulüdür;
A2/A10 bütün kabul kapıları veya üretim yayını tamamlandı sayılmaz.

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
performans ölçümü ve tam kullanıcı kabulü ayrıca açıktır. Yeni release/genel
baseline kontrolü sürüyor.

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


## 9 Ekim 2026 — GitHub ve Hosting yayını

`8d06ba0` main dalına push edildi; doğrulanmış web-final-34 Firebase Hosting
üzerinden yayımlandı. Önceki canlı sürüm geri dönüş kanalında korunuyor.
Canlı misafir testleri ve CI sonuçları
`tool/development_baseline/CANLI_TEST_RAPORU_2026-10-09.md` dosyasına işlendi.
CI 6 başarısız test içeriyor; hesapla manuel editör/kayıt/export testi ve insan
model kabulü açık. Yayın, bütün aşamaların kabul edildiği anlamına gelmez.
