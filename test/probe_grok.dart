import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  final apiKey = Platform.environment['SUTOLS_GROK_API_KEY'] ?? '';
  const liveEnabled = bool.fromEnvironment('SUTOLS_LIVE_TESTS');
  test('Direct Grok API Test', () async {
    final client = http.Client();
    final url = Uri.parse('https://api.x.ai/v1/chat/completions');

    final payload = {
      'model': 'grok-4.3',
      'messages': [
        {
          'role': 'system',
          'content': 'Sen bir sunum uzmanısın. Yalnızca JSON döndür.'
        },
        {
          'role': 'user',
          'content':
              'Yapay Zeka hakkında 3 slaytlık JSON üret: {"slides": [{"title": "t", "type": "hero", "content": "c", "keywords": []}]}'
        }
      ],
      'max_tokens': 1000,
      'temperature': 0.5,
    };

    final stopwatch = Stopwatch()..start();
    try {
      final response = await client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${apiKey}',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
      stopwatch.stop();

      print('Status: ${response.statusCode}');
      print('Latency: ${stopwatch.elapsedMilliseconds}ms');
      expect(response.statusCode, 200, reason: 'Grok request must succeed');
    } catch (e) {
      stopwatch.stop();
      print('Request failed after ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    } finally {
      client.close();
    }
  },
      skip: !liveEnabled
          ? 'Enable with --dart-define=SUTOLS_LIVE_TESTS=true'
          : apiKey.isEmpty
              ? 'Set SUTOLS_GROK_API_KEY in the process environment'
              : false);
}
