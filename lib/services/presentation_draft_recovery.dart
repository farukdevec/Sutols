import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'serialized_save_queue.dart';

/// Local checkpoint scoped to the authenticated owner and presentation ID.
/// Operations are ordered so completion of an old cloud save cannot remove
/// the checkpoint of a newer edit.
class PresentationDraftRecovery {
  static final _queue = SerializedSaveQueue();
  static String _key(String uid, String id) => 'sutols_draft_v1:$uid:$id';
  static Future<void> put(String uid, String id, String source) =>
      _queue.run(() async {
        final preferences = await SharedPreferences.getInstance();
        final saved = await preferences.setString(
            _key(uid, id),
            jsonEncode({
              'version': 1,
              'savedAt': DateTime.now().toUtc().toIso8601String(),
              'json': source
            }));
        if (!saved) throw StateError('Yerel kurtarma kaydı yazılamadı.');
      });
  static Future<String?> read(String uid, String id) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(uid, id));
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      return value is Map && value['version'] == 1 && value['json'] is String
          ? value['json'] as String
          : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearIfMatches(String uid, String id, String source) =>
      _queue.run(() async {
        if (await read(uid, id) != source) return;
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_key(uid, id));
      });
}
