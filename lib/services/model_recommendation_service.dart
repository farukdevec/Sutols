import 'model_matching_service.dart';
import 'model_repository.dart';
import 'presentation_keyword_catalog.dart';

String boundedRecommendationContext(Iterable<String> slideTexts) =>
    PresentationKeywordCatalog.normalize(slideTexts
        .take(20)
        .map((s) => s.length > 1000 ? s.substring(0, 1000) : s)
        .join(' '));

/// Bounded, offline suggestions using the same evidence gate as generation.
/// Selecting a suggestion remains an explicit editor action.
class ModelRecommendationIndex {
  ModelRecommendationIndex(List<ModelCatalogEntry> models)
      : _models = List.unmodifiable(models);

  final List<ModelCatalogEntry> _models;
  final Map<String, List<SimilarModelMatch>> _similarCache = {};

  /// Two concrete shared terms are required; a shared category alone is never
  /// evidence. Negative tags protect both sides of the relationship.
  List<SimilarModelMatch> similar(String seedId, {int limit = 6}) {
    if (!_similarCache.containsKey(seedId)) {
      final seeds = _models.where((m) => m.id == seedId);
      if (seeds.isEmpty) return const [];
      final seed = seeds.first;
      String context(ModelCatalogEntry m) =>
          PresentationKeywordCatalog.normalize(
              [m.name, ...m.tags.take(40), ...m.tagsEn.take(40)].join(' '));
      Set<String> terms(ModelCatalogEntry m) {
        // Display labels such as "schema/model" are not subject evidence.
        const displayWords = {
          'sema',
          'semasi',
          'model',
          'modeli',
          'modeller',
          'schematic',
          'schema',
          'diagram',
          '3d',
          '3b'
        };
        return PresentationKeywordCatalog.significantWords(context(m))
            .where((word) => !displayWords.contains(word))
            .toSet();
      }

      final seedContext = context(seed);
      final seedTerms = terms(seed);
      final candidates = <SimilarModelMatch>[];
      for (final model in _models) {
        if (model.id == seedId) continue;
        final modelContext = context(model);
        bool excluded(ModelCatalogEntry m, String text) =>
            m.excludeTags.take(40).any((tag) {
              final normalized = PresentationKeywordCatalog.normalize(tag);
              return normalized.isNotEmpty &&
                  PresentationKeywordCatalog.textMatchesKeyword(
                      text, normalized);
            });
        if (excluded(model, seedContext) || excluded(seed, modelContext))
          continue;
        final modelTerms = terms(model);
        final shared = seedTerms.intersection(modelTerms).toList()..sort();
        if (shared.length < 2) continue;
        final union = seedTerms.union(modelTerms).length;
        candidates.add(SimilarModelMatch(
            model, List.unmodifiable(shared), shared.length / union));
      }
      candidates.sort((a, b) {
        final score = b.score.compareTo(a.score);
        return score != 0 ? score : a.model.id.compareTo(b.model.id);
      });
      if (_similarCache.length >= 32)
        _similarCache.remove(_similarCache.keys.first);
      _similarCache[seedId] = List.unmodifiable(candidates.take(12));
    }
    return List.unmodifiable(_similarCache[seedId]!.take(limit.clamp(0, 12)));
  }

  String? _lastKey;
  List<ModelMatch> _lastMatches = const [];

  List<ModelMatch> recommend({
    required Iterable<String> slideTexts,
    Set<String> alreadyUsed = const {},
    int limit = 6,
  }) {
    // Titles should be supplied first. Bound input before tokenizing imported
    // long text so recommendations cannot stall typing in the editor.
    final normalized = boundedRecommendationContext(slideTexts);
    if (_lastKey != normalized) {
      // Retain word order and repetitions for multiword negative tags.
      final terms = [
        PresentationKeywordCatalog.words(normalized).take(60).join(' ')
      ];
      _lastMatches = List.unmodifiable(ModelMatchingService.rankCatalogModels(
        models: _models,
        keywords: terms,
      ).where(ModelMatchingService.isStrong3dMatch));
      _lastKey = normalized;
    }
    return List.unmodifiable(_lastMatches
        .where((m) => !alreadyUsed.contains(m.id))
        .take(limit.clamp(0, 12)));
  }
}

class SimilarModelMatch {
  const SimilarModelMatch(this.model, this.sharedTerms, this.score);
  final ModelCatalogEntry model;
  final List<String> sharedTerms;
  final double score;
}
