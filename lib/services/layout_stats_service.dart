import 'package:cloud_firestore/cloud_firestore.dart';

class LayoutStatsService {
  final _db = FirebaseFirestore.instance;

  Future<void> recordUsage(String category, String layout, bool wasSuccessful) async {
    final docId = '${category}_$layout';
    final ref = _db.collection('layoutStats').doc(docId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final timesUsed = (snapshot.data()?['timesUsed'] ?? 0) as int;
      final timesSuccessful = (snapshot.data()?['timesSuccessful'] ?? 0) as int;

      transaction.set(ref, {
        'category': category,
        'layout': layout,
        'timesUsed': timesUsed + 1,
        'timesSuccessful': timesSuccessful + (wasSuccessful ? 1 : 0),
      }, SetOptions(merge: true));
    });
  }

  Future<double> getSuccessRate(String category, String layout) async {
    final docId = '${category}_$layout';
    final doc = await _db.collection('layoutStats').doc(docId).get();
    if (!doc.exists) return 0.5; // veri yoksa nötr
    final used = (doc.data()?['timesUsed'] ?? 1) as int;
    final successful = (doc.data()?['timesSuccessful'] ?? 0) as int;
    return successful / used;
  }
}