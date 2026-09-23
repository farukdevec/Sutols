import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firestore_rest_helper.dart';

class _PersistenceHttpException implements Exception {
  const _PersistenceHttpException(this.statusCode);
  final int statusCode;
  bool get retryable => statusCode == 429 || statusCode >= 500;
  @override
  String toString() => 'Sunum kayıt isteği başarısız (HTTP $statusCode).';
}

/// A generated presentation and its quota charge are one atomic commit.
/// The caller allocates the ID once; retries never allocate another document.
class PresentationPersistenceService {
  PresentationPersistenceService({
    http.Client? client,
    Future<String> Function()? tokenProvider,
    DateTime Function()? now,
    this.requestTimeout = const Duration(seconds: 30),
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _tokenProvider = tokenProvider ?? FirestoreRestHelper.authToken,
        _now = now ?? DateTime.now;

  final http.Client _client;
  final bool _ownsClient;
  final Future<String> Function() _tokenProvider;
  final DateTime Function() _now;
  final Duration requestTimeout;
  static const _base = FirestoreRestHelper.apiBase;
  static const _documents = 'projects/sutols/databases/(default)/documents';

  void close() {
    if (_ownsClient) _client.close();
  }

  Future<Map<String, String>> _headers() async => {
        'Authorization': 'Bearer ${await _tokenProvider()}',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>?> _read(
      String path, Map<String, String> headers) async {
    final response = await _client
        .get(Uri.parse('$_base/$path'), headers: headers)
        .timeout(requestTimeout);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw _PersistenceHttpException(response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  int _count(Map<String, dynamic>? document) {
    if (document == null) return 0;
    final value = document['fields']?['count']?['integerValue'];
    final count = int.tryParse('$value');
    if (count == null || count < 0) {
      throw const FormatException('Günlük kullanım sayacı geçersiz.');
    }
    return count;
  }

  /// Advisory only: the authoritative check is repeated in the atomic save.
  Future<bool> hasQuota(String uid, int dailyLimit) async {
    final day = _now().toIso8601String().substring(0, 10);
    return _count(await _read('users/$uid/usage/$day', await _headers())) <
        dailyLimit;
  }

  Future<bool> save({
    required String uid,
    required int dailyLimit,
    required String presentationId,
    required List<Map<String, dynamic>> writes,
  }) async {
    final path = 'presentations/$presentationId';
    final parentName = '$_documents/$path';
    // Require the create-only parent in the same batch: its existence is our
    // durable receipt after a lost response. No updates/overwrites on retries.
    if (!writes.any((write) =>
        write['update']?['name'] == parentName &&
        write['update']?['fields']?['userId']?['stringValue'] == uid &&
        write['currentDocument']?['exists'] == false)) {
      throw ArgumentError(
          'Atomik kayıt, oluşturulacak sunum belgesini içermeli.');
    }
    final day = _now().toIso8601String().substring(0, 10);
    final usagePath = 'users/$uid/usage/$day';
    Object? lastError;
    for (var attempt = 0; attempt < 4; attempt++) {
      final headers = await _headers();
      try {
        final saved = await _read(path, headers);
        if (saved != null) {
          if (saved['fields']?['userId']?['stringValue'] != uid) {
            throw StateError('Sunum kimliği başka bir kullanıcıya ait.');
          }
          return true;
        }
        final usage = await _read(usagePath, headers);
        final count = _count(usage);
        if (count >= dailyLimit) {
          // A previous timed-out commit can complete between the two reads.
          final receipt = await _read(path, headers);
          return receipt?['fields']?['userId']?['stringValue'] == uid;
        }
        final version = usage?['updateTime'];
        if (usage != null && (version is! String || version.isEmpty)) {
          throw const FormatException('Günlük kullanım sürümü okunamadı.');
        }
        final response = await _client
            .post(
              Uri.parse('$_base:commit'),
              headers: headers,
              body: jsonEncode({
                'writes': [
                  ...writes,
                  {
                    'update': {
                      'name': '$_documents/$usagePath',
                      'fields': {
                        'uid': {'stringValue': uid},
                        'date': {'stringValue': day},
                        'count': {'integerValue': '${count + 1}'},
                      },
                    },
                    'currentDocument': usage == null
                        ? {'exists': false}
                        : {'updateTime': version},
                  },
                ],
              }),
            )
            .timeout(requestTimeout);
        if (response.statusCode == 200) return true;
        lastError =
            Exception('Sunum kaydedilemedi (HTTP ${response.statusCode}).');
        if (response.statusCode == 409 ||
            response.statusCode == 412 ||
            response.statusCode == 429 ||
            response.statusCode >= 500) {
          continue;
        }
        throw lastError;
      } on TimeoutException catch (error) {
        lastError = error;
      } on http.ClientException catch (error) {
        lastError = error;
      } on _PersistenceHttpException catch (error) {
        if (!error.retryable) rethrow;
        lastError = error;
      }
    }
    // One final receipt check, including a successful last commit whose
    // response was lost. Never refund or issue a new ID on an unknown outcome.
    try {
      final saved = await _read(path, await _headers());
      if (saved?['fields']?['userId']?['stringValue'] == uid) return true;
    } catch (_) {
      // Preserve the operation ID so an uncertain save can be investigated.
    }
    throw Exception(
        'Kayıt doğrulanamadı. Sunum kimliği: $presentationId. $lastError');
  }
}
