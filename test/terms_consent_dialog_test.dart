import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sutol/ui/widgets/terms_consent_dialog.dart';

void main() {
  testWidgets(
    'Şartlar dialogu: açılır, kutucuk onayı olmadan Devam Et pasiftir, '
    'kutucuk tıklanınca aktifleşir, onay ile kapanır',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: appNavigatorKey,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: FilledButton(
                  onPressed: () => showTermsConsentDialog(),
                  child: const Text('test-kayit'),
                ),
              ),
            ),
          ),
          routes: {
            '/gizlilik': (_) => Scaffold(
                  appBar: AppBar(title: const Text('gizlilik-sayfasi')),
                ),
            '/sartlar': (_) => Scaffold(
                  appBar: AppBar(title: const Text('sartlar-sayfasi')),
                ),
          },
        ),
      );

      await tester.tap(find.text('test-kayit'));
      await tester.pumpAndSettle();

      // Dialog ekranda; onay kutucuğu ve linkler metnin içinde.
      expect(find.text('Devam etmeden önce'), findsOneWidget);
      expect(find.byType(TermsConsentBox), findsOneWidget);

      // Kutucuk işaretlenmeden "Devam Et" disabled.
      final devam = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Devam Et'),
      );
      expect(devam.onPressed, isNull);

      // Kutucuğa (metnin sağ ucundan) tıklayınca tik işaretlenir,
      // Devam Et aktifleşir.
      final boxText = find.textContaining('okudum, kabul ediyorum');
      final boxRect = tester.getRect(boxText);
      await tester.tapAt(Offset(boxRect.right - 20, boxRect.center.dy));
      await tester.pump();

      final devamAktif = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Devam Et'),
      );
      expect(devamAktif.onPressed, isNotNull);

      // Onay korunur; Devam Et dialogu kapatır.
      await tester.tap(find.text('Devam Et'));
      await tester.pumpAndSettle();
      expect(find.text('Devam etmeden önce'), findsNothing);
    },
  );

  testWidgets('Şartlar dialogundaki linkler sayfaları açar, geri gelince '
      'dialog açık kalır',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: appNavigatorKey,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: FilledButton(
                    onPressed: () => showTermsConsentDialog(),
                    child: const Text('test-kayit'),
                ),
              ),
            ),
          ),
          routes: {
            '/gizlilik': (_) => Scaffold(
                  appBar: AppBar(title: const Text('gizlilik-sayfasi')),
                ),
            '/sartlar': (_) => Scaffold(
                  appBar: AppBar(title: const Text('sartlar-sayfasi')),
                ),
          },
          ),
        );

        await tester.tap(find.text('test-kayit'));
        await tester.pumpAndSettle();

        // Giriş paragrafındaki linkler yapısal olarak tıklanabilir (recognizer'lı).
        final introRichText = tester.widget<RichText>(
          find.byWidgetPredicate(
            (w) => w is RichText &&
                w.text.toPlainText().startsWith("Sutols'u kullanmaya başlamak"),
          ),
        );
        var hasClickableLink = false;
        introRichText.text.visitChildren((span) {
          if (span is TextSpan && span.recognizer != null) {
            hasClickableLink = true;
          }
          return true;
        });
        expect(hasClickableLink, isTrue);

        // Kutucuk metninin başındaki "Kullanım Şartları" linki /sartlar
        // sayfasını açar (link metin hizasının en başında durur).
        final boxText = find.byWidgetPredicate(
          (w) => w is RichText &&
              w.text.toPlainText().contains('okudum, kabul ediyorum'),
        );
        final boxRect = tester.getRect(boxText);
        await tester.tapAt(Offset(boxRect.left + 15, boxRect.top + 12));
        await tester.pumpAndSettle();
        expect(find.text('sartlar-sayfasi'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Geri dönünce dialog hâlâ açık (kapatılamıyor).
        expect(find.text('Devam etmeden önce'), findsOneWidget);

        // Kutucuk metnindeki "Gizlilik Politikası" linki de /gizlilik
        // sayfasını açar (baştaki linkin hemen ardındadır).
        final boxRect2 = tester.getRect(boxText);
        await tester.tapAt(Offset(boxRect2.left + 150, boxRect2.top + 12));
        await tester.pumpAndSettle();
        expect(find.text('gizlilik-sayfasi'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Devam etmeden önce'), findsOneWidget);
      },
    );
}