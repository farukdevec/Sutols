# Tüm katalog arama ve kategori düzeltmesi — 9 Ekim 2026

## Kök neden
Önceki düzeltme Biyoloji aliasını kapsarken Uzay, Doğa, Coğrafya ve Uzay, Fizik, Kimya ve eski bulut kategori adlarını ayrı bıraktı. Bu nedenle bir kategori çipinde tek kayıt görülmesi, o konuda yalnızca tek model olduğu anlamına gelmiyordu.

## Değişiklikler
- Eski slug, Türkçe, İngilizce ve yeni paket kategori adları ortak konu filtrelerine bağlandı.
- Ad, dosya kimliği, Türkçe/İngilizce etiket ve konu kategorileri ortak indeks içinde aranır. Dosya kimliklerinde bulanık eşleşme yapılmaz; uçak kimliği plane ile planet karışmaz.
- Uzay, coğrafya, fizik, kimya, elektronik, mühendislik, matematik, enerji, ulaşım, eğitim ve diğer konular için keşif terimleri genişletildi.
- Somut nesneler için çift dilli eşanlamlı etiketler eklendi. Zenginleştirme tekrar yüklemelerde aynı sonucu verir; önbellek ve bulut kayıtlarına uygulanır.
- model, modeli, 3D gibi arama dolgu sözcükleri sonuçları gereksiz yere elemez.
- Filtrelerde toplam model sayısı gösterilir. Kategoriler çoklu olabilir, sayıları toplam model sayısına eklenmemelidir.
- Finansal hedef dağı, vizyon teleskobu, yazılım virüsü ve fabrika üretim hücresi gibi yanlış konu adayları için regresyon kontrolleri eklendi.

## Veri ve doğrulama
Yerel üç eski katalog dosyası 1037 farklı dosya kimliği içeriyor. Uygulama paketindeki 106 modelle test kataloğu 1143 kayıt oldu. Bu sayı kullanıcının bildirdiği canlı toplamla eşleşse de canlı kayıtların aynı içerik olduğunu kanıtlamaz.

1143 kaydın her biri adıyla ve kimliğiyle bulunuyor; kayıp ad sorgusu yok. Bu test kataloğunda Doğa ve Coğrafya 148, Uzay ve Astronomi 39 model içeriyor. Ayrıntılar SUTOLS_TUM_KATALOG_ARAMA_DENETIMI.json içinde.

Flutter test paketi: 585 başarılı, 2 atlanan. Son indeks optimizasyonundan sonra 6 odaklı test tekrar başarılı. Flutter analyze temiz. Backend tip kontrolü değiştirilmeyen functions/src/index.ts içinde önceden mevcut 3 kullanılmayan değişken hatası bildirdi (jwks, signature, header); Hosting değişikliği backend yayını içermiyor.

## Sınırlar
Girişli canlı 1143 kayıt bu ortamda henüz okunamadı; açık canlı sekme hâlâ giriş ekranında. Kaynak Firestore belgeleri yerinde değiştirilmez, katalog okumasında deterministik düzeltme uygulanır. Güvenlik, üyelik, dosya kimliği, asset bağlantısı ve negatif etiketler korunur. Model dosyalarının geometrisi değiştirilmedi.

Atlas Windows vault bu Mac ortamında mevcut olmadığı için oturum kaydı bu proje raporunda tutuldu.
