import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/presentation_preview_page.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';

void main() {
  testWidgets('normal first slide has a sized canvas and visible content',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(const [
      PresentationPage(id: 'qa', textBlocks: [
        PresentationTextBlock(
            id: 'title',
            text: 'Moleküllerin dünyası',
            position: Offset(.07, .08),
            fontSize: 50,
            type: PresentationTextType.title,
            widthFactor: .86),
      ], componentBlocks: [
        PresentationComponentBlock(
            id: 'water',
            modelAssetId: 'sutols-water-molecule',
            position: Offset(.53, .27),
            size: Size(.4, .6))
      ])
    ]);
    await tester.pumpWidget(MaterialApp(
        home: PresentationPreviewPage(
            controller: controller, useFullscreen: false)));
    await tester.pumpAndSettle();
    final canvas = find.byType(PresentationPageCanvas);
    expect(canvas, findsOneWidget);
    expect(tester.getSize(canvas).width, greaterThan(1000));
    expect(tester.getSize(canvas).height, greaterThan(500));
    final title = find.descendant(
        of: canvas, matching: find.text('Moleküllerin dünyası'));
    expect(title, findsOneWidget);
    expect(tester.getRect(title).width, greaterThan(100));
    expect(tester.getRect(title).height, greaterThan(10));
    expect(tester.takeException(), isNull);
  });
}
