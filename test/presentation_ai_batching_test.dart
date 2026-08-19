import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_ai_batching.dart';

void main() {
  test('AI sunumlarını en fazla dört slaytlık sıralı gruplara böler', () {
    final ranges = PresentationAiBatching.ranges(10);

    expect(
      ranges,
      <({int start, int end})>[
        (start: 0, end: 4),
        (start: 4, end: 8),
        (start: 8, end: 10),
      ],
    );
    expect(
      ranges.every(
        (range) =>
            range.end - range.start <= PresentationAiBatching.maxSlidesPerBatch,
      ),
      isTrue,
    );
  });

  test('boş sunum için AI isteği üretmez', () {
    expect(PresentationAiBatching.ranges(0), isEmpty);
  });

  test('30 slaytı kayıp ve tekrar olmadan sekiz gruba ayırır', () {
    final ranges = PresentationAiBatching.ranges(30);
    final indexes = ranges
        .expand(
            (range) => <int>[for (var i = range.start; i < range.end; i++) i])
        .toList(growable: false);

    expect(ranges, hasLength(8));
    expect(indexes, List<int>.generate(30, (index) => index));
  });

  test(
      'parçaları en fazla iki eşzamanlı işlemle ve sırasını koruyarak çalıştırır',
      () async {
    var active = 0;
    var peakActive = 0;
    final results = await PresentationAiBatching.mapOrdered<int, int>(
      <int>[1, 2, 3, 4, 5],
      (value) async {
        active += 1;
        if (active > peakActive) peakActive = active;
        await Future<void>.delayed(
          Duration(milliseconds: value.isEven ? 5 : 15),
        );
        active -= 1;
        return value * 10;
      },
    );

    expect(peakActive, 2);
    expect(results, <int>[10, 20, 30, 40, 50]);
  });
}
