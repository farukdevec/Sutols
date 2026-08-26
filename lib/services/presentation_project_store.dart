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
    String? presentationName,
    int? slideCount,
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

    final cleanName = presentationName?.trim();
    if ((cleanName != null && cleanName.isNotEmpty) || slideCount != null) {
      final metadataFields = <String, dynamic>{
        if (cleanName != null && cleanName.isNotEmpty) ...{
          'topic': {'stringValue': cleanName},
          'title': {'stringValue': cleanName},
        },
        if (slideCount != null)
          'slideCount': {'integerValue': '${slideCount.clamp(0, 9999)}'},
        'updatedAt': {'timestampValue': FirestoreRestHelper.nowTimestamp()},
      };
      await FirestoreRestHelper.patchDocument(
        'presentations/$presentationId',
        metadataFields,
        updateMask: <String>[
          if (cleanName != null && cleanName.isNotEmpty) 'topic',
          if (cleanName != null && cleanName.isNotEmpty) 'title',
          if (slideCount != null) 'slideCount',
          'updatedAt',
        ],
      );
    }
  }

  /// Sunumun listelerde ve editör başlığında görünen adını
  /// günceller. Sunum kimliği değişmediği için aynı adı kullanan
  /// başka bir sunum bulunması kaydı engellemez.
  static Future<void> updatePresentationName({
    required String presentationId,
    required String name,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Sunum adı boş olamaz.');
    }
    await FirestoreRestHelper.patchDocument(
      'presentations/$presentationId',
      {
        'topic': {'stringValue': cleanName},
        'title': {'stringValue': cleanName},
        'updatedAt': {'timestampValue': FirestoreRestHelper.nowTimestamp()},
      },
      updateMask: const ['topic', 'title', 'updatedAt'],
    );
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
