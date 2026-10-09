# Sutols A0 — Başlangıç ve teknik borç raporu

Tarih: 8 Ekim 2026. Başlangıç commit'i: `f673c0411ae752e35da967314cffba756e4177da`.

## Ürünün amacını koruma

Sutols'un amacı metin/konudan sunum üretmek, düzenlemek, uygun 3B/2B görsellerle anlatımı güçlendirmek ve sunumu paylaşmak/dışa aktarmaktır. Bu oturumda `lib/`, `web/`, katalog, sahne, AI yönlendirme ve proje şeması değiştirilmedi. Mevcut Firebase cache değişikliği korundu. Deployment ve GitHub push yapılmadı.

## Tamamlanan başlangıç işleri

- A0.1: Commit, çalışma alanı ve araç sürümleri kaydedildi. Flutter 3.38.9, Dart 3.10.8, Node 25.6.0; functions paketi Node 24 istiyor. SDK yükseltmesi yapılmadı.
- A0.2: 60 kontrollü test dosyası çalıştırıldı. Gerçek üretim servislerine bağlı altı dosya açık listeyle ayrı tutuldu; başarısızlıklar silinmedi veya başarılı sayılmadı.
- A0.5: `test/probe_grok.dart` içindeki eksik `EnvConfig` bağımlılığı kaldırıldı. Anahtar süreç ortamından alınır; test açık opt-in olmadan veya anahtar olmadan gerekçesiyle atlanır. HTTP hata/istisnasını gizlemez; istemciyi kapatır.
- Tekrarlanabilir kontrol aracı: `tool/run_development_baseline.py`. Test, analiz ve functions tip kontrolünü raporlar; hata varsa sıfır olmayan exit code üretir.
- Kurulum/test kılavuzu: `tool/development_baseline/README.md`.
- Ayrı klasöre yerel web build başarıyla üretildi; mevcut `build/web` üzerine yazılmadı.
- Tam kaynak geçmişi Git bundle olarak yedeklendi ve doğrulandı. Mevcut eski sürüm regression testinden V1 proje fixture'ı korundu. Bu gerçek kullanıcı sunumu veya üretim yayınının doğrulanmış birebir yedeği değildir.

## Doğrulama sonuçları

| Kontrol | Sonuç |
|---|---|
| Kontrollü Flutter testleri | 412 başarılı, 29 başarısız (14 failure + 15 error), 2 atlanan |
| Ayrı tutulan üretim test dosyaları | 6; başarısız/başarılı sayılmadı |
| Flutter analiz | 0 hata; 8 uyarı + 1 bilgi. Uyarılar nedeniyle exit code 1 |
| Grok probe, opt-in kapalı | Açık gerekçeyle atlandı; dış servise çağrı yapılmadı |
| Functions TypeScript | 15 mevcut TypeScript tanısı; derleme başarılı değil |
| Flutter web release build | Başarılı; yaklaşık 99 saniye |
| Kaynak davranış değişikliği | `git diff -- lib web` boş |

Build, CupertinoIcons font ailesinin bulunamadığına dair mevcut bir uyarı veriyor. Bu oturumda yeni font/paket eklenmedi. GPU/frame ölçümü henüz yapılmadı; hızlanma veya enerji tasarrufu iddiası yok.

## Başarısız testlerin dosya bazında dağılımı

| Dosya | Başarısız test olayı |
|---|---|
| `ai_routing_test.dart` | 3 |
| `auth_page_visual_test.dart` | 1 |
| `editor_golden_test.dart` | 2 |
| `editor_responsive_test.dart` | 12 |
| `language_controller_test.dart` | 1 |
| `model_catalog_cache_test.dart` | 1 |
| `presentation_auto_builder_test.dart` | 1 |
| `presentation_background_library_test.dart` | 5 |
| `presentation_deck_builder_test.dart` | 1 |
| `presentation_keyword_catalog_test.dart` | 1 |
| `presentation_narrative_architecture_test.dart` | 1 |

Tam liste `SUTOLS_A0_TEST_ENVANTERI.csv` dosyasında. Sınıflandırmalar kök neden kararı değildir; hangi testin eski beklenti, hangi davranışın gerçek hata olduğu tek tek kanıtlanacak.

Örnek kanıtlar:

