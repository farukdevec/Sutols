import '../models/slide_model.dart';

class PresentationExportAssetException implements Exception {
  PresentationExportAssetException(Iterable<String> missing)
      : missingModelIds = Set.unmodifiable(missing);
  final Set<String> missingModelIds;
  @override
  String toString() =>
      'Presentation export missing ${missingModelIds.length} model assets';
}

/// Model downloads must finish before offering the HTML download. Image-only
/// blocks (including legacy image IDs) are not model download requirements.
void requireEmbeddedExportModels(
    {required List<PresentationPage> pages,
    required Map<String, String> modelSources,
    Set<String> imageIds = const {}}) {
  final required = pages
      .expand((p) => p.componentBlocks)
      .where(
          (b) => b.imageAssetId == null && !imageIds.contains(b.modelAssetId))
      .map((b) => b.modelAssetId)
      .whereType<String>()
      .toSet();
  final missing = required.where((id) => modelSources[id]?.isNotEmpty != true);
  if (missing.isNotEmpty) throw PresentationExportAssetException(missing);
}
