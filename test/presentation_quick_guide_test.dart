import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/ui/widgets/presentation_quick_guide.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(1200, 900)]) {
    testWidgets(
        'quick guide supports forward, back and early dismissal at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () => showPresentationQuickGuide(context),
                      child: const Text('Open'))))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 5'), findsOneWidget);
      await tester.tap(find.text('Sonraki'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 5'), findsOneWidget);
      await tester.tap(find.text('Önceki'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 5'), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Sonraki'));
        await tester.pumpAndSettle();
      }
      expect(find.text('5 / 5'), findsOneWidget);
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();
      expect(find.text('Hızlı başlangıç'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kapat'));
      await tester.pumpAndSettle();
      expect(find.text('Hızlı başlangıç'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
