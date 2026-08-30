import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_export_builder.dart';

void main() {
  test('benchmarks script-safe JSON export', () {
    final notes = List<String>.filled(2000, '<tag>&value>').join();
    final pages = List<PresentationPage>.generate(
      30,
      (index) => PresentationPage(
        id: 'json-benchmark-$index',
        textBlocks: const <PresentationTextBlock>[],
        speakerNotes: '$index:$notes',
      ),
      growable: false,
    );

    String build() => buildPresentationExportHtml(
          pages: pages,
          compact: false,
        );

    for (var index = 0; index < 3; index += 1) {
      build();
    }

    final samples = <int>[];
    var checksum = 0;
    for (var index = 0; index < 15; index += 1) {
      final stopwatch = Stopwatch()..start();
      final document = build();
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
      checksum = _checksum(document);
    }
    samples.sort();

    final document = build();
    expect(document, contains(r'\u003Ctag\u003E\u0026value'));
    expect(document, isNot(contains('<tag>&value>')));
    expect(checksum, _checksum(document));
    // ignore: avoid_print
    print(
      'export-json median_us=${samples[samples.length ~/ 2]} '
      'checksum=$checksum length=${document.length}',
    );
  });
}

int _checksum(String value) {
  var hash = 0x811c9dc5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
