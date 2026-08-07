import 'package:cloud_firestore/cloud_firestore.dart';

class UsageService {
  final _db = FirebaseFirestore.instance;

  Future<bool> tryConsumeDailyQuota(String uid, int dailyLimit) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final ref = _db.collection('users').doc(uid).collection('usage').doc(today);

    try {
      return await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        final currentCount = snapshot.exists ? (snapshot.data()?['count'] ?? 0) as int : 0;

        if (currentCount >= dailyLimit) {
          return false;
        }

        transaction.set(ref, {
          'uid': uid,
          'date': today,
          'count': currentCount + 1,
        }, SetOptions(merge: true));

        return true;
      });
    } catch (e) {
      return false;
    }
  }
}
