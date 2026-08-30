import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_retention_service.dart';

void main() {
  test('benchmarks retention document ordering', () {
    final documents = List<Map<String, dynamic>>.generate(
      2000,
      (index) => <String, dynamic>{
        'name': 'presentations/$index',
        'fields': <String, dynamic>{
          'createdAt': <String, dynamic>{
            'timestampValue': DateTime.utc(2020)
                .add(Duration(minutes: index))
                .toIso8601String(),
          },
        },
      },
      growable: false,
    )..shuffle(Random(42));

    final samples = <int>[];
    var checksum = 0;
    for (var sample = 0; sample < 7; sample += 1) {
      final working = List<Map<String, dynamic>>.of(documents);
      final stopwatch = Stopwatch()..start();
      PresentationRetentionService.sortDocumentsNewestFirst(working);
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
      checksum = _checksum(working);
      expect(working.first['name'], 'presentations/1999');
      expect(working.last['name'], 'presentations/0');
    }
    samples.sort();

    // ignore: avoid_print
    print(
      'retention-sort median_us=${samples[samples.length ~/ 2]} '
      'checksum=$checksum',
    );
  });
}

int _checksum(List<Map<String, dynamic>> documents) {
  var checksum = 0;
  for (var index = 0; index < documents.length; index += 1) {
    final id = int.parse((documents[index]['name'] as String).split('/').last);
    checksum = (checksum + (index + 1) * id) & 0x7fffffff;
  }
  return checksum;
}
