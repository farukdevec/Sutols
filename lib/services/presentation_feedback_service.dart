import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persists the voluntary, post-generation evaluation for a presentation.
class PresentationFeedbackService {
  PresentationFeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submit({
    required String presentationId,
    required int modelRating,
    required int textRating,
    required int visualRating,
    required int templateRating,
    String? note,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Geri bildirim göndermek için giriş yapmalısınız.');
    }

    await _firestore.collection('presentation_feedback').add({
      'presentationId': presentationId,
      'userId': user.uid,
      'modelRating': modelRating,
      'textRating': textRating,
      'visualRating': visualRating,
      'templateRating': templateRating,
      'note': note?.trim() ?? '',
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }
}
