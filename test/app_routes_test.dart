import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/routes.dart';
import 'package:sutol/state/language_controller.dart';
import 'package:sutol/ui/auth_page.dart';
import 'package:sutol/ui/faq_page.dart';
import 'package:sutol/ui/home_page.dart';
import 'package:sutol/ui/legal_pages.dart';
import 'package:sutol/ui/membership_page.dart';
import 'package:sutol/ui/my_presentations_page.dart';
import 'package:sutol/ui/presentation_open_page.dart';
import 'package:sutol/ui/redeem_code_page.dart';
import 'package:sutol/ui/widgets/authenticated_route_guard.dart';

void main() {
  group('AppRoutes URL Mapping & Resolution Tests', () {
    test('createTopicSlug properly normalizes Turkish chars and spaces', () {
      expect(AppRoutes.createTopicSlug('Çernobil Nükleer Faciası!'),
          'cernobil-nukleer-faciasi');
      expect(AppRoutes.createTopicSlug('Maddenin Halleri ve Isı Değişimi'),
          'maddenin-halleri-ve-isi-degisimi');
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
              expect(AppRoutes.routes[AppRoutes.home]!(context),
                  isA<SutolHomePage>());
              expect(
                  AppRoutes.routes[AppRoutes.login]!(context), isA<AuthPage>());
              expect(AppRoutes.routes[AppRoutes.myPresentations]!(context),
                  isA<MyPresentationsPage>());
              expect(AppRoutes.routes[AppRoutes.membership]!(context),
                  isA<MembershipPage>());
              expect(AppRoutes.routes[AppRoutes.redeem]!(context),
                  isA<RedeemCodePage>());
              expect(AppRoutes.routes[AppRoutes.privacy]!(context),
                  isA<PrivacyPolicyPage>());
              expect(AppRoutes.routes[AppRoutes.terms]!(context),
                  isA<TermsOfServicePage>());
              expect(AppRoutes.routes[AppRoutes.faq]!(context), isA<FaqPage>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Aliases and alternate routes map to correct pages',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppRoutes.routes['/auth']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/giris']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/kayit']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/register']!(context), isA<AuthPage>());
              expect(AppRoutes.routes['/presentations']!(context),
                  isA<MyPresentationsPage>());
              expect(AppRoutes.routes['/my-presentations']!(context),
                  isA<MyPresentationsPage>());
              expect(AppRoutes.routes['/pricing']!(context),
                  isA<MembershipPage>());
              expect(AppRoutes.routes['/fiyatlandirma']!(context),
                  isA<MembershipPage>());
              expect(AppRoutes.routes['/planlar']!(context),
                  isA<MembershipPage>());
              expect(AppRoutes.routes['/membership']!(context),
                  isA<MembershipPage>());
              expect(
                  AppRoutes.routes['/redeem']!(context), isA<RedeemCodePage>());
              expect(AppRoutes.routes['/privacy']!(context),
                  isA<PrivacyPolicyPage>());
              expect(AppRoutes.routes['/terms']!(context),
                  isA<TermsOfServicePage>());
              expect(AppRoutes.routes['/faq']!(context), isA<FaqPage>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets(
        'Dynamic topic slug route resolution (e.g. /maddenin-halleri-id54445484)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/maddenin-halleri-id54445484'),
              ) as MaterialPageRoute;
              final widget = route.builder(context);
              expect(widget, isA<PresentationOpenPage>());
              expect(
                  (widget as PresentationOpenPage).presentationId, '54445484');
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
              expect((widget as PresentationOpenPage).presentationId,
                  'legacyDoc456');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Dynamic /editor and /editor/{id} route resolution',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final blankRoute = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/editor'),
              ) as MaterialPageRoute;
              final blankWidget = blankRoute.builder(context);
              expect(blankWidget, isA<AuthenticatedRouteGuard>());
              expect(
                (blankWidget as AuthenticatedRouteGuard).redirectRoute,
                AppRoutes.home,
              );

              final idRoute = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/editor/deck999'),
              ) as MaterialPageRoute;
              final widget = idRoute.builder(context);
              expect(widget, isA<AuthenticatedRouteGuard>());
              expect(
                (widget as AuthenticatedRouteGuard).redirectRoute,
                AppRoutes.home,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('Trailing slash normalization in onGenerateRoute',
        (tester) async {
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

    testWidgets(
        'English /en and /en/... routes resolution and language state update',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // /en
              final enHome = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/en'),
              ) as MaterialPageRoute;
              expect(enHome.builder(context), isA<SutolHomePage>());

              // /en/pricing
              final enPricing = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/en/pricing'),
              ) as MaterialPageRoute;
              expect(enPricing.builder(context), isA<MembershipPage>());

              // /en/login
              final enLogin = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/en/login'),
              ) as MaterialPageRoute;
              expect(enLogin.builder(context), isA<AuthPage>());

              // /en/editor
              final enEditor = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/en/editor'),
              ) as MaterialPageRoute;
              final enEditorWidget = enEditor.builder(context);
              expect(enEditorWidget, isA<AuthenticatedRouteGuard>());
              expect(
                (enEditorWidget as AuthenticatedRouteGuard).redirectRoute,
                '/en',
              );

              // /en/slide/sample123
              final enSlide = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/en/slide/sample123'),
              ) as MaterialPageRoute;
              final slideWidget =
                  enSlide.builder(context) as PresentationOpenPage;
              expect(slideWidget.presentationId, 'sample123');

              // /en/faq
              final enFaq = AppRoutes.onGenerateRoute(
                const RouteSettings(name: '/en/faq'),
              ) as MaterialPageRoute;
              expect(enFaq.builder(context), isA<FaqPage>());

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    test('getLocalizedPath converts paths accurately between TR and EN', () {
      // Home
      expect(AppRoutes.getLocalizedPath('/', AppLanguage.en), '/en');
      expect(AppRoutes.getLocalizedPath('/en', AppLanguage.tr), '/');

      // Membership / Pricing
      expect(
          AppRoutes.getLocalizedPath('/uyelik', AppLanguage.en), '/en/pricing');
      expect(
          AppRoutes.getLocalizedPath('/en/pricing', AppLanguage.tr), '/uyelik');
      expect(AppRoutes.getLocalizedPath('/pricing', AppLanguage.tr), '/uyelik');

      // Presentations
      expect(AppRoutes.getLocalizedPath('/sunumlarim', AppLanguage.en),
          '/en/my-presentations');
      expect(AppRoutes.getLocalizedPath('/en/my-presentations', AppLanguage.tr),
          '/sunumlarim');

      // Editor
      expect(
          AppRoutes.getLocalizedPath('/editor', AppLanguage.en), '/en/editor');
      expect(
          AppRoutes.getLocalizedPath('/en/editor', AppLanguage.tr), '/editor');
      expect(AppRoutes.getLocalizedPath('/editor/doc123', AppLanguage.en),
          '/en/editor/doc123');
      expect(AppRoutes.getLocalizedPath('/en/editor/doc123', AppLanguage.tr),
          '/editor/doc123');

      // Slide
      expect(AppRoutes.getLocalizedPath('/slide123', AppLanguage.en),
          '/en/slide123');
      expect(AppRoutes.getLocalizedPath('/en/slide123', AppLanguage.tr),
          '/slide123');

      // FAQ
      expect(AppRoutes.getLocalizedPath('/sss', AppLanguage.en), '/en/faq');
      expect(AppRoutes.getLocalizedPath('/en/faq', AppLanguage.tr), '/sss');

      // Privacy / Terms
      expect(AppRoutes.getLocalizedPath('/gizlilik', AppLanguage.en),
          '/en/privacy');
      expect(AppRoutes.getLocalizedPath('/en/privacy', AppLanguage.tr),
          '/gizlilik');
      expect(
          AppRoutes.getLocalizedPath('/sartlar', AppLanguage.en), '/en/terms');
      expect(
          AppRoutes.getLocalizedPath('/en/terms', AppLanguage.tr), '/sartlar');
    });

    test('presentationUrl respects isEnglish and active language', () {
      expect(
        AppRoutes.presentationUrl(
            id: '54445484', topic: 'Matter States', isEnglish: true),
        '/en/matter-states-id54445484',
      );
      expect(
        AppRoutes.presentationUrl(id: '54445484', topic: '', isEnglish: true),
        '/en/slide54445484',
      );
      expect(
        AppRoutes.presentationUrl(
            id: '54445484', topic: 'Maddenin Halleri', isEnglish: false),
        '/maddenin-halleri-id54445484',
      );
    });
  });
}
