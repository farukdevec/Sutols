import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_content_quality.dart';
import 'package:sutol/services/presentation_prompt_builder.dart';
import 'package:sutol/services/gemini_presentation_service.dart';
import 'package:sutol/services/grok_presentation_service.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/safe_json_parser.dart';

void main() {
  test('normalization preserves emphasis and is idempotent through parsing',
      () {
    const raw = '- **Öğretmen Denetimi:** Öğretmen önerileri kontrol eder.\n'
        '2. Uyarlama: Alıştırmalar öğrencinin hızına göre değişir.';
    const expected =
        '• **Öğretmen Denetimi:** Öğretmen önerileri kontrol eder.\n'
        '• **Uyarlama:** Alıştırmalar öğrencinin hızına göre değişir.';
    expect(PresentationContentQuality.normalizeContentBullets(raw), expected);
    expect(
        PresentationContentQuality.normalizeContentBullets(expected), expected);
    final parsed = SafeJsonParser.parsePresentationPayload(
      '{"slides":[{"title":"Eğitim", "content":"- **Denetim:** Öğretmen önerileri kontrol eder."}]}',
    );
    final slide = (parsed['slides'] as List).first as Map<String, dynamic>;
    for (final content in [
      GeminiSlide.fromJson(slide).content,
      GrokSlide.fromJson(slide).content,
      NvidiaSlide.fromJson(slide).content,
    ]) {
      expect(content, '• **Denetim:** Öğretmen önerileri kontrol eder.');
    }
  });

  test(
      'normalization preserves meaningful numbers, URLs and sentence boundaries',
      () {
    final result = PresentationContentQuality.normalizeContentBullets(
      '2026 yılında ölçüm yapılır.\n3.14 yaklaşık pi değeridir.\n'
      'https://sutols.com\n**Ölçüm:** Değer 3.14 olarak okunur. **Denetim:** Sonuç kontrol edilir.',
    );
    expect(result, contains('2026 yılında'));
    expect(result, contains('3.14 yaklaşık'));
    expect(result, contains('https://sutols.com'));
    expect(result, contains('okunur.\n• **Denetim:**'));
  });

  test(
      'Turkish quality gate flags missing labels, long text and incomplete clauses',
      () {
    for (final content in [
      '• Öğrenciler kendi hızlarında öğrenir ve öğretmen onlara destek olur.',
      '• **Uyarlama:** ${List.filled(21, 'kelime').join(' ')}.',
      '• **Denetim:** Öğretmen önerileri kontrol eder ve:',
      '• **Denetim:** Öğretmen önerileri kontrol eder.\n'
          '• **Denetim:** Öğretmen önerileri kontrol eder.',
    ]) {
      final samples = [
        PresentationContentSample(title: 'Eğitim', content: content)
      ];
      final result =
          PresentationContentQuality.evaluateQuality(samples, language: 'tr');
      expect(result.needsRevision, isTrue, reason: content);
      expect(result.isPass, isFalse, reason: content);
      expect(
          PresentationContentQuality.rejectionReason(samples, language: 'tr'),
          isNotNull);
    }
  });

  test(
      'concise labeled Turkish bullets pass while hero and English stay flexible',
      () {
    const slides = [
      PresentationContentSample(
        title: 'Sınıfta Yapay Zekâ',
        content:
            '• **Uyarlama:** Alıştırmalar öğrencinin öğrenme hızına göre değişir.\n'
            '• **Denetim:** Öğretmen önerilerin doğruluğunu ders öncesinde kontrol eder.',
      )
    ];
    expect(
        PresentationContentQuality.rejectionReason(slides, language: 'turkish'),
        isNull);
    for (final entry in [('hero', 'tr'), ('concept', 'english')]) {
      expect(
          PresentationContentQuality.turkishContentIssues([
            PresentationContentSample(
                title: 'Eğitim',
                type: entry.$1,
                content:
                    'Learning tools help every student develop at their own pace.'),
          ], language: entry.$2),
          isEmpty);
    }
  });

  test('generation and revision prompts agree on Turkish bullet rules', () {
    for (final prompt in [
      PresentationPromptBuilder.buildSystemInstruction(),
      PresentationPromptBuilder.buildUserPrompt(
          topic: 'Eğitim', slideCount: 5, language: 'tr'),
      PresentationPromptBuilder.buildRevisionPrompt(
          originalJson: '{}',
          issues: [],
          globalIssues: [],
          topic: 'Eğitim',
          slideCount: 5,
          language: 'tr'),
    ]) {
      expect(prompt, contains('**Vurgulu Başlık:** Açıklama'));
      expect(prompt, contains('20 kelime'));
      expect(prompt, isNot(contains('formatına zorlama')));
    }
    final userPrompt = PresentationPromptBuilder.buildUserPrompt(
        topic: 'Eğitim', slideCount: 5, language: 'tr');
    expect(userPrompt, isNot(contains('İstenen Slayt Sayısı:')),
        reason: 'The legacy proxy must not replace the new content contract.');
    expect(userPrompt, contains('Slayt adedi: 5'));
  });
}
