import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_repository.dart';

void main() {
  test('model katalog girdisi kalıcı önbellekte kayıpsız saklanır', () {
    const original = ModelCatalogEntry(
      id: 'earth',
      name: 'Dünya',
      modelUrl: 'https://assets.sutols.com/earth.glb',
      thumbnailUrl: 'https://assets.sutols.com/thumbnails/earth.webp',
      tags: <String>['dünya', 'gezegen'],
      tagsEn: <String>['earth', 'planet'],
      category: 'Uzay',
      tier: 'plus',
      excludeTags: <String>['yemek'],
    );

    final restored = ModelCatalogEntry.fromCacheJson(original.toCacheJson());

    expect(restored, isNotNull);
    expect(restored!.id, original.id);
    expect(restored.name, original.name);
    expect(restored.modelUrl, original.modelUrl);
    expect(restored.thumbnailUrl, original.thumbnailUrl);
    expect(restored.tags, original.tags);
    expect(restored.tagsEn, original.tagsEn);
    expect(restored.category, original.category);
    expect(restored.tier, original.tier);
    expect(restored.excludeTags, original.excludeTags);
  });

  test('geçersiz katalog girdisi önbellekten yüklenmez', () {
    expect(ModelCatalogEntry.fromCacheJson(<String, dynamic>{}), isNull);
  });
}
