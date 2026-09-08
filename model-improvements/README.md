# Model geliştirme kayıtları

> **Çalışma kullanıcı isteğiyle ertelendi.** Bu dosyalar ekip incelemesi ve daha sonra kaldığı yerden devam etmek içindir. Yeni kullanıcı talimatı gelmeden model geliştirmeye veya yayına devam etmeyin. Durum: [workflow-control.json](workflow-control.json).

Ana çalışma talimatı: [../prompt.md](../prompt.md).

## Başlangıç durumu — 7 Eylül 2026

Bu oturumda katalog ve sunumun model yükleme/animasyon kodu incelendi; yerel Anıtkabir GLB dosyasının yapısı okundu. Model geometrisi, materyali veya animasyonu değiştirilmedi; buluta yayın yapılmadı. Tam görsel model incelemesi henüz yapılmadı. **Geliştirilmiş: 0; yayınlanmış: 0.**

Yerel kaynaklar aynı kapsamı temsil etmiyor:

| Kaynak | Kayıt |
| --- | ---: |
| `tool/models-katalogu-duzenli.md` beyanı | 580 |
| `functions/scripts/models-raw.json` | 582 |
| `functions/scripts/models-raw-new.json` | 455 |
| `functions/scripts/models-tagged.json` | 1035 |
| JSON dosya adlarının birleşimi | 1037 |
| Dart katalog girdileri | 6 |
| Başlangıç envanterindeki aday kayıt | 1043 |

**1043, doğrulanmış benzersiz canlı model sayısı değildir.** Dart kayıtları bulut kayıtlarıyla aynı modele işaret edebilir. Örneğin kompresör, soğutma kulesi ve HVAC katalog kimlikleri uzak dosya adından farklıdır. Canlı Firestore/R2 mutabakatı yapılmadı. İsim benzerliğine dayanarak kayıt silinmedi veya birleştirilmedi.

## Dosyaların kullanımı

- `inventory.json`: bulunan kaynakların başlangıç aday listesi. Her aday `pending`; bulut kimlikleri doğrulanana kadar `modelId: null`. Dart kimlik doğrulaması yalnız kod içindeki kapsamı ifade eder.
- `records/_template.json`: gerçek model çalışması başladığında `<recordKey>.json` adıyla doldurulacak şablon. Şablon model sayısına dahil edilmez.
- `events.jsonl`: olayları yalnız sonuna ekle. Kaydın yapılmış olması modelin doğrulandığı anlamına gelmez.
- `reports/anitkabir-initial.json`: ölçülmüş dosya boyutu, hash, mesh/materyal sayısı ve klip yapısı; görsel ve çalışma zamanı testleri `not_run`.

Model başına güncel durum için `records` kayıtları, geçmiş için olay günlüğü kullanılır. Başlangıç envanterindeki durumlar bir ilerleme panosu değildir; ilerleme sayıları güncel model kayıtlarından hesaplanmalıdır. Bilinmeyen ölçümleri sıfırla doldurma.

## İlk somut bulgular

Anıtkabir GLB: 3.507.628 byte, 2001 düğüm, 272 mesh, 26 materyal. SHA-256 katalogla aynı. Bayrak kumaşı, ön ve arka sembol için üç ayrı morph animasyon klibi var. Birlikte oynatma gerçek uygulamada kontrol edilmeli; ayrık klipler için otomatik eşzamanlı oynatma varsayılmamalı. Mesh sayısı üçgen veya draw call sayısı değildir.

Anıtkabir paket öncelikli ve model bazlı pozlama değeri `0.003`. Global ışık ayarına müdahale etmeden incelemek gerekiyor. Kodda bu ayarın gömülü ışık şiddeti nedeniyle seçildiği açıklanmış; görüntü üzerinden henüz doğrulanmadı.

`assets/models/yolcu_ucagi.glb` ve `assets/models/gercekci_dunya.glb` katalogda tanımlı, ancak yapılan yerel dosya taramasında bulunmadı. Bu kayıtlar indirilebilir veya çalışıyor kabul edilmedi.

## İlk parti adayları

| Aday kimlik / dosya kökü | Katalog adı | İlk inceleme sorusu |
| --- | --- | --- |
| `Ambulans` | Ambulans | Tepe lambası parçaları ayrı mı, mevcut döngü nedir? |
| `helikopter_rotor_sistemi` | Helikopter Rotor Sistemi | Rotor pivotları ve birlikte çalışan parçalar doğru mu? |
| `elektrik_motoru_kesiti` | Elektrik Motoru Kesiti | Rotor/stator ayrımı ve şafta bağlı dönüş doğru mu? |
| `otomobil_parcalari_motor_sistemi` | Otomobil Parçaları Motor Sistemi | Görünen mekanizma hangi çevrimi anlatıyor? |
| `anitkabir` | Anıtkabir | Bayrağın kumaş ve sembol klipleri birlikte oynuyor mu? |

`311_ambulans_ic_duzeni` ayrı bir iç düzen modelidir; dış ambulansla aynı siren reçetesini otomatik uygulama. Bu adayların yerel GLB incelemesi Anıtkabir dışında yapılmadı.

## Eski sürüme dönüş korumasının mevcut sınırı

Kayıt sözleşmesi ve ilerleme zemini oluşturuldu. **Otomatik yayın engeli, koşullu revizyon güncellemesi ve uygulama önbelleğinde sürüm zorunluluğu henüz uygulanmadı.** Dolayısıyla yalnız bu dosyalar eski sürüme teknik olarak dönüşü engellemez. `prompt.md`, bunların nasıl kurulup doğrulanacağını zorunlu adımlar olarak tanımlar.

