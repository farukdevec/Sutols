import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/safe_json_parser.dart';

void main() {
  group('SafeJsonParser Tests', () {
    test('Scenario 1: Direct JSON map parsing', () {
      const raw = '''
      {
        "slides": [
          {
            "title": "Giriş",
            "content": "- Madde 1\\n- Madde 2\\n- Madde 3",
            "keywords": ["anahtar1", "anahtar2"]
          }
        ]
      }
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      expect(parsed['slides'], isA<List>());
      final slides = parsed['slides'] as List;
      expect(slides.length, 1);
      expect(slides.first['title'], 'Giriş');
      expect(slides.first['keywords'], ['anahtar1', 'anahtar2']);
    });

    test('Scenario 2: Markdown code fence (```json ... ```) with preamble and postamble', () {
      const raw = '''
      Harika bir konu! İşte hazırladığım sunum:
      ```json
      {
        "slides": [
          {
            "title": "Yapay Zeka Tarihi",
            "content": "- 1950 Alan Turing testi\\n- 1956 Dartmouth konferansı\\n- 2020 Büyük dil modelleri",
            "keywords": ["turing", "ai"]
          }
        ]
      }
      ```
      Umarım sunumunuzda faydalı olur!
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.length, 1);
      expect(slides.first['title'], 'Yapay Zeka Tarihi');
    });

    test('Scenario 3: DeepSeek <think>...</think> tags removal', () {
      const raw = '''
      <think>
      Kullanıcı yapay zeka hakkında 1 slayt istiyor.
      JSON formatında döndürmeliyim.
      </think>
      {
        "slides": [
          {
            "title": "Derin Öğrenme",
            "content": "- Çok katmanlı ağlar\\n- Geri yayılım algoritması\\n- GPU hızlandırma",
            "keywords": ["deep learning", "neural"]
          }
        ]
      }
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.length, 1);
      expect(slides.first['title'], 'Derin Öğrenme');
    });

    test('Scenario 4: Array-only root JSON structure ([{...}])', () {
      const raw = '''
      [
        {
          "title": "Bulut Bilişim",
          "content": "- IaaS hizmetleri\\n- PaaS platformları\\n- SaaS uygulamaları",
          "keywords": ["cloud", "server"]
        }
      ]
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.length, 1);
      expect(slides.first['title'], 'Bulut Bilişim');
    });

    test('Scenario 5: Alternative Turkish keys (baslik, icerik, anahtar_kelimeler)', () {
      const raw = '''
      {
        "slaytlar": [
          {
            "baslik": "Türk Kahvesi",
            "icerik": "- İnce çekilmiş kahve\\n- Bakır cezve\\n- Kısık ateşte pişirme",
            "anahtar_kelimeler": ["kahve", "cezve"]
          }
        ]
      }
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.length, 1);
      expect(slides.first['title'], 'Türk Kahvesi');
      expect(slides.first['content'], contains('İnce çekilmiş'));
      expect(slides.first['keywords'], ['kahve', 'cezve']);
    });

    test('Scenario 6: Embedded JSON between preambles without code fences', () {
      const raw = '''
      Here is the requested presentation JSON for your topic:
      {"slides": [{"title": "Güneş Sistemi", "content": "- Güneş merkezdedir\\n- 8 gezegen bulunur\\n- Kuiper kuşağı dış sınırdır", "keywords": ["gunes", "gezegen"]}]}
      Let me know if you need more slides!
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.length, 1);
      expect(slides.first['title'], 'Güneş Sistemi');
    });

    test('Scenario 7: Schema and content validation succeeds for valid payload', () {
      final valid = {
        'slides': [
          {
            'title': 'Test Başlık',
            'content': '- Madde 1\\n- Madde 2\\n- Madde 3',
            'keywords': ['test'],
          }
        ]
      };

      expect(() => SafeJsonParser.validateSchema(valid), returnsNormally);
      expect(() => SafeJsonParser.validateContent(valid), returnsNormally);
    });

    test('Scenario 8: Schema and content validation fails for empty/missing fields', () {
      final missingTitle = {
        'slides': [
          {
            'content': '- Madde 1',
          }
        ]
      };
      expect(() => SafeJsonParser.validateSchema(missingTitle), throwsA(isA<FormatException>()));

      final emptyTitle = {
        'slides': [
          {
            'title': '   ',
            'content': '- Madde 1',
          }
        ]
      };
      expect(() => SafeJsonParser.validateContent(emptyTitle), throwsA(isA<FormatException>()));
    });

    test('Scenario 9: Reasoning preamble before unnested slide objects (Nemotron style)', () {
      const raw = '''
      We need to produce JSON with slides array of exactly 2 items.
      Let's design:
      Slide1: {
        "title": "Maddenin Halleri",
        "subtitle": "Temel Kavramlar",
        "type": "hero",
        "content": "- **Katı:** Sabit şekil\\n- **Sıvı:** Akışkan\\n- **Gaz:** Serbest",
        "keywords": ["katı", "sıvı", "gaz"]
      }
      Slide2: {
        "title": "Hal Değişimleri",
        "type": "process",
        "content": "- **Erime:** Katıdan sıvıya\\n- **Buharlaşma:** Sıvıdan gaza",
        "keywords": ["erime", "buharlaşma"]
      }
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.length, 2);
      expect(slides[0]['title'], 'Maddenin Halleri');
      expect(slides[1]['title'], 'Hal Değişimleri');
    });

    test('Scenario 10: Truncated JSON recovery when model hits token limit', () {
      const raw = '''
      {
        "slides": [
          {
            "title": "Güneş Enerjisi",
            "content": "- **Fotovoltaik:** Işığı elektriğe dönüştürür",
            "keywords": ["güneş"]
          },
          {
            "title": "Rüzgar Enerjisi",
            "content": "- **Türbinler:** Kinetik enerjiyi elektriğe
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.isNotEmpty, true);
      expect(slides.first['title'], 'Güneş Enerjisi');
    });

    test('Scenario 11: Complex nested JSON with reasoning text and balanced brace extraction', () {
      const raw = '''
      Plan: Produce high quality presentation for middle school.
      Step 1: Introduction.
      {"slides": [{"title": "Atomun Yapısı", "subtitle": "Mikro Dünya", "type": "cards", "sections": [{"heading": "Proton", "description": "Çekirdekte bulunur"}], "content": "- **Proton:** Çekirdekte bulunur", "keywords": ["atom"]}]}
      I hope this helps!
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(raw);
      final slides = parsed['slides'] as List;
      expect(slides.length, 1);
      expect(slides.first['title'], 'Atomun Yapısı');
      expect(slides.first['sections'], isA<List>());
    });
  });
}
