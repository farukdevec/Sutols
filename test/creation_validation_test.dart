import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/ui/design/design_system.dart';
import 'package:sutol/ui/home_page.dart';

void main() {
  for (final width in [390.0, 1000.0]) {
    testWidgets('empty topic is explained and focused at width $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final title = TextEditingController();
      final topic = TextEditingController(text: '   ');
      final titleFocus = FocusNode();
      final topicFocus = FocusNode();
      addTearDown(title.dispose);
      addTearDown(topic.dispose);
      addTearDown(titleFocus.dispose);
      addTearDown(topicFocus.dispose);
      var calls = 0;
      await tester.pumpWidget(MaterialApp(
        theme: sutolLightTheme,
        home: Scaffold(
            body: SingleChildScrollView(
                child: PresentationCreationCard(
          titleController: title,
          promptController: topic,
          titleFocusNode: titleFocus,
          promptFocusNode: topicFocus,
          onGenerate: (_, __) => calls++,
          slideCount: 3,
          hasPlusSlideAccess: false,
          onSlideCountChanged: (_) {},
        ))),
      ));
      await tester
          .tap(find.byKey(const ValueKey('presentation-generate-button')));
      await tester.pump();
      expect(calls, 0);
      expect(topicFocus.hasFocus, isTrue);
      expect(find.text('Lütfen sunumun konusunu yazın.'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('presentation-prompt-field')),
          'Güneş enerjisi');
      await tester
          .tap(find.byKey(const ValueKey('presentation-generate-button')));
      await tester.pump();
      expect(
          calls, 1); // The title remains optional; corrected input can proceed.
      expect(tester.takeException(), isNull);
    });
  }
}
