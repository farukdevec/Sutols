# Sutols Performans Optimizasyon Günlüğü

Başlangıç baseline (2026-08-30 03:54 +03): release `main.dart.js` 7.089.498 bayt, Anıtkabir GLB 4.302.048 bayt; Lighthouse FCP 5.145 ms, Speed Index 8.780 ms, ana iş parçacığı 16.817 ms. Headless ilk rota LCP üretmediği için FPS/1% low, TTI, GPU bellek ve draw-call bu ortamda ölçülemedi. Sanal tur regresyon paketi: 42/42 geçti.

---

## Tur 1 - 2026-08-30 04:00 +03

**Hipotez:** Export turunun boşta da çalışan sürekli rAF/DOM sorgusunu yalnızca klavye veya joystick girdisi varken çalıştırmak ana iş parçacığı yükünü davranışı değiştirmeden azaltır.
**Değişiklik:** `presentation_export_builder.dart` içindeki tur frame döngüsü girdiyle başlatılıp girdi bitince duracak hale getirildi; çıktı sözleşmesi testi eklendi.
**Baseline Metrikler:** Aktif FPS: 60,78; boşta aktif-model sorgusu: 22,88/sn; Bundle: 7.089.498 bayt; Model: 4.302.048 bayt.
**Sonuç Metrikler:** Aktif FPS: 60,27; boşta aktif-model sorgusu: 0/sn (-%100); Bundle: 7.089.801 bayt (+%0,004); Model: 4.302.048 bayt.
**Fonksiyonel Regresyon:** Geçti — 42/42 tur testi, gerçek Chrome klavye hareketi ve konsol kontrolü başarılı; `flutter analyze` yalnız önceden var olan `env_config.dart` eksikliği/uyarılarını bildirdi.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Hareket FPS'i aynı kalırken sunumun boşta çalışan tur döngüsü tamamen kaldırıldı; tekrar denenmemeli.

---

## Tur 2 - 2026-08-30 04:04 +03

**Hipotez:** Aktif yürüyüşte değişmeyen model sınırlarını her karede tekrar almak yerine doğrulanmış sınırları model-viewer başına önbelleğe almak API/GC yükünü azaltır.
**Değişiklik:** Export `constrainTourTarget` için `WeakMap` tabanlı geometri sınırı önbelleği eklendi; geçersiz/yüklenmemiş geometri önbelleğe alınmıyor.
**Baseline Metrikler:** FPS: 60,08; 1% low: 56,82; 3 sn geometri API çağrısı: 724; Bundle: 7.089.801 bayt.
**Sonuç Metrikler:** FPS: 60,03; 1% low: 56,82; 3 sn geometri API çağrısı: 362 (-%50); Bundle: 7.090.501 bayt (+%0,010).
**Fonksiyonel Regresyon:** Geçti — hedef hareketi eşdeğer, frame spike 0 → 0, konsol hatası yok ve 42/42 tur testi geçti.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Vsync FPS'i zaten tavanda; değişmeyen model sınırı çağrılarının yarısı ve bunların geçici nesneleri kaldırıldı.

---

## Tur 3 - 2026-08-30 04:10 +03

**Hipotez:** Önizleme ve geçiş iframe'lerine tüm yerel font CSS'ini gömmek yerine yalnız kullanılan aileleri eklemek belge aktarımını/CSS parse yükünü görsel fark olmadan azaltır.
**Değişiklik:** Tek sayfa ve iki sayfalı geçiş belgeleri mevcut `sutolHtmlStageStylesForPages` filtresini kullanıyor; kullanılan fontun korunduğu test edildi.
**Baseline Metrikler:** Tur belgesi: 238.829 bayt; geçiş belgesi: 244.845 bayt; font-face: 172; Bundle: 7.090.501 bayt; yükleme: 1.693 ms.
**Sonuç Metrikler:** Tur belgesi: 150.261 bayt (-%37,1); geçiş belgesi: 158.341 bayt (-%35,3); font-face: 0; Bundle: 6.919.962 bayt (-%2,4); yükleme: 1.685 ms.
**Fonksiyonel Regresyon:** Geçti — Chrome ekran görüntüsü hash'i birebir aynı, konsol temiz, kullanılan Roboto korundu ve 43/43 tur testi geçti.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Model içeren metinsiz tur iframe'leri 88.568 bayt daha az CSS taşıyor; görsel çıktı değişmedi.

