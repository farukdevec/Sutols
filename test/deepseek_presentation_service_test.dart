import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/deepseek_presentation_service.dart';

void main() {
  group('DeepSeekPresentationService JSON parsing tests', () {
    test('parses standard slides object payload', () {
      const jsonStr = '''
      {
        "slides": [
          {
            "title": "Bilgisayarların Gelişimi",
            "content": "- 1971'de Intel 4004 piyasaya sürüldü.\\n- x86 mimarisi standartlaştı.\\n- 2020'de Apple M-serisine geçiş yapıldı.",
            "keywords": ["intel", "apple", "islemci"]
          }
        ]
      }
      ''';
      final pres = DeepSeekPresentation.fromJson(
        DeepSeekPresentationService.parsePresentationPayload(jsonStr),
      );
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'Bilgisayarların Gelişimi');
      expect(pres.slides.first.keywords, ['intel', 'apple', 'islemci']);
    });

    test('strips reasoning think tags from DeepSeek-R1 responses', () {
      const reasoningPayload = '''
      <think>
      User wants a presentation about computing history.
      I need to ensure at least 3 factual bullet points.
      Slide 1: Microprocessors, 1971 Intel 4004.
      </think>
      {
        "slides": [
          {
            "title": "İşlemci Mimarileri",
            "content": "- Intel 4004 ilk ticari mikroişlemcidir.\\n- TSMC 3nm üretim süreci performans artışı sundu.\\n- ARM mimarisi mobil cihazlarda standart hale geldi.",
            "keywords": ["intel", "arm", "tsmc"]
          }
        ]
      }
      ''';
      final parsed = DeepSeekPresentationService.parsePresentationPayload(reasoningPayload);
      final pres = DeepSeekPresentation.fromJson(parsed);
      expect(pres.slides.length, 1);
      expect(pres.slides.first.title, 'İşlemci Mimarileri');
    });

    test('tryParsePresentationPayload returns null for invalid payload', () {
      const invalidContent = 'Bu bir slayt JSON yapısı değildir.';
      final parsed = DeepSeekPresentationService.tryParsePresentationPayload(invalidContent);
      expect(parsed, isNull);
    });
  });
}
