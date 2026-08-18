import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/grok_presentation_service.dart';

void main() {
  group('GrokPresentationService JSON parsing tests', () {
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
          "content": "- Detay madde 1\\n- Detay madde 2",
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
            "content": "- İçerik",
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
            "content": "- Madde 1",
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
    test('throws exception when API key is empty', () {
      final service = GrokPresentationService(customApiKey: '');
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
  });
}
