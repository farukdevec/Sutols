import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/model_search_service.dart';

void main() {
  const plane = ModelCatalogEntry(
      id: 'plane',
      name: 'Yolcu Uçağı',
      modelUrl: 'plane.glb',
      thumbnailUrl: '',
      tags: ['uçak', 'havacılık'],
      tagsEn: ['airplane', 'aircraft'],
      category: 'Ulaşım',
      tier: 'free');
  const earth = ModelCatalogEntry(
      id: 'earth',
      name: 'Gerçekçi Dünya',
      modelUrl: 'earth.glb',
      thumbnailUrl: '',
      tags: ['gezegen', 'dünya'],
      tagsEn: ['earth', 'planet'],
      category: 'Uzay',
      tier: 'free');
  test('finds Turkish names, partial terms and English tags', () {
    final index = ModelSearchIndex(const [plane, earth]);
    for (final query in ['UÇAK', 'havac', 'aircraft', 'yolcu uçakları']) {
      expect(index.search(query).map((m) => m.id), ['plane']);
    }
    expect(index.search('planet').single.id, 'earth');
    expect(index.search('kahve'), isEmpty);
  });
  test(
      'manual discovery tolerates one typo in long terms without loosening short words',
      () {
    const microscope = ModelCatalogEntry(
        id: 'scope',
        name: 'Mikroskop',
        modelUrl: 'scope.glb',
        thumbnailUrl: '',
        tags: ['laboratuvar'],
        category: 'Bilim',
        tier: 'free');
    final index = ModelSearchIndex(const [microscope]);
    for (final query in ['mikroskp', 'mikroskpo', 'mikroskopp', 'mikrozkop']) {
      expect(index.search(query).map((m) => m.id), ['scope'], reason: query);
    }
    expect(index.search('makrozkap'), isEmpty);
    expect(ModelSearchIndex(const [earth]).search('eart'),
        isNotEmpty); // explicit prefix
    expect(ModelSearchIndex(const [earth]).search('erth'),
        isEmpty); // short fuzzy token rejected
  });
  test('category and every query term must agree; cached result is immutable',
      () {
    final index = ModelSearchIndex(const [plane, earth]);
    expect(index.search('uçak', category: 'Uzay'), isEmpty);
    expect(index.search('yolcu gezegen'), isEmpty);
    final a = index.search('earth');
    expect(identical(a, index.search('EARTH')), isTrue);
    expect(() => a.clear(), throwsUnsupportedError);
    expect(index.search('').length, 2);
  });
}