---

## Tur 4 - 2026-08-30 04:12 +03

**Hipotez:** Flutter tur önizlemesinde `_effectivePage` sonucunu build başına bir kez paylaşmak geçici sayfa/model tahsislerini ve frame oluşturma süresini azaltır.
**Değişiklik:** Geçici olarak `_effectivePage` tek yerel değere indirildi; ölçüm sonrası üretim değişikliği geri alındı.
**Baseline Metrikler:** 500 kare medyanı: 240.941 µs; Bundle: 6.919.962 bayt.
**Sonuç Metrikler:** 500 kare medyanı: 246.400 µs (+%2,27 daha yavaş); Bundle: değişmedi (geri alındı).
**Fonksiyonel Regresyon:** Geçti — aktif WASD tur benchmark widget testi tamamlandı.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Azalan küçük nesne tahsisi widget-pump maliyetini iyileştirmedi; bu yöntem ve küçük varyasyonları tekrar denenmemeli.

---

## Tur 5 - 2026-08-30 04:16 +03

**Hipotez:** Ana sayfada kullanılmayan `model-viewer` modülünü ilk gerçek 3B tuvale kadar ertelemek ilk yükleme transferini ve render gecikmesini azaltır.
**Değişiklik:** Eager `<script>` web shell'den kaldırıldı; `HtmlModelCanvas` ilk oluşturulduğunda modülü yalnız bir kez ekleyen lazy loader eklendi.
**Baseline Metrikler:** FCP: 228 ms; DCL: 245,1 ms; Load: 509,2 ms; transfer: 381.201 bayt; Bundle: 6.919.962 bayt.
**Sonuç Metrikler:** FCP: 216 ms (-%5,3); DCL: 219,6 ms (-%10,4); Load: 438,2 ms (-%13,9); transfer: 89.137 bayt (-%76,6); Bundle: 6.920.413 bayt.
**Fonksiyonel Regresyon:** Geçti — 43/43 tur testi, Chrome `HtmlModelCanvas` platform testi ve release build başarılı; ilk rotada model-viewer isteği yok.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** 292.064 baytlık model-viewer modülü yalnız 3B özellik gerçekten açıldığında yükleniyor; çıktı davranışı korunuyor.

---

## Tur 6 - 2026-08-30 04:20 +03

**Hipotez:** Aynı font kombinasyonu için saf sahne CSS sonucunu sınırlı önbellekte tutmak, tekrar belge üretimindeki regex/tahsis maliyetini çıktıyı değiştirmeden azaltır.
**Değişiklik:** Font kombinasyonu anahtarlı, sekiz girişli LRU sahne stili önbelleği eklendi; aynı kombinasyonun aynı dizeyi döndürdüğü test edildi.
**Baseline Metrikler:** 100 belge üretim medyanı: 141,9 ms; Bundle: 6.920.413 bayt.
**Sonuç Metrikler:** 100 belge üretim medyanı: 50,8 ms (-%64,2); Bundle: 6.920.649 bayt (+%0,003).
**Fonksiyonel Regresyon:** Geçti — CSS dizesi birebir aynı, 43/43 tur testi ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Tekrarlanan sahne/iframe üretiminde 89 KB font CSS taraması atlanıyor; önbellek bellek büyümesini engellemek için sekiz girişle sınırlı.

---

## Tur 7 - 2026-08-30 04:27 +03

**Hipotez:** Anıtkabir GLB içindeki yinelenen, bit düzeyinde eşdeğer veri yapılarının kayıpsız tekilleştirilmesi transfer ve GPU yükleme maliyetini görsel/işlevsel değişiklik olmadan azaltır.
**Değişiklik:** Yalnız yapısal `dedup` uygulandı; geometri, texture, animasyon ve sıkıştırma ayarları değiştirilmedi; katalog boyut metadatası güncellendi.
**Baseline Metrikler:** Model: 4.302.048 bayt; GPU upload vertex: 78.702; render vertex: 922.572; Bundle: 6.920.649 bayt.
**Sonuç Metrikler:** Model: 3.627.636 bayt (-%15,7); GPU upload vertex: 73.278 (-%6,9); render vertex: 922.572; Bundle: 6.920.722 bayt.
**Fonksiyonel Regresyon:** Geçti — durağan ve animasyonlu Chrome kare hash'leri birebir aynı; bbox, kamera hedefi, üç animasyon ve konsol çıktısı aynı; 43/43 tur testi ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Kayıpsız accessor/buffer tekilleştirme, çizilen geometriyi değiştirmeden model payload'ından 674.412 bayt kaldırdı.

