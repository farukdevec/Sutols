import 'dart:math' as math;
import 'package:flutter/painting.dart';
import '../models/slide_model.dart';

enum ReadabilityIssueKind {
  longText,
  smallFont,
  tightBox,
  outsideStage,
  lowContrast
}

class PresentationReadabilityIssue {
  const PresentationReadabilityIssue(this.blockId, this.kind);
  final String blockId;
  final ReadabilityIssueKind kind;
}

/// On-demand preflight; it does not modify blocks or claim exact browser fit.
/// Geometry uses the same 1000px reference width as the HTML renderer.
class PresentationReadabilityService {
  // A separate model does not change the background behind the text. When
  // geometry or motion makes that background uncertain, omit the contrast
  // estimate rather than treating model pixels as the plain slide color.
  static bool _hasKnownFlatBackground(
      PresentationPage page, PresentationTextBlock block) {
    if ((page.backgroundKind != PresentationBackgroundKind.plainWhite &&
            block.surface == PresentationTextSurface.none) ||
        block.textEffect != PresentationTextEffect.none) return false;
    if (page.componentBlocks.isEmpty) return true;
    final height = block.heightFactor;
    if (height == null ||
        !height.isFinite ||
        height <= 0 ||
        !block.widthFactor.isFinite ||
        block.widthFactor <= 0 ||
        !block.position.dx.isFinite ||
        !block.position.dy.isFinite ||
        block.rotationDegrees != 0 ||
        block.entranceAnimation != PresentationEntranceAnimation.none ||
        block.textAnimation != PresentationTextAnimation.none ||
        block.overflow == PresentationTextOverflow.expand) return false;
    final textBounds = Rect.fromLTWH(
        block.position.dx, block.position.dy, block.widthFactor, height);
    for (final component in page.componentBlocks) {
      if (component.entranceAnimation != PresentationEntranceAnimation.none ||
          !component.position.dx.isFinite ||
          !component.position.dy.isFinite ||
          !component.size.width.isFinite ||
          !component.size.height.isFinite ||
          component.size.width <= 0 ||
          component.size.height <= 0) return false;
      final componentBounds = Rect.fromLTWH(component.position.dx,
          component.position.dy, component.size.width, component.size.height);
      // Keep a small safety margin around component edges/effects.
      if (textBounds.overlaps(componentBounds.inflate(.02))) return false;
    }
    return true;
  }

  static List<PresentationReadabilityIssue> inspect({
    required PresentationPage page,
    required double aspectRatio,
    required TextStyle Function(PresentationTextBlock) styleFor,
  }) {
    final issues = <PresentationReadabilityIssue>[];
    final stageHeight =
        1000 / (aspectRatio.isFinite ? aspectRatio.clamp(.2, 5) : 16 / 9);
    for (final block in page.textBlocks) {
      if (block.text.trim().isEmpty) continue;
      if (_hasKnownFlatBackground(page, block)) {
        final hex = block.textColorHex;
        if (hex != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
          final textColor =
              Color(0xff000000 | int.parse(hex.substring(1), radix: 16));
          final background = block.surfaceColor ??
              (page.backgroundColorsInverted
                  ? const Color(0xff000000)
                  : const Color(0xffffffff));
          final a = textColor.computeLuminance();
          final b = background.computeLuminance();
          final ratio = (math.max(a, b) + .05) / (math.min(a, b) + .05);
          if (ratio < 4.5) {
            issues.add(PresentationReadabilityIssue(
                block.id, ReadabilityIssueKind.lowContrast));
          }
        }
      }
      final words = RegExp(r'\S+').allMatches(block.text).take(101).length;
      final limit = switch (block.type) {
        PresentationTextType.title => 18,
        PresentationTextType.subtitle => 30,
        PresentationTextType.body => 85,
      };
      if (words > limit) {
        issues.add(PresentationReadabilityIssue(
            block.id, ReadabilityIssueKind.longText));
      }
      if (block.fontSize.isFinite && block.fontSize < 18) {
        issues.add(PresentationReadabilityIssue(
            block.id, ReadabilityIssueKind.smallFont));
      }
      if (block.position.dx < 0 ||
          block.position.dy < 0 ||
          block.position.dx + block.widthFactor > 1.001 ||
          block.position.dy >= 1 ||
          (block.heightFactor != null &&
              block.position.dy + block.heightFactor! > 1.001)) {
        issues.add(PresentationReadabilityIssue(
            block.id, ReadabilityIssueKind.outsideStage));
      }
      // A free-height box can grow naturally. Only diagnose bounded boxes.
      if (block.heightFactor == null ||
          block.text.length > 16000 ||
          !block.fontSize.isFinite ||
          !block.widthFactor.isFinite ||
          !block.heightFactor!.isFinite ||
          !block.padding.isFinite ||
          !block.effectiveLineHeight.isFinite) continue;
      final width = block.widthFactor * 1000 - block.padding * 2;
      final height = block.heightFactor! * stageHeight - block.padding * 2;
      if (width <= 0 || height <= 0) {
        issues.add(PresentationReadabilityIssue(
            block.id, ReadabilityIssueKind.tightBox));
        continue;
      }
      final size = block.overflow == PresentationTextOverflow.shrink
          ? math.min(block.fontSize, 18.0)
          : block.fontSize;
      final painter = TextPainter(
        text: TextSpan(
            text: block.text,
            style: styleFor(block).copyWith(
                fontSize: size.clamp(1, 500),
                height: block.effectiveLineHeight.clamp(.5, 5))),
        textDirection: TextDirection.ltr,
      );
      try {
        painter.layout(maxWidth: width);
        if (painter.height > height + 1 || painter.width > width + 1) {
          issues.add(PresentationReadabilityIssue(
              block.id, ReadabilityIssueKind.tightBox));
        }
      } finally {
        painter.dispose();
      }
    }
    return List.unmodifiable(issues);
  }
}
