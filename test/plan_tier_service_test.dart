import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/plan_tier_service.dart';

void main() {
  test('yeni ve eski ücretli tier değerleri Plus olarak normalleşir', () {
    expect(PlanTierService.normalize('plus'), 'plus');
    expect(PlanTierService.normalize('premium'), 'plus');
    expect(PlanTierService.normalize('pro'), 'plus');
    expect(PlanTierService.normalize('free'), 'free');
  });

  test('Plus promosyonu ücretsiz hesabı Plus yapabilir', () {
    expect(
      PlanTierService.canRedeemPlus(
        grantsTier: 'plus',
        currentTier: 'free',
      ),
      isTrue,
    );
  });

  test('eski Premium ve Pro kodları da yalnızca Plus kazandırır', () {
    for (final legacyTier in <String>['premium', 'pro']) {
      expect(
        PlanTierService.canRedeemPlus(
          grantsTier: legacyTier,
          currentTier: 'free',
        ),
        isTrue,
      );
      expect(PlanTierService.normalize(legacyTier), PlanTierService.plus);
    }
  });

  test('Plus hesap aynı kodla yeniden yükseltilemez', () {
    expect(
      PlanTierService.canRedeemPlus(
        grantsTier: 'plus',
        currentTier: 'plus',
      ),
      isFalse,
    );
  });

  test('bilinmeyen plan veren kod reddedilir', () {
    expect(
      PlanTierService.canRedeemPlus(
        grantsTier: 'enterprise',
        currentTier: 'free',
      ),
      isFalse,
    );
  });
}
