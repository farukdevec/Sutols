import 'dart:convert';

import 'package:http/http.dart' as http;

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

class NvidiaPresentationService {
  static const String _proxyUrl =
      'https://sutol-ai-proxy.sutolsofficial.workers.dev';

  Future<GeminiPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
  }) async {
    final prompt = '''Kullanıcının verdiği konu hakkında $slideCount slaytlık bir sunum yapısı oluştur.

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

    final body = {
      'model': 'nvidia/nemotron-3.5-lightning-30b-a3b',
      'messages': [
        {
          'role': 'system',
          'content':
              'Sen bir sunum içeriği üreten asistansın. SADECE geçerli JSON döndür, başka hiçbir açıklama veya markdown kod bloğu (```json gibi) ekleme.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 0.7,
      'max_tokens': 4096,
      'stream': false,
    };

    final response = await http.post(
      Uri.parse(_proxyUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Nvidia proxy hatası: ${response.statusCode} - ${response.body}',
      );
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final content = responseJson['choices']?[0]?['message']?['content']
        as String?;

    if (content == null || content.isEmpty) {
      throw Exception('Nvidia proxy boş yanıt döndürdü.');
    }

    String cleaned = content.trim();

    // 1. ```json ile başlıyorsa kod bloğu işaretlerini temizle
    if (cleaned.startsWith('```')) {
      final firstNewline = cleaned.indexOf('\n');
      if (firstNewline != -1) {
        cleaned = cleaned.substring(firstNewline + 1);
      }
      cleaned = cleaned.replaceFirst(RegExp(r'```\s*$'), '').trim();
    }

    // 2. JSON.parse() dene
    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      // 3. Başarısız olursa, ilk { ile son } arasındaki kısmı regex ile çıkarıp
      //    tekrar parse etmeyi dene
      final regex = RegExp(r'\{.*\}', dotAll: true);
      final match = regex.firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(0)!;
        try {
          parsed = jsonDecode(cleaned) as Map<String, dynamic>;
        } catch (e) {
          // 4. Hâlâ başarısızsa açıklayıcı bir hata fırlat
          throw Exception(
            'Nvidia yanıtı JSON olarak ayrıştırılamadı. İçerik: $cleaned\nHata: $e',
          );
        }
      } else {
        throw Exception(
          'Nvidia yanıtı JSON olarak ayrıştırılamadı. İçerik: $cleaned',
        );
      }
    }

    return GeminiPresentation.fromJson(parsed);
  }
}
