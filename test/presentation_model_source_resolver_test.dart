import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/presentation_model_source_resolver.dart';

void main() {
  test('resolves only model ids used by the presentation', () {
    const catalog = <ModelCatalogEntry>[
      ModelCatalogEntry(
        id: 'used-model',
        name: 'Used',
        modelUrl: 'https://assets.sutols.com/used.glb',
        thumbnailUrl: '',
        tags: <String>[],
        category: 'science',
        tier: 'free',
      ),
      ModelCatalogEntry(
        id: 'unused-model',
        name: 'Unused',
        modelUrl: 'https://assets.sutols.com/unused.glb',
        thumbnailUrl: '',
        tags: <String>[],
        category: 'science',
        tier: 'free',
      ),
    ];

    expect(
      modelSourcesForIds(<String>{'used-model', 'missing-model'}, catalog),
      const <String, String>{
        'used-model': 'https://assets.sutols.com/used.glb',
      },
    );
  });
}
