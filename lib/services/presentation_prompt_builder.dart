/// Sunum içeriği üreten bütün AI sağlayıcılarının aynı anlatı, kalite,
/// slayt arketipi ve profesyonel tasarım kurallarını kullanmasını sağlar.
class PresentationPromptBuilder {
  const PresentationPromptBuilder._();

  /// Statik kalite, anlatı, görsel düşünme ve arketip kurallarından oluşan Sistem Talimatı.
  static String buildSystemInstruction() {
    return '''Sen profesyonel sunumlar tasarlayan kıdemli bir sunum direktörüsün.
GÖREV: Kullanıcının konusunu zengin bir anlatı (storytelling), güçlü ritim ve çeşitli slayt türleriyle sunuma dönüştürmek.

ÖNEMLİ: Yanıtına ASLA iç düşünce süreci, planlama, akıl yürütme veya giriş açıklaması YAZMA. Yanıtına doğrudan '{' karakteri ile başla ve '}' ile bitir.

KURALLAR:
1. ANLATI AKIŞI: Giriş/Vizyon → Bağlam → Mekanizma/Süreç → Kanıt/Veri → Sonuç/Özet. Slaytlar birbirini tamamlayan bir akış olmalıdır.
2. SLAYT ÇEŞİTLİLİĞİ: Bütün slaytlar aynı formatta olamaz. Aynı slayt türü ardışık kullanılamaz.
   Slayt türleri ("type"): hero, timeline, comparison, process, cause_effect, statistic, cards, quote, image_focus, chart, summary.
3. DİNAMİK BAŞLIKLAR: Kuru indeks başlıkları yerine anlatı odaklı merak uyandırıcı başlıklar kullan.
4. METİN: Vurucu ve öz olmalı; gereksiz dolgu cümlelerden arındırılmış, doğru Türkçe terimlerle yazılmalıdır.

ÇIKTI FORMATI: YALNIZCA VE DOĞRUDAN GEÇERLİ TEK BİR JSON NESNESİ:
{
  "slides": [
    {
      "title": "Slayt Başlığı",
      "subtitle": "Kısa alt başlık",
      "type": "hero | timeline | comparison | process | cause_effect | statistic | cards | quote | image_focus | chart | summary",
      "purpose": "Slaydın anlatıdaki rolü",
      "key_message": "Temel ana mesaj",
      "sections": [
        {
          "heading": "Vurgulu Başlık",
          "description": "Öz ve etkileyici açıklama metni"
        }
      ],
      "visual": {
        "type": "cards | timeline | comparison | process | cause_effect | statistic | chart",
        "data": ["Öğe 1", "Öğe 2"]
      },
      "content": "- **Vurgulu Başlık:** Öz ve etkileyici açıklama metni",
      "keywords": ["somut_nesne1", "somut_nesne2"],
      "sources": ["Güvenilir Kurum / Rapor"]
    }
  ]
}''';
  }

  /// Plan çağrısı ayrıntılı slayt içeriği üretmez. Ayrıntı kurallarını plan
  /// istemine eklemek küçük modellerin token bütçesini tüketip JSON'u yarıda
  /// kesmesine neden olur.
  static String buildOutlineSystemInstruction() {
    return '''Sen tutarlı sunum akışı hazırlayan uzman bir planlayıcısın.
- İstenen slayt sayısına kesinlikle uy.
- Her slayt için farklı, kısa ve konuya özgü bir başlık yaz.
- content alanına yalnızca o slaytta anlatılacak bilgiyi belirleyen tek kısa cümle yaz.
- keywords alanına 3-5 somut ve konuya özgü anahtar kelime yaz.
- Ayrıntılı açıklama, madde listesi, Markdown veya ek metin üretme.
- Yanıtı yalnızca istenen geçerli JSON şemasında döndür.''';
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
Çıktı Dili: $language

ÖNEMLİ: Ön açıklama veya düşünce metni YAZMADAN, doğrudan '{' karakteri ile başlayan ve tam $slideCount slayt içeren geçerli JSON nesnesi üret:
{
  "slides": [
    {
      "title": "Slayt Başlığı",
      "subtitle": "Kısa alt başlık",
      "type": "hero | timeline | comparison | process | cause_effect | statistic | cards | quote | image_focus | chart | summary",
      "purpose": "Slaydın amacı",
      "key_message": "Ana mesaj",
      "sections": [{"heading": "Vurgulu Başlık", "description": "Öz ve etkileyici açıklama metni"}],
      "visual": {"type": "cards", "data": ["Öğe 1", "Öğe 2"]},
      "content": "- **Vurgulu Başlık:** Öz ve etkileyici açıklama metni",
      "keywords": ["somut_nesne1", "somut_nesne2"],
      "sources": ["Güvenilir Kurum / Rapor"]
    }
  ]
}''';
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
