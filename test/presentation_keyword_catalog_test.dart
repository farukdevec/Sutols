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
}
