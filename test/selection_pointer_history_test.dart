import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';

void main() {
  PresentationController setup() {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(const [
      PresentationPage(id: 'p', textBlocks: [
        PresentationTextBlock(
            id: 't',
            text: 'Metin korunur',
            position: Offset(.1, .1),
            fontSize: 30,
            type: PresentationTextType.body,
            widthFactor: .3),
      ])
    ]);
    controller.selectTextBlock('t');
    return controller;
  }

  const canvas = Size(1000, 600);

  testWidgets('held pointer pause keeps one drag as one undo step',
      (tester) async {
    final controller = setup();
    final before = controller.selectedTextBlock!;
    controller.beginSelectionPointerInteraction(1);
    controller.moveSelectedText(const Offset(10, 0), canvas);
    await tester.pump(const Duration(milliseconds: 600));
    controller.moveSelectedText(const Offset(20, 0), canvas);
    controller.endSelectionPointerInteraction(1);
    final after = controller.selectedTextBlock!.position;
    expect(after.dx, closeTo(.13, .00001));
    controller.undo();
    expect(controller.selectedTextBlock!.position, before.position);
    expect(controller.selectedTextBlock!.text, before.text);
    expect(controller.canUndo, isFalse);
    controller.redo();
    expect(controller.selectedTextBlock!.position, after);
  });

  testWidgets('two quick released gestures remain separate undo steps',
      (tester) async {
    final controller = setup();
    controller.beginSelectionPointerInteraction(1);
    controller.moveSelectedText(const Offset(10, 0), canvas);
    controller.endSelectionPointerInteraction(1);
    final first = controller.selectedTextBlock!.position;
    controller.beginSelectionPointerInteraction(2);
    controller.moveSelectedText(const Offset(20, 0), canvas);
    controller.endSelectionPointerInteraction(2);
    controller.undo();
    expect(controller.selectedTextBlock!.position, first);
    controller.undo();
    expect(controller.selectedTextBlock!.position, const Offset(.1, .1));
    expect(controller.canUndo, isFalse);
  });

  testWidgets(
      'clicks without transforms add no history, keyboard bursts still expire',
      (tester) async {
    final controller = setup();
    controller.beginSelectionPointerInteraction(1);
    controller.endSelectionPointerInteraction(1);
    expect(controller.canUndo, isFalse);
    controller.nudgeSelectedItems(const Offset(1, 0));
    controller.nudgeSelectedItems(const Offset(1, 0));
    final firstBurst = controller.selectedTextBlock!.position;
    await tester.pump(const Duration(milliseconds: 300));
    controller.nudgeSelectedItems(const Offset(1, 0));
    controller.undo();
    expect(controller.selectedTextBlock!.position, firstBurst);
    controller.undo();
    expect(controller.selectedTextBlock!.position, const Offset(.1, .1));
  });

  testWidgets('multi pointer and cancellation do not leak drag grouping',
      (tester) async {
    final controller = setup();
    controller.beginSelectionPointerInteraction(1);
    controller.beginSelectionPointerInteraction(2);
    controller.moveSelectedText(const Offset(10, 0), canvas);
    controller.endSelectionPointerInteraction(1);
    await tester.pump(const Duration(milliseconds: 500));
    controller.moveSelectedText(const Offset(10, 0), canvas);
    final dragged = controller.selectedTextBlock!.position;
    controller.cancelSelectionPointerInteractions();
    controller.nudgeSelectedItems(const Offset(1, 0));
    controller.undo();
    expect(controller.selectedTextBlock!.position, dragged);
    controller.undo();
    expect(controller.selectedTextBlock!.position, const Offset(.1, .1));
    expect(controller.canUndo, isFalse);
  });
}
