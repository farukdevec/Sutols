import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sutol/ui/auth_page.dart';
import 'package:sutol/ui/design/design_system.dart';
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
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final kayitButtonAktif = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Kayıt Ol'),
      );
      expect(kayitButtonAktif.onPressed, isNotNull);

      // Sosyal giriş butonları yalnızca Giriş Yap sekmesinde gösterilir.
      expect(find.text('Google ile Devam Et'), findsNothing);

      // Giriş sekmesine dönünce kutucuk kaybolur, onay sıfırlanır.
      await tester.ensureVisible(find.text('Giriş Yap'));
      await tester.pump();
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.byType(TermsConsentBox), findsNothing);
      expect(find.text('Google ile Devam Et'), findsOneWidget);
    },
  );

  testWidgets('geniş login ekranı profesyonel ürün bilgi kartlarını gösterir',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: sutolLightTheme,
        home: const AuthPage(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('auth-info-card-left')), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-info-card-right')), findsOneWidget);
    expect(find.text('SUNUM, YENİDEN DÜŞÜNÜLDÜ'), findsOneWidget);
    expect(find.text('ÜÇ BOYUTLU ETKİ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
