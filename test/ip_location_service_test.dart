import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/ip_location_service.dart';

void main() {
  test('IP yanıtından yalnızca yaklaşık konum alanlarını okur', () async {
    Uri? requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(
        jsonEncode({
          'success': true,
          'ip': '203.0.113.10',
          'city': 'İstanbul',
          'region': 'İstanbul',
          'country': 'Türkiye',
          'country_code': 'tr',
          'latitude': 41.0,
          'longitude': 29.0,
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final location = await IpLocationService(client: client).lookup();

    expect(requestedUri?.host, 'ipwho.is');
    expect(location, isNotNull);
    expect(location!.city, 'İstanbul');
    expect(location.region, 'İstanbul');
    expect(location.country, 'Türkiye');
    expect(location.countryCode, 'TR');
  });

  test('başarısız IP yanıtında giriş akışını bozmadan null döner', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode({'success': false}),
          200,
        ));

    expect(await IpLocationService(client: client).lookup(), isNull);
  });
}
