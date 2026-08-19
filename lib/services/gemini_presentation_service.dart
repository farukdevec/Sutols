import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';

import 'ai_model_config.dart';
import 'presentation_content_quality.dart';
import 'presentation_prompt_builder.dart';
import 'safe_json_parser.dart';

/// Gemini'nin response_schema ile zorladığı tek slayt yapısı.
class GeminiSlide {
  final String title;
  final String content;
  final List<String> keywords;
  final String type;

  const GeminiSlide({
    required this.title,
    required this.content,
    required this.keywords,
    this.type = 'cards',
  });

  factory GeminiSlide.fromJson(Map<String, dynamic> json) {
    final rawTitle = (json['title'] ?? json['baslik']) as String? ?? '';
    final rawContent = json['content'] ?? json['icerik'];
    final rawKeywords = json['keywords'] ?? json['anahtar_kelimeler'];
    final rawType = json['type'] ?? json['slide_type'] ?? json['layout'] ?? json['tip'] ?? 'cards';

    String contentStr = '';
    if (rawContent is String) {
      contentStr = rawContent;
    } else if (rawContent is List) {
      contentStr = rawContent.whereType<String>().join('\n');
    }

    final keywordsList = rawKeywords is List
        ? rawKeywords.map((k) => k.toString()).toList(growable: false)
        : const <String>[];

    return GeminiSlide(
      title: PresentationContentQuality.sanitizeTitle(rawTitle),
      content: contentStr,
      keywords: keywordsList,
      type: rawType.toString().toLowerCase().trim(),
    );
  }
}

/// Üst düzey yanıt yapısı: { "slides": [...] }
class GeminiPresentation {
  final List<GeminiSlide> slides;

  const GeminiPresentation({required this.slides});