---

## Tur 8 - 2026-08-30 04:29 +03

**Hipotez:** Tekrarlanan animasyonsuz mesh düğümlerini `EXT_mesh_gpu_instancing` ile işaretlemek draw call yükünü geometriyi değiştirmeden azaltır.
**Değişiklik:** Geçici GLB üzerinde `instance` dönüşümü denendi; araç animasyonlu dosyalarda dönüşümü güvenli bulmayıp uygulamadı, üretim dosyası değişmedi.
**Baseline Metrikler:** Model: 3.627.636 bayt; GPU upload vertex: 73.278; render vertex: 922.572.
**Sonuç Metrikler:** Model: 3.627.636 bayt; GPU upload vertex: 73.278; render vertex: 922.572 (iyileşme yok).
**Fonksiyonel Regresyon:** Geçti — üretilen dosya metrikleri/gerekli uzantıları değişmedi; üretim değişikliği yapılmadı.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Animasyonlu düğümleri elle ayıran varyasyonlar davranış riski taşıyor; GPU instancing bu modelde yeniden denenmemeli.

---

## Tur 9 - 2026-08-30 04:36 +03

**Hipotez:** Mesh indeks/vertex sırasını GPU post-transform önbellek yerelliğine göre kayıpsız düzenlemek vertex shader tekrarlarını azaltır.
**Değişiklik:** Anıtkabir GLB'ye `reorder --target performance` uygulandı; katalog boyut ve SHA-256 metadatası güncellendi.
**Baseline Metrikler:** Cache-16 miss: 535.608 (ACMR 1,742); Model: 3.627.636 bayt; Bundle: 6.920.722 bayt.
**Sonuç Metrikler:** Cache-16 miss: 482.536 (-%9,9, ACMR 1,569); Model: 3.631.196 bayt (+%0,10); Bundle: 6.920.722 bayt.
**Fonksiyonel Regresyon:** Geçti — bbox/kamera/animasyon aynı; sabit karede yalnız 3/480.000 piksel raster gürültüsü (ortalama kanal farkı 0,00001); 43/43 tur testi ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** 3,6 KB transfer bedeli karşılığında küçük GPU cache'lerde yaklaşık %10 daha az vertex yeniden işleme bekleniyor; veri değerleri değiştirilmedi.

---

## Tur 10 - 2026-08-30 04:40 +03

**Hipotez:** GLB içindeki iki PNG roughness texture'ını kayıpsız PNG filtre/deflate optimizasyonuyla yeniden paketlemek görsel çıktıyı değiştirmeden transferi azaltır.
**Değişiklik:** Yalnız PNG kapsayıcı sıkıştırması optimize edildi; çözümlenen RGBA pikselleri, geometri ve animasyon verileri değiştirilmedi; boyut/SHA-256 metadatası güncellendi.
**Baseline Metrikler:** Model: 3.631.196 bayt; iki PNG: 380.821 bayt; Cache-16 miss: 482.536; Bundle: 6.920.722 bayt.
**Sonuç Metrikler:** Model: 3.507.628 bayt (-%3,40); iki PNG: 257.256 bayt (-%32,4); Cache-16 miss: 482.536; Bundle: 6.920.722 bayt.
**Fonksiyonel Regresyon:** Geçti — 2×512×512 texture'da 0 farklı RGBA kanal; bbox/kamera/animasyon aynı; 43/43 tur testi ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Palette/deflate kodlaması 123.568 bayt kaldırırken shader'a ulaşan texture pikselleri bit düzeyinde aynı kaldı.

---

## Tur 11 - 2026-08-30 05:05 +03

