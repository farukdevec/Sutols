import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/usage_service.dart';

void main() {
  const uid = 'free-user';
  final fixedNow = DateTime(2026, 8, 13, 10);

  UsageService serviceWith(MockClient client) => UsageService(
        client: client,
        tokenProvider: () async => 'test-token',
        now: () => fixedNow,
      );

  test('ücretsiz planın günlük sunum hakkı 5', () {
    expect(UsageService.dailyLimitForTier('free'), 5);
    expect(UsageService.dailyLimitForTier('unknown'), 5);
    expect(UsageService.dailyLimitForTier('plus'), 15);
    expect(UsageService.dailyLimitForTier('premium'), 999);
  });

  test('ilk günlük kullanım kaydını oluşturur', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount += 1;
      if (request.method == 'GET') return http.Response('', 404);
      expect(request.method, 'POST');
      expect(request.url.queryParameters['documentId'], '2026-08-13');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['fields']['count']['integerValue'], '1');
      return http.Response('{}', 200);
    });

    expect(
      await serviceWith(client).tryConsumeDailyQuota(uid, 5),
      isTrue,
    );
    expect(requestCount, 2);
  });

  test('dördüncü kullanımdan sonra sayacı 5 yapar', () async {
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        return http.Response(
          jsonEncode({
            'fields': {
              'count': {'integerValue': '4'},
            },
            'updateTime': '2026-08-13T10:00:00.000000Z',
          }),
          200,
        );
      }
      expect(request.method, 'PATCH');
      expect(
        request.url.queryParameters['currentDocument.updateTime'],
        '2026-08-13T10:00:00.000000Z',
      );
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['fields']['count']['integerValue'], '5');
      return http.Response('{}', 200);
    });

    expect(
      await serviceWith(client).tryConsumeDailyQuota(uid, 5),
      isTrue,
    );
  });

  test('sayaç 5 olduğunda ücretsiz kullanımı reddeder', () async {
    var requestCount = 0;
    final client = MockClient((request) async {
      requestCount += 1;
      return http.Response(
        jsonEncode({
          'fields': {
            'count': {'integerValue': '5'},
          },
          'updateTime': '2026-08-13T10:00:00.000000Z',
        }),
        200,
      );
    });

    expect(
      await serviceWith(client).tryConsumeDailyQuota(uid, 5),
      isFalse,
    );
    expect(requestCount, 1);
  });

  test('Firestore erişim hatasını kota doldu olarak yorumlamaz', () async {
    final client = MockClient((request) async => http.Response('denied', 403));

    expect(
      () => serviceWith(client).tryConsumeDailyQuota(uid, 5),
      throwsA(isA<UsageServiceException>()),
    );
  });
}
