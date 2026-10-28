import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_composition_service.dart';
import 'package:sutol/state/presentation_controller.dart';

void main() {
  const title = PresentationTextBlock(
      id: 'title',
      text: 'Türkçe başlık',
      position: Offset(.1, .1),
      fontSize: 48,
      type: PresentationTextType.title,
      widthFactor: .6);
  const body = PresentationTextBlock(
      id: 'body',
      text: 'İçerik anlamı ve biçimi korunmalı.',
      position: Offset(.2, .5),
      fontSize: 26,
      type: PresentationTextType.body,
      widthFactor: .6,
      textColorHex: '#123456',
      textBold: true,
      revealStep: 2);
  const model = PresentationComponentBlock(
      id: 'model',
      modelAssetId: 'sutols-water-molecule',
      position: Offset(.5, .5),
      size: Size(.4, .4),
      modelOrbitTheta: 41,
      modelAnimationName: 'Spin',
      modelAnimationTime: 2.4);
  for (final layout in PresentationComposition.values) {
    test('$layout preserves content and scene state in bounded slots', () {
      final page = PresentationPage(
          id: 'p',
          textBlocks: [title, body],
          componentBlocks: [
            model,
            if (layout == PresentationComposition.comparison ||
                layout == PresentationComposition.process)
              model.copyWith(id: 'second')
          ],
          speakerNotes: 'Notlar',
          backgroundKind: PresentationBackgroundKind.plainWhite);
      final next = PresentationCompositionService.apply(page, layout);
      expect(next.id, page.id);
      expect(next.speakerNotes, page.speakerNotes);
      expect(next.textBlocks.map((b) => b.text),
          page.textBlocks.map((b) => b.text));
      expect(next.textBlocks.last.fontSize, 26);
      expect(next.textBlocks.last.textColorHex, '#123456');
      expect(next.textBlocks.last.revealStep, 2);
      for (final block in next.textBlocks) {
        expect(block.position.dx, greaterThanOrEqualTo(0));
        expect(block.position.dy + block.heightFactor!, lessThanOrEqualTo(1));
        expect(block.position.dx + block.widthFactor, lessThanOrEqualTo(1));
      }
      for (final block in next.componentBlocks) {
        expect(block.modelOrbitTheta, 41);
        expect(block.modelAnimationName, 'Spin');
        expect(block.modelAnimationTime, 2.4);
        expect(block.position.dx + block.size.width, lessThanOrEqualTo(1));
        expect(block.position.dy + block.size.height, lessThanOrEqualTo(1));
      }
    });
  }
  test('four data descriptions occupy separate readable geometry slots', () {
    final page = PresentationPage(id: 'data', textBlocks: [
      title,
      for (var i = 0; i < 4; i++) body.copyWith(id: 'body-$i')
    ]);
    final next = PresentationCompositionService.apply(
        page, PresentationComposition.data);
    final slots = next.textBlocks
        .map((b) => Rect.fromLTWH(
            b.position.dx, b.position.dy, b.widthFactor, b.heightFactor!))
        .toList();
    for (var i = 0; i < slots.length; i++) {
      for (var j = i + 1; j < slots.length; j++) {
        expect(slots[i].overlaps(slots[j]), isFalse);
      }
    }
    expect(next.textBlocks.skip(1).map((b) => b.fontSize), everyElement(26));
    expect(
        next.textBlocks.map((b) => b.text), page.textBlocks.map((b) => b.text));
  });
  test('unsupported layouts leave every block unchanged', () {
    final page = PresentationPage(id: 'p', textBlocks: [
      title,
      for (var i = 0; i < 5; i++) body.copyWith(id: 'b$i')
    ], componentBlocks: [
      model
    ]);
    for (final layout in PresentationComposition.values) {
      expect(PresentationCompositionService.supports(page, layout), isFalse);
      expect(
          identical(PresentationCompositionService.apply(page, layout), page),
          isTrue);
    }
  });
  test(
      'layout applies only to selected slide and undo restores original objects',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    final first = PresentationPage(
        id: 'one', textBlocks: [title, body], componentBlocks: [model]);
    const second = PresentationPage(id: 'two', textBlocks: []);
    controller.replaceDeck([first, second]);
    expect(controller.applyComposition(PresentationComposition.focus), isTrue);
    expect(identical(controller.pages[1], second), isTrue);
    expect(controller.selectedPage.componentBlocks.single.position,
        isNot(model.position));
    controller.undo();
    expect(controller.selectedPage.textBlocks, first.textBlocks);
    expect(controller.selectedPage.componentBlocks, first.componentBlocks);
    expect(controller.applyComposition(PresentationComposition.comparison),
        isFalse);
  });
}
