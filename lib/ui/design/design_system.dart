import 'package:flutter/material.dart';

import 'design_tokens.dart';

export 'design_tokens.dart';

// ─────────────────────────────────────────────
//  Sutol Design System — Premium SaaS Edition
// ─────────────────────────────────────────────

/// Light Theme (Default, Premium SaaS Look)
final ThemeData sutolLightTheme = _buildThemeData(
  brightness: Brightness.light,
  appColors: AppColors.light,
);

/// Dark Theme (Secondary)
final ThemeData sutolDarkTheme = _buildThemeData(
  brightness: Brightness.dark,
  appColors: AppColors.dark,
);

ThemeData _buildThemeData({
  required Brightness brightness,
  required AppColors appColors,
}) {
  final textTheme = TextTheme(
    displayLarge: AppTypography.display.copyWith(color: appColors.textPrimary),
    headlineLarge: AppTypography.headline.copyWith(color: appColors.textPrimary),
    titleLarge: AppTypography.titleLarge.copyWith(color: appColors.textPrimary),
    titleMedium: AppTypography.titleMedium.copyWith(color: appColors.textPrimary),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: appColors.textPrimary),
    bodyMedium: AppTypography.bodyMedium.copyWith(color: appColors.textPrimary),
    labelLarge: AppTypography.labelLarge.copyWith(color: appColors.textSecondary),
    labelMedium: AppTypography.labelMedium.copyWith(color: appColors.textSecondary),
    labelSmall: AppTypography.labelSmall.copyWith(color: appColors.textSecondary),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: appColors.surface,
    colorScheme: ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: appColors.primary,
      surface: appColors.surface,
      onSurface: appColors.onSurface,
      error: appColors.danger,
    ),
    textTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[
      appColors,
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.surface,
      foregroundColor: appColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.titleMedium.copyWith(color: appColors.textPrimary),
      iconTheme: IconThemeData(color: appColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: appColors.surfaceElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: appColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: appColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: appColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: appColors.borderFocus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: appColors.danger, width: 1),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: appColors.textSecondary.withValues(alpha: 0.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appColors.primary,
        foregroundColor: appColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
          vertical: AppSpacing.s12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: appColors.primary,
        foregroundColor: appColors.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
          vertical: AppSpacing.s12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: appColors.textPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
          vertical: AppSpacing.s12,
        ),
        side: BorderSide(color: appColors.border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: appColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: appColors.textSecondary,
        padding: const EdgeInsets.all(AppSpacing.s8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: appColors.border,
      thickness: 1,
      space: 1,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: appColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: AppTypography.labelSmall.copyWith(color: appColors.onPrimary),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
    ),
  );
}

// ── Context Extension ──────────────────────────

extension SutolTheme on BuildContext {
  /// Access our semantic colors safely.
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;

  /// Backward compatibility aliases for existing code
  /// to minimize immediate compilation errors.
  _LegacyColorWrapper get sutolColors => _LegacyColorWrapper(this);
}

/// A temporary wrapper to help transition from the old color scheme
/// to the new AppColors without breaking every file at once.
class _LegacyColorWrapper {
  const _LegacyColorWrapper(this.context);
  final BuildContext context;

  AppColors get _c => context.colors;

  Color get primary => _c.primary;
  Color get onPrimary => _c.onPrimary;
  Color get primaryContainer => _c.primary.withValues(alpha: 0.1);
  Color get onPrimaryContainer => _c.primary;
  Color get surface => _c.surfaceElevated;
  Color get onSurface => _c.textPrimary;
  Color get surfaceSubtle => _c.surface;
  Color get onSurfaceVariant => _c.textSecondary;
  Color get background => _c.surface;
  Color get outline => _c.border;
  
  // Gradients
  LinearGradient get surfaceGlow => const LinearGradient(
    colors: [Color(0xFFFAFAFA), Color(0xFFFAFAFA)],
  );

