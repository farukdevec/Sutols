import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Probe sutols.online /nvidia-test endpoint', () async {
    final client = http.Client();
    final url = Uri.parse('https://sutols.online/nvidia-test');

    final stopwatch = Stopwatch()..start();
    try {
      final response = await client.get(
        url,
        headers: {
          'Origin': 'https://sutols.com',
          'Accept': 'application/json',
        },
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
