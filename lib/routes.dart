import 'package:flutter/material.dart';

import 'state/language_controller.dart';
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
  /// Örn: /cernobil-nukleer-faciasi-id54445484 veya /en/slide54445484
  static String presentationUrl({
    required String id,
    String? topic,
    bool? isEnglish,
  }) {
    final cleanId = id.trim();
    final en = isEnglish ?? LanguageController.instance.isEnglish;
    final prefix = en ? '/en' : '';
    if (topic != null && topic.trim().isNotEmpty) {
      final slug = createTopicSlug(topic);
      if (slug.isNotEmpty) {
        return '$prefix/$slug-id$cleanId';
      }
    }
    return '$prefix/slide$cleanId';
  }

  /// Aktif rota yolunu hedef dile göre yerelleştirilmiş URL formatına dönüştürür.
  /// Örn: '/' & en -> '/en'
  ///      '/en' & tr -> '/'
  ///      '/uyelik' & en -> '/en/pricing'
  ///      '/en/pricing' & tr -> '/uyelik'
  ///      '/editor/123' & en -> '/en/editor/123'
  ///      '/en/editor/123' & tr -> '/editor/123'
  ///      '/slide123' & en -> '/en/slide123'
  static String getLocalizedPath(String currentPath, AppLanguage language) {
    var raw = currentPath.trim();
    if (raw.isEmpty) raw = '/';
    if (raw.length > 1 && raw.endsWith('/')) {
      raw = raw.substring(0, raw.length - 1);
    }

    final isEn = language == AppLanguage.en;

    // Eğer zaten /en ile başlıyorsa temizleyelim
    var normalized = raw;
    if (normalized == '/en') {
      normalized = '/';
    } else if (normalized.startsWith('/en/')) {
      normalized = normalized.substring('/en'.length);
    }

    if (!isEn) {
      // Türkçe canonical rotalar
      switch (normalized) {
        case '/pricing':
        case '/membership':
        case '/fiyatlandirma':
        case '/planlar':
          return membership;
        case '/my-presentations':
        case '/presentations':
          return myPresentations;
        case '/redeem':
          return redeem;
        case '/privacy':
        case '/privacy-policy':
          return privacy;
        case '/terms':
        case '/terms-of-service':
          return terms;
        case '/faq':
          return faq;
        case '/auth':
        case '/register':
        case '/kayit':
        case '/giris':
          return login;
        default:
          return normalized;
      }
    } else {
      // İngilizce canonical rotalar (/en/...)
      switch (normalized) {
        case '/':
          return '/en';
        case '/uyelik':
        case '/membership':
        case '/fiyatlandirma':
        case '/planlar':
          return '/en/pricing';
        case '/sunumlarim':
        case '/my-presentations':
        case '/presentations':
          return '/en/my-presentations';
        case '/kod-kullan':
        case '/redeem':
          return '/en/redeem';
        case '/gizlilik':
        case '/privacy':
        case '/privacy-policy':
          return '/en/privacy';
        case '/sartlar':
        case '/terms':
        case '/terms-of-service':
          return '/en/terms';
        case '/sss':
        case '/faq':
          return '/en/faq';
        case '/login':
        case '/auth':
        case '/register':
        case '/giris':
        case '/kayit':
          return '/en/login';
        default:
          return '/en$normalized';
      }
    }
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

        // /en ve İngilizce doğrudan rotalar
        '/en': (_) => const SutolHomePage(),
        '/en/login': (_) => const AuthPage(),
        '/en/auth': (_) => const AuthPage(),
        '/en/register': (_) => const AuthPage(),
        '/en/pricing': (_) => const MembershipPage(),
        '/en/membership': (_) => const MembershipPage(),
        '/en/my-presentations': (_) => const MyPresentationsPage(),
        '/en/presentations': (_) => const MyPresentationsPage(),
        '/en/redeem': (_) => const RedeemCodePage(),
        '/en/privacy': (_) => const PrivacyPolicyPage(),
        '/en/privacy-policy': (_) => const PrivacyPolicyPage(),
        '/en/terms': (_) => const TermsOfServicePage(),
        '/en/terms-of-service': (_) => const TermsOfServicePage(),
        '/en/faq': (_) => const FaqPage(),
        '/en/sunumlarim': (_) => const MyPresentationsPage(),
        '/en/uyelik': (_) => const MembershipPage(),
        '/en/kod-kullan': (_) => const RedeemCodePage(),
        '/en/gizlilik': (_) => const PrivacyPolicyPage(),
        '/en/sartlar': (_) => const TermsOfServicePage(),
        '/en/sss': (_) => const FaqPage(),

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

    // /en öneki algılama ve dil senkronizasyonu
    final isEnRoute = path == '/en' || path.startsWith('/en/');
    if (isEnRoute) {
      if (LanguageController.instance.currentLanguage.value != AppLanguage.en) {
        LanguageController.instance.currentLanguage.value = AppLanguage.en;
        LanguageController.instance.isManuallySelected = true;
      }
    }

    // 1. Bilinen statik rota eşleşmelerini öncelikle kontrol et (tam yol ile)
    final staticBuilder = routes[path];
    if (staticBuilder != null) {
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: staticBuilder,
      );
    }

    // /en önekini soyup standart alt rotaları çözümle
    var lookupPath = path;
    if (path == '/en') {
      lookupPath = '/';
    } else if (path.startsWith('/en/')) {
      lookupPath = path.substring('/en'.length);
    }

    final strippedStaticBuilder = routes[lookupPath];
    if (strippedStaticBuilder != null) {
      return MaterialPageRoute<dynamic>(
        settings: settings,
        builder: strippedStaticBuilder,
      );
    }

    // 2. /editor rotası (boş sunum veya ID ile açılış)
    if (lookupPath == editor) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => HtmlPresentationEditorPage(
          controller: PresentationController(),
        ),
      );
    }

    if (lookupPath.startsWith('/editor/')) {
      final id = lookupPath.substring('/editor/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 3. /slide{id} veya /slide/{id} (Örn: /slide12345, /slide/12345)
    if (lookupPath.startsWith('/slide')) {
      var id = lookupPath.substring('/slide'.length).trim();
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
    if (lookupPath.startsWith('/p/')) {
      final id = lookupPath.substring('/p/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 5. /s/{id} kısa paylaşım rotası
    if (lookupPath.startsWith('/s/')) {
      final id = lookupPath.substring('/s/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 6. /presentation/{id} rotası
    if (lookupPath.startsWith('/presentation/')) {
      final id = lookupPath.substring('/presentation/'.length).trim();
      if (id.isNotEmpty) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PresentationOpenPage(presentationId: id),
        );
      }
    }

    // 7. Konu adı + id formatı (Örn: /cernobil-nukleer-faciasi-id54445484 veya /maddenin-halleriid54445484 veya /id54445484)
    final topicIdMatch =
        RegExp(r'^/(?:[a-zA-Z0-9_\-]*?)id([a-zA-Z0-9_\-]+)$').firstMatch(lookupPath);
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
    final rawName = settings.name ?? '';
    if (rawName == '/en' || rawName.startsWith('/en/')) {
      LanguageController.instance.currentLanguage.value = AppLanguage.en;
      LanguageController.instance.isManuallySelected = true;
    }
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
      final isEn = LanguageController.instance.isEnglish;
      Navigator.of(context).pushReplacementNamed(isEn ? '/en' : home);
    }
  }
}
