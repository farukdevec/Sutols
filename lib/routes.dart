import 'package:flutter/material.dart';

import 'state/presentation_controller.dart';
import 'ui/admin/admin_gate.dart';
import 'ui/auth_page.dart';
import 'ui/faq_page.dart';
import 'ui/home_page.dart';
import 'ui/html_presentation_editor_page.dart';
import 'ui/legal_pages.dart';
import 'ui/membership_page.dart';
import 'ui/my_presentations_page.dart';
import 'ui/presentation_open_page.dart';
import 'ui/redeem_code_page.dart';

/// Web ve mobil platformlar için merkezi rota ve URL yöneticisi.
class AppRoutes {
  AppRoutes._();

  // Ana rotalar
  static const String home = '/';
  static const String login = '/login';
  static const String myPresentations = '/sunumlarim';
  static const String membership = '/uyelik';
  static const String redeem = '/kod-kullan';
  static const String editor = '/editor';
  static const String admin = '/admin';
  static const String privacy = '/gizlilik';
  static const String terms = '/sartlar';
  static const String faq = '/sss';

  /// Verilen konu başlığı ve ID için SEO ve kullanıcı dostu sunum URL'i üretir.
  /// Örn: /cernobil-nukleer-faciasi-id54445484 veya /slide54445484
  static String presentationUrl({required String id, String? topic}) {
    final cleanId = id.trim();
    if (topic != null && topic.trim().isNotEmpty) {
      final slug = createTopicSlug(topic);
      if (slug.isNotEmpty) {
        return '/$slug-id$cleanId';
      }
    }
    return '/slide$cleanId';
  }

  /// Konu başlığından URL dostu slug üretir.
  static String createTopicSlug(String text) {
    if (text.trim().isEmpty) return '';
    var slug = text.trim().toLowerCase();
    slug = slug
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > 50) {
      slug = slug.substring(0, 50).replaceAll(RegExp(r'-+$'), '');
    }
    return slug;
  }

  /// Statik rota haritası
  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const SutolHomePage(),
        login: (_) => const AuthPage(),
        myPresentations: (_) => const MyPresentationsPage(),
        membership: (_) => const MembershipPage(),
        redeem: (_) => const RedeemCodePage(),
        admin: (_) => const AdminGate(),
        privacy: (_) => const PrivacyPolicyPage(),
        terms: (_) => const TermsOfServicePage(),
        faq: (_) => const FaqPage(),

        // Alternatif / İngilizce takma adlar (Aliases)
        '/auth': (_) => const AuthPage(),
        '/giris': (_) => const AuthPage(),
        '/kayit': (_) => const AuthPage(),
        '/register': (_) => const AuthPage(),
        '/my-presentations': (_) => const MyPresentationsPage(),
        '/presentations': (_) => const MyPresentationsPage(),
        '/pricing': (_) => const MembershipPage(),
        '/fiyatlandirma': (_) => const MembershipPage(),
        '/planlar': (_) => const MembershipPage(),
        '/membership': (_) => const MembershipPage(),
        '/redeem': (_) => const RedeemCodePage(),
        '/yonetici': (_) => const AdminGate(),
        '/privacy': (_) => const PrivacyPolicyPage(),
        '/privacy-policy': (_) => const PrivacyPolicyPage(),
        '/terms': (_) => const TermsOfServicePage(),
        '/terms-of-service': (_) => const TermsOfServicePage(),
        '/faq': (_) => const FaqPage(),
      };

  /// Dinamik ve parametreli rotaları işleyen rota üretici
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final rawName = settings.name ?? '';
    final uri = Uri.tryParse(rawName);
    var path = uri?.path.trim() ?? rawName.trim();

    if (path.isEmpty) path = '/';
    // Sondaki fazla bölü işaretlerini temizle (/login/ -> /login)
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    // 1. Bilinen statik rota eşleşmelerini öncelikle kontrol et
    final staticBuilder = routes[path];
    if (staticBuilder != null) {
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: staticBuilder,
      );
    }

    // 2. /editor rotası (boş sunum veya ID ile açılış)
    if (path == editor) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => HtmlPresentationEditorPage(
          controller: PresentationController(),
        ),
      );
    }

    if (path.startsWith('/editor/')) {
      final id = path.substring('/editor/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 3. /slide{id} veya /slide/{id} (Örn: /slide12345, /slide/12345)
    if (path.startsWith('/slide')) {
      var id = path.substring('/slide'.length).trim();
      if (id.startsWith('/')) {
        id = id.substring(1).trim();
      }
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 4. /p/{id} paylaşım rotası (Geriye dönük uyumluluk)
    if (path.startsWith('/p/')) {
      final id = path.substring('/p/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 5. /s/{id} kısa paylaşım rotası
    if (path.startsWith('/s/')) {
      final id = path.substring('/s/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 6. /presentation/{id} rotası
    if (path.startsWith('/presentation/')) {
      final id = path.substring('/presentation/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 7. Konu adı + id formatı (Örn: /cernobil-nukleer-faciasi-id54445484 veya /maddenin-halleriid54445484 veya /id54445484)
    final topicIdMatch =
        RegExp(r'^/(?:[a-zA-Z0-9_\-]*?)id([a-zA-Z0-9_\-]+)$').firstMatch(path);
    if (topicIdMatch != null) {
      final id = topicIdMatch.group(1);
      if (id != null && id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    return null;
  }

  /// Bilinmeyen URL durumunda ana sayfaya yönlendirir
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const SutolHomePage(),
    );
  }

  /// Doğrudan URL ile girilen sayfalarda tarayıcı geri butonunu güvenle yönetir
  static void handleAppBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(home);
    }
  }
}
