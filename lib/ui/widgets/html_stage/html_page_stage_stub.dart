import 'package:flutter/material.dart';

import '../../../models/slide_model.dart';
import 'html_stage_document.dart';

class HtmlPageTransitionStage extends StatelessWidget {
  const HtmlPageTransitionStage({
    super.key,
    required this.from,
    required this.to,
    required this.kind,
    required this.durationMs,
    this.onReady,
  });

  final PresentationPage from;
  final PresentationPage to;
  final PresentationTransitionKind kind;
  final int durationMs;
  final VoidCallback? onReady;

  @override
  Widget build(BuildContext context) {
    if (onReady != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onReady?.call());
    }
    return HtmlPageStage(
      page: to,
      showBadge: false,
      renderMode: HtmlStageRenderMode.preview,
    );
  }
}

class HtmlBackgroundPreview extends StatelessWidget {
  const HtmlBackgroundPreview({
    super.key,
    required this.kind,
    required this.onTap,
  });

  final PresentationBackgroundKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: presentationBackgroundPreviewColors(kind),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class HtmlLiveBackground extends StatelessWidget {
  const HtmlLiveBackground({
    super.key,
    required this.kind,
    this.animationEnabled = true,
    this.animationSpeed = 1,
    this.colorsInverted = false,
  });

  final PresentationBackgroundKind kind;
  final bool animationEnabled;
  final double animationSpeed;
  final bool colorsInverted;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: presentationBackgroundVariantPreviewColors(
              kind,
              colorsInverted: colorsInverted,
            ),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
}

class HtmlComponentPreview extends StatelessWidget {
  const HtmlComponentPreview({
    super.key,
    required this.kind,
  });

  final PresentationComponentKind kind;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: presentationComponentPreviewColors(kind),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            presentationComponentIcon(kind),
            size: 20,
          ),
        ),
      );
}

class HtmlPageStage extends StatelessWidget {
  const HtmlPageStage({
    super.key,
    required this.page,
    this.selectedTextBlockId,
    this.inlineEditingTextBlockId,
    this.selectedComponentBlockId,
    this.visibleRevealStep,
    this.showBadge = true,
    this.showBackground = true,
    this.renderMode = HtmlStageRenderMode.full,
    this.onTap,
    this.cssTransform = 'none',
    this.cssOpacity = 1,
    this.cssClipPath,
    this.cssTransformOrigin = 'center center',
    this.tourPointPlacementEnabled = false,
    this.tourSurfacePickPosition,
    this.tourSurfacePickGeneration = 0,
    this.onTourSurfacePointPicked,
    this.onTourSurfacePickMissed,
    this.onTourInteraction,
    this.onTourHotspot,
    this.tourInteractionEnabled = false,
    this.tourCameraTheta,
    this.tourCameraPhi,
    this.tourCameraTargetX,
    this.tourCameraTargetY,
    this.tourCameraTargetZ,
    this.tourCameraZoom,
    this.tourCameraRevision = 0,
  });

  final PresentationPage page;
  final String? selectedTextBlockId;
  final String? inlineEditingTextBlockId;
  final String? selectedComponentBlockId;
  final int? visibleRevealStep;
  final bool showBadge;
  final bool showBackground;
  final HtmlStageRenderMode renderMode;
  final VoidCallback? onTap;
  final String cssTransform;
  final double cssOpacity;
  final String? cssClipPath;
  final String cssTransformOrigin;
  final bool tourPointPlacementEnabled;
  final Offset? tourSurfacePickPosition;
  final int tourSurfacePickGeneration;
  final ValueChanged<ModelTourSurfacePoint>? onTourSurfacePointPicked;
  final VoidCallback? onTourSurfacePickMissed;
  final VoidCallback? onTourInteraction;
  final ValueChanged<String>? onTourHotspot;
  final bool tourInteractionEnabled;
  final double? tourCameraTheta;
  final double? tourCameraPhi;
  final double? tourCameraTargetX;
  final double? tourCameraTargetY;
  final double? tourCameraTargetZ;
  final double? tourCameraZoom;
  final int tourCameraRevision;

  @override
  Widget build(BuildContext context) {
    final stage = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFF7F9FD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(
          'HTML sahnesi web uzerinde aktif olacak.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF142033),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
    if (onTap == null) {
      return stage;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: stage,
    );
  }
}

class HtmlModelCanvas extends StatelessWidget {
  const HtmlModelCanvas({
    super.key,
    required this.modelId,
    required this.animationEnabled,
    required this.autoRotate,
    required this.rotationSpeed,
    required this.zoom,
    this.cameraRadius,
    required this.exposure,
    required this.environmentImage,
    required this.orbitEnabled,
    required this.tourEnabled,
    required this.tourInteractive,
    required this.orbitTheta,
    required this.orbitPhi,
    required this.targetX,
    required this.targetY,
    required this.targetZ,
    this.pickSurfacePosition = false,
    this.onSurfacePositionPicked,
    this.onSurfacePickMissed,
  });

  final String modelId;
  final bool animationEnabled;
  final bool autoRotate;
  final double rotationSpeed;
  final double zoom;
  final double? cameraRadius;
  final double exposure;
  final String? environmentImage;
  final bool orbitEnabled;
  final bool tourEnabled;
  final bool tourInteractive;
  final double orbitTheta;
  final double orbitPhi;
  final double targetX;
  final double targetY;
  final double targetZ;
  final bool pickSurfacePosition;
  final ValueChanged<ModelTourSurfacePoint>? onSurfacePositionPicked;
  final VoidCallback? onSurfacePickMissed;

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Colors.transparent,
        child: Center(child: Icon(Icons.view_in_ar_rounded)),
      );
}
