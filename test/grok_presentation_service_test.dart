import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/grok_presentation_service.dart';

void main() {
  group('GrokPresentationService JSON parsing tests', () {
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
      final pres = GrokPresentation.fromJson(
        GrokPresentationService.parsePresentationPayload(jsonStr),
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
      final pres = GrokPresentation.fromJson(
        GrokPresentationService.parsePresentationPayload(jsonStr),
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
      final pres = GrokPresentation.fromJson(
        GrokPresentationService.parsePresentationPayload(jsonStr),
      );
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'Giriş');
    });

    test('parses payload wrapped in markdown code blocks and preamble', () {
      const rawStr = '''
      İşte istediğiniz sunum:
      ```json
      {
        "slides": [
          {
            "title": "Giriş",
            "content": "- Makine öğrenimi algoritmaları\\n- Doğal dil işleme modelleri\\n- Bilgisayarlı görü teknikleri",
            "keywords": ["test"]
          }
        ]
      }
      ```
      ''';
      final pres = GrokPresentation.fromJson(
        GrokPresentationService.parsePresentationPayload(rawStr),
      );
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'Giriş');
    });
  });

  group('GrokPresentationService API key configuration tests', () {
    test('throws exception when API key and proxy URL are both empty', () {
      final service = GrokPresentationService(customApiKey: '', customProxyUrl: '');
      expect(
        () => service.generatePresentation('Yapay Zeka'),
        throwsA(isA<Exception>()),
      );
    });

    test('effectiveApiKey prefers customApiKey over static apiKey', () {
      GrokPresentationService.apiKey = 'static_key';
      final serviceWithCustom = GrokPresentationService(customApiKey: 'custom_key');
      final serviceWithoutCustom = GrokPresentationService();

      expect(serviceWithCustom.effectiveApiKey, 'custom_key');
      expect(serviceWithoutCustom.effectiveApiKey, 'static_key');

      // Reset static key
      GrokPresentationService.apiKey = '';
    });

    test('effectiveProxyUrl prefers customProxyUrl over static proxyUrl', () {
      GrokPresentationService.proxyUrl = 'https://sutols.online/grok';
      final serviceWithCustom = GrokPresentationService(customProxyUrl: 'https://custom.proxy/grok');
      final serviceWithoutCustom = GrokPresentationService();

      expect(serviceWithCustom.effectiveProxyUrl, 'https://custom.proxy/grok');
      expect(serviceWithoutCustom.effectiveProxyUrl, 'https://sutols.online/grok');

      // Reset static proxyUrl
      GrokPresentationService.proxyUrl = '';
    });

    test('generatePresentation succeeds when mockClient returns valid response', () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'slides': [
                      {
                        'title': 'Grok Slayt',
                        'content': '- Model mimarisinin ilk temeli\n- İkinci derin analitik aşama\n- Üçüncü stratejik optimizasyon',
                        'keywords': ['grok'],
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
      });

      final service = GrokPresentationService(
        customProxyUrl: 'https://sutols.online/',
        client: mockClient,
      );

      final result = await service.generatePresentation('Grok Konu');
      expect(result.slides.length, 1);
      expect(result.slides.first.title, 'Grok Slayt');
    });
  });
}
