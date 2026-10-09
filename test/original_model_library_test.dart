import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/presentation_3d_model_catalog.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/model_search_service.dart';

void main() {
  test('expanded originals are distinct and discoverable by their full names',
      () {
    final catalog = ModelRepository.mergeWithBundledModels(const []);
    final index = ModelSearchIndex(catalog);
    expect(originalPresentation3DModels.length, 100);
    expect(originalPresentation3DModels.map((m) => m.id).toSet().length, 100);
    for (final model in originalPresentation3DModels) {
      expect(index.search(model.label).take(3).map((m) => m.id),
          contains(model.id),
          reason: model.label);
      expect(
          index.search(model.label, category: model.category).map((m) => m.id),
          contains(model.id),
          reason: '${model.label} category');
    }
  });
  test('every original also has a searchable English object name', () {
    final index =
        ModelSearchIndex(ModelRepository.mergeWithBundledModels(const []));
    final missing = <String>[];
    for (final model in originalPresentation3DModels) {
      final english = model.id == 'sutols-three-d-printer'
          ? '3d printer'
          : model.id.substring('sutols-'.length).replaceAll('-', ' ');
      if (!index.search(english).any((m) => m.id == model.id))
        missing.add(english);
    }
    expect(missing, isEmpty, reason: missing.join(', '));
  });
  test('new objects remain discoverable with Turkish and English subject terms',
      () {
    final index =
        ModelSearchIndex(ModelRepository.mergeWithBundledModels(const []));
    const terms = {
      'sutols-laboratory-funnel': ['laboratuvar hunisi', 'laboratory funnel'],
      'sutols-truss-bridge': ['kafes köprü', 'truss bridge'],
      'sutols-robotic-arm': ['robot kolu', 'robotic arm'],
      'sutols-quartz-crystal': ['kuvars', 'quartz crystal'],
      'sutols-mobius-strip': ['möbius şeridi', 'mobius strip'],
    };
    for (final entry in terms.entries) {
      for (final term in entry.value)
        expect(index.search(term).take(3).map((m) => m.id), contains(entry.key),
            reason: term);
    }
  });
}
