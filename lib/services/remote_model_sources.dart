import 'package:flutter/foundation.dart';

import '../models/presentation_3d_model_catalog.dart';
import 'model_asset_service.dart';

/// Eşleştirilen Firestore modellerinin sahne (model-viewer) tarafından
/// çözülebilmesi için global kaynak kayıt defteri.
///
/// Key: model doküman ID'si (örn. "01_SWOT_Analiz_Kupu")
/// Value: imzalı yükleme kaynağı — Cloudflare R2 signed modelUrl veya yerel asset yolu.
class RemoteModelSources {
  RemoteModelSources._();

  static final Map<String, String> _sources = <String, String>{};
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Map<String, String> get all =>
      Map<String, String>.unmodifiable(_sources);

  static void registerAll(Map<String, String> sources) {
    var changed = false;
    for (final entry in sources.entries) {
      if (entry.key.trim().isEmpty || entry.value.trim().isEmpty) continue;
      final k = entry.key.trim();
      final v = entry.value.trim();
      if (_sources[k] != v) {
        _sources[k] = v;
        changed = true;
      }
    }
    if (changed) {
      revision.value += 1;
    }
  }

  static bool hasSignedSource(String modelId) {
    final key = modelId.trim();
    if (key.isEmpty) return false;
    final registered = _sources[key];
    if (registered != null && registered.isNotEmpty) {
      if (registered.startsWith('assets/') ||
          registered.startsWith('packages/')) {
        return true;
      }
      if (ModelAssetService.isSignedUrlValid(registered)) {
        return true;
      }
    }
    return findPresentation3DModelAsset(key) != null;
  }

  static String? sourceFor(String modelId) {
    final key = modelId.trim();
    if (key.isEmpty) return null;
    final registered = _sources[key];
    if (registered != null && registered.isNotEmpty) return registered;

    final localAsset = findPresentation3DModelAsset(key);
    if (localAsset != null && localAsset.assetPath.isNotEmpty) {
      _sources[key] = localAsset.assetPath;
      return localAsset.assetPath;
    }

    return null;
  }
}
