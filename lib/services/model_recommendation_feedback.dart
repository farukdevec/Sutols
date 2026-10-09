import 'dart:collection';
import 'model_recommendation_service.dart';

typedef ModelRecommendationScope = ({
  String owner,
  String pageId,
  String context
});

/// Session-only feedback. It never changes catalog tags, generated slides,
/// saved projects or automatic selection. Context is the same bounded text
/// already used by the recommendation index; it is not written to storage/logs.
class ModelRecommendationFeedback {
  final _rejected = LinkedHashMap<ModelRecommendationScope, Set<String>>();
  static const maxContexts = 32;
  static const maxModelsPerContext = 200;

  ModelRecommendationScope scope(
          {required String owner,
          required String pageId,
          required Iterable<String> slideTexts}) =>
      (
        owner: owner,
        pageId: pageId,
        context: boundedRecommendationContext(slideTexts)
      );

  Set<String> rejected(ModelRecommendationScope scope) =>
      Set.unmodifiable(_rejected[scope] ?? const <String>{});

  void reject(ModelRecommendationScope scope, String modelId) {
    if (modelId.isEmpty) return;
    final ids = _rejected.remove(scope) ?? <String>{};
    if (ids.length < maxModelsPerContext) ids.add(modelId);
    _rejected[scope] = ids;
    while (_rejected.length > maxContexts)
      _rejected.remove(_rejected.keys.first);
  }

  void restore(ModelRecommendationScope scope, String modelId) {
    final ids = _rejected[scope];
    ids?.remove(modelId);
    if (ids != null && ids.isEmpty) _rejected.remove(scope);
  }

  void restoreAll(ModelRecommendationScope scope) => _rejected.remove(scope);

  void clear() => _rejected.clear();
}
