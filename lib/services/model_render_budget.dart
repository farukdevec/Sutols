import '../models/slide_model.dart';

/// Floors for model-viewer 4.3.1's own stepped, hysteretic GPU scaler.
/// This affects model pixels only, never Flutter text or slide geometry.
double modelMinimumRenderScale(PresentationRenderQuality quality) =>
    switch (quality) {
      PresentationRenderQuality.economy => .4,
      PresentationRenderQuality.balanced => .5,
      PresentationRenderQuality.high => .79,
    };

/// A document shares one renderer. Honor the strictest visible consumer;
/// hidden consumers must not keep another slide's quality unnecessarily high.
double sharedModelMinimumRenderScale(
    Iterable<PresentationRenderQuality> active) {
  var floor = .0;
  for (final quality in active) {
    final candidate = modelMinimumRenderScale(quality);
    if (candidate > floor) floor = candidate;
  }
  return floor == 0 ? .5 : floor;
}
