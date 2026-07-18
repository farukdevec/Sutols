import 'package:flutter/material.dart';

import 'ui/design/design_system.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SutolApp());
}

class SutolApp extends StatelessWidget {
  const SutolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sutol',
      debugShowCheckedModeBanner: false,
      theme: sutolLightTheme,
      darkTheme: sutolDarkTheme,
      themeMode: ThemeMode.system,
      home: const SutolHomePage(),
    );
  }
}

// Custom extensions for easier access to design system properties
extension SutolThemeExtension on ThemeData {
  Color get seed => Colors.blue;
  Color get surface => Colors.white;
  Color get background => Colors.grey[50]!;
}
