import 'support/golden_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/html_presentation_editor_page.dart';
import 'package:sutol/ui/design/design_system.dart';

void main() {
  setUpAll(loadGoldenFonts);
  testWidgets('editor golden at 800x800', (tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
          theme: sutolLightTheme,
          home: HtmlPresentationEditorPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HtmlPresentationEditorPage),
      matchesGoldenFile('goldens/editor_800.png'),
    );
  });

  testWidgets('editor golden at 390x844', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
          theme: sutolLightTheme,
          home: HtmlPresentationEditorPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HtmlPresentationEditorPage),
      matchesGoldenFile('goldens/editor_390.png'),
    );
  });
}
