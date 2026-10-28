import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/model_camera_pose_cache.dart';

ModelViewerCameraPose pose(double radius) => ModelViewerCameraPose(
    theta: 35,
    phi: 60,
    radius: radius,
    targetX: 1,
    targetY: 2,
    targetZ: 3,
    animationTime: 7,
    animationName: 'clip');

void main() {
  test('a replacement model cannot inherit the slot previous camera', () {
    final cache = ModelCameraPoseCache();
    final old = pose(100);
    cache.captureOrCached(
        cameraKey: 'slide:block',
        modelId: 'old',
        source: 'old.glb',
        loadedSource: 'old.glb',
        readLivePose: () => old);
    var reads = 0;
    final pending = cache.captureOrCached(
        cameraKey: 'slide:block',
        modelId: 'new',
        source: 'new.glb',
        loadedSource: 'old.glb',
        readLivePose: () {
          reads++;
          return old;
        });
    expect(pending, isNull);
    expect(reads, 0);
    expect(cache.lookup('slide:block', 'old'), same(old));
    expect(cache.lookup('slide:block', 'new'), isNull);
  });

  test('a renewed URL keeps only a previously valid pose of the same model',
      () {
    final cache = ModelCameraPoseCache();
    final saved = pose(2);
    cache.captureOrCached(
        cameraKey: 'slot',
        modelId: 'water',
        source: 'first',
        loadedSource: 'first',
        readLivePose: () => saved);
    final pending = cache.captureOrCached(
        cameraKey: 'slot',
        modelId: 'water',
        source: 'renewed',
        loadedSource: 'first',
        readLivePose: () => fail('Old loaded source must not be read'));
    expect(pending, same(saved));
    expect(pending!.animationTime, 7);
    expect(pending.animationName, 'clip');
  });

  test('accepted new load replaces the pose and clears the old identity', () {
    final cache = ModelCameraPoseCache();
    final old = pose(100), current = pose(2);
    cache.captureOrCached(
        cameraKey: 'slot',
        modelId: 'old',
        source: 'old',
        loadedSource: 'old',
        readLivePose: () => old);
    expect(
        cache.captureOrCached(
            cameraKey: 'slot',
            modelId: 'new',
            source: 'new',
            loadedSource: 'new',
            readLivePose: () => current),
        same(current));
    expect(cache.lookup('slot', 'old'), isNull);
    expect(cache.lookup('slot', 'new'), same(current));
  });

  test(
      'unknown loaded state does not capture a default camera; cache is bounded',
      () {
    final cache = ModelCameraPoseCache(capacity: 2);
    expect(
        cache.captureOrCached(
            cameraKey: 'slot',
            modelId: 'new',
            source: 'new',
            loadedSource: null,
            readLivePose: () => fail('Unloaded camera must not be read')),
        isNull);
    for (final key in ['a', 'b', 'c']) {
      cache.captureOrCached(
          cameraKey: key,
          modelId: 'water',
          source: 'ready',
          loadedSource: 'ready',
          readLivePose: () => pose(2));
    }
    expect(cache.lookup('a', 'water'), isNull);
    expect(cache.lookup('b', 'water'), isNotNull);
    expect(cache.lookup('c', 'water'), isNotNull);
  });
}
