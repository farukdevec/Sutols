import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/presentation_model_source_resolver.dart';
import 'package:sutol/services/remote_model_sources.dart';

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

  test('yalnızca imzalı uzak adresler render edilebilir kabul edilir', () {
    const rawId = 'raw-render-source-test';
    const signedId = 'signed-render-source-test';
    RemoteModelSources.registerAll(const <String, String>{
      rawId: 'https://assets.sutols.com/raw.glb',
      signedId: 'https://assets.sutols.com/signed.glb?token=test',
    });

    expect(RemoteModelSources.hasSignedSource(rawId), isFalse);
    expect(RemoteModelSources.sourceFor(rawId), isNull);
    expect(RemoteModelSources.sourceForRefresh(rawId), contains('raw.glb'));
    expect(RemoteModelSources.hasSignedSource(signedId), isTrue);
    expect(RemoteModelSources.sourceFor(signedId), contains('token=test'));
  });
}
