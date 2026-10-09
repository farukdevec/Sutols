import 'dart:ui';
import '../models/slide_model.dart';

/// Explicit, reversible layout choices. Content, identities, camera and motion
/// remain untouched; text fit is checked separately by the readability tool.
enum PresentationComposition { focus, comparison, annotated, process, data }

class PresentationCompositionService {
  static bool supports(PresentationPage page, PresentationComposition layout) {
    final titles = page.textBlocks
        .where((b) => b.type == PresentationTextType.title)
        .length;
    final bodyCount = page.textBlocks.length - titles;
    if (titles > 1 || bodyCount > 4) return false;
    return switch (layout) {
      PresentationComposition.focus => page.componentBlocks.length <= 1,
      PresentationComposition.comparison =>
        page.componentBlocks.length == 2 && bodyCount <= 2,
      PresentationComposition.annotated => page.componentBlocks.length == 1,
      PresentationComposition.process => page.componentBlocks.length >= 2 &&
          page.componentBlocks.length <= 3 &&
          bodyCount <= page.componentBlocks.length,
      PresentationComposition.data => page.componentBlocks.length <= 1,
    };
  }

  static PresentationPage apply(
      PresentationPage page, PresentationComposition layout) {
    if (!supports(page, layout)) return page;
    final bodies = page.textBlocks
        .where((b) => b.type != PresentationTextType.title)
        .toList();
    final components = page.componentBlocks;
    final textSlots = <Rect>[];
    final componentSlots = <Rect>[];
    switch (layout) {
      case PresentationComposition.focus:
        if (components.isEmpty) {
          _rows(textSlots, bodies.length,
              const Rect.fromLTWH(.08, .25, .84, .67));
        } else {
          _rows(textSlots, bodies.length,
              const Rect.fromLTWH(.06, .26, .42, .66));
          componentSlots.add(const Rect.fromLTWH(.53, .25, .41, .66));
        }
      case PresentationComposition.comparison:
        componentSlots.addAll(const [
          Rect.fromLTWH(.06, .25, .42, .43),
          Rect.fromLTWH(.52, .25, .42, .43)
        ]);
        textSlots.addAll(const [
          Rect.fromLTWH(.06, .73, .42, .20),
          Rect.fromLTWH(.52, .73, .42, .20)
        ]);
      case PresentationComposition.annotated:
        componentSlots.add(const Rect.fromLTWH(.30, .27, .40, .63));
        textSlots.addAll(const [
          Rect.fromLTWH(.04, .27, .23, .29),
          Rect.fromLTWH(.73, .27, .23, .29),
          Rect.fromLTWH(.04, .61, .23, .29),
          Rect.fromLTWH(.73, .61, .23, .29)
        ]);
      case PresentationComposition.process:
        final count = components.length;
        final width = (.88 - .04 * (count - 1)) / count;
        for (var i = 0; i < count; i++) {
          final x = .06 + i * (width + .04);
          componentSlots.add(Rect.fromLTWH(x, .26, width, .44));
          textSlots.add(Rect.fromLTWH(x, .75, width, .18));
        }
      case PresentationComposition.data:
        final area = components.isEmpty
            ? const Rect.fromLTWH(.06, .26, .88, .66)
            : const Rect.fromLTWH(.06, .26, .43, .66);
        if (bodies.length < 3) {
          _rows(textSlots, bodies.length, area);
        } else {
          final width = (area.width - .03) / 2;
          final height = (area.height - .03) / 2;
          for (var i = 0; i < bodies.length; i++) {
            textSlots.add(Rect.fromLTWH(area.left + (i % 2) * (width + .03),
                area.top + (i ~/ 2) * (height + .03), width, height));
          }
        }
        if (components.isNotEmpty)
          componentSlots.add(const Rect.fromLTWH(.54, .26, .40, .66));
    }
    var bodyIndex = 0;
    return page.copyWith(
      textBlocks: page.textBlocks.map((block) {
        final slot = block.type == PresentationTextType.title
            ? const Rect.fromLTWH(.06, .05, .88, .15)
            : textSlots[bodyIndex++];
        return block.copyWith(
            position: slot.topLeft,
            widthFactor: slot.width,
            heightFactor: slot.height);
      }).toList(growable: false),
      componentBlocks: [
        for (var i = 0; i < components.length; i++)
          components[i].copyWith(
              position: componentSlots[i].topLeft, size: componentSlots[i].size)
      ],
    );
  }

  static void _rows(List<Rect> slots, int count, Rect area) {
    if (count == 0) return;
    final height = (area.height - .03 * (count - 1)) / count;
    for (var i = 0; i < count; i++)
      slots.add(Rect.fromLTWH(
          area.left, area.top + i * (height + .03), area.width, height));
  }
}
