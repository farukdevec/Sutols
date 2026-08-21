import 'package:flutter/material.dart';

import '../services/shared_prefs_service.dart';

/// Uygulama geneli tema modu kontrolü (kalıcı: SharedPreferences).
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const String _prefsKey = 'theme_mode';

  final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  Future<void> init() async {
    try {
      final prefs = await SharedPrefsService.instance.prefs;
      final saved = prefs.getString(_prefsKey);
      if (saved == 'dark') {
        mode.value = ThemeMode.dark;
      }
    } catch (_) {
      // Best-effort: kayıtlı tema okunamazsa varsayılan açık tema.
    }
  }

  Future<void> toggle() async {
    final next =
        mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    mode.value = next;
    try {
      final prefs = await SharedPrefsService.instance.prefs;
      await prefs.setString(
          _prefsKey, next == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Best-effort: tema kaydı hatası akışı bozmamalı.
    }
  }
}
