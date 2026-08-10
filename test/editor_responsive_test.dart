import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/html_presentation_editor_page.dart';

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);

    FlutterErrorDetails? captured;
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      captured ??= details;
      // Test çerçevesinin hata kaydını korumak için varsayılanı da çağır.
      prevOnError?.call(details);
    };
    await tester.pumpWidget(
      MaterialApp(
        home: HtmlPresentationEditorPage(controller: controller),
      ),
    );
    await tester.pump();
    FlutterError.onError = prevOnError;
    if (captured != null) {
      FlutterError.dumpErrorToConsole(captured!, forceReport: true);
    }
  }

  testWidgets('editor renders without overflow at 390px (mobile)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    expect(find.byType(HtmlPresentationEditorPage), findsOneWidget);
  });

  testWidgets('editor renders without overflow at 768px (tablet)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(768, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor renders without overflow at 1150px (dar pencere)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1150, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('arka plan sekmesi 1120px genişlikte taşmaz', (tester) async {
    await pumpAt(tester, const Size(1120, 800));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Arka Planlar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final w in <double>[700, 760, 800, 860, 900, 1000, 1080]) {
    testWidgets('arka plan sekmesi ${w.toInt()}px genişlikte taşmaz', (
      tester,
    ) async {
      await pumpAt(tester, Size(w, 800));
      expect(tester.takeException(), isNull, reason: 'initial layout @$w');
      await tester.tap(find.text('Arka Planlar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'backgrounds tab @$w');
    });
  }

  for (final tab in <String>['Şablonlar', 'Bilesenler', 'Geçişler']) {
    for (final size in <Size>[const Size(390, 844), const Size(800, 800)]) {
      testWidgets(
        '"$tab" sekmesi ${size.width.toInt()}px genişlikte taşmaz',
        (tester) async {
          await pumpAt(tester, size);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$tab @ $size');
        },
      );
    }
  }

  for (final size in <Size>[const Size(390, 844), const Size(800, 800)]) {
    testWidgets('"Metin" sekmesi ${size.width.toInt()}px genişlikte taşmaz', (
      tester,
    ) async {
      await pumpAt(tester, size);
      expect(tester.takeException(), isNull);
      final tab = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.text('Metin'),
      );
      await tester.ensureVisible(tab.first);
      await tester.pumpAndSettle();
      await tester.tap(tab.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Metin @ $size');
    });
  }

  testWidgets('mobilde filmstrip açıkken de taşma olmaz', (tester) async {
    await pumpAt(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Sayfalar (1)'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Sayfaları Gizle'), findsOneWidget);
  });

  testWidgets('editor renders without overflow at 1400px (studio)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));
    expect(tester.takeException(), isNull);
  });
}
