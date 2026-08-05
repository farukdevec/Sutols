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

  /// Bir koleksiyondaki tüm dokümanları getirir (GET .../{collectionId}).
  static Future<List<Map<String, dynamic>>> listDocuments(
      String collectionId) async {
    final token = await authToken();
    final response = await http.get(
      Uri.parse('$apiBase/$collectionId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Firestore okuma hatası (HTTP ${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['documents'] as List? ?? const []).cast<Map<String, dynamic>>();
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
    final uri = Uri.parse('$apiBase/$path')
        .replace(queryParameters: {'updateMask.fieldPaths': updateMask.join(',')});
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

  /// REST API için geçerli RFC3339 UTC zaman damgası üretir.
  /// (Firestore REST, server timestamp sentinel desteklemez; timestampValue
  /// yalnızca "2014-10-02T15:01:23Z" formatını kabul eder.)
  static String nowTimestamp() => DateTime.now().toUtc().toIso8601String();

  /// structuredQuery çalıştırır (POST .../documents:runQuery).
  /// Sonucu doküman map listesi olarak döndürür.
  static Future<List<Map<String, dynamic>>> runQuery(
      Map<String, dynamic> structuredQuery) async {
    final token = await authToken();
    final response = await http.post(
      Uri.parse('$apiBase:runQuery'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'structuredQuery': structuredQuery}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Firestore sorgu hatası (HTTP ${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body) as List;
    return body
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
}
