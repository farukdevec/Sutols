import 'support/golden_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sutol/ui/auth_page.dart';
import 'package:sutol/ui/design/design_system.dart';

void main() {
  setUpAll(loadGoldenFonts);
  testWidgets('login page desktop visual', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: sutolLightTheme,
        home: const AuthPage(),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(AuthPage));
      await precacheImage(const AssetImage('assets/images/logo.webp'), context);
      await precacheImage(
          const AssetImage('assets/images/sutols_wordmark.webp'), context);
    });
    await tester.pump();

    await expectLater(
      find.byType(AuthPage),
      matchesGoldenFile('goldens/auth_page_desktop.png'),
    );
  });
}
