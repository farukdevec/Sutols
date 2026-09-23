import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/presentation_persistence_service.dart';

const _uid = 'user-1';
const _presentationId = 'presentation-123';
const _day = '2026-08-13';
const _base =
    'https://firestore.googleapis.com/v1/projects/sutols/databases/(default)/documents';
const _documents = 'projects/sutols/databases/(default)/documents';

final _fixedNow = DateTime(2026, 8, 13, 10);

PresentationPersistenceService serviceWith(MockClient client) =>
    PresentationPersistenceService(
      client: client,
      tokenProvider: () async => 'test-token',
      now: () => _fixedNow,
      requestTimeout: const Duration(milliseconds: 100),
    );

Map<String, dynamic> usage({int count = 0, String version = 'v1'}) => {
      'fields': {
        'count': {'integerValue': '$count'},
      },
      'updateTime': version,
    };

Map<String, dynamic> savedPresentation() => {
      'fields': {
        'userId': {'stringValue': _uid},
      },
    };

List<Map<String, dynamic>> writes() => [
      {
        'update': {
          'name': '$_documents/presentations/$_presentationId',
          'fields': {
            'userId': {'stringValue': _uid},
          },
        },
        'currentDocument': {'exists': false},
      },
      {
        'update': {
          'name': '$_documents/presentations/$_presentationId/slides/slide-1',
          'fields': {
            'text': {'stringValue': 'Hello'},
          },
        },
        'currentDocument': {'exists': false},
      },
      {
        'update': {
          'name': '$_documents/presentations/$_presentationId/project/data',
          'fields': {
            'presentationId': {'stringValue': _presentationId},
          },
        },
        'currentDocument': {'exists': false},
      },
    ];

Future<bool> saveWith(MockClient client, {int limit = 5}) =>
    serviceWith(client).save(
      uid: _uid,
      dailyLimit: limit,
      presentationId: _presentationId,
      writes: writes(),
    );