  Color get success => _c.success;
  Color get warning => _c.warning;
  Color get error => _c.danger;
  Color get info => _c.accent; // fallback
  Color get onInfo => _c.onPrimary; // fallback
  Color get secondaryContainer => _c.surfaceElevated;
  Color get onSecondaryContainer => _c.textPrimary;
  Color get surfaceTinted => _c.surfaceElevated;
  Color get outlineVariant => _c.border;
  Color get primaryLight => _c.primary.withValues(alpha: 0.1);
}

/// Additional legacy getters directly on BuildContext
extension SutolThemeLegacy on BuildContext {
  AppColors get _c => colors;

  Color get primary => _c.primary;
  Color get onPrimary => _c.onPrimary;
  Color get surface => _c.surfaceElevated;
  Color get onSurface => _c.textPrimary;
  Color get surfaceVariant => _c.surface;
  Color get onSurfaceVariant => _c.textSecondary;
  Color get background => _c.surface;
  Color get outline => _c.border;
  Color get error => _c.danger;
  Color get onError => _c.onPrimary;

  double get radiusSm => AppRadius.sm;
  double get radiusMd => AppRadius.md;
  double get radiusLg => AppRadius.lg;
  double get radiusXl => AppRadius.xl;
  double get radiusXxl => AppRadius.xl; // fallback

  double get spacingXs => AppSpacing.s4;
  double get spacingSm => AppSpacing.s8;
  double get spacingMd => AppSpacing.s12;
  double get spacingLg => AppSpacing.s16;
  double get spacingXl => AppSpacing.s24;

  Duration get motionFast => AppMotion.fast;
  Duration get motionNormal => AppMotion.standard;
  Duration get motionSlow => AppMotion.slow;

  Curve get motionDefaultCurve => AppMotion.easeOut;

  _LegacyDecoration get decoration => _LegacyDecoration(this);
  _LegacySpacing get spacing => _LegacySpacing();
}

class _LegacySpacing {
  double get sm => AppSpacing.s8;
  double get md => AppSpacing.s12;
  double get lg => AppSpacing.s16;
  double get xl => AppSpacing.s24;
  double get base => AppSpacing.s16;
  double get xs => AppSpacing.s4;
}

class _LegacyDecoration {
  const _LegacyDecoration(this.context);
  final BuildContext context;

  BoxDecoration glass({double opacity = 0.8, double borderRadius = 16}) {
    return BoxDecoration(
      color: context.colors.surfaceElevated.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
    );
  }

  BoxDecoration panel() {
    return BoxDecoration(
      color: context.colors.surfaceElevated,
      border: Border(
        top: BorderSide(color: context.colors.border),
      ),
    );
  }

  BoxDecoration cardElevated({required Color color, int elevation = 1}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: context.colors.border),
      boxShadow: elevation > 0 ? AppShadows.sm : AppShadows.none,
    );
  }
}

class SutolElevation {
  static const none = AppShadows.none;
  static const xs = AppShadows.sm;
  static const md = AppShadows.md;
  static const lg = AppShadows.lg;
  static const xl = AppShadows.lg;
  static const primaryGlow = AppShadows.lg;
}

class _LegacyMotion {
  Duration get fast => AppMotion.fast;
  Duration get normal => AppMotion.standard;
  Duration get slow => AppMotion.slow;
  Curve get defaultCurve => AppMotion.easeOut;
}

// Global Legacy Classes
class SutolLightColors {
  static const primary = Color(0xFF0F172A);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE2E8F0);
  static const onPrimaryContainer = Color(0xFF0F172A);
  static const surface = Color(0xFFFAFAFA);
  static const surfaceSubtle = Color(0xFFFAFAFA);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const onSurfaceVariant = Color(0xFF64748B);
  static const outline = Color(0xFFE2E8F0);
  static const outlineVariant = Color(0xFFF1F5F9);
  
  static const primaryHover = Color(0xFF1E293B);
  static const primaryPressed = Color(0xFF334155);
  static const primaryLight = Color(0xFFE2E8F0);
  
  static const infoContainer = Color(0xFFDBEAFE);
  static const onInfoContainer = Color(0xFF1E3A8A);
  static const successContainer = Color(0xFFD1FAE5);
  static const onSuccessContainer = Color(0xFF065F46);
  static const warningContainer = Color(0xFFFEF3C7);
  static const onWarningContainer = Color(0xFF92400E);
  static const errorContainer = Color(0xFFFEE2E2);
  static const onErrorContainer = Color(0xFF991B1B);
  
  static const error = Color(0xFFEF4444);
  static const secondaryContainer = Color(0xFFF1F5F9);
  static const onSecondaryContainer = Color(0xFF334155);
  
  static const onSurface = Color(0xFF0F172A);
}

