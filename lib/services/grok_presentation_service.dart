import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../env_config.dart';
import 'presentation_content_quality.dart';
import 'presentation_prompt_builder.dart';

/// Grok'tan dönen slayt yapısı.
class GrokSlide {
  final String title;
  final String content;
  final List<String> keywords;

  const GrokSlide({
    required this.title,
    required this.content,
    required this.keywords,
  });

  factory GrokSlide.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final content = json['content'];
    final rawKeywords = json['keywords'];
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Slayt başlığı (title) geçersiz.');
    }
    final cleanedTitle = PresentationContentQuality.sanitizeTitle(title);
    final normalizedContent = _normalizeContent(content);
    if (normalizedContent.isEmpty) {
      throw const FormatException('Slayt içeriği (content) geçersiz.');
    }
    if (rawKeywords is! List) {
      throw const FormatException(
          'Slayt anahtar kelimeleri (keywords) geçersiz.');
    }
    return GrokSlide(
      title: cleanedTitle,
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
class GrokPresentation {
  final List<GrokSlide> slides;

  const GrokPresentation({required this.slides});

  factory GrokPresentation.fromJson(Map<String, dynamic> json) {
    final rawSlides = json['slides'];
    if (rawSlides is! List) {
      throw const FormatException('Yanıtta "slides" listesi bulunamadı.');
    }
    if (rawSlides.isEmpty) {
      throw const FormatException('Yanıtta hiç slayt bulunamadı.');
    }
    final slides = <GrokSlide>[];
    for (var i = 0; i < rawSlides.length; i += 1) {
      final rawSlide = rawSlides[i];
      if (rawSlide is! Map) {
        throw FormatException('slides[$i] nesnesi geçersiz.');
      }
      slides.add(
        GrokSlide.fromJson(
          rawSlide.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }
    return GrokPresentation(slides: slides);
  }
}

class GrokPresentationService {
  /// --dart-define=GROK_API_KEY=... ile geçilen anahtar
  static const String _envApiKey = String.fromEnvironment('GROK_API_KEY');

  /// Grok API Anahtarı (xAI API Key).
  static String apiKey = '';

  /// Cloudflare Worker veya Backend Proxy adresi (Örn: 'https://sutols.online/')
  static String proxyUrl = 'https://sutols.online/';

  static const String _defaultApiUrl = 'https://api.x.ai/v1/chat/completions';
  static const String _defaultModel = 'grok-4.3';
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const int _maxAttempts = 2;

  static const List<String> defaultCandidateModels = [
    'grok-4.3',
    'grok-4.1-fast',
    'grok-beta',
  ];

  final String? customApiKey;
  final String? customProxyUrl;
  final String modelName;

  GrokPresentationService({
    this.customApiKey,
    this.customProxyUrl,
    this.modelName = _defaultModel,
  });

  String get effectiveApiKey {
    if (customApiKey != null && customApiKey!.isNotEmpty) {
      return customApiKey!;
    }
    if (apiKey.isNotEmpty) {
      return apiKey;
    }
    if (EnvConfig.grokApiKey.isNotEmpty) {
      return EnvConfig.grokApiKey;
    }
    return _envApiKey;
  }

  String get effectiveProxyUrl => customProxyUrl ?? proxyUrl;

  Future<GrokPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
    String? model,
    List<String>? candidateModels,
  }) async {
    final proxy = effectiveProxyUrl.trim();
    final key = effectiveApiKey.trim();

    if (proxy.isEmpty && (key.isEmpty || key == 'YOUR_GROK_API_KEY_HERE')) {
      throw Exception(
        'Grok API Key veya Proxy URL tanımlanmamış. '
        'Lütfen GrokPresentationService.apiKey veya GrokPresentationService.proxyUrl alanını yapılandırın.',
      );
    }

    final systemInstruction = PresentationPromptBuilder.buildSystemInstruction();
    final userPrompt = PresentationPromptBuilder.buildUserPrompt(
      topic: topic,
      slideCount: slideCount,
      language: language,
    );
    final maxTokens = (slideCount * 800 + 1000).clamp(2000, 8192);

    final selectedModel = model ?? modelName;
    final modelsToTry = candidateModels ?? [
      selectedModel,
      ...defaultCandidateModels.where((m) => m != selectedModel),
    ];

    String lastError = '';

    for (final candidateModel in modelsToTry) {
      try {
        final body = {
          'model': candidateModel,
          'messages': [
            {
              'role': 'system',
              'content': '$systemInstruction\n\nİstenen sunumu KESİNLİKLE VE YALNIZCA TEK BİR GEÇERLİ JSON NESNESİ OLARAK DÖNDÜR. '
                  'JSON Şeması: {"slides": [{"title": "Slayt Başlığı", "content": "- Açıklama 1\\n- Açıklama 2\\n- Açıklama 3", "keywords": ["nesne1", "nesne2"]}]}. '
                  'Yanıtında asla ekstra metin, açıklama veya markdown kod bloğu yazma.',
            },
            {
              'role': 'user',
              'content': userPrompt,
            },
          ],
          'temperature': 0.65,
          'max_tokens': maxTokens,
          'response_format': {
            'type': 'json_object',
          },
          'stream': false,
        };

        final response = await _postWithRetry(
          body: body,
          key: key,
          proxyUrl: proxy,
        );
        final responseJson = _decodeJsonMap(
          response.body,
          onError: 'Grok API / Proxy geçerli JSON döndürmedi.',
        );
        final content = _extractAssistantContent(responseJson);

        if (content == null || content.isEmpty) {
          lastError = 'Grok ($candidateModel) yanıtında choices[0].message.content boş döndü.';
          continue;
        }

        final parsed = _parsePresentationPayload(content);
        return GrokPresentation.fromJson(parsed);
      } catch (e) {
        lastError = e.toString();
      }
    }

    throw Exception(lastError.isEmpty
        ? 'Grok sunum üretimi başarısız oldu.'
        : lastError);
  }

  Future<http.Response> _postWithRetry({
    required Map<String, dynamic> body,
    required String key,
    required String proxyUrl,
  }) async {
    final useProxy = proxyUrl.isNotEmpty;
    final targetUri = Uri.parse(useProxy ? proxyUrl : _defaultApiUrl);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (useProxy) 'Origin': 'https://sutols.com',
      if (!useProxy && key.isNotEmpty) 'Authorization': 'Bearer $key',
    };

    var lastError = '';
    for (var attempt = 1; attempt <= _maxAttempts; attempt += 1) {
      try {
        final response = await http
            .post(
              targetUri,
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(
              _requestTimeout,
              onTimeout: () => throw TimeoutException(
                'Grok isteği ${_requestTimeout.inSeconds} saniyede zaman aşımına uğradı.',
              ),
            );

        if (response.statusCode == 200) {
          return response;
        }

        if (response.statusCode == 404 && useProxy && key.isNotEmpty) {
          // Fall back to direct xAI endpoint if proxy returns 404
          final directHeaders = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',
          };
          final directResponse = await http
              .post(
                Uri.parse(_defaultApiUrl),
                headers: directHeaders,
                body: jsonEncode(body),
              )
              .timeout(
                _requestTimeout,
                onTimeout: () => throw TimeoutException(
                  'Grok isteği ${_requestTimeout.inSeconds} saniyede zaman aşımına uğradı.',
                ),
              );
          if (directResponse.statusCode == 200) {
            return directResponse;
          }
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
        lastError = e.message ?? 'Grok isteği zaman aşımına uğradı.';
        if (attempt == _maxAttempts) {
          throw Exception(lastError);
        }
      } on http.ClientException catch (e) {
        lastError = 'Grok bağlantı hatası: ${e.message}';
        if (attempt == _maxAttempts) {
          throw Exception(lastError);
        }
      }

      await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
    }

    throw Exception(lastError.isEmpty
        ? 'Grok isteği başarısız oldu.'
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
        return 'Grok AI isteği geçersiz (400). Model veya isteği kontrol edin.$bodySuffix';
      case 401:
        return 'Grok AI yetkilendirme hatası (401). API key (xAI API Key) geçersiz veya eksik.$bodySuffix';
      case 403:
        return 'Grok AI erişim engellendi (403). İzinleri veya hesabı kontrol edin.$bodySuffix';
      case 429:
        return 'Grok AI hız sınırına takıldı (429). Lütfen daha sonra tekrar deneyin.$bodySuffix';
      default:
        if (statusCode >= 500) {
          return 'Grok AI sunucu hatası ($statusCode).$bodySuffix';
        }
        return 'Grok AI isteği başarısız oldu ($statusCode).$bodySuffix';
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

  @visibleForTesting
  static Map<String, dynamic> parsePresentationPayload(String rawContent) =>
      _parsePresentationPayload(rawContent);

  static Map<String, dynamic> _parsePresentationPayload(String rawContent) {
    var cleaned = rawContent.trim();

    if (cleaned.contains('```')) {
      final match = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(1)!.trim();
      } else if (cleaned.startsWith('```')) {
        final firstNewline = cleaned.indexOf('\n');
        if (firstNewline != -1) {
          cleaned = cleaned.substring(firstNewline + 1);
        }
        cleaned = cleaned.replaceFirst(RegExp(r'```\s*$'), '').trim();
      }
    }

    final directMap = _tryDecodeMap(cleaned);
    if (directMap != null) {
      return _normalizePresentationPayload(directMap);
    }

    final directList = _tryDecodeList(cleaned);
    if (directList != null) {
      return _normalizeSlideList(directList);
    }

    final extractedSlides = _extractAllSlidesFromText(cleaned);
    if (extractedSlides.isNotEmpty) {
      return {'slides': extractedSlides};
    }

    throw Exception(
      'Grok yanıtı JSON olarak ayrıştırılamadı. İçerik: $cleaned',
    );
  }

  static List<Map<String, dynamic>> _extractAllSlidesFromText(String text) {
    final slides = <Map<String, dynamic>>[];

    final slideMatches = RegExp(r'\{[^{}]*"slides"\s*:\s*\[[\s\S]*?\][^{}]*\}').allMatches(text);
    for (final match in slideMatches) {
      final map = _tryDecodeMap(match.group(0)!);
      if (map != null && map['slides'] is List) {
        for (final item in map['slides'] as List) {
          if (item is Map) {
            final m = item.map((k, v) => MapEntry(k.toString(), v));
            if (_looksLikeSlideObject(m)) slides.add(m);
          }
        }
      }
    }
    if (slides.isNotEmpty) return slides;

    final objMatches = RegExp(r'\{[^{}]*"title"\s*:[^{}]*"content"\s*:[^{}]*\}').allMatches(text);
    for (final match in objMatches) {
      final map = _tryDecodeMap(match.group(0)!);
      if (map != null && _looksLikeSlideObject(map)) {
        slides.add(map);
      }
    }
    if (slides.isNotEmpty) return slides;

    return _decodeJsonObjectSequence(text);
  }

  static List<dynamic>? _tryDecodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic> _normalizeSlideList(List<dynamic> list) {
    final validSlides = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is Map) {
        final map = item.map((key, value) => MapEntry(key.toString(), value));
        if (_looksLikeSlideObject(map)) {
          validSlides.add(map);
        }
      }
    }
    if (validSlides.isEmpty) {
      throw const FormatException('AI yanıtında geçerli slayt bulunamadı.');
    }
    return {'slides': validSlides};
  }

  static Map<String, dynamic> _normalizePresentationPayload(
    Map<String, dynamic> decoded,
  ) {
    for (final key in const ['slides', 'sunum', 'slaytlar', 'presentation', 'items', 'data']) {
      if (decoded[key] is List) {
        return {'slides': decoded[key]};
      }
    }

    for (final entry in decoded.entries) {
      if (entry.value is List) {
        final list = entry.value as List;
        if (list.isNotEmpty &&
            list.any((item) => item is Map && _looksLikeSlideObject(item.map((k, v) => MapEntry(k.toString(), v))))) {
          return {'slides': list};
        }
      }
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