void main() {
  test(
      'quota precheck never charges or writes, even when generation is abandoned',
      () async {
    for (final count in [0, 4, 5]) {
      var reads = 0;
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        reads++;
        return count == 0
            ? http.Response('', 404)
            : http.Response(jsonEncode(usage(count: count)), 200);
      });
      expect(await serviceWith(client).hasQuota(_uid, 5), count < 5);
      expect(reads, 1);
    }
  });

  test(
      'preflight rejects a batch without a create-only parent and writes nothing',
      () async {
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response('{}', 200);
    });

    await expectLater(
      () => serviceWith(client).save(
        uid: _uid,
        dailyLimit: 5,
        presentationId: _presentationId,
        writes: writes().sublist(1),
      ),
      throwsArgumentError,
    );
    expect(requests, 0);
  });

  test('exhausted quota does not commit', () async {
    var commits = 0;
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        commits++;
        return http.Response('{}', 200);
      }
      if (request.url.path.endsWith('/presentations/$_presentationId')) {
        return http.Response('', 404);
      }
      return http.Response(jsonEncode(usage(count: 5)), 200);
    });

    final result = await saveWith(client, limit: 5);
    expect(result, isFalse);
    expect(commits, 0);
  });

  test('one atomic commit contains parent, slides, project, and quota with CAS',
      () async {
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/presentations/$_presentationId')) {
          return http.Response('', 404);
        }
        return http.Response(jsonEncode(usage()), 200);
      }
      expect(request.url.toString(), '$_base:commit');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final batch = (body['writes'] as List).cast<Map<String, dynamic>>();
      expect(batch, hasLength(4));
      expect(
          batch.take(3).map((w) => w['update']['name']),
          containsAll([
            '$_documents/presentations/$_presentationId',
            '$_documents/presentations/$_presentationId/slides/slide-1',
            '$_documents/presentations/$_presentationId/project/data',
          ]));
      expect(
          batch.last['update']['name'], '$_documents/users/$_uid/usage/$_day');
      expect(batch.last['update']['fields']['count']['integerValue'], '1');
      expect(batch.last['currentDocument']['updateTime'], 'v1');
      return http.Response('{}', 200);
    });

    expect(await saveWith(client), isTrue);
  });

  test('CAS conflict rereads the updated counter before retrying', () async {
    var usageReads = 0;
    var commits = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/presentations/$_presentationId')) {
          return http.Response('', 404);
        }
        usageReads++;
        return http.Response(
            jsonEncode(usage(count: usageReads - 1, version: 'v$usageReads')),
            200);
      }
      commits++;
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final quota = (body['writes'] as List).last as Map<String, dynamic>;
      expect(quota['update']['fields']['count']['integerValue'],
          commits == 1 ? '1' : '2');
      expect(
          quota['currentDocument']['updateTime'], commits == 1 ? 'v1' : 'v2');
      return http.Response('', commits == 1 ? 409 : 200);
    });

    expect(await saveWith(client), isTrue);
    expect(commits, 2);
    expect(usageReads, 2);
  });

  test('lost response is recovered by the receipt and charges once', () async {
    var commits = 0;
    var receiptReads = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/presentations/$_presentationId')) {
          receiptReads++;
          return receiptReads == 1
              ? http.Response('', 404)
              : http.Response(jsonEncode(savedPresentation()), 200);
        }
        return http.Response(jsonEncode(usage()), 200);
      }
      commits++;
      expect(commits, 1);
      return throw http.ClientException('response lost');
    });

    expect(await saveWith(client), isTrue);
    expect(commits, 1);
    expect(receiptReads, 2);
  });

  test('transient failures retry the same presentation ID', () async {
    final commitBodies = <String>[];
    var commits = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/presentations/$_presentationId')) {
          return http.Response('', 404);
        }
        return http.Response(jsonEncode(usage()), 200);
      }
      commitBodies.add(request.body);
      commits++;
      return http.Response('', commits == 1 ? 500 : 200);
    });

    expect(await saveWith(client), isTrue);
    expect(commits, 2);
    expect(commitBodies[0], commitBodies[1]);
  });

  test('transient read failures retry before committing', () async {
    var parentReads = 0;
    var commits = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/presentations/$_presentationId')) {
          parentReads++;
          return parentReads == 1
              ? http.Response('temporary failure', 500)
              : http.Response('', 404);
        }
        return http.Response(jsonEncode(usage()), 200);
      }
      commits++;
      return http.Response('{}', 200);
    });

    expect(await saveWith(client), isTrue);
    expect(parentReads, 2);
    expect(commits, 1);
  });

  test('definitive 403 is not retried', () async {
    var commits = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/presentations/$_presentationId')) {
          return http.Response('', 404);
        }
        return http.Response(jsonEncode(usage()), 200);
      }
      commits++;
      return http.Response('forbidden', 403);
    });

    await expectLater(saveWith(client), throwsA(isA<Exception>()));
    expect(commits, 1);
  });

  test('all unknown retries fail with the operation ID', () async {
    var commits = 0;
    var receiptReads = 0;
    final client = MockClient((request) async {
      if (request.method == 'GET') {
        if (request.url.path.endsWith('/presentations/$_presentationId')) {
          receiptReads++;
          return http.Response('', 404);
        }
        return http.Response(jsonEncode(usage()), 200);
      }
      commits++;
      return http.Response('server error', 500);
    });

    await expectLater(
      saveWith(client),
      throwsA(predicate(
          (error) => '$error'.contains(_presentationId) && commits == 4)),
    );
    expect(receiptReads, 5);
  });

  test('existing saved receipt succeeds even when quota is exhausted',
      () async {
    var commits = 0;
    var usageReads = 0;
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        commits++;
        return http.Response('{}', 200);
      }
      if (request.url.path.endsWith('/presentations/$_presentationId')) {
        return http.Response(jsonEncode(savedPresentation()), 200);
      }
      usageReads++;
      return http.Response(jsonEncode(usage(count: 5)), 200);
    });

    expect(await saveWith(client), isTrue);
    expect(commits, 0);
    expect(usageReads, 0);
  });

  test('malformed usage fails safe without committing', () async {
    var commits = 0;
    final client = MockClient((request) async {
      if (request.method == 'POST') commits++;
      if (request.url.path.endsWith('/presentations/$_presentationId')) {
        return http.Response('', 404);
      }
      return http.Response(
          jsonEncode({
            'fields': {
              'count': {'integerValue': 'not-a-number'},
            },
            'updateTime': 'v1',
          }),
          200);
    });

    await expectLater(saveWith(client), throwsA(isA<FormatException>()));
    expect(commits, 0);
  });
}
