import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';

import 'presentation_prompt_builder.dart';

/// Gemini'nin response_schema ile zorladığı tek slayt yapısı.
class GeminiSlide {
  final String title;
  final String content;
  final List<String> keywords;

  const GeminiSlide({
    required this.title,
    required this.content,
    required this.keywords,
  });

  factory GeminiSlide.fromJson(Map<String, dynamic> json) {
    return GeminiSlide(
      title: json['title'] as String,
      content: json['content'] as String,
      keywords: (json['keywords'] as List).cast<String>(),
    );
  }
}

/// Üst düzey yanıt yapısı: { "slides": [...] }
class GeminiPresentation {
  final List<GeminiSlide> slides;

  const GeminiPresentation({required this.slides});

  factory GeminiPresentation.fromJson(Map<String, dynamic> json) {
    return GeminiPresentation(
      slides: (json['slides'] as List)
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

  // Güncel model listesi: https://firebase.google.com/docs/ai-logic/models
  static const String modelName = 'gemini-3.6-flash';

  static Schema _slideSchema() {
    return Schema.object(
      properties: {
        'title': Schema.string(),
        'content': Schema.string(),
        'keywords': Schema.array(items: Schema.string()),
      },
    );
  }

  /// Konu metnine göre Gemini'den JSON sunum yapısı üretir.
  ///
  /// [slideCount] kadar slayt istenir; [language] ile çıktı dili belirlenir.
  /// Yanıt, response_schema ile { slides: [{title, content, keywords}] }
  /// biçimine zorlanır.
  ///
  /// İstekten önce, konuya en yakın geçmiş dışa aktarılmış sunumlar (en fazla
  /// 2) aranır; bulunursa prompt'un başına referans yapısı eklenir.
  Future<GeminiPresentation> generatePresentation(
    String topic, {
    int slideCount = 5,
    String language = 'turkish',
  }) async {
    final model = _ai.generativeModel(
      model: modelName,
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
      ),
    );

    final references = await _findSimilarExported(topic);
    final referenceBlock =
        references.isEmpty ? '' : _buildReferenceBlock(references);

    final prompt = PresentationPromptBuilder.build(
      topic: topic,
      slideCount: slideCount,
      language: language,
      referenceBlock: referenceBlock,
    );

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Gemini boş yanıt döndürdü.');
    }

    final json = jsonDecode(_stripCodeFence(text)) as Map<String, dynamic>;
    return GeminiPresentation.fromJson(json);
  }

  /// Konuyla en yakın eşleşen (basit keyword eşleşmesi) ve `wasExported ==
  /// true` olan en fazla 2 geçmiş sunumu döndürür.
  ///
  /// Ön filtre: konu kelimelerinden basit bir anahtar kelime çıkarılır,
  /// yalnızca o kelimeyi `topic` alanında içeren dokümanlar çekilir
  /// (`>=` / `<=` aralık sorgusu ile). En fazla 50 doküman incelenir
  /// (`.limit(50)`). Tam içerik (`content`) asla prompt'a eklenmez;
  /// yalnızca slayt başlıkları (`title`) ve yerleşim (`layout`) kullanılır.
  /// Hata durumunda boş liste döner (üretim bozulmaz).
  Future<List<_PastExample>> _findSimilarExported(String topic) async {
    try {
      // Basit anahtar kelime çıkar (ilk anlamlı token)
      final tokens = _tokens(topic);
      if (tokens.isEmpty) return const [];
      final keyword = tokens.first;

      // Ön filtre: keyword'i topic alanında içeren dokümanlar,
      // en fazla 50 doküman çekilir.
      final snapshot = await _db
          .collection('presentations')
          .where('topic', isGreaterThanOrEqualTo: keyword)
          .where('topic', isLessThanOrEqualTo: '$keyword\uf8ff')
          .limit(50)
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
        // İçerik (`content`) asla eklenmez; yalnızca başlık + layout.
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

  /// Referans blok metnini üretir: başlıklar (ve yerleşimler) prompt'un
  /// başına eklenir.
  static String _buildReferenceBlock(List<_PastExample> examples) {
    final parts = examples.map((e) {
      final titles = e.titles.join(', ');
      final layouts = e.layouts.toSet().where((l) => l.isNotEmpty).join(', ');
      return layouts.isEmpty ? '[$titles]' : '[$titles — yerleşim: $layouts]';
    }).join(', ');
    return '''Referans olarak, geçmişte başarılı bulunan benzer sunumların yapısı: $parts. Buna benzer kalitede ve yapıda bir sunum üret, ama konuyu birebir kopyalama, yeni ve özgün içerik oluştur.

''';
  }

  /// Bir sunum dokümanından yalnızca slayt başlıklarını (`title`) ve
  /// yerleşim türlerini (`layout`) okur. `content` alanı ASLA çekilmez
  /// veya prompt'a eklenmez; bu, bir kullanıcının özel içeriğinin
  /// başka bir kullanıcıya sızmasını engeller.
  Future<_PastExample> _exampleFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data()!;
    final embedded = data['slides'];
    List<Map<String, dynamic>> slides;
    if (embedded is List) {
      slides = embedded
          .whereType<Map<dynamic, dynamic>>()
          // `content` asla alınmaz; yalnızca başlık + layout.
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
          .where((t) => t.isNotEmpty)
          .toList(),
      layouts: slides
          .map((s) => s['layout'] as String)
          .where((l) => l.isNotEmpty)
          .toList(),
    );
  }

  /// Metni küçük harfli kelime tokene'larına böler (2 harften kısa bağlaç
  /// benzeri sözcükler elenir).
  static List<String> _tokens(String text) {
    return RegExp(r'[a-zçğıöşü0-9]+')
        .allMatches(text.toLowerCase())
        .map((m) => m.group(0)!)
        .where((t) => t.length > 2)
        .toList();
  }

  /// [a]'daki tokene'ların kaç tanesi [b]'de geçiyor (basit eşleşme skoru).
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

  static String _stripCodeFence(String text) {
    final trimmed = text.trim();
    if (trimmed.startsWith('```')) {
      final firstLineEnd = trimmed.indexOf('\n');
      return trimmed
          .substring(firstLineEnd + 1)
          .replaceFirst(RegExp(r'```\s*$'), '')
          .trim();
    }
    return trimmed;
  }
}
