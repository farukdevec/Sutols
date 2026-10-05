import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_visual_plan.dart';

void main() {
  group('PresentationVisualPlan', () {
    test('diagrammatic plans do not fall back to stock photos', () {
      expect(
        PresentationVisualPlan.isPhotoCandidate(
          visualKind: 'chart',
          hasConfident3dModel: false,
        ),
        isFalse,
      );
      expect(
        PresentationVisualPlan.isPhotoCandidate(
          visualKind: 'comparison',
          hasConfident3dModel: false,
        ),
        isFalse,
      );
    });

    test('only explicit image plans reserve a photo fallback', () {
      expect(
        PresentationVisualPlan.isPhotoCandidate(
          visualKind: 'concept',
          hasConfident3dModel: false,
        ),
        isFalse,
      );
      expect(
        PresentationVisualPlan.isPhotoCandidate(
          visualKind: 'illustration',
          hasConfident3dModel: false,
        ),
        isTrue,
      );
    });

    test('photo plan limits and spreads images through a five-slide deck', () {
      final selected = PresentationVisualPlan.choosePhotoSlides(
        slideCount: 5,
        candidates: const [0, 1, 2, 3, 4],
      );

      expect(selected, hasLength(2));
      expect((selected[0] - selected[1]).abs(), greaterThan(1));
    });

    test('explicit photo plans take priority over 3D', () {
      expect(PresentationVisualPlan.prefersPhotoOver3d('photo'), isTrue);
      expect(PresentationVisualPlan.prefersPhotoOver3d('object_3d'), isFalse);
    });

    test('3D models require an explicit object_3d plan', () {
      expect(PresentationVisualPlan.allows3dModel('object_3d'), isTrue);
      for (final kind in [
        'process_diagram',
        'comparison',
        'chart',
        'table',
        'illustration',
        'none',
      ]) {
        expect(
          PresentationVisualPlan.allows3dModel(kind),
          isFalse,
          reason: kind,
        );
      }
    });
  });
}
