/// Sunum içeriği üreten bütün AI sağlayıcılarının aynı anlatı ve kalite
/// kurallarını kullanmasını sağlar. İstemleri sistem talimatı ve dinamik kullanıcı
/// mesajı olarak ikiye ayırarak token kullanımını optimize eder.
class PresentationPromptBuilder {
  const PresentationPromptBuilder._();

  /// Statik kalite, anlatı ve yapı kurallarından oluşan Sistem Talimatı.
  /// API tarafında önbelleklenebilir (Context Caching).
  static String buildSystemInstruction() {
    return '''Sen akademik ve kurumsal standartlarda sunum içeriği üreten uzman bir asistansın.

TEMEL PLANLAMA VE ANLATI KURALLARI:
- Sunumu baştan sona tek bir ana tez ve mantıksal anlatı doğrultusunda yapılandır.
- Akışı temelden ayrıntıya; açıklamadan örnek ve uygulamaya; değerlendirmeden sonuca ilerlet.
- Başlıkların tamamı birbirinden farklı, kısa ve konuya özgü olsun.
- Her slayt içeriğinde 3-5 ayrı detaylı açıklama maddesi (toplam 35-65 kelime) bulundur.
- Her maddede somut bilgi, mekanizma, örnek veya karşılaştırma ver.
- Aynı cümleyi, cümle kalıbını veya bilgiyi birden fazla slaytta tekrarlama.
- "Bu sunumda...", "Bu slaytta...", "Konuya genel bakış" gibi dolgu ifadeler KESİNLİKLE KULLANMA.
- ARAYÜZ VE SİSTEM METNİ YAZMA: Slaytlara "sürükleme kolu", "drag_handle", "sahne kartı", "seçili sayfa" gibi yazılım talimatları ekleme.

ÇIKTI FORMATI:
- Yanıtı istenen dilde, Türkçe ise ç, ğ, ı, ö, ş, ü karakterlerine dikkat ederek ver.
- Slayt içerik maddeleri satır başında "- " ile başlamalıdır.
- Slayt anahtar kelimeleri (keywords), 3B modeller ve fiziksel nesnelerle doğrudan eşleşebilecek 3-8 somut nesne, araç veya yapı adı içermelidir.''';
  }

  /// Konuya özgü dinamik kullanıcı istemi.
  static String buildUserPrompt({
    required String topic,
    required int slideCount,
    required String language,
    String referenceBlock = '',
  }) {
    return '''${referenceBlock}Konu: $topic
Slayt Sayısı: $slideCount
Çıktı Dili: $language''';
  }

  /// Geriye dönük uyumluluk için birleşik istem metni.
  static String build({
    required String topic,
    required int slideCount,
    required String language,
    String referenceBlock = '',
  }) {
    return '''${buildSystemInstruction()}

${buildUserPrompt(topic: topic, slideCount: slideCount, language: language, referenceBlock: referenceBlock)}''';
  }
}
