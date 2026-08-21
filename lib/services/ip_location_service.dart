import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IpLocation {
  const IpLocation({
    required this.city,
    required this.region,
    required this.country,
    required this.countryCode,
  });

  final String city;
  final String region;
  final String country;
  final String countryCode;

  bool get isEmpty => city.isEmpty && region.isEmpty && country.isEmpty;

  Map<String, dynamic> toJson() => {
    'city': city,
    'region': region,
    'country': country,
    'countryCode': countryCode,
  };

  factory IpLocation.fromJson(Map<String, dynamic> json) {
    return IpLocation(
      city: _string(json['city']),
      region: _string(json['region']),
      country: _string(json['country']),
      countryCode: _string(json['countryCode']).toUpperCase(),
    );
  }

  static String _string(Object? value) => value is String ? value.trim() : '';
}

/// GPS izni istemeden bağlantının genel IP adresinden yaklaşık konum üretir.
/// Ham IP, koordinat, posta kodu veya servis sağlayıcı bilgisi saklanmaz.
class IpLocationService {
  IpLocationService({http.Client? client, SharedPreferences? prefs})
      : _client = client ?? http.Client(),
        _prefs = prefs;

  static const _endpoint =
      'https://ipwho.is/?fields=success,country,country_code,region,city';
  static const _cacheKey = 'cached_ip_location';
  static const _cacheDurationKey = 'cached_ip_location_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  final http.Client _client;
  final SharedPreferences? _prefs;

  static String _string(Object? value) => value is String ? value.trim() : '';

  Future<IpLocation?> lookup() async {
    // Önce cache'ten oku
    final cached = await _getCachedLocation();
    if (cached != null) {
      return cached;
    }

    // Cache yoksa veya süresi dolduysa API'den al
    final location = await _fetchFromApi();
    if (location != null) {
      // Cache'le
      await _cacheLocation(location);
    }
    return location;
  }

  Future<IpLocation?> _getCachedLocation() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final timestampStr = prefs.getString(_cacheDurationKey);

      if (cachedJson == null || timestampStr == null) return null;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return null;

      // Cache süresi doldu mu?
      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        return null;
      }

      final json = jsonDecode(cachedJson) as Map<String, dynamic>;
      return IpLocation.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheLocation(IpLocation location) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(location.toJson()));
      await prefs.setString(_cacheDurationKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Cache hatası uygulamayı bozmamalı
    }
  }

  Future<IpLocation?> _fetchFromApi() async {
    try {
      final response = await _client
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return null;

      final location = IpLocation(
        city: _string(data['city']),
        region: _string(data['region']),
        country: _string(data['country']),
        countryCode: _string(data['country_code']).toUpperCase(),
      );
      return location.isEmpty ? null : location;
    } catch (_) {
      return null;
    }
  }
}
