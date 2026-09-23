import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
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
  /// Yerel biçim denetimini AI konu/dil denetimiyle birleştirir.
  /// Yüksek bir AI puanı yerel biçim ihlalini geçersiz kılamaz.
  Future<QualityScoreResult> judgePresentation({
    required NvidiaPresentation presentation,
    required String topic,
    String targetAudience = 'general',
    String language = 'turkish',
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
      language: language,
    );

    // Heuristik yalnızca biçim, yoğunluk ve tekrar sinyalidir; konu
    // doğruluğunu kanıtlayamaz. Bu nedenle her üretim AI denetiminden geçer.
    try {
      final judgePrompt =
          '''Aşağıdaki sunumu pedagojik doğruluk, hedef kitle uyumu, anlatı akışı ve tekrar açısından denetle.

KONU: $topic
HEDEF KİTLE: $targetAudience
DİL: $language
SLAYT SAYISI: ${presentation.slides.length}

SUNUM:
${jsonEncode({
            'slides': presentation.slides
                .map((s) => {
                      'title': s.title,
                      'purpose': s.purpose,
                      'content': s.content,
                      'type': s.type,
                      'visual': s.visual,
                    })
                .toList()
          })}

Yalnızca ve doğrudan tek bir JSON nesnesi dön:
{
  "score": 0-100_arasi_genel_puan,
  "factual_accuracy": 0-100_arasi_konu_dogrulugu,
  "visual_relevance": 0-100_arasi_gorsel_alaka,
  "revision_required": true/false,
  "issues": [
    {"slide": 1, "category": "factual_accuracy|visual_relevance|audience_fit|redundancy|pedagogy", "problem": "Kısa problem tanımı"}
  ],
  "global_issues": ["Genel sorun varsa"]
}

ZORUNLU DENETİM:
1. Her iddiayı konunun yerleşik bilgisiyle karşılaştır. Fizik, kimya, tarih,
   biyoloji veya matematikte yanlış/uydurma ifade varsa factual_accuracy'yi
   ciddi biçimde düşür ve ilgili slaytı issue olarak yaz.
2. visual.subject, must_include, must_avoid veya kind varsa; bunların slayt
   metnini somut biçimde destekleyip desteklemediğini ayrıca denetle.
3. Biçim düzgün olsa bile kavramsal hata varsa yüksek puan verme.
4. Türkçe madde slaytlarında Vurgulu Başlık: Açıklama biçimini denetle:
   başlık 1-5 kelime, açıklama en fazla 20 kelimelik tam bir cümle olmalı.
   Kapak, alıntı ve tek soruluk slaytlar hariç eksik biçimi content_format
   kategorisinde bildir ve revision_required=true yap.
5. Eksik yüklem, yanlış iyelik/durum/bağlaç eki, birebir çeviri ve yinelenen
   fikirleri denetle; bozuk Türkçeyi readability kategorisinde bildir.
   Girişte kapsam, ana düşünce ve temel sorunun açık olduğunu kontrol et.''';

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
        final content =
            (decoded['choices']?[0]?['message']?['content'] ?? '').toString();
        Map<String, dynamic>? parsedJudge;
        try {
          final direct = jsonDecode(content);
          if (direct is Map) {
            parsedJudge = direct.map((k, v) => MapEntry(k.toString(), v));
          }
        } catch (_) {}
        if (parsedJudge == null &&
            content.contains('{') &&
            content.contains('}')) {
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
          final factualPercent = parsedJudge['factual_accuracy'] is num
              ? (parsedJudge['factual_accuracy'] as num)
                  .toInt()
                  .clamp(0, 100)
                  .toInt()
              : heuristicResult.factualAccuracy * 5;
          final visualPercent = parsedJudge['visual_relevance'] is num
              ? (parsedJudge['visual_relevance'] as num)
                  .toInt()
                  .clamp(0, 100)
                  .toInt()
              : heuristicResult.visualPotential * 20;
          // A deck cannot pass merely because it is well formatted.  Topic
          // correctness is a hard ceiling on the aggregate result.
          final correctedScore = math
              .min(
                judgeScore.clamp(0, 100),
                factualPercent,
              )
              .toInt();

          final rawIssues = parsedJudge['issues'];
          final issuesList = <Map<String, dynamic>>[
            ...heuristicResult.slideIssues,
          ];
          if (rawIssues is List) {
            for (final item in rawIssues) {
              if (item is Map) {
                // Exact label and word-count rules are deterministic. The
                // small AI judge can incorrectly flag already-valid bullets.
                if (item['category'] == 'content_format' &&
                    !heuristicResult.slideIssues.any((issue) =>
                        issue['category'] == 'content_format' &&
                        issue['slide'] == item['slide'])) {
                  continue;
                }
                issuesList.add(item.map((k, v) => MapEntry(k.toString(), v)));
              }
            }
          }

          final rawGlobal = parsedJudge['global_issues'];
          final globalList = rawGlobal is List
              ? rawGlobal.map((e) => e.toString()).toList()
              : heuristicResult.globalIssues;

          return QualityScoreResult(
            overallScore: correctedScore,
            factualAccuracy: (factualPercent / 5).round().clamp(0, 20).toInt(),
            audienceFit: heuristicResult.audienceFit,
            pedagogicalValue: heuristicResult.pedagogicalValue,
            narrativeCoherence: heuristicResult.narrativeCoherence,
            redundancy: heuristicResult.redundancy,
            readability: heuristicResult.readability,
            visualPotential: math
                .min(
                  heuristicResult.visualPotential,
                  (visualPercent / 20).round().clamp(0, 5),
                )
                .toInt(),
            slideIssues: issuesList.isNotEmpty
                ? issuesList
                : heuristicResult.slideIssues,
            globalIssues: globalList,
            needsRevision: heuristicResult.needsRevision ||
                parsedJudge['revision_required'] == true ||
                (correctedScore >= 75 && correctedScore < 85),
            isPass: correctedScore >= 85 &&
                !heuristicResult.needsRevision &&
                parsedJudge['revision_required'] != true,
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
      'slides': originalPresentation.slides
          .map((s) => {
                'title': s.title,
                if (s.purpose != null) 'purpose': s.purpose,
                'type': s.type,
                'content': s.content,
                if (s.keywords.isNotEmpty) 'visual_keywords': s.keywords,
                if (s.visual != null) 'visual': s.visual,
              })
          .toList()
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
        {
          'role': 'system',
          'content': PresentationPromptBuilder.buildSystemInstruction(
              language: language)
        },
        {'role': 'user', 'content': revisionPrompt}
      ],
      'temperature': 0.3,
      'max_tokens': (slideCount * 650 + 1800).clamp(4096, 6144),
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
      final content =
          (decoded['choices']?[0]?['message']?['content'] ?? '').toString();
      final parsed = SafeJsonParser.parsePresentationPayload(content);
      return NvidiaPresentation.fromJson(parsed);
    }

    throw Exception(
        'Revizyon isteği başarısız oldu (HTTP ${response.statusCode}).');
  }
}
