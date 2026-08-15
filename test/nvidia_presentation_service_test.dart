import 'package:flutter_test/flutter_test.dart';
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
  });
}
