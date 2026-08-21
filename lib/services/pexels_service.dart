import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'remote_image_sources.dart';

/// Pexels API görsel kaynak URL'leri.
@immutable
class PexelsPhotoSrc {
  const PexelsPhotoSrc({
    this.original = '',
    this.large2x = '',
    this.large = '',
    this.medium = '',
    this.small = '',
    this.portrait = '',
    this.landscape = '',
    this.tiny = '',
  });

  factory PexelsPhotoSrc.fromJson(Map<String, dynamic> json) {
    return PexelsPhotoSrc(
      original: json['original'] as String? ?? '',
      large2x: json['large2x'] as String? ?? '',
      large: json['large'] as String? ?? '',
      medium: json['medium'] as String? ?? '',
      small: json['small'] as String? ?? '',
      portrait: json['portrait'] as String? ?? '',
      landscape: json['landscape'] as String? ?? '',
      tiny: json['tiny'] as String? ?? '',
    );
  }

  final String original;
  final String large2x;
  final String large;
  final String medium;
  final String small;
  final String portrait;
  final String landscape;
  final String tiny;

  Map<String, dynamic> toJson() => {
        'original': original,
        'large2x': large2x,
        'large': large,
        'medium': medium,
        'small': small,
        'portrait': portrait,
        'landscape': landscape,
        'tiny': tiny,
      };
}

/// Pexels Fotoğraf Nesnesi.
@immutable
class PexelsPhoto {
  const PexelsPhoto({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.photographer,
    required this.photographerUrl,
    required this.photographerId,
    required this.avgColor,
    required this.src,
    required this.alt,
  });

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) {
    return PexelsPhoto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 1920,
      height: (json['height'] as num?)?.toInt() ?? 1080,
      url: json['url'] as String? ?? 'https://www.pexels.com',
      photographer: json['photographer'] as String? ?? 'Pexels Photographer',
      photographerUrl: json['photographer_url'] as String? ??
          'https://www.pexels.com',
      photographerId: (json['photographer_id'] as num?)?.toInt() ?? 0,
      avgColor: json['avg_color'] as String? ?? '#202020',
      src: json['src'] is Map<String, dynamic>
          ? PexelsPhotoSrc.fromJson(json['src'] as Map<String, dynamic>)
          : const PexelsPhotoSrc(),
      alt: json['alt'] as String? ?? 'Pexels Fotoğrafı',
    );
  }

  final int id;
  final int width;
  final int height;
  final String url;
  final String photographer;
  final String photographerUrl;
  final int photographerId;
  final String avgColor;
  final PexelsPhotoSrc src;
  final String alt;

  /// Sutols sahnesinde ve kayıt defterinde kullanılan benzersiz kimlik.
  String get sourceId => 'pexels-$id';

  /// Fotoğrafın gerçek en/boy oranı.
  double get aspectRatio =>
      width > 0 && height > 0 ? width / height : 16 / 9;

  /// Sahnede ve önizlemede kullanılacak en uygun yüksek çözünürlüklü URL.
  String get bestDisplayUrl {
    if (src.large2x.isNotEmpty) return src.large2x;
    if (src.large.isNotEmpty) return src.large;
    if (src.medium.isNotEmpty) return src.medium;
    if (src.original.isNotEmpty) return src.original;
    return src.small;
  }

  /// Liste görünümünde kullanılacak hafif önizleme URL'si.
  String get thumbnailDisplayUrl {
    if (src.medium.isNotEmpty) return src.medium;
    if (src.small.isNotEmpty) return src.small;
    if (src.tiny.isNotEmpty) return src.tiny;
    return bestDisplayUrl;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'width': width,
        'height': height,
        'url': url,
        'photographer': photographer,
        'photographer_url': photographerUrl,
        'photographer_id': photographerId,
        'avg_color': avgColor,
        'src': src.toJson(),
        'alt': alt,
      };
}

/// Arama veya Keşfet sonuç kümesi.
@immutable
class PexelsSearchResult {
  const PexelsSearchResult({
    required this.photos,
    required this.page,
    required this.perPage,
    required this.totalResults,
    this.nextPage,
  });

  factory PexelsSearchResult.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];
    final photosList = <PexelsPhoto>[];
    if (rawPhotos is List) {
      for (final item in rawPhotos) {
        if (item is Map<String, dynamic>) {
          photosList.add(PexelsPhoto.fromJson(item));
        }
      }
    }

    return PexelsSearchResult(
      photos: List<PexelsPhoto>.unmodifiable(photosList),
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
      totalResults: (json['total_results'] as num?)?.toInt() ?? photosList.length,
      nextPage: json['next_page'] as String?,
    );
  }

  final List<PexelsPhoto> photos;
  final int page;
  final int perPage;
  final int totalResults;
  final String? nextPage;
}

/// Pexels API istemci servisi.
///
/// Tüm istekler Cloudflare Worker proxy'si üzerinden ve kullanıcının
/// Firebase ID Token'ı ile yetkilendirilerek gerçekleştirilir.
/// Hata veya rate-limit (429) durumlarında exception fırlatmaz, sessizce null döner.
class PexelsService {
  PexelsService({String? proxyUrl})
      : _proxyUrl = _cleanProxyUrl(proxyUrl ?? defaultProxyUrl);

