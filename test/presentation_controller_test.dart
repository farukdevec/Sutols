import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';

void main() {
  test('newly added 3D models animate and rotate automatically', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);

    controller.add3DModelBlock(
      const Presentation3DModelAsset(
        id: 'animated-model',
        label: 'Animated model',
        assetPath: 'https://example.com/animated-model.glb',
        category: 'Test',
        tags: <String>[],
        byteSize: 0,
        sha256: '',
        hasAnimations: true,
      ),
    );

    final modelBlock = controller.selectedComponentBlock!;
    expect(modelBlock.modelAnimationEnabled, isTrue);
    expect(modelBlock.modelAutoRotate, isTrue);
  });

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

  test('page operations addPageAfter duplicatePage movePage and removePageAt work correctly', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);

    expect(controller.pages, hasLength(1));
    final initialPageId = controller.selectedPage.id;

    // Add page after index 0
    controller.addPageAfter(0);
    expect(controller.pages, hasLength(2));
    expect(controller.selectedIndex, 1);

    // Duplicate page at index 1
    controller.duplicatePage(1);
    expect(controller.pages, hasLength(3));
    expect(controller.selectedIndex, 2);

    // Move page down and up
    controller.movePageUp(2);
    expect(controller.selectedIndex, 1);

    controller.movePageDown(1);
    expect(controller.selectedIndex, 2);

    // Remove page at index 2
    controller.removePageAt(2);
    expect(controller.pages, hasLength(2));

    // Test undo restores previous pages state
    controller.undo();
    expect(controller.pages, hasLength(3));
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

  test('uploaded photos are separate from models and use their image ratio',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);

    controller.addUploadedImageBlock('photo-portrait', aspectRatio: 0.75);
    final portrait = controller.selectedComponentBlock!;
    expect(portrait.imageAssetId, 'photo-portrait');
    expect(portrait.modelAssetId, isNull);
    expect(portrait.imageAspectRatio, 0.75);
    expect(
      portrait.size.width / portrait.size.height,
      closeTo(0.75 / (16 / 9), 0.0001),
    );
    controller.resizeSelectedComponentByHandle(
      const Offset(120, 0),
      const Size(1000, 562.5),
      fromLeft: false,
      fromTop: false,
      fromRight: true,
      fromBottom: false,
    );
    final resizedPortrait = controller.selectedComponentBlock!;
    expect(
      resizedPortrait.size.width / resizedPortrait.size.height,
      closeTo(0.75 / (16 / 9), 0.0001),
    );

    controller.addUploadedImageBlock('photo-landscape', aspectRatio: 2.0);
    final landscape = controller.selectedComponentBlock!;
    expect(landscape.size.width / landscape.size.height,
        closeTo(2.0 / (16 / 9), 0.0001));
  });

  test('selected text can be resized from every edge', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);

    controller.resizeSelectedTextByHandle(
      const Offset(100, 0),
      const Size(1000, 500),
      renderedHeightFactor: 0.2,
      fromLeft: false,
      fromTop: false,
      fromRight: true,
      fromBottom: false,
    );
    expect(controller.selectedTextBlock!.widthFactor, closeTo(0.44, 0.0001));

    controller.resizeSelectedTextByHandle(
      const Offset(50, 0),
      const Size(1000, 500),
      renderedHeightFactor: 0.2,
      fromLeft: true,
      fromTop: false,
      fromRight: false,
      fromBottom: false,
    );
    expect(controller.selectedTextBlock!.position.dx, closeTo(0.17, 0.0001));
    expect(controller.selectedTextBlock!.widthFactor, closeTo(0.39, 0.0001));

    controller.resizeSelectedTextByHandle(
      const Offset(0, 90),
      const Size(1000, 500),
      renderedHeightFactor: 0.2,
      fromLeft: false,
      fromTop: false,
      fromRight: false,
      fromBottom: true,
    );
    expect(controller.selectedTextBlock!.heightFactor, closeTo(0.38, 0.0001));
    expect(controller.selectedTextBlock!.fontSize, closeTo(91.2, 0.0001));

    controller.resizeSelectedTextByHandle(
      const Offset(0, 25),
      const Size(1000, 500),
      renderedHeightFactor: 0.38,
      fromLeft: false,
      fromTop: true,
      fromRight: false,
      fromBottom: false,
    );
    expect(controller.selectedTextBlock!.position.dy, closeTo(0.21, 0.0001));
    expect(controller.selectedTextBlock!.heightFactor, closeTo(0.33, 0.0001));
    expect(controller.selectedTextBlock!.fontSize, closeTo(79.2, 0.0001));
  });
}