Sonraki işlem: canlı kimlik/nesne anahtarı mutabakatı, pilot kaynakların yetkili indirilmesi, önce görüntülerinin alınması ve ölçümlerin kaydedilmesi; ardından model başına geliştirme. Yayımlanmış duruma yalnız sunum içi doğrulamadan sonra geçilir.

## Oturum kaydı

Proje `AGENTS.md` dosyası Windows'taki `C:\Users\Emre\Documents\EmreOS` Atlas vault'una kayıt istiyor. Bu macOS oturumunda o yol kullanılabilir değil; Windows komutu çalıştırılmadı. Çalışma özeti bu dosyada ve `events.jsonl` içinde yerel olarak tutuldu.

## Pilot ilerleme — 7 Eylül 2026, ikinci oturum

**Geliştirme adayı: 1; yalnız incelenen: 0; engelli: 5; validated: 0; published: 0.** Başlangıç envanterindeki 1.037 diğer aday bu partide işlenmedi; canlı benzersiz model sayısı halen doğrulanmadı.

- **Anıtkabir r1:** bayrağın kumaş ve iki sembol klibi tek `Sutols_Functional_Loop` içinde birleştirildi; başlangıçtaki 1/24 saniyelik bekleme kaldırıldı. Yakın planda kumaşın ay-yıldızı örtmesi giderildi. Dosya 3.507.628 → 3.507.296 byte; fiziksel ölçüler, hareket zarfı, geometri ve materyaller aynı. Üç oynatma döngüsü ile duraklat/devam yerel model-viewer 4.3.1 testinde geçti. Validator 0 hata, kaynakla aynı 73 uyarı. [Tam rapor, önce/sonra ve aday dosya](reports/533a4fd62f2b3444/README.md), [güncel kayıt](records/533a4fd62f2b3444.json).
- **Ambulans, Helikopter Rotor Sistemi, Elektrik Motoru Kesiti, Otomobil Parçaları Motor Sistemi, Kalp Dolaşım Sistemi:** kaynak URL'leri HTTP 403; yetkisiz canlı Firestore isteği de 403. Yerel betiğin beklediği servis hesabı ve R2 `.env` dosyası bulunmadı. Dosyalar incelenmiş veya geliştirilmiş sayılmadı. [Erişim kanıtı](reports/pilot-access.json).
- Anıtkabir'in yayındaki hosting dosyası yerel temel ve Dart katalog SHA-256 değeriyle eşleşti. Uygulama dosyası/katalog metadata/bulut yayını değiştirilmedi. Gerçek editör, kayıt–yeniden açma, dışa aktarma, önbellek ve hedef cihaz performans kapıları açık.
- İlk tarayıcı testindeki başarısız denemeler ve `loop` bildirimi gelmemesi kaydedildi; üç döngü kontrolü gerçek oynatma zamanı dönüşleriyle doğrulandı. Bu düzeltme yalnız QA aracındadır; üretim renderer'ına yeni döngü eklenmedi.

Sonraki işlem: yetkili Sutols oturumu/yerel proje yapılandırmasıyla bulut pilotlarına erişim ve Anıtkabir r1 uygulama testleri. Oturum özeti burada ve eklemeli olay günlüğünde tutuldu; Windows Atlas yolu bu macOS ortamında kullanılamıyor.

## Kalıcı döngü ve devam kaydı — 8 Eylül 2026

1.043 adayın sırası `queue.sqlite3` içinde, okunabilir devam durumu [checkpoint.json](checkpoint.json) içinde saklanıyor. [Devam talimatı](RESUME.md) oturum/limit sonrası izlenecek adımları açıklıyor. Dosya kilidi, transaction, eklemeli olay outbox'ı, hash uyuşmazlığı ve kesinti sonrası tekrar olay yazmama kontrolleri için **8 test geçti**. Kuyruk durumu model geliştirme durumu değildir.

Şu an: **1 Anıtkabir adayı uygulama doğrulaması bekliyor; 1.040 uzak kaynak adayı dosya erişimi bekliyor; 2 paket kaynağı eksik.** Model kayıtlarında 1 candidate ve 7 blocked var. Uzak kaynakların 1.035'i tek tek indirilmedi/incelenmedi; ortak erişim önkoşulu nedeniyle kuyrukta bekliyor. Yeni model geliştirmesi veya yayın yapılmadı.

Chrome'daki oturumun girişli olduğu ve model aramasının çalıştığı doğrulandı; önceki sayfa başlığından yapılan giriş ekranı çıkarımı düzeltilmiştir. Ambulans seçimi kaynak bağlantısı oluşturuyor; dosyanın yerel alımı Cloudflare HTTP 403 / 1010 ile engelli. Dosya/gerçek Firestore kimliği ve görsel render doğrulanmış sayılmadı. [Erişim raporu](reports/browser-access-2026-09-08.json).

Sonraki ihtiyaç: projeye ait yetkili R2/Firestore geliştirme yapılandırması veya orijinal GLB kaynak klasörü. Kaynaklar hazır olduğunda pilot sırasından ve kayıtlı hash/revizyondan devam edilecek. Anıtkabir r1 yeniden üretilmeyecek. Windows Atlas yolu mevcut ortamda kullanılamadığından bu oturum özeti yerel kayıtlarla tutuldu.
