import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_rest_helper.dart';

class PresentationRetentionService {
  PresentationRetentionService({FirebaseFirestore? db}) : _customDb = db;

  final FirebaseFirestore? _customDb;
  // ignore: unused_element
  FirebaseFirestore get _db => _customDb ?? FirebaseFirestore.instance;

  int limitForTier(String tier) {
    switch (tier.trim().toLowerCase()) {
      case 'premium':
        return 200;
      case 'plus':
      case 'pro':
        return 25;
      default:
        return 10;
    }
  }

  Future<void> enforceLimit(String userId, String tier) async {
    final limit = limitForTier(tier);

    // presentations koleksiyonundan bu kullanıcının TÜM sunumlarını
    // .where/.orderBy KULLANMADAN çek (Int64 riski), Dart tarafında
    // createdAt'e göre sırala (REST helper üzerinden)
    final documents = await FirestoreRestHelper.runQuery({
      'from': [
        {'collectionId': 'presentations'},
      ],
      'where': {
        'fieldFilter': {
          'field': {'fieldPath': 'userId'},
          'op': 'EQUAL',
          'value': {'stringValue': userId},
        },
      },
    });

    if (documents.length <= limit) return;

    // Dart tarafında createdAt'e göre yeniden eskiye (azalan) sırala
    documents.sort((a, b) {
      final aFields = a['fields'] as Map<String, dynamic>? ?? const {};
      final bFields = b['fields'] as Map<String, dynamic>? ?? const {};
      final aTime = FirestoreRestHelper.timestampField(aFields, 'createdAt');
      final bTime = FirestoreRestHelper.timestampField(bFields, 'createdAt');
      final aDate =
          DateTime.tryParse(aTime) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          DateTime.tryParse(bTime) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    // Sıralı listede limit'i aşan (en eski) sunumları bul
    final excessDocs = documents.skip(limit);

    for (final document in excessDocs) {
      final presentationId =
          (document['name'] as String? ?? '').split('/').last;
      if (presentationId.isEmpty) continue;
      await _deletePresentationTree(presentationId);
    }
  }

  Future<void> _deletePresentationTree(String presentationId) async {
    // 1. presentations/{id}/project/data alt dokümanını sil
    try {
      await FirestoreRestHelper.deleteDocument(
        'presentations/$presentationId/project/data',
      );
    } catch (_) {}

    // 2. presentations/{id}/slides/* alt dokümanlarını sil
    try {
      final slides = await FirestoreRestHelper.runQuery({
        'from': [
          {
            'collectionId': 'slides',
            'parent': 'presentations/$presentationId',
          },
        ],
      });
      for (final slide in slides) {
        final slideId = (slide['name'] as String? ?? '').split('/').last;
        if (slideId.isNotEmpty) {
          try {
            await FirestoreRestHelper.deleteDocument(
              'presentations/$presentationId/slides/$slideId',
            );
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 3. presentations/{id} ana dokümanını sil
    try {
      await FirestoreRestHelper.deleteDocument('presentations/$presentationId');
    } catch (_) {}
  }
}
