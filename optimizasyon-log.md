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
