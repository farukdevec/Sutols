import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_rest_helper.dart';

class ModelMatch {
  final String id;
  final String name;
  final String modelUrl;
  final String thumbnailUrl;
  final int score;


  ModelMatch({
    required this.id,
    required this.name,
    required this.modelUrl,
    required this.thumbnailUrl,
    required this.score,
  });
}


class ModelMatchingService {
  Future<List<ModelMatch>> matchModelsForSlide(List<String> keywords) async {
    if (keywords.isEmpty) return [];
    if (FirebaseAuth.instance.currentUser == null) return [];

    final limitedKeywords = keywords.take(10).toList();

    final docs = await FirestoreRestHelper.listDocuments('models');

    final matches = docs.map((doc) {
      final id = (doc['name'] as String? ?? '').split('/').last;
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};

      final name = FirestoreRestHelper.stringField(fields, 'name');
      final modelUrl = FirestoreRestHelper.stringField(fields, 'modelUrl');
      final thumbnailUrl = FirestoreRestHelper.stringField(fields, 'thumbnailUrl');
      final tags = FirestoreRestHelper.arrayField(fields, 'tags');

      final score = tags.where((t) => limitedKeywords.contains(t)).length;

      return ModelMatch(
        id: id,
        name: name,
        modelUrl: modelUrl,
        thumbnailUrl: thumbnailUrl,
        score: score,
      );
    }).where((m) => m.score > 0).toList();


    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }
}
