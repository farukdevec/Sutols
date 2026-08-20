import 'firestore_rest_helper.dart';

/// Keeps only the newest presentations allowed by the user's plan.
class PresentationRetentionService {
  PresentationRetentionService._();

  static const int freeLimit = 3;
  static const int plusLimit = 15;

  static int limitForTier(String tier) {
    final normalized = tier.trim().toLowerCase();
    return normalized == 'plus' ||
            normalized == 'pro' ||
            normalized == 'premium'
        ? plusLimit
        : freeLimit;
  }

  static Future<void> enforceForUser({
    required String userId,
    required String tier,
  }) async {
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
      'orderBy': [
        {
          'field': {'fieldPath': 'createdAt'},
          'direction': 'DESCENDING',
        },
      ],
    });

    final limit = limitForTier(tier);
    if (documents.length <= limit) return;

    for (final document in documents.skip(limit)) {
      final presentationId =
          (document['name'] as String? ?? '').split('/').last;
      if (presentationId.isEmpty) continue;
      await _deletePresentationTree(presentationId);
    }
  }

  static Future<void> _deletePresentationTree(String presentationId) async {
    for (final collectionId in const <String>['slides', 'project']) {
      final children = await FirestoreRestHelper.runQuery({
        'from': [
          {
            'collectionId': collectionId,
            'parent': 'presentations/$presentationId',
          },
        ],
      });
      for (final child in children) {
        final childId = (child['name'] as String? ?? '').split('/').last;
        if (childId.isNotEmpty) {
          await FirestoreRestHelper.deleteDocument(
            'presentations/$presentationId/$collectionId/$childId',
          );
        }
      }
    }

    await FirestoreRestHelper.deleteDocument('presentations/$presentationId');
  }
}
