import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_asset_service.dart';

void main() {
  test('requires an explicit expiry for opaque signed model tokens', () {
    expect(
      ModelAssetService.isSignedUrlValid(
        'https://assets.sutols.com/model.glb?token=opaque-token',
      ),
      isFalse,
    );
    expect(
      ModelAssetService.isSignedUrlValid(
        'https://assets.sutols.com/model.glb?token=opaque-token&expires=4102444800',
      ),
      isTrue,
    );
  });

  test('rejects an expired signed model URL before it reaches model-viewer', () {
    expect(
      ModelAssetService.isSignedUrlValid(
        'https://assets.sutols.com/model.glb?token=expired&expires=1',
      ),
      isFalse,
    );
  });
}
