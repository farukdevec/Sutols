import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcının çerez / kullanım verisi onay durumu.
enum CookieConsentState {
  /// Henüz karar verilmedi — banner gösterilir.
  undecided,

  /// "Kabul Et": temel çerezler + kullanım verisi analitiği.
  accepted,

  /// "Sadece Zorunlu Çerezler": yalnız oturum/auth, analitik kapalı.
  essential,
}

/// Çerez onayı durumunu yönetir.
///
/// Giriş yapmış kullanıcılarda seçim Firestore `users/{uid}.cookieConsent`
/// alanında saklanır; misafir kullanıcılarda yalnızca cihazda
/// (SharedPreferences) tutulur.
class CookieConsentService {
  CookieConsentService._();
  static final CookieConsentService instance = CookieConsentService._();

  static const String _prefsKey = 'cookie_consent';
  static const String _firestoreField = 'cookieConsent';

  final ValueNotifier<CookieConsentState> state =
      ValueNotifier<CookieConsentState>(CookieConsentState.undecided);

  /// Kullanım verisi (analitik) toplama izni var mı?
  bool get analyticsAllowed => state.value == CookieConsentState.accepted;

  /// Uygulama başlangıcında bir kez çağrılır; mevcut kullanıcının kayıtlı
  /// seçimini yükler ve oturum değişikliklerinde yeniden senkronize eder.
  Future<void> load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _loadFromFirestore(user.uid);
      } else {
        await _loadFromPrefs();
      }

      FirebaseAuth.instance.authStateChanges().listen((u) {
        if (u != null) {
          _loadFromFirestore(u.uid);
        } else {
          _loadFromPrefs();
        }
      });
    } catch (_) {
      await _loadFromPrefs();
    }
  }

  Future<void> accept() => _save(CookieConsentState.accepted);

  Future<void> essentialOnly() => _save(CookieConsentState.essential);

  Future<void> _save(CookieConsentState value) async {
    state.value = value;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({_firestoreField: value.name});
        } catch (_) {
          // Best-effort: Firestore yazılamazsa yerel kayıt yeterlidir.
        }
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, value.name);
    } catch (_) {}
  }

  Future<void> _loadFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) {
        await _loadFromPrefs();
        return;
      }
      state.value = _parse(doc.data()?[_firestoreField]);
    } catch (_) {
      // Okuma hatası olursa cihazdaki kayda düş.
      await _loadFromPrefs();
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state.value = _parse(prefs.getString(_prefsKey));
  }

  CookieConsentState _parse(Object? raw) {
    if (raw is String && raw == CookieConsentState.accepted.name) {
      return CookieConsentState.accepted;
    }
    if (raw is String && raw == CookieConsentState.essential.name) {
      return CookieConsentState.essential;
    }
    return CookieConsentState.undecided;
  }
}