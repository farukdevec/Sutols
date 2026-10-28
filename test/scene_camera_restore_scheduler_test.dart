import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/scene_camera_restore_scheduler.dart';

void main() {
  testWidgets('hidden scenes never run retries; resume runs a bounded batch',
      (tester) async {
    var calls = 0;
    final scheduler = SceneCameraRestoreScheduler(onRestore: () => calls++);
    scheduler.restart();
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 0);
    scheduler.setActive(true);
    await tester.pump(const Duration(milliseconds: 1));
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 6);
    await tester.pump(const Duration(seconds: 20));
    expect(calls, 6);
    scheduler.dispose();
  });

  testWidgets('hiding cancels pending retries and resuming replaces them',
      (tester) async {
    var calls = 0;
    final scheduler = SceneCameraRestoreScheduler(onRestore: () => calls++);
    scheduler.setActive(true);
    await tester.pump(const Duration(milliseconds: 50));
    expect(calls, 2);
    scheduler.setActive(false);
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 2);
    scheduler.setActive(true);
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 8);
    scheduler.dispose();
  });

  testWidgets(
      'repeated layout changes replace retries instead of multiplying them',
      (tester) async {
    var calls = 0;
    final scheduler = SceneCameraRestoreScheduler(onRestore: () => calls++);
    scheduler.setActive(true);
    for (var i = 0; i < 100; i++) {
      scheduler.restart();
    }
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 6);
    scheduler.setActive(true);
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 6);
    scheduler.dispose();
  });

  testWidgets('disposed scenes cannot restart or execute callbacks',
      (tester) async {
    var calls = 0;
    final scheduler = SceneCameraRestoreScheduler(onRestore: () => calls++);
    scheduler.setActive(true);
    scheduler.dispose();
    scheduler.setActive(false);
    scheduler.setActive(true);
    scheduler.restart();
    await tester.pump(const Duration(seconds: 3));
    expect(calls, 0);
  });
}
