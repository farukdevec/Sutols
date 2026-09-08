# Sutols — 3D model geliştirme çalışma talimatı

## Görev ve ürün amacı

Sutols sunum platformunun mevcut 3D model kütüphanesini, her modelin kimliğini ve sunumlardaki yerleşimini koruyarak geliştir. Amaç; daha gerçekçi, teknik işlevi daha iyi anlaşılır, sade ve sürekli izlenebilir modeller üretmektir. Bu bir oyun efekti veya sinematik gösteri çalışması değildir. Model, slaytın anlatımını desteklemeli; yazıların ve konuşmacının önüne geçmemelidir.

Kapsam tüm modellerdir. Çalışmayı küçük partiler halinde yürüt; her modeli ayrı değerlendir ve doğrula. Aynı animasyon reçetesini bütün kataloğa uygulama. Bu dosyanın oluşturulması veya envantere giriş yapılması, modelin geliştirilmiş olduğu anlamına gelmez.

## Her oturumun başlangıcı

1. Projenin `AGENTS.md` dosyasını, bu talimatı, `model-improvements/README.md`, `model-improvements/events.jsonl` ve ilgili model kaydını oku. `git status --short` ile mevcut kullanıcı değişikliklerini belirle ve koru.
2. `model-improvements/inventory.json` başlangıç aday listesidir; canlı katalog yerine geçmez. Firestore `models`, R2 nesneleri ve paket modelleriyle mutabakat yap. Dosya adından türetilen aday kimliğini gerçek Firestore belge kimliği olarak kabul etme.
3. İşlenecek modelin gerçek kalıcı kimliğini, alias kimliklerini, nesne anahtarını ve mevcut yayınlanmış dosyanın SHA-256 özetini doğrula. Süresi dolan imzalı URL'yi kalıcı kimlik olarak kullanma.
4. Daha önce geliştirilmiş bir modelde son doğrulanmış sürümü temel al. Eski ham dosyadan tekrar başlama. Kayıt ile dosya özeti uyuşmazsa `blocked` olayı ekle; uyuşmazlığı çözmeden dosya değiştirip yayınlama.
5. İlk parti: erişilebilen ambulans, helikopter ve motor örnekleri; ardından bir organik model ve bir statik mimari/soyut model. Bunlar bulunamazsa adayları ve eksik erişimi kaydet; yapılmayan işi tamamlanmış gösterme. Pilot doğrulandıktan sonra 5–10 modellik partilerle devam et.

## İncelenmiş mimari ve korunacak sözleşmeler

- `lib/models/presentation_3d_model_catalog.dart`: paket katalog, `id`, `assetPath`, `byteSize`, `sha256`, `hasAnimations`, `hasRig`, `supportsVirtualTour`, `preferBundledAsset`, model bazlı ışık ayarları.
- `lib/services/model_repository.dart`: Firestore kataloğu, kullanıcı bazlı bellek/kalıcı önbellek, 12 saatlik TTL ve paketle birleştirme. Paket önceliği olan bir modeli yalnız bulutta değiştirmek yeterli değildir.
- `lib/services/model_asset_service.dart`: R2 nesne anahtarları, yetkilendirme, süreli imzalı URL ve küçük resim çözümü.
- `lib/services/remote_model_sources.dart` ve `presentation_model_source_resolver.dart`: kimlikten kaynağa çözümleme, kayıtlı sunumları yeniden açma ve kaynak yenileme.
- `lib/ui/widgets/html_stage/html_page_stage_web.dart`: doğrudan model-viewer sahnesi. `autoplay` ve `auto-rotate` ayrı ayarlardır.
- `lib/ui/widgets/html_stage/html_stage_document.dart`: HTML sahnesi, dışa aktarma ve animasyon işaretlemesi. Doğrudan sahne ile aynı davranış doğrulanmalıdır.
- `lib/models/slide_model.dart`, `model_tour_runtime.dart`: kayıtlı yerleşimler, kameralar, sanal tur noktaları. Alanları topluca yeniden yazma.

