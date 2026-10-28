# Sutols düzeltme raporu — 9 Ekim 2026

## Uygulanan düzeltmeler

- Boş veya yalnız boşluk içeren konuda Oluştur işlemi açıklama gösterir ve konu alanına odak verir. Başlık isteğe bağlı kalır; mevcut otomatik sunum oluşturma amacı korunur.
- Sunum üretim hatası kullanıcıya anlaşılır mesaj ve Yeniden dene eylemi gösterir. Teknik hata ayrıntıları kullanıcı mesajından çıkarılmıştır.
- SSS'den ana sayfaya geri dönüşte sekme başlığı Sutols olarak geri yüklenir.
- Şifre görünürlük düğmesi Şifreyi göster / Şifreyi gizle etiketlerini taşır.
- Türkçe ve İngilizce yardım metinleri HTML, PDF ve proje JSON çıktısını anlatır. PDF'nin tarayıcı yazdırma penceresinden kaydedildiği, HTML için varlık erişiminin gerektiği açıklanır.
- Doğrulanmamış binlerce profesyonel model iddiası kaldırılır; yerel şematik modeller ve erişilebilir bulut katalogları ayrı anlatılır.
- Mobil tuval yardım metni görünür alanla sınırlanır ve seçili nesnenin üzerine gelmez.
- AI üretimi ve revizyonunda istenen slayt sayısı zorunludur. Mock HTTP istemcisi ile gerçek HTTP istemcisi aynı kabul kontrolünden geçer. Grok/Gemini yedekleri de eksik slaytla başarılı sayılmaz.
- Uzun sunumlarda en çok üç eksik slayt için, bir kez, yalnız eksik içeriği üretme isteği yapılabilir. Mevcut slaytlar korunur; birleşik sunum tekrar içerik kalite kontrolünden geçer. Boş veya kopya slaytlarla sayı tamamlanmaz.
- Döngüsel/tekrarlı veya düşük puanlı içerik için tek hedefli revizyon denenir. Hatalı sayı veya içerikteki revizyon kabul edilmez. Varsayılan servis yolunda yalnız geçersiz sunum yanıtı için bir taze üretim denemesi yapılabilir; ağ ve yetki hataları bu denemeyi tetiklemez. Süre bütçesi kontrolleri ve mevcut kalite eşikleri korunur. Bu kurtarma işlemleri sorunlu yanıtlarda gecikmeyi ve AI çağrı sayısını artırabilir.
- Revizyon istemi değişmeyen slaytlar dahil bütün dizinin dönmesini açıkça ister. Başlık, hedef kitle ve öğrenme amacı, yanıt bunları içermiyorsa asıl sunumdan korunur.
- Görsel testler gerçek ürün fontlarını ve önceden yüklenmiş logoları kullanır. Inter/Roboto alt kümeleri mevcut kaynaklardan TTF biçimine dönüştürülür; karakter haritaları/glif sırası doğrulanır, kaynak/çıktı özetleri kaydedilir ve mevcut lisanslar korunur. Linux'un WOFF2 yükleyemediğinde kare metin üretmesi doğru referans kabul edilmemiştir. macOS/CoreText ve Linux/FreeType için düzgün çizilmiş, incelenmiş ayrı referanslar kullanılır; iki platformda da karşılaştırma tamdır.
- CI Flutter 3.38.9 sürümüne sabitlenir. Kontrollü regresyonlar her push'ta çalışır; canlı AI benchmark'ları açıkça başlatılan seçenekle ayrı çalıştırılır ve başarısızlıkları raporlanır. Test kanıtları artifact olarak saklanır.
- Analizi engelleyen dokuz eski uyarı/bilgi giderilir: kullanılmayan özel kod/parametre ve importlar temizlenir; dropdown güncel initialValue API'sine geçirilir.

## Doğrulama

