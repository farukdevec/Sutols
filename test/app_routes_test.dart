import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/routes.dart';
import 'package:sutol/ui/auth_page.dart';
import 'package:sutol/ui/faq_page.dart';
import 'package:sutol/ui/home_page.dart';
import 'package:sutol/ui/legal_pages.dart';
import 'package:sutol/ui/membership_page.dart';
import 'package:sutol/ui/my_presentations_page.dart';
import 'package:sutol/ui/presentation_open_page.dart';
import 'package:sutol/ui/redeem_code_page.dart';
import 'package:sutol/ui/html_presentation_editor_page.dart';

void main() {
  group('AppRoutes URL Mapping & Resolution Tests', () {
    test('createTopicSlug properly normalizes Turkish chars and spaces', () {
      expect(AppRoutes.createTopicSlug('Çernobil Nükleer Faciası!'), 'cernobil-nukleer-faciasi');
      expect(AppRoutes.createTopicSlug('Maddenin Halleri ve Isı Değişimi'), 'maddenin-halleri-ve-isi-degisimi');
      expect(AppRoutes.createTopicSlug('   '), '');
    });

    test('presentationUrl formats topic-based slug and ID', () {
      expect(
        AppRoutes.presentationUrl(id: '54445484', topic: 'Maddenin Halleri'),
        '/maddenin-halleri-id54445484',
      );
      expect(
        AppRoutes.presentationUrl(id: '54445484', topic: ''),
        '/slide54445484',
      );
    });

    testWidgets('Static routes map to correct pages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppRoutes.routes[AppRoutes.home]!(context), isA<SutolHomePage>());
              expect(AppRoutes.routes[AppRoutes.login]!(context), isA<AuthPage>());
              expect(AppRoutes.routes[AppRoutes.myPresentations]!(context), isA<MyPresentationsPage>());
              expect(AppRoutes.routes[AppRoutes.membership]!(context), isA<MembershipPage>());
              expect(AppRoutes.routes[AppRoutes.redeem]!(context), isA<RedeemCodePage>());
              expect(AppRoutes.routes[AppRoutes.privacy]!(context), isA<PrivacyPolicyPage>());
              expect(AppRoutes.routes[AppRoutes.terms]!(context), isA<TermsOfServicePage>());
              expect(AppRoutes.routes[AppRoutes.faq]!(context), isA<FaqPage>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Aliases and alternate routes map to correct pages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppRoutes.routes['/auth']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/giris']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/kayit']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/register']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/presentations']!(context), isA<MyPresentationsPage>());
              expect(AppRoutes.routes['/my-presentations']!(context), isA<MyPresentationsPage>());
              expect(AppRoutes.routes['/pricing']!(context), isA<MembershipPage>());
              expect(AppRoutes.routes['/fiyatlandirma']!(context), isA<MembershipPage>());
              expect(AppRoutes.routes['/planlar']!(context), isA<MembershipPage>());
              expect(AppRoutes.routes['/membership']!(context), isA<MembershipPage>());
              expect(AppRoutes.routes['/redeem']!(context), isA<RedeemCodePage>());
              expect(AppRoutes.routes['/privacy']!(context), isA<PrivacyPolicyPage>());
              expect(AppRoutes.routes['/terms']!(context), isA<TermsOfServicePage>());
              expect(AppRoutes.routes['/faq']!(context), isA<FaqPage>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Dynamic topic slug route resolution (e.g. /maddenin-halleri-id54445484)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/maddenin-halleri-id54445484'),
              ) as MaterialPageRoute;
              final widget = route.builder(context);
              expect(widget, isA<PresentationOpenPage>());
              expect((widget as PresentationOpenPage).presentationId, '54445484');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Dynamic /slide{id} route resolution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/slideabc123'),
              ) as MaterialPageRoute;
              final widget = route.builder(context);
              expect(widget, isA<PresentationOpenPage>());
              expect((widget as PresentationOpenPage).presentationId, 'abc123');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Dynamic /slide/{id} route resolution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/slide/xyz789'),
              ) as MaterialPageRoute;
              final widget = route.builder(context);
              expect(widget, isA<PresentationOpenPage>());
              expect((widget as PresentationOpenPage).presentationId, 'xyz789');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Dynamic /p/{id} legacy route resolution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/p/legacyDoc456'),
              ) as MaterialPageRoute;
              final widget = route.builder(context);
              expect(widget, isA<PresentationOpenPage>());
              expect((widget as PresentationOpenPage).presentationId, 'legacyDoc456');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Dynamic /editor and /editor/{id} route resolution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final blankRoute = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/editor'),
              ) as MaterialPageRoute;
              expect(blankRoute.builder(context), isA<HtmlPresentationEditorPage>());

              final idRoute = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/editor/deck999'),
              ) as MaterialPageRoute;
              final widget = idRoute.builder(context);
              expect(widget, isA<PresentationOpenPage>());
              expect((widget as PresentationOpenPage).presentationId, 'deck999');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Trailing slash normalization in onGenerateRoute', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/login/'),
              ) as MaterialPageRoute;
              expect(route.builder(context), isA<AuthPage>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Unknown route fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = AppRoutes.onUnknownRoute(
                const RouteSettings(name: '/some-random-unknown-path'),
              ) as MaterialPageRoute;
              expect(route.builder(context), isA<SutolHomePage>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