**Hipotez:** Export reveal-step sayacında birleştirilmiş geçici liste ve `where` tahsislerini iki doğrudan döngüyle kaldırmak export üretimini hızlandırır.
**Değişiklik:** Yalnız `_revealStepCountForPage` içinde click animasyonu sayımı geçici liste yerine iki döngüyle denendi; üretim kodu ölçüm sonrası geri alındı.
**Baseline Metrikler:** 40×30 sayfalı export benchmark ortalaması: 9.104 ms; çıktı: 111.332.040 bayt.
**Sonuç Metrikler:** 40×30 benchmark ortalaması: 9.116 ms (+%0,1 daha yavaş); çıktı: 111.332.040 bayt.
**Fonksiyonel Regresyon:** Geçti — çıktı boyutu aynı; yeni üretim değişikliği korunmadı.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Bu küçük tahsis azaltımı ölçüm gürültüsü içinde fayda üretmedi; reveal-step hesabında yeniden denenmemeli.

---

## Tur 12 - 2026-08-30 05:10 +03

**Hipotez:** Export sıkıştırmasında her çağrıda aynı üç regex'i yeniden derlemek yerine değişmez regex nesnelerini paylaşmak üretim süresini azaltır.
**Değişiklik:** `_compactHtml` regex'leri dosya düzeyinde paylaşıldı; çıktı ve export testleri doğrulandı, ölçüm sonrası üretim değişikliği geri alındı.
**Baseline Metrikler:** 40×30 sayfalı export benchmark ortalaması: 9.104 ms; çıktı: 111.332.040 bayt.
**Sonuç Metrikler:** Benchmark üç koşuda: 9.298, 9.288, 9.515 ms; çıktı: 111.332.040 bayt (baseline'dan yaklaşık %2,9 daha yavaş).
**Fonksiyonel Regresyon:** Geçti — export testleri 5/5; yeni hata yok.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Regex derleme paylaşımı bu export senaryosunda ölçülebilir kazanım vermedi; tekrar denenmemeli.

---

## Tur 13 - 2026-08-30 05:15 +03

**Hipotez:** Model indeksinde normalize edilmiş etiket ve isim kelimelerini önceden saklamak, her model skorlamasında tekrar `split` maliyetini kaldırır.
**Değişiklik:** `_IndexedModel` içine önceden bölünmüş isim/etiket kelimeleri eklendi; eşleşme sonuçları aynı kaldı, ölçüm sonrası üretim kodu geri alındı.
**Baseline Metrikler:** 20×240 model benchmark ortalaması: 731,1 ms; toplam eşleşme: 4.800.
**Sonuç Metrikler:** Üç koşu: 746,3 / 742,9 / 743,0 ms; toplam eşleşme: 4.800 (yaklaşık %1,8 daha yavaş).
**Fonksiyonel Regresyon:** Model eşleştirme testleri geçti; keyword test paketi mevcut `güneş paneli` beklentisinde başarısız oldu.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Bu indeks tahsisi, skorlamadaki kazancı aşarak benchmark’ı yavaşlattı; aynı kelime önbellekleme varyasyonu yeniden denenmemeli.

---

## Tur 14 - 2026-08-30 05:20 +03

**Hipotez:** Stage patch sonunda yapılan toplu `fitAllText` zaten tüm metinleri ölçtüğü için `patchElement` içindeki tekil `fitText` çağrısı kaldırılabilir.
**Değişiklik:** Yalnız tekil fit çağrısı geçici olarak kaldırıldı; export testi geçti, Chrome frame ölçümü ortamda tamamlanamadı ve değişiklik geri alındı.
**Baseline Metrikler:** Release `main.dart.js`: 7.002.709 bayt; 5/5 export testi geçti.
**Sonuç Metrikler:** Release `main.dart.js`: 7.002.559 bayt (-150 bayt, -%0,002); Chrome patch/frame metriği alınamadı.
**Fonksiyonel Regresyon:** Export testi geçti; görsel eşdeğerlik ölçülemediği için kabul edilmedi.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Dört ardışık aday anlamlı ölçülebilir kazanım vermedi; promptun durma koşulu uygulandı.

---

## Tur 15 - 2026-08-30 05:42 +03

**Hipotez:** Büyük `assets/images/logo.png` dosyasını kayıpsız PNG filtre/DEFLATE optimizasyonuyla yeniden paketlemek uygulama transferini azaltır.
**Değişiklik:** Asset bildirimi ve release manifesti ölçüldü; dosyanın uygulamaya dahil edilmediği görüldüğü için üretim dosyasına dokunulmadı.
**Baseline Metrikler:** Kaynak PNG: 1.734.427 bayt; release manifestindeki PNG kaydı: 0; runtime transfer katkısı: 0 bayt.
**Sonuç Metrikler:** Bundle/asset transferi değişmedi; ölçülebilir çalışma zamanı kazanımı yok.
**Fonksiyonel Regresyon:** Geçti — kaynak ve üretim kodu değiştirilmedi.
**Karar:** REDDEDİLDİ (değişiklik uygulanmadı)
**Not/Ders:** Yalnız WebP logo bildiriliyor ve kullanılıyor; manifest dışındaki PNG'yi optimize etmek repo boyutu dışında uygulama performansına etki etmiyor.

---

## Tur 16 - 2026-08-30 05:45 +03

**Hipotez:** Bayt düzeyinde aynı olan yerel 400/700 WOFF2 dosyalarını tek URL'de birleştirmek font transferini ve deploy boyutunu görsel fark olmadan azaltır.
**Değişiklik:** SHA-256'sı aynı 63 adet 700 dosyasının CSS yerel kaynağı karşılık gelen 400 dosyasına yönlendirildi, kopyalar kaldırıldı ve font indirme aracı aynı içeriği yeniden üretmeyecek biçimde güncellendi.
**Baseline Metrikler:** 178 WOFF2: 5.985.664 bayt; yinelenen içerik: 2.570.188 bayt; release font paketi: 5.985.664 bayt.
**Sonuç Metrikler:** 115 WOFF2: 3.415.476 bayt (-%42,9); yinelenen hash grubu: 0; release `main.dart.js`: 7.002.709 bayt (değişmedi).
**Fonksiyonel Regresyon:** Geçti — 172 CSS yerel kaynağının tamamı mevcut, 80 adet 700 yüzü korunuyor, kaldırılan her dosya canonical dosyayla bit düzeyinde aynı; 41/41 ilgili test ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Font glif/veri ve CSS weight sözleşmesi değişmeden deploy/önbellek yükünden 2.570.188 bayt kaldırıldı; ortak yüzlerde 400+700 ağ isteği tek kaynakta birleşiyor.

---

## Tur 17 - 2026-08-30 05:46 +03

**Hipotez:** Runtime tarafından okunmayan güzel şablon kaynak klasörünü Flutter asset manifestinden çıkarmak deploy boyutunu azaltır.
**Değişiklik:** Manifest kapsamı ve release çıktısı ölçüldü; Flutter dizin bildiriminin alt klasörleri değil yalnız iki kök dosyayı paketlediği görüldü, üretim değişikliği uygulanmadı.
**Baseline Metrikler:** Release toplamı: 56.584.066 bayt; paketlenen aday: 2 dosya / 55.798 bayt.
**Sonuç Metrikler:** Öngörülen toplam küçülme yalnız 55.798 bayt (-%0,099); `%3` kabul eşiğinin altında.
**Fonksiyonel Regresyon:** Geçti — kaynak, manifest ve üretim çıktısı değiştirilmedi.
**Karar:** REDDEDİLDİ (değişiklik uygulanmadı)
**Not/Ders:** Flutter klasör asset bildirimi recursive değil; kaynak kitaplık 3,54 MB olsa da release'e yalnız 55,8 KB giriyor, bu nedenle manifest varyasyonları yeniden denenmemeli.

---

## Tur 18 - 2026-08-30 05:48 +03

**Hipotez:** İlk rota/manifest tarafından kullanılan favicon PNG'lerini kayıpsız yeniden kodlamak ağ transferini azaltır.
**Değişiklik:** 64, 192 ve 512 piksel faviconlar geçici dizinde PNG olarak yeniden kodlandı; üretim dosyaları değiştirilmedi.
**Baseline Metrikler:** 64 px: 8.217 bayt; 192 px: 49.869 bayt; 512 px: 268.619 bayt.
**Sonuç Metrikler:** Sırasıyla 8.204 / 49.856 / 268.606 bayt; en iyi kazanç 13 bayt ve `%0,16` altında.
**Fonksiyonel Regresyon:** Geçti — deneme yalnız geçici dosyalarda yapıldı; üretim çıktısı değişmedi.
**Karar:** REDDEDİLDİ (değişiklik uygulanmadı)
**Not/Ders:** Mevcut favicon PNG'leri zaten etkin sıkıştırılmış; aynı yeniden kodlama veya küçük codec ayarı varyasyonları `%3` eşiğine ulaşamaz.

---

## Tur 19 - 2026-08-30 05:50 +03

**Hipotez:** Üretilen 1.027 HTML bileşenindeki yalnız sunumsal whitespace/girintiyi güvenle sıkıştırmak ana JS bundle'ını anlamlı ölçüde küçültür.
**Değişiklik:** Etiket arası whitespace ve satır girintisi varyasyonları salt okunur olarak ölçüldü; script/preformatted içeriğe girmeyen güvenli sınırda üretim değişikliği uygulanmadı.
**Baseline Metrikler:** Katalog kaynağı: 2.099.087 bayt; release `main.dart.js`: 7.002.709 bayt; HTML içeriği: 1.466.312 karakter.
**Sonuç Metrikler:** Güvenli etiket arası kazanç: 36.294 bayt; girinti dahil üst sınır: 84.918 bayt / bundle'ın teorik `%1,21`'i.
**Fonksiyonel Regresyon:** Geçti — üretim kodu ve HTML çıktısı değiştirilmedi.
**Karar:** REDDEDİLDİ (değişiklik uygulanmadı)
**Not/Ders:** `%3` için script/CSS minification gerekirdi; bu varyasyonlar JS veya preformatted whitespace semantiği taşıyabildiğinden görsel/davranış eşdeğerliği garanti edilemiyor.

---

## Tur 20 - 2026-08-30 05:52 +03

**Hipotez:** Enum ile aynı sıradaki 1.051 bileşen tanımını hash-map yerine `kind.index` ile doğrudan listeden okumak lookup CPU/heap maliyetini çıktı değişmeden azaltır.
**Değişiklik:** `_presentationComponentDefinitionByKind` kaldırıldı; erişim `presentationComponentDefinitions[kind.index]` oldu ve üretici araç aynı çıktıyı kalıcı üretecek şekilde güncellendi.
**Baseline Metrikler:** 5 milyon karışık lookup medyanı: 14.597 µs; release `main.dart.js`: 7.002.709 bayt.
**Sonuç Metrikler:** Ayrı süreç medyanları: 10.268 / 10.096 / 9.869 µs; en muhafazakâr kazanç -%29,7; bundle: 7.002.572 bayt (-137 bayt).
**Fonksiyonel Regresyon:** Geçti — 1.051/1.051 enum-tanım hizası doğrulandı; component/editor/codec/export/tur paketinde 75/75 test ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Davranış ve HTML dizeleri birebir kalırken her bileşen erişimindeki hash hesabı ve 1.051 girişli lookup map tahsisi kaldırıldı.

---

## Tur 21 - 2026-08-30 05:55 +03

**Hipotez:** 1.051 dallı bileşen DOM-adı switch'ini enum indeksli sabit dize listesine çevirmek lookup ve bundle maliyetini aynı çıktı ile azaltır.
**Değişiklik:** `presentationComponentDomName` switch yerine `_presentationComponentDomNames[kind.index]` kullanıyor; üretici araç aynı temsili kalıcı üretiyor.
**Baseline Metrikler:** 1 milyon karışık lookup medyanı: 893.842 µs; generated kaynak: 2.082.020 karakter; bundle: 7.002.572 bayt.
**Sonuç Metrikler:** Ayrı süreç medyanları: 13.680 / 13.096 / 13.088 µs (en muhafazakâr -%98,47); kaynak -61.421 karakter; bundle: 6.986.867 bayt (-15.705).
**Fonksiyonel Regresyon:** Geçti — 1.051/1.051 DOM adı enumdan türetilen beklenen değerle aynı; component/editor/codec/export/tur paketinde 76/76 test ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Büyük enum switch'i Dart VM'de beklenenden pahalıydı; indeksli const tablo çıktıyı korurken lookup'u yaklaşık 65 kat hızlandırdı.

---
