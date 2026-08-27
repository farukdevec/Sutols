import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/model_tour_runtime.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';

void main() {
  test('render edilen kesin kamera pozu önizleme stateine kaydedilir', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(
      const <PresentationPage>[
        PresentationPage(
          id: 'camera-page',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'camera-model',
              modelAssetId: 'anitkabir',
              modelTourEnabled: true,
              position: Offset.zero,
              size: Size(1, 1),
            ),
          ],
        ),
      ],
    );

    expect(
      controller.syncRenderedModelCameraPoses(
        const <String, ModelViewerCameraPose>{
          'camera-page:camera-model': ModelViewerCameraPose(
            theta: 32,
            phi: 84,
            radius: 17.625,
            targetX: 4,
            targetY: -2,
            targetZ: 11,
            turntableRotation: 1.2345,
            fieldOfView: 37.25,
          ),
        },
      ),
      isTrue,
    );

    final editorModel = controller.pages.single.componentBlocks.single;
    expect(editorModel.modelOrbitTheta, 32);
    expect(editorModel.modelOrbitPhi, 84);
    expect(editorModel.modelCameraRadius, 17.625);
    expect(editorModel.modelTurntableRotation, 1.2345);
    expect(editorModel.modelFieldOfView, 37.25);
    expect(editorModel.modelTargetX, 4);
    expect(editorModel.modelTargetY, -2);
    expect(editorModel.modelTargetZ, 11);

    final previewController = PresentationController();
    addTearDown(previewController.dispose);
    previewController.replaceDeck(controller.pages);
    previewController.commitAllModelTourPoses();
    final previewModel = previewController.pages.single.componentBlocks.single;
    expect(previewModel.modelCameraRadius, 17.625);
    expect(previewModel.modelTurntableRotation, 1.2345);
    expect(previewModel.modelFieldOfView, 37.25);
    expect(previewModel.modelOrbitTheta, 32);
    expect(previewModel.modelOrbitPhi, 84);
    expect(previewModel.modelTargetX, 4);
    expect(previewModel.modelTargetY, -2);
    expect(previewModel.modelTargetZ, 11);
  });

  test('sunum kopyası editör kamera stateini değiştirmeden taşır', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(
      const <PresentationPage>[
        PresentationPage(
          id: 'camera-page',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'camera-model',
              modelAssetId: 'anitkabir',
              modelTourEnabled: true,
              modelOrbitTheta: 145,
              modelOrbitPhi: 78,
              modelTargetX: 4,
              modelTargetY: -2,
              modelTargetZ: 11,
              modelZoom: 3.25,
              modelTurntableRotation: 2.3456,
              modelFieldOfView: 39.5,
              position: Offset.zero,
              size: Size(1, 1),
            ),
          ],
        ),
      ],
    );

    final previewController = PresentationController();
    addTearDown(previewController.dispose);
    previewController.replaceDeck(
      controller.pages.toList(growable: false),
      effectSettings: controller.effectSettings,
    );
    previewController.commitAllModelTourPoses();

    final editorModel = controller.pages.single.componentBlocks.single;
    final previewModel = previewController.pages.single.componentBlocks.single;
    expect(previewModel.modelOrbitTheta, editorModel.modelOrbitTheta);
    expect(previewModel.modelOrbitPhi, editorModel.modelOrbitPhi);
    expect(previewModel.modelTargetX, editorModel.modelTargetX);
    expect(previewModel.modelTargetY, editorModel.modelTargetY);
    expect(previewModel.modelTargetZ, editorModel.modelTargetZ);
    expect(previewModel.modelZoom, editorModel.modelZoom);
    expect(previewModel.modelCameraRadius, editorModel.modelCameraRadius);
    expect(
      previewModel.modelTurntableRotation,
      editorModel.modelTurntableRotation,
    );
    expect(previewModel.modelFieldOfView, editorModel.modelFieldOfView);
    expect(
      previewModel.modelAnimationEnabled,
      editorModel.modelAnimationEnabled,
    );
    expect(previewModel.modelTourFrozen, isTrue);
    expect(editorModel.modelTourFrozen, isFalse);
  });

  test('aynı blok kimliği farklı sayfalarda ayrı kamera pozunu korur', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(
      const <PresentationPage>[
        PresentationPage(
          id: 'camera-page-a',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'shared-model',
              modelAssetId: 'anitkabir',
              modelOrbitTheta: 105,
              position: Offset.zero,
              size: Size(1, 1),
            ),
          ],
        ),
        PresentationPage(
          id: 'camera-page-b',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'shared-model',
              modelAssetId: 'anitkabir',
              modelOrbitTheta: 255,
              position: Offset.zero,
              size: Size(1, 1),
            ),
          ],
        ),
      ],
    );

    final previewController = PresentationController();
    addTearDown(previewController.dispose);
    previewController.replaceDeck(
      controller.pages.toList(growable: false),
      effectSettings: controller.effectSettings,
    );

    final first = previewController.pages[0].componentBlocks.single;
    final second = previewController.pages[1].componentBlocks.single;
    expect(first.modelOrbitTheta, 105);
    expect(second.modelOrbitTheta, 255);
  });

  test('çözümlenmiş tur hedefi DOM kamera karesiyle geri yazılmaz', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(
      const <PresentationPage>[
        PresentationPage(
          id: 'resolved-camera-page',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'resolved-camera-model',
              modelAssetId: 'anitkabir',
              modelTourEnabled: true,
              modelOrbitTheta: 205,
              modelOrbitPhi: 82,
              modelCameraRadius: 20,
              modelTargetX: 9,
              modelTargetY: -3,
              modelTargetZ: 4,
              position: Offset.zero,
              size: Size(1, 1),
            ),
          ],
        ),
      ],
    );

    controller.commitAllModelTourPoses();

    final model = controller.pages.single.componentBlocks.single;
    expect(model.modelOrbitTheta, 205);
    expect(model.modelOrbitPhi, 82);
    expect(model.modelCameraRadius, 20);
    expect(model.modelTargetX, 9);
    expect(model.modelTargetY, -3);
    expect(model.modelTargetZ, 4);
  });

  test('sunum hazırlığı her sayfanın tur kamerasını ayrı pozda sabitler', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(
      const <PresentationPage>[
        PresentationPage(
          id: 'tour-a',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'model-a',
              modelAssetId: 'anitkabir',
              modelTourEnabled: true,
              modelOrbitTheta: 25,
              modelTargetX: 12,
              position: Offset.zero,
              size: Size(1, 1),
            ),
          ],
        ),
        PresentationPage(
          id: 'tour-b',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'model-b',
              modelAssetId: 'anitkabir',
              modelTourEnabled: true,
              modelOrbitTheta: 210,
              modelTargetX: -18,
              position: Offset.zero,
              size: Size(1, 1),
            ),
          ],
        ),
      ],
    );

    expect(controller.commitAllModelTourPoses(), isTrue);

    final first = controller.pages[0].componentBlocks.single;
    final second = controller.pages[1].componentBlocks.single;
    expect(first.modelTourFrozen, isTrue);
    expect(second.modelTourFrozen, isTrue);
    expect(first.modelOrbitTheta, 25);
    expect(first.modelTargetX, 12);
    expect(second.modelOrbitTheta, 210);
    expect(second.modelTargetX, -18);
  });

  test('farklı tur modelleri ilk sayfa dahil tam görsel pozu korur', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(
      List<PresentationPage>.generate(3, (index) {
        return PresentationPage(
          id: 'tour-page-$index',
          textBlocks: const <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'tour-model-$index',
              modelAssetId: 'virtual-tour-model-$index',
              modelTourEnabled: true,
              modelOrbitTheta: 35 + index * 105,
              modelOrbitPhi: 55 + index * 8,
              modelCameraRadius: 12 + index * 9,
              modelTurntableRotation: .35 + index * 1.1,
              modelFieldOfView: 32 + index * 7,
              modelTargetX: -18 + index * 17,
              modelTargetZ: 24 - index * 19,
              position: Offset.zero,
              size: const Size(1, 1),
            ),
          ],
        );
      }),
    );

    final expected = controller.pages
        .map((page) => page.componentBlocks.single)
        .toList(growable: false);
    expect(controller.commitAllModelTourPoses(), isTrue);

    for (var index = 0; index < 3; index++) {
      final actual = controller.pages[index].componentBlocks.single;
      expect(actual.modelTourFrozen, isTrue);
      expect(actual.modelOrbitTheta, expected[index].modelOrbitTheta);
      expect(actual.modelOrbitPhi, expected[index].modelOrbitPhi);
      expect(actual.modelCameraRadius, expected[index].modelCameraRadius);
      expect(
        actual.modelTurntableRotation,
        expected[index].modelTurntableRotation,
      );
      expect(actual.modelFieldOfView, expected[index].modelFieldOfView);
      expect(actual.modelTargetX, expected[index].modelTargetX);
      expect(actual.modelTargetZ, expected[index].modelTargetZ);
    }
  });

  test('applying a transition requests one preview for that slide gap', () {
    final controller = PresentationController()..addPage();
    final before = controller.transitionPreviewRevision;

    controller.updateTransitionAfterPage(0, PresentationTransitionKind.cover);

    expect(controller.transitionAfterPage(0), PresentationTransitionKind.cover);
    expect(controller.transitionPreviewGapIndex, 0);
    expect(controller.transitionPreviewRevision, before + 1);

    controller.updateTransitionAfterPage(0, PresentationTransitionKind.cover);
    expect(controller.transitionPreviewRevision, before + 2);

    controller.updateTransitionAfterPage(0, PresentationTransitionKind.none);
    expect(controller.transitionPreviewRevision, before + 2);
  });

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
    expect(modelBlock.modelZoom, 1);

    controller.updateSelectedModelZoom(2.4);
    expect(controller.selectedComponentBlock!.modelZoom, 2.4);

    controller.updateSelectedModelZoom(99);
    expect(controller.selectedComponentBlock!.modelZoom, 10);
  });

  test('visuals can fill the slide background and move to layer edges', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.addComponentBlock(PresentationComponentKind.edebiyat01);
    final foregroundId = controller.selectedComponentBlock!.id;
    controller.addUploadedImageBlock('photo-1');
    final imageId = controller.selectedComponentBlock!.id;
    controller.addComponentBlock(PresentationComponentKind.edebiyat02);
    final topId = controller.selectedComponentBlock!.id;

    controller.selectComponentBlock(imageId);
    controller.setSelectedVisualAsBackground();

    final background = controller.selectedPage.componentBlocks.first;
    expect(background.id, imageId);
    expect(background.position, Offset.zero);
    expect(background.size, const Size(1, 1));

    controller.moveSelectedComponentToEdge(forward: true);
    expect(controller.selectedPage.componentBlocks.last.id, imageId);

    controller.moveSelectedComponentToEdge(forward: false);
    expect(controller.selectedPage.componentBlocks.first.id, imageId);
    expect(
      controller.selectedPage.componentBlocks.map((block) => block.id),
      <String>[imageId, foregroundId, topId],
    );
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

  test(
      'page operations addPageAfter duplicatePage movePage and removePageAt work correctly',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);

    expect(controller.pages, hasLength(1));

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
    final reorderController = PresentationController();
    addTearDown(reorderController.dispose);
    reorderController.addPage();
    reorderController.addPage();
    final originalOrder =
        reorderController.pages.map((page) => page.id).toList();

    reorderController.reorderPage(1, 0);
    expect(
      reorderController.pages.map((page) => page.id),
      <String>[originalOrder[1], originalOrder[0], originalOrder[2]],
    );
    expect(reorderController.selectedIndex, 0);

    reorderController.reorderPage(0, 3);
    expect(
      reorderController.pages.map((page) => page.id),
      <String>[originalOrder[0], originalOrder[2], originalOrder[1]],
    );
    expect(reorderController.selectedIndex, 2);

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
      PresentationTransitionKind.none,
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

  test('3B model copy and duplicate preserve model settings', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(
      const Presentation3DModelAsset(
        id: 'copyable-model',
        label: 'Copyable model',
        assetPath: 'https://example.com/copyable.glb',
        category: 'Test',
        tags: <String>[],
        byteSize: 0,
        sha256: '',
      ),
    );
    controller.updateSelectedModelZoom(7.5);
    controller.updateSelectedModelOrbitEnabled(true);

    controller.copySelectedItems();
    controller.pasteCopiedItems();

    expect(controller.selectedPage.componentBlocks, hasLength(2));
    final copy = controller.selectedComponentBlock!;
    expect(copy.modelAssetId, 'copyable-model');
    expect(copy.modelZoom, 7.5);
    expect(copy.modelOrbitEnabled, isTrue);

    controller.duplicateSelectedItems();
    expect(controller.selectedPage.componentBlocks, hasLength(3));
    expect(controller.selectedComponentBlock!.modelAssetId, 'copyable-model');
    expect(controller.selectedComponentBlock!.modelZoom, 7.5);
  });

  test('virtual tour drag moves and resets the 3D camera target', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(
      const Presentation3DModelAsset(
        id: 'anitkabir',
        label: 'Tour model',
        assetPath: 'https://example.com/tour.glb',
        category: 'Test',
        tags: <String>[],
        byteSize: 0,
        sha256: '',
      ),
    );

    controller.updateSelectedModelTourEnabled(true);
    expect(controller.selectedComponentBlock!.modelTourEnabled, isTrue);
    expect(controller.selectedComponentBlock!.modelOrbitEnabled, isFalse);
    expect(controller.selectedComponentBlock!.modelAutoRotate, isFalse);

    controller.beginSelectedModelOrbitGesture();
    var cameraNotifications = 0;
    controller.addListener(() => cameraNotifications += 1);
    controller.lookAroundSelectedModelTour(const Offset(80, -50));
    expect(
      cameraNotifications,
      1,
      reason: 'İlk fare hareketi gecikmeden kameraya yansımalı.',
    );
    final firstMove = controller.selectedComponentBlock!;
    expect(firstMove.modelOrbitTheta, isNot(0));
    expect(firstMove.modelOrbitPhi, isNot(75));
    for (var i = 0; i < 100; i++) {
      controller.lookAroundSelectedModelTour(const Offset(1, 1));
    }
    controller.endSelectedModelOrbitGesture();
    expect(cameraNotifications, lessThan(10));

    // FPS turu modelin tabanında kalır; alt yüzeyi gösterecek açıya hiç
    // geçmeden, insan göz hizasındaki bakış aralığını korur.
    for (var i = 0; i < 40; i++) {
      controller.lookAroundSelectedModelTour(const Offset(0, 24));
    }
    expect(controller.selectedComponentBlock!.modelOrbitPhi, 89);
    for (var i = 0; i < 40; i++) {
      controller.lookAroundSelectedModelTour(const Offset(0, -24));
    }
    expect(controller.selectedComponentBlock!.modelOrbitPhi, 42);

    controller.beginSelectedModelOrbitGesture();
    controller.moveSelectedModelTour(forward: 20);
    controller.moveSelectedModelTour(right: 15);
    controller.endSelectedModelOrbitGesture();
    final moved = controller.selectedComponentBlock!;
    expect(moved.modelTargetX.abs(), greaterThan(0));
    expect(moved.modelTargetZ.abs(), greaterThan(0));

    controller.resetSelectedModelTourPosition();
    expect(controller.selectedComponentBlock!.modelTargetX, 0);
    expect(controller.selectedComponentBlock!.modelTargetY, 0);
    expect(controller.selectedComponentBlock!.modelTargetZ, 0);
  });

  test('virtual tour preview pose is saved to its slide model', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(
      const Presentation3DModelAsset(
        id: 'anitkabir',
        label: 'Tour camera model',
        assetPath: 'https://example.com/tour-camera.glb',
        category: 'Test',
        tags: <String>[],
        byteSize: 0,
        sha256: '',
      ),
    );
    controller.updateSelectedModelTourEnabled(true);
    final pageId = controller.selectedPage.id;
    final blockId = controller.selectedComponentBlock!.id;

    controller.saveModelTourPose(
      pageId: pageId,
      blockId: blockId,
      pose: const ModelTourPose(
        theta: 128,
        phi: 64,
        x: 12,
        y: 3,
        z: -7,
      ),
      zoom: 3.25,
      freeze: true,
    );

    final saved = controller.selectedComponentBlock!;
    expect(saved.modelOrbitTheta, 128);
    expect(saved.modelOrbitPhi, 64);
    expect(saved.modelTargetX, 12);
    expect(saved.modelTargetY, 3);
    expect(saved.modelTargetZ, -7);
    expect(saved.modelZoom, 3.25);
    expect(saved.modelTourFrozen, isTrue);
    expect(saved.modelAnimationEnabled, isTrue);
    expect(saved.modelAutoRotate, isFalse);

    controller.updateSelectedModelTourEnabled(true);
    expect(controller.selectedComponentBlock!.modelTourFrozen, isFalse);
  });

  test('virtual tour cannot be enabled for a non-spatial model', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(
      const Presentation3DModelAsset(
        id: 'yolcu-ucagi',
        label: 'Yolcu Uçağı',
        assetPath: 'https://example.com/plane.glb',
        category: 'Test',
        tags: <String>[],
        byteSize: 0,
        sha256: '',
      ),
    );

    controller.updateSelectedModelTourEnabled(true);

    expect(controller.selectedComponentBlock!.modelTourEnabled, isFalse);
  });

  test('virtual tour point persists as a model hotspot', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(
      const Presentation3DModelAsset(
        id: 'anitkabir',
        label: 'Tour point model',
        assetPath: 'https://example.com/tour-point.glb',
        category: 'Test',
        tags: <String>[],
        byteSize: 0,
        sha256: '',
      ),
    );

    controller.updateSelectedModelTourEnabled(true);
    controller.addSelectedModelTourHotspot(
      label: 'Giriş noktası',
      kind: ModelTourHotspotKind.text,
      x: .2,
      y: -.8,
      z: .4,
    );

    final hotspot = controller.selectedComponentBlock!.modelTourHotspots.single;
    expect(hotspot.kind, ModelTourHotspotKind.text);
    expect(hotspot.label, 'Giriş noktası');
    expect(hotspot.x, .2);
    expect(hotspot.y, -.8);
    expect(hotspot.z, .4);
  });

  test('uploaded photos start at image ratio and can then resize freely', () {
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
    expect(resizedPortrait.size.width,
        closeTo(portrait.size.width + 0.12, 0.0001));
    expect(resizedPortrait.size.height, closeTo(portrait.size.height, 0.0001));
    expect(
      resizedPortrait.size.width / resizedPortrait.size.height,
      isNot(closeTo(0.75 / (16 / 9), 0.0001)),
    );

    controller.resizeSelectedComponentByHandle(
      const Offset(0, 56.25),
      const Size(1000, 562.5),
      fromLeft: false,
      fromTop: false,
      fromRight: false,
      fromBottom: true,
    );
    final verticallyResizedPortrait = controller.selectedComponentBlock!;
    expect(
      verticallyResizedPortrait.size.width,
      closeTo(resizedPortrait.size.width, 0.0001),
    );
    expect(
      verticallyResizedPortrait.size.height,
      closeTo(resizedPortrait.size.height + 0.10, 0.0001),
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

  test('text and components can move and resize beyond every stage edge', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    const canvas = Size(1000, 500);

    controller.moveSelectedText(const Offset(-300, -200), canvas);
    expect(controller.selectedTextBlock!.position.dx, lessThan(0));
    expect(controller.selectedTextBlock!.position.dy, lessThan(0));

    controller.resizeSelectedTextByHandle(
      const Offset(1800, 900),
      canvas,
      renderedHeightFactor: 0.2,
      fromLeft: false,
      fromTop: false,
      fromRight: true,
      fromBottom: true,
    );
    final text = controller.selectedTextBlock!;
    expect(text.position.dx + text.widthFactor, greaterThan(1));
    expect(text.position.dy + text.heightFactor!, greaterThan(1));

    controller.addComponentBlock(PresentationComponentKind.edebiyat01);
    controller.moveSelectedText(const Offset(700, 500), canvas);
    expect(controller.selectedComponentBlock!.position.dx, greaterThan(1));
    expect(controller.selectedComponentBlock!.position.dy, greaterThan(1));

    controller.resizeSelectedComponentByHandle(
      const Offset(1400, 700),
      canvas,
      fromLeft: false,
      fromTop: false,
      fromRight: true,
      fromBottom: true,
    );
    expect(controller.selectedComponentBlock!.size.width, greaterThan(1));
    expect(controller.selectedComponentBlock!.size.height, greaterThan(1));
  });
}
