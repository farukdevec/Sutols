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

## Tur 22 - 2026-08-30 05:57 +03

**Hipotez:** Değişmez bileşen alt başlıklarını her widget rebuild'inde `take(4).join` ile üretmek yerine enum başına tembel önbelleğe almak CPU/GC maliyetini azaltır.
**Değişiklik:** En fazla 1.051 nullable slot kullanan `_presentationComponentSubtitles` eklendi; her alt başlık ilk erişimde aynı tags/description kuralıyla üretilip tekrar kullanılıyor.
**Baseline Metrikler:** 100 bin karışık alt başlık erişimi medyanı: 19.027 µs; bundle: 6.986.867 bayt.
**Sonuç Metrikler:** Ayrı süreç medyanları: 1.615 / 1.461 / 1.393 µs (en muhafazakâr -%91,5); bundle: 6.986.867 bayt (değişmedi).
**Fonksiyonel Regresyon:** Geçti — 1.051/1.051 sonuç orijinal tags/description hesabıyla aynı; component/editor/codec/export/tur paketinde 77/77 test ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Kart grid'i tekrar çizildiğinde aynı join dizeleri ve ara iterable'lar yeniden üretilmiyor; önbellek katalog boyutuyla sabit sınırlı.

---

## Tur 23 - 2026-08-30 06:01 +03

**Hipotez:** Editör bileşen panelinde değişmez 1.051 tanımı her build'de map/list/sort ile yeniden hazırlamak yerine bir kez sıralayıp paylaşmak frame CPU/GC maliyetini azaltır.
**Değişiklik:** Eski algoritmanın birebir sonucunu unmodifiable listede tutan `presentationComponentDefinitionsSortedByLabel` eklendi; panel build'i bu listeyi kullanıyor.
**Baseline Metrikler:** 100 katalog hazırlama medyanı: 529.855 µs; bundle: 6.986.867 bayt.
**Sonuç Metrikler:** 100 önbellek erişimi medyanı: 5 µs (-%99,999); bundle: 6.987.017 bayt (+150 bayt).
**Fonksiyonel Regresyon:** Geçti — 1.051 kimliğin sırası eski map+sort algoritmasıyla birebir aynı; component/editor/codec/export/tur paketinde 78/78 test ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Arama yazımı ve panel rebuild'lerinde yaklaşık 5,3 ms'lik değişmez katalog hazırlığı ile ilgili geçici map/list/string tahsisleri kaldırıldı.

---

## Tur 24 - 2026-08-30 06:03 +03

**Hipotez:** Kökü array olan geçerli sunum JSON'unu map ve list için iki kez decode etmek yerine tek decode sonucunu tipe göre yönlendirmek parse süresini azaltır.
**Değişiklik:** 30 slaytlık array-root payload üzerinde tek-decode yolu geçici olarak uygulandı; ölçüm eşiği aşılmadığı için üretim kodu ve benchmark geri alındı.
**Baseline Metrikler:** 100 parse medyanı: 72.692 µs.
**Sonuç Metrikler:** Ayrı süreç medyanları: 71.573 / 70.414 / 68.327 µs; en muhafazakâr kazanç yalnız `%1,54`.
**Fonksiyonel Regresyon:** Geçti — benchmark çıktısı 30/30 slaytı korudu; üretim değişikliği tamamen geri alındı.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Array decode tekrarı toplam normalize/temizleme maliyetinin küçük bölümü; aynı decode-birleştirme varyasyonları `%3` eşiğini güvenilir geçmiyor.

---

## Tur 25 - 2026-08-30 06:06 +03

**Hipotez:** `tryParsePresentationPayload` içinde parse aşamasında zaten temizlenmiş payload'ı ikinci kez kopyalayıp temizlemeyi kimlik işaretiyle atlamak CPU/GC maliyetini azaltır.
**Değişiklik:** `_cleanAllContent` çıktıları zayıf `Expando` işareti alıyor; try-parse işaretli sonucu doğrulama sonrası doğrudan döndürüyor, işaretsiz kurtarma yollarını eskisi gibi temizliyor.
**Baseline Metrikler:** 30 slaytlı map için 100 doğrulanmış parse medyanı: 125.043 µs; bundle: 6.987.017 bayt.
**Sonuç Metrikler:** Ayrı süreç medyanları: 69.131 / 68.113 / 67.650 µs (en muhafazakâr -%44,7); bundle: 6.987.202 bayt (+185).
**Fonksiyonel Regresyon:** Geçti — 11/11 parser testi ve yeni çıktı eşitliği testi geçti; geniş pakette 105/106 geçti, Tur 13'ten beri mevcut solar-photon→optics beklenti hatası izole iki koşuda da değişmeden kaldı; release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Payload şeması/değeri değişmeden normal doğrulanmış parse yolundaki ikinci 30-slidelık map/list temizleme ve kopyalama geçişi kaldırıldı.

