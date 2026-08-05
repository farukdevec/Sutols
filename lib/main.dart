import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/firebase_options.dart';
import 'services/auth_service.dart';
import 'state/theme_controller.dart';
import 'ui/admin/admin_gate.dart';
import 'ui/design/design_system.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  await ThemeController.instance.init();
  runApp(const SutolApp());
}

class SutolApp extends StatelessWidget {
  const SutolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Sutol',
          debugShowCheckedModeBanner: false,
          theme: sutolLightTheme,
          darkTheme: sutolDarkTheme,
          themeMode: themeMode,
          home: StreamBuilder<User?>(
            stream: AuthService.instance.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _SplashScreen();
              }
              return const SutolHomePage();
            },
          ),
          routes: {
            '/admin': (_) => const AdminGate(),
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
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
