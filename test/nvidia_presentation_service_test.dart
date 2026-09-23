import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/ai_model_config.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';

void main() {
  group('NvidiaPresentationService JSON parsing and routing tests', () {
    test('accepts every supported slide-count lower bound', () {
      expect(NvidiaPresentationService.minimumAllowedSlides(1), 1);
      expect(NvidiaPresentationService.minimumAllowedSlides(2), 2);
      expect(NvidiaPresentationService.minimumAllowedSlides(3), 3);
      expect(NvidiaPresentationService.minimumAllowedSlides(30), 29);
    });

    test('parses standard slides object payload', () {
      const jsonStr = '''
      {
        "slides": [
          {
            "title": "Giriş",
            "content": "- Evrenin temel yapıtaşları\\n- Yıldızlar ve galaksiler\\n- Karadeliklerin gizemi",
            "keywords": ["dunya", "uzay"]
          }
        ]
      }
      ''';
      final pres = NvidiaPresentation.fromJson(
        NvidiaPresentationService.parsePresentationPayload(jsonStr),
      );
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'Giriş');
      expect(pres.slides.first.keywords, ['dunya', 'uzay']);
    });

    test('parses root-level array payload', () {
      const jsonStr = '''
      [
        {
          "title": "Giriş",
          "content": "- Güneş merkezli model\\n- Gezegenlerin yörüngeleri\\n- Çekim kuvveti yasaları",
          "keywords": ["dunya"]
        }
      ]
      ''';
      final pres = NvidiaPresentation.fromJson(
        NvidiaPresentationService.parsePresentationPayload(jsonStr),
      );
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'Giriş');
    });

    test('parses payload with alternative key (sunum/slaytlar)', () {
      const jsonStr = '''
      {
        "sunum": [
          {
            "title": "Giriş",
            "content": "- Klasik fizik temelleri\\n- Kuantum teorisinin doğuşu\\n- Modern fizik uygulamaları",
            "keywords": ["kavram"]
          }
        ]
      }
      ''';
      final pres = NvidiaPresentation.fromJson(
        NvidiaPresentationService.parsePresentationPayload(jsonStr),
      );
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'Giriş');
    });

    test('parses fenced payload locally then runs the mandatory quality judge',
        () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['model'] == AiModelConfig.modelLlama31_8b) {
          return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {
                      'content': jsonEncode({
                        'score': 95,
                        'factual_accuracy': 95,
                        'revision_required': false
                      })
                    }
                  }
                ]
              }),
              200);
        }
        const rawMarkdown = '''
        İşte sunumunuz:
        ```json
        {
          "slides": [
            {
              "title": "Giriş: Yapay Zeka",
              "content": "- Öğrenme: Algoritmalar verilerdeki örüntüleri öğrenir.\\n- Dil: Modeller yazılı metinleri işler.\\n- Görü: Sistemler görüntülerdeki nesneleri tanır.",
              "keywords": ["test"]
            }
          ]
        }
        ```
        Umarım beğenirsiniz.
        ''';
        return http.Response.bytes(
          utf8.encode(jsonEncode({
            'choices': [
              {
                'message': {
                  'content': rawMarkdown,
                }
              }
            ]
          })),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = NvidiaPresentationService(
        client: mockClient,
        customCandidateModels: [AiModelConfig.modelNemotronNano],
      );

      final result = await service.generatePresentation('Test Konusu');
      // One generation and one judge call, no parsing repair or revision call.
      expect(requestCount, 2);
      expect(result.slides.length, 1);
      expect(result.slides.first.title, 'Giriş: Yapay Zeka');
    });

    test(
        'candidate fallback: Super 120B fails -> GPT-OSS 120B succeeds -> Llama NOT called',
        () async {
      final calledModels = <String>[];
      final mockClient = MockClient((request) async {
        final reqBody = jsonDecode(request.body) as Map<String, dynamic>;
        final model = reqBody['model'] as String;
        calledModels.add(model);
        if (model == AiModelConfig.modelLlama31_8b) {
          return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {
                      'content': jsonEncode({
                        'score': 95,
                        'factual_accuracy': 95,
                        'revision_required': false
                      })
                    }
                  }
                ]
              }),
              200);
        }

        if (model == AiModelConfig.modelNemotronSuper) {
          // Super 120B 500 hatası döner
          return http.Response('Server Error', 500);
        }

        if (model == AiModelConfig.modelGptOss120b) {
          // GPT-OSS 120B başarılı döner
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'slides': [
                        {
                          'title': 'GPT-OSS 120B Başlık',
                          'content':
                              '- Mimari: Model ağırlıkları öğrenilen ilişkileri temsil eder.\n- Optimizasyon: Eğitim sırasında parametreler güncellenir.\n- Çıkarım: Model yeni girdiler için yanıt üretir.',
                          'keywords': ['gpt'],
                        }
                      ]
                    }),
                  }
                }
              ]
            })),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        return http.Response('Unexpected', 400);
      });

      final service = NvidiaPresentationService(
        client: mockClient,
        customCandidateModels: [
          AiModelConfig.modelNemotronSuper,
          AiModelConfig.modelGptOss120b,
          AiModelConfig.modelLlama33_70b,
        ],
      );

      final result = await service.generatePresentation('Test');
      expect(calledModels, [
        AiModelConfig.modelNemotronSuper,
        AiModelConfig.modelGptOss120b,
        AiModelConfig.modelLlama31_8b
      ]);
      expect(calledModels, isNot(contains(AiModelConfig.modelLlama33_70b)));
      expect(result.slides.first.title, 'GPT-OSS 120B Başlık');
    });

    test(
        'default candidates starts with GPT-OSS 120B and keeps verified fallbacks',
        () {
      expect(NvidiaPresentationService.defaultCandidateModels.first,
          AiModelConfig.modelGptOss120b);
      expect(NvidiaPresentationService.defaultCandidateModels,
          contains(AiModelConfig.modelGptOss120b));
      expect(NvidiaPresentationService.defaultCandidateModels,
          isNot(contains(AiModelConfig.modelNemotronSuper)));
      expect(NvidiaPresentationService.defaultCandidateModels,
          contains(AiModelConfig.modelGptOss20b));
      expect(NvidiaPresentationService.defaultCandidateModels,
          contains(AiModelConfig.modelNemotronNano));
      expect(NvidiaPresentationService.defaultCandidateModels,
          contains(AiModelConfig.modelLlama31_8b));
      expect(NvidiaPresentationService.defaultCandidateModels,
          isNot(contains(AiModelConfig.modelNemotronUltra)));
    });

    test('rejects a below-minimum final candidate instead of accepting it',
        () async {
      var judgeCalls = 0;
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['model'] == AiModelConfig.modelLlama31_8b) {
          judgeCalls += 1;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'score': 60,
                      'factual_accuracy': 60,
                      'revision_required': false,
                      'issues': <Map<String, dynamic>>[],
                    }),
                  },
                },
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'slides': [
                      {
                        'title': 'Learning',
                        'content':
                            '- **Adaptation:** Exercises change with learner pace.\n- **Practice:** Learners apply ideas with guided tasks.\n- **Review:** Teachers check progress and adjust support.',
                        'keywords': ['learning'],
                      },
                    ],
                  }),
                },
              },
            ],
          }),
          200,
        );
      });

      final service = NvidiaPresentationService(
        client: mockClient,
        customCandidateModels: [AiModelConfig.modelNemotronNano],
      );

      await expectLater(
        service.generatePresentation('Learning'),
        throwsA(
          predicate((error) => error.toString().contains('minimum 75')),
        ),
      );
      expect(judgeCalls, 1);
    });

    test('generates valid one- and two-slide requests with mocked AI',
        () async {
      for (final requestedSlideCount in [1, 2]) {
        final mockClient = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          if (body['model'] == AiModelConfig.modelLlama31_8b) {
            return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {
                      'content': jsonEncode({
                        'score': 95,
                        'factual_accuracy': 95,
                        'revision_required': false,
                        'issues': <Map<String, dynamic>>[],
                      }),
                    },
                  },
                ],
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'slides': [
                        {
                          'title': 'Learning',
                          'content':
                              '- **Concept:** Learners connect ideas through guided examples.\n- **Practice:** Learners apply the concept in a short task.\n- **Review:** Teachers check understanding and give feedback.',
                          'keywords': ['learning'],
                        },
                      ],
                    }),
                  },
                },
              ],
            }),
            200,
          );
        });

        final service = NvidiaPresentationService(
          client: mockClient,
          customCandidateModels: [AiModelConfig.modelNemotronNano],
        );
        final result = await service.generatePresentation(
          'Learning',
          slideCount: requestedSlideCount,
        );
        expect(result.slides, hasLength(1));
      }
    });

    test('rejects a high score with an unresolved factual issue', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['model'] == AiModelConfig.modelLlama31_8b) {
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'score': 95,
                      'factual_accuracy': 95,
                      'revision_required': false,
                      'issues': [
                        {
                          'slide': 1,
                          'category': 'factual_accuracy',
                          'problem': 'Claim remains unsupported.',
                        },
                      ],
                    }),
                  },
                },
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'slides': [
                      {
                        'title': 'Learning',
                        'content':
                            '- **Concept:** Learners connect ideas through guided examples.\n- **Practice:** Learners apply the concept in a short task.\n- **Review:** Teachers check understanding and give feedback.',
                        'keywords': ['learning'],
                      },
                    ],
                  }),
                },
              },
            ],
          }),
          200,
        );
      });
      final service = NvidiaPresentationService(
        client: mockClient,
        customCandidateModels: [AiModelConfig.modelNemotronNano],
      );

      await expectLater(
        service.generatePresentation('Learning'),
        throwsA(predicate((error) => error.toString().contains('ciddi'))),
      );
    });
  });
}
