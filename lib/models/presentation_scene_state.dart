import 'package:flutter/foundation.dart';

import 'slide_model.dart';

/// Persistent scene identity and normalized model pose. Loading progress,
/// signed URLs, DOM handles and visibility belong to the renderer, not this state.
@immutable
class PresentationSceneState {
  const PresentationSceneState._({
    required this.pageId,
    required this.block,
    required this.assetVersion,
  });

  static const version = 1;
  final String pageId;
  final PresentationComponentBlock block;
  final String? assetVersion;
  String get blockId => block.id;
  String? get modelId => block.modelAssetId;

  static double effectiveExposure(PresentationComponentBlock block) =>
      normalizeBlock(block).modelExposure ??
      findPresentation3DModelAsset(block.modelAssetId ?? '')?.exposure ??
      1;

  factory PresentationSceneState.fromComponent({
    required String pageId,
    required PresentationComponentBlock block,
  }) =>
      PresentationSceneState._(
        pageId: pageId,
        block: normalizeBlock(block),
        assetVersion: block.modelAssetId == null
            ? null
            : findPresentation3DModelAsset(block.modelAssetId!)?.sha256,
      );

  /// Use the existing project codec limits in every rendering surface. Valid
  /// angles remain unwrapped so a saved turntable/tour does not jump at 360°.
  static PresentationComponentBlock normalizeBlock(
      PresentationComponentBlock block) {
    if (block.modelAssetId == null) return block;
    double finite(double value, double fallback) =>
        value.isFinite ? value : fallback;
    double bounded(double value, double fallback, double min, double max) =>
        finite(value, fallback).clamp(min, max).toDouble();
    final radius = block.modelCameraRadius;
    final clip = block.modelAnimationName;
    return block.copyWith(
      modelAnimationTime: bounded(block.modelAnimationTime, 0, 0, 86400),
      modelAnimationName: clip != null && clip.trim().isEmpty ? null : clip,
      modelRotationSpeed: finite(block.modelRotationSpeed, 30),
      modelZoom: bounded(block.modelZoom, 1, .5, 10),
      modelCameraRadius: radius == null || !radius.isFinite
          ? null
          : radius.clamp(.001, 100000).toDouble(),
      modelTurntableRotation: finite(block.modelTurntableRotation, 0),
      modelFieldOfView: bounded(block.modelFieldOfView, 45, 1, 179),
      modelExposure:
          block.modelExposure == null || !block.modelExposure!.isFinite
              ? null
              : block.modelExposure!.clamp(.1, 3).toDouble(),
      modelOrbitTheta: finite(block.modelOrbitTheta, 0),
      modelOrbitPhi: finite(block.modelOrbitPhi, 75),
      modelTargetX: bounded(block.modelTargetX, 0, -500, 500),
      modelTargetY: bounded(block.modelTargetY, 0, -500, 500),
      modelTargetZ: bounded(block.modelTargetZ, 0, -500, 500),
    );
  }
}
