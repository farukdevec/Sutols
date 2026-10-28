# Sutols model hazırlama pilotu

Üretim:

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --python tool/models/build_original_models.py
```

100 şematik model için lite/quality GLB, 512 px şeffaf PNG ve sürümlü manifest
üretir. Tekrar üretimde Blender sürümünü ve renderer farklarını kaydedin.
Yayımlanmış dosyaları yerinde değiştirmeyin; yeni paket için yolları sürümleyin.
Geometri tek başına eğitimsel doğruluğun veya animasyonlu model uyumluluğunun
kanıtı değildir. Mevcut rigli modeller bu işlemle yeniden dışa aktarılmaz.

Doğrulama:

```sh
npm --prefix tool/models ci
npm --prefix tool/models run validate
```

Denetim zorunlu metadata, benzersiz ID/hash, dosya boyutu/hash eşleşmesi,
thumbnail varlığı ve Khronos glTF doğrulamasını içerir. Rapor varsayılan olarak
`build/model-validation.json` konumundadır. Hatalı paket yayınlanmamalıdır.
Üçgen sayısı Blender modifier uygulandıktan sonra hesaplanır; draw call sayısı
değildir. Yüzey/material değişiminde gerçek model-viewer karşılaştırması gerekir.

Kaynak ve hak kaydı: ORIGINAL_MODELS_LICENSE.md. 25 → 50 → 100 adımlarıyla 11 kategoride 100 özgün modele genişletildi.
Dosya doğrulaması insan görsel/öğretimsel onayı yerine geçmez. Hiçbir dış model bu paket
aracına topluca eklenmemelidir; her dış dosyanın lisans/atıf kaydı doğrulanmalıdır.

Dart kataloğu `python3 tool/models/generate_catalog.py` ile manifestten üretilir; ardından `dart format lib/models/original_model_catalog.dart` çalıştırın.
Sürüm/hash güncellemelerini ve iki dosyanın tutarlılığını birlikte kontrol edin.
Dengeli/Tasarruf lite sürümü; Yüksek quality sürümü seçer. İçeri gömülmüş veya
kullanıcıdan gelen farklı kaynak adresleri kalite seçimiyle değiştirilmez.

## Aynı kontrol sayfasını yeniden üretme

```sh
python3 tool/models/preview.py --port 8794
```

Sayfa manifestten bütün modelleri ve iki varyantı çıkarır. Yalnızca bir canlı
model-viewer oluşturur; aynı model tekrar seçildiğinde mevcut yükleme durumunu
korur. Thumbnail, hafif/kaliteli varyant ve lifecycle sayaç kontrolü vardır.
`--generate-only` sunucu açmadan build/model-preview çıktısını hazırlar.
Sunucu yalnızca 127.0.0.1'e bağlanır. Model-viewer JS'i ilk yüklemede ağ ister;
GLB ve thumbnail yerel kaynaklardan okunur. Kontrol sayfası üretim editörünün
tam birleşik görev senaryosu yerine geçmez.

## Yerel model kabulü (karantina → inceleme → onaylı paket)

`intake.cjs` canlı kataloğa veya Firestore'a yazmaz. Admin paneli yerel karar
dosyası üretir; uzak yayın endpoint'i henüz yoktur; mevcut `/models` yazma kuralı değiştirilmez.
Yeni dosya önce karantinaya alınır; otomatik denetim görsel ve lisans incelemesinin
yerine geçmez.

Metadata JSON örneği:

```json
{"id":"ornek-atom-v1","name":"Atom","category":"Fizik","tags":["atom","elektron"],"tagsEn":["atom","electron"],"excludeTags":[],"license":"Lisans metni veya kayıt yolu","source":"Kaynak ve sürüm bilgisi","author":"Hak sahibi"}
```

```sh
node tool/models/intake.cjs submit metadata.json model.glb thumbnail.png
node tool/models/intake.cjs approve build/model-intake/quarantine/ID/HASH "İnceleyen adı" --visual-reviewed --license-reviewed
node --test tool/models/intake.test.cjs
```

İsteğe bağlı `--directory PATH` tüm çıktıları başka yerel klasöre yönlendirir.
GLB 2.0 gömülü kaynaklarla sınırlıdır; harici/data URI kabul edilmez. Başlangıç
bütçesi 8 MiB, 50.000 üçgen ve çizilebilir varsayılan sahnedir. Khronos hataları
onayı engeller; uyarılar `--warnings-reviewed` ile ayrıca incelenmelidir.
PNG için boyut/başlık kontrolü yapılır (128–2048 px, en çok 2 MiB); görselin
gerçekte açıldığı ve doğru nesneyi gösterdiği insan incelemesinde doğrulanır.
Model, küçük resim ve metadata SHA-256 kaydı onay öncesi tekrar doğrulanır.
Aynı başvuru üzerine yazılmaz. Onay `local-approved-unpublished` paket üretir;
canlı katalogya katmak için sonraki yayın akışı gereklidir. Lisans alanının dolu
olması hakların doğrulandığı anlamına gelmez; inceleyen kaynak hakkını kontrol eder.

### Admin inceleme ekranı ve karar dosyası

Admin panelindeki **Model inceleme** bölümünden karantina klasörünün
`receipt.json` dosyasını açın. Model ve küçük resim önizlemesi için:

```sh
python3 tool/models/preview_intake.py build/model-intake/quarantine/ID/HASH
```

Araç üç dosyanın hash'ini kontrol eder, yalnızca bu başvuruyu localhost'ta açar;
harici/data-URI GLB kaynaklarını engeller. Model-viewer modülü CDN'den yüklenir.
Önizlemeyi kontrol ettikten sonra admin ekranında görsel, lisans ve varsa
Khronos uyarısı incelemesini işaretleyin. İnceleyen adı ve notla karar dosyasını
indirin. Dosya uzak sisteme gönderilmez; uygulanması ayrı yerel adımdır:

```sh
node tool/models/intake.cjs review ornek-atom-v1-review.json build/model-intake/quarantine/ID/HASH
```

Onay: model, thumbnail ve metadata kimliklerini eşleştirir; GLB'yi tekrar
Khronos ile denetler; lisans ve görsel kontrol beyanı gerekir. Değişen dosya veya
farklı başvuru kararı reddedilir. Ret: ayrı değişmez inceleme kaydı üretir.
Onaylı paket `approved` altında kalır; canlı katalog yayını henüz bağlı değildir.
Doğrudan CLI onayı da artık `--visual-reviewed --license-reviewed` ister.


## Rig, animasyon, saydamlık ve doku pilotları

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --python tool/models/build_visual_pilots.py -- /absolute/visual-pilots
node tool/models/validate_visual_pilots.cjs /absolute/visual-pilots
```

Bu ayrı araç v1 kataloğunu yeniden yazmaz. Rigli rüzgâr türbini (bir skin,
bir RotorSpin klibi) ve alpha-blend laboratuvar malzemesi (1024/2048px özgün
kalibrasyon dokusu) için dört GLB ve iki thumbnail üretir. Manifest kimliği ve
GLB özellik sayıları dosyanın gerçek JSON'u ile tekrar denetlenir; Khronos hata
ve uyarıları komutu başarısız kılar. İlk üretimde skinned mesh parent uyarısı
saptandı; armature modifier korunup mesh sahne kökü yapılarak giderildi.

Bunlar yayımlanmamış QA varlıklarıdır. Gerçek insan/organik rig, fizik simülasyonu,
optik olarak doğru cam veya hedef GPU tüketimi kabulünün yerine geçmez. PNG
sıkıştırılmış boyutu doku belleği değildir; 2048px RGBA dokunun yalnızca ana
seviyesi teorik olarak 16 MiB'dir (mipmap ve sürücü maliyeti hariç). Pilotlar
önce intake submit ile karantinaya girer; insan görsel/lisans kabulü olmadan
approved veya üretim katalog girdisi olarak etiketlenmez.
