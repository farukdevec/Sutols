import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'serialized_save_queue.dart';

/// Stores only stable catalog IDs, scoped to the current account.
/// Model files and short-lived authorization URLs never enter this record.
class ModelLibraryPreferences {
  ModelLibraryPreferences(this.owner);
  final String owner;
  static final _writes = SerializedSaveQueue();
  final Set<String> favorites = {};
  final List<String> recent = [];
  String get _key => 'sutols_model_library_v1:$owner';

  Future<void> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw);
      if (data is! Map || data['version'] != 1) return;
      List<String> ids(Object? value, int limit) => value is List
          ? value
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toSet()
              .take(limit)
              .toList()
          : [];
      favorites
        ..clear()
        ..addAll(ids(data['favorites'], 200));
      recent
        ..clear()
        ..addAll(ids(data['recent'], 30));
    } catch (_) {
      // An invalid preference does not prevent browsing the catalog.
    }
  }

  Future<void> toggleFavorite(String id) {
    if (!favorites.remove(id) && favorites.length < 200) favorites.add(id);
    return _save();
  }

  Future<void> recordUse(String id) {
    recent.remove(id);
    recent.insert(0, id);
    if (recent.length > 30) recent.removeRange(30, recent.length);
    return _save();
  }

  Future<void> _save() {
    final source = jsonEncode(
        {'version': 1, 'favorites': favorites.toList(), 'recent': recent});
    return _writes.run(() async {
      final saved =
          await (await SharedPreferences.getInstance()).setString(_key, source);
      if (!saved) throw StateError('Model tercihleri kaydedilemedi.');
    });
  }
}
