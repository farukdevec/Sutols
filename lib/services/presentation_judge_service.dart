import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_model_config.dart';
import 'nvidia_presentation_service.dart';
import 'presentation_content_quality.dart';
import 'presentation_prompt_builder.dart';
import 'safe_json_parser.dart';

/// Hızlı ve deterministik AI Denetçi (Judge) ve Revizyon Servisi
class PresentationJudgeService {
  final String proxyUrl;
  final http.Client? client;

  PresentationJudgeService({
    this.proxyUrl = NvidiaPresentationService.defaultProxyUrl,
    this.client,
  });

  /// Sunumu çok boyutlu olarak denetler.
  /// Skor >= 85 ise ek ağ maliyeti yaratmadan anında PASS döner.
  /// Skor 75-84 aralığında ise hızlı AI Judge analizi yapar.
  Future<QualityScoreResult> judgePresentation({
    required NvidiaPresentation presentation,
    required String topic,
    String targetAudience = 'general',
    bool forceAiJudge = false,
  }) async {
    final samples = presentation.slides
        .map((s) => PresentationContentSample(
              title: s.title,
              content: s.content,
              type: s.type,
              purpose: s.purpose,
              keywords: s.keywords,
              visual: s.visual,
            ))
        .toList(growable: false);

    final heuristicResult = PresentationContentQuality.evaluateQuality(
      samples,
      targetAudience: targetAudience,
    );

    // Skor zaten yüksekse (>=85) veya tamamen geçersizse (<60) ve zorlama yoksa ek AI çağrısına gerek yok
    if (!forceAiJudge && (heuristicResult.overallScore >= 85 || heuristicResult.overallScore < 60)) {
      return heuristicResult;
    }

    // 75-84 aralığında hızlı model ile AI Judge denetimi
    try {
      final judgePrompt = '''Aşağıdaki sunumu pedagojik doğruluk, hedef kitle uyumu, anlatı akışı ve tekrar açısından denetle.

KONU: $topic
HEDEF KİTLE: $targetAudience
SLAYT SAYISI: ${presentation.slides.length}

SUNUM:
${jsonEncode({
        'slides': presentation.slides.map((s) => {
              'title': s.title,
              'purpose': s.purpose,
              'content': s.content,
              'type': s.type,
            }).toList()
      })}

Yalnızca ve doğrudan tek bir JSON nesnesi dön:
{
  "score": 0-100_arasi_puan,
  "revision_required": true/false,
  "issues": [
    {"slide": 1, "category": "audience_fit|redundancy|pedagogy", "problem": "Kısa problem tanımı"}
  ],
  "global_issues": ["Genel sorun varsa"]
}''';

      final httpClient = client;
      final body = {
        'model': AiModelConfig.modelLlama31_8b,
        'messages': [
          {'role': 'user', 'content': judgePrompt}
        ],
        'temperature': 0.1,
        'max_tokens': 500,
      };

      final response = await (httpClient != null
              ? httpClient.post(
                  Uri.parse(proxyUrl),
                  headers: const {
                    'Content-Type': 'application/json',
                    'Origin': 'https://sutols.com',
                  },
                  body: jsonEncode(body),
                )
              : http.post(
                  Uri.parse(proxyUrl),
                  headers: const {
                    'Content-Type': 'application/json',
                    'Origin': 'https://sutols.com',
                  },
                  body: jsonEncode(body),
                ))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final content = (decoded['choices']?[0]?['message']?['content'] ?? '').toString();
        Map<String, dynamic>? parsedJudge;
        try {
          final direct = jsonDecode(content);
          if (direct is Map) {
            parsedJudge = direct.map((k, v) => MapEntry(k.toString(), v));
          }
        } catch (_) {}
        if (parsedJudge == null && content.contains('{') && content.contains('}')) {
          try {
            final firstBrace = content.indexOf('{');
            final lastBrace = content.lastIndexOf('}');
            final sub = content.substring(firstBrace, lastBrace + 1);
            final direct = jsonDecode(sub);
            if (direct is Map) {
              parsedJudge = direct.map((k, v) => MapEntry(k.toString(), v));
            }
          } catch (_) {}
        }

        if (parsedJudge != null) {
          final judgeScore = parsedJudge['score'] is num
              ? (parsedJudge['score'] as num).toInt()
              : heuristicResult.overallScore;

          final rawIssues = parsedJudge['issues'];
          final issuesList = <Map<String, dynamic>>[];
          if (rawIssues is List) {
            for (final item in rawIssues) {
              if (item is Map) {
                issuesList.add(item.map((k, v) => MapEntry(k.toString(), v)));
              }
            }
          }

          final rawGlobal = parsedJudge['global_issues'];
          final globalList = rawGlobal is List
              ? rawGlobal.map((e) => e.toString()).toList()
              : heuristicResult.globalIssues;

          return QualityScoreResult(
            overallScore: judgeScore,
            factualAccuracy: heuristicResult.factualAccuracy,
            audienceFit: heuristicResult.audienceFit,
            pedagogicalValue: heuristicResult.pedagogicalValue,
            narrativeCoherence: heuristicResult.narrativeCoherence,
            redundancy: heuristicResult.redundancy,
            readability: heuristicResult.readability,
            visualPotential: heuristicResult.visualPotential,
            slideIssues: issuesList.isNotEmpty ? issuesList : heuristicResult.slideIssues,
            globalIssues: globalList,
            needsRevision: judgeScore >= 75 && judgeScore < 85,
            isPass: judgeScore >= 85,
          );
        }
      }
    } catch (_) {
      // Ağ veya model hatasında güvenilir deterministik sonuca güven
    }

