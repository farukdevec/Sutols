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
      expect(NvidiaPresentationService.minimumAllowedSlides(30), 30);
    });

    test('rejects short and oversized decks independently of HTTP transport',
        () {
      final deck = NvidiaPresentation(slides: [
        const NvidiaSlide(
            title: 'Water', content: 'Water freezes.', keywords: ['water']),
      ]);
      expect(() => NvidiaPresentationService.validateSlideCount(deck, 2),
          throwsFormatException);
      expect(() => NvidiaPresentationService.validateSlideCount(deck, 0),
          throwsFormatException);
      expect(() => NvidiaPresentationService.validateSlideCount(deck, 1),
          returnsNormally);
    });

    test(
        'short deck falls back and the next candidate receives the count contract',
        () async {
      final generationPrompts = <String>[];
      final slides = [
        {
          'title': 'Ice',
          'content':
              '**Freezing:** Water forms solid crystals below its freezing point.\n**Shape:** Solid ice keeps its shape.',
          'keywords': ['ice']
        },
        {
          'title': 'Steam',
          'content':
              '**Heating:** Heat converts liquid water into water vapor.\n**Motion:** Gas particles spread throughout their container.',
          'keywords': ['steam']
        },
      ];
      final mock = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final judging = body['model'] == AiModelConfig.modelLlama31_8b;
        if (!judging)
          generationPrompts
              .add((body['messages'] as List).last['content'] as String);
        final content = judging
            ? {'score': 95, 'factual_accuracy': 95, 'revision_required': false}
            : {
                'slides': generationPrompts.length == 1
                    ? slides.take(1).toList()
                    : slides
              };
        return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': jsonEncode(content)}
                }
              ]
            }),
            200);
      });
      final result = await NvidiaPresentationService(
        client: mock,
        customCandidateModels: [
          AiModelConfig.modelNemotronNano,
          AiModelConfig.modelGptOss120b
        ],
      ).generatePresentation('States of water',
          slideCount: 2, language: 'english');
      expect(result.slides, hasLength(2));
      expect(generationPrompts, hasLength(2));
      expect(generationPrompts.last, contains('Return exactly 2 complete'));
    });

    for (final wrongRevisionCount in [false, true]) {
      test(
          'repairs tautology without accepting a wrong-sized revision: $wrongRevisionCount',
          () async {
        var generations = 0;
        final prompts = <String>[];
        final mock = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          Object content;
          if (body['model'] == AiModelConfig.modelLlama31_8b) {
            content = {
              'score': 95,
              'factual_accuracy': 95,
              'revision_required': false
            };
          } else {
            generations++;
            prompts.add((body['messages'] as List).last['content'] as String);
            final slide = generations == 1
                ? {
                    'title': 'Radiation',
                    'content': 'Radiation radiation radiation.',
                    'keywords': ['radiation']
                  }
                : {
                    'title': 'Shielding',
                    'content':
                        '**Barrier:** Concrete absorbs part of the radiation passing through it.\n**Distance:** Moving away from the source reduces exposure.',
                    'keywords': ['concrete']
                  };
            content = {
              'slides': [
                slide,
                if (generations > 1 && wrongRevisionCount) slide
              ]
            };
          }
          return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {'content': jsonEncode(content)}
                  }
                ]
              }),
              200);
        });
        final future = NvidiaPresentationService(
          client: mock,
          customCandidateModels: [AiModelConfig.modelNemotronNano],
        ).generatePresentation('Radiation shielding',
            slideCount: 1, language: 'english');
        if (wrongRevisionCount) {
          await expectLater(future,
              throwsA(predicate((e) => e.toString().contains('totolojik'))));
        } else {
          final result = await future;
          expect(result.slides, hasLength(1));
          expect(result.slides.single.title, 'Shielding');
        }
        expect(generations, 2);
        expect(prompts.last, contains('totolojik'));
        expect(prompts.last, contains('RETURN ALL slides'));
      });
    }

    for (final recoverySucceeds in [true, false]) {
      test('default route retries an invalid deck only once: $recoverySucceeds',
          () async {
        var attempts = 0;
        final mock = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final judging = body['model'] == AiModelConfig.modelLlama31_8b;
          if (!judging) attempts++;
          final content = judging
              ? {
                  'score': 95,
                  'factual_accuracy': 95,
                  'revision_required': false
                }
              : {
                  'slides': [
                    {
                      'title': 'Ice',
                      'content':
                          '**Freezing:** Water forms solid crystals below its freezing point.\n**Shape:** Solid ice keeps its shape.',
                      'keywords': ['ice']
                    },
                    if (recoverySucceeds && attempts == 2)
                      {
                        'title': 'Steam',
                        'content':
                            '**Heating:** Heat converts liquid water into water vapor.\n**Motion:** Gas particles spread throughout their container.',
                        'keywords': ['steam']
                      },
                  ]
                };
          return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {'content': jsonEncode(content)}
                  }
                ]
              }),
              200);
        });
        final future = NvidiaPresentationService(client: mock)
            .generatePresentation('States of water',
                slideCount: 2, language: 'english');
        if (recoverySucceeds) {
          expect((await future).slides, hasLength(2));
        } else {
          await expectLater(future, throwsA(isA<Exception>()));
        }
        expect(attempts, 2);
      });
    }

    for (final invalidCompletion in [false, true]) {
      test(
          'completes missing slides and validates the combined deck: $invalidCompletion',
          () async {
        final slides = [
          {
            'title': 'Ice',
            'content':
                '**Freezing:** Water forms solid crystals below its freezing point.\n**Shape:** Solid ice keeps its shape.',
            'keywords': ['ice']
          },
          {
            'title': 'Steam',
            'content':
                '**Heating:** Heat converts liquid water into water vapor.\n**Motion:** Gas particles spread throughout their container.',
            'keywords': ['steam']
          },
          {
            'title': 'Measurement',
            'content':
                '**Thermometer:** A thermometer measures the temperature of the sample.\n**Observation:** Students record the reading before and after heating.',
            'keywords': ['thermometer']
          },
          {
            'title': 'Applications',
            'content':
                '**Cooling:** Melting ice absorbs energy from a drink.\n**Cooking:** Boiling water transfers heat to food in a saucepan.',
            'keywords': ['saucepan']
          },
        ];
        var generations = 0;
        final mock = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final judging = body['model'] == AiModelConfig.modelLlama31_8b;
          if (!judging) generations++;
          final content = judging
              ? {
                  'score': 95,
                  'factual_accuracy': 95,
                  'revision_required': false
                }
              : {
                  'title': 'Water experiment',
                  'target_audience': 'middle_school',
                  'slides': generations == 1
                      ? slides.take(3).toList()
                      : invalidCompletion
                          ? [slides.last, slides.last]
                          : [slides.last]
                };
          if (!judging && generations == 2) {
            expect((body['messages'] as List).last['content'],
                contains('exactly 1 NEW slides'));
          }
          return http.Response(
              jsonEncode({
                'choices': [
                  {
                    'message': {'content': jsonEncode(content)}
                  }
                ]
              }),
              200);
        });
        final future = NvidiaPresentationService(
          client: mock,
          customCandidateModels: [AiModelConfig.modelNemotronNano],
        ).generatePresentation('States of water',
            slideCount: 4, language: 'english');
        if (invalidCompletion) {
          await expectLater(future, throwsA(isA<Exception>()));
        } else {
          final result = await future;
          expect(result.slides.map((s) => s.title),
              ['Ice', 'Steam', 'Measurement', 'Applications']);
          expect(result.targetAudience, 'middle_school');
          expect(result.title, 'Water experiment');
        }
        expect(generations, 2);
      });
    }

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

      final result =
          await service.generatePresentation('Test Konusu', slideCount: 1);
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

      final result = await service.generatePresentation('Test', slideCount: 1);
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
        service.generatePresentation('Learning', slideCount: 1),
        throwsA(
          predicate((error) => error.toString().contains('minimum 75')),
        ),
      );
      expect(judgeCalls, 2);
    });

    test('generates a valid single-slide request with mocked AI', () async {
      for (final requestedSlideCount in [1]) {
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

    test('accepts a passing deck when a factual issue is advisory', () async {
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

      final result =
          await service.generatePresentation('Learning', slideCount: 1);
      expect(result.slides, hasLength(1));
      expect(result.slides.first.title, 'Learning');
    });

    test(
        'keeps a usable 75-point NVIDIA deck when a factual issue remains advisory',
        () async {
      var generationCalls = 0;
      var judgeCalls = 0;
      final deck = {
        'slides': [
          {
            'title': 'Yapay Zekâdaki Güncel Gelişmeler',
            'content':
                '- **Çok Modlu Modeller:** Metin, görsel ve sesi aynı iş akışında birlikte yorumlar.\n- **Küçük Modeller:** Daha az kaynakla cihaz üzerinde hızlı ve özel çıkarım sunar.\n- **Yapay Zekâ Ajanları:** Araç kullanarak çok adımlı görevleri planlar ve tamamlar.',
            'keywords': ['yapay zekâ', 'çok modlu model', 'ajan'],
          },
        ],
      };
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['model'] == AiModelConfig.modelLlama31_8b) {
          judgeCalls += 1;
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'score': 75,
                      'factual_accuracy': 80,
                      'revision_required': true,
                      'issues': [
                        {
                          'slide': 1,
                          'category': 'factual_accuracy',
                          'problem': 'Tanım daha kesin ifade edilebilir.',
                        },
                      ],
                    }),
                  },
                },
              ],
            })),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        generationCalls += 1;
        return http.Response.bytes(
          utf8.encode(jsonEncode({
            'choices': [
              {
                'message': {'content': jsonEncode(deck)},
              },
            ],
          })),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final service = NvidiaPresentationService(
        client: mockClient,
        customCandidateModels: [AiModelConfig.modelNemotronNano],
      );

      final result = await service.generatePresentation(
        'yapay zekadaki güncel gelişmeler neler?',
        slideCount: 1,
      );

      expect(result.slides, hasLength(1));
      expect(generationCalls, 2); // initial generation + revision
      expect(judgeCalls, 2); // original + revised deck
    });
  });
}
