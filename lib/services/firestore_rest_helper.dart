import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Firestore REST API (v1) üzerinden erişim yardımcıları.
/// FlutterFire SDK'nın web'deki Int64 dartify hatasından kaçınmak için
/// tüm Firestore okumaları REST API ile yapılır.
class FirestoreRestHelper {
  static const String apiBase =
      'https://firestore.googleapis.com/v1/projects/sutols/databases/(default)/documents';

  static Future<String> authToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Lütfen önce giriş yapın.');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Kimlik doğrulama belirteci alınamadı.');
    }
    return token;
  }

  /// Tek bir dokümanı getirir (GET .../{path}); yoksa null döner.
  static Future<Map<String, dynamic>?> getDocument(String path) async {
    final token = await authToken();
    final response = await http.get(
      Uri.parse('$apiBase/$path'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 404) return null;

    if (response.statusCode != 200) {
      throw Exception(
          'Firestore okuma hatası (HTTP ${response.statusCode}): ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Bir koleksiyondaki TÜM dokümanları getirir (GET .../{collectionId}).
  /// REST API sayfa başına en fazla 100-300 doküman döndürür; nextPageToken
  /// takip edilerek sonuna kadar sayfalanır.
  static Future<List<Map<String, dynamic>>> listDocuments(
      String collectionId) async {
    final token = await authToken();
    final docs = <Map<String, dynamic>>[];
    String? pageToken;
    do {
      final uri = Uri.parse('$apiBase/$collectionId').replace(
        queryParameters: <String, String>{
          'pageSize': '300',
          if (pageToken != null) 'pageToken': pageToken,
        },
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Firestore okuma hatası (HTTP ${response.statusCode}): ${response.body}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      docs.addAll(
        (body['documents'] as List? ?? const []).cast<Map<String, dynamic>>(),
      );
      pageToken = body['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);
    return docs;
  }

  /// Yeni doküman oluşturur (POST .../{collectionId}?documentId={id}).
  /// Doküman zaten varsa HTTP 409 (ALREADY_EXISTS) döner.
  static Future<Map<String, dynamic>> createDocument(
    String collectionId,
    String documentId,
    Map<String, dynamic> fields,
  ) async {
    final token = await authToken();
    final uri = Uri.parse('$apiBase/$collectionId')
        .replace(queryParameters: {'documentId': documentId});
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fields': fields}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Firestore oluşturma hatası (HTTP ${response.statusCode}): ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Mevcut dokümanın belirtilen alanlarını günceller (PATCH .../{path}).
  /// updateMask zorunludur: hangi alanların yazılacağını listeler,
  /// listede olmayan alanlara dokunulmaz.
  static Future<Map<String, dynamic>> patchDocument(
    String path,
    Map<String, dynamic> fields, {
    required List<String> updateMask,
  }) async {
    final token = await authToken();
    final query = updateMask
        .map((f) => 'updateMask.fieldPaths=${Uri.encodeQueryComponent(f)}')
        .join('&');
    final uri = Uri.parse('$apiBase/$path').replace(query: query);
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fields': fields}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Firestore güncelleme hatası (HTTP ${response.statusCode}): ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Dokümanı siler (DELETE .../{path}).
  static Future<void> deleteDocument(String path) async {
    final token = await authToken();
    final response = await http.delete(
      Uri.parse('$apiBase/$path'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Firestore silme hatası (HTTP ${response.statusCode}): ${response.body}');
    }
  }

  /// REST API için geçerli RFC3339 UTC zaman damgası üretir.
  /// (Firestore REST, server timestamp sentinel desteklemez; timestampValue
  /// yalnızca "2014-10-02T15:01:23Z" formatını kabul eder.)
  static String nowTimestamp() => toFirestoreTimestamp(DateTime.now());

  /// structuredQuery çalıştırır (POST .../documents:runQuery).
  /// Sonucu doküman map listesi olarak döndürür.
  ///
  /// Alt koleksiyon sorgularında ("from" girdisindeki göreli `parent`,
  /// örn. "presentations/{id}") parent, tam kaynak adı olarak istek
  /// gövdesine taşınır; URL her zaman .../documents:runQuery olur.
  /// (REST API alt koleksiyon yolunu URL'de kabul etmez: .../presentations/
  /// {id}/slides:runQuery HTTP 400 INVALID_ARGUMENT "lacks /" hatası döner.)
  static Future<List<Map<String, dynamic>>> runQuery(
      Map<String, dynamic> structuredQuery) async {
    final token = await authToken();

    String? parent;
    final from = structuredQuery['from'] as List?;
    if (from != null) {
      for (final entry in from) {
        if (entry is Map<String, dynamic>) {
          final entryParent = entry.remove('parent') as String?;
          if (entryParent != null && entryParent.isNotEmpty) {
            parent = entryParent;
          }
        }
      }
    }

    final url = Uri.parse('$apiBase:runQuery');
    final body = parent == null
        ? {'structuredQuery': structuredQuery}
        : {
            'parent': '$apiBase/$parent',
            'structuredQuery': structuredQuery,
          };
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Firestore sorgu hatası (HTTP ${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as List;
    return decoded
        .whereType<Map<String, dynamic>>()
        .where((e) => e.containsKey('document'))
        .map((e) => e['document'] as Map<String, dynamic>)
        .toList();
  }

  static String stringField(Map<String, dynamic> fields, String key) {
    return fields[key]?['stringValue'] as String? ?? '';
  }

  static String integerField(Map<String, dynamic> fields, String key) {
    return fields[key]?['integerValue'] as String? ?? '';
  }

  static String timestampField(Map<String, dynamic> fields, String key) {
    return fields[key]?['timestampValue'] as String? ?? '';
  }

  static List<String> arrayField(Map<String, dynamic> fields, String key) {
    final values = fields[key]?['arrayValue']?['values'] as List? ?? const [];
    return values
        .map((v) => (v as Map<String, dynamic>)['stringValue'] as String? ?? '')
        .where((v) => v.isNotEmpty)
        .toList();
  }

  /// UTC DateTime'i Firestore REST API'nin kabul ettiği RFC3339 formatına
  /// (sonunda mutlaka 'Z' olacak şekilde) dönüştürür.
  static String toFirestoreTimestamp(DateTime dt) {
    final utc = dt.toUtc();
    final iso = utc.toIso8601String();
    return iso.endsWith('Z') ? iso : '${iso}Z';
  }
}
