import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_content_quality.dart';
import 'package:sutol/services/presentation_judge_service.dart';
import 'package:sutol/services/presentation_prompt_builder.dart';

void main() {
  group('Presentation Smart Revision Tests', () {
    test('buildRevisionPrompt constructs targeted revision prompt with issues', () {
      final prompt = PresentationPromptBuilder.buildRevisionPrompt(
        originalJson: '{"slides": []}',
        issues: [
          {'slide': 2, 'category': 'redundancy', 'problem': 'Tekrarlayan tanım'},
          {'slide': 6, 'category': 'audience_fit', 'problem': 'Ağır terminoloji'},
        ],
        globalIssues: ['Anlatıyı sadeleştir'],
        topic: 'Maddenin Halleri',
        slideCount: 7,
        language: 'turkish',
      );

      expect(prompt, contains('Slayt 2 (redundancy): Tekrarlayan tanım'));
      expect(prompt, contains('Slayt 6 (audience_fit): Ağır terminoloji'));
      expect(prompt, contains('YALNIZCA sorun tespit edilen slaytları düzelt'));
    });

    test('revisePresentation calls proxy and returns updated NvidiaPresentation', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'slides': [
                      {
                        'title': 'Maddenin Halleri',
                        'type': 'concept',
                        'content': '- **Tanecik Yapısı:** Madde atom ve moleküllerden oluşur.',
                        'visual_keywords': ['su', 'buz', 'tanecik']
                      },
                      {
                        'title': 'Katı Hâl (Düzeltildi)',
                        'type': 'concept',
                        'content': '- **Sabit Şekil:** Tanecikler birbirine çok yakındır ve sadece titreşir.',
                        'visual_keywords': ['buz', 'kristal']
                      }
                    ]
                  })
                }
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final judge = PresentationJudgeService(client: mockClient);
      final original = NvidiaPresentation(
        slides: const [
          NvidiaSlide(title: 'Maddenin Halleri', content: 'Eski metin', keywords: ['su']),
          NvidiaSlide(title: 'Katı Hâl', content: 'Sorunlu metin', keywords: ['buz']),
        ],
      );

      final revised = await judge.revisePresentation(
        originalPresentation: original,
        qualityResult: const QualityScoreResult(
          overallScore: 78,
          factualAccuracy: 18,
          audienceFit: 14,
          pedagogicalValue: 16,
          narrativeCoherence: 12,
          redundancy: 8,
          readability: 6,
          visualPotential: 4,
          slideIssues: [
            {'slide': 2, 'problem': 'Sorunlu metin'}
          ],
          needsRevision: true,
          isPass: false,
        ),
        topic: 'Maddenin Halleri',
        slideCount: 2,
        language: 'turkish',
      );

      expect(revised.slides.length, 2);
      expect(revised.slides[1].title, contains('Düzeltildi'));
      expect(revised.slides[1].content, contains('titreşir'));
    });
  });
}
