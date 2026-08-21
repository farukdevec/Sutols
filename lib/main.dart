import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/shared_prefs_service.dart';
import 'services/firebase_options.dart';
import 'services/auth_service.dart';
import 'state/theme_controller.dart';
import 'state/language_controller.dart';
import 'ui/admin/admin_gate.dart';
import 'ui/auth_page.dart';
import 'ui/design/design_system.dart';
import 'ui/home_page.dart';
import 'ui/legal_pages.dart';
import 'ui/faq_page.dart';
import 'ui/presentation_open_page.dart';
import 'ui/widgets/cookie_consent_banner.dart';
import 'ui/widgets/terms_consent_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  // SharedPreferences'i önceden yükle (tüm controller'lar tarafından kullanılır)
  await SharedPrefsService.instance.preload();
  
  await Future.wait<void>(<Future<void>>[
    Firebase.initializeApp(options: DefaultFirebaseOptions.web),
    ThemeController.instance.init(),
  ]);
  // Dil kontrolörünü bloke etmeden başlat - IP tespiti arka planda yapılacak
  LanguageController.instance.init();
  runApp(const SutolApp());
}

class SutolApp extends StatelessWidget {
  const SutolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageController.instance.currentLanguage,
      builder: (context, language, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.instance.mode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'Sutols',
              debugShowCheckedModeBanner: false,
              navigatorKey: appNavigatorKey,
              theme: sutolLightTheme,
              darkTheme: sutolDarkTheme,
              themeMode: themeMode,
              home: CookieConsentHost(
                child: StreamBuilder<User?>(
                  stream: AuthService.instance.authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _SplashScreen();
                    }
                    final user = snapshot.data;
                    if (user == null) {
                      return const SutolHomePage();
                    }
                    // Giriş yapıldıysa paylaşım bağlantılarını (/p/{id}) yakala.
                    return _DeepLinkHost(child: const SutolHomePage());
                  },
                ),
              ),
              routes: {
                '/admin': (_) => const AdminGate(),
                '/login': (_) => const AuthPage(),
                '/gizlilik': (_) => const PrivacyPolicyPage(),
                '/sartlar': (_) => const TermsOfServicePage(),
                '/sss': (_) => const FaqPage(),
              },
              onGenerateRoute: (settings) {
                // Handle /slide{id} routes
                if (settings.name?.startsWith('/slide') == true) {
                  final path = settings.name!;
                  // Extract the ID after /slide
                  final id = path.substring('/slide'.length);
                  if (id.isNotEmpty) {
                    return MaterialPageRoute<void>(
                      builder: (_) => PresentationOpenPage(presentationId: id),
                    );
                  }
                }
                // Handle /p/{id} routes (keep existing functionality)
                if (settings.name?.startsWith('/p/') == true) {
                  final segments = settings.name!.split('/');
                  if (segments.length >= 3) {
                    final presentationId = segments[2];
                    return MaterialPageRoute<void>(
                      builder: (_) => PresentationOpenPage(presentationId: presentationId),
                    );
                  }
                }
                return null;
              },
            );
          },
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              tr('Sutols yükleniyor', 'Loading Sutols'),
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paylaşım bağlantısı (/p/{presentationId}) ile gelen kullanıcıyı
/// sunum açılış sayfasına yönlendirir.
class _DeepLinkHost extends StatefulWidget {
  const _DeepLinkHost({required this.child});

  final Widget child;

  @override
  State<_DeepLinkHost> createState() => _DeepLinkHostState();
}

class _DeepLinkHostState extends State<_DeepLinkHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleDeepLink());
  }

  void _handleDeepLink() {
    if (!kIsWeb) return;
    final path = Uri.base.path;
    final segments = Uri.base.pathSegments.where((s) => s.isNotEmpty).toList();
    
    // Handle /slide{id} routes
    if (path.startsWith('/slide')) {
      final presentationId = path.substring('/slide'.length);
      if (presentationId.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PresentationOpenPage(presentationId: presentationId),
          ),
        );
        return;
      }
    }
    
    // Handle /p/{id} routes (existing functionality)
    if (segments.length == 2 && segments[0] == 'p') {
      final presentationId = segments[1];
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PresentationOpenPage(presentationId: presentationId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
