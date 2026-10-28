import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/bounded_scene_cache.dart';

void main() {
  test('long sessions retain only the configured number of scene values', () {
    final cache = BoundedSceneCache<int>(capacity: 256);
    for (var i = 0; i < 10000; i++) {
      cache['model-$i'] = i;
    }
    expect(cache.length, 256);
    expect(cache['model-0'], isNull);
    expect(cache['model-9744'], 9744);
    expect(cache['model-9999'], 9999);
  });

  test('recently used poses survive eviction ahead of unused values', () {
    final cache = BoundedSceneCache<int>(capacity: 2);
    cache['active'] = 1;
    cache['old'] = 2;
    expect(cache['active'], 1);
    cache['new'] = 3;
    expect(cache['active'], 1);
    expect(cache['old'], isNull);
    expect(cache['new'], 3);
  });

  test('updating a scene refreshes its value without growing the cache', () {
    final cache = BoundedSceneCache<int>(capacity: 2);
    cache['a'] = 1;
    cache['b'] = 2;
    cache['a'] = 9;
    cache['c'] = 3;
    expect(cache.length, 2);
    expect(cache['a'], 9);
    expect(cache['b'], isNull);
  });

  test('missing values and existence checks do not change eviction order', () {
    final cache = BoundedSceneCache<int>(capacity: 2);
    cache['a'] = 1;
    cache['b'] = 2;
    expect(cache['missing'], isNull);
    expect(cache.containsKey('a'), true);
    cache['c'] = 3;
    expect(cache['a'], isNull);
    expect(cache.length, 2);
  });

  test('rejects invalid capacity even outside assertion-enabled builds', () {
    expect(() => BoundedSceneCache<int>(capacity: 0), throwsArgumentError);
    expect(() => BoundedSceneCache<int>(capacity: -1), throwsArgumentError);
  });
}
