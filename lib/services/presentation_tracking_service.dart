import 'package:cloud_firestore/cloud_firestore.dart';

import 'cookie_consent_service.dart';

class PresentationTrackingService {
  final _db = FirebaseFirestore.instance;

  /// Kullanım verisi toplama yalnızca "Kabul Et" seçen kullanıcılarda
  /// çalışır; "Sadece Zorunlu Çerezler" seçiminde tüm çağrılar pas geçilir.
  bool get _trackingAllowed => CookieConsentService.instance.analyticsAllowed;

  Future<void> markEdited(String presentationId) async {
    if (!_trackingAllowed) return;
    await _db.collection('presentations').doc(presentationId).update({
      'wasEdited': true,
      'editCount': FieldValue.increment(1),
    });
  }

  Future<void> markExported(String presentationId) async {
    if (!_trackingAllowed) return;
    await _db.collection('presentations').doc(presentationId).update({
      'wasExported': true,
    });
  }

  Future<void> addTimeSpent(String presentationId, int seconds) async {
    if (!_trackingAllowed) return;
    await _db.collection('presentations').doc(presentationId).update({
      'timeSpentSeconds': FieldValue.increment(seconds),
    });
  }
}