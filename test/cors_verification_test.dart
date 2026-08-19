import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('CORS Preflight (OPTIONS) & POST Validation for sutols.online', () async {
    final client = http.Client();
    final url = Uri.parse('https://sutols.online/');

    final testOrigins = [
      'https://sutols.com',
      'https://www.sutols.com',
      'https://sutols.web.app',
      'https://www.sutols.web.app',
      'https://sutols.firebaseapp.com',
    ];

    for (final origin in testOrigins) {
      print('\n--- Testing Origin: $origin ---');

      // 1. Test OPTIONS Preflight with user-agent, authorization, content-type
      final preflightReq = http.Request('OPTIONS', url);
      preflightReq.headers.addAll({
        'Origin': origin,
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'authorization, content-type, user-agent',
      });

      final streamedPreflight = await client.send(preflightReq);
      final preflightResp = await http.Response.fromStream(streamedPreflight);

      print('[PREFLIGHT] Status: ${preflightResp.statusCode}');
      print('[PREFLIGHT] Allow-Origin: ${preflightResp.headers['access-control-allow-origin']}');
      print('[PREFLIGHT] Allow-Headers: ${preflightResp.headers['access-control-allow-headers']}');
      print('[PREFLIGHT] Allow-Methods: ${preflightResp.headers['access-control-allow-methods']}');

      expect(preflightResp.statusCode, 204);
      expect(preflightResp.headers['access-control-allow-origin'], origin);
      expect(preflightResp.headers['access-control-allow-headers']?.toLowerCase().contains('user-agent'), isTrue);
      expect(preflightResp.headers['access-control-allow-headers']?.toLowerCase().contains('authorization'), isTrue);
      expect(preflightResp.headers['access-control-allow-headers']?.toLowerCase().contains('content-type'), isTrue);

      // 2. Test POST Request
      final postBody = {
        'model': 'nvidia/nemotron-3-nano-30b-a3b',
        'messages': [
          {'role': 'system', 'content': 'Test'},
          {'role': 'user', 'content': 'Test'}
        ],
        'max_tokens': 50,
      };

      final postReq = http.Request('POST', url);
      postReq.headers.addAll({
        'Origin': origin,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      postReq.body = jsonEncode(postBody);

      final streamedPost = await client.send(postReq);
      final postResp = await http.Response.fromStream(streamedPost);

      print('[POST] Status: ${postResp.statusCode}');
      print('[POST] Allow-Origin: ${postResp.headers['access-control-allow-origin']}');

      expect(postResp.headers['access-control-allow-origin'], origin);
    }
  });
}
