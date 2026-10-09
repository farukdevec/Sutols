# Sutols canlı yayın ve kullanıcı testi — 9 Ekim 2026

## Yayın sonucu

- Uygulama commit'i: `8d06ba0fce2f2ff2736ee8117447e35e898c0b0f`; GitHub main dalına push başarılı.
- Canlı site: https://sutols.com/ — tarayıcıda normal ana sayfa ve giriş ekranı açıldı.
- Firebase Hosting: https://sutols.web.app/ — Hosting-only deploy başarılı. Functions, Worker, yetkilendirme ve kurallar değiştirilmedi.
- Yayımlanan main.dart.js SHA-256: `e80a16c9b04fa715b9c90d0f7f11b2b71f7ad7e5278710ffe7c5f1a6eb84bc95`.
- Kaynak SHA-256: `afa4c3b91e0d1605d3920c3442816e625d4ee7d3f6e0df39e4533fe88d5248c9`.
- Canonical Hosting manifesti ve uygulama dosyası yerel web-final-34 ile eşleşti. Örnek water-molecule-lite.glb HTTP 200; dosya özeti katalogla eşleşti.
- Önceki canlı sürümün geri dönüş kopyası: https://sutols--rollback-20261009-p29bipsy.web.app
- Gerekirse geri dönüş komutu: `firebase hosting:clone sutols:rollback-20261009 sutols:live --project sutols --account sutolsofficial@gmail.com` (çalıştırılmadı).
- İlk deploy 403 ile reddedildi; yapılandırma konumundan kaynaklanan hesap seçimi açıkça mevcut doğru hesaba bağlanarak çözüldü. Yetkiler genişletilmedi.
- Custom domain manifestinin ham isteği 403 döndü; tarayıcıda aynı manifest URL'si istemci güvenlik engeline takıldı. Engel aşılmadı. Custom domain dosya özeti ayrıca doğrulanmış sayılmıyor; canonical Hosting doğrulaması başarılı.

## Gerçek tarayıcıda tamamlanan senaryolar

| Senaryo | Gözlenen sonuç |
| --- | --- |
| Ana sayfa ve zorunlu çerez seçimi | Form ve site bağlantıları açıldı. |
| Konu boşken Oluştur | İşlem sessizce durdu; kullanıcıya açıklama çıkmadı. |
| Başlık, konu ve 3 sayfa seçimi | Yazılan değerler ve seçim arayüzde doğrulandı. |
| Girişsiz geçerli form gönderimi | Giriş gerektiği uyarısı ve Giriş Yap yönlendirmesi çalıştı. |
| Giriş ekranı | E-posta, şifre, sosyal giriş ve yardım bağlantıları göründü. |
| Boş giriş formu | Geçersiz e-posta adresi mesajı gösterildi; geçerli hesap kullanılmadı. |
| SSS sorularını açma ve geri dönüş | Yanıtlar açıldı; geri dönüşte sayfa başlığı SSS olarak kaldı. |
| Ayarlar paneli | Açıldı ve kapatıldı; kullanıcı tercihleri değiştirilmedi. |
| Konsol gözlemi | Ayrı misafir test sekmesinden okunan warn/error listesi boştu; tüm uygulama için hatasızlık garantisi değildir. |

## Bulgular ve önerilen sıra

