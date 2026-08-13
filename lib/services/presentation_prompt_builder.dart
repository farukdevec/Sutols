/// Sunum içeriği üreten bütün AI sağlayıcılarının aynı anlatı ve kalite
/// kurallarını kullanmasını sağlar.
class PresentationPromptBuilder {
  const PresentationPromptBuilder._();

  static String build({
    required String topic,
    required int slideCount,
    required String language,
    String referenceBlock = '',
  }) {
    return '''${referenceBlock}Kullanıcının verdiği konu hakkında tam olarak $slideCount slaytlık, baştan sona planlanmış bir sunum oluştur.

ÖNCE ÇIKTIYA YAZMADAN PLANLA:
- Sunum için tek bir ana tez ve mantıksal anlatı yolu belirle.
- $slideCount slaydın her birine benzersiz bir amaç ve alt konu ata.
- Akışı temelden ayrıntıya; açıklamadan örnek ve uygulamaya; değerlendirmeden sonuca ilerlet.
- 20 veya daha fazla slaytta içeriği 5-7 anlamlı bölüme ayır; ancak başlıklarda "Bölüm 1" gibi yapay adlar kullanma.

SUNUM DÜZENİ:
- İlk slayt konuya özgü güçlü bir açılış ve kapsam sunsun.
- İlk bölüm tanım, bağlam ve temel kavramları kursun.
- Orta bölüm farklı alt konuları, mekanizmaları, neden-sonuç ilişkilerini, örnekleri ve uygulamaları sırayla geliştirsin.
- Son bölüme yakın slaytlar karşılaştırma, sorunlar, sınırlılıklar, güncel durum ve gelecek perspektifi içersin.
- Son slayt yeni bilgi başlatmadan ana çıkarımları sentezlesin.
- Slayt sayısı azsa bu rolleri birleştir; hiçbir zaman aynı rolü tekrarlama.

İÇERİK KALİTESİ:
- Her slayt yalnızca kendi benzersiz alt konusunu anlatsın ve önceki slaydın doğal devamı olsun.
- Başlıkların tamamı birbirinden farklı, kısa ve konuya özgü olsun.
- Her content alanında 3-5 ayrı madde ve toplam yaklaşık 35-65 kelime kullan.
- Her maddede somut bilgi, açıklama, mekanizma, örnek, karşılaştırma veya çıkarım ver.
- Aynı bilgiyi farklı kelimelerle yeniden anlatma; bir bilgi yalnızca en uygun slaytta yer alsın.
- Aynı cümleyi, cümle kalıbını, giriş ifadesini veya maddeyi birden fazla slaytta kullanma.
- "Bu sunumda...", "Bu slaytta...", "Konuya genel bakış...", "önemli noktalar" gibi dolgu ve üst-anlatı ifadeleri kullanma.
- Giriş yalnızca ilk slaytta, özet yalnızca son slaytta bulunsun.
- Kesinliğinden emin olmadığın sayı, tarih, kişi veya kaynak uydurma.

ÇIKTI KURALLARI:
- Tam olarak $slideCount slayt üret; eksik veya fazla üretme.
- Her slaytta title, content ve keywords alanlarını doldur.
- content içindeki her madde ayrı satırda "- " ile başlasın.
- keywords, yalnızca o slaydın görsel ana fikrini temsil eden 3-8 somut nesne, kişi, yer, süreç veya kavram içersin.
- Komşu slaytların keywords listelerini gereksiz yere aynılaştırma.
- Tüm metinler "$language" dilinde olsun; Türkçe ise ç, ğ, ı, ö, ş, ü karakterlerini doğru kullan.
- İşletim sistemi bildirimi, yazılım uyarısı, lisans filigranı, bozuk kelime veya konu dışı metin üretme.
- Yalnızca geçerli JSON döndür; açıklama veya markdown kod bloğu ekleme.

Konu: $topic
''';
  }
}
