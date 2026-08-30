import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/safe_json_parser.dart';

void main() {
  test('validated presentation JSON try-parse benchmark', () {
    final raw = jsonEncode(<String, Object>{
      'slides': List<Map<String, Object>>.generate(
        30,
        (index) => <String, Object>{
          'title': '**Slayt $index**',
          'content': '- **Birinci:** madde $index\n- İkinci madde $index',
          'keywords': <String>['konu', 'slayt', '$index'],
        },
      ),
    });
    var checksum = 0;
    final direct = SafeJsonParser.parsePresentationPayload(raw);
    final validated = SafeJsonParser.tryParsePresentationPayload(raw)!;
    expect(validated, direct);
    expect((validated['slides'] as List).first['title'], 'Slayt 0');

    for (var index = 0; index < 10; index += 1) {
      checksum +=
          (SafeJsonParser.tryParsePresentationPayload(raw)!['slides'] as List)
              .length;
    }

    final samples = <int>[];
    for (var run = 0; run < 7; run += 1) {
      final stopwatch = Stopwatch()..start();
      for (var iteration = 0; iteration < 100; iteration += 1) {
        checksum +=
            (SafeJsonParser.tryParsePresentationPayload(raw)!['slides'] as List)
                .length;
      }
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    expect(checksum, 30 * 710);
    // ignore: avoid_print
    print('safe_json_try_parse_samples_us=$samples median_us=${samples[3]}');
  });
}
