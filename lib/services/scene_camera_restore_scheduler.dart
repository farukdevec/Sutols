import 'dart:async';

/// Bounded camera stabilization retries that only run for a visible scene.
class SceneCameraRestoreScheduler {
  SceneCameraRestoreScheduler({required this.onRestore});
  final void Function() onRestore;
  final List<Timer> _timers = [];
  bool _active = false;
  bool _disposed = false;

  void setActive(bool active) {
    if (_disposed || _active == active) return;
    _active = active;
    if (active) {
      restart();
    } else {
      _cancel();
    }
  }

  void restart() {
    _cancel();
    if (!_active || _disposed) return;
    for (final milliseconds in [0, 50, 150, 350, 750, 1200]) {
      _timers.add(Timer(Duration(milliseconds: milliseconds), () {
        if (_active && !_disposed) onRestore();
      }));
    }
  }

  void _cancel() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void dispose() {
    _disposed = true;
    _cancel();
  }
}
