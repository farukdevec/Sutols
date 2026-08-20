import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sutol/env_config.dart';

void main() {
  test('Direct Grok API Test', () async {
    final client = http.Client();
    final url = Uri.parse('https://api.x.ai/v1/chat/completions');

    final payload = {
      'model': 'grok-4.3',
      'messages': [
        {'role': 'system', 'content': 'Sen bir sunum uzmanısın. Yalnızca JSON döndür.'},
        {'role': 'user', 'content': 'Yapay Zeka hakkında 3 slaytlık JSON üret: {"slides": [{"title": "t", "type": "hero", "content": "c", "keywords": []}]}'}
      ],
      'max_tokens': 1000,
      'temperature': 0.5,
    };

    final stopwatch = Stopwatch()..start();
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvConfig.grokApiKey}',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));
      stopwatch.stop();

      print('Status: ${response.statusCode}');
      print('Latency: ${stopwatch.elapsedMilliseconds}ms');
      print('Body:\n${response.body}');
    } catch (e) {
      stopwatch.stop();
      print('Error after ${stopwatch.elapsedMilliseconds}ms: $e');
    }
  });
}
