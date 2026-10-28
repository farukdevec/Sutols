import '../models/presentation_3d_model_catalog.dart';

enum ModelCapabilityFilter { all, smallDownload, animated, virtualTour }

/// Unknown metadata does not prove a capability. Small download is a file-size
/// filter, not a claim about frame rate, texture memory or GPU consumption.
bool modelMatchesCapability(String id, ModelCapabilityFilter filter) {
  if (filter == ModelCapabilityFilter.all) return true;
  final asset = findPresentation3DModelAsset(id);
  if (asset == null) return false;
  return switch (filter) {
    ModelCapabilityFilter.all => true,
    ModelCapabilityFilter.smallDownload =>
      asset.byteSize > 0 && asset.byteSize <= 1024 * 1024,
    ModelCapabilityFilter.animated => asset.hasAnimations,
    ModelCapabilityFilter.virtualTour => asset.supportsVirtualTour,
  };
}