Model kimliklerini, mevcut sunum referanslarını, ölçek/orijin/eksen sözleşmesini, yetkilendirmeyi, erişim katmanını ve kategori/etiket eşleştirmesini koru. Eski sunumların yeniden açılması zorunludur. Dosya geliştirmesi için renderer değiştirme, her modele özel JavaScript döngüsü ekleme veya yeni harici servis bağımlılığı oluşturma. Zorunlu bir altyapı eksikliğini ayrı, küçük ve geriye uyumlu değişiklik olarak ele al; kanıtını kaydet.

## Model başına gerçek inceleme

Dosyayı edinmeden görsel veya teknik kaliteyi değerlendirilmiş sayma. Kaynağı aç, sabit kamera ve sabit ışıkla en az ön/yan/üç çeyrek görüntü al. Mevcut animasyonu izle. Kaynak `.blend` veya üretici betik mevcutsa onu koruyarak çalış; yalnız GLB varsa yeniden içe/dışa aktarmanın materyal, rig ve veri kaybını kontrol et.

Başlangıç raporuna kaydet: dosya boyutu ve SHA-256, geometri üçgen sayısı, düğüm/mesh/primitive/materyal sayıları, dokuların çözünürlükleri ve yaklaşık GPU bellek maliyeti, rig/morph target varlığı, animasyon klipleri/süreleri/kanalları, kullanılan ve gerekli uzantılar, eksik dış kaynaklar, dünya uzayında bounding box, merkez, taban yüksekliği, orijin, kök dönüşümü ve tam döngüde hareket sınırları. Ölçülmeyen değer `null` olmalı; tahmin ölçüm diye yazılmamalıdır.

Her model için kısa karar yaz: nesne nedir, teknik olarak ne anlatır, hangi parça gerçekten hareket eder, hangi parça sabit kalır, mevcut kusur nedir ve önerilen hareket neden bu modele uygundur? Benzer ad, aynı mekanizma anlamına gelmez. Bilimsel veya mekanik belirsizlikte güvenilir teknik kaynağı doğrula ve kaydet.

## Görsel kalite ve boyut bütçesi

“Boyutları çok değiştirmemek” hem modelin sahnedeki fiziksel ölçülerini hem dosya ağırlığını kapsar. Aşağıdaki sayılar başlangıç çalışma bütçeleridir; kullanıcının verdiği kesin sayılar veya mevcut sistemin ölçülmüş kapasitesi değildir.

- Siluet, oranlar, ince kenarlar, yüzey normalleri, malzeme ayrımı ve doğru PBR roughness/metallic değerleriyle gerçekçilik kazan. Plastik gibi metal, ayna gibi kauçuk, opak cam ve yapay aşırı parlaklığı düzelt. Doku büyütmeyi ve poligon eklemeyi ilk çözüm yapma.
- Aynı kök koordinat sisteminde durağan bounding box boyutları için eksen başına en fazla %2 değişim hedefle; sıfıra yakın eksenlerde eski en büyük boyutun %0,2'sini mutlak tolerans olarak kullan. Merkez ve taban kayması eski en büyük boyutun %0,5'ini aşmasın. Ölçeği düzeltmek için kayıtlı slaytları yeniden ölçekleme.
- Tam animasyondaki sınırlar durağan başlangıç zarfından %5'ten fazla genişlememeli. Daha geniş mevcut hareket varsa küçültmenin tur noktalarına ve anlatıma etkisini de değerlendir. Kamera kadrajından taşma hiçbir durumda kabul edilmez.
- Yeni GLB boyutu hedef olarak başlangıçtan büyük olmasın. En fazla %10 artış ancak somut görsel/teknik fayda ve performans ölçümüyle açıklanabilir. Üçgen ve materyal/draw call artışlarını ayrıca raporla. Eşik aşımında otomatik kabul yapma; optimize et veya gerekçeli istisna olarak incelemeye bırak.
- Mevcut rig, UV, morph target, isimler ve turla ilişkili yüzeyleri gereksiz değiştirme. Optimize ederken animasyonlu parçaları sabit gövdeyle birleştirme. Sıkıştırmayı yalnız mevcut uygulamanın çözücü desteği doğrulanırsa kullan.
- Karşılaştırmayı aynı kamera, viewport ve aydınlatmayla yap. Modeli daha kaliteli göstermek için yalnız pozlamayı veya arka planı değiştirme. Küçük resmi yeni sürümden üret.

