import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  test('benchmarks Jaccard similarity without changing its result', () {
    final left = <String>{
      for (var index = 0; index < 200; index += 1) 'word-$index',
    };
    final right = <String>{
      for (var index = 100; index < 300; index += 1) 'word-$index',
    };

    expect(
      PresentationContentQuality.jaccardSimilarity(left, right),
      closeTo(1 / 3, 1e-12),
    );
    expect(
      PresentationContentQuality.jaccardSimilarity(<String>{}, <String>{}),
      1,
    );
    expect(
      PresentationContentQuality.jaccardSimilarity(left, <String>{}),
      0,
    );

    for (var index = 0; index < 1000; index += 1) {
      PresentationContentQuality.jaccardSimilarity(left, right);
    }

    final samples = <int>[];
    var checksum = 0.0;
    for (var sample = 0; sample < 7; sample += 1) {
      final stopwatch = Stopwatch()..start();
      var total = 0.0;
      for (var index = 0; index < 50000; index += 1) {
        total += PresentationContentQuality.jaccardSimilarity(left, right);
      }
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
      checksum = total;
    }
    samples.sort();

    expect(checksum, closeTo(50000 / 3, 1e-6));
    // ignore: avoid_print
    print(
      'jaccard median_us=${samples[samples.length ~/ 2]} '
      'checksum=${checksum.toStringAsFixed(6)}',
    );
  });
}
