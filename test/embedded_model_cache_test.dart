import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/embedded_model_cache.dart';

void main() {
  test('source and asset version both identify a cached export', () {
    final cache = EmbeddedModelCache();
    cache.store(source: '/model.glb', assetVersion: 'v1', data: 'old');
    expect(cache.lookup(source: '/model.glb', assetVersion: 'v1'), 'old');
    expect(cache.lookup(source: '/model.glb', assetVersion: 'v2'), isNull);
    expect(cache.lookup(source: '/other.glb', assetVersion: 'v1'), isNull);
    cache.store(source: '/unknown.glb', assetVersion: '', data: 'unknown');
    expect(cache.lookup(source: '/unknown.glb', assetVersion: ''), isNull);
  });

  test('recently used entries survive count eviction', () {
    final cache = EmbeddedModelCache(maxEntries: 2);
    for (final source in ['a', 'b']) {
      cache.store(source: source, assetVersion: 'v', data: source);
    }
    expect(cache.lookup(source: 'a', assetVersion: 'v'), 'a');
    cache.store(source: 'c', assetVersion: 'v', data: 'c');
    expect(cache.lookup(source: 'b', assetVersion: 'v'), isNull);
    expect(cache.lookup(source: 'a', assetVersion: 'v'), 'a');
    expect(cache.length, 2);
  });

  test('character budget and replacements keep memory accounting bounded', () {
    final cache = EmbeddedModelCache(maxEncodedCharacters: 6);
    cache.store(source: 'a', assetVersion: 'v', data: '1234');
    cache.store(source: 'a', assetVersion: 'v', data: '12');
    expect(cache.encodedCharacters, 2);
    cache.store(source: 'b', assetVersion: 'v', data: '3456');
    expect(cache.encodedCharacters, 6);
    cache.store(source: 'huge', assetVersion: 'v', data: '1234567');
    expect(cache.length, 2);
    cache.store(source: 'c', assetVersion: 'v', data: '789');
    expect(cache.encodedCharacters, 3);
    expect(cache.lookup(source: 'a', assetVersion: 'v'), isNull);
    expect(cache.lookup(source: 'b', assetVersion: 'v'), isNull);
  });
}
