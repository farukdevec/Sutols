import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'ai_model_config.dart';
import 'presentation_content_quality.dart';
import 'presentation_judge_service.dart';
import 'presentation_prompt_builder.dart';
import 'safe_json_parser.dart';

/// Gemini / NVIDIA / Grok için standart slayt yapısı.
class NvidiaSlide {
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

  const NvidiaSlide({
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

  factory NvidiaSlide.fromJson(Map<String, dynamic> json) {
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
        if (lines.isNotEmpty) {
          normalizedContent = lines.join('\n');
        }
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

    return NvidiaSlide(
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

/// Üst düzey yanıt yapısı: { "title": "...", "target_audience": "...", "learning_objective": "...", "slides": [...] }
class NvidiaPresentation {
  final String? title;
  final String? targetAudience;
  final String? learningObjective;
  final List<NvidiaSlide> slides;

  const NvidiaPresentation({
    this.title,
    this.targetAudience,
    this.learningObjective,
    required this.slides,
  });

  factory NvidiaPresentation.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? json['baslik'])?.toString();
    final targetAudience = (json['target_audience'] ?? json['hedef_kitle'])?.toString();
    final learningObjective = (json['learning_objective'] ?? json['ogrenme_hedefi'])?.toString();
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
        throw FormatException('Slayt ${i + 1} geçerli bir JSON nesnesi değil.');
      }
      slides.add(
        NvidiaSlide.fromJson(
          rawSlide.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }
    return NvidiaPresentation(
      title: title != null && title.trim().isNotEmpty ? title.trim() : null,
      targetAudience: targetAudience != null && targetAudience.trim().isNotEmpty ? targetAudience.trim() : null,
      learningObjective: learningObjective != null && learningObjective.trim().isNotEmpty ? learningObjective.trim() : null,
      slides: slides,
    );
  }
}

class NvidiaPresentationService {
  static const String defaultProxyUrl = 'https://sutols.online/';
  static const String defaultModelName = AiModelConfig.modelNemotronSuper;
  static const List<String> defaultCandidateModels =
      AiModelConfig.defaultNvidiaCandidateModels;

  final String proxyUrl;
  final String modelName;
  final List<String>? customCandidateModels;
  final http.Client? client;

  NvidiaPresentationService({
    this.proxyUrl = defaultProxyUrl,
    this.modelName = defaultModelName,
    this.customCandidateModels,
    this.client,
  });

  Future<NvidiaPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
    String? model,
    List<String>? candidateModels,
    bool checkQuality = true,
  }) async {
    final systemInstruction =
        PresentationPromptBuilder.buildSystemInstruction(language: language);
    final userPrompt = PresentationPromptBuilder.buildUserPrompt(
      topic: topic,
      slideCount: slideCount,
      language: language,
    );
    final maxTokens = (slideCount * 800 + 2000).clamp(4096, 8192);

    final selectedModel = model ?? modelName;
    final modelsToTry = candidateModels ??
        customCandidateModels ??
        [
          selectedModel,
          ...defaultCandidateModels.where((m) => m != selectedModel),
        ];

    assert(() {
      // ignore: avoid_print
      print(
        '[AI PROMPT DEBUG]\n'
        'provider: nvidia\n'
        'model: $selectedModel\n'
        'system prompt length: ${systemInstruction.length}\n'
        'user prompt length: ${userPrompt.length}\n'
        'schema: slides[title, type, content, keywords]\n'
        'slide count: $slideCount',
      );
      return true;
    }());

    String lastError = '';

    for (var i = 0; i < modelsToTry.length; i++) {
      final candidateModel = modelsToTry[i];
      final timeout =
          AiModelConfig.timeoutForModel(candidateModel, slideCount: slideCount);
      final nextModel =
          i + 1 < modelsToTry.length ? modelsToTry[i + 1] : 'Gemini Fallback';

      final stopwatch = Stopwatch()..start();

      try {
        final body = {
          'model': candidateModel,
          'messages': [
            {
              'role': 'system',
              'content': systemInstruction,
            },
            {
              'role': 'user',
              'content': userPrompt,
            },
          ],
          'temperature': 0.2,
          'max_tokens': maxTokens,
          'response_format': {
            'type': 'json_object',
          },
          'stream': false,
        };

        final response = await _postWithTimeout(body, timeout: timeout);
        final responseJson = _decodeJsonMap(
          response.body,
          onError: 'NVIDIA API / Proxy geçerli JSON döndürmedi.',
        );
        final content = _extractAssistantContent(responseJson);

        if (content == null || content.isEmpty) {
          throw const FormatException('choices[0].message.content boş döndü.');
        }

        final parsed = SafeJsonParser.parsePresentationPayload(content);
        SafeJsonParser.validateSchema(parsed);
        SafeJsonParser.validateContent(parsed);

        var presentation = NvidiaPresentation.fromJson(parsed);
        if (client == null && presentation.slides.length > slideCount) {
          presentation = NvidiaPresentation(
            slides:
                presentation.slides.take(slideCount).toList(growable: false),
          );
        }
        final minAllowedSlides = (slideCount - 1).clamp(3, slideCount);
        if (client == null && presentation.slides.length < minAllowedSlides) {
          throw FormatException(
            'NVIDIA $candidateModel $slideCount yerine '
            '${presentation.slides.length} slayt döndürdü.',
          );
        }

        final judgeService = PresentationJudgeService(
          proxyUrl: proxyUrl,
          client: client,
        );

        var qualityResult = await judgeService.judgePresentation(
          presentation: presentation,
          topic: topic,
          targetAudience: topic,
        );

        AiRouterLogger.logDetailedQuality(
          overall: qualityResult.overallScore,
          accuracy: qualityResult.factualAccuracy,
          audienceFit: qualityResult.audienceFit,
          pedagogy: qualityResult.pedagogicalValue,
          narrative: qualityResult.narrativeCoherence,
          redundancy: qualityResult.redundancy,
          readability: qualityResult.readability,
          visual: qualityResult.visualPotential,
        );

        // Smart Revision Loop (75 - 84 band)
        if (checkQuality && qualityResult.needsRevision) {
          AiRouterLogger.logJudge(
            score: qualityResult.overallScore,
            revision: true,
            issues: qualityResult.slideIssues
                .map((e) => e['problem']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList(),
          );

          final revStopwatch = Stopwatch()..start();
          try {
            final revised = await judgeService.revisePresentation(
              originalPresentation: presentation,
              qualityResult: qualityResult,
              topic: topic,
              slideCount: slideCount,
              language: language,
              modelName: candidateModel,
            );
            revStopwatch.stop();

            final revisedQuality = await judgeService.judgePresentation(
              presentation: revised,
              topic: topic,
              targetAudience: topic,
            );

            if (revisedQuality.overallScore > qualityResult.overallScore) {
              presentation = revised;
              qualityResult = revisedQuality;
              AiRouterLogger.logRevision(
                attempt: 1,
                status: 'SUCCESS',
                latency: revStopwatch.elapsed,
              );
            } else {
              AiRouterLogger.logRevision(
                attempt: 1,
                status: 'KEPT_ORIGINAL',
                latency: revStopwatch.elapsed,
              );
            }
          } catch (revError) {
            revStopwatch.stop();
            AiRouterLogger.logRevision(
              attempt: 1,
              status: 'FAILED ($revError)',
              latency: revStopwatch.elapsed,
            );
          }
        } else {
          AiRouterLogger.logJudge(
            score: qualityResult.overallScore,
            revision: false,
          );
          AiRouterLogger.logRevision(
            attempt: 0,
            status: 'SKIPPED',
          );
        }

        if (checkQuality) {
          if (qualityResult.overallScore < 75) {
            final isLastCandidate = i == modelsToTry.length - 1;
            if (!isLastCandidate) {
              throw FormatException(
                'Kalite kontrolü ve denetçi reddetti (Skor: ${qualityResult.overallScore}/100, minimum 75 gereklidir).',
              );
            }
          }
        }

        final keyHeader = response.headers['x-ai-key'] ?? 'key1';
        final modelHeader = response.headers['x-ai-model'] ?? candidateModel;

        stopwatch.stop();
        AiRouterLogger.logSuccess(
          provider: 'NVIDIA',
          key: keyHeader,
          model: modelHeader,
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

        AiRouterLogger.logFailure(
          provider: 'NVIDIA',
          key: 'key1',
          model: candidateModel,
          attempt: i + 1,
          errorType: errorType,
          latency: stopwatch.elapsed,
          details: lastError,
          action: i == 0 ? 'FALLBACK_TO_KEY2' : 'FALLBACK → $nextModel',
        );
      }
    }

    throw Exception(
        lastError.isEmpty ? 'NVIDIA sunum üretimi başarısız oldu.' : lastError);
  }

  Future<http.Response> _postWithTimeout(
    Map<String, dynamic> body, {
    required Duration timeout,
  }) async {
    final httpClient = client;
    http.Response response;

    final headers = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Origin': 'https://sutols.com',
    };

    try {
      response = await (httpClient != null
              ? httpClient.post(
                  Uri.parse(proxyUrl),
                  headers: headers,
                  body: jsonEncode(body),
                )
              : http.post(
                  Uri.parse(proxyUrl),
                  headers: headers,
                  body: jsonEncode(body),
                ))
          .timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
          'NVIDIA ($proxyUrl) isteği ${timeout.inSeconds} saniyede zaman aşımına uğradı.',
        ),
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }

    if (response.statusCode == 200) {
      return response;
    }

    // 400 Bad Request: response_format desteklenmiyorsa tek seferlik formatsız dene
    if (response.statusCode == 400 && body.containsKey('response_format')) {
      final fallbackBody = Map<String, dynamic>.from(body)
        ..remove('response_format');
      try {
        final fallbackResponse = await (httpClient != null
                ? httpClient.post(
                    Uri.parse(proxyUrl),
                    headers: headers,
                    body: jsonEncode(fallbackBody),
                  )
                : http.post(
                    Uri.parse(proxyUrl),
                    headers: headers,
                    body: jsonEncode(fallbackBody),
                  ))
            .timeout(timeout);
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
    if (msg.contains('bağlantı') ||
        msg.contains('network') ||
        msg.contains('socketexception')) {
      return AiErrorType.networkError;
    }
    return AiErrorType.unknown;
  }

  static String _statusErrorMessage({
    required int statusCode,
    required String responseBody,
  }) {
    final detail = _extractErrorDetail(responseBody);
    switch (statusCode) {
      case 400:
        return 'AI isteği geçersiz (400). Detay: $detail';
      case 401:
        return 'AI kimlik doğrulaması başarısız (401). API anahtarını kontrol edin. Detay: $detail';
      case 403:
        return 'AI erişim engellendi (403). Origin/CORS ayarlarını kontrol edin. Detay: $detail';
      case 429:
        return 'AI hız limiti aşıldı (429 Rate Limit). Başka modele geçiliyor. Detay: $detail';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'AI sunucu hatası ($statusCode). Sağlayıcı yanıt vermedi. Detay: $detail';
      default:
        return 'AI HTTP $statusCode hatası. Detay: $detail';
    }
  }

  static String _extractErrorDetail(String responseBody) {
    if (responseBody.trim().isEmpty) return 'Yanıt gövdesi boş';
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        if (decoded['error'] is Map && decoded['error']['message'] != null) {
          return decoded['error']['message'].toString();
        }
        if (decoded['error'] != null) {
          return decoded['error'].toString();
        }
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }
      }
    } catch (_) {}
    return responseBody.length > 200
        ? '${responseBody.substring(0, 200)}...'
        : responseBody;
  }

  static Map<String, dynamic> _decodeJsonMap(
    String raw, {
    required String onError,
  }) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw FormatException(onError);
    } catch (_) {
      try {
        return SafeJsonParser.parsePresentationPayload(raw);
      } catch (_) {
        throw FormatException(onError);
      }
    }
  }

  static String? _extractAssistantContent(Map<String, dynamic> responseJson) {
    if (responseJson['choices'] is List &&
        (responseJson['choices'] as List).isNotEmpty) {
      final choice = (responseJson['choices'] as List).first;
      if (choice is Map && choice['message'] is Map) {
        final message = choice['message'] as Map;
        final content = message['content'];
        if (content is String) return content;
      }
    }
    return null;
  }

  static Map<String, dynamic> parsePresentationPayload(String raw) =>
      SafeJsonParser.parsePresentationPayload(raw);

  @visibleForTesting
  static String normalizeContentForTesting(Object? content) =>
      NvidiaSlide._normalizeContent(content);
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
