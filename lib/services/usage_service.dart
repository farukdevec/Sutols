import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firestore_rest_helper.dart';

class UsageServiceException implements Exception {
  const UsageServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Günlük kullanım sayacını Firestore REST API üzerinden atomik olarak artırır.
///
/// Web'de Firestore SDK'sının sayı alanlarını dönüştürürken verdiği hatalar kota
/// dolmuş gibi yorumlanmamalıdır. REST yanıtı kota aşımı ile erişim/bağlantı
/// hatalarını birbirinden ayırmamızı sağlar.
class UsageService {
  UsageService({
    http.Client? client,
    Future<String> Function()? tokenProvider,
    DateTime Function()? now,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider ?? FirestoreRestHelper.authToken,
        _now = now ?? DateTime.now;

  static const int freeDailyLimit = 5;
  static const int plusDailyLimit = 15;

  final http.Client _client;
  final Future<String> Function() _tokenProvider;
  final DateTime Function() _now;

  static int dailyLimitForTier(String tier) => switch (tier) {
        'plus' || 'premium' || 'pro' => plusDailyLimit,
        _ => freeDailyLimit,
      };

  Future<bool> tryConsumeDailyQuota(String uid, int dailyLimit) async {
    final today = _now().toIso8601String().substring(0, 10);
    final documentPath = 'users/$uid/usage/$today';
    final token = await _tokenProvider();
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Eşzamanlı iki istekte updateTime önkoşulu yalnızca bir yazmayı kabul
    // eder. Diğeri güncel sayacı okuyup yeniden dener.
    for (var attempt = 0; attempt < 4; attempt += 1) {
      final readResponse = await _client.get(
        Uri.parse('${FirestoreRestHelper.apiBase}/$documentPath'),
        headers: headers,
      );

      if (readResponse.statusCode == 404) {
        final createUri = Uri.parse(
          '${FirestoreRestHelper.apiBase}/users/$uid/usage',
        ).replace(queryParameters: <String, String>{'documentId': today});
        final createResponse = await _client.post(
          createUri,
          headers: headers,
          body: jsonEncode({
            'fields': {
              'uid': {'stringValue': uid},
              'date': {'stringValue': today},
              'count': {'integerValue': '1'},
            },
          }),
        );
        if (createResponse.statusCode == 200) return true;
        if (createResponse.statusCode == 409) continue;
        throw _responseException('oluşturma', createResponse);
      }

      if (readResponse.statusCode != 200) {
        throw _responseException('okuma', readResponse);
      }

      final document = jsonDecode(readResponse.body) as Map<String, dynamic>;
      final fields = document['fields'] as Map<String, dynamic>? ?? const {};
      final countValue = fields['count'] as Map<String, dynamic>?;
      final rawCount = countValue?['integerValue'];
      final currentCount = switch (rawCount) {
        String value => int.tryParse(value) ?? 0,
        num value => value.toInt(),
        _ => 0,
      };
      if (currentCount >= dailyLimit) return false;

      final updateTime = document['updateTime'] as String?;
      if (updateTime == null || updateTime.isEmpty) {
        throw const UsageServiceException(
          'Günlük kullanım kaydının sürüm bilgisi okunamadı.',
        );
      }
      final updateUri = Uri.parse(
        '${FirestoreRestHelper.apiBase}/$documentPath',
      ).replace(queryParameters: <String, String>{
        'updateMask.fieldPaths': 'count',
        'currentDocument.updateTime': updateTime,
      });
      final updateResponse = await _client.patch(
        updateUri,
        headers: headers,
        body: jsonEncode({
          'fields': {
            'count': {'integerValue': '${currentCount + 1}'},
          },
        }),
      );
      if (updateResponse.statusCode == 200) return true;
      if (updateResponse.statusCode == 409 ||
          updateResponse.statusCode == 412) {
        continue;
      }
      throw _responseException('güncelleme', updateResponse);
    }

    throw const UsageServiceException(
      'Günlük kullanım sayacı eşzamanlı istekler nedeniyle güncellenemedi.',
    );
  }

  UsageServiceException _responseException(
    String operation,
    http.Response response,
  ) {
    return UsageServiceException(
      'Günlük kullanım sayacı $operation hatası '
      '(HTTP ${response.statusCode}).',
    );
  }
}
