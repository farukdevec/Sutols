import 'package:firebase_auth/firebase_auth.dart';

import '../models/presentation_3d_model_catalog.dart';
import 'model_repository.dart';
import 'presentation_keyword_catalog.dart';

class ModelMatch {
  final String id;
  final String name;
  final String modelUrl;
  final String thumbnailUrl;
  final int score;

  ModelMatch({
    required this.id,
    required this.name,
    required this.modelUrl,
    required this.thumbnailUrl,
    required this.score,
  });
}

class ModelMatchingService {
  static List<ModelCatalogEntry>? _indexedSource;
  static List<_IndexedModel> _indexedModels = const <_IndexedModel>[];

  /// Katalogdaki kelimelerin doküman-frekansı (kaç farklı modelde geçiyor).
  /// IDF ağırlıklandırma için kullanılır: yaygın kelimeler (ör. "gelişim"
  /// birçok modelde geçebilir) düşük ağırlık alır, nadir/spesifik kelimeler
  /// (ör. "kahve", "embriyo") yüksek ağırlık alır.
  static Map<String, int> _wordDocFrequency = const <String, int>{};
  static int _totalIndexedModels = 0;

  /// Bir modelin "güvenilir eşleşme" sayılması için gereken minimum ağırlıklı
  /// skor. Bunun altındaki skorlar aday listesinden tamamen elenir; böylece
  /// çağıran taraf (PresentationService) rastgele/alakasız bir model
  /// atamak yerine 2D bileşen düzenine (fallback) düşebilir.
  static const double _minConfidentWeightedScore = 2.0;

  static List<ModelCatalogEntry> get localCatalogEntries =>
      presentation3DModelCatalog
          .map(
            (m) => ModelCatalogEntry(
              id: m.id,
              name: m.label,
              modelUrl: m.assetPath,
              thumbnailUrl: '',
              tags: m.tags,
              category: m.category,
              tier: 'free',
            ),
          )
          .toList(growable: false);

  Future<List<ModelMatch>> matchModelsForSlide(List<String> keywords) async {
    if (keywords.isEmpty) return const <ModelMatch>[];
    final results = await matchModelsForSlides(<List<String>>[keywords]);
    return results.single;
  }

