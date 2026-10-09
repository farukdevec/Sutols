# Yerel release kimliği ve geri dönüş

## Doğrulanmış build

```sh
python3 tool/build_release_manifest.py build/verified-web
```

Araç önce gerçek release derlemesini çalıştırır; lib, web, assets ve pubspec
kaynak fingerprint'ini önce/sonra karşılaştırır. Eski main.dart.js'ye yeni kaynak
kimliği yazılmaz. Kaynak derleme sırasında değişirse manifest üretilmez.
Önceki manifest yeni derleme başlamadan kaldırılır. Manifest base commit'i,
dirty çalışma durumunu, UTC zamanı, kaynak/JS hash'ini, katalog/şema sürümünü ve
feature flag'leri içerir. Yayın yapmaz. Deploy edilen artefact aynı klasör olmalı;
burada üretim veya staging yayını yapılmadı.

## Dar feature flag'ler

```sh
python3 tool/build_release_manifest.py build/rollback-candidate --disable SUTOLS_ORIGINAL_MODELS
```

- SUTOLS_VISIBLE_SCENES: yeni sahne lifecycle ve doğrudan görünürlük kontrolü.
  Export'un diğer mevcut statik sayfa/CSS davranışlarını bütünüyle geri almaz.
- SUTOLS_ORIGINAL_MODELS: yeni özgün modellerin katalog keşfine eklenmesi.
  Eski projede kayıtlı ID'yi veya yayınlanmış GLB dosyasını silmez.
- SUTOLS_INFLECTED_MATCHING: yeni ortak çekim kökü dalı. Önceden var olan
  benzerlik ve diğer eşleştirme davranışlarını tamamen geri almaz.

Manuel arama, kayıt kuyruğu, fontlar ve kalite tercihi bu flag'lerle geri alınmaz.
Tam geri dönüş için değişiklik öncesi kod ve aynı dönemin dağıtım artefact'i gerekir.
Yeni v1 model paketinin adresleri yayımlandıktan sonra değiştirilemez; yeni dosya
v2 adresinde yayınlanmalıdır. Henüz v1 üretimde yayımlanmadı.

## Yayın kapıları

1. Kontrollü baseline raporu, yeni başarısız test bulunmaması ve glTF raporu.
2. Golden farklarının inceleme/onayı; referansları otomatik yenileme yok.
3. Staging'de yavaş ağ, arama, kamera, slayt, sunum, geri dönüş, kayıt, yeniden açma,
   export; özellikle oturum değişimi ve imzalı URL süresi dolumu.
4. Gerçek eski sunum fixture'ı ve önceki dağıtım artefact'i ile geri dönüş denemesi.
5. Cihaz/GPU ve insan görev testleri; bu adımlar yapılmadan hedef yüzdeler iddia edilmez.

Mevcut Functions TypeScript hataları ve eksik sutol-model-proxy kaynağı yayına
engeldir. Yerel frontend build başarısı backend deployment doğrulaması değildir.
