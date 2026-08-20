import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_retention_service.dart';

void main() {
  test('ücretsiz kullanıcılar en fazla 3 sunum saklar', () {
    expect(PresentationRetentionService.limitForTier('free'), 3);
    expect(PresentationRetentionService.limitForTier(''), 3);
  });

  test('Plus kullanıcılar en fazla 15 sunum saklar', () {
    expect(PresentationRetentionService.limitForTier('plus'), 15);
    expect(PresentationRetentionService.limitForTier('PLUS'), 15);
  });
}
