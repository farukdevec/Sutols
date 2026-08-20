import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_prompt_builder.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  group('Presentation Token Budget & Efficiency Tests', () {
    test('System prompt is lean, structured, and does not exceed token budget limit', () {
      final systemPrompt = PresentationPromptBuilder.buildSystemInstruction();

      // System prompt should be comprehensive yet compact (< 4500 chars)
      expect(systemPrompt.length, lessThan(4500));
      expect(systemPrompt, contains('learning_objective'));
      expect(systemPrompt, contains('visual_keywords'));
      expect(systemPrompt, contains('purpose'));
    });

    test('User prompt scales cleanly with slide count without repetitive bloat', () {
      final prompt7 = PresentationPromptBuilder.buildUserPrompt(
        topic: 'Yapay Zeka ve Gelecek',
        slideCount: 7,
        language: 'tr',
      );

      final prompt15 = PresentationPromptBuilder.buildUserPrompt(
        topic: 'Yapay Zeka ve Gelecek',
        slideCount: 15,
        language: 'tr',
      );

      expect(prompt7.length, lessThan(2000));
      expect(prompt15.length, lessThan(2500));
      expect(prompt7, contains('7'));
      expect(prompt15, contains('15'));
    });

    test('Quality evaluator penalizes essay-like excessive text density', () {
      final denseParagraphSlide = PresentationContentSample(
        title: 'Yoğun Metinli Slayt',
        purpose: 'Konuyu gereksiz uzun anlatmak',
        type: 'concept',
        content: '- **Yoğun Metin:** ${'Bu metin slayt yerine bir web makalesi gibi yazılmıştır. ' * 20}',
        visual: {'kind': 'none'},
        keywords: ['madde'],
      );

      final result = PresentationContentQuality.evaluateQuality(
        [denseParagraphSlide],
        targetAudience: 'ortaokul',
      );

      // Readability score should be penalized for extreme word count
      expect(result.readability, lessThan(10));
    });

    test('Revision prompt is focused only on flawed slides to minimize token consumption', () {
      final revisionPrompt = PresentationPromptBuilder.buildRevisionPrompt(
        originalJson: '{"slides": [{"title": "Slayt 1"}, {"title": "Slayt 2"}]}',
        issues: [
          {'slide_index': 1, 'issue': 'Çok fazla müfredat jargonu içeriyor'},
        ],
        globalIssues: ['Konu anlatımı ortaokul seviyesine indirgenmeli'],
        topic: 'Maddenin Halleri',
        slideCount: 2,
        language: 'tr',
      );

      // Revision prompt should be compact and specify only the targeted issues
      expect(revisionPrompt.length, lessThan(2500));
      expect(revisionPrompt, contains('Slayt 2'));
      expect(revisionPrompt, contains('Çok fazla müfredat jargonu'));
    });
  });
}