class SutolDarkColors {
  static const primary = Color(0xFF14B8A6);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF1E293B);
  static const onPrimaryContainer = Color(0xFFF8FAFC);
  static const surface = Color(0xFF090D16);
  static const surfaceSubtle = Color(0xFF131B2E);
  static const surfaceElevated = Color(0xFF131B2E);
  static const onSurfaceVariant = Color(0xFF94A3B8);
  static const outline = Color(0xFF26334D);
  static const outlineVariant = Color(0xFF334155);
  
  static const primaryHover = Color(0xFF0D9488);
  static const primaryPressed = Color(0xFF0F766E);
  static const primaryLight = Color(0xFF134E4A);
  
  static const infoContainer = Color(0xFF1E3A8A);
  static const onInfoContainer = Color(0xFFDBEAFE);
  static const successContainer = Color(0xFF065F46);
  static const onSuccessContainer = Color(0xFFD1FAE5);
  static const warningContainer = Color(0xFF92400E);
  static const onWarningContainer = Color(0xFFFEF3C7);
  static const errorContainer = Color(0xFF991B1B);
  static const onErrorContainer = Color(0xFFFEE2E2);
  
  static const error = Color(0xFFF87171);
  static const secondaryContainer = Color(0xFF1E293B);
  static const onSecondaryContainer = Color(0xFFF1F5F9);
  
  static const onSurface = Color(0xFFF8FAFC);
}

class SutolMotion {
  static const instant = Duration.zero;
  static const fastest = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const moderate = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 400);
  static const ease = Curves.easeOutCubic;
  static const easeOut = Curves.easeOutCubic;
  static const easeIn = Curves.easeInCubic;
  static const easeInOut = Curves.easeInOutCubic;
  static const spring = Curves.fastOutSlowIn;
  static const smooth = Curves.easeInOutSine;
  static const staggerBase = Duration(milliseconds: 50);
}

class SutolRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double full = 9999;
}

class SutolSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double base = 16;
  static const double section = 64;
  static const double hero = 80;
}

class SutolTypography {
  static const displayLarge = AppTypography.display;
  static const displayMedium = AppTypography.headline;
  static const displaySmall = AppTypography.headline;
  static const headlineLarge = AppTypography.headline;
  static const headlineMedium = AppTypography.titleLarge;
  static const headlineSmall = AppTypography.titleMedium;
  static const titleLarge = AppTypography.titleLarge;
  static const titleMedium = AppTypography.titleMedium;
  static const titleSmall = AppTypography.titleMedium;
  static const bodyLarge = AppTypography.bodyLarge;
  static const bodyMedium = AppTypography.bodyMedium;
  static const bodySmall = AppTypography.bodyMedium;
  static const labelLarge = AppTypography.labelLarge;
  static const labelMedium = AppTypography.labelMedium;
  static const labelSmall = AppTypography.labelSmall;
  static const caption = AppTypography.labelSmall;
}

extension SutolThemeLegacyMore on BuildContext {
  double get sm => AppSpacing.s8;
  double get md => AppSpacing.s12;
  double get lg => AppSpacing.s16;
  double get xl => AppSpacing.s24;
  double get xs => AppSpacing.s4;
  Color get primaryLight => colors.primary.withValues(alpha: 0.1);
  _LegacyMotion get motion => _LegacyMotion();
  List<BoxShadow> get elevation0 => AppShadows.none;
  List<BoxShadow> get elevation1 => AppShadows.sm;
  List<BoxShadow> get elevation2 => AppShadows.md;
  List<BoxShadow> get elevation3 => AppShadows.lg;
}