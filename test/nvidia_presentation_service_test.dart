import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';

void main() {
  group('NvidiaPresentationService JSON parsing tests', () {
    test('parses standard slides object payload', () {
      const jsonStr = '''
      {
        "slides": [
          {
            "title": "Giriş",
            "content": "- İlk madde\\n- İkinci madde",
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
          "content": "- Detay madde 1\\n- Detay madde 2",
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
            "content": "- İçerik",
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

    test('parses payload wrapped in markdown code blocks and preamble', () {
      const rawStr = '''
      Harika! İşte istediğiniz sunum:
      ```json
      {
        "slides": [
          {
            "title": "Giriş",
            "content": "- Madde 1",
            "keywords": ["test"]
          }
        ]
      }
      ```
      Umarım beğenirsiniz.
      ''';
      final pres = NvidiaPresentation.fromJson(
        NvidiaPresentationService.parsePresentationPayload(rawStr),
      );
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'Giriş');
    });

    test('tryParsePresentationPayload returns null for plain Markdown/text response', () {
      const markdownStr = '''
      ** Slayt 1 :**
      ** Giriş :**
      ** Sinan Akçıl'ın Maaş ve Ekonomi Üzerine Bir Analiz **
      - Madde 1
      - Madde 2
      ''';
      final parsed = NvidiaPresentationService.tryParsePresentationPayload(markdownStr);
      expect(parsed, isNull);
    });

    test('tryParsePresentationPayload returns non-null map for valid JSON', () {
      const jsonStr = '''
      {
        "slides": [
          {
            "title": "Ekonomi Analizi",
            "content": "- Madde 1\\n- Madde 2",
            "keywords": ["ekonomi", "maas"]
          }
        ]
      }
      ''';
      final parsed = NvidiaPresentationService.tryParsePresentationPayload(jsonStr);
      expect(parsed, isNotNull);
      expect(parsed!['slides'], isA<List>());
    });

    test('generatePresentation triggers JSON ONLY retry when initial response is Markdown', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        final reqBody = jsonDecode(request.body) as Map<String, dynamic>;
        
        // First call: returns Markdown
        if (requestCount == 1) {
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': "** Slayt 1 :**\n** Giriş :**\n** Sinan Akçıl'ın Maaş ve Ekonomi Üzerine Bir Analiz **",
                  }
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        // Second call (correction retry): verify assistant message is included in correction request
        final messages = reqBody['messages'] as List;
        expect(messages.any((m) => m['role'] == 'assistant'), isTrue);

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'slides': [
                      {
                        'title': 'Giriş: Ekonomi',
                        'content': '- Sinan Akçıl maaş analizi',
                        'keywords': ['ekonomi', 'maas'],
                      }
                    ]
                  }),
                }
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = NvidiaPresentationService(
        client: mockClient,
        customCandidateModels: ['meta/llama-3.1-8b-instruct'],
      );

      final result = await service.generatePresentation('Sinan Akçıl Maaş');
      expect(requestCount, 2);
      expect(result.slides.length, 1);
      expect(result.slides.first.title, 'Giriş: Ekonomi');
    });

    test('generatePresentation falls back to next candidate model if JSON retry fails', () async {
      final requestedModels = <String>[];
      final mockClient = MockClient((request) async {
        final reqBody = jsonDecode(request.body) as Map<String, dynamic>;
        final model = reqBody['model'] as String;
        requestedModels.add(model);

        if (model == 'model_a') {
          // model_a returns plain Markdown on all calls
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': '** Slayt 1 :** Markdown format',
                  }
                }
              ]
            }),
            200,
          );
        }

        // model_b returns valid JSON
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'slides': [
                      {
                        'title': 'Model B Slayt',
                        'content': '- Madde 1',
                        'keywords': ['test'],
                      }
                    ]
                  }),
                }
              }
            ]
          }),
          200,
        );
      });

      final service = NvidiaPresentationService(
        client: mockClient,
        customCandidateModels: ['model_a', 'model_b'],
      );

      final result = await service.generatePresentation('Test Konusu');
      expect(requestedModels, contains('model_a'));
      expect(requestedModels, contains('model_b'));
      expect(result.slides.first.title, 'Model B Slayt');
    });
  });
}