## Animasyon tasarımı

Ana hareket nesnenin teknik işlevini açıklamalı. Bütün modeli zıplatma, sallama veya döndürme işlemini varsayılan çözüm yapma. Kamera otomatik dönüşü, modelin çalışma animasyonu değildir. Gövde sabit, anlamlı parçalar hareketli olsun; fiziksel olarak gerekli küçük gövde hareketleri gerekçelendirilsin.

| Model türü | Uygun hareket | Kaçınılacak davranış |
| --- | --- | --- |
| Ambulans | Tepe lambasında küçük alanlı, yumuşak ve dengeli uyarı döngüsü; uygun donanımda döner reflektör | Aracın zıplaması, tüm sahnenin yanıp sönmesi, varsayılan siren sesi |
| Helikopter | Doğru pivotta ana rotor ve varsa kuyruk rotorunun tutarlı dönüşü | Gövdenin rotorla dönmesi, yerleşimden uçup çıkma, ters/yalpalayan rotor |
| İçten yanmalı motor | Görülebilen piston, biyel ve krankın uygun faz ilişkisi | Bağımsız rastgele pistonlar, mekanik çarpışma, aşırı titreşim |
| Elektrik motoru | Sabit stator içinde rotor/şaft dönüşü | İçten yanmalı motor hareketinin kopyalanması |
| Motosiklet | Model yapısına uygun küçük motor/aktarma hareketi; durağan araçta mantıklı rölanti | Yerde sabit aracın sebepsiz hızla dönen tekerlekleri |
| Pompa, kompresör, fan | Doğru mil/kanat hareketi; mevcut kesitte mekanizmanın anlaşılması | Rastgele akış parçacıkları, gövde deformasyonu |
| Kalp, akciğer | Anlatılan fizyolojiye uygun ölçülü döngü | Her organı aynı biçimde büyütüp küçültme |
| Mimari/anıt | Varsa bayrak veya gerçek hareketli unsur | Binanın nefes alması, kolonların dönmesi |
| Soyut grafik/eğitim modeli | Anlamlı sürecin sakin gösterimi, değişmeyen veri anlamı | Gerçek veri gibi görünen uydurma değer değişimi |

Doğal hareketi olmayan modele sırf animasyon olsun diye yanlış hareket ekleme. Modeli gerçekçilik yönünden geliştir; `animation_not_applicable` gerekçesiyle kaydet veya anlatıma uygun açıklayıcı hareket tasarla. Her model incelenmeli; her nesne fiziksel olarak hareket etmek zorunda değildir.

Döngü uzunluğu için 3–8 saniye başlangıç tercihidir; rotor ve mekanik frekanslar bu aralığa zorlanmaz. Kesintisiz tekrar, düşük dikkat dağıtma ve teknik tutarlılık önceliklidir. Hızlı mekanizmayı anlaşılır göstermek için yavaşlatıyorsan bunu raporda belirt. Ses varsayılan olarak yoktur.

