import 'dart:collection';

/// Stores only public bundled data. Authorized downloads are never retained.
/// The budget counts encoded characters, avoiding an unbounded base64 cache.
class EmbeddedModelCache {
  EmbeddedModelCache({
    this.maxEntries = 16,
    this.maxEncodedCharacters = 16 * 1024 * 1024,
  })  : assert(maxEntries > 0),
        assert(maxEncodedCharacters > 0);

  final int maxEntries;
  final int maxEncodedCharacters;
  final _entries = LinkedHashMap<String, String>();
  int _encodedCharacters = 0;

  int get length => _entries.length;
  int get encodedCharacters => _encodedCharacters;

  String? lookup({required String source, required String assetVersion}) {
    if (assetVersion.isEmpty) return null;
    final key = '$source\n$assetVersion';
    final value = _entries.remove(key);
    if (value != null) _entries[key] = value;
    return value;
  }

  void store({
    required String source,
    required String assetVersion,
    required String data,
  }) {
    if (assetVersion.isEmpty || data.length > maxEncodedCharacters) return;
    final key = '$source\n$assetVersion';
    final previous = _entries.remove(key);
    if (previous != null) _encodedCharacters -= previous.length;
    while (_entries.isNotEmpty &&
        (_entries.length >= maxEntries ||
            _encodedCharacters + data.length > maxEncodedCharacters)) {
      _encodedCharacters -= _entries.remove(_entries.keys.first)!.length;
    }
    _entries[key] = data;
    _encodedCharacters += data.length;
  }
}
