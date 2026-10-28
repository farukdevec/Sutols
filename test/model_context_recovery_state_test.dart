import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/model_context_recovery_state.dart';

const captured = ModelViewerCameraPose(
    theta: 123,
    phi: 67,
    radius: 2.4,
    targetX: 1,
    targetY: 2,
    targetZ: 3,
    fieldOfView: 51,
    turntableRotation: .7,
    animationTime: 8.5,
    animationName: 'spin');

void main() {
  test('context restoration retains the exact transient camera and clip', () {
    final recovery = ModelContextRecoveryState(modelId: 'water');
    final revision = recovery.lose(captured)!;
    expect(recovery.isLost, true);
    expect(recovery.restore(revision), true);
    expect(recovery.isLost, false);
    expect(recovery.pose, same(captured));
    expect(recovery.pose!.animationTime, 8.5);
    expect(recovery.pose!.animationName, 'spin');
    expect(recovery.pose!.turntableRotation, .7);
    expect(recovery.restore(revision), false);
  });

  test(
      'duplicate loss preserves the first pose and late callbacks cannot resume a new loss',
      () {
    final recovery = ModelContextRecoveryState(modelId: 'water');
    final first = recovery.lose(captured)!;
    expect(recovery.lose(null), first);
    expect(recovery.pose, same(captured));
    recovery.restore(first);
    final next = recovery.lose(null)!;
    expect(next, isNot(first));
    expect(recovery.restore(first), false);
    expect(recovery.isLost, true);
    expect(recovery.restore(next), true);
    expect(recovery.pose, isNull);
  });

  test(
      'model changes while lost keep canvas recovery but discard the old model pose',
      () {
    final recovery = ModelContextRecoveryState(modelId: 'old');
    final revision = recovery.lose(captured)!;
    recovery.useModel('new');
    expect(recovery.isLost, true);
    expect(recovery.pose, isNull);
    expect(recovery.restore(revision), true);
    expect(recovery.pose, isNull);
  });

  test('explicit camera edits supersede the transient recovery pose', () {
    final recovery = ModelContextRecoveryState(modelId: 'water');
    final revision = recovery.lose(captured)!;
    recovery.clearPose();
    expect(recovery.isLost, true);
    expect(recovery.restore(revision), true);
    expect(recovery.pose, isNull);
  });

  test('a new canvas invalidates its previous restore callback', () {
    final recovery = ModelContextRecoveryState(modelId: 'water');
    final old = recovery.lose(captured)!;
    recovery.reset();
    expect(recovery.restore(old), false);
    final current = recovery.lose(captured)!;
    expect(recovery.restore(old), false);
    expect(recovery.restore(current), true);
  });

  test('dispose prevents recovery or new losses from restarting the scene', () {
    final recovery = ModelContextRecoveryState(modelId: 'water');
    final revision = recovery.lose(captured)!;
    recovery.dispose();
    expect(recovery.restore(revision), false);
    expect(recovery.lose(captured), isNull);
    expect(recovery.isLost, false);
    expect(recovery.pose, isNull);
  });
}
