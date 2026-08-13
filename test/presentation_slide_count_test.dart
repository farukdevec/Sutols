import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/fallback_slide_generator.dart';
import 'package:sutol/services/presentation_service.dart';

void main() {
  group('sunum sayfa sayısı', () {
    for (final count in <int>[1, 7, 8, 30]) {
      test('yedek üretici tam $count sayfa üretir', () {
        final presentation = FallbackSlideGenerator.generatePresentation(
          'Yapay zeka ve eğitim',
          slideCount: count,
        );

        expect(presentation.slides, hasLength(count));
      });
    }

    test('ücretsiz plan yalnızca 1-7 sayfaya erişir', () {
      expect(PresentationService.canUseSlideCount('free', 1), isTrue);
      expect(PresentationService.canUseSlideCount('free', 7), isTrue);
      expect(PresentationService.canUseSlideCount('free', 8), isFalse);
      expect(PresentationService.canUseSlideCount('free', 30), isFalse);
    });

    test('Plus plan 1-30 sayfaya erişir', () {
      for (final tier in <String>['plus', 'premium', 'pro']) {
        expect(PresentationService.canUseSlideCount(tier, 1), isTrue);
        expect(PresentationService.canUseSlideCount(tier, 30), isTrue);
      }
    });

    test('tüm planlarda aralık dışı değerler reddedilir', () {
      expect(PresentationService.canUseSlideCount('plus', 0), isFalse);
      expect(PresentationService.canUseSlideCount('plus', 31), isFalse);
    });
  });
}
