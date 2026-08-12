import 'package:firebase_auth/firebase_auth.dart';

import 'model_repository.dart';

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

    final models = await ModelRepository.instance.getModels();

    final matches = models
        .map((model) {
          final score =
              model.tags.where((t) => limitedKeywords.contains(t)).length;

          return ModelMatch(
            id: model.id,
            name: model.name,
            modelUrl: model.modelUrl,
            thumbnailUrl: model.thumbnailUrl,
            score: score,
          );
        })
        .where((m) => m.score > 0)
        .toList();

    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }
}
