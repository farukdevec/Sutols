import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/presentation_component_catalog.dart';

void main() {
  test('component definitions stay aligned with enum indices', () {
    for (final kind in PresentationComponentKind.values) {
      final definition = presentationComponentDefinition(kind);
      expect(definition.kind, kind);
      final tags = definition.tags.take(4).join(', ');
      expect(
        presentationComponentSubtitle(kind),
        tags.isEmpty ? definition.description : tags,
      );
      expect(
        presentationComponentDomName(kind),
        kind.name.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => '-${match.group(1)!.toLowerCase()}',
        ),
      );
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

  test('component DOM-name lookup benchmark', () {
    final kinds = PresentationComponentKind.values;
    var checksum = 0;

    for (var round = 0; round < 2; round += 1) {
      for (var index = 0; index < 100000; index += 1) {
        checksum += presentationComponentDomName(
          kinds[(index * 37) % kinds.length],
        ).length;
      }
    }

    final samples = <int>[];
    for (var run = 0; run < 5; run += 1) {
      final stopwatch = Stopwatch()..start();
      for (var index = 0; index < 1000000; index += 1) {
        checksum += presentationComponentDomName(
          kinds[(index * 37) % kinds.length],
        ).length;
      }
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    expect(checksum, greaterThan(0));
    // ignore: avoid_print
    print('component_dom_name_samples_us=$samples median_us=${samples[2]}');
  });

  test('component subtitle lookup benchmark', () {
    final kinds = PresentationComponentKind.values;
    var checksum = 0;

    for (var round = 0; round < 2; round += 1) {
      for (var index = 0; index < 10000; index += 1) {
        checksum += presentationComponentSubtitle(
          kinds[(index * 37) % kinds.length],
        ).length;
      }
    }

    final samples = <int>[];
    for (var run = 0; run < 5; run += 1) {
      final stopwatch = Stopwatch()..start();
      for (var index = 0; index < 100000; index += 1) {
        checksum += presentationComponentSubtitle(
          kinds[(index * 37) % kinds.length],
        ).length;
      }
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    expect(checksum, greaterThan(0));
    // ignore: avoid_print
    print('component_subtitle_samples_us=$samples median_us=${samples[2]}');
  });

  test('sorted component library benchmark', () {
    var checksum = 0;
    final expectedByKind =
        <PresentationComponentKind, PresentationComponentDefinition>{
      for (final category in presentationComponentCategories())
        for (final definition
            in presentationComponentDefinitionsForCategory(category))
          definition.kind: definition,
    };
    final expected = expectedByKind.values.toList(growable: false)
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    final initial = presentationComponentDefinitionsSortedByLabel();
    expect(
        initial.map((definition) => definition.id), expected.map((d) => d.id));

    final samples = <int>[];
    for (var run = 0; run < 5; run += 1) {
      final stopwatch = Stopwatch()..start();
      for (var iteration = 0; iteration < 100; iteration += 1) {
        final definitions = presentationComponentDefinitionsSortedByLabel();
        checksum += definitions.first.id.length + definitions.last.id.length;
      }
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    expect(checksum, greaterThan(0));
    // ignore: avoid_print
    print('component_sort_samples_us=$samples median_us=${samples[2]}');
  });
}
