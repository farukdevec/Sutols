import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/ui/design/design_system.dart';
import 'package:sutol/ui/home_page.dart';

void main() {
  testWidgets('mobile presentation form keeps focus when keyboard resizes view',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final titleController = TextEditingController();
    final promptController = TextEditingController();
    final titleFocusNode = FocusNode();
    final promptFocusNode = FocusNode();
    addTearDown(titleController.dispose);
    addTearDown(promptController.dispose);
    addTearDown(titleFocusNode.dispose);
    addTearDown(promptFocusNode.dispose);

    Widget app() => MaterialApp(
          theme: sutolLightTheme,
          home: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PresentationCreationCard(
                  titleController: titleController,
                  promptController: promptController,
                  titleFocusNode: titleFocusNode,
                  promptFocusNode: promptFocusNode,
                  onGenerate: (_, __) {},
                  slideCount: 5,
                  hasPlusSlideAccess: false,
                  onSlideCountChanged: (_) {},
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(app());
    await tester.tap(
      find.byKey(const ValueKey<String>('presentation-title-field')),
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('presentation-title-field')),
      'Mobil sunum',
    );
    expect(titleFocusNode.hasFocus, isTrue);

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpWidget(app());
    await tester.pump();

    expect(titleFocusNode.hasFocus, isTrue);
    expect(titleController.text, 'Mobil sunum');
    expect(tester.takeException(), isNull);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(promptFocusNode.hasFocus, isTrue);
  });

  testWidgets('form sends title and prompt as separate generation values',
      (tester) async {
    final titleController = TextEditingController();
    final promptController = TextEditingController();
    final titleFocusNode = FocusNode();
    final promptFocusNode = FocusNode();
    addTearDown(titleController.dispose);
    addTearDown(promptController.dispose);
    addTearDown(titleFocusNode.dispose);
    addTearDown(promptFocusNode.dispose);

    String? submittedTitle;
    String? submittedTopic;
    await tester.pumpWidget(MaterialApp(
      theme: sutolLightTheme,
      home: Scaffold(
        body: PresentationCreationCard(
          titleController: titleController,
          promptController: promptController,
          titleFocusNode: titleFocusNode,
          promptFocusNode: promptFocusNode,
          onGenerate: (title, topic) {
            submittedTitle = title;
            submittedTopic = topic;
          },
          slideCount: 5,
          hasPlusSlideAccess: false,
          onSlideCountChanged: (_) {},
        ),
      ),
    ));

    await tester.enterText(
      find.byKey(const ValueKey<String>('presentation-title-field')),
      'Eğitimde Yapay Zekâ',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('presentation-prompt-field')),
      'Ders planlama ve etik riskleri ayrıntılandır.',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('presentation-generate-button')),
    );

    expect(submittedTitle, 'Eğitimde Yapay Zekâ');
    expect(submittedTopic, 'Ders planlama ve etik riskleri ayrıntılandır.');
  });
}
