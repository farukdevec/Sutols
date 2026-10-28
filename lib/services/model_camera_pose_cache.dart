import '../models/slide_model.dart';
import 'bounded_scene_cache.dart';

/// A slot can display several models over time; poses belong to its model too.
class ModelCameraPoseCache {
  ModelCameraPoseCache({int capacity = 256})
      : _values =
            BoundedSceneCache<({String modelId, ModelViewerCameraPose pose})>(
                capacity: capacity);
  final BoundedSceneCache<({String modelId, ModelViewerCameraPose pose})>
      _values;

  ModelViewerCameraPose? lookup(String cameraKey, String modelId) {
    final value = _values[cameraKey];
    return value?.modelId == modelId ? value?.pose : null;
  }

  ModelViewerCameraPose? captureOrCached({
    required String cameraKey,
    required String modelId,
    required String? source,
    required String? loadedSource,
    required ModelViewerCameraPose? Function() readLivePose,
  }) {
    // Changing src does not immediately replace the viewer's loaded scene.
    // Reading its camera here would assign the old model's pose to the new one.
    if (source != null && source.isNotEmpty && source == loadedSource) {
      final pose = readLivePose();
      if (pose != null) {
        _values[cameraKey] = (modelId: modelId, pose: pose);
        return pose;
      }
    }
    return lookup(cameraKey, modelId);
  }
}
