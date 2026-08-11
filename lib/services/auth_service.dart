import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../ui/widgets/terms_consent_dialog.dart';
import 'firestore_rest_helper.dart';

/// Kullanıcı Kullanım Şartları'nı onaylamadan hesap oluşturma tamamlanamaz;
/// onay verilmediyse bu hata fırlatılır.
class TermsConsentNotApprovedException implements Exception {
  const TermsConsentNotApprovedException();

  @override
  String toString() => 'Kullanım şartları onaylanmadı.';
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _termsVersion = '1.0';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        await _ensureUserDocument(user);
      }
      return user;
    });
  }

  Future<void> _ensureUserDocument(User user) async {
    // ignore: avoid_print
    print('ensureUserDocument başladı');
    final uid = user.uid;
    // ignore: avoid_print
    print('UID: $uid');
    final path = 'users/$uid';

    Map<String, dynamic>? doc;
    // ignore: avoid_print
    print('GET users başladı');
    try {
      doc = await FirestoreRestHelper.getDocument(path);
    } catch (e) {
      // ignore: avoid_print
      print('GET hata: $e');
      return;
    }
    // ignore: avoid_print
    print('GET status: ${doc == null ? '404 / bulunamadı' : '200 / bulundu'}');

    final fields = doc?['fields'] as Map<String, dynamic>? ?? {};
    final status = FirestoreRestHelper.stringField(fields, 'status');
    if (status == 'suspended') {
      // ignore: avoid_print
      print('Hesap askıya alınmış: $uid — çıkış yapılıyor');
      await _auth.signOut();
      throw Exception('Hesabınız askıya alınmıştır');
    }

    try {
      if (doc == null) {
        // ignore: avoid_print
        print('Kullanıcı bulunamadı');
        // ignore: avoid_print
        print('PATCH başladı');
        await FirestoreRestHelper.createDocument('users', uid, {
          'displayName': {'stringValue': user.displayName ?? ''},
          'email': {'stringValue': user.email ?? ''},
          'role': {'stringValue': 'user'},
          'tier': {'stringValue': 'free'},
          'presentationCount': {'integerValue': '0'},
          'createdAt': {'timestampValue': FirestoreRestHelper.nowTimestamp()},
          'lastActiveAt': {'timestampValue': FirestoreRestHelper.nowTimestamp()},
        });
        // ignore: avoid_print
        print('PATCH başarılı');
      } else {
        // ignore: avoid_print
        print('Kullanıcı bulundu');
        // ignore: avoid_print
        print('PATCH başladı');
        await FirestoreRestHelper.patchDocument(
          path,
          {
            'lastActiveAt': {'timestampValue': FirestoreRestHelper.nowTimestamp()},
          },
          updateMask: const ['lastActiveAt'],
        );
        // ignore: avoid_print
        print('PATCH başarılı');
      }
    } catch (e) {
      // ignore: avoid_print
      print('PATCH hata: $e');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) {
    // Zaten kayıtlı kullanıcı girişi: onay dialogu gerektirmez.
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Email/şifre ile YENİ KAYIT akışı.
  ///
  /// Hesap oluşturulmadan HEMEN ÖNCE şartlar onay dialogu gösterilir;
  /// kullanıcı "Devam Et" demeden kayıt işlemi tamamlanmaz.
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    final accepted = await showTermsConsentDialog();
    if (!accepted) {
      throw const TermsConsentNotApprovedException();
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _recordTermsAcceptance(credential.user?.uid);
    return credential;
  }

  /// Google ile giriş akışı.
  ///
  /// Giriş başarılı olduktan sonra hesap İLK KEZ açıldıysa (yeni kullanıcı)
  /// şartlar onay dialogu gösterilir. Onaylanmazsa oluşturulan hesap silinir
  /// ve oturum kapatılarak giriş ekranına dönülür. Zaten kayıtlı, tekrar
  /// giriş yapan kullanıcılara (users dokümanı oluşmuş) dialog hiç
  /// gösterilmez.
  Future<UserCredential> signInWithGoogle() async {
    final credential = await _auth.signInWithPopup(GoogleAuthProvider());
    final user = credential.user;
    if (user != null && _isFirstSignIn(user)) {
      final accepted = await showTermsConsentDialog();
      if (accepted) {
        await _recordTermsAcceptance(user.uid);
      } else {
        await _cancelFirstSignIn(credential);
      }
    }
    return credential;
  }

  Future<void> signOut() => _auth.signOut();

  /// Hesap `creationTime` ile `lastSignInTime` aynıysa bu, hesabın ilk
  /// girişidir. (users/{uid} dokümanı, authStateChanges tetikli
  /// `_ensureUserDocument` ile yarış halinde oluştuğu için Firestore yerine
  /// oturum metadata'sı esas alınır — daha güvenilirdir.)
  bool _isFirstSignIn(User user) {
    final created = user.metadata.creationTime;
    final lastSignIn = user.metadata.lastSignInTime;
    if (created == null || lastSignIn == null) return true;
    return created.difference(lastSignIn).inSeconds.abs() <= 60;
  }

  /// Onay verilmeyen ilk girişte oluşturulan hesabı siler; silinemezse bile
  /// oturumu kapatıp giriş ekranına döner.
  Future<void> _cancelFirstSignIn(UserCredential credential) async {
    try {
      await credential.user?.delete();
    } catch (_) {
      // Az önce oluşturulan hesap silinemezse dahi oturum kapatılır.
    }
    await _auth.signOut();
  }

  /// Onay verildiğinde users/{uid} dokümanına şartlar alanlarını ekler:
  /// `termsAcceptedAt` (sunucu zamanı) ve `termsVersion` ("1.0").
  ///
  /// Doküman `_ensureUserDocument` tarafından eş zamanlı oluşturulduğu için
  /// hazır olana kadar birkaç kez denenir; yine de yazılamazsa sessizce geçer
  /// (çerez onayında olduğu gibi best-effort).
  Future<void> _recordTermsAcceptance(String? uid) async {
    if (uid == null) return;
    final terms = {
      'termsAcceptedAt': FieldValue.serverTimestamp(),
      'termsVersion': _termsVersion,
    };

    for (var attempt = 0; attempt < 6; attempt++) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(terms, SetOptions(merge: true));
        return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
  }
}