- AI routing testleri eski model zincirini beklerken farklı seçim/fallback sonucu alıyor. Ürün davranışını incelemeden bu beklentiler değiştirilmeyecek.
- Dil testi `Topic:` metnini bekliyor; mevcut prompt `Presentation subject:` içeriyor. Sözleşme beklentisi farkı adayı.
- Bazı font testleri dış Google Fonts importunu bekliyor; uygulamada yerel font mekanizması var. Yerel fontların gerçekten yüklendiği doğrulanmadan test sadece yeniden yazılmayacak.
- Editör testlerinde model paneli, mobil taşma, seçilen font ve sanal tur kamera davranışı başarısız. Bunlar kullanım kolaylığı ve sahne tutarlılığı çalışmalarının kabul kapısıdır.
- Golden görsellerde fark var. Referans görüntüler otomatik güncellenmedi; oluşan fark görüntüleri ayrı çalışma klasörüne alındı. Başlangıçta temiz olan takipli test görüntüleri geri getirildi.
- Proje codec/legacy regression testlerinde başarısızlık kaydedilmedi; kayıt ve eski sürüm uyumluluğu için başlangıç kanıtı korunuyor.

## Açık A0 işleri ve somut bağımlılıklar

**A0.3 — Proxy kaynaklarının geri getirilmesi:** `sutol-model-proxy` boş; `.gitmodules` adresi yok. Doğru repository/Worker kaynağı kanıtlanmadığı için adres uydurulmadı. İlgisiz `_birdev_readme_refresh` gitlink'leri ayrı bakım işi.

**A0.4 — Functions/Worker ayrımı:** Derleme hataları yanı sıra `functions/src/index.ts` içinde sabit örnek objectKey ve JWT imzasını doğrulamadan payload döndüren tamamlanmamış akış görüldü. Bunu yalnızca tipleri susturarak derlenebilir yapmak doğru bir yayın zemini sağlamaz. Önce gerçek yayımlanan Worker kaynağı ve binding sözleşmesiyle eşleştirilmeli; sonra ayrı, davranış testli değişiklik yapılmalı. Bu tespit yayındaki Worker'ın aynı kodu kullandığını kanıtlamaz.

**A0.6 — Üretim geri dönüşünün tamamlanması:** Kaynak bundle ve legacy fixture hazır. Gerçek eski kullanıcı sunumu ve canlı dağıtımın commit/artefact eşlemesi henüz doğrulanmadı; madde tam bitmiş işaretlenmedi.

A0 aşaması bütünüyle tamamlanmış değildir. A0.1/A0.2/A0.5 tamamlandı; A0.3/A0.4 ve A0.6'nın üretim doğrulaması açık. Performans veya ürün davranışı refaktörü bu rapora dayanarak ayrı iş paketiyle yapılacak.

## Tekrarlama

```sh
python3 tool/run_development_baseline.py
flutter build web --no-pub --output=build/development_baseline/web
```

Canlı servis testlerini çalıştırmak için kılavuzdaki ayrı `--live` akışı kullanılır. Baseline scripti genel ağ izolasyonu sağlamaz; liste yeni testlerle güncel tutulmalı.

## Sıradaki iş

Öncelikle A0.3/A0.4 için gerçek proxy kaynağını proje geçmişi ve mevcut deployment metadata'sından doğrula. Kaynak doğrulanamazsa bu dış bağımlılığı açık tut; mevcut sunum akışını değiştirmeden A1 için referans sahne ve görünür/gizli sahne ölçüm altyapısını hazırlayabilirsin. A2/A3 refaktörüne geçmeden başlangıç ölçümü ve ilgili davranış hatalarının durumu netleştirilecek.

## Kayıt ve geri dönüş

Ara çıktılar: bu sohbetin `work/sutols-a0/` klasörü. `source-before.bundle`, baseline JSON/logları, golden farklar, V1 regression fixture ve yerel build burada korundu. Bundle başlangıç commit'ini ve tam kaynak geçmişini kapsar; mevcut takip dışı dosyaların/secret'ların yedeği değildir. Geri dönüş yapılacaksa mevcut çalışmalar ayrıca korunarak bundle ayrı klasöre clone edilebilir.

Projenin Atlas günlük komutu Windows yoluna ve PowerShell'e bağlı. Bu macOS ortamında belirtilen vault/çalıştırıcı bulunmadığından komut çalıştırılamadı; oturumun bulguları bu rapor ve geliştirme planında kaydedildi.
