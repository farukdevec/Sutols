import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_matching_service.dart';
import 'package:sutol/services/model_repository.dart';

void main() {
  test('repeated catalogue queries retain results at 1000 entries', () {
    final models = List<ModelCatalogEntry>.generate(
        1000,
        (i) => ModelCatalogEntry(
              id: 'model-$i',
              name: 'Nesne $i',
              modelUrl: '$i.glb',
              thumbnailUrl: '',
              tags: ['nesne$i', 'mekanik', 'parca$i', 'teknik$i'],
              category: 'muhendislik',
              tier: 'free',
            ));
    List<String> query() => ModelMatchingService.rankCatalogModels(
          models: models,
          keywords: const ['nesne42', 'parca42'],
        ).map((m) => m.id).toList();
    final expected = query();
    final samples = <int>[];
    for (var i = 0; i < 15; i++) {
      final clock = Stopwatch()..start();
      final actual = query();
      clock.stop();
      samples.add(clock.elapsedMicroseconds);
      expect(actual, expected);
    }
    samples.sort();
    print('catalogue_1000_warm_query_us=$samples p95_us=${samples.last}');
  });
}
