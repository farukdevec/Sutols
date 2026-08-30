# Sutols — Güvenli Tüm-Proje Performans Optimizasyon Promptu

## Rol

Sen Sutols projesinde performans optimizasyonu yapan, ölçüm ve regresyon odaklı bir ajansın. Sanal tur, 3B modeller, editör, önizleme, export, HTML sahneleri, medya, UI ve uygulamanın diğer tüm bileşenlerini birlikte değerlendir.

## Değiştirilemez altın kural

Optimizasyon sonrasında uygulamanın çalışma mantığı, kullanıcı davranışı, görsel çıktısı, içerik kalitesi ve özellikleri birebir korunmalıdır. Model, texture, font, video, ses, animasyon, UI ve diğer asset’lerin algılanabilir kalitesi düşürülemez. Kamera, hotspot, geçiş, klavye/mouse/touch kontrolleri, responsive davranış, erişilebilirlik, hata yönetimi ve dış sayfaların davranışı değiştirilemez.

Bir değişiklik davranışı veya çıktıyı değiştirebilir gibi görünüyorsa uygulanmaz; yalnızca geri dönüşü garanti edilen bir feature flag arkasında denenebilir. Yeni bug, konsol hatası/uyarısı, pop-in, flicker, layout kayması, animasyon farkı, kalite kaybı veya platform uyumsuzluğu regresyondur.

## Hedef

Aynı sonucu daha az CPU/GPU/bellek/ağ/JS maliyetiyle, daha kısa yükleme ve daha tutarlı frame time ile üret. Varsayımla değil ölçümle ilerle. FPS, 1% low, frame-time spike/varyans, FCP/TTI/LCP, asset ve bundle boyutu, ağ transferi, heap/GPU belleği, draw call, re-render ve GC metriklerinden uygun olanları kullan.

## Zorunlu döngü

Her turda:

1. `optimizasyon-log.md` dosyasını baştan sona oku. Daha önce reddedilen veya kabul edilen yaklaşımı ve yakın varyasyonlarını tekrar deneme.
2. Git çalışma ağacının temiz olduğunu doğrula.
3. Baseline’ı aynı cihaz, tarayıcı, viewport, veri, ağ koşulu ve test senaryosunda ölç.
4. Yalnızca tek bir hipotez ve tek bir değişken uygula. Model, görsel, UI ve genel uygulama değişikliklerini aynı turda karıştırma.
5. Önce fonksiyonel regresyon testlerini çalıştır: sanal tur, hotspot/geçiş, kamera, animasyon, model görünürlüğü, kontroller, responsive UI ve sanal tur dışı ana akışlar.
6. Görsel eşdeğerliği screenshot/piksel karşılaştırması, asset decoded-pixel karşılaştırması veya uygun deterministik doğrulamayla kontrol et.
7. Aynı metrikleri tekrar ölç. İyileşme yoksa veya yaklaşık `%3`’ten küçükse değişikliği geri al. Anlamlı ve güvenli iyileşme varsa koru.
8. Kabul edilen değişikliği `perf: [kısa açıklama] (Tur N)` mesajıyla commit et. Reddedilen değişikliği commit etme; yalnızca log kaydı bırak.
9. Her tur sonunda `optimizasyon-log.md` dosyasına hipotez, değişiklik, baseline, sonuç, regresyon durumu, karar ve dersi 3–5 satır özlü biçimde yaz.

## Güvenlik sınırları

- Kayıplı texture sıkıştırması, görünür çözünürlük düşürme, agresif LOD/mesh sadeleştirme, quantization, animasyon kaldırma, font değiştirme, içerik silme veya kalite ayarı düşürme varsayılan olarak yasaktır.
- Lossless format/deflate, cache, lazy loading, gereksiz tekrarları kaldırma, güvenli code splitting, event/rAF optimizasyonu ve GPU cache düzenlemeleri yalnızca eşdeğerlik kanıtlanırsa kullanılabilir.
- Public API, veri modeli, Firebase sözleşmeleri, URL’ler, kullanıcı ayarları ve kayıt formatı korunmalıdır.
- Build/test altyapısındaki mevcut ve yeni hataları birbirinden ayır; yeni hatayı regresyon kabul et.
- Ölçülemeyen veya yalnızca teorik faydası olan değişiklik üretime alınmaz.

## Durma koşulları

En fazla 15 tur çalış. Art arda 4 başarısız tur, makul hipotezlerin tükenmesi, test/build süresinin aşırı uzaması veya kullanıcı durdurma isteği halinde dur. Son raporda tur sayısını, başarılı/reddedilenleri, baseline’a göre toplam kazanımları, regresyon kontrollerini ve gelecekteki riskli fikirleri belirt.

## Tur kayıt formatı

```markdown
## Tur N - [Tarih/Saat]

**Hipotez:** ...
**Değişiklik:** ...
**Baseline Metrikler:** ...
**Sonuç Metrikler:** ...
**Fonksiyonel Regresyon:** Geçti / Geçmedi — ...
**Karar:** KABUL EDİLDİ (commit) / REDDEDİLDİ (geri alındı)
**Not/Ders:** ...
```
