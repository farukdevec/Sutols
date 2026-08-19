import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sutol/services/ai_model_config.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';

void main() {
  test('Real Generation Test: Makine Öğrenmesi with Origin', () async {
    final client = http.Client();
    final url = Uri.parse('https://sutols.online/');
    final stopwatch = Stopwatch()..start();

    final body = {
      'model': 'nvidia/nemotron-3-nano-30b-a3b',
      'messages': [
        {
          'role': 'system',
          'content': 'Sen bir sunum uzmanısın. JSON formatında {"slides": [{"title": "...", "content": "...", "keywords": [...]}]} döndür.',
        },
        {
          'role': 'user',
          'content': 'Konu: Makine Öğrenmesi\nSlayt Sayısı: 10\nÇıktı Dili: turkish',
        }
      ],
      'temperature': 0.5,
      'max_tokens': 2500,
    };

    final resp = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Origin': 'https://sutols.com',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      },
      body: jsonEncode(body),
    );

    stopwatch.stop();
    print('STATUS: ${resp.statusCode}');
    print('LATENCY: ${stopwatch.elapsedMilliseconds}ms');
    print('BODY: ${resp.body}');
  });
}
