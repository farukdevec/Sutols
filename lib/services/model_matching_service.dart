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
    _indexedModels = models
        .map(
          (model) => _IndexedModel(
            model: model,
            normalizedName: PresentationKeywordCatalog.normalize(model.name),
            normalizedTags: <String>[...model.tags, ...model.tagsEn]
                .map(PresentationKeywordCatalog.normalize)
                .where((tag) => tag.isNotEmpty)
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
    return _indexedModels;
  }

  static List<ModelMatch> _matchIndexed(
    List<_IndexedModel> models,
    List<String> keywords,
  ) {
    if (keywords.isEmpty) return const <ModelMatch>[];

    final limitedKeywords = keywords
        .take(10)
        .map(PresentationKeywordCatalog.normalize)
        .where((keyword) => keyword.isNotEmpty)
        .toList(growable: false);

    final matches = models
        .map((indexed) {
          var score = 0;
          for (final tag in indexed.normalizedTags) {
            if (_anyKeywordMatches(limitedKeywords, tag)) score += 2;
          }
          if (_anyKeywordMatches(limitedKeywords, indexed.normalizedName)) {
            score += 1;
          }
          final model = indexed.model;

          return ModelMatch(
            id: model.id,
            name: model.name,
            modelUrl: model.modelUrl,
            thumbnailUrl: model.thumbnailUrl,
            score: score,
          );
        })
        .where((m) => m.score > 0)
        .toList();

    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }

  /// Verilen katalog üzerinde çalışan saf eşleştirme girişi. Üretimdeki
  /// sıralama ile testlerin kullandığı sıralamanın ayrışmasını önler.
  static List<ModelMatch> rankCatalogModels({
    required List<ModelCatalogEntry> models,
    required List<String> keywords,
  }) {
    final indexedModels = models
        .map(
          (model) => _IndexedModel(
            model: model,
            normalizedName: PresentationKeywordCatalog.normalize(model.name),
            normalizedTags: model.tags
                .map(PresentationKeywordCatalog.normalize)
                .where((tag) => tag.isNotEmpty)
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
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
  });

  final ModelCatalogEntry model;
  final String normalizedName;
  final List<String> normalizedTags;
}
