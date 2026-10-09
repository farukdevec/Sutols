# Katalog etiket ve kategori düzeltmesi — 9 Ekim 2026

## Bulgu
Kategori filtresi ham kategori değerini birebir karşılaştırıyordu. Eski katalogda biyoloji modelleri analiz-modeli ve diyagram kategorilerinde de bulunuyor. Yerel 1035 kayıtlık eski metadata örneği canlı katalog değildir; kullanıcının bildirdiği 1143 canlı toplam ayrıca doğrulanmalıdır.

## Uygulama
- Bulut, paket ve kalıcı önbellek kayıtlarında deterministik, idempotent metadata zenginleştirme.
- Kategori yazımı, harf ve tire farklarının standartlaştırılması.
- Manuel keşifte çoklu konu kategorileri; örneğin organel hem Analiz Modelleri hem Biyoloji filtresinde bulunabilir.
- Somut kavramların Türkçe/İngilizce eşanlamlı etiketleri; genel konu etiketleri otomatik yerleştirme etiketlerine eklenmez.
- Yazılım virüsü, galvanik ve yakıt hücresi için biyolojiye yanlış dahil olma koruması.
- Kimlik, dosya bağlantısı, üyelik ve excludeTags korunur. Dosya indirmesi veya model dosyasının çözülmesi gerekmez.
- Arama kategorileri indeks hazırlanırken hesaplanır; her tuşta yeniden hesaplanmaz.

## Doğrulama
35 ilgili test başarılı, Flutter analyze temiz. 1035 kayıtlık eski örnekte Biyoloji keşfi 141 kayıt buldu; bu canlı sayı veya görsel olarak incelenmiş model sayısı değildir. CRISPR, Golgi, mitokondri ve ribozom regresyonları kontrol edildi. Kategori çakışmaları kasıtlıdır; kategori toplamları genel model toplamını aşabilir.

## Sınırlar
Firestore kaydı yerinde değiştirilmez; uygulama katalog yüklerken düzeltme uygular. Ham kaynak kayıtları korunur. Canlı girişli hesaptaki 1143 model ve nihai kategori sayıları ayrıca kullanıcı oturumunda kontrol edilmelidir. Atlas Windows vault bu Mac ortamında mevcut olmadığı için bu kayıt yerel proje raporuna yazılmıştır.
