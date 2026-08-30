import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/presentation_component_catalog.dart';

void main() {
  test('component definitions stay aligned with enum indices', () {
    for (final kind in PresentationComponentKind.values) {
      expect(presentationComponentDefinition(kind).kind, kind);
    }
  });

  test('component definition lookup benchmark', () {
    final kinds = PresentationComponentKind.values;
    var checksum = 0;

    for (var round = 0; round < 2; round += 1) {
      for (var index = 0; index < 100000; index += 1) {
        checksum += presentationComponentDefinition(
          kinds[(index * 37) % kinds.length],
        ).id.length;
      }
    }

    final samples = <int>[];
    for (var run = 0; run < 5; run += 1) {
      final stopwatch = Stopwatch()..start();
      for (var index = 0; index < 1000000; index += 1) {
        checksum += presentationComponentDefinition(
          kinds[(index * 37) % kinds.length],
        ).id.length;
      }
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    // Keep the looked-up values observable so the compiler cannot discard them.
    expect(checksum, greaterThan(0));
    // ignore: avoid_print
    print('component_lookup_samples_us=$samples median_us=${samples[2]}');
  });
}
