import 'package:firebase_auth/firebase_auth.dart';

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
  Future<List<ModelMatch>> matchModelsForSlide(List<String> keywords) async {
    if (keywords.isEmpty) return [];
    if (FirebaseAuth.instance.currentUser == null) return [];

    final limitedKeywords = keywords
        .take(10)
        .map(PresentationKeywordCatalog.normalize)
        .where((keyword) => keyword.isNotEmpty)
        .toList(growable: false);

    final models = await ModelRepository.instance.getModels();

    final matches = models
        .map((model) {
          final score = keywordMatchScore(
            keywords: limitedKeywords,
            tags: model.tags,
            modelName: model.name,
          );

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