---

## Tur 26 - 2026-08-30 06:07 +03

**Hipotez:** Web geçiş iframe'inin fallback ve load yollarından gelebilen çift `onReady` bildirimini tekilleştirmek yinelenen geçiş işini azaltır.
**Değişiklik:** Üretici ve tüketici kontrol akışı incelendi; zamanlamayı değiştirecek üretim değişikliği uygulanmadı.
**Baseline Metrikler:** Olası callback teslimi: 2; `_startLoadedTransition` animasyon başlatma: 1; ikinci çağrı `isAnimating` nedeniyle no-op.
**Sonuç Metrikler:** Tekilleştirmede callback 1 olsa da animasyon/frame/re-render sayısı 1→1; ölçülebilir uygulama kazanımı yok.
**Fonksiyonel Regresyon:** Geçti — kod değiştirilmedi; mevcut fallback ve yükleme zamanlaması korundu.
**Karar:** REDDEDİLDİ (değişiklik uygulanmadı)
**Not/Ders:** Tüketici zaten idempotent; fallback'i geciktirmek veya kaldırmak iframe hazır olma davranışını değiştireceğinden bu varyasyonlar denenmemeli.

---

## Tur 27 - 2026-08-30 06:15 +03

**Hipotez:** Proje yüklenirken her bileşen türünü 1.051 üyeli enum listesinde doğrusal aramak yerine değişmez ad→enum indeksi kullanmak büyük proje decode CPU maliyetini azaltır.
**Değişiklik:** `PresentationComponentKind` adları bir kez `asNameMap()` ile indekslendi; bileşen çözümleme aynı varsayılan değeri koruyan doğrudan map lookup kullanıyor.
**Baseline Metrikler:** 240 bileşenli projeyi 100 kez decode etme ayrı süreç ölçümleri: 80.344 / 80.190 / 81.397 µs; medyan: 80.344 µs; release `main.dart.js`: 6.987.202 bayt.
**Sonuç Metrikler:** Ayrı süreç ölçümleri: 36.796 / 36.358 / 36.994 µs; medyan: 36.796 µs (-%54,2); bundle: 6.987.370 bayt (+168 bayt, +%0,0024).
**Fonksiyonel Regresyon:** Geçti — 1.051/1.051 bileşen türü ve bilinmeyen türün `edebiyat01` geri dönüşü doğrulandı; seçili codec/controller/export/3B/tur paketinde 74/74 test ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Büyük katalogda doğrusal isim taraması proje dosyasındaki her bileşen için tekrarlanıyordu; sabit indeks çıktıyı korurken benchmark süresini yarıdan fazla düşürdü.

---

## Tur 28 - 2026-08-30 18:52 +03

**Hipotez:** Otomatik bileşen eşleştirmesinde aynı slayt başlık/gövde metnini her katalog anahtar sözcüğü için tekrar parçalamak yerine çağrı başına bir kez tokenlaştırmak CPU/GC maliyetini azaltır.
**Değişiklik:** Başlık ve gövdenin tam/önemli kelime listeleri eşleştirme çağrısı başında bir kez üretilip mevcut aynı `wordsMatch` ve puanlama kurallarına aktarıldı; altı temalı sonuç için deterministik benchmark/golden testi eklendi.
**Baseline Metrikler:** 12 eşleştirme için ayrı süreç medyanları: 1.139.182 / 1.154.659 / 1.132.963 µs; checksum: 2.314; release `main.dart.js`: 6.987.370 bayt.
**Sonuç Metrikler:** Ayrı süreç medyanları: 182.571 / 188.649 / 187.494 µs; süreç medyanlarının medyanı 187.494 µs (-%83,5); checksum: 2.314; bundle: 6.987.717 bayt (+347, +%0,005).
**Fonksiyonel Regresyon:** Geçti — golden sonuçlar birebir aynı; ilgili geniş pakette değişiklik ve temiz `HEAD` aynı 70/79 sonucu verdi (9 mevcut hata); hedefli analiz temiz ve release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Katalog indeksini büyütmeden yalnızca tek skor çağrısındaki değişmez giriş tokenlarını paylaşmak, eşleştirme sonucunu korurken ölçülen CPU süresini yaklaşık altıda bire indirdi.

---

## Tur 29 - 2026-08-30 19:05 +03

