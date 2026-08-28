import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/model_tour_runtime.dart';

void main() {
  test('tour look normalizes theta and keeps the safe vertical range', () {
    const pose = ModelTourPose(theta: 1, phi: 82, x: 0, y: 0, z: 0);
    final looked = ModelTourRuntime.look(
      pose,
      horizontalPixels: 48,
      verticalPixels: 999,
    );

    expect(looked.theta, inInclusiveRange(0, 360));
    expect(looked.phi, ModelTourRuntime.maxPhi);
  });

  test('tour movement is constrained to the model footprint', () {
    const pose = ModelTourPose(theta: 0, phi: 82, x: 0, y: 0, z: 0);
    final bounds = ModelTourRuntime.boundsFromModel(
      centerX: 0,
      centerY: 3,
      centerZ: 0,
      width: 10,
      height: 6,
      depth: 8,
    );
    final moved = ModelTourRuntime.move(
      pose,
      forwardMeters: 100,
      rightMeters: 100,
      bounds: bounds,
    );

    expect(moved.x, bounds.maxX);
    expect(moved.z, bounds.minZ);
    expect(moved.y, bounds.groundY);
  });

  test('ileri ve sağ hareket kameranın baktığı yöne göre döner', () {
    const origin = ModelTourPose(theta: 0, phi: 82, x: 0, y: 0, z: 0);

    final north = ModelTourRuntime.move(
      origin,
      forwardMeters: 4,
      rightMeters: 0,
    );
    expect(north.x, closeTo(0, 0.0001));
    expect(north.z, closeTo(-4, 0.0001));

    final northRight = ModelTourRuntime.move(
      origin,
      forwardMeters: 0,
      rightMeters: 4,
    );
    expect(northRight.x, closeTo(4, 0.0001));
    expect(northRight.z, closeTo(0, 0.0001));

    final eastFacing = ModelTourRuntime.move(
      origin.copyWith(theta: 90),
      forwardMeters: 4,
      rightMeters: 2,
    );
    expect(eastFacing.x, closeTo(-4, 0.0001));
    expect(eastFacing.z, closeTo(-2, 0.0001));

    final southFacing = ModelTourRuntime.move(
      origin.copyWith(theta: 180),
      forwardMeters: 4,
      rightMeters: 2,
    );
    expect(southFacing.x, closeTo(-2, 0.0001));
    expect(southFacing.z, closeTo(4, 0.0001));
  });

  test('klavye tur hızı hızlı ve ortak çalışma değerini kullanır', () {
    expect(ModelTourRuntime.keyboardWalkSpeedMetersPerSecond, 36);
  });
}
