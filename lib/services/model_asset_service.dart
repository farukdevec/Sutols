import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class _CachedSignedUrl {
  const _CachedSignedUrl({required this.url, required this.expiresAt});
  final String url;
  final DateTime expiresAt;
}

class ModelAssetService {
  ModelAssetService._();

  static const String _base = 'https://assets.sutols.com';
  static const String _thumbPrefix = 'thumbnails';
  static const String _authorizeEndpoint = 'https://assets.sutols.com/authorize';

  static final Map<String, _CachedSignedUrl> _signedUrlCache = <String, _CachedSignedUrl>{};
  static final Map<String, Future<String?>> _inFlightRequests = <String, Future<String?>>{};

  /// Clears in-memory signed URL cache.
  static void clearCache() {
    _signedUrlCache.clear();
    _inFlightRequests.clear();
  }

  /// Extract object key (e.g. "110_megafon.glb" or "thumbnails/110_megafon.webp")
  /// from a full URL, object path, or raw field.
  static String extractKey(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';

    try {
      final uri = Uri.tryParse(value);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
        var path = uri.path;
        path = path.replaceAll(RegExp(r'^/+'), '');
        return path;
      }
    } catch (_) {}

    final key = value.replaceAll(RegExp(r'^/+'), '');
    return key;
  }

  /// Normalize a stored model URL or object key into the canonical
  /// assets.sutols.com model URL.
  static String modelUrlFromField(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';

    try {
      final uri = Uri.tryParse(value);
      if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
        if (uri.host.toLowerCase().contains('assets.sutols.com')) {
          return value;
        }
        final fileName = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : uri.path.split('/').last;
        if (fileName.isEmpty) return '';
        return '$_base/$fileName';
      }
    } catch (_) {}

    final key = value.replaceAll(RegExp(r'^/+'), '');
    final fileName = key.split('/').last;
    return '$_base/$fileName';
  }

  /// Generate a signed URL via Cloudflare Worker authorize endpoint.
  /// The signed URL is valid for 5 minutes and includes HMAC-SHA256 signature.
  static Future<String?> generateSignedUrl(
    String rawKey, {
    String? idToken,
    bool forceRefresh = false,
  }) async {
    final trimmed = rawKey.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('sig=') && trimmed.contains('expires=')) {
      return trimmed;
    }

    final key = extractKey(trimmed);
    if (key.isEmpty) return null;

    if (!forceRefresh) {
      final cached = _signedUrlCache[key];
      if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
        print('[ASSET_AUTH] key=$key status=cached signed=true');
        return cached.url;
      }
    }

    final existingInFlight = _inFlightRequests[key];
    if (existingInFlight != null) {
      return existingInFlight;
    }

    final future = _fetchSignedUrl(key, idToken: idToken);
    _inFlightRequests[key] = future;
    try {
      final result = await future;
      return result;
    } finally {
      _inFlightRequests.remove(key);
    }
  }

  static Future<String?> _fetchSignedUrl(String key, {String? idToken}) async {
    try {
      final token = idToken ?? await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null || token.isEmpty) {
        print('[ASSET_AUTH] key=$key status=no_user_token signed=false');
        return null;
      }

      final response = await http.post(
        Uri.parse(_authorizeEndpoint),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'key': key,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>?;
        if (data != null) {
          final signedUrl = (data['url'] as String?) ?? (data['signedUrl'] as String?);
          if (signedUrl != null && signedUrl.isNotEmpty) {
            _signedUrlCache[key] = _CachedSignedUrl(
              url: signedUrl,
              expiresAt: DateTime.now().add(const Duration(minutes: 4, seconds: 15)),
            );
            print('[ASSET_AUTH] key=$key status=200 signed=true');
            return signedUrl;
          }
        }
      }
      print('[ASSET_AUTH] key=$key status=${response.statusCode} signed=false');
      return null;
    } catch (e) {
      print('[ASSET_AUTH] key=$key status=error signed=false');
      return null;
    }
  }

  /// Returns object key for thumbnail (e.g. "thumbnails/76_3B_Buyuyen_Bar_Grafigi.webp")
  static String thumbnailKey({String? thumbnailField, String? modelField, String? modelId}) {
    final thumb = (thumbnailField ?? '').trim();
    if (thumb.isNotEmpty) {
      return extractKey(thumb);
    }
    final m = (modelField ?? '').trim();
    if (m.isNotEmpty) {
      final key = extractKey(m);
      final fileName = key.split('/').last;
      final thumbName = fileName.replaceAll(RegExp(r'\.glb$', caseSensitive: false), '.webp');
      return '$_thumbPrefix/$thumbName';
    }
    final id = (modelId ?? '').trim();
    if (id.isNotEmpty) {
      final cleanId = id.replaceAll(RegExp(r'\.glb$', caseSensitive: false), '');
      return '$_thumbPrefix/$cleanId.webp';
    }
    return '';
  }

  /// Signed URL ile model erişimi için full URL oluştur.
  static String? buildModelUrl(String? signedUrl) {
    if (signedUrl != null && signedUrl.isNotEmpty && signedUrl.contains('token=')) {
      return signedUrl;
    }
    return null;
  }



  /// Thumbnail URL oluştur.
  static String thumbnailUrl({String? thumbnailField, String? modelField, String? modelId}) {
    final thumb = (thumbnailField ?? '').trim();
    if (thumb.isNotEmpty) {
      try {
        final uri = Uri.tryParse(thumb);
        if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
          if (uri.host.toLowerCase().contains('assets.sutols.com')) return thumb;
          final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : uri.path.split('/').last;
          return '$_base/$_thumbPrefix/$fileName';
        }
      } catch (_) {}
      final fileName = thumb.split('/').last;
      return '$_base/$_thumbPrefix/$fileName';
    }

    final m = (modelField ?? '').trim();
    if (m.isNotEmpty) {
      try {
        final uri = Uri.tryParse(m);
        if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
          final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : uri.path.split('/').last;
          final thumbName = fileName.replaceAll(RegExp(r'\.glb', caseSensitive: false), '.webp');
          return '$_base/$_thumbPrefix/$thumbName';
        }
      } catch (_) {}
      final fileName = m.split('/').last;
      final thumbName = fileName.replaceAll(RegExp(r'\.glb', caseSensitive: false), '.webp');
      return '$_base/$_thumbPrefix/$thumbName';
    }

    final id = (modelId ?? '').trim();
    if (id.isNotEmpty) return '$_base/$_thumbPrefix/$id.webp';

    return '';
  }

  /// GLB indirme ve erişim işlemini Firestore glb_downloads koleksiyonuna kaydeder.
  static Future<void> logDownloadEvent(String rawKey, {String source = 'web'}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final key = extractKey(rawKey);
      if (key.isEmpty || !key.toLowerCase().endsWith('.glb')) return;

      final now = DateTime.now().toUtc().toIso8601String();
      final firestoreUrl =
          'https://firestore.googleapis.com/v1/projects/sutols/databases/(default)/documents/glb_downloads';
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      await http.post(
        Uri.parse(firestoreUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fields': {
            'userId': {'stringValue': user.uid},
            'userEmail': {'stringValue': user.email ?? ''},
            'displayName': {'stringValue': user.displayName ?? ''},
            'modelKey': {'stringValue': key},
            'downloadedAt': {'timestampValue': now.endsWith('Z') ? now : '${now}Z'},
            'source': {'stringValue': source},
          }
        }),
      );
    } catch (_) {
      // Modellerin çalışmasını aksatmaması için hata yutulur
    }
  }
}


