@Timeout(Duration(minutes: 5))
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_auto_builder.dart';

void main() {
  test('benchmarks automatic component matching', () {
    const slides = <(String, String)>[
      ('Artificial intelligence', 'Neural networks and machine learning'),
      ('Climate change', 'Renewable energy and carbon emissions'),
      ('Human anatomy', 'The heart pumps blood through the circulatory system'),
      ('Space exploration', 'Planets orbit stars across the galaxy'),
      ('Financial markets', 'Investments, inflation, and economic growth'),
      ('Classical music', 'Orchestra instruments and musical composition'),
    ];

    int runBatch() {
      var checksum = 0;
      for (var repetition = 0; repetition < 2; repetition += 1) {
        for (final slide in slides) {
          checksum += bestPresentationComponentForSlide(
                title: slide.$1,
                body: slide.$2,
              )?.index ??
              -1;
        }
      }
      return checksum;
    }

    final warmupChecksum = runBatch();
    final selectedKinds = <String?>[
      for (final slide in slides)
        bestPresentationComponentForSlide(title: slide.$1, body: slide.$2)
            ?.name,
    ];
    final samples = <int>[];
    var checksum = 0;
    for (var sample = 0; sample < 5; sample += 1) {
      final stopwatch = Stopwatch()..start();
      checksum = runBatch();
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    expect(checksum, warmupChecksum);
    expect(selectedKinds, const <String?>[
      null,
      null,
      'biyoloji09',
      'astronomi01',
      null,
      'muzik13',
    ]);
    // ignore: avoid_print
    print(
        'component-match checksum=$checksum samples_us=$samples median_us=${samples[2]}');
  });
}
