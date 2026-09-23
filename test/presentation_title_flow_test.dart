import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_title.dart';

void main() {
  group('presentation title flow', () {
    test('explicit title remains separate from the generation prompt', () {
      const title = 'Yapay Zekânın Eğitimde Kullanımı';
      const prompt =
          'Yapay zekâ ile ders planlama, etik ilkeler ve ölçme hakkında ayrıntılı bir sunum hazırla.';

      final resolvedTitle = resolvePresentationTitle(
        title: '  $title  ',
        topic: prompt,
      );

      expect(resolvedTitle, title);
      expect(resolvedTitle, isNot(prompt));
    });

    test('blank title derives a compact deterministic title from the prompt',
        () {
      final prompt = List<String>.filled(30, 'ayrıntı').join('   ');

      final resolvedTitle = resolvePresentationTitle(
        title: ' \n ',
        topic: prompt,
      );

      expect(resolvedTitle.length, presentationFallbackTitleMaxLength);
      expect(resolvedTitle, endsWith('…'));
      expect(resolvedTitle, isNot(contains('  ')));
    });

    test('short prompt is the complete fallback title', () {
      expect(
        resolvePresentationTitle(
          title: '',
          topic: '  Kısa\n sunum konusu  ',
        ),
        'Kısa sunum konusu',
      );
    });
  });
}
