import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_rest_helper.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

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
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    return _auth.signInWithPopup(provider);
  }

  Future<void> signOut() => _auth.signOut();
}
