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
