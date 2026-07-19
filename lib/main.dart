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
      themeMode: ThemeMode.light,
      home: const SutolHomePage(),
    );
  }
}
