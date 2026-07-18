import 'package:flutter/material.dart';

import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SutolApp());
}

class SutolApp extends StatelessWidget {
  const SutolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0EA5E9),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Sutol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF050816),
        fontFamily: 'Trebuchet MS',
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const SutolHomePage(),
    );
  }
}
