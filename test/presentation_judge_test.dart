import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_judge_service.dart';

void main() {
  group('PresentationJudgeService Tests', () {
    test('high quality deck passes when the mandatory AI fact judge approves it', () async {
      final judge = PresentationJudgeService(
        client: MockClient((_) async => http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {
                      'content': jsonEncode({
                        'score': 94,
                        'factual_accuracy': 96,
                        'visual_relevance': 90,
                        'revision_required': false,
                        'issues': [],
                        'global_issues': [],
                      }),
                    },
                  },
                ],
              }),
              200,
            )),
      );
      final presentation = NvidiaPresentation(
        slides: const [
          NvidiaSlide(
            title: 'Maddenin Halleri',
            purpose: 'Temel kavramı tanıtmak',
            type: 'concept',
            content: '- **Tanecik Yapısı:** Madde atom ve moleküllerden oluşur.',
            keywords: ['su', 'buz', 'tanecik'],
          ),
          NvidiaSlide(
            title: 'Katı Hâl',
            purpose: 'Katıların düzenini öğretmek',
            type: 'concept',
            content: '- **Sabit Şekil:** Tanecikler titreşir ve sıkı dizilidir.',
            keywords: ['kristal', 'buz'],
          ),
          NvidiaSlide(
            title: 'Sıvı Hâl',
            purpose: 'Sıvıların akışkanlığını öğretmek',
            type: 'concept',
            content: '- **Akışkanlık:** Tanecikler kayarak kabın şeklini alır.',
            keywords: ['su', 'bardak'],
          ),
        ],
      );

      final result = await judge.judgePresentation(
        presentation: presentation,
        topic: 'Maddenin Halleri',
        targetAudience: 'ortaokul',
      );

      expect(result.overallScore, greaterThanOrEqualTo(85));
      expect(result.needsRevision, isFalse);
      expect(result.isPass, isTrue);
    });

    test('fact judge rejects a fluent but physically incorrect claim', () async {
      final judge = PresentationJudgeService(
        client: MockClient((request) async {
          expect(request.body, contains('Sürtünme kuvveti her zaman hareket yönündedir'));
          expect(request.body, contains('HEDEF KİTLE: ortaokul'));
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'score': 88,
                      'factual_accuracy': 15,
                      'visual_relevance': 80,
                      'revision_required': true,
                      'issues': [
                        {
                          'slide': 1,
                          'category': 'factual_accuracy',
                          'problem': 'Sürtünme kuvvetinin yönü ters yazılmış.'
                        }
                      ],
                      'global_issues': ['Fiziksel yön bilgisi düzeltilmeli.']
                    })
                  }
                }
              ]
            }),
            200,
          );
        }),
      );
      final result = await judge.judgePresentation(
        presentation: const NvidiaPresentation(
          slides: [
            NvidiaSlide(
              title: 'Sürtünmenin Yönü',
              type: 'concept',
              content: '- Sürtünme kuvveti her zaman hareket yönündedir.',
              keywords: ['kutu', 'zemin'],
              visual: {
                'kind': 'photo',
                'subject': 'wooden block sliding on a rough surface',
              },
            ),
          ],
        ),
        topic: 'Statik ve kinetik sürtünme',
        targetAudience: 'ortaokul',
      );

      expect(result.overallScore, lessThan(75));
      expect(result.factualAccuracy, lessThan(5));
      expect(result.isPass, isFalse);
    });

    test('Judge identifies issues and requests revision when mock AI judge detects problem', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'score': 78,
                    'revision_required': true,
                    'issues': [
                      {
                        'slide': 2,
                        'category': 'audience_fit',
                        'problem': 'Terminoloji ortaokul seviyesi için fazla ağır.'
                      }
                    ],
                    'global_issues': ['Genel anlatı akışını sadeleştir.']
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
      final presentation = NvidiaPresentation(
        slides: const [
          NvidiaSlide(
            title: 'Maddenin Halleri',
            purpose: 'Temel kavramı tanıtmak',
            type: 'concept',
            content: '- **Tanecik Yapısı:** Madde atom ve moleküllerden oluşur.\n- **Üç Temel Hâl:** Katı, sıvı ve gaz temel hâllerdir.',
            keywords: ['su', 'buz', 'tanecik'],
          ),
          NvidiaSlide(
            title: 'Katı Hâl',
            purpose: 'Katıların düzenini öğretmek',
            type: 'concept',
            content: '- **Sabit Şekil:** Katı maddelerin mikroskobik organizasyonu taneciklerin yoğun etkileşim içinde bulunmasıdır.',
            keywords: ['kristal', 'buz'],
          ),
          NvidiaSlide(
            title: 'Sıvı Hâl',
            purpose: 'Sıvıların akışkanlığını öğretmek',
            type: 'concept',
            content: '- **Akışkanlık:** Tanecikler kayarak kabın şeklini alır.',
            keywords: ['su', 'bardak'],
          ),
        ],
      );

      final result = await judge.judgePresentation(
        presentation: presentation,
        topic: 'ortaokul düzeyinde maddenin halleri',
        targetAudience: 'ortaokul',
        forceAiJudge: true,
      );

      expect(result.needsRevision, isTrue);
      expect(result.slideIssues.isNotEmpty, isTrue);
    });
  });
}