- Son yerel kontrollü paket: **579 başarılı, 2 atlanan test; başarısızlık yok**, 92 test dosyası. Altı production bağımlı dosya bu pakete dahil değildir.
- Odaklı testler boş form/odak, route geri dönüş başlığı, yanlış sayıda yanıt/revizyon, sınırlı yeniden üretim, eksik slayt tamamlama ve revizyon metadata korumasını kapsar.
- Yerel üç golden kontrolü geçer. Referanslar gerçek fontlarla görsel olarak incelenmiştir; karşılaştırma toleransı gevşetilmemiştir.
- Son commit'in toplu canlı AI turu: **3 test başarılı**, istenen **10, 7 ve 10 slayt** üretildi. Slayt sayısı ve kalite beklentileri gevşetilmedi. Bu otomatik puanlar insan/uzman içerik değerlendirmesi değildir.
- Genel analiz: **hata/uyarı yok**. Son web release derlemesi başarılı.
- Normal push CI: https://github.com/farukdevec/Sutols/actions/runs/37889781728 — **başarılı**, Linux'ta 579 başarılı / 2 atlanan test ve analiz.
- Canlı AI dahil CI: https://github.com/farukdevec/Sutols/actions/runs/37889781760 — **başarılı**, kontrollü testler + üç production benchmark + analiz.
- Canlı tarayıcı: boş konuda uyarı ve odak, SSS'den geri dönüşte Sutols başlığı, HTML/PDF/JSON yardım metni, doğru model katalog açıklaması ve şifre göster/gizle erişilebilir adları doğrulandı. Okunan misafir test sekmesinde konsol hata/uyarı listesi boştu; work/fix-live-console.json dosyasına kaydedildi.
- Ekran kanıtı: `SUTOLS_CANLI_BOS_KONU_DUZELTILDI.png` (outputs klasörü).

## Yayın ve kalan kabul sınırları

Uygulama commit'i: `a028d36652a55ab78531764063322ef1c480942c`; önceki düzeltme `93bc7eb`. Test referansı/CI commit'i: `f33f0df` (uygulama kaynakları aynı).

Firebase **Hosting-only yayın başarılı**: https://sutols.com/ ve https://sutols.web.app/

Canonical Hosting kaynağı, JS dosyası ve örnek native TTF dosyası yerel paketle SHA-256 üzerinden eşleşti. Custom domain'de gerçek arayüz kontrol edildi; ilk incelemedeki manifest URL güvenlik engeli aşılmadı ve bu URL için ayrıca dosya özeti doğrulaması iddia edilmiyor.

- Kaynak SHA-256: `77819feec3204a84cb8792c51034e0f806d119fbbeff34d5167eaa4ed59601d2`
- main.dart.js SHA-256: `3222345be7e4ec25d0c3393c6d707ae7e8bb1d697fd41b7317e677b8c01141f1`
- Paket: web-fixes-36. Sunucudaki manifest paket hazırlığını, outputs yayın özeti ise başarılı deploy sonucunu kaydeder.

Önceki canlı sürümün kopyası: https://sutols--before-fixes-20261009-embje0ey.web.app

Hosting dışındaki Functions/Worker/yetkilendirme değişiklikleri bu düzeltme kapsamına dahil değildir. İlk yeniden testlerde 9/10 ve 3/7 yanıtları gözlendi. İstemci kabul, tamamlama ve tekrar üretim adımları bu gözleme dayanır; son toplu CI turu geçti. Hatalı yanıt başarılı sunum olarak sunulmaz.

Mevcut test hesabıyla kullanıcı girişi henüz tamamlanmadığı için canlı hesapla editör, kayıt/yeniden açma ve dosya indirme kabulü açık kalır. İnsan model/etiket değerlendirmesi ve fiziksel cihaz/GPU güç-bellek ölçümleri bu raporla tamamlandı sayılmaz.

Atlas yönergesindeki Windows vault/PowerShell yolu bu macOS ortamında kullanılamadığı için oturum kaydı yerel proje durum dosyalarında tutulur.
