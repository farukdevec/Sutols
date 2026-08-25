import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/presentation_preview_page.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';
import 'package:sutol/ui/widgets/html_stage/html_page_stage.dart';

void main() {
  testWidgets(
      'ESC önizleme turundaki son kamera state\'ini editöre commit eder',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    final initial = controller.selectedComponentBlock!;

    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            hostContext = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );
    Navigator.of(hostContext).push(
      MaterialPageRoute<void>(
        builder: (_) => PresentationPreviewPage(
          controller: controller,
          useFullscreen: false,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Keşfe başla · Modeli sürükle'));
    await tester.pump();

    final cameraLayer =
        find.byKey(const ValueKey<String>('tour-camera-interaction'));
    expect(cameraLayer, findsOneWidget);
    await tester.drag(cameraLayer, const Offset(72, -28));
    await tester.pump();

    final joystick = find.bySemanticsLabel('Tur hareket joysticki');
    expect(joystick, findsOneWidget);
    final joystickGesture = find
        .descendant(of: joystick, matching: find.byType(GestureDetector))
        .first;
    tester
        .widget<GestureDetector>(joystickGesture)
        .onPanDown!(DragDownDetails(localPosition: const Offset(42, 0)));
    await tester.pump(const Duration(milliseconds: 100));
    tester.widget<GestureDetector>(joystickGesture).onPanEnd!(DragEndDetails());
    await tester.pump();

    // Önizleme kamerası çıkışa kadar lokaldir; ESC explicit commit noktasıdır.
    expect(controller.selectedComponentBlock!.modelOrbitTheta,
        initial.modelOrbitTheta);
    expect(
        controller.selectedComponentBlock!.modelTargetX, initial.modelTargetX);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));

    final committed = controller.selectedComponentBlock!;
    expect(committed.modelTourFrozen, isTrue);
    expect(Navigator.of(hostContext).canPop(), isFalse);
    expect(committed.modelOrbitTheta, isNot(initial.modelOrbitTheta));
    expect(
      committed.modelTargetX != initial.modelTargetX ||
          committed.modelTargetZ != initial.modelTargetZ,
      isTrue,
    );
  });

  testWidgets('sunum HTML sahnesi editörde dondurulan tur kamerasını kullanır',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.lookAroundSelectedModelTour(const Offset(64, -18));
    controller.moveSelectedModelTour(forward: 14, right: -6);
    controller.updateSelectedModelZoom(3.6);
    controller.commitSelectedModelTourPose();
    final expected = controller.selectedComponentBlock!;

    await tester.pumpWidget(
      MaterialApp(
        home: PresentationPreviewPage(
          controller: controller,
          useFullscreen: false,
        ),
      ),
    );
    await tester.pump();

    final htmlStage = tester.widget<HtmlPageStage>(
      find.byType(HtmlPageStage),
    );
    expect(htmlStage.tourCameraTheta, expected.modelOrbitTheta);
    expect(htmlStage.tourCameraPhi, expected.modelOrbitPhi);
    expect(htmlStage.tourCameraTargetX, expected.modelTargetX);
    expect(htmlStage.tourCameraTargetY, expected.modelTargetY);
    expect(htmlStage.tourCameraTargetZ, expected.modelTargetZ);
    expect(htmlStage.tourCameraZoom, expected.modelZoom);

    final fallback = tester.widget<PresentationPageThumbnailCanvas>(
      find.byType(PresentationPageThumbnailCanvas),
    );
    expect(
      fallback.page.componentBlocks.any((block) => block.modelAssetId != null),
      isFalse,
    );
  });

  testWidgets(
      'sunumda sayfa değişince her HTML sahnesi kendi dondurulmuş kamerasını kullanır',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.lookAroundSelectedModelTour(const Offset(48, -12));
    controller.moveSelectedModelTour(forward: 9, right: 3);
    controller.updateSelectedModelZoom(2.4);
    controller.commitSelectedModelTourPose();
    final firstCamera = controller.selectedComponentBlock!;

    controller.addPage();
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.lookAroundSelectedModelTour(const Offset(-96, 20));
    controller.moveSelectedModelTour(forward: -5, right: 11);
    controller.updateSelectedModelZoom(4.8);
    controller.commitSelectedModelTourPose();
    final secondCamera = controller.selectedComponentBlock!;
    controller.selectPage(0);

    await tester.pumpWidget(
      MaterialApp(
        home: PresentationPreviewPage(
          controller: controller,
          useFullscreen: false,
        ),
      ),
    );
    await tester.pump();

    HtmlPageStage currentStage() => tester.widget<HtmlPageStage>(
          find.byType(HtmlPageStage),
        );

    expect(currentStage().page.id, controller.pages.first.id);
    expect(currentStage().tourCameraTheta, firstCamera.modelOrbitTheta);
    expect(currentStage().tourCameraTargetX, firstCamera.modelTargetX);
    expect(currentStage().tourCameraTargetZ, firstCamera.modelTargetZ);
    expect(currentStage().tourCameraZoom, firstCamera.modelZoom);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(currentStage().page.id, controller.pages[1].id);
    expect(currentStage().tourCameraTheta, secondCamera.modelOrbitTheta);
    expect(currentStage().tourCameraTargetX, secondCamera.modelTargetX);
    expect(currentStage().tourCameraTargetZ, secondCamera.modelTargetZ);
    expect(currentStage().tourCameraZoom, secondCamera.modelZoom);
  });

  testWidgets('aktif turda sayfa değişimi kamerayı kaydeder ve turu dondurmaz',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    final initialFirstCamera = controller.selectedComponentBlock!;

    controller.addPage();
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.selectPage(0);
    controller.updateTransitionKind(PresentationTransitionKind.fade);

    await tester.pumpWidget(
      MaterialApp(
        home: PresentationPreviewPage(
          controller: controller,
          useFullscreen: false,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Keşfe başla · Modeli sürükle'));
    await tester.pump();
    await tester.drag(
      find.byKey(const ValueKey<String>('tour-camera-interaction')),
      const Offset(88, -24),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final savedFirstCamera = controller.pages.first.componentBlocks.single;
    expect(savedFirstCamera.modelTourFrozen, isFalse);
    expect(
      savedFirstCamera.modelOrbitTheta,
      isNot(initialFirstCamera.modelOrbitTheta),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final firstStage = tester.widget<HtmlPageStage>(find.byType(HtmlPageStage));
    expect(firstStage.page.id, controller.pages.first.id);
    expect(firstStage.tourCameraTheta, savedFirstCamera.modelOrbitTheta);
    expect(firstStage.tourCameraPhi, savedFirstCamera.modelOrbitPhi);
    expect(firstStage.tourCameraTargetX, savedFirstCamera.modelTargetX);
    expect(firstStage.tourCameraTargetZ, savedFirstCamera.modelTargetZ);
    expect(firstStage.tourCameraZoom, savedFirstCamera.modelZoom);
    expect(
      find.byKey(const ValueKey<String>('tour-camera-interaction')),
      findsOneWidget,
    );
  });

  testWidgets('çoklu modelde sunum aktif tur modelinin kamerasını kullanır',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);

    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.lookAroundSelectedModelTour(const Offset(24, -8));
    controller.moveSelectedModelTour(forward: 4, right: 2);
    controller.commitSelectedModelTourPose();
    final frozenCamera = controller.selectedComponentBlock!;

    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.lookAroundSelectedModelTour(const Offset(-120, 18));
    controller.moveSelectedModelTour(forward: 13, right: -7);
    controller.updateSelectedModelZoom(4.2);
    final activeCamera = controller.selectedComponentBlock!;

    await tester.pumpWidget(
      MaterialApp(
        home: PresentationPreviewPage(
          controller: controller,
          useFullscreen: false,
        ),
      ),
    );
    await tester.pump();

    final stage = tester.widget<HtmlPageStage>(find.byType(HtmlPageStage));
    expect(activeCamera.id, isNot(frozenCamera.id));
    expect(stage.tourCameraTheta, activeCamera.modelOrbitTheta);
    expect(stage.tourCameraPhi, activeCamera.modelOrbitPhi);
    expect(stage.tourCameraTargetX, activeCamera.modelTargetX);
    expect(stage.tourCameraTargetZ, activeCamera.modelTargetZ);
    expect(stage.tourCameraZoom, activeCamera.modelZoom);
    expect(stage.tourCameraTheta, isNot(frozenCamera.modelOrbitTheta));
  });
}
