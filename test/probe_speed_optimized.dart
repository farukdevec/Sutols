@Timeout(Duration(minutes: 5))
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sutol/services/safe_json_parser.dart';

void main() {
  test('Streamlined Prompt Speed Test for Llama 3.1 8B', () async {
    final client = http.Client();
    final url = Uri.parse('https://sutols.online/');

    const optimizedSystemInstruction = '''Sen profesyonel sunumlar tasarlayan kıdemli bir sunum direktörüsün.
GÖREV: Konuyu zengin anlatı ve çeşitli slayt türleriyle sunuma dönüştürmek.

KURALLAR:
1. Türkçe Kuralları: Motamot çeviri yapma, devrik/eksik cümle kurma, profesyonel terimler kullan.
2. Slayt Yapısı: Paragraf yazma. Her maddeyi "- **Vurgulu Başlık:** Net ve öz açıklama metni" şeklinde yaz.
3. Slayt Çeşitliliği: type alanına uygun arketipi ata (hero, cards, timeline, comparison, process, statistic, summary).
4. Çıktı: Ön açıklama veya düşünce metni YAZMA. Doğrudan tek bir JSON nesnesi döndür:
{"slides": [{"title": "Başlık", "type": "cards", "content": "- **Vurgulu Madde:** Açıklama", "keywords": ["anahtar1", "anahtar2"]}]}''';

    const optimizedUserPrompt = '''Konu: Yapay Zeka ve Gelecek
Slayt Sayısı: 5
Çıktı Dili: turkish

Yalnızca ve doğrudan tam 5 slayt içeren geçerli JSON nesnesi döndür:''';

    final payload = {
      'model': 'meta/llama-3.1-8b-instruct',
      'messages': [
        {'role': 'system', 'content': optimizedSystemInstruction},
        {'role': 'user', 'content': optimizedUserPrompt},
      ],
      'temperature': 0.3,
      'max_tokens': 2000,
      'response_format': {'type': 'json_object'},
    };

    final stopwatch = Stopwatch()..start();
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'https://sutols.com',
      },
      body: jsonEncode(payload),
    );
    stopwatch.stop();

    print('Status: ${response.statusCode}');
    print('LATENCY: ${stopwatch.elapsedMilliseconds}ms (${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s)');
    final decoded = jsonDecode(response.body);
    final content = decoded['choices']?[0]?['message']?['content'] ?? '';
    final parsed = SafeJsonParser.parsePresentationPayload(content as String);
    print('Slides: ${(parsed['slides'] as List).length}');
    for (var i = 0; i < (parsed['slides'] as List).length; i++) {
      final s = parsed['slides'][i];
      print('\nSlide ${i + 1} (${s['type']}): ${s['title']}');
      print('Content:\n${s['content']}');
      print('Keywords: ${s['keywords']}');
    }
  });
}