  static const String defaultProxyUrl = 'https://sutols.online/';

  final String _proxyUrl;

  static String _cleanProxyUrl(String url) {
    var clean = url.trim();
    if (!clean.endsWith('/')) {
      clean = '$clean/';
    }
    return clean;
  }

  static Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      developer.log('[PexelsService] Failed to get Firebase ID token: $e');
      return null;
    }
  }

  /// Pexels üzerinden anahtar kelime ile fotoğraf arar.
  ///
  /// Hata veya kota aşımı (429) durumunda exception fırlatmaz, null döner.
  Future<PexelsSearchResult?> searchPhotos(
    String query, {
    int perPage = 15,
    int page = 1,
    String orientation = 'landscape',
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return null;

    try {
      final idToken = await _getAuthToken();
      if (idToken == null) {
        developer.log('[PexelsService] User not logged in, search aborted');
        return null;
      }

      final uri = Uri.parse('${_proxyUrl}pexels/search').replace(
        queryParameters: {
          'query': cleanQuery,
          'per_page': perPage.toString(),
          'page': page.toString(),
          'orientation': orientation,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return PexelsSearchResult.fromJson(data);
        }
      } else {
        developer.log(
          '[PexelsService] searchPhotos failed with status=${response.statusCode}: ${response.body}',
        );
      }
      return null;
    } catch (e) {
      developer.log('[PexelsService] searchPhotos exception: $e');
      return null;
    }
  }

  /// Pexels üzerinden öne çıkan/küratörlü fotoğrafları getirir.
  Future<PexelsSearchResult?> getCuratedPhotos({
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final idToken = await _getAuthToken();
      if (idToken == null) return null;

      final uri = Uri.parse('${_proxyUrl}pexels/curated').replace(
        queryParameters: {
          'per_page': perPage.toString(),
          'page': page.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return PexelsSearchResult.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      developer.log('[PexelsService] getCuratedPhotos exception: $e');
      return null;
    }
  }

  /// Slayt konusu, başlığı ve anahtar kelimelerine göre Pexels'ten en uygun
  /// yatay görseli otomatik bulur ve [RemoteImageSources]'a kaydeder.
  ///
  /// Herhangi bir hata, 429 veya arama sonucunun boş olması durumunda
  /// sessizce `null` döner; sunum üretim sürecini ASLA kesintiye uğratmaz.
  Future<PexelsPhoto?> matchPhotoForSlide({
    required List<String> keywords,
    required String title,
    String? topic,
  }) async {
    try {
      final candidates = _buildSearchTerms(
        keywords: keywords,
        title: title,
        topic: topic,
      );

      if (candidates.isEmpty) return null;

      for (final term in candidates) {
        final result = await searchPhotos(
          term,
          perPage: 5,
          page: 1,
          orientation: 'landscape',
        );

        if (result != null && result.photos.isNotEmpty) {
          final chosen = result.photos.first;
          // Slayt sahnesinin görseli hemen gösterebilmesi için kaydedelim
          RemoteImageSources.register(
            chosen.sourceId,
            chosen.bestDisplayUrl,
          );
          return chosen;
        }
      }
      return null;
    } catch (e) {
      developer.log('[PexelsService] matchPhotoForSlide safe fallback: $e');
      return null;
    }
  }

  /// Slayt bilgilerinden arama adayı terimleri sıralı olarak üretir.
  List<String> _buildSearchTerms({
    required List<String> keywords,
    required String title,
    String? topic,
  }) {
    final terms = <String>[];

    // 1. Doğrudan somut anahtar kelimeler
    for (final kw in keywords) {
      final clean = _cleanKeyword(kw);
      if (clean.isNotEmpty && !terms.contains(clean)) {
        terms.add(clean);
      }
    }

    // 2. Başlıktaki anlamlı sözcükler
    final titleWords = title
        .split(RegExp(r'\s+'))
        .map(_cleanKeyword)
        .where((w) => w.length >= 3 && !_isStopWord(w))
        .toList();
    if (titleWords.isNotEmpty) {
      final combined = titleWords.take(2).join(' ');
      if (!terms.contains(combined)) {
        terms.add(combined);
      }
    }

    // 3. Genel konu
    if (topic != null && topic.trim().isNotEmpty) {
      final cleanTopic = _cleanKeyword(topic);
      if (cleanTopic.isNotEmpty && !terms.contains(cleanTopic)) {
        terms.add(cleanTopic);
      }
    }

    return terms;
  }

  static String _cleanKeyword(String kw) {
    return kw
        .replaceAll(RegExp(r'[^\w\s\u00C0-\u017F]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isStopWord(String word) {
    final lower = word.toLowerCase();
    const stopWords = <String>{
      've', 'veya', 'ile', 'için', 'bir', 'bu', 'şu', 'giriş', 'sonuç',
      'özet', 'hakkında', 'nedir', 'nasıl', 'neden', 'genel', 'bakış',
      'önemli', 'temel', 'slayt', 'sunum', 'the', 'and', 'for', 'about'
    };
    return stopWords.contains(lower);
  }
}
