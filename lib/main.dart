import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

import 'routes.dart';
import 'services/shared_prefs_service.dart';
import 'services/firebase_options.dart';
import 'state/theme_controller.dart';
import 'state/language_controller.dart';
import 'ui/design/design_system.dart';
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
              builder: (context, child) {
                return CookieConsentHost(
                  child: child ?? const SizedBox.shrink(),
                );
              },
              initialRoute: AppRoutes.home,
              routes: AppRoutes.routes,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              onUnknownRoute: AppRoutes.onUnknownRoute,
            );
          },
        );
      },
    );
  }
}

