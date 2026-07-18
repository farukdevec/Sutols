import 'package:flutter/material.dart';

// Premium Design System 2026 - Sutol UI/UX Redesign
// Inspired by Canva, Figma, Linear, Vercel, Modern SaaS Platforms

class SutolColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEEF2FF);
  static const Color onPrimaryContainer = Color(0xFF4338CA);

  static const Color secondary = Color(0xFF64748B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF1F5F9);
  static const Color onSecondaryContainer = Color(0xFF1E293B);

  static const Color tertiary = Color(0xFFEC4899);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFDF2F8);
  static const Color onTertiaryContainer = Color(0xFFBE185D);

  static const Color background = Color(0xFFFAFAFA);
  static const Color onBackground = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  static const Color success = Color(0xFF10B981);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFECFDF5);
  static const Color onSuccessContainer = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFFBE6);
  static const Color onWarningContainer = Color(0xFF92400E);

  static const Color info = Color(0xFF3B82F6);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFEFF6FF);
  static const Color onInfoContainer = Color(0xFF1D4ED8);

  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFCBD5E1);
  static const Color shadow = Color(0x08000000);
  static const Color shadowStrong = Color(0x1A000000);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SutolSpacing {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class SutolRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class SutolElevation {
  static const List<BoxShadow> level0 = [];
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: SutolColors.shadow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: SutolColors.shadow,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: SutolColors.shadow,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  static const List<BoxShadow> level4 = [
    BoxShadow(
      color: SutolColors.shadowStrong,
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: SutolColors.shadow,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}

class SutolMotion {
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.fastOutSlowIn;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutSine;
  static const Curve materialCurve = Curves.standardDecelerate;
}

extension SutolTheme on BuildContext {
  Color get seed => SutolColors.primary;
  Color get surface => SutolColors.surface;
  Color get background => SutolColors.background;
  Color get onSurface => SutolColors.onSurface;
  Color get onSurfaceVariant => SutolColors.onSurfaceVariant;
  Color get outline => SutolColors.outline;
  Color get primaryContainer => SutolColors.primaryContainer;
  Color get onPrimaryContainer => SutolColors.onPrimaryContainer;
  Color get secondaryContainer => SutolColors.secondaryContainer;
  Color get onSecondaryContainer => SutolColors.onSecondaryContainer;
  Color get tertiaryContainer => SutolColors.tertiaryContainer;
  Color get onTertiaryContainer => SutolColors.onTertiaryContainer;

  double get xs => SutolSpacing.xs;
  double get sm => SutolSpacing.sm;
  double get md => SutolSpacing.md;
  double get lg => SutolSpacing.lg;
  double get xl => SutolSpacing.xl;
  double get xxl => SutolSpacing.xxl;
  double get xxxl => SutolSpacing.xxxl;

  double get radiusXs => SutolRadius.xs;
  double get radiusSm => SutolRadius.sm;
  double get radiusMd => SutolRadius.md;
  double get radiusLg => SutolRadius.lg;
  double get radiusXl => SutolRadius.xl;
  double get radiusXxl => SutolRadius.xxl;

  List<BoxShadow> get elevation0 => SutolElevation.level0;
  List<BoxShadow> get elevation1 => SutolElevation.level1;
  List<BoxShadow> get elevation2 => SutolElevation.level2;
  List<BoxShadow> get elevation3 => SutolElevation.level3;
  List<BoxShadow> get elevation4 => SutolElevation.level4;

  Duration get motionFastest => SutolMotion.fastest;
  Duration get motionFast => SutolMotion.fast;
  Duration get motionNormal => SutolMotion.normal;
  Duration get motionSlow => SutolMotion.slow;
  Duration get motionSlower => SutolMotion.slower;
  Duration get motionSlowest => SutolMotion.slowest;

  Curve get motionDefaultCurve => SutolMotion.defaultCurve;
  Curve get motionSpringCurve => SutolMotion.springCurve;
  Curve get motionBounceCurve => SutolMotion.bounceCurve;
  Curve get motionSmoothCurve => SutolMotion.smoothCurve;
  Curve get motionMaterialCurve => SutolMotion.materialCurve;
}