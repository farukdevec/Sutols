import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

/// Gemini'nin response_schema ile zorladığı tek slayt yapısı.
class GeminiSlide {
  final String title;
  final String content;
  final List<String> keywords;

  const GeminiSlide({
    required this.title,
    required this.content,
    required this.keywords,
  });

  factory GeminiSlide.fromJson(Map<String, dynamic> json) {
    return GeminiSlide(
      title: json['title'] as String,
      content: json['content'] as String,
      keywords: (json['keywords'] as List).cast<String>(),
    );
  }
}

/// Üst düzey yanıt yapısı: { "slides": [...] }
class GeminiPresentation {
  final List<GeminiSlide> slides;

  const GeminiPresentation({required this.slides});

  factory GeminiPresentation.fromJson(Map<String, dynamic> json) {
    return GeminiPresentation(
      slides: (json['slides'] as List)
          .map((s) => GeminiSlide.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GeminiPresentationService {
  GeminiPresentationService({FirebaseAI? ai}) : _ai = ai ?? FirebaseAI.googleAI();

  final FirebaseAI _ai;

  // Güncel model listesi: https://firebase.google.com/docs/ai-logic/models
  static const String modelName = 'gemini-3.6-flash';

  static Schema _slideSchema() {
    return Schema.object(
      properties: {
        'title': Schema.string(),
        'content': Schema.string(),
        'keywords': Schema.array(items: Schema.string()),
      },
    );
  }

  /// Konu metnine göre Gemini'den JSON sunum yapısı üretir.
  ///
  /// [slideCount] kadar slayt istenir; [language] ile çıktı dili belirlenir.
  /// Yanıt, response_schema ile { slides: [{title, content, keywords}] }
  /// biçimine zorlanır.
  Future<GeminiPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
  }) async {
    final model = _ai.generativeModel(
      model: modelName,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'slides': Schema.array(
              items: _slideSchema(),
              minItems: slideCount,
              maxItems: slideCount,
            ),
          },
        ),
      ),
    );

    final prompt = '''
Kullanıcının verdiği konu hakkında $slideCount slaytlık bir sunum yapısı oluştur.

Kurallar:
- Tam olarak $slideCount slayt üret.
- Her slaytta: title (kısa ve dikkat çekici başlık), content (slaytta gösterilecek
  madde işaretleri veya kısa paragraflar, en fazla 120 kelime), keywords
  (içerikle eşleşen 3-8 anahtar kelime) alanları doldur.
- Tüm metinler "$language" dilinde olmalı.
- content alanında her bilgiyi ayrı satıra yaz (madde işaretleri için "- " kullan,
  "- " ile başlayan satırlar sunumda tek tek gösterilecektir).
- Türkçe karakterleri doğru kullan: ç, ğ, ı, ö, ş, ü.
- ASLA şunları üretme: işletim sistemi bildirimleri, yazılım uyarıları, lisans
  filigranları, "Windows'u Etkinleştir" benzeri kullanıcı arayüzü metinleri,
  bozuk/eksik kelimeler. Yalnızca konuya özgü özgün sunum içeriği yaz.
- Yazım hatalarına dikkat et; her kelime tam ve doğru olmalı.
- Yalnızca istenen JSON şemasına uygun geçerli bir JSON döndür, başka açıklama yazma.

Konu: $topic
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Gemini boş yanıt döndürdü.');
    }

    final json = jsonDecode(_stripCodeFence(text)) as Map<String, dynamic>;
    return GeminiPresentation.fromJson(json);
  }

  static String _stripCodeFence(String text) {
    final trimmed = text.trim();
    if (trimmed.startsWith('```')) {
      final firstLineEnd = trimmed.indexOf('\n');
      return trimmed.substring(firstLineEnd + 1).replaceFirst(RegExp(r'```\s*$'), '').trim();
    }
    return trimmed;
  }
}
