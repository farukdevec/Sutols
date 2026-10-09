import '../models/slide_model.dart';

/// Transient GPU recovery state, never part of a saved project.
class ModelContextRecoveryState {
  ModelContextRecoveryState({required String modelId}) : _modelId = modelId;
  String _modelId;
  int _revision = 0;
  bool _disposed = false;
  bool _isLost = false;
  ModelViewerCameraPose? _pose;
  bool get isLost => _isLost;
  ModelViewerCameraPose? get pose => _pose;

  int? lose(ModelViewerCameraPose? currentPose) {
    if (_disposed) return null;
    if (!isLost) {
      _revision++;
      _pose = currentPose;
      _isLost = true;
    }
    return _revision;
  }

  bool restore(int revision) {
    if (_disposed || !isLost || revision != _revision) return false;
    _isLost = false;
    return true;
  }

  void useModel(String modelId) {
    if (_modelId == modelId) return;
    _modelId = modelId;
    // GPU recovery belongs to the canvas; its old pose belongs to the model.
    _pose = null;
  }

  void clearPose() => _pose = null;

  void reset() {
    _revision++;
    _isLost = false;
    _pose = null;
  }

  void dispose() {
    reset();
    _disposed = true;
  }
}
