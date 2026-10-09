import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Render the bundled product fonts instead of the test-only Ahem squares.
Future<void> loadGoldenFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json'))
      as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

// CoreText and FreeType use different glyph metrics/rasterization. Keep strict,
// visually reviewed references for each tested platform rather than tolerating
// mismatches or accepting unreadable Ahem fallback screenshots.
String goldenPath(String file) =>
    'goldens/${Platform.isLinux ? 'linux/' : ''}$file';
