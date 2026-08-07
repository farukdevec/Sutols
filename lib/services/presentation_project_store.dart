import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_rest_helper.dart';

/// Editör deck durumunun (deck JSON) `presentations/{id}/project` dokümanında
/// saklanması ve yüklenmesi. REST API ile çalışır (Int64 dartify hatası yok).
class PresentationProjectStore {
  static const String _projectDocId = 'data';

  /// Proje dokümanını getirir; yoksa null döner.
  /// Dönen map: `json` (deck JSON), `updatedAt`, `updatedByName`, ...
  static Future<Map<String, dynamic>?> loadProject(String presentationId) async {
    final doc = await FirestoreRestHelper.getDocument(
      'presentations/$presentationId/project/$_projectDocId',
    );
    if (doc == null) return null;

    final fields = doc['fields'] as Map<String, dynamic>? ?? {};
    return {
      'json': FirestoreRestHelper.stringField(fields, 'json'),
      'updatedAt': FirestoreRestHelper.timestampField(fields, 'updatedAt'),
      'updatedByUid': FirestoreRestHelper.stringField(fields, 'updatedByUid'),
      'updatedByName': FirestoreRestHelper.stringField(fields, 'updatedByName'),
      'updatedByEmail': FirestoreRestHelper.stringField(fields, 'updatedByEmail'),
    };
  }

  /// Deck JSON'u sunumun proje dokümanına yazar (yoksa oluşturur).
  /// Kaydedenin kimliği (uid/ad/e-posta) dokümana imza olarak eklenir.
  static Future<void> saveProject({
    required String presentationId,
    required String json,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Lütfen önce giriş yapın.');
    }

    final name = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName!.trim()
        : (user.email ?? '');
    final fields = <String, dynamic>{
      'json': {'stringValue': json},
      'updatedAt': {'timestampValue': FirestoreRestHelper.nowTimestamp()},
      'updatedByUid': {'stringValue': user.uid},
      'updatedByName': {'stringValue': name},
      'updatedByEmail': {'stringValue': user.email ?? ''},
    };

    final path = 'presentations/$presentationId/project/$_projectDocId';
    final existing = await FirestoreRestHelper.getDocument(path);
    if (existing == null) {
      await FirestoreRestHelper.createDocument(
        'presentations/$presentationId/project',
        _projectDocId,
        fields,
      );
    } else {
      await FirestoreRestHelper.patchDocument(
        path,
        fields,
        updateMask: const [
          'json',
          'updatedAt',
          'updatedByUid',
          'updatedByName',
          'updatedByEmail',
        ],
      );
    }
  }

  /// Paylaşım bayrağını günceller (sahip işlemi).
  static Future<void> setShared(String presentationId, bool shared) async {
    await FirestoreRestHelper.patchDocument(
      'presentations/$presentationId',
      {'shared': {'booleanValue': shared}},
      updateMask: const ['shared'],
    );
  }
}
