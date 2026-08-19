import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_model_config.dart';
import 'presentation_content_quality.dart';
import 'presentation_prompt_builder.dart';
import 'safe_json_parser.dart';

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
    final title = json['title'] ?? json['baslik'];
    final content = json['content'] ?? json['icerik'];
    final rawKeywords = json['keywords'] ?? json['anahtar_kelimeler'];

    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Slayt başlığı (title) geçersiz.');
    }
    final cleanedTitle = PresentationContentQuality.sanitizeTitle(title);
    final normalizedContent = _normalizeContent(content);
    if (normalizedContent.isEmpty) {
      throw const FormatException('Slayt içeriği (content) geçersiz.');
    }

    final keywordsList = rawKeywords is List
        ? rawKeywords.map((k) => k.toString()).toList(growable: false)
        : const <String>[];

    return DeepSeekSlide(
      title: cleanedTitle,
      content: normalizedContent,
      keywords: keywordsList,
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
        throw FormatException('slides[$i] nesnesi geçersiz.');
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
  static const String defaultModelName = AiModelConfig.modelNemotronNano;
  static const Duration _requestTimeout = AiModelConfig.timeoutNano;

  static const List<String> defaultCandidateModels =
      AiModelConfig.defaultNvidiaCandidateModels;

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
    final maxTokens = (slideCount * 250 + 600).clamp(1000, 3000);

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
              'content': '$systemInstruction\n\nİstenen sunumu KESİNLİKLE VE YALNIZCA TEK BİR GEÇERLİ JSON NESNESİ OLARAK DÖNDÜR. '
                  'JSON Şeması: {"slides": [{"title": "Slayt Başlığı", "content": "- Açıklama 1\\n- Açıklama 2\\n- Açıklama 3", "keywords": ["nesne1", "nesne2"]}]}. '
                  'Yanıtında asla ekstra metin, açıklama veya markdown kod bloğu yazma.',
            },
            {
              'role': 'user',
              'content': userPrompt,
            },
          ],
          'temperature': 0.5,
          'max_tokens': maxTokens,
          'response_format': {
            'type': 'json_object',
          },
          'stream': false,
        };

        final response = await _postWithTimeout(body);
        final responseJson = _decodeJsonMap(
          response.body,
          onError: 'AI Gateway geçerli JSON döndürmedi.',
        );
        final content = _extractAssistantContent(responseJson);

        if (content == null || content.trim().isEmpty) {
          throw const FormatException('API yanıtında choices[0].message.content boş döndü.');
        }

        final parsed = SafeJsonParser.parsePresentationPayload(content);
        SafeJsonParser.validateSchema(parsed);
        SafeJsonParser.validateContent(parsed);

        return DeepSeekPresentation.fromJson(parsed);
      } catch (e) {
        lastError = e.toString();
      }
    }

    throw Exception(lastError.isEmpty
        ? 'Sunum üretimi başarısız oldu.'
        : lastError);
  }

  Future<http.Response> _postWithTimeout(Map<String, dynamic> body) async {
    final httpClient = client;
    final response = await (httpClient != null
            ? httpClient.post(
                Uri.parse(proxyUrl),
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
            : http.post(
                Uri.parse(proxyUrl),
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              ))
        .timeout(
      _requestTimeout,
      onTimeout: () => throw TimeoutException(
        'İstek ${_requestTimeout.inSeconds} saniyede zaman aşımına uğradı.',
      ),
    );

    if (response.statusCode == 200) {
      return response;
    }

    throw Exception('İstek başarısız (${response.statusCode}): ${response.body}');
  }

  static Map<String, dynamic>? tryParsePresentationPayload(String rawContent) =>
      SafeJsonParser.tryParsePresentationPayload(rawContent);

  static Map<String, dynamic> parsePresentationPayload(String rawContent) =>
      SafeJsonParser.parsePresentationPayload(rawContent);

  static Map<String, dynamic> _decodeJsonMap(
    String raw, {
    required String onError,
  }) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
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
