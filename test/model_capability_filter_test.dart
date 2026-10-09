import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/presentation_3d_model_catalog.dart';
import 'package:sutol/services/model_capability_filter.dart';

void main() {
  test('unknown models remain in library but do not claim capabilities', () {
    expect(
        modelMatchesCapability('unknown', ModelCapabilityFilter.all), isTrue);
    for (final filter in ModelCapabilityFilter.values.skip(1)) {
      expect(modelMatchesCapability('unknown', filter), isFalse);
    }
  });
  test('capabilities follow the catalog rather than tags or object names', () {
    for (final asset in presentation3DModelCatalog) {
      expect(modelMatchesCapability(asset.id, ModelCapabilityFilter.animated),
          asset.hasAnimations,
          reason: asset.id);
      expect(
          modelMatchesCapability(asset.id, ModelCapabilityFilter.virtualTour),
          asset.supportsVirtualTour,
          reason: asset.id);
      expect(
          modelMatchesCapability(asset.id, ModelCapabilityFilter.smallDownload),
          asset.byteSize > 0 && asset.byteSize <= 1024 * 1024,
          reason: asset.id);
    }
  });
}
