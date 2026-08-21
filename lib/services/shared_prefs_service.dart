import 'package:shared_preferences/shared_preferences.dart';

/// Singleton SharedPreferences servisi - tekrar tekrar instance oluşturmayı önler
class SharedPrefsService {
  SharedPrefsService._();
  static final SharedPrefsService instance = SharedPrefsService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Senkron erişim (dikkatli kullan - sadece init sırasında)
  SharedPreferences? get prefsSync => _prefs;

  /// Önceden yüklenmiş mi?
  bool get isInitialized => _prefs != null;

  /// Önceden yükle (main'de kullanmak için)
  Future<void> preload() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }
}
