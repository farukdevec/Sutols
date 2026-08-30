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
