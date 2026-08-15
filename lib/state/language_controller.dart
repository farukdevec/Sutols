import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ip_location_service.dart';

enum AppLanguage { tr, en }

/// Uygulama geneli dil seçimi ve konum bazlı otomatik algılama kontrolcüsü.
class LanguageController {
  LanguageController._();
  static final LanguageController instance = LanguageController._();

  static const String _prefsKey = 'language_code';

  final ValueNotifier<AppLanguage> currentLanguage =
      ValueNotifier<AppLanguage>(AppLanguage.tr);

  /// Kullanıcının manuel olarak bir dil tercihi kaydedip kaydetmediğini tutar.
  bool isManuallySelected = false;

  /// Otomatik tespit edilen konum açıklaması (örn. "Türkiye (TR)").
  String? detectedLocationInfo;

  /// SharedPreferences ve konum sorgusundan dil durumunu yükler.
  Future<void> init({IpLocationService? locationService}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'tr') {
        currentLanguage.value = AppLanguage.tr;
        isManuallySelected = true;
        return;
      } else if (saved == 'en') {
        currentLanguage.value = AppLanguage.en;
        isManuallySelected = true;
        return;
      }
    } catch (_) {
      // SharedPreferences okunamadıysa konum sorgusuna geç
    }

    // Kullanıcı henüz elle tercih yapmamışsa konum bazlı otomatik seçim
    await autoDetectLocation(locationService: locationService);
  }

  /// IP konum servisinden konumu alır ve TR ise Türkçe, diğer ülkeler ise İngilizce seçer.
  Future<void> autoDetectLocation({IpLocationService? locationService}) async {
    try {
      final service = locationService ?? IpLocationService();
      final loc = await service.lookup();
      if (loc != null && !loc.isEmpty) {
        final code = loc.countryCode.toUpperCase();
        final countryName = loc.country.isNotEmpty ? loc.country : code;
        detectedLocationInfo = '$countryName ($code)';

        if (!isManuallySelected) {
          if (code == 'TR' ||
              countryName.toLowerCase().contains('türkiye') ||
              countryName.toLowerCase().contains('turkey')) {
            currentLanguage.value = AppLanguage.tr;
          } else {
            currentLanguage.value = AppLanguage.en;
          }
        }
      }
    } catch (_) {
      // Konum alınamazsa varsayılan Türkçe olarak kalır.
    }
  }

  /// Kullanıcı dil tercihini değiştirdiğinde çağrılır ve kaydedilir.
  Future<void> setLanguage(AppLanguage language) async {
    currentLanguage.value = language;
    isManuallySelected = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, language == AppLanguage.tr ? 'tr' : 'en');
    } catch (_) {
      // Kayıt hatası akışı bozmamalı.
    }
  }

  /// Sıfırla ve yeniden konuma göre otomatik belirle.
  Future<void> resetToAutoDetect({IpLocationService? locationService}) async {
    isManuallySelected = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
    await autoDetectLocation(locationService: locationService);
  }

  String get languageCode => currentLanguage.value == AppLanguage.tr ? 'tr' : 'en';

  /// AI servislerine gönderilecek dil parametresi ('turkish' veya 'english').
  String get aiLanguage => currentLanguage.value == AppLanguage.tr ? 'turkish' : 'english';

  bool get isEnglish => currentLanguage.value == AppLanguage.en;
  bool get isTurkish => currentLanguage.value == AppLanguage.tr;

  /// Çeviri yardımcısı: Türkçe ve İngilizce metin alır, aktif dile göre döndürür.
  String tr(String turkish, String english) {
    return isEnglish ? english : turkish;
  }
}

/// Kolay kullanım için top-level çeviri fonksiyonu
String tr(String turkish, String english) {
  return LanguageController.instance.tr(turkish, english);
}

/// BuildContext üzerinden kolay erişim
extension LanguageBuildContextX on BuildContext {
  String tr(String turkish, String english) {
    return LanguageController.instance.tr(turkish, english);
  }
}
