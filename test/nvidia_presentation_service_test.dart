import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/ai_model_config.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';

void main() {
  group('NvidiaPresentationService JSON parsing and routing tests', () {
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

    test('parses payload wrapped in markdown code blocks and preamble in 0 extra AI calls', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        const rawMarkdown = '''
        İşte sunumunuz:
        ```json
        {
          "slides": [
            {
              "title": "Giriş: Yapay Zeka",
              "content": "- Makine öğrenimi algoritmaları\\n- Doğal dil işleme modelleri\\n- Bilgisayarlı görü teknikleri",
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
      // Should succeed in exactly 1 request via local SafeJsonParser (no 2nd AI call)
      expect(requestCount, 1);
      expect(result.slides.length, 1);
      expect(result.slides.first.title, 'Giriş: Yapay Zeka');
    });

    test('candidate fallback: Super 120B fails -> GPT-OSS 120B succeeds -> Llama NOT called', () async {
      final calledModels = <String>[];
      final mockClient = MockClient((request) async {
        final reqBody = jsonDecode(request.body) as Map<String, dynamic>;
        final model = reqBody['model'] as String;
        calledModels.add(model);

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
                          'content': '- Model ağırlıkları ve mimari\n- Parametre optimizasyonu\n- Hızlı çıkarım performansı',
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
      expect(calledModels, [AiModelConfig.modelNemotronSuper, AiModelConfig.modelGptOss120b]);
      expect(calledModels, isNot(contains(AiModelConfig.modelLlama33_70b)));
      expect(result.slides.first.title, 'GPT-OSS 120B Başlık');
    });

    test('default candidates contains Super 120B, GPT-OSS 120B, Llama 3.3 70B, GPT-OSS 20B, Nano, Llama 3.1 8B and excludes Ultra', () {
      expect(NvidiaPresentationService.defaultCandidateModels.first, AiModelConfig.modelNemotronSuper);
      expect(NvidiaPresentationService.defaultCandidateModels, contains(AiModelConfig.modelGptOss120b));
      expect(NvidiaPresentationService.defaultCandidateModels, contains(AiModelConfig.modelLlama33_70b));
      expect(NvidiaPresentationService.defaultCandidateModels, contains(AiModelConfig.modelGptOss20b));
      expect(NvidiaPresentationService.defaultCandidateModels, contains(AiModelConfig.modelNemotronNano));
      expect(NvidiaPresentationService.defaultCandidateModels, contains(AiModelConfig.modelLlama31_8b));
      expect(NvidiaPresentationService.defaultCandidateModels, isNot(contains(AiModelConfig.modelNemotronUltra)));
    });
  });
}
