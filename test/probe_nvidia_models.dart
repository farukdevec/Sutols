@Timeout(Duration(minutes: 5))
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sutol/services/presentation_prompt_builder.dart';
import 'package:sutol/services/safe_json_parser.dart';

void main() {
  test('NVIDIA Models Latency & Response Test', () async {
    final client = http.Client();
    final url = Uri.parse('https://sutols.online/');

    final models = [
      'meta/llama-3.1-8b-instruct',
      'nvidia/nemotron-3-nano-30b-a3b',
      'openai/gpt-oss-20b',
      'meta/llama-3.3-70b-instruct',
    ];

    for (final model in models) {
      print('\n----------------------------------------');
      print('TESTING: $model (5 slides)');
      final systemInstruction = PresentationPromptBuilder.buildSystemInstruction();
      final userPrompt = PresentationPromptBuilder.buildUserPrompt(
        topic: 'Yapay Zeka',
        slideCount: 5,
        language: 'turkish',
      );

      final payload = {
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemInstruction},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.3,
        'max_tokens': 3000,
        'response_format': {'type': 'json_object'},
      };

      final stopwatch = Stopwatch()..start();
      try {
        final response = await client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Origin': 'https://sutols.com',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 60));
        stopwatch.stop();

        print('Status: ${response.statusCode}');
        print('Latency: ${stopwatch.elapsedMilliseconds}ms (${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}s)');
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final content = decoded['choices']?[0]?['message']?['content'] ?? '';
          print('Content length: ${(content as String).length}');
          final parsed = SafeJsonParser.parsePresentationPayload(content);
          print('Parsed slides count: ${(parsed['slides'] as List).length}');
          print('Sample first slide: ${parsed['slides'][0]['title']}');
        } else {
          print('Error response: ${response.body}');
        }
      } catch (e) {
        stopwatch.stop();
        print('FAILED after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
    }
  });
}
