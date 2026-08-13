import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'presentation_prompt_builder.dart';

/// Gemini'nin response_schema ile zorladığı tek slayt yapısı.
class NvidiaSlide {
  final String title;
  final String content;
  final List<String> keywords;

  const NvidiaSlide({
    required this.title,
    required this.content,
    required this.keywords,
  });

  factory NvidiaSlide.fromJson(Map<String, dynamic> json) {
    return NvidiaSlide(
      title: json['title'] as String,
      content: json['content'] as String,
      keywords: (json['keywords'] as List).cast<String>(),
    );
  }
}

/// Üst düzey yanıt yapısı: { "slides": [...] }
class NvidiaPresentation {
  final List<NvidiaSlide> slides;

  const NvidiaPresentation({required this.slides});

  factory NvidiaPresentation.fromJson(Map<String, dynamic> json) {
    return NvidiaPresentation(
      slides: (json['slides'] as List)
          .map((s) => NvidiaSlide.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NvidiaPresentationService {
  static const String _proxyUrl =
      'https://sutol-ai-proxy.sutolsofficial.workers.dev';
  static const Duration _requestTimeout = Duration(seconds: 20);

  Future<NvidiaPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
  }) async {
    final prompt = PresentationPromptBuilder.build(
      topic: topic,
      slideCount: slideCount,
      language: language,
    );

    final body = {
      'model': 'nvidia/nemotron-3.5-nano-30b-a3b',
      'messages': [
        {
          'role': 'system',
          'content': 'Sen deneyimli bir sunum editörü ve bilgi mimarısın. Önce anlatı '
              'akışını planlar, sonra her slayta benzersiz bir görev verirsin. '
              'Aynı bilgiyi veya cümle kalıbını tekrarlamazsın. SADECE geçerli '
              'JSON döndürürsün; açıklama ve markdown eklemezsin.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 0.65,
      'max_tokens': 4096,
      'stream': false,
    };

    final response = await http
        .post(
          Uri.parse(_proxyUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(
          _requestTimeout,
          onTimeout: () => throw TimeoutException(
            'NVIDIA servisine 20 saniye içinde ulaşılamadı.',
          ),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Nvidia proxy hatası: ${response.statusCode} - ${response.body}',
      );
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        responseJson['choices']?[0]?['message']?['content'] as String?;

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

    return NvidiaPresentation.fromJson(parsed);
  }
}