    return heuristicResult;
  }

  /// Sorunlu slaytları ana yüksek kaliteli model ile hedefe yönelik revize eder.
  Future<NvidiaPresentation> revisePresentation({
    required NvidiaPresentation originalPresentation,
    required QualityScoreResult qualityResult,
    required String topic,
    required int slideCount,
    required String language,
    String modelName = AiModelConfig.modelNemotronSuper,
  }) async {
    final originalJson = jsonEncode({
      'slides': originalPresentation.slides.map((s) => {
            'title': s.title,
            if (s.purpose != null) 'purpose': s.purpose,
            'type': s.type,
            'content': s.content,
            if (s.keywords.isNotEmpty) 'visual_keywords': s.keywords,
            if (s.visual != null) 'visual': s.visual,
          }).toList()
    });

    final revisionPrompt = PresentationPromptBuilder.buildRevisionPrompt(
      originalJson: originalJson,
      issues: qualityResult.slideIssues,
      globalIssues: qualityResult.globalIssues,
      topic: topic,
      slideCount: slideCount,
      language: language,
    );

    final httpClient = client;
    final body = {
      'model': modelName,
      'messages': [
        {'role': 'user', 'content': revisionPrompt}
      ],
      'temperature': 0.3,
      'max_tokens': 4096,
    };

    final response = await (httpClient != null
            ? httpClient.post(
                Uri.parse(proxyUrl),
                headers: const {
                  'Content-Type': 'application/json',
                  'Origin': 'https://sutols.com',
                },
                body: jsonEncode(body),
              )
            : http.post(
                Uri.parse(proxyUrl),
                headers: const {
                  'Content-Type': 'application/json',
                  'Origin': 'https://sutols.com',
                },
                body: jsonEncode(body),
              ))
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final content = (decoded['choices']?[0]?['message']?['content'] ?? '').toString();
      final parsed = SafeJsonParser.parsePresentationPayload(content);
      return NvidiaPresentation.fromJson(parsed);
    }

    throw Exception('Revizyon isteği başarısız oldu (HTTP ${response.statusCode}).');
  }
}
