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
    this.searchTerm,
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
  /// Seçimin hangi sorgudan geldiği; üretim logunda gerçek eşleşmeyi
  /// inceleyebilmek için yanıt nesnesiyle taşınır.
  final String? searchTerm;

  PexelsPhoto withSearchTerm(String value) => PexelsPhoto(
        id: id,
        width: width,
        height: height,
        url: url,
        photographer: photographer,
        photographerUrl: photographerUrl,
        photographerId: photographerId,
        avgColor: avgColor,
        src: src,
        alt: alt,
        searchTerm: value,
      );

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
    String? subject,
    List<String> mustInclude = const <String>[],
    List<String> mustAvoid = const <String>[],
    Set<int> excludedPhotoIds = const <int>{},
  }) async {
    try {
      final candidates = _buildSearchTerms(
        keywords: keywords,
        title: title,
        topic: topic,
        subject: subject,
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
          final chosen = _chooseProfessionalLandscape(
            result.photos,
            excludedPhotoIds: excludedPhotoIds,
            // Sonuç metadatası çoğunlukla İngilizce olduğundan, seçimi
            // kullanıcının Türkçe yönergesiyle değil gerçekten çağrılan sorgu
            // ile doğrula. Böylece "çevre" aramasından gelen rastgele sazlık
            // fotoğrafı teknik bir soğutma slaydına yerleşmez.
            subject: term,
            mustInclude: mustInclude,
            mustAvoid: mustAvoid,
          );
          if (chosen == null) continue;
          developer.log(
            '[PexelsService] selected id=${chosen.id} term="$term" '
            'subject="$subject"',
          );
          // Slayt sahnesinin görseli hemen gösterebilmesi için kaydedelim
          RemoteImageSources.register(
            chosen.sourceId,
            chosen.bestDisplayUrl,
          );
          return chosen.withSearchTerm(term);
        }
      }
      developer.log(
        '[PexelsService] no suitable photo; subject="$subject" '
        'keywords=${keywords.join(',')}',
      );
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
    String? subject,
  }) {
    final terms = <String>[];

    // Pexels'in indeks dili ağırlıkla İngilizce. Yaygın teknik Türkçe
    // kavramlarda doğrudan alan karşılığını ilk sorgu yaparak arama kalitesini
    // yükselt; özgün konu/başlık sorguları yine aşağıdaki sırada korunur.
    for (final alias in _englishSearchAliases('$subject $title $topic')) {
      if (!terms.contains(alias)) terms.add(alias);
    }

    // Modelin kurduğu somut görsel cümlesi, tekil anahtar kelimelerden daha
    // iyi Pexels sonucu verir. Örn. "solar panels on a factory roof".
    final cleanSubject = _cleanKeyword(subject ?? '');
    if (cleanSubject.isNotEmpty) terms.add(cleanSubject);

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

  static List<String> _englishSearchAliases(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
    final aliases = <String>[];
    void addWhen(bool condition, String alias) {
      if (condition && !aliases.contains(alias)) aliases.add(alias);
    }
    addWhen(normalized.contains('sogutucu akiskan'), 'refrigerant');
    addWhen(normalized.contains('sogutma dongu'), 'refrigeration cycle');
    addWhen(normalized.contains('buharlasma'), 'evaporation cooling');
    addWhen(normalized.contains('yogunlasma'), 'condenser refrigeration');
    addWhen(normalized.contains('enerji verimlil'), 'energy efficient cooling');
    addWhen(normalized.contains('cevre'), 'sustainable refrigeration');
    addWhen(normalized.contains('sogutma'), 'refrigeration system');
    return aliases;
  }

  static PexelsPhoto? _chooseProfessionalLandscape(
    List<PexelsPhoto> photos, {
    required Set<int> excludedPhotoIds,
    String? subject,
    List<String> mustInclude = const <String>[],
    List<String> mustAvoid = const <String>[],
  }) {
    final available = photos
        .where((photo) =>
            photo.id > 0 &&
            !excludedPhotoIds.contains(photo.id) &&
            photo.bestDisplayUrl.isNotEmpty)
        .toList(growable: false);
    if (available.isEmpty) return null;

    final scored = available
        .map((photo) => (
              photo: photo,
              score: scorePhotoRelevance(
                photo,
                subject: subject,
                mustInclude: mustInclude,
                mustAvoid: mustAvoid,
              ),
            ))
        .where((item) => item.score >= 3)
        .toList(growable: false);
    if (scored.isEmpty) return null;

    // Pexels sonucu yalnızca görsel sinyalle asgari alaka gösteriyorsa
    // tutulur; eşitlikte sunumda dengeli duran yatay kare tercih edilir.
    scored.sort((a, b) {
      final relevance = b.score.compareTo(a.score);
      if (relevance != 0) return relevance;
      final aDistance = (a.photo.aspectRatio - (16 / 9)).abs();
      final bDistance = (b.photo.aspectRatio - (16 / 9)).abs();
      return aDistance.compareTo(bDistance);
    });
    return scored.first.photo;
  }

  /// Pexels metadata'sı sınırlı olduğundan bu bilerek muhafazakâr bir eşiktir:
  /// yeterli sinyal yoksa alakasız stok fotoğraf yerine null döner.
  static int scorePhotoRelevance(
    PexelsPhoto photo, {
    String? subject,
    List<String> mustInclude = const <String>[],
    List<String> mustAvoid = const <String>[],
  }) {
    final searchable = _cleanKeyword('${photo.alt} ${photo.url}').toLowerCase();
    final tokens = searchable.split(RegExp(r'\s+')).where((t) => t.length >= 3).toSet();
    final subjectTerms = <String>[
      if (subject != null) ..._signalTokens(subject),
    ].toSet();
    final requiredObjects = mustInclude.expand(_signalTokens).toSet();
    final required = <String>{...subjectTerms, ...requiredObjects};
    final avoided = mustAvoid.expand(_signalTokens).toSet();
    if (avoided.any(tokens.contains)) return -100;
    // A required object is evidence, not a preference: never accept a
    // generic result such as a boat for a refrigeration-maintenance slide.
    if (requiredObjects.isNotEmpty && !requiredObjects.any(tokens.contains)) {
      return 0;
    }
    if (required.isEmpty) return 2;
    final matches = required.where(tokens.contains).length;
    // Sıralama tek başına kanıt değildir: sonuç sayfasındaki ilgisiz bir doğa
    // fotoğrafı teknik slayta taşınmamalı. En az bir sorgu sinyali gerekir.
    return matches == 0 ? 0 : matches * 3;
  }

  static Iterable<String> _signalTokens(String value) => _cleanKeyword(value)
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((token) => token.length >= 3 && !_isStopWord(token));

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
