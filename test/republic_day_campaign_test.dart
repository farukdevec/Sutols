import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/republic_day_campaign.dart';
import 'package:sutol/models/presentation_3d_model_catalog.dart';

void main() {
  test('Decorations expire exactly at October 31 midnight in Turkey', () {
    expect(
        isRepublicDayCampaignActive(
            DateTime.parse('2026-10-30T23:59:59+03:00')),
        isTrue);
    expect(
        isRepublicDayCampaignActive(
            DateTime.parse('2026-10-31T00:00:00+03:00')),
        isFalse);
    expect(isRepublicDayCampaignActive(DateTime.parse('2026-10-30T21:00:00Z')),
        isFalse);
    expect(isRepublicDayCampaignActive(DateTime.parse('2026-11-01T12:00:00Z')),
        isFalse);
  });
  test('Campaign never repeats automatically; model remains permanent', () {
    expect(isRepublicDayCampaignActive(DateTime.utc(2027, 10, 29)), isFalse);
    expect(findPresentation3DModelAsset('cumhuriyet-29-ekim'), isNotNull);
  });
}
