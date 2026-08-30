import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_keyword_catalog.dart';

void main() {
  test('does not match short tags inside unrelated words', () {
    const unrelatedPairs = <(String, String)>[
      ('kultur', 'tur'),
      ('telefon', 'fon'),
      ('terapi', 'api'),
      ('karakter', 'kar'),
      ('sentez', 'tez'),
      ('genel', 'gen'),
      ('hakkinda', 'hak'),
      ('notron', 'not'),
    ];

    for (final pair in unrelatedPairs) {
      expect(
        PresentationKeywordCatalog.wordsMatch(pair.$1, pair.$2),
        isFalse,
        reason: '${pair.$1} must not trigger ${pair.$2}',
      );
    }
  });

  test('keeps safe inflection and typo matching', () {
    expect(
        PresentationKeywordCatalog.wordsMatch('ekolojisi', 'ekoloji'), isTrue);
    expect(PresentationKeywordCatalog.wordsMatch('fotn', 'foton'), isTrue);
    expect(
        PresentationKeywordCatalog.wordsMatch('gezegenler', 'gezegen'), isTrue);
  });

  test('does not treat a shared word beginning as an inflection', () {
    expect(PresentationKeywordCatalog.wordsMatch('antik', 'antijen'), isFalse);
    expect(PresentationKeywordCatalog.wordsMatch('antik', 'antikor'), isFalse);
  });

  test('matches phrases by complete words instead of raw substrings', () {
    final text = PresentationKeywordCatalog.normalize(
      'Güneş panelleri yenilenebilir enerji üretir.',
    );

    expect(
      PresentationKeywordCatalog.textMatchesKeyword(
        text,
        PresentationKeywordCatalog.normalize('güneş paneli'),
      ),
      isTrue,
    );
    expect(
      PresentationKeywordCatalog.textMatchesKeyword(
        PresentationKeywordCatalog.normalize('Sunum hakkında bilgiler'),
        PresentationKeywordCatalog.normalize('hak'),
      ),
      isFalse,
    );
  });

  test('word tokenizer benchmark', () {
    const inputs = <String>[
      'artificial intelligence and machine learning',
      'space-exploration: planets, stars, galaxy 2026',
      'renewable_energy + carbon/emissions',
      'human anatomy; heart & circulatory system',
      '123 alpha42 beta-7 gamma',
      '...leading and trailing...',
    ];
    const expected = <List<String>>[
      <String>['artificial', 'intelligence', 'and', 'machine', 'learning'],
      <String>['space', 'exploration', 'planets', 'stars', 'galaxy', '2026'],
      <String>['renewable', 'energy', 'carbon', 'emissions'],
      <String>['human', 'anatomy', 'heart', 'circulatory', 'system'],
      <String>['123', 'alpha42', 'beta', '7', 'gamma'],
      <String>['leading', 'and', 'trailing'],
    ];
    for (var index = 0; index < inputs.length; index += 1) {
      expect(PresentationKeywordCatalog.words(inputs[index]), expected[index]);
    }

    int runBatch() {
      var checksum = 0;
      for (var iteration = 0; iteration < 10000; iteration += 1) {
        for (final input in inputs) {
          final words = PresentationKeywordCatalog.words(input);
          checksum += words.length + words.first.length + words.last.length;
        }
      }
      return checksum;
    }

    final expectedChecksum = runBatch();
    final samples = <int>[];
    var checksum = 0;
    for (var run = 0; run < 5; run += 1) {
      final stopwatch = Stopwatch()..start();
      checksum = runBatch();
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    expect(checksum, expectedChecksum);
    // ignore: avoid_print
    print('keyword_words_checksum=$checksum samples_us=$samples median_us=${samples[2]}');
  });
}
