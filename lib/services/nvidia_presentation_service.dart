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
    final title = json['title'];
    final content = json['content'];
    final rawKeywords = json['keywords'];
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Slayt başlığı (title) geçersiz.');
    }
    final normalizedContent = _normalizeContent(content);
    if (normalizedContent.isEmpty) {
      throw const FormatException('Slayt içeriği (content) geçersiz.');
    }
    if (rawKeywords is! List) {
      throw const FormatException(
          'Slayt anahtar kelimeleri (keywords) geçersiz.');
    }
    return NvidiaSlide(
      title: title,
      content: normalizedContent,
      keywords: rawKeywords.whereType<String>().toList(growable: false),
    );
  }

  static String _normalizeContent(Object? rawContent) {
    if (rawContent is String) {
      return rawContent.trim();
    }
    if (rawContent is List) {
      final lines = rawContent
          .whereType<String>()
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
      return lines.join('\n');
    }
    return '';
  }
}

/// Üst düzey yanıt yapısı: { "slides": [...] }
class NvidiaPresentation {
  final List<NvidiaSlide> slides;

  const NvidiaPresentation({required this.slides});

  factory NvidiaPresentation.fromJson(Map<String, dynamic> json) {
    final rawSlides = json['slides'];
    if (rawSlides is! List) {
      throw const FormatException('Yanıtta "slides" listesi bulunamadı.');
    }
    if (rawSlides.isEmpty) {
      throw const FormatException('Yanıtta hiç slayt bulunamadı.');
    }
    final slides = <NvidiaSlide>[];
    for (var i = 0; i < rawSlides.length; i += 1) {
      final rawSlide = rawSlides[i];
      if (rawSlide is! Map) {
        throw FormatException('slides[$i] nesnesi geçersiz.');
      }
      slides.add(
        NvidiaSlide.fromJson(
          rawSlide.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }
    return NvidiaPresentation(slides: slides);
  }
}

class NvidiaPresentationService {
  static const String _proxyUrl = 'https://sutols.online/';
  static const String _modelName = 'meta/llama-3.1-8b-instruct';
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const int _maxAttempts = 2;

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
      'model': _modelName,
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

    final response = await _postWithRetry(body);
    final responseJson = _decodeJsonMap(
      response.body,
      onError: 'Cloudflare Worker geçerli JSON döndürmedi.',
    );
    final content = _extractAssistantContent(responseJson);

    if (content == null || content.isEmpty) {
      throw Exception(
        'Cloudflare Worker yanıtında choices[0].message.content boş döndü.',
      );
    }

    final parsed = _parsePresentationPayload(content);
    return NvidiaPresentation.fromJson(parsed);
  }

  Future<http.Response> _postWithRetry(Map<String, dynamic> body) async {
    var lastError = '';
    for (var attempt = 1; attempt <= _maxAttempts; attempt += 1) {
      try {
        final response = await http
            .post(
              Uri.parse(_proxyUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(
              _requestTimeout,
              onTimeout: () => throw TimeoutException(
                'Cloudflare Worker isteği ${_requestTimeout.inSeconds} saniyede zaman aşımına uğradı.',
              ),
            );

        if (response.statusCode == 200) {
          return response;
        }

        lastError = _statusErrorMessage(
          statusCode: response.statusCode,
          responseBody: response.body,
        );
        if (!_isRetriableStatus(response.statusCode) ||
            attempt == _maxAttempts) {
          throw Exception(lastError);
        }
      } on TimeoutException catch (e) {
        lastError =
            e.message ?? 'Cloudflare Worker isteği zaman aşımına uğradı.';
        if (attempt == _maxAttempts) {
          throw Exception(lastError);
        }
      } on http.ClientException catch (e) {
        lastError = 'Cloudflare Worker bağlantı hatası: ${e.message}';
        if (attempt == _maxAttempts) {
          throw Exception(lastError);
        }
      }

      await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
    }

    throw Exception(lastError.isEmpty
        ? 'Cloudflare Worker isteği başarısız oldu.'
        : lastError);
  }

  static bool _isRetriableStatus(int statusCode) =>
      statusCode == 429 || statusCode >= 500;

  static String _statusErrorMessage({
    required int statusCode,
    required String responseBody,
  }) {
    final body = responseBody.trim();
    final bodySuffix = body.isEmpty ? '' : ' Detay: $body';
    switch (statusCode) {
      case 400:
        return 'AI isteği geçersiz (400). Model veya request formatını kontrol edin.$bodySuffix';
      case 401:
        return 'AI isteği yetkilendirilemedi (401). Worker kimlik doğrulamasını kontrol edin.$bodySuffix';
      case 403:
        return 'AI isteği engellendi (403). Origin/CORS ayarlarını kontrol edin.$bodySuffix';
      case 429:
        return 'AI isteği hız sınırına takıldı (429). Lütfen kısa süre sonra tekrar deneyin.$bodySuffix';
      default:
        if (statusCode >= 500) {
          return 'Cloudflare Worker/NVIDIA servis hatası ($statusCode).$bodySuffix';
        }
        return 'AI isteği başarısız oldu ($statusCode).$bodySuffix';
    }
  }

  static Map<String, dynamic> _decodeJsonMap(
    String raw, {
    required String onError,
  }) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(onError);
    }
    return decoded;
  }

  static Map<String, dynamic> _parsePresentationPayload(String rawContent) {
    var cleaned = rawContent.trim();
    if (cleaned.startsWith('```')) {
      final firstNewline = cleaned.indexOf('\n');
      if (firstNewline != -1) {
        cleaned = cleaned.substring(firstNewline + 1);
      }
      cleaned = cleaned.replaceFirst(RegExp(r'```\s*$'), '').trim();
    }

    final direct = _tryDecodeMap(cleaned);
    if (direct != null) {
      return _normalizePresentationPayload(direct);
    }

    final blockMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(cleaned);
    if (blockMatch != null) {
      final block = blockMatch.group(0)!;
      final blockMap = _tryDecodeMap(block);
      if (blockMap != null) {
        return _normalizePresentationPayload(blockMap);
      }
    }

    final objectSequence = _decodeJsonObjectSequence(cleaned);
    if (objectSequence.isNotEmpty) {
      return {'slides': objectSequence};
    }

    throw Exception(
      'Nvidia yanıtı JSON olarak ayrıştırılamadı. İçerik: $cleaned',
    );
  }

  static Map<String, dynamic> _normalizePresentationPayload(
    Map<String, dynamic> decoded,
  ) {
    if (decoded['slides'] is List) {
      return decoded;
    }
    if (_looksLikeSlideObject(decoded)) {
      return {
        'slides': [decoded]
      };
    }
    throw const FormatException(
        'AI yanıtı geçerli sunum JSON formatında değil.');
  }

  static Map<String, dynamic>? _tryDecodeMap(String raw) {
    try {
      return _decodeJsonMap(
        raw,
        onError: 'AI yanıtı JSON sunum formatında değil.',
      );
    } on FormatException {
      return null;
    }
  }

  static bool _looksLikeSlideObject(Map<String, dynamic> decoded) =>
      decoded.containsKey('title') && decoded.containsKey('content');

  static List<Map<String, dynamic>> _decodeJsonObjectSequence(String raw) {
    final matches = RegExp(r'\{[\s\S]*?\}(?=\s*\{|$)', multiLine: true)
        .allMatches(raw)
        .map((match) => match.group(0)!.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final slides = <Map<String, dynamic>>[];
    for (final part in matches) {
      final decoded = _tryDecodeMap(part);
      if (decoded == null || !_looksLikeSlideObject(decoded)) {
        continue;
      }
      slides.add(decoded);
    }
    return slides;
  }

  static String? _extractAssistantContent(Map<String, dynamic> responseJson) {
    final choices = responseJson['choices'];
    if (choices is! List || choices.isEmpty) {
      return null;
    }
    final firstChoice = choices.first;
    if (firstChoice is! Map) {
      return null;
    }
    final message = firstChoice['message'];
    if (message is! Map) {
      return null;
    }
    final content = message['content'];
    return content is String ? content : null;
  }
}
