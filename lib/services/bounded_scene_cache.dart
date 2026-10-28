import 'dart:collection';

/// Session-only values; project state remains the durable source of truth.
class BoundedSceneCache<T extends Object> {
  BoundedSceneCache({required this.capacity}) {
    if (capacity <= 0) throw ArgumentError.value(capacity, 'capacity');
  }

  final int capacity;
  final _values = LinkedHashMap<String, T>();
  int get length => _values.length;
  bool containsKey(String key) => _values.containsKey(key);

  T? operator [](String key) {
    final value = _values.remove(key);
    if (value != null) _values[key] = value;
    return value;
  }

  void operator []=(String key, T value) {
    _values.remove(key);
    _values[key] = value;
    if (_values.length > capacity) _values.remove(_values.keys.first);
  }
}
