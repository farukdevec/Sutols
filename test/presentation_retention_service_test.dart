import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_retention_service.dart';

void main() {
  final service = PresentationRetentionService();

  test('ücretsiz kullanıcılar en fazla 10 sunum saklar', () {
    expect(service.limitForTier('free'), 10);
    expect(service.limitForTier(''), 10);
  });

  test('Plus kullanıcılar en fazla 25 sunum saklar', () {
    expect(service.limitForTier('plus'), 25);
    expect(service.limitForTier('PLUS'), 25);
    expect(service.limitForTier('pro'), 25);
  });

  test('Premium kullanıcılar en fazla 200 sunum saklar', () {
    expect(service.limitForTier('premium'), 200);
    expect(service.limitForTier('PREMIUM'), 200);
  });
}
