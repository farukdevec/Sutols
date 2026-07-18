import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';

void main() {
  test('undo and redo restore deck mutations', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);

    expect(controller.pages, hasLength(1));
    expect(controller.canUndo, isFalse);

    controller.addPage();
    expect(controller.pages, hasLength(2));
    expect(controller.canUndo, isTrue);

    controller.undo();
    expect(controller.pages, hasLength(1));
    expect(controller.canRedo, isTrue);

    controller.redo();
    expect(controller.pages, hasLength(2));
    expect(controller.canRedo, isFalse);
  });

  test('undo and redo restore effect settings', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);

    controller.updateTransitionKind(PresentationTransitionKind.zoom);
    expect(
      controller.effectSettings.transitionKind,
      PresentationTransitionKind.zoom,
    );

    controller.undo();
    expect(
      controller.effectSettings.transitionKind,
      PresentationTransitionKind.slide,
    );

    controller.redo();
    expect(
      controller.effectSettings.transitionKind,
      PresentationTransitionKind.zoom,
    );
  });

  test('selected text and components can be copied duplicated and deleted', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.addComponentBlock(PresentationComponentKind.edebiyat01);
    controller.selectItems(
      textBlockIds: const <String>['text-1'],
      componentBlockIds: const <String>['component-1'],
    );

    controller.copySelectedItems();
    expect(controller.canPasteItems, isTrue);

    controller.pasteCopiedItems();
    expect(controller.selectedPage.textBlocks, hasLength(2));
    expect(controller.selectedPage.componentBlocks, hasLength(2));
    expect(controller.selectedItemCount, 2);

    controller.undo();
    expect(controller.selectedPage.textBlocks, hasLength(1));
    expect(controller.selectedPage.componentBlocks, hasLength(1));

    controller.duplicateSelectedItems();
    expect(controller.selectedPage.textBlocks, hasLength(2));
    expect(controller.selectedPage.componentBlocks, hasLength(2));

    controller.removeSelectedItems();
    expect(controller.selectedPage.textBlocks, hasLength(1));
    expect(controller.selectedPage.componentBlocks, hasLength(1));
  });
}
