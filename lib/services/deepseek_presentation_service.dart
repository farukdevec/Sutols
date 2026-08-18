import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'presentation_content_quality.dart';
import 'presentation_prompt_builder.dart';

class DeepSeekSlide {
  final String title;
  final String content;
  final List<String> keywords;

  const DeepSeekSlide({
    required this.title,
    required this.content,
    required this.keywords,
  });

  factory DeepSeekSlide.fromJson(Map<String, dynamic> json) {
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
    return DeepSeekSlide(
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

class DeepSeekPresentation {
  final List<DeepSeekSlide> slides;

  const DeepSeekPresentation({required this.slides});

  factory DeepSeekPresentation.fromJson(Map<String, dynamic> json) {
    final rawSlides = json['slides'];
    if (rawSlides is! List) {
      throw const FormatException('Yanıtta "slides" listesi bulunamadı.');
    }
    if (rawSlides.isEmpty) {
      throw const FormatException('Yanıtta hiç slayt bulunamadı.');
    }
    final slides = <DeepSeekSlide>[];
    for (var i = 0; i < rawSlides.length; i += 1) {
      final rawSlide = rawSlides[i];
      if (rawSlide is! Map) {
        throw FormatException('slides[\] nesnesi geçersiz.');
      }
      slides.add(
        DeepSeekSlide.fromJson(
          rawSlide.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }
    return DeepSeekPresentation(slides: slides);
  }
}

class DeepSeekPresentationService {
  static const String defaultProxyUrl = 'https://sutols.online/';
  static const String defaultModelName = 'deepseek-ai/deepseek-r1';
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const int _maxAttempts = 2;

  static const List<String> defaultCandidateModels = [
    'deepseek-ai/deepseek-r1',
    'deepseek-ai/deepseek-v3',
    'deepseek-reasoner',
    'deepseek-chat',
  ];

  final String proxyUrl;
  final String modelName;
  final List<String>? customCandidateModels;
  final http.Client? client;

  DeepSeekPresentationService({
    this.proxyUrl = defaultProxyUrl,
    this.modelName = defaultModelName,
    this.customCandidateModels,
    this.client,
  });

  Future<DeepSeekPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
    String? model,
    List<String>? candidateModels,
  }) async {
    final systemInstruction =
        PresentationPromptBuilder.buildSystemInstruction();
    final userPrompt = PresentationPromptBuilder.buildUserPrompt(
      topic: topic,
      slideCount: slideCount,
      language: language,
    );
    final maxTokens = (slideCount * 800 + 1000).clamp(2000, 8192);

    final selectedModel = model ?? modelName;
    final modelsToTry = candidateModels ??
        customCandidateModels ??
        [
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
              'content': '\\n\nİstenen sunumu KESİNLİKLE VE YALNIZCA TEK BİR GEÇERLİ JSON NESNESİ OLARAK DÖNDÜR. '
                  'JSON Şeması: {"slides": [{"title": "Slayt Başlığı", "content": "- Açıklama 1\\n- Açıklama 2\\n- Açıklama 3", "keywords": ["nesne1", "nesne2"]}]}. '
                  'Yanıtında asla ekstra metin, açıklama veya markdown kod bloğu yazma.',
            },
            {
              'role': 'user',
              'content': userPrompt,
            },
          ],
          'temperature': 0.6,
          'max_tokens': maxTokens,
          'response_format': {
            'type': 'json_object',
          },
          'stream': false,
        };

        final response = await _postWithRetry(body);
        final responseJson = _decodeJsonMap(
          response.body,
          onError: 'DeepSeek proxy geçerli JSON döndürmedi.',
        );
        final content = _extractAssistantContent(responseJson);

        if (content == null || content.trim().isEmpty) {
          lastError =
              'DeepSeek ($candidateModel) yanıtında choices[0].message.content boş döndü.';
          continue;
        }

        final parsed = tryParsePresentationPayload(content);
        if (parsed != null) {
          return DeepSeekPresentation.fromJson(parsed);
        }

        lastError =
            'DeepSeek ($candidateModel) yanıtı JSON olarak ayrıştırılamadı. İçerik: ${content.trim()}';
      } catch (e) {
        lastError = e.toString();
      }
    }