  factory GeminiPresentation.fromJson(Map<String, dynamic> json) {
    final rawSlides = json['slides'] as List? ?? const [];
    return GeminiPresentation(
      slides: rawSlides
          .map((s) => GeminiSlide.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Geçmişte dışa aktarılmış (başarılı bulunmuş) bir sunumun prompt
/// referansı için yalnızca yapı bilgisi: slayt başlıkları + yerleşimler.
class _PastExample {
  const _PastExample({
    required this.topic,
    required this.titles,
    required this.layouts,
  });

  final String topic;
  final List<String> titles;
  final List<String> layouts;
}

class GeminiPresentationService {
  GeminiPresentationService({FirebaseAI? ai})
      : _ai = ai ?? FirebaseAI.googleAI();

  final FirebaseAI _ai;
  final _db = FirebaseFirestore.instance;

  static const String modelName = AiModelConfig.modelGeminiFlash;
  static const Duration timeout = AiModelConfig.timeoutGemini;

  static Schema _slideSchema() {
    return Schema.object(
      properties: {
        'title': Schema.string(),
        'type': Schema.string(),
        'content': Schema.string(),
        'keywords': Schema.array(items: Schema.string()),
      },
    );
  }

  /// Konu metnine göre Gemini'den JSON sunum yapısı üretir.
  Future<GeminiPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
    bool checkQuality = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final systemInstruction = PresentationPromptBuilder.buildSystemInstruction();
    final maxTokens = (slideCount * 800 + 1000).clamp(3000, 16384);

    try {
      final model = _ai.generativeModel(
        model: modelName,
        systemInstruction: Content.system(systemInstruction),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'slides': Schema.array(
                items: _slideSchema(),
                minItems: slideCount,
                maxItems: slideCount,
              ),
            },
          ),
          maxOutputTokens: maxTokens,
        ),
      );

      // Geçmiş referans aramasını 1.5s ile sınırla (üretimi geciktirmesin)
      final references = await _findSimilarExported(topic)
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => const []);
      final referenceBlock =
          references.isEmpty ? '' : _buildReferenceBlock(references);

      final prompt = PresentationPromptBuilder.buildUserPrompt(
        topic: topic,
        slideCount: slideCount,
        language: language,
        referenceBlock: referenceBlock,
      );

      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Gemini isteği ${timeout.inSeconds} saniyede zaman aşımına uğradı.');
      });

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Gemini boş yanıt döndürdü.');
      }

      final json = SafeJsonParser.parsePresentationPayload(text);
      SafeJsonParser.validateSchema(json);
      SafeJsonParser.validateContent(json);

      final presentation = GeminiPresentation.fromJson(json);

      if (checkQuality) {
        final reason = PresentationContentQuality.rejectionReason(
          presentation.slides
              .map(
                (s) => PresentationContentSample(
                  title: s.title,
                  content: s.content,
                ),
              )
              .toList(growable: false),
        );
        if (reason != null) {
          throw FormatException('Gemini sunum kalite kontrolü: $reason');
        }
      }

      stopwatch.stop();
      AiRouterLogger.logSuccess(
        provider: 'Gemini',
        model: modelName,
        attempt: 1,
        status: 200,
        latency: stopwatch.elapsed,
        jsonValid: true,
        schemaValid: true,
        qualityPass: true,
      );

      return presentation;
    } catch (e) {
      stopwatch.stop();
      final errorType = e is TimeoutException ? AiErrorType.timeout : AiErrorType.unknown;
      AiRouterLogger.logFailure(
        provider: 'Gemini',
        model: modelName,
        attempt: 1,
        errorType: errorType,
        latency: stopwatch.elapsed,
        details: e.toString(),
        action: 'FALLBACK → Grok',
      );
      rethrow;
    }
  }

  /// Konuyla en yakın eşleşen ve `wasExported == true` olan en fazla 2 geçmiş sunumu döndürür.
  Future<List<_PastExample>> _findSimilarExported(String topic) async {
    try {
      final tokens = _tokens(topic);
      if (tokens.isEmpty) return const [];
      final keyword = tokens.first;

      final snapshot = await _db
          .collection('presentations')
          .where('topic', isGreaterThanOrEqualTo: keyword)
          .where('topic', isLessThanOrEqualTo: '$keyword\uf8ff')
          .limit(20)
          .get();

      final topicTokens = _tokens(topic);
      final scored = <(int, DocumentSnapshot<Map<String, dynamic>>)>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['wasExported'] != true) {
          continue;
        }
        final score = _tokenOverlap(
          topicTokens,
          _tokens(data['topic'] as String? ?? ''),
        );
        if (score > 0) {
          scored.add((score, doc));
        }
      }
      scored.sort((a, b) => b.$1.compareTo(a.$1));

      final examples = <_PastExample>[];
      for (final entry in scored.take(2)) {
        final example = await _exampleFromDoc(entry.$2);
        if (example.titles.isEmpty) {
          continue;
        }
        examples.add(example);
      }
      return examples;
    } catch (_) {
      return const [];
    }
  }

  static String _buildReferenceBlock(List<_PastExample> examples) {
    final parts = examples.map((e) {
      final titles = e.titles.join(', ');
      final layouts = e.layouts.toSet().where((l) => l.isNotEmpty).join(', ');
      return layouts.isEmpty ? '[$titles]' : '[$titles — yerleşim: $layouts]';
    }).join(', ');
    return '''Referans olarak, geçmişte başarılı bulunan benzer sunumların yapısı: $parts. Buna benzer kalitede ve yapıda bir sunum üret, ama konuyu birebir kopyalama, yeni ve özgün içerik oluştur.

''';
  }

  Future<_PastExample> _exampleFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data()!;
    final embedded = data['slides'];
    List<Map<String, dynamic>> slides;
    if (embedded is List) {
      slides = embedded
          .whereType<Map<dynamic, dynamic>>()
          .map((slide) => {
                'title': slide['title'] as String? ?? '',
                'layout': slide['layout'] as String? ?? '',
              })
          .toList();
    } else {
      try {
        final slideDocs = await _db
            .collection('presentations')
            .doc(doc.id)
            .collection('slides')
            .orderBy('order')
            .get();
        slides = slideDocs.docs.map((slideDoc) {
          final slideData = slideDoc.data();
          return {
            'title': slideData['title'] as String? ?? '',
            'layout': slideData['layout'] as String? ?? '',
          };
        }).toList();
      } catch (_) {
        slides = const [];
      }
    }
    return _PastExample(
      topic: data['topic'] as String? ?? '',
      titles: slides
          .map((s) => s['title'] as String)
          .where((t) =>
              t.isNotEmpty &&
              !_isUiInstructionTitle(t))
          .toList(),
      layouts: slides
          .map((s) => s['layout'] as String)
          .where((l) => l.isNotEmpty)
          .toList(),
    );
  }

  static bool _isUiInstructionTitle(String title) {
    final lower = title.toLowerCase();
    return lower.contains('drag_handle') ||
        lower.contains('sürükleme') ||
        lower.contains('surukleme') ||
        lower.contains('sahne kart') ||
        lower.contains('seçili sayfa') ||
        lower.contains('secili sayfa');
  }

  static List<String> _tokens(String text) {
    return RegExp(r'[a-zçğıöşü0-9]+')
        .allMatches(text.toLowerCase())
        .map((m) => m.group(0)!)
        .where((t) => t.length > 2)
        .toList();
  }

  static int _tokenOverlap(List<String> a, List<String> b) {
    final set = b.toSet();
    var count = 0;
    for (final token in a.toSet()) {
      if (set.contains(token)) {
        count++;
      }
    }
    return count;
  }
}
