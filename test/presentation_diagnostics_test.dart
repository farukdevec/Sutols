import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/gemini_presentation_service.dart';
import 'package:sutol/services/presentation_service.dart';

void main() {
  test('final slide diagnostics expose all reviewable text as JSON', () {
    const slide = GeminiSlide(
      title: 'Evrenin Genişlemesi',
      subtitle: 'Kırmızıya kayma',
      content: '• **Gözlem:** Uzak galaksilerin ışığı kırmızıya kayar.',
      keywords: <String>['galaxy', 'redshift'],
      type: 'comparison',
      purpose: 'Hubble gözlemini açıklamak',
      keyMessage: 'Uzay genişledikçe ışığın dalga boyu uzar.',
      visual: <String, dynamic>{
        'kind': 'comparison',
        'subject': 'galaxy redshift comparison',
      },
    );

    final line = PresentationService.formatSlideTextLog(slide, 2);
    const prefix = '[SUTOL AI][SLIDE_TEXT] ';
    expect(line, startsWith(prefix));
    final payload =
        jsonDecode(line.substring(prefix.length)) as Map<String, dynamic>;

    expect(payload['slide'], 2);
    expect(payload['title'], slide.title);
    expect(payload['subtitle'], slide.subtitle);
    expect(payload['content'], slide.content);
    expect(payload['purpose'], slide.purpose);
    expect(payload['key_message'], slide.keyMessage);
    expect(payload['keywords'], slide.keywords);
    expect(payload['visual'], slide.visual);
    expect(payload['word_count'], greaterThan(5));
  });
}
