import '../models/presentation_3d_model_catalog.dart';
import '../models/slide_model.dart';
import 'model_repository.dart';
import 'remote_model_sources.dart';
import 'model_asset_service.dart';

/// Kaydedilmiş sunumlardaki model kimliklerini gerçek GLB adresleriyle eşleştirir.
Future<void> hydratePresentationModelSources(
  Iterable<PresentationPage> pages,
) async {
  final missingIds = pages
      .expand((page) => page.componentBlocks)
      .map((block) => block.modelAssetId)
      .whereType<String>()
      .where((id) => !RemoteModelSources.hasSignedSource(id))
      .toSet();
  if (missingIds.isEmpty) return;

  final catalog = await ModelRepository.instance.getModels();
  final baseSources = modelSourcesForIds(missingIds, catalog);

  final resolvedSources = <String, String>{};
  for (final entry in baseSources.entries) {
    if (entry.value.startsWith('assets/') || entry.value.startsWith('packages/')) {
      resolvedSources[entry.key] = entry.value;
      continue;
    }
    String? signedUrl;
    try {
      signedUrl = await ModelAssetService.generateSignedUrl(entry.value);
    } catch (_) {}
    if (signedUrl != null && signedUrl.trim().isNotEmpty) {
      resolvedSources[entry.key] = signedUrl.trim();
    }
  }

  if (resolvedSources.isNotEmpty) {
    RemoteModelSources.registerAll(resolvedSources);
  }
}

Map<String, String> modelSourcesForIds(
  Set<String> modelIds,
  Iterable<ModelCatalogEntry> catalog,
) {
  final map = <String, String>{};
  for (final model in catalog) {
    if (modelIds.contains(model.id) && model.modelUrl.trim().isNotEmpty) {
      map[model.id] = model.modelUrl.trim();
    }
  }
  for (final asset in presentation3DModelCatalog) {
    if (modelIds.contains(asset.id) && asset.assetPath.trim().isNotEmpty) {
      map.putIfAbsent(asset.id, () => asset.assetPath.trim());
    }
  }
  return map;
}
