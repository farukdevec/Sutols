import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sutol/ui/auth_page.dart';
import 'package:sutol/ui/widgets/terms_consent_dialog.dart';

void main() {
  testWidgets(
    'Kayıt Ol sekmesinde onay kutucuğu butonlara tıklanmadan görünür; '
    'işaretlenmeden Kayıt Ol butonu pasiftir',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AuthPage(),
          routes: {
            '/gizlilik': (_) => const Scaffold(),
            '/sartlar': (_) => const Scaffold(),
          },
        ),
      );

      // Giriş sekmesinde kutucuk yok.
      expect(find.byType(TermsConsentBox), findsNothing);

      // "Kayıt Ol" sekmesine geçince kutucuk anında görünür.
      await tester.tap(find.text('Kayıt Ol'));
      await tester.pumpAndSettle();
      expect(find.byType(TermsConsentBox), findsOneWidget);

      // İşaretlenmeden "Kayıt Ol" butonu pasiftir.
      final kayitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Kayıt Ol'),
      );
      expect(kayitButton.onPressed, isNull);

      // Kutucuğa tıklayınca tik işaretlenir ve buton aktifleşir.
      // (Dar kartta metin çok satıra sarıldığı için linklere denk gelmeyen
      //  Checkbox hedeflenir.)
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final kayitButtonAktif = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Kayıt Ol'),
      );
      expect(kayitButtonAktif.onPressed, isNotNull);

      // Google butonu da aynı kutucukla gated.
      final googleButton = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Google ile Devam Et'),
          matching: find.bySubtype<OutlinedButton>(),
        ),
      );
      expect(googleButton.onPressed, isNotNull);

      // Giriş sekmesine dönünce kutucuk kaybolur, onay sıfırlanır.
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.byType(TermsConsentBox), findsNothing);
    },
  );
}