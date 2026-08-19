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
  final remoteEntries = <MapEntry<String, String>>[];
  for (final entry in baseSources.entries) {
    if (entry.value.startsWith('assets/') ||
        entry.value.startsWith('packages/')) {
      resolvedSources[entry.key] = entry.value;
      continue;
    }
    remoteEntries.add(entry);
  }

  // Her modelin yetkilendirmesi birbirinden bağımsızdır. Bunları sırayla
  // beklemek, model sayısı arttıkça üretim süresini doğrusal büyütüyordu.
  final signedSources = await _mapConcurrentOrdered(
    remoteEntries,
    (entry) async {
      try {
        final signedUrl =
            await ModelAssetService.generateSignedUrl(entry.value);
        if (signedUrl != null && signedUrl.trim().isNotEmpty) {
          return MapEntry(entry.key, signedUrl.trim());
        }
      } catch (_) {}
      return null;
    },
    concurrency: 6,
  );
  for (final entry in signedSources.whereType<MapEntry<String, String>>()) {
    resolvedSources[entry.key] = entry.value;
  }

  // Fallback for missing model IDs not found in catalog or catalog asset paths
  for (final id in missingIds) {
    if (!resolvedSources.containsKey(id)) {
      final fallbackSource = RemoteModelSources.sourceFor(id) ?? id;
      if (!fallbackSource.startsWith('assets/') && !fallbackSource.startsWith('packages/')) {
        try {
          final signedUrl = await ModelAssetService.generateSignedUrl(fallbackSource);
          if (signedUrl != null && signedUrl.trim().isNotEmpty) {
            resolvedSources[id] = signedUrl.trim();
          }
        } catch (_) {}
      }
    }
  }

  if (resolvedSources.isNotEmpty) {
    RemoteModelSources.registerAll(resolvedSources);
  }
}

Future<List<R>> _mapConcurrentOrdered<T, R>(
  List<T> items,
  Future<R> Function(T item) operation, {
  required int concurrency,
}) async {
  final results = <R>[];
  for (var start = 0; start < items.length; start += concurrency) {
    final end = (start + concurrency).clamp(0, items.length);
    results.addAll(await Future.wait(items.sublist(start, end).map(operation)));
  }
  return results;
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
