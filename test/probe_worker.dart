import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test(
    'Probe sutols.online directly',
    () async {
      final client = http.Client();
      final url = Uri.parse('https://sutols.online/');

    final payload = {
      'model': 'meta/llama-3.3-70b-instruct',
      'messages': [
        {'role': 'system', 'content': 'Sen bir sunum uzmanısın. Yalnızca JSON döndür.'},
        {'role': 'user', 'content': 'Çernobil hakkında 3 slaytlık JSON üret: {"slides": [{"title": "t", "type": "hero", "content": "c", "keywords": []}]}'}
      ],
      'max_tokens': 1000,
      'temperature': 0.5,
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
    print('Latency: ${stopwatch.elapsedMilliseconds}ms');
    print('Headers: ${response.headers}');
    print('Body:\n${response.body}');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
