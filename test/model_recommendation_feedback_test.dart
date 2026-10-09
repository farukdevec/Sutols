import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_recommendation_feedback.dart';
import 'package:sutol/services/model_recommendation_service.dart';
import 'package:sutol/services/model_repository.dart';

void main() {
  test('feedback is scoped to owner, slide and bounded normalized text', () {
    final feedback = ModelRecommendationFeedback();
    ModelRecommendationScope scope(String owner, String page, String text) =>
        feedback.scope(owner: owner, pageId: page, slideTexts: [text]);
    final original = scope('one', 'p', 'ATOM ELEKTRON');
    feedback.reject(original, 'atom');
    expect(feedback.rejected(scope('one', 'p', 'atom elektron')), {'atom'});
    for (final other in [
      scope('two', 'p', 'atom elektron'),
      scope('one', 'other', 'atom elektron'),
      scope('one', 'p', 'atom proton')
    ]) {
      expect(feedback.rejected(other), isEmpty);
    }
    expect(() => feedback.rejected(original).add('x'), throwsUnsupportedError);
    feedback.restore(original, 'atom');
    expect(feedback.rejected(original), isEmpty);
  });

  test('feedback limits memory and an empty ID cannot evict a context', () {
    final feedback = ModelRecommendationFeedback();
    ModelRecommendationScope scope(int i) =>
        feedback.scope(owner: 'one', pageId: '$i', slideTexts: ['atom']);
    for (var i = 0; i < 33; i++) feedback.reject(scope(i), 'model');
    expect(feedback.rejected(scope(0)), isEmpty);
    expect(feedback.rejected(scope(32)), {'model'});
    for (var i = 0; i < 250; i++) feedback.reject(scope(32), 'm$i');
    expect(feedback.rejected(scope(32)), hasLength(200));
    feedback.reject(scope(99), '');
    expect(feedback.rejected(scope(1)), {'model'});
    feedback.restoreAll(scope(32));
    expect(feedback.rejected(scope(32)), isEmpty);
    expect(feedback.rejected(scope(2)), {'model'});
    feedback.clear();
    expect(feedback.rejected(scope(2)), isEmpty);
    expect(boundedRecommendationContext([List.filled(2000, 'a').join()]),
        hasLength(1000));
  });

  test(
      'rejecting a suggestion refills safe candidates without modifying the catalog',
      () {
    final models = [
      for (var i = 0; i < 10; i++)
        ModelCatalogEntry(
            id: 'atom-$i',
            name: 'Atom',
            modelUrl: 'models/$i.glb',
            thumbnailUrl: '',
            tags: ['atom', 'elektron', 'çekirdek'],
            category: 'Fizik',
            tier: 'free')
    ];
    models.addAll([
      for (var i = 0; i < 50; i++)
        ModelCatalogEntry(
            id: 'other-$i',
            name: 'Nesne $i',
            modelUrl: 'models/other-$i.glb',
            thumbnailUrl: '',
            tags: ['unrelated$i'],
            category: 'Diğer',
            tier: 'free')
    ]);
    final index = ModelRecommendationIndex(models);
    final feedback = ModelRecommendationFeedback();
    final scope = feedback.scope(
        owner: 'one', pageId: 'p', slideTexts: ['Atom elektron çekirdek']);
    final initial = index.recommend(slideTexts: ['Atom elektron çekirdek']);
    feedback.reject(scope, initial.first.id);
    final next = index.recommend(
        slideTexts: ['Atom elektron çekirdek'],
        alreadyUsed: feedback.rejected(scope));
    expect(next, hasLength(6));
    expect(next.map((m) => m.id), isNot(contains(initial.first.id)));
    expect(models.first.tags, ['atom', 'elektron', 'çekirdek']);
    expect(index.recommend(slideTexts: ['Atom elektron çekirdek']).first.id,
        initial.first.id);
  });
}
