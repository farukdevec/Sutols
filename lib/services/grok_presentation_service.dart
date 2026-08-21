import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'ai_model_config.dart';
import 'presentation_content_quality.dart';
import 'presentation_prompt_builder.dart';
import 'safe_json_parser.dart';

/// Grok'tan dönen slayt yapısı.
class GrokSlide {
  final String title;
  final String? subtitle;
  final String content;
  final List<String> keywords;
  final String type;
  final String? purpose;
  final String? keyMessage;
  final List<Map<String, dynamic>>? sections;
  final Map<String, dynamic>? visual;
  final List<String> sources;

  const GrokSlide({
    required this.title,
    this.subtitle,
    required this.content,
    required this.keywords,
    this.type = 'cards',
    this.purpose,
    this.keyMessage,
    this.sections,
    this.visual,
    this.sources = const <String>[],
  });

  factory GrokSlide.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? json['baslik'];
    final subtitle = (json['subtitle'] ?? json['alt_baslik'] ?? json['sub_title'])?.toString();
    final rawContent = json['content'] ?? json['icerik'];
    final rawKeywords = json['visual_keywords'] ?? json['keywords'] ?? json['anahtar_kelimeler'];
    final rawType = json['type'] ??
        json['slide_type'] ??
        json['layout'] ??
        json['tip'] ??
        'concept';
    final purpose = (json['purpose'] ?? json['amac'] ?? json['role'])?.toString();
    final keyMessage = (json['key_message'] ?? json['keyMessage'] ?? json['ana_mesaj'])?.toString();
    final rawSections = json['sections'] ?? json['bolumler'];
    final rawVisual = json['visual'] ?? json['gorsel'];
    final rawSources = json['sources'] ?? json['kaynaklar'];

    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Slayt başlığı (title) geçersiz.');
    }
    final cleanedTitle = PresentationContentQuality.sanitizeTitle(title);
    var normalizedContent = _normalizeContent(rawContent);

    List<Map<String, dynamic>>? sectionsList;
    if (rawSections is List) {
      sectionsList = <Map<String, dynamic>>[];
      for (final sec in rawSections) {
        if (sec is Map) {
          sectionsList.add(sec.map((k, v) => MapEntry(k.toString(), v)));
        }
      }
    }

    if (normalizedContent.isEmpty) {
      if (sectionsList != null && sectionsList.isNotEmpty) {
        final lines = <String>[];
        for (final sec in sectionsList) {
          final heading = sec['heading'] ?? sec['title'] ?? sec['baslik'] ?? '';
          final desc = sec['description'] ?? sec['desc'] ?? sec['text'] ?? sec['aciklama'] ?? sec['content'] ?? '';
          if (heading.toString().trim().isNotEmpty && desc.toString().trim().isNotEmpty) {
            lines.add('- ${heading.toString().trim()}: ${desc.toString().trim()}');
          } else if (desc.toString().trim().isNotEmpty) {
            lines.add('- ${desc.toString().trim()}');
          } else if (heading.toString().trim().isNotEmpty) {
            lines.add('- ${heading.toString().trim()}');
          }
        }
        if (lines.isNotEmpty) normalizedContent = lines.join('\n');
      } else if (keyMessage != null && keyMessage.trim().isNotEmpty) {
        normalizedContent = '- ${keyMessage.trim()}';
      }
    }

    if (normalizedContent.isEmpty) {
      throw const FormatException('Slayt içeriği (content) geçersiz.');
    }

    final keywordsList = rawKeywords is List
        ? rawKeywords.map((k) => k.toString()).toList(growable: false)
        : const <String>[];

    final sourcesList = rawSources is List
        ? rawSources.map((s) => s.toString()).toList(growable: false)
        : const <String>[];

    Map<String, dynamic>? visualMap;
    if (rawVisual is Map) {
      visualMap = rawVisual.map((k, v) => MapEntry(k.toString(), v));
    }

    return GrokSlide(
      title: cleanedTitle,
      subtitle: subtitle != null && subtitle.trim().isNotEmpty ? subtitle.trim() : null,
      content: normalizedContent,
      keywords: keywordsList,
      type: rawType.toString().toLowerCase().trim(),
      purpose: purpose != null && purpose.trim().isNotEmpty ? purpose.trim() : null,
      keyMessage: keyMessage != null && keyMessage.trim().isNotEmpty ? keyMessage.trim() : null,
      sections: sectionsList,
      visual: visualMap,
      sources: sourcesList,
    );
  }

  static String _normalizeContent(Object? rawContent) {
    if (rawContent is String) {
      return PresentationContentQuality.normalizeContentBullets(rawContent);
    }
    if (rawContent is Map) {
      final headline = rawContent['headline'] ?? rawContent['ana_fikir'] ?? '';
      final supportingText = rawContent['supporting_text'] ?? rawContent['aciklama'] ?? '';
      final rawKeyPoints = rawContent['key_points'] ?? rawContent['maddeler'];
      final lines = <String>[];
      final cleanHeadline = headline.toString().replaceAll('*', '').trim();
      final cleanSupporting = supportingText.toString().replaceAll('*', '').trim();
      if (cleanHeadline.isNotEmpty && cleanSupporting.isNotEmpty) {
        lines.add('- $cleanHeadline: $cleanSupporting');
      } else if (cleanHeadline.isNotEmpty) {
        lines.add('- $cleanHeadline');
      } else if (cleanSupporting.isNotEmpty) {
        lines.add('- $cleanSupporting');
      }
      if (rawKeyPoints is List) {
        for (final pt in rawKeyPoints) {
          if (pt != null && pt.toString().trim().isNotEmpty) {
            final cleanPt = pt.toString().trim();
            lines.add(cleanPt.startsWith('-') ? cleanPt : '- $cleanPt');
          }
        }
      }
      if (lines.isNotEmpty) {
        return PresentationContentQuality.normalizeContentBullets(lines.join('\n'));
      }
    }
    if (rawContent is List) {
      final joined = rawContent.whereType<String>().join('\n');
      return PresentationContentQuality.normalizeContentBullets(joined);
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
  static const String _envApiKey = String.fromEnvironment('GROK_API_KEY');

  /// Grok API Anahtarı (xAI API Key).
  static String apiKey = '';

  /// Cloudflare Worker veya Backend Proxy adresi (Örn: 'https://sutols.online/')
  static String proxyUrl = 'https://sutols.online/';

  static const String _defaultApiUrl = 'https://api.x.ai/v1/chat/completions';
  static const String _defaultModel = AiModelConfig.modelGrokDefault;
  static const Duration _requestTimeout = AiModelConfig.timeoutGrok;

  static const List<String> defaultCandidateModels =
      AiModelConfig.defaultGrokCandidateModels;

  final String? customApiKey;
  final String? customProxyUrl;
  final String modelName;
  final http.Client? client;

  GrokPresentationService({
    this.customApiKey,
    this.customProxyUrl,
    this.modelName = _defaultModel,
    this.client,
  });

  String get effectiveApiKey {
    if (customApiKey != null && customApiKey!.isNotEmpty) {
      return customApiKey!;
    }
    if (apiKey.isNotEmpty) {
      return apiKey;
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
    bool checkQuality = true,
  }) async {
    final proxy = effectiveProxyUrl.trim();
    final key = effectiveApiKey.trim();

    if (proxy.isEmpty && (key.isEmpty || key == 'YOUR_GROK_API_KEY_HERE')) {
      throw Exception(
        'Grok API Key veya Proxy URL tanımlanmamış. '
        'Lütfen GrokPresentationService.proxyUrl veya apiKey alanını yapılandırın.',
      );
    }

    final systemInstruction =
        PresentationPromptBuilder.buildSystemInstruction(language: language);
    final userPrompt = PresentationPromptBuilder.buildUserPrompt(
      topic: topic,
      slideCount: slideCount,
      language: language,
    );
    final maxTokens = (slideCount * 800 + 1000).clamp(2000, 8192);

    final selectedModel = model ?? modelName;
    final modelsToTry = candidateModels ??
        [
          selectedModel,
          ...defaultCandidateModels.where((m) => m != selectedModel),
        ];

    String lastError = '';

    for (var i = 0; i < modelsToTry.length; i++) {
      final candidateModel = modelsToTry[i];
      final nextModel = i + 1 < modelsToTry.length
          ? modelsToTry[i + 1]
          : 'Kelime Tabanlı Yedek';
      final stopwatch = Stopwatch()..start();

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

        final response = await _postWithTimeout(
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
          throw const FormatException(
              'Grok yanıtında choices[0].message.content boş döndü.');
        }

        final parsed = SafeJsonParser.parsePresentationPayload(content);
        SafeJsonParser.validateSchema(parsed);
        SafeJsonParser.validateContent(parsed);

        final presentation = GrokPresentation.fromJson(parsed);

        if (checkQuality) {
          final qualityReason = PresentationContentQuality.rejectionReason(
            presentation.slides
                .map(
                  (s) => PresentationContentSample(
                    title: s.title,
                    content: s.content,
                  ),
                )
                .toList(growable: false),
          );
          if (qualityReason != null) {
            throw FormatException(
                'Grok kalite kontrolü reddedildi: $qualityReason');
          }
        }

        stopwatch.stop();
        AiRouterLogger.logSuccess(
          provider: 'Grok',
          model: candidateModel,
          attempt: i + 1,
          status: 200,
          latency: stopwatch.elapsed,
          jsonValid: true,
          schemaValid: true,
          qualityPass: true,
        );

        return presentation;
      } catch (e) {
        stopwatch.stop();
        lastError = e.toString();
        final errorType = _classifyError(e);

        final is403 = lastError.contains('403');
        final details = is403
            ? 'Grok 403 Forbidden: Team credits/licenses eksikliği (xAI API credits / license missing), model hatası değil.'
            : lastError;

        AiRouterLogger.logFailure(
          provider: 'Grok',
          model: candidateModel,
          attempt: i + 1,
          errorType: errorType,
          latency: stopwatch.elapsed,
          details: details,
          action: 'FALLBACK → $nextModel',
        );
      }
    }

    throw Exception(
        lastError.isEmpty ? 'Grok sunum üretimi başarısız oldu.' : lastError);
  }

  Future<http.Response> _postWithTimeout({
    required Map<String, dynamic> body,
    required String key,
    required String proxyUrl,
  }) async {
    final useProxy = proxyUrl.isNotEmpty;
    final targetUri = Uri.parse(useProxy ? proxyUrl : _defaultApiUrl);
    final httpClient = client;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (!useProxy && key.isNotEmpty) 'Authorization': 'Bearer $key',
    };

    http.Response response;
    try {
      response = await (httpClient != null
              ? httpClient.post(
                  targetUri,
                  headers: headers,
                  body: jsonEncode(body),
                )
              : http.post(
                  targetUri,
                  headers: headers,
                  body: jsonEncode(body),
                ))
          .timeout(
        _requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Grok isteği ${_requestTimeout.inSeconds} saniyede zaman aşımına uğradı.',
        ),
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Grok bağlantı hatası: $e');
    }

    if (response.statusCode == 200) {
      return response;
    }

    // 400 Bad Request: response_format kaldırıp tek seferlik dene
    if (response.statusCode == 400 && body.containsKey('response_format')) {
      final fallbackBody = Map<String, dynamic>.from(body)
        ..remove('response_format');
      try {
        final fallbackResponse = await (httpClient != null
                ? httpClient.post(
                    targetUri,
                    headers: headers,
                    body: jsonEncode(fallbackBody),
                  )
                : http.post(
                    targetUri,
                    headers: headers,
                    body: jsonEncode(fallbackBody),
                  ))
            .timeout(_requestTimeout);
        if (fallbackResponse.statusCode == 200) {
          return fallbackResponse;
        }
      } catch (_) {}
    }

    throw HttpExceptionWithStatus(
      statusCode: response.statusCode,
      message: _statusErrorMessage(
        statusCode: response.statusCode,
        responseBody: response.body,
      ),
    );
  }

  static AiErrorType _classifyError(dynamic error) {
    if (error is TimeoutException) return AiErrorType.timeout;
    if (error is HttpExceptionWithStatus) {
      return AiModelConfig.classifyStatusCode(error.statusCode);
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('zaman aşımı') ||
        msg.contains('timed out') ||
        msg.contains('timeout')) {
      return AiErrorType.timeout;
    }
    if (msg.contains('kalite kontrolü') || msg.contains('yetersiz içerik')) {
      return AiErrorType.qualityRejection;
    }
    if (msg.contains('şema') ||
        msg.contains('schema') ||
        msg.contains('başlığı boş')) {
      return AiErrorType.schemaError;
    }
    if (msg.contains('json') || msg.contains('formatexception')) {
      return AiErrorType.invalidJson;
    }
    return AiErrorType.unknown;
  }

  static String _statusErrorMessage({
    required int statusCode,
    required String responseBody,
  }) {
    final body = responseBody.trim();
    final bodySuffix = body.isEmpty ? '' : ' Detay: $body';
    switch (statusCode) {
      case 400:
        return 'Grok AI isteği geçersiz (400).$bodySuffix';
      case 401:
        return 'Grok AI yetkilendirme hatası (401).$bodySuffix';
      case 403:
        return 'Grok AI erişim engellendi (403 Forbidden). Team credits/licenses eksikliği (xAI API credits / license missing), model hatası değil.$bodySuffix';
      case 404:
        return 'Grok AI endpoint bulunamadı (404).$bodySuffix';
      case 429:
        return 'Grok AI hız sınırına takıldı (429).$bodySuffix';
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
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
      throw FormatException(onError);
    }
    return decoded;
  }

  @visibleForTesting
  static Map<String, dynamic> parsePresentationPayload(String rawContent) =>
      SafeJsonParser.parsePresentationPayload(rawContent);

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

class HttpExceptionWithStatus implements Exception {
  final int statusCode;
  final String message;

  const HttpExceptionWithStatus({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}
