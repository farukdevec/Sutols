import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_matching_service.dart';
import 'package:sutol/services/model_repository.dart';

void main() {
  test('aynı model kimliği arama indeksine yalnızca bir kez eklenir', () {
    const repositoryEntry = ModelCatalogEntry(
      id: 'gercekci-dunya',
      name: 'Gerçekçi Dünya Atlası',
      modelUrl: '/models/gercekci_dunya.glb',
      thumbnailUrl: '/model_thumbnails/gercekci_dunya.webp',
      tags: <String>['dünya', 'gezegen', 'küre', 'atlas', 'earth'],
      category: 'Coğrafya ve Uzay',
      tier: 'free',
    );
    const localDuplicate = ModelCatalogEntry(
      id: 'gercekci-dunya',
      name: 'Gerçekçi Dünya Atlası',
      modelUrl: 'assets/models/gercekci_dunya.glb',
      thumbnailUrl: '',
      tags: <String>['dünya', 'gezegen', 'küre', 'atlas', 'earth'],
      category: 'Coğrafya ve Uzay',
      tier: 'free',
    );

    final matches = ModelMatchingService.rankCatalogModels(
      models: const <ModelCatalogEntry>[repositoryEntry, localDuplicate],
      keywords: const <String>['dünya', 'gezegen', 'küre', 'atlas', 'earth'],
    );

    expect(matches, hasLength(1));
    expect(matches.single.id, 'gercekci-dunya');
    expect(matches.single.modelUrl, repositoryEntry.modelUrl);
    expect(matches.single.thumbnailUrl, repositoryEntry.thumbnailUrl);
  });

  test('antik silah slaytı antijen modelini eşleştirmez', () {
    const antibody = ModelCatalogEntry(
      id: 'antikor-antijen',
      name: 'Antikor Antijen Modeli',
      modelUrl: 'antikor.glb',
      thumbnailUrl: '',
      tags: <String>['antikor', 'antijen', 'bağışıklık', 'biyoloji'],
      category: 'anatomi-ve-tip',
      tier: 'free',
    );

    final matches = ModelMatchingService.rankCatalogModels(
      models: const <ModelCatalogEntry>[antibody],
      keywords: const <String>[
        'Antik Menzilli Silahlar',
        'Antik dönemde ok ve fling',
        'uzun menzil ve delme gücü',
      ],
    );

    expect(matches, isEmpty);
  });
}
