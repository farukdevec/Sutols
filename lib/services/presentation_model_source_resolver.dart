import '../models/slide_model.dart';
import 'model_repository.dart';
import 'remote_model_sources.dart';

/// Kaydedilmiş sunumlardaki model kimliklerini gerçek GLB adresleriyle
/// eşleştirir. Eski proje dosyaları yalnızca kimliği sakladığı için bu adım,
/// yeniden açılan sunumlarda modellerin boş görünmesini engeller.
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
  RemoteModelSources.registerAll(
    modelSourcesForIds(missingIds, catalog),
  );
}

Map<String, String> modelSourcesForIds(
  Set<String> modelIds,
  Iterable<ModelCatalogEntry> catalog,
) {
  return <String, String>{
    for (final model in catalog)
      if (modelIds.contains(model.id) && model.modelUrl.trim().isNotEmpty)
        model.id: model.modelUrl,
  };
}
