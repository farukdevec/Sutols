import 'dart:async';

/// Prevent an older cloud write finishing after and overwriting a newer one.
/// A failed write does not poison later saves. Each caller observes its own
/// success/failure; this queue does not claim multi-user conflict resolution.
class SerializedSaveQueue {
  Future<void> _tail = Future<void>.value();
  Future<void> run(Future<void> Function() save) {
    final current = _tail.then((_) => save());
    _tail = current.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return current;
  }
}
