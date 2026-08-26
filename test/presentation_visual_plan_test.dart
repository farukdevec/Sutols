import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_visual_plan.dart';

void main() {
  group('PresentationVisualPlan', () {
    test('diagram and table slides do not receive stock photos', () {
      expect(
        PresentationVisualPlan.isPhotoCandidate(
          visualKind: 'chart',
          hasConfident3dModel: false,
        ),
        isFalse,
      );
      expect(
        PresentationVisualPlan.isPhotoCandidate(
          visualKind: 'none',
          hasConfident3dModel: false,
        ),
        isFalse,
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
  });
}
