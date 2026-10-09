import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/model_recommendation_service.dart';

void main() {
  ModelCatalogEntry model(String id, String name, List<String> tags,
          {List<String> excludes = const []}) =>
      ModelCatalogEntry(
          id: id,
          name: name,
          modelUrl: 'models/$id.glb',
          thumbnailUrl: '',
          tags: tags,
          excludeTags: excludes,
          category: 'Fizik',
          tier: 'free');

  test('suggestions show evidence, respect exclusions and omit used models',
      () {
    final index = ModelRecommendationIndex([
      model('atom', 'Atom', ['atom', 'elektron', 'çekirdek']),
      model('coffee', 'Kahve', ['kahve', 'fincan']),
      model('excluded', 'Atom', ['atom', 'elektron'], excludes: ['kahve']),
    ]);
    final matches =
        index.recommend(slideTexts: ['Atom elektron çekirdek kahve']);
    expect(matches.map((m) => m.id), isNot(contains('excluded')));
    expect(matches.first.id, 'atom');
    expect(matches.first.matchedTerms, contains('elektron'));
    expect(
        index.recommend(
            slideTexts: ['Atom elektron çekirdek kahve'],
            alreadyUsed: {'atom'}).map((m) => m.id),
        isNot(contains('atom')));
  });

  test('generic headings and an unrelated slide produce no suggestions', () {
    final index = ModelRecommendationIndex([
      model('atom', 'Atom', ['atom', 'elektron', 'çekirdek']),
    ]);
    expect(index.recommend(slideTexts: ['Faydalar ve riskler']), isEmpty);
    expect(index.recommend(slideTexts: ['Şiir ve edebiyat']), isEmpty);
    expect(index.recommend(slideTexts: []), isEmpty);
  });

  test('edited text invalidates cached results and results are bounded', () {
    final index = ModelRecommendationIndex([
      for (var i = 0; i < 20; i++)
        model('atom-$i', 'Atom', ['atom', 'elektron', 'çekirdek']),
      for (var i = 0; i < 100; i++)
        model('unrelated-$i', 'Nesne $i', ['unrelated$i']),
    ]);
    expect(
        index.recommend(slideTexts: ['Atom elektron çekirdek']), hasLength(6));
    expect(index.recommend(slideTexts: ['Atom elektron çekirdek'], limit: 100),
        hasLength(12));
    expect(index.recommend(slideTexts: ['Atom elektron çekirdek'], limit: -1),
        isEmpty);
    expect(index.recommend(slideTexts: ['Sanat ve şiir']), isEmpty);
  });
  test('similar discovery requires evidence and protects both negative domains',
      () {
    final index = ModelRecommendationIndex([
      model('seed', 'Atom', ['atom', 'elektron', 'çekirdek']),
      model('similar', 'Elektron', ['atom', 'elektron']),
      model('category-only', 'Kaldıraç', ['kuvvet', 'denge']),
      model('one-tag', 'Atom', ['atom']),
      model('excluded', 'Atom elektron', ['atom', 'elektron'],
          excludes: ['çekirdek']),
    ]);
    final matches = index.similar('seed');
    expect(matches.map((m) => m.model.id), ['similar']);
    expect(matches.single.sharedTerms, ['atom', 'elektron']);
    expect(index.similar('missing'), isEmpty);
    expect(index.similar('seed', limit: -1), isEmpty);
    expect(() => matches.clear(), throwsUnsupportedError);
  });

  test('similar discovery has stable ties and seed exclusions apply in reverse',
      () {
    final index = ModelRecommendationIndex([
      model('seed', 'Atom', ['atom', 'elektron'], excludes: ['kahve']),
      model('b', 'Atom elektron', ['atom', 'elektron']),
      model('a', 'Atom elektron', ['atom', 'elektron']),
      model('coffee', 'Atom elektron kahve', ['atom', 'elektron', 'kahve']),
    ]);
    expect(index.similar('seed').map((m) => m.model.id), ['a', 'b']);
    expect(index.similar('seed', limit: 1).single.model.id, 'a');
  });
  test('schema and model labels cannot inflate similarity evidence', () {
    final index = ModelRecommendationIndex([
      model('seed', 'Atom Şeması', ['atom']),
      model('other', 'Atom Şeması', ['atom']),
    ]);
    expect(index.similar('seed'), isEmpty);
  });
}
