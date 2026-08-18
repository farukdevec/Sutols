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

class HtmlPageStage extends StatelessWidget {
  const HtmlPageStage({
    super.key,
    required this.page,
    this.selectedTextBlockId,
    this.inlineEditingTextBlockId,
    this.selectedComponentBlockId,
    this.visibleRevealStep,
    this.showBadge = true,
    this.renderMode = HtmlStageRenderMode.full,
    this.onTap,
    this.cssTransform = 'none',
    this.cssOpacity = 1,
    this.cssClipPath,
    this.cssTransformOrigin = 'center center',
  });

  final PresentationPage page;
  final String? selectedTextBlockId;
  final String? inlineEditingTextBlockId;
  final String? selectedComponentBlockId;
  final int? visibleRevealStep;
  final bool showBadge;
  final HtmlStageRenderMode renderMode;
  final VoidCallback? onTap;
  final String cssTransform;
  final double cssOpacity;
  final String? cssClipPath;
  final String cssTransformOrigin;

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