    throw Exception(lastError.isEmpty
        ? 'DeepSeek sunum üretimi başarısız oldu.'
        : lastError);
  }

  Future<http.Response> _postWithRetry(Map<String, dynamic> body) async {
    var lastError = '';
    final httpClient = client;
    for (var attempt = 1; attempt <= _maxAttempts; attempt += 1) {
      try {
        final response = await (httpClient != null
                ? httpClient.post(
                    Uri.parse(proxyUrl),
                    headers: {
                      'Content-Type': 'application/json',
                      'Origin': 'https://sutols.com',
                    },
                    body: jsonEncode(body),
                  )
                : http.post(
                    Uri.parse(proxyUrl),
                    headers: {
                      'Content-Type': 'application/json',
                      'Origin': 'https://sutols.com',
                    },
                    body: jsonEncode(body),
                  ))
            .timeout(
              _requestTimeout,
              onTimeout: () => throw TimeoutException(
                'DeepSeek isteği ${_requestTimeout.inSeconds} saniyede zaman aşımına uğradı.',
              ),
            );

        if (response.statusCode == 200) {
          return response;
        }

        if (response.statusCode == 400 && body.containsKey('response_format')) {
          final fallbackBody = Map<String, dynamic>.from(body)
            ..remove('response_format');
          final fallbackResponse = await (httpClient != null
                  ? httpClient.post(
                      Uri.parse(proxyUrl),
                      headers: {
                        'Content-Type': 'application/json',
                        'Origin': 'https://sutols.com',
                      },
                      body: jsonEncode(fallbackBody),
                    )
                  : http.post(
                      Uri.parse(proxyUrl),
                      headers: {
                        'Content-Type': 'application/json',
                        'Origin': 'https://sutols.com',
                      },
                      body: jsonEncode(fallbackBody),
                    ))
              .timeout(
                _requestTimeout,
                onTimeout: () => throw TimeoutException(
                  'DeepSeek isteği ${_requestTimeout.inSeconds} saniyede zaman aşımına uğradı.',
                ),
              );
          if (fallbackResponse.statusCode == 200) {
            return fallbackResponse;
          }
        }

        lastError = 'DeepSeek isteği başarısız oldu (${response.statusCode}).';
      } catch (e) {
        lastError = e.toString();
      }

      await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
    }

    throw Exception(lastError);
  }

  static Map<String, dynamic>? tryParsePresentationPayload(String rawContent) {
    try {
      final parsed = parsePresentationPayload(rawContent);
      DeepSeekPresentation.fromJson(parsed);
      return parsed;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> parsePresentationPayload(String rawContent) {
    var cleaned = rawContent.trim();

    if (cleaned.contains('</think>')) {
      cleaned = cleaned.substring(cleaned.lastIndexOf('</think>') + 8).trim();
    }

    if (cleaned.contains('`')) {
      final match =
          RegExp(r'`(?:json)?\s*([\s\S]*?)\s*`').firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(1)!.trim();
      } else if (cleaned.startsWith('`')) {
        final firstNewline = cleaned.indexOf('\n');
        if (firstNewline != -1) {
          cleaned = cleaned.substring(firstNewline + 1);
        }
        cleaned = cleaned.replaceFirst(RegExp(r'`\s*$'), '').trim();
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

    throw Exception('DeepSeek yanıtı JSON olarak ayrıştırılamadı.');
  }

  static Map<String, dynamic> _normalizeSlideList(List<dynamic> list) {
    final validSlides = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is Map) {
        final map = item.map((key, value) => MapEntry(key.toString(), value));
        if (map.containsKey('title') && map.containsKey('content')) {
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
    for (final key in const [
      'slides',
      'sunum',
      'slaytlar',
      'presentation',
      'items',
      'data'
    ]) {
      if (decoded[key] is List) {
        return {'slides': decoded[key]};
      }
    }
    if (decoded.containsKey('title') && decoded.containsKey('content')) {
      return {
        'slides': [decoded]
      };
    }
    throw const FormatException(
        'AI yanıtı geçerli sunum JSON formatında değil.');
  }

  static Map<String, dynamic>? _tryDecodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  static List<dynamic>? _tryDecodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
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

  static String? _extractAssistantContent(Map<String, dynamic> responseJson) {
    final choices = responseJson['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final firstChoice = choices.first;
    if (firstChoice is! Map) return null;
    final message = firstChoice['message'];
    if (message is! Map) return null;
    final content = message['content'];
    return content is String ? content : null;
  }
}
