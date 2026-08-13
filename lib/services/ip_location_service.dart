import 'dart:convert';

import 'package:http/http.dart' as http;

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
}

/// GPS izni istemeden bağlantının genel IP adresinden yaklaşık konum üretir.
/// Ham IP, koordinat, posta kodu veya servis sağlayıcı bilgisi saklanmaz.
class IpLocationService {
  IpLocationService({http.Client? client}) : _client = client ?? http.Client();

  static const _endpoint =
      'https://ipwho.is/?fields=success,country,country_code,region,city';
  final http.Client _client;

  Future<IpLocation?> lookup() async {
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

  static String _string(Object? value) => value is String ? value.trim() : '';
}
