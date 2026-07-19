import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Sutol Design Tokens — Premium SaaS System
// ─────────────────────────────────────────────

/// Custom colors using ThemeExtension for semantic clarity.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceElevated,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.border,
    required this.borderFocus,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.accent,
  });

  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color surfaceElevated;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color border;
  final Color borderFocus;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color accent;

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? onPrimary,
    Color? surface,
    Color? surfaceElevated,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? border,
    Color? borderFocus,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? accent,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      border: border ?? this.border,
      borderFocus: borderFocus ?? this.borderFocus,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      accent: accent ?? this.accent,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }

  /// Light theme color palette (Premium SaaS, Vercel/Linear inspired)
  static const AppColors light = AppColors(
    primary: Color(0xFF0F172A), // Deep slate/navy
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAFA), // Soft off-white background
    surfaceElevated: Color(0xFFFFFFFF), // Pure white for cards
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    borderFocus: Color(0xFF3B82F6), // Professional blue focus
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    accent: Color(0xFF6366F1), // Indigo accent
  );

  /// Dark theme color palette (Optional/Secondary)
  static const AppColors dark = AppColors(
    primary: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF0F172A),
    surface: Color(0xFF0B0F19),
    surfaceElevated: Color(0xFF111827),
    onSurface: Color(0xFFF8FAFC),
    onSurfaceVariant: Color(0xFF94A3B8),
    border: Color(0xFF1E293B),
    borderFocus: Color(0xFF60A5FA),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    accent: Color(0xFF818CF8),
  );
}

// ── Typography ─────────────────────────────────

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );
}

// ── Spacing (8px Grid) ─────────────────────────

class AppSpacing {
  const AppSpacing._();
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;
  static const double s64 = 64;
  static const double s96 = 96;
}

// ── Border Radius ──────────────────────────────

class AppRadius {
  const AppRadius._();
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;
}

// ── Elevation / Shadows ────────────────────────

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x05000000), blurRadius: 15, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 15, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x08000000), blurRadius: 40, offset: Offset(0, 20)),
  ];
}

// ── Motion ──────────────────────────────────────

class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.fastOutSlowIn;
}
