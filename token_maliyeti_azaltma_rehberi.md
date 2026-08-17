# Token Maliyetlerini Azaltma Stratejisi ve Uygulama Rehberi

## Slayt 1: Giriş ve Kapsam

- **Temel Hedef:** Sutols sunum oluşturma altyapısındaki yapay zekâ token tüketimini ve API maliyetlerini %50 ile %70 arasında azaltmak.
- **Kapsam:** İstem mimarisi optimizasyonu, API önbellekleme mekanizmaları, dinamik yanıt sınırlandırma ve katmanlı model kullanımı.
- **Odak Soru:** Sunum kalitesinden ve içeriğin derinliğinden ödün vermeden jeton maliyetleri nasıl en düşük seviyeye çekilebilir?

---

## Slayt 2: Mevcut Durum Analizi

- **Tekrarlayan İstem Yükü:** Her API çağrısında yaklaşık 500 token büyüklüğündeki statik kurallar ve JSON şema tanımları isteme yeniden eklenmektedir.
- **Çiftlenmiş Şema Tanımları:** Gemini API üzerindeki `responseSchema` özelliğine rağmen metin içerisinde 150 token'lık manuel JSON yapısı talimat olarak verilmektedir.
- **Sınırsız Yanıt Uzunluğu:** API yanıtlarında üst token sınırı tanımlanmadığı için AI modelleri gereksiz uzun açıklama satırları üreterek çıktı maliyetini artırmaktadır.
- **Tek Tip Model Kullanımı:** Basit ve karmaşık tüm istem süreçlerinde aynı yüksek maliyetli model tercih edilmektedir.

---

## Slayt 3: İstem Sıkıştırma ve Şema Optimizasyonu

- **Statik Metin Budama:** İstem içerisindeki tekrarlayan JSON şema örnekleri ve gereksiz dolgu cümleleri istemden çıkarılmalıdır.
- **Yapılandırılmış Veri Kullanımı:** Yapay zekâ servisinin yerel şema doğrulayıcısı aktif edilerek metin tabanlı kural anlatımı 15 token düzeyine düşürülmelidir.
- **Sistem İstemcisi Ayrıştırması:** Sabit kalite kuralları kullanıcı mesajından ayrılıp sistem rolüne (`systemInstruction`) aktarılmalıdır.
- **Tekil Sorumluluk İlkesi:** İstem metni yalnızca dinamik konu, slayt sayısı ve dil parametrelerini içerecek şekilde hafifletilmelidir.

---

## Slayt 4: Bağlam Önbelleğe Alma Entegrasyonu

- **Statik Ön Eki Önbellekleme:** Sistem istemleri ve genel sunum kuralları API sağlayıcı tarafında önbelleğe alınarak girdi maliyetleri düşürülmelidir.
- **Geçmiş Referans Yapılandırması:** Benzer sunum örneklerinin tam metinleri yerine yalnızca başlık ve düzen bilgileri önbelleğe uygun formatta sunulmalıdır.
- **Veri Tabanı Okuma Optimizasyonu:** Geçmiş sunum sorgularında yalnızca gerekli alanlar çekilerek ağ ve token yükü en aza indirilmelidir.
- **Tekrarlayan Çağrı Engelleme:** Aynı konu başlıkları için üretilen yapılar önbellekte saklanarak mükerrer API istekleri önlenmelidir.

---

## Slayt 5: Çok Katmanlı Model Seçimi ve Yanıt Sınırı

- **Dinamik Çıktı Sınırı:** Slayt adedine göre değişkenlik gösteren üst token sınırı (`maxOutputTokens`) tanımlanarak gereksiz çıktı üretimi engellenmelidir.
- **Katmanlı Model Mimarisi:** Taslak ve anahtar kelime üretiminde düşük maliyetli hızlı modeller, nihai sunumda ise gelişmiş modeller kullanılmalıdır.
- **Düzgün Hata Düşüşü:** AI servislerine ulaşılamadığı durumlarda maliyetsiz yerel şablon üretecine (Fallback Engine) geçiş sağlanmalıdır.
- **Kota ve Kullanım Takibi:** Kullanıcı seviyesinde günlük kullanım sınırları API çağrısı öncesinde kontrol edilerek gereksiz tüketim engellenmelidir.

---

## Slayt 6: Yerel Algoritmalar ve Önbellek Mimari

- **Deterministik İçerik Üretimi:** Basit konu başlıkları ve standart sunum yapıları için yerel kelime kütüphanesi tercih edilmelidir.
- **Sözlük Bazlı Eşleştirme:** 3B model ve arka plan seçimleri yapay zekaya yaptırılmak yerine istemci tarafındaki anahtar kelime motoru ile gerçekleştirilmelidir.
- **Toplu Veri İşleme:** Firestore üzerindeki slayt kayıt işlemleri tekil istekler yerine toplu commit yapısıyla yürütülmelidir.
- **İstemci Tarafı Ön Bellekleme:** Sık kullanılan model katalogları yerel bellekte tutularak veritabanı okuma maliyeti sıfırlanmalıdır.

---

## Slayt 7: Sonuç ve Kazanç Sentezi

- **Girdi Token Tasarrufu:** İstem sıkıştırma ve bağlam önbellekleme ile girdi jetonlarında %60 tasarruf elde edilmektedir.
- **Çıktı Token Denetimi:** Dinamik yanıt sınırlandırma sayesinde çıktı maliyetleri %45 oranında azaltılmaktadır.
- **Toplam Maliyet İyileşmesi:** Uygulanan teknik adımlarla sistem geneli yapay zekâ maliyetlerinde ortalama %65 düşüş sağlanmaktadır.
- **Sistem Performansı Artışı:** Küçülen istem boyutları sayesinde API yanıt süreleri belirgin şekilde hızlanmaktadır.