Tüm eşzamanlı parçaları ilk ve varsayılan `Sutols_Functional_Loop` klibinde birleştir. Alternatif klip gerekiyorsa sonrasına koy. Ayrı kliplerin kendiliğinden birlikte çalışacağını varsayma: model-viewer klip adı verilmezse ilk animasyonu seçer ([resmi belge](https://modelviewer.dev/docs/index.html)). Özellikle bayrağın kumaşı ve üzerindeki semboller aynı zaman çizelgesinde beraber hareket etmelidir.

Gömülü glTF düğüm dönüşümleri ve morph ağırlıklarını tercih et. Temel glTF animasyonu materyal parlaklık rengini doğrudan hedeflemez ([glTF 2.0 şartnamesi](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html)). Ambulans ışığını Blender materyal keyframe'iyle yapıp GLB'de çalışacağını varsayma. Gerçek donanıma uygun döner reflektör gibi taşınabilir çözümü değerlendir; yeni uzantı gerektiren materyal animasyonunu mevcut renderer'da doğrulamadan kullanma. Modelin fiziksel donanımına uymayan hareketle bu sınırlamayı gizleme.

İlk ve son poz görsel olarak eşleşmeli; hızda sıçrama, bir karelik duraklama, geri sarma veya geometri kesişmesi olmamalı. Tam rotor turunda yalnız 0°/360° anahtarlarıyla yetinme; aradaki dönüşü doğrula. En az üç tam döngüyü, sınırdan hemen önce/sonra kareleri ve duraklatıp devam ettirmeyi incele. Kök konumu birikerek kaymamalı. Animasyon kapalıyken model anlamlı ve temiz bir pozda kalmalı.

## Sürüm, kayıt ve eskiye dönüş koruması

Kayıt yerleri:

- `model-improvements/inventory.json`: kaynak adayları ve kimlik mutabakatı; tamamlanma otoritesi değildir.
- `model-improvements/records/<record-key>.json`: modelin güncel durumu, sürümleri ve kanıt referansları.
- `model-improvements/events.jsonl`: yalnız sonuna eklenen olay günlüğü. Geçmiş satırları silme/düzeltme; düzeltmeyi yeni olay olarak ekle.
- `model-improvements/reports/<record-key>/`: önce/sonra ölçümleri, görüntüler, döngü kaydı, validator ve uygulama doğrulaması.

Durum akışı: `pending → inspected → in_progress → candidate → validated → published`. Herhangi bir aşamadan `blocked` veya `failed` olabilir; yeniden başlama yeni olayla ve en son sağlam kaynaktan yapılır. `validated` yerel kalite kapılarını geçmiş, `published` ise yayındaki dosya özeti ve uygulama davranışı da doğrulanmış demektir. `animation_not_applicable` bir karar alanıdır; kalite doğrulamasının yerine geçmez.

Model kaydı en az şu alanları içerir: `recordKey`, gerçek `modelId`, `aliases`, `name`, `category`, `status`, `baseRevision`, `candidateRevision`, `publishedRevision`, `sourceObjectKey`, `sourceSha256`, `outputObjectKey`, `outputSha256`, `sourceProjectPath`, `metricsBefore`, `metricsAfter`, `animationDecision`, `clipName`, `durationSeconds`, `changes`, `validation`, `evidencePaths`, `exceptionReason`, `updatedAt`, `nextAction`. Bilinmeyen alanlar `null`; sahte hash, kimlik veya ölçüm yok.

Her olayda UTC ISO zamanı, `eventId`, `recordKey`, doğrulanmışsa `modelId`, `fromStatus`, `toStatus`, `baseRevision`, `revision`, `inputSha256`, `outputSha256`, işlem özeti, kanıt yolları ve sonraki adım bulunsun. Sonraki oturum model adını değil kimlik + hash + revizyonu esas alsın. Tamamlanmış modeli yalnız yeni ve açık iyileştirme gereği varsa yeniden aç; bunu yeni sürüm olarak kaydet.

Dosyaları sürüm ve içerik özeti taşıyan değişmez nesne anahtarlarıyla sakla. Eski GLB'yi yerinde ezme. Aynı model kimliğinin katalog kaydını doğrulanmış yeni anahtara yönlendir; yetkilendirme ve thumbnail çözümlemesinin bu anahtarla çalıştığını önceden test et. Hash'li anahtar yapısını Worker doğrulamadan varsayma.

Yayın öncesi katalogdaki mevcut revizyon/hash ile beklenen temel sürümü tekrar karşılaştır. Arada değişmişse işlemi durdur ve birleştir; son yazan kazanır yaklaşımı kullanma. Varlığı doğrulanmamış bir otomatik kilit veya atomik bulut güncellemesi varmış gibi raporlama. Birden fazla çalışan varsa dosya kilidi/transaction ve şartlı güncelleme mekanizmasını gerçekten kurup doğrula.

Yayın sırası: yeni dosya ve thumbnail → indirip hash doğrulama → katalog işaretçisini şartlı güncelleme → paket metadata gerekiyorsa güncelleme → önbellek/kaynak yenileme → gerçek uygulamada yeniden açma → `published` olayı. Aşamalar arasında kesinti olursa kayıttan devam et; yayın durumunu tahmin etme. Geri dönüş ancak kayıtlı gerekçeyle önceki doğrulanmış sürüme yapılır; yeni bir rollback olayı eklenir ve geliştirme geçmişi korunur.

Önemli: Bu Markdown ve JSON kayıtları tek başına çalışan uygulamaya teknik sürüm kilidi eklemez. Mutlak otomatik eskiye dönüş koruması için yayın betiğinin kayıt/hash/revizyon kontrolünü zorunlu kılması ve uygulamanın katalog sürümü yenilemesini uygulaması gerekir. Bu parçalar kurulmadıysa durumu açıkça `not_implemented` kaydet.

## Kalite kapıları

1. GLB yapısı ve glTF validator: hata yok; uyarılar tek tek gerekçeli. Dış kaynağa kırık bağlantı yok, desteklenmeyen gerekli uzantı yok.
2. Önce/sonra aynı koşullarda görsel inceleme: daha iyi materyal ve detay, doğru oranlar, temiz gölgeler, kayıp parça yok.
3. Ölçü/dosya/performance bütçesi: hesaplanmış farklar, hareket boyunca kadraj, doku belleği ve draw call etkisi.
4. Animasyon: tüm işlev parçaları birlikte, teknik ilişki doğru, üç döngü temiz, kapalı/açık ve devam ettirme doğru; kamera dönüşünden bağımsız.
5. Sutols editör, sunum/önizleme, kayıt–kapat–yeniden aç ve HTML dışa aktarmada dene. Statik görüntü/PDF varsa temiz sabit kare doğrula. Kullanıcı ölçeği, kamera ve tur noktaları bozulmamalı.
6. Aynı cihaz/tarayıcı/viewport üzerinde başlangıç ve aday için yükleme süresi ve kare süresi ölç; tek model ve en az üç görünür model içeren örneği kullan. Hedef kare süresi regresyonu %10'dan fazla olmasın; ölçüm gürültüsünü tekrarlarla kontrol et. Hedef cihaz yoksa o kontrol `not_run` kalır.
7. Sıcak/eski katalog önbelleği, yeni oturum, süresi dolmuş URL, çevrimdışı davranış ve slayttan ayrılıp dönme senaryolarında kaynak/animasyon durumunu dene. Animasyon durdurma gerekiyorsa yalnız autoplay niteliğinin kaldırılmasına güvenme; çalışan klibin gerçekten durduğunu doğrula.
8. Kod değişmişse değişime uygun mevcut testleri çalıştır: katalog, kaynak çözümleyici, model asset service, tur ve sahne testleri. İlgisiz kullanıcı değişikliklerini düzeltmeye çalışma. Başarısızlığı kaydet, başarı diye özetleme.

Tüm zorunlu kapılar kanıtlı geçmeden `validated`, canlı doğrulama olmadan `published` yazma. Her partinin sonunda geliştirilen, yalnız incelenen, engelli ve kalan modelleri ayrı say; kaynak belirsizliği varsa toplamı kesin canlı model sayısı olarak sunma.

## Oturum teslimi

Her model için değişiklik, animasyon gerekçesi, eski/yeni byte ve ölçüler, dosya/hash/revizyon, test sonucu ve açık riski kaydet. Kullanıcıya kısa bir parti özeti ve kayıt bağlantıları ver. Yarım kalan işin temel sürümünü ve somut sonraki adımını yaz. Kaynak dosyalarını, önceki sağlam sürümleri ve kullanıcı değişikliklerini koru. Yetki gerektiren veya erişilemeyen kaynakları kayıtta açıkça belirt; yapılmayan yayın veya görsel incelemeyi yapılmış gibi gösterme.
