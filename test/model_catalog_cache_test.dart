import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/presentation_3d_model_catalog.dart';
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

  test('küçük resmi olmayan paket modelleri de katalogda görünür', () {
    const staleCloudModel = ModelCatalogEntry(
      id: 'yolcu-ucagi',
      name: 'Eski uçak',
      modelUrl: 'https://assets.sutols.com/old-plane.glb',
      thumbnailUrl: 'https://assets.sutols.com/thumbnails/old-plane.webp',
      tags: <String>[],
      category: 'Eski',
      tier: 'premium',
    );

    final catalog = ModelRepository.mergeWithBundledModels(
      const <ModelCatalogEntry>[staleCloudModel],
    );
    final ids = catalog.map((model) => model.id).toSet();

    expect(
      ids,
      containsAll(
        presentation3DModelCatalog.map((model) => model.id),
      ),
    );
    final plane = catalog.singleWhere((model) => model.id == 'yolcu-ucagi');
    final earth = catalog.singleWhere((model) => model.id == 'gercekci-dunya');
    final anitkabir = catalog.singleWhere((model) => model.id == 'anitkabir');
    expect(plane.modelUrl, 'https://assets.sutols.com/old-plane.glb');
    expect(plane.thumbnailUrl, isEmpty);
    expect(plane.tier, 'premium');
    expect(anitkabir.modelUrl, '/models/anitkabir.glb');
    expect(earth.thumbnailUrl, isEmpty);
  });
}