| Öncelik | Bulgu | Etki ve düzeltme önerisi |
| --- | --- | --- |
| P1 | Canlı AI testlerinde içerik kalitesi ve slayt sayısı uyuşmazlığı | Çernobil benchmark'ında kalite reddi; madde durumlarında en az 6 yerine 4, diğer Çernobil testinde 10 yerine 9 slayt. Üretim yanıtının istenen sayıya ve içerik kalite koşullarına uyumu doğrulanmalı; başarısız durumda anlaşılır uyarı/yeniden deneme sunulmalı. Bunlar CI üzerinden canlı servis gözlemleridir; hesapla manuel test yerine geçmez. |
| P2 | Boş konu alanında etkin Oluştur düğmesi sessizce sonuçsuz kalıyor | Kullanıcı uygulamanın yanıt vermediğini düşünebilir. Konu alanına zorunluluk mesajı ve odak verilmeli. `lib/ui/home_page.dart` içindeki boş konu erken dönüşü de gözlemi destekliyor. |
| P2 | Şifre görünürlük düğmesinin erişilebilir adı yok | Ekran okuyucuda işlev anlaşılmıyor. Şifreyi göster/gizle etiketi eklenmeli. |
| P2 | Üç golden testi mevcut referans görsellerle eşleşmiyor | Giriş 1.24%, editör 800x800 47.15%, editör 390x844 23.45%. Tasarım farkları insan tarafından incelenmeli; referanslar körlemesine güncellenmemeli. |
| P3 | SSS'den ana sayfaya dönünce belge başlığı güncellenmiyor | Sekme adı, erişilebilirlik ve gezinme tutarlılığı bozuluyor. Route geri dönüşünde başlık güncellenmeli. |
| P3 | İndirme yardımında yalnızca HTML anlatılıyor | PDF ve proje JSON akışlarıyla yardım metni eşleştirilmeli; desteklenen koşullar açıklanmalı. |
| P3 | Model yardımında binlerce profesyonel varlık ifadesi var | Bulut katalog sayısı bu testte doğrulanmadı. Özgün şematik modeller, kalite seviyeleri ve bulut katalog kapsamı açık anlatılmalı; toplam sayı gerçek kataloğa dayanmalı. |

## Otomatik doğrulama ve sınırlar

GitHub CI: https://github.com/farukdevec/Sutols/actions/runs/37885674101

Bu run: **568 geçti, 6 başarısız, 2 atlandı**. Üç başarısızlık canlı AI üretim testlerinde, üçü golden karşılaştırmalarında. Önceki main commit'inin CI durumu da başarısızdı; tüm nedenlerin aynı olduğu iddia edilmez.

Yerel kontrollü test paketi: **565 geçti, 3 golden başarısız, 2 atlandı**, 90 dosya; altı production bağımlı test dosyası dışarıda bırakılmıştı. Ek sahne yaşam döngüsü/bağlam toparlama kontrolleri geçti. Bu iki test kapsamı farklıdır.

CI iyileştirmesi: Flutter sürümü sabitlenmeli; kontrollü regresyon testleri ve ayrıca açıkça başlatılan canlı AI benchmark'ları ayrılmalı. Canlı kalite başarısızlıkları saklanmamalı veya beklentiler sırf yeşil sonuç için gevşetilmemeli.

Functions tarafındaki önceden saptanan 15 TypeScript hatası bu Hosting yayınına dahil edilmedi. Önceki proxy kaynak bağlantısı eksikliği de giderilmiş sayılmıyor.

## Henüz doğrulanmayanlar

Mevcut test hesabıyla kullanıcı girişi istendi; bu rapor hazırlanırken giriş tamamlanmadı. **Canlı hesapla sunum üretme, model arama/ekleme, editör–önizleme geçişi, otomatik kayıt, yeniden açma ve HTML/PDF/JSON indirme manuel olarak test edilmedi.** Bu akışlar için test sonucu başarılı yazılmamıştır.

Yeni 100 özgün şematik modelin varlıkları yayınlandı; insan görsel/öğretimsel kabulü hâlâ açık. Gerçek Android/iOS, GPU güç/bellek ölçümü, bulut kataloğunun toplam sayısı, insan etiket değerlendirmesi ve pilot kullanıcı kabulü tamamlanmadı. A0–A10 planının bütünü tamamlandı sayılmaz.

Ekran kanıtları çalışma alanı outputs klasöründe: SUTOLS_CANLI_ANA_SAYFA.png, SUTOLS_CANLI_GIRIS_YONLENDIRMESI.png, SUTOLS_CANLI_SSS.png. Ayrıntılı komut kanıtları work klasöründedir. Bu rapor bulguları kaydeder; belirtilen hatalar bu yayın sonrasında düzeltilmiş değildir.
