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

  test('generic physics words do not select an unrelated catalyst surface', () {
    const catalyst = ModelCatalogEntry(
      id: 'katalizor-yuzeyi',
      name: 'Katalizör Yüzey Modeli',
      modelUrl: 'katalizor.glb',
      thumbnailUrl: '',
      tags: <String>['katalizör', 'yüzey', 'kimya'],
      category: 'kimya',
      tier: 'free',
    );

    final matches = ModelMatchingService.rankCatalogModels(
      models: const <ModelCatalogEntry>[catalyst],
      keywords: const <String>[
        'statik sürtünme',
        'kuvvet',
        'hareket',
        'temas yüzeyi',
      ],
    );

    expect(matches, isEmpty);
  });

  test('presentation-like GLB assets are never used as automatic 3D objects', () {
    const matrix = ModelCatalogEntry(
      id: 'etki-efor-matrisi',
      name: 'Etki Efor Matrisi',
      modelUrl: 'matrix.glb',
      thumbnailUrl: '',
      tags: <String>['etki', 'efor', 'matris', 'analiz'],
      category: 'analiz-modeli',
      tier: 'free',
    );
    const wheel = ModelCatalogEntry(
      id: 'eylemsizlik-tekerlegi',
      name: 'Eylemsizlik Tekerleği',
      modelUrl: 'wheel.glb',
      thumbnailUrl: '',
      tags: <String>['tekerlek', 'dönme', 'fizik', 'deney'],
      category: 'analiz-modeli',
      tier: 'free',
    );

    final matches = ModelMatchingService.rankCatalogModels(
      models: const <ModelCatalogEntry>[matrix, wheel],
      keywords: const <String>['etki', 'tekerlek'],
    );

    expect(matches.map((match) => match.id), <String>['eylemsizlik-tekerlegi']);
  });

  test('context-only cooling terms do not select a cooling tower', () {
    const coolingTower = ModelCatalogEntry(
      id: 'sogutma-kulesi',
      name: 'Soğutma Kulesi',
      modelUrl: 'tower.glb',
      thumbnailUrl: '',
      tags: <String>['soğutma', 'endüstri'],
      category: 'endustri',
      tier: 'free',
    );
    final matches = ModelMatchingService.rankCatalogModels(
      models: const <ModelCatalogEntry>[coolingTower],
      keywords: const <String>['soğutma', 'enerji verimliliği', 'çevre'],
    );

    expect(matches, isNotEmpty);
    expect(ModelMatchingService.isStrong3dMatch(matches.single), isFalse);
  });
}
