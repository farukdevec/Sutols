import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/cookie_consent_service.dart';
import 'package:sutol/ui/widgets/cookie_consent_banner.dart';

void main() {
  testWidgets('CookieConsentHost shows banner when undecided', (tester) async {
    CookieConsentService.instance.state.value = CookieConsentState.undecided;

    await tester.pumpWidget(
      const MaterialApp(
        home: CookieConsentHost(
          child: Scaffold(body: Text('Main Content')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Main Content'), findsOneWidget);
    expect(find.text('Çerez Tercihleriniz ve Gizliliğiniz'), findsOneWidget);
    expect(find.text('Tümünü Kabul Et'), findsOneWidget);
    expect(find.text('Sadece Zorunlu'), findsOneWidget);
    expect(find.text('Özelleştir'), findsOneWidget);
  });

  testWidgets('Tapping Tümünü Kabul Et accepts consent and hides banner', (tester) async {
    CookieConsentService.instance.state.value = CookieConsentState.undecided;

    await tester.pumpWidget(
      const MaterialApp(
        home: CookieConsentHost(
          child: Scaffold(body: Text('Main Content')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Tümünü Kabul Et'));
    await tester.pumpAndSettle();

    expect(CookieConsentService.instance.state.value, CookieConsentState.accepted);
    expect(find.text('Çerez Tercihleriniz ve Gizliliğiniz'), findsNothing);
  });

  testWidgets('Tapping Sadece Zorunlu updates state to essential', (tester) async {
    CookieConsentService.instance.state.value = CookieConsentState.undecided;

    await tester.pumpWidget(
      const MaterialApp(
        home: CookieConsentHost(
          child: Scaffold(body: Text('Main Content')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Sadece Zorunlu'));
    await tester.pumpAndSettle();

    expect(CookieConsentService.instance.state.value, CookieConsentState.essential);
    expect(find.text('Çerez Tercihleriniz ve Gizliliğiniz'), findsNothing);
  });

  testWidgets('Tapping Özelleştir opens preferences modal', (tester) async {
    CookieConsentService.instance.state.value = CookieConsentState.undecided;

    await tester.pumpWidget(
      const MaterialApp(
        home: CookieConsentHost(
          child: Scaffold(body: Text('Main Content')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Özelleştir'));
    await tester.pumpAndSettle();

    expect(find.text('Çerez Tercihleri'), findsOneWidget);
    expect(find.text('Zorunlu Çerezler'), findsOneWidget);
    expect(find.text('Analitik & Performans Çerezleri'), findsOneWidget);
    expect(find.text('Seçimleri Kaydet'), findsOneWidget);
  });
}