**Hipotez:** Editör bileşen aramasında 1.051 değişmez tanımın metin alanlarını her tuş vuruşunda yeniden küçük harfe çevirmek yerine enum indeksli arama terimlerini bir kez hazırlamak arama CPU/GC maliyetini azaltır.
**Değişiklik:** Etiket, kategori, açıklama ve tag alanlarının küçük harfli karşılıkları sınırlı bir indeksle paylaşıldı; aynı alan-bazlı `contains` ve alfabetik sıra korundu, üretici araç ve birebir kimlik karşılaştırmalı benchmark güncellendi.
**Baseline Metrikler:** 800 arama için ayrı süreç medyanları: 1.532.025 / 1.568.279 / 1.562.848 µs; checksum: 123.747; release `main.dart.js`: 6.987.717 bayt.
**Sonuç Metrikler:** Ayrı süreç medyanları: 465.806 / 442.695 / 448.928 µs; süreç medyanlarının medyanı 448.928 µs (-%71,3); checksum: 123.747; bundle: 6.988.182 bayt (+465, +%0,0067).
**Fonksiyonel Regresyon:** Geçti — arama/katalog 6/6 ve sorgu kimlikleri birebir aynı; geniş paket öncekiyle aynı 70/79, editor paketi 9 mevcut hata ve izole tekrarda geçen bir zamanlama flake'i dışında aynı; release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Sıralamayı veya eşleşme sınırlarını değiştirmeden değişmez UI arama alanlarını paylaşmak, tekrar eden lowercase tahsislerini kaldırıp ölçülen süreyi yaklaşık üçte bire indirdi.

---

## Tur 30 - 2026-08-30 19:08 +03

**Hipotez:** Otomatik eşleştirme normalde tek bileşen istediği için tüm uygun adayları listeleyip sıralamak yerine aynı skor/label kuralıyla tek kazananı akış içinde tutmak CPU ve tahsis maliyetini azaltır.
**Değişiklik:** `maxComponents == 1` yolunda geçici tek-kazanan seçimi denendi; çoklu seçim yolu korunarak ölçüldü ve eşik aşılmadığı için üretim kodu tamamen geri alındı.
**Baseline Metrikler:** 12 eşleştirme için ayrı süreç medyanları: 275.519 / 258.164 / 266.653 µs; süreç medyanlarının medyanı 266.653 µs; checksum: 2.314.
**Sonuç Metrikler:** Ayrı süreç medyanları: 274.299 / 270.286 / 266.500 µs; süreç medyanlarının medyanı 270.286 µs (+%1,4 daha yavaş); checksum: 2.314.
**Fonksiyonel Regresyon:** Geçti — altı golden eşleşme ve checksum birebir aynı; üretim değişikliği geri alındı.
**Karar:** REDDEDİLDİ (geri alındı)
**Not/Ders:** Aday sıralama maliyeti toplam 1.051 tanımlı skorlamanın küçük bir bölümü; tek-kazanan dalı eklemek sıcak döngüyü iyileştirmedi ve yeniden denenmemeli.

---

## Tur 31 - 2026-08-30 19:10 +03

**Hipotez:** Yoğun eşleştirme yollarında ASCII kelime ayrıştırmasını regex `split` ve iterable filtre yerine aynı `[a-z0-9]` sınırlarını tarayan tek geçişle yapmak CPU/GC maliyetini azaltır.
**Değişiklik:** `PresentationKeywordCatalog.words` doğrudan code-unit taramasına geçirildi; boş ayraçları atlama ve sabit uzunluklu liste sözleşmesi korundu, altı farklı giriş için deterministik golden/benchmark eklendi.
**Baseline Metrikler:** 60.000 tokenizasyon medyanları: 168.876 / 169.552 / 156.569 µs; uçtan uca 12 eşleştirme süreç medyanı: 266.653 µs; checksumlar: 1.070.000 / 2.314; bundle: 6.988.182 bayt.
**Sonuç Metrikler:** Tokenizasyon medyanları: 10.198 / 9.681 / 9.925 µs; süreç medyanlarının medyanı 9.925 µs (-%94,1); eşleştirme 103.363 µs (-%61,2); checksumlar aynı; bundle: 6.988.221 bayt (+39).
**Fonksiyonel Regresyon:** Geçti — hedefli analiz temiz; model/golden 3/3, tur-kamera-geçiş 16/16 ve FPS kontrolü geçti; geniş paket yeni test dahil 71/80 ile aynı 9 mevcut hatayı verdi; release build başarılı.
**Karar:** KABUL EDİLDİ (commit)
**Not/Ders:** Basit ASCII sözleşmesinde genel regex motoru baskın maliyetti; eşdeğer doğrudan tarama tokenizerı yaklaşık 17 kat, bileşen eşleştirmeyi yaklaşık 2,6 kat hızlandırdı.

---
