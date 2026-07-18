# Sutol

Sutol, girilen başlık ve metinlerden düzenlenebilir HTML sunumları üreten, Flutter Web tabanlı bir sunum hazırlama uygulamasıdır. İçeriği cihaz üzerinde analiz eder; uygun arka planları, metin yerleşimlerini ve görsel bileşenleri anahtar kelime ve benzerlik eşleştirmesiyle otomatik olarak seçer.

> [!NOTE]
> Otomatik oluşturma işlemi herhangi bir yapay zekâ servisine veya harici API'ye bağlanmaz. Metin analizi ve yerleşim seçimi tamamen yerel ve deterministik olarak çalışır.

## İçindekiler

- [Özellikler](#özellikler)
- [Nasıl çalışır?](#nasıl-çalışır)
- [Mimari](#mimari)
- [Proje yapısı](#proje-yapısı)
- [Kurulum](#kurulum)
- [Test ve doğrulama](#test-ve-doğrulama)
- [Kullanım notları](#kullanım-notları)
- [Bilinen sınırlamalar](#bilinen-sınırlamalar)
- [Yol haritası](#yol-haritası)
- [Katkıda bulunma](#katkıda-bulunma)
- [Lisans](#lisans)

## Özellikler

- **Metinden otomatik sunum üretimi:** Her sayfanın başlığı ve gövde metni analiz edilerek uygun sahne hazırlanır.
- **Akıllı içerik eşleştirme:** Türkçe ve İngilizce anahtar kelimeler ile küçük yazım ve aksan farklarını yakalayabilen fuzzy eşleştirme desteklenir.
- **Geniş bileşen kataloğu:** Farklı konu kategorilerine ait HTML/CSS tabanlı görsel bileşenler otomatik veya manuel olarak slaytlara eklenebilir.
- **HTML sahne editörü:** Arka plan, metin, bileşen, akış ve efekt ayarları tek bir çalışma alanından düzenlenebilir.
- **Geri alma ve yineleme:** Düzenleme işlemleri arayüzden veya klavye kısayollarıyla geri alınabilir ve yinelenebilir.
- **Sunum akışı:** Öğelere adımlı gösterim (reveal), başka bir sayfaya yönlendiren hotspot ve sunucu notu atanabilir.
- **Sunum modu:** Tam ekran görüntüleme, klavye ile gezinme, yakınlaştırma ve sunucu notları desteklenir.
- **Efektler:** Slayt geçişi, geçiş süresi, hareket azaltma ve sahne yakınlaştırma seçenekleri bulunur.
- **Proje kaydetme ve yükleme:** Çalışmalar Sutol JSON proje dosyası olarak indirilebilir ve daha sonra yeniden açılabilir.
- **Dışa aktarma:** Sunum tek bir HTML dosyası olarak indirilebilir veya tarayıcının yazdırma akışıyla PDF olarak kaydedilebilir.

## Nasıl çalışır?

1. Ana ekrandan **Sunum Oluştur** seçilir.
2. Her slayt için başlık ve metin girilir; gerekirse yeni sayfalar eklenir.
3. **Sunumu Oluştur** seçildiğinde boş sayfalar atlanır ve içerik analiz edilir.
4. Uygulama her sayfa için arka planı, metin düzenini ve uygun görsel bileşenleri belirler.
5. Oluşturulan sunum editörde özelleştirilir, önizlenir ve istenen formatta dışa aktarılır.

Basitleştirilmiş veri akışı:

```text
Başlık + metin
      │
      ▼
PresentationAutoBuilder
  ├─ anahtar kelime ve fuzzy eşleştirme
  ├─ arka plan seçimi
  └─ bileşen ve yerleşim seçimi
      │
      ▼
PresentationPage / SlideModel
      │
      ▼
HtmlPresentationEditorPage
  ├─ PresentationPreviewPage       → sunum modu
  ├─ PresentationExportBuilder     → bağımsız HTML / PDF yazdırma
  └─ PresentationProjectCodec      → Sutol JSON proje dosyası
```

## Mimari

Sutol, arayüz, durum yönetimi, veri modelleri ve platforma özel servisleri birbirinden ayıran sade bir yapıya sahiptir:

- `models`: Slayt, metin bloğu, efekt ve bileşen kataloğu modelleri.
- `services`: Otomatik oluşturma, eşleştirme, HTML export ve proje dosyası işlemleri.
- `state`: Sayfa seçimi, düzenleme geçmişi ve sunum durumunun yönetimi.
- `ui`: Metin girişi, editör, sahne ve sunum modu ekranları.

Web'e özel indirme, dosya seçme ve tam ekran işlemleri koşullu Dart export'larıyla ayrılmıştır. Böylece web API'leri desteklenmeyen hedeflerde doğrudan derleme bağımlılığı oluşturmaz.

## Proje yapısı

```text
lib/
├── main.dart
├── models/
│   ├── presentation_component_catalog.dart
│   └── slide_model.dart
├── services/
│   ├── presentation_auto_builder.dart
│   ├── presentation_export_builder.dart
│   ├── presentation_export_service*.dart
│   ├── presentation_fullscreen_service*.dart
│   ├── presentation_keyword_catalog.dart
│   ├── presentation_project_codec.dart
│   └── presentation_project_io*.dart
├── state/
│   └── presentation_controller.dart
└── ui/
    ├── home_page.dart
    ├── presentation_text_draft_page.dart
    ├── html_presentation_editor_page.dart
    ├── presentation_preview_page.dart
    └── widgets/
        └── html_stage/
test/
├── presentation_auto_builder_test.dart
├── presentation_controller_test.dart
└── presentation_project_codec_test.dart
tool/
└── bileşen kataloğu üretim ve kontrol araçları
web/
└── Flutter Web başlangıç dosyaları
```

`gitsunum/` dizinindeki Shower ve reveal.js kaynakları ana Flutter uygulamasından bağımsız, üçüncü taraf sunum projeleridir. Bu dizinler kendi lisans ve geliştirme kurallarına tabi olabilir.

## Kurulum

### Gereksinimler

- Flutter SDK (Dart `>=3.5.0 <4.0.0` desteği olan bir sürüm)
- Chrome veya güncel, Chromium tabanlı bir tarayıcı
- İsteğe bağlı: üretim build'ini yerelde sunmak için Python 3

Flutter kurulumunuzu kontrol edin:

```bash
flutter doctor
```

Bağımlılıkları yükleyin:

```bash
flutter pub get
```

Uygulamayı Chrome'da çalıştırın:

```bash
flutter run -d chrome
```

### Üretim build'i

```bash
flutter build web
```

Oluşan build'i yerelde sunmak için:

```bash
python3 -m http.server 8080 --directory build/web
```

Ardından `http://localhost:8080` adresini açın.

## Test ve doğrulama

Kod biçimini kontrol edin:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Statik analizi çalıştırın:

```bash
flutter analyze
```

Birim testlerini çalıştırın:

```bash
flutter test
```

Web build'ini doğrulayın:

```bash
flutter build web
```

Önerilen manuel kontroller:

- Türkçe, İngilizce ve küçük yazım hataları içeren metinlerin uygun arka plan ve bileşenlerle eşleştiğini doğrulayın.
- Tamamen boş girişte editöre geçilmediğini ve kullanıcıya uyarı gösterildiğini kontrol edin.
- Metin ve bileşenlerin taşınabildiğini, boyutlandırılabildiğini ve silinebildiğini doğrulayın.
- Geri alma/yineleme, reveal, hotspot, sunucu notu ve efekt ayarlarını sınayın.
- Sutol JSON dosyasını kaydedip yeniden yükleyin.
- HTML export'u farklı bir sekmede açın; PDF seçeneğinin yazdırma penceresini açtığını kontrol edin.

## Kullanım notları

Sunum modundaki temel klavye kontrolleri:

| Tuş | İşlev |
|---|---|
| `→`, `Page Down`, `Space` | Sonraki reveal adımı veya slayt |
| `←`, `Page Up`, `Backspace` | Önceki reveal adımı veya slayt |
| `F` | Tam ekranı aç/kapat |
| `Z`, `+` | Yakınlaştırmayı aç/kapat |
| `P`, `N` | Sunucu notları panelini aç/kapat |
| `Esc` | Sunum modundan çık |

Editörde geri alma için `Ctrl/Cmd + Z`; yineleme için `Ctrl + Y` veya `Cmd + Shift + Z` kullanılabilir.

## Bilinen sınırlamalar

- İçerik analizi anahtar kelime ve benzerlik tabanlıdır; bağlamsal bir yapay zekâ modeli kullanmaz.
- Fuzzy eşleştirme, yanlış pozitifleri azaltmak amacıyla kısa kelimelerde bilinçli olarak daha katıdır.
- PDF dışa aktarma, tarayıcının **Yazdır / PDF olarak kaydet** özelliğini kullanır; uygulamanın kendi PDF motoru yoktur.
- Proje dosyası kaydetme/yükleme ve dışa aktarma akışları öncelikli olarak web hedefi için geliştirilmiştir.
- MP4 veya video dışa aktarma henüz desteklenmez.

## Yol haritası

- [ ] MP4/video dışa aktarma için capture veya render hattı
- [ ] Daha geniş eş anlamlı ve alan terimi havuzu
- [ ] Mobil ve masaüstü için yerel dosya işlemleri
- [ ] Bulut tabanlı kaydetme ve eşitleme
- [ ] Görsel regresyon testleri
- [ ] Daha kapsamlı erişilebilirlik kontrolleri

## Katkıda bulunma

Bir değişiklik göndermeden önce:

1. `dart format --output=none --set-exit-if-changed lib test` komutunu çalıştırın.
2. `flutter analyze` ve `flutter test` sonuçlarının temiz olduğundan emin olun.
3. Yeni davranışlar için ilgili testleri ekleyin veya güncelleyin.
4. Commit mesajını değişikliğin amacını açıklayacak biçimde yazın.

## Lisans

Bu depo için henüz bir kök lisans dosyası belirtilmemiştir. Kaynak kodu kullanmadan veya dağıtmadan önce proje sahibinden izin alın. `gitsunum/` altındaki üçüncü taraf projelerin lisansları ayrıca geçerlidir.