  /// Bir sunumdaki bütün slaytları aynı katalog ve aynı normalize edilmiş
  /// arama indeksi üzerinden eşleştirir. Böylece model kataloğu her slaytta
  /// yeniden gezilip etiketler tekrar tekrar normalize edilmez.
  Future<List<List<ModelMatch>>> matchModelsForSlides(
    List<List<String>> keywordsBySlide,
  ) async {
    if (keywordsBySlide.isEmpty) return const <List<ModelMatch>>[];
    if (keywordsBySlide.every((keywords) => keywords.isEmpty)) {
      return List<List<ModelMatch>>.generate(
        keywordsBySlide.length,
        (_) => const <ModelMatch>[],
        growable: false,
      );
    }

    List<ModelCatalogEntry> onlineModels = const <ModelCatalogEntry>[];
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        onlineModels = await ModelRepository.instance.getModels();
      } catch (_) {}
    }

    final allModels = <ModelCatalogEntry>[
      ...onlineModels,
      ...localCatalogEntries,
    ];
    final indexedModels = _indexFor(allModels);
    return keywordsBySlide
        .map((keywords) => _matchIndexed(indexedModels, keywords))
        .toList(growable: false);
  }

  List<_IndexedModel> _indexFor(List<ModelCatalogEntry> models) {
    if (identical(_indexedSource, models)) return _indexedModels;
    _indexedSource = models;
    _indexedModels = _buildIndex(models);
    return _indexedModels;
  }

  /// Katalogdan indeks oluşturur ve aynı anda IDF hesaplaması için gereken
  /// kelime doküman-frekansı tablosunu günceller. `matchModelsForSlides` ve
  /// `rankCatalogModels` (konu bazlı Aşama 2 araması) aynı istatistikleri
  /// kullansın diye ortak metot burada toplandı.
  static List<_IndexedModel> _buildIndex(List<ModelCatalogEntry> models) {
    final indexed = models
        .map(
          (model) => _IndexedModel(
            model: model,
            normalizedName: PresentationKeywordCatalog.normalize(model.name),
            normalizedTags: <String>[...model.tags, ...model.tagsEn]
                .map(PresentationKeywordCatalog.normalize)
                .where((tag) => tag.isNotEmpty)
                .toList(growable: false),
            normalizedExcludeTags: model.excludeTags
                .map(PresentationKeywordCatalog.normalize)
                .where((tag) => tag.isNotEmpty)
                .toSet(),
          ),
        )
        .toList(growable: false);

    final freq = <String, int>{};
    for (final m in indexed) {
      final wordsInModel = <String>{
        ...PresentationKeywordCatalog.words(m.normalizedName),
        for (final tag in m.normalizedTags)
          ...PresentationKeywordCatalog.words(tag),
      };
      for (final w in wordsInModel) {
        freq[w] = (freq[w] ?? 0) + 1;
      }
    }
    _wordDocFrequency = freq;
    _totalIndexedModels = indexed.length;
    return indexed;
  }

  /// Bir kelimenin ayırt edicilik ağırlığı (0.2 - 1.0 arası). Katalogdaki
  /// çoğu modelde geçen kelimeler düşük ağırlık, sadece birkaç modele özgü
  /// kelimeler yüksek ağırlık alır.
  static double _specificityWeight(String normalizedWord) {
    final total = _totalIndexedModels == 0 ? 1 : _totalIndexedModels;
    final df = _wordDocFrequency[normalizedWord] ?? 1;
    final commonness = df / total; // 0..1
    final weight = 1.0 - (commonness * 0.8);
    return weight.clamp(0.2, 1.0);
  }

  static List<ModelMatch> _matchIndexed(
    List<_IndexedModel> models,
    List<String> keywords,
  ) {
    if (keywords.isEmpty) return const <ModelMatch>[];

    // 1) Normalize et, kelimelere böl, JENERİK/DOLGU kelimeleri ele.
    //    Bu adım olmadan "gelişim", "tarih", "farklı" gibi kelimeler
    //    tamamen alakasız modelleri (ör. "Embriyo Gelişimi") tetikleyebiliyordu.
    final limitedKeywords = keywords
        .take(30)
        .map(PresentationKeywordCatalog.normalize)
        .where((keyword) => keyword.isNotEmpty)
        .expand(PresentationKeywordCatalog.words)
        .where((word) => !PresentationKeywordCatalog.isGenericWord(word))
        .toSet()
        .toList(growable: false);

    if (limitedKeywords.isEmpty) return const <ModelMatch>[];

    final matches = <ModelMatch>[];
    for (final indexed in models) {
      // excludeTags: model açıkça bu kelimelerden birini dışlıyorsa (yanlış
      // domain koruması), skorlamaya hiç girmeden ele.
      if (indexed.normalizedExcludeTags.isNotEmpty &&
          limitedKeywords.any(indexed.normalizedExcludeTags.contains)) {
        continue;
      }

      // 2) Her etiket/isim eşleşmesi, eşleşen kelimenin IDF ağırlığıyla
      //    çarpılır. Yaygın kelimeler düşük katkı, nadir/spesifik kelimeler
      //    yüksek katkı sağlar.
      var weighted = 0.0;
      for (final tag in indexed.normalizedTags) {
        final w = _bestMatchWeight(limitedKeywords, tag);
        if (w > 0) weighted += 2 * w;
      }
      final nameWeight = _bestMatchWeight(limitedKeywords, indexed.normalizedName);
      if (nameWeight > 0) weighted += 1 * nameWeight;

      if (weighted <= 0) continue;

      final model = indexed.model;
      matches.add(ModelMatch(
        id: model.id,
        name: model.name,
        modelUrl: model.modelUrl,
        thumbnailUrl: model.thumbnailUrl,
        // Ondalıklı ağırlığı okunabilir bir tamsayı skoruna çevir (×10).
        score: (weighted * 10).round(),
      ));
    }

    // 3) Minimum güven eşiği: yalnızca gerçekten güçlü eşleşmeler döner.
    //    Zayıf/şüpheli eşleşmeler burada elenir ki çağıran taraf rastgele
    //    bir modele zorlanmak yerine 2D bileşen düzenine düşebilsin.
    final confident = matches
        .where((m) => m.score >= (_minConfidentWeightedScore * 10).round())
        .toList();
    confident.sort((a, b) => b.score.compareTo(a.score));
    return confident;
  }

  /// [candidateText] (bir etiket ya da model ismi) içindeki kelimelerden,
  /// [keywordWords] listesindeki herhangi biriyle eşleşen en yüksek IDF
  /// ağırlığını döner. Eşleşme yoksa 0.
  static double _bestMatchWeight(
    List<String> keywordWords,
    String candidateText,
  ) {
    if (candidateText.isEmpty) return 0;
    var best = 0.0;
    for (final candidateWord in PresentationKeywordCatalog.words(candidateText)) {
      for (final keywordWord in keywordWords) {
        if (PresentationKeywordCatalog.wordsMatch(keywordWord, candidateWord) ||
            PresentationKeywordCatalog.wordsMatch(candidateWord, keywordWord)) {
          final w = _specificityWeight(candidateWord);
          if (w > best) best = w;
        }
      }
    }
    return best;
  }

  /// Verilen katalog üzerinde çalışan saf eşleştirme girişi. Üretimdeki
  /// sıralama ile testlerin kullandığı sıralamanın ayrışmasını önler.
  static List<ModelMatch> rankCatalogModels({
    required List<ModelCatalogEntry> models,
    required List<String> keywords,
  }) {
    // Aynı IDF/özgüllük istatistiklerini kullanmak için slayt bazlı
    // eşleştirmedeki (_indexFor) ile aynı _buildIndex yolunu kullanır.
    final indexedModels = _buildIndex(models);
    return _matchIndexed(indexedModels, keywords);
  }

  /// Bir destede aynı modelin gereksiz tekrarlanmasını azaltırken model
  /// önceliğini korur. İlgili kullanılmamış seçenek yoksa en güçlü eşleşme
  /// döner; hiç eşleşme yoksa bileşen aşamasına geçilmesi için null döner.
  static ModelMatch? bestMatchPreferUnused(
    List<ModelMatch> matches,
    Set<String> usedModelIds,
  ) {
    if (matches.isEmpty) return null;
    for (final match in matches) {
      if (!usedModelIds.contains(match.id)) return match;
    }
    return matches.first;
  }

  /// Pure matcher used by the runtime and tests. Tags carry more weight than
  /// the display name; Turkish characters, casing and close word forms are
  /// normalized by the shared presentation keyword catalog.
  static int keywordMatchScore({
    required List<String> keywords,
    required List<String> tags,
    String modelName = '',
  }) {
    final normalizedKeywords = keywords
        .map(PresentationKeywordCatalog.normalize)
        .where((keyword) => keyword.isNotEmpty)
        .expand(PresentationKeywordCatalog.words)
        .where((word) => !PresentationKeywordCatalog.isGenericWord(word))
        .toSet()
        .toList(growable: false);
    if (normalizedKeywords.isEmpty) return 0;

    var score = 0;
    for (final tag in tags) {
      final normalizedTag = PresentationKeywordCatalog.normalize(tag);
      if (_anyKeywordMatches(normalizedKeywords, normalizedTag)) {
        score += 2;
      }
    }

    final normalizedName = PresentationKeywordCatalog.normalize(modelName);
    if (_anyKeywordMatches(normalizedKeywords, normalizedName)) {
      score += 1;
    }
    return score;
  }

  static bool _anyKeywordMatches(
    List<String> normalizedKeywords,
    String normalizedCandidate,
  ) {
    if (normalizedCandidate.isEmpty) return false;
    return normalizedKeywords.any(
      (keyword) =>
          PresentationKeywordCatalog.textMatchesKeyword(
            keyword,
            normalizedCandidate,
          ) ||
          PresentationKeywordCatalog.textMatchesKeyword(
            normalizedCandidate,
            keyword,
          ),
    );
  }
}

class _IndexedModel {
  const _IndexedModel({
    required this.model,
    required this.normalizedName,
    required this.normalizedTags,
    this.normalizedExcludeTags = const <String>{},
  });

  final ModelCatalogEntry model;
  final String normalizedName;
  final List<String> normalizedTags;
  final Set<String> normalizedExcludeTags;
}
