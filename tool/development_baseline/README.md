# Sutols geliştirme başlangıç kontrolü

Bu iş paketi uygulamanın sunum oluşturma, düzenleme, 3B gösterim ve dışa aktarma davranışını değiştirmez. Mevcut sürümün ölçülebilir test/derleme durumunu kaydeder. Eski test beklentileri yalnızca sonuçları yeşile çevirmek amacıyla değiştirilmez.

## Kurulum

Başlangıç ortamı: Flutter 3.38.9 / Dart 3.10.8. Önce `flutter pub get` çalıştırın. SDK'yı güncellemek ayrı bir değişiklik paketidir.

`functions/package.json` Node 24 ister. İncelemenin yapıldığı makinede Node 25.6.0 bulunuyordu; tam üretim eşdeğerliği için Node 24 ile ayrıca kontrol gerekir. Bağımlılıkları gereken ortamda `npm --prefix functions ci` ile kurun. TypeScript derleme hataları mevcut ve bu aşamada giderilmedi.

## Tekrarlanabilir başlangıç raporu

```sh
python3 tool/run_development_baseline.py
```

Çıktılar varsayılan olarak Git'in dışladığı `build/development_baseline/` klasörüne kaydedilir. Farklı klasör için `--output /absolute/path` kullanın. Script test, analiz ve functions tip kontrolünü çalıştırır; herhangi biri başarısızsa exit code 1 döndürür. Başarısız testler raporlandığı için raporun oluşması testlerin geçtiği anlamına gelmez.

- `baseline.json`: başlangıç commit'i, çalışma alanı durumu, araç sürümleri, seçilen/dışlanan testler, komutlar ve sonuçlar.
- `tests.jsonl`: Flutter test olayları ve başarısızlıklar.
- `analysis.log`: Dart analiz sonucu.
- `functions.log`: `tsc --noEmit` sonucu; bağımlılıklar yoksa bu kontrol açıkça çalıştırılmamış olarak raporlanır.

Altı üretim bağımlı dosya varsayılan kontrolden açık bir listeyle ayrılır. Script bunları silmez veya başarılı saymaz; isimlerini ve gerekçelerini raporlar. Mevcut render/replay testlerinin kendi açık opt-in koşulları korunur. Yeni test eklenirken gerçek servis bağımlılığı ayrıca denetlenmelidir; bu script genel bir ağ sandbox'ı değildir.

Golden test başarısızlıkları `test/failures/` altında görüntüler oluşturabilir. Görseller incelenmeden `--update-goldens` çalıştırmayın; test kaynakları ve başarısızlık görüntüleri ayrı tutulmalıdır.

## Canlı testler

```sh
python3 tool/run_development_baseline.py --live
```

Bu komut gerçek servisleri çağırır, AI kotası tüketebilir ve ağ/üretim durumuna bağlıdır. Kontrollü test başlangıç raporundan ayrı kaydedilmelidir. Üretim ortamını sıradan regresyon testi yerine kullanmayın.

Grok deneme dosyası normal test keşfinde değildir (`probe_grok.dart`). Eksik, Git dışı `lib/env_config.dart` yerine süreç ortamındaki `SUTOLS_GROK_API_KEY` değerini okur. Anahtarı depoya, markdown dosyasına veya komut geçmişine yazmayın. Anahtarı güvenli süreç ortamı üzerinden verdikten sonra:

```sh
flutter test --no-pub --dart-define=SUTOLS_LIVE_TESTS=true test/probe_grok.dart
```

Opt-in veya anahtar yoksa gerekçesiyle atlanır. Aktif olduğunda HTTP hatasını gerçek başarısızlık olarak raporlar ve istemciyi kapatır.

## Yerel web build kontrolü

```sh
flutter build web --no-pub --output=build/development_baseline/web
```

Bu işlem yerel derleme kontrolüdür. `firebase deploy`, Worker yayını veya GitHub push içermez. Çıktı klasörünü açıkça seçmek mevcut `build/web` paketini korur.

## Ürün amacı için korunacak kontroller

- Metin/konudan sunum oluşturma ve AI fallback akışı.
- Üretilen içeriğin düzenlenmesi; doğru 3B/2B görsel seçimi.
- Kamera ve model yönünün editör/preview/sunum arasında korunması.
- Kayıt/yükleme ve eski proje sürümlerinin açılması.
- Metnin okunurluğu, HTML dışa aktarma ve platform uyumluluğu.

Bu davranışlar sonraki optimizasyonlarda kabul kapısıdır. İlk aşama kaynak `lib/` ve `web/` dosyalarını değiştirmez.

## Web-only preview readiness regression

The native widget layout test cannot exercise an iframe's null browsing context.
For this check, build the isolated local fixture (never a production route):

```sh
flutter build web --release --no-pub --target tool/development_baseline/preview_smoke_main.dart --output build/preview-smoke
python3 -m http.server 8824 --bind 127.0.0.1 --directory build/preview-smoke
```

Open the loopback URL in the browser. The title, body and water molecule must be
visible, and the QA header must say “No Flutter runtime errors”. Toggle Suspend
and Resume; reinitializing the iframe must not show a gray error surface or
throw `NullWindowException`/a null `postMessage` error. The fixture has no account,
Firebase initialization, inference or project persistence. It supplements the
real editor → presentation → editor check; it does not validate cloud saving.

## Native GPU context recovery checks

The direct editor fixture is `model_context_smoke_main.dart`. Build it explicitly
as the web target, then copy the unpublished rigged pilot into the disposable
build's `/models/qa-context/rigged-wind-turbine-lite.glb` path. It invokes the
standard `WEBGL_lose_context` extension and reports native loss/restore, camera,
turntable and paused clip equality, plus explicit seek/play/pause checks.
The extended fixture then replaces the direct scene 50 times and checks one
connected model viewer at a time and zero after disposal. DOM counts do not
establish GPU/SDK cache memory release or driver resource usage.
Never register this QA asset path in the production catalog.

The shared HTML document can be generated without a web build:

```sh
SUTOLS_CONTEXT_QA_DOCUMENT=/absolute/disposable/generated-context.html flutter test --no-pub tool/development_baseline/model_context_document_fixture_test.dart
node --test test/model_context_recovery_script_test.mjs test/scene_lifecycle_test.mjs
```

Serve this document with the same QA-only GLB path over loopback HTTP. It runs a
native context loss/restore check and presents the measurements in visible DOM.
An iframe wrapper exercises the generated preview document. The sensors and
script are QA-only. These tests do not establish physical driver recovery,
mobile device compatibility, FPS, GPU memory or energy improvements.
