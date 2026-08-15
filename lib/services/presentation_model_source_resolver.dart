import '../models/slide_model.dart';
import 'model_repository.dart';
import 'remote_model_sources.dart';
import 'model_asset_service.dart';

/// Kaydedilmiş sunumlardaki model kimliklerini gerçek imzalı GLB adresleriyle
/// eşleştirir. Yalnızca geçerli imzalı URL'leri kayıt defterine ekler.
Future<void> hydratePresentationModelSources(
  Iterable<PresentationPage> pages,
) async {
  final missingIds = pages
      .expand((page) => page.componentBlocks)
      .map((block) => block.modelAssetId)
      .whereType<String>()
      .where((id) => RemoteModelSources.sourceFor(id) == null)
      .toSet();
  if (missingIds.isEmpty) return;

  final catalog = await ModelRepository.instance.getModels();
  final baseSources = modelSourcesForIds(missingIds, catalog);

  final resolvedSources = <String, String>{};
  for (final entry in baseSources.entries) {
    final signedUrl = await ModelAssetService.generateSignedUrl(entry.value);
    if (signedUrl != null && signedUrl.isNotEmpty && signedUrl.contains('token=')) {
      resolvedSources[entry.key] = signedUrl;
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
  final map = <String, String>{
    for (final model in catalog)
      if (modelIds.contains(model.id) && model.modelUrl.trim().isNotEmpty)
        model.id: model.modelUrl,
  };
  for (final id in modelIds) {
    if (!map.containsKey(id) && id.trim().isNotEmpty) {
      map[id] = id;
    }
  }
  return map;
}
