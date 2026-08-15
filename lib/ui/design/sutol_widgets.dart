import 'package:flutter/material.dart';

import 'design_system.dart';

/// High-resolution Sutols brand lockup.
///
/// The symbol and custom wordmark stay as separate transparent assets so the
/// compact layout can show only the symbol without raster cropping.
class SutolsBrandLockup extends StatelessWidget {
  const SutolsBrandLockup({
    super.key,
    required this.height,
    this.showWordmark = true,
    this.showBetaBadge = true,
    this.color,
  });

  final double height;
  final bool showWordmark;
  final bool showBetaBadge;
  final Color? color;

  Widget _tinted(Widget child) {
    final tint = color;
    if (tint == null) return child;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final betaTextColor = color ??
        (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5));

    return Semantics(
      image: true,
      label: 'Sutols Beta',
      child: SizedBox(
        height: height,
        child: _tinted(
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox.square(
                dimension: height,
                child: Image.asset(
                  'assets/images/logo.webp',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              if (showWordmark) ...<Widget>[
                SizedBox(width: height * 0.12),
                SizedBox(
                  height: height * 0.58,
                  child: Image.asset(
                    'assets/images/sutols_wordmark.webp',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ],
              if (showBetaBadge) ...<Widget>[
                SizedBox(width: height * 0.18),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (height * 0.18).clamp(5.0, 9.0),
                    vertical: (height * 0.06).clamp(2.0, 4.0),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withValues(alpha: 0.15),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(SutolRadius.xs),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'BETA',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: (height * 0.26).clamp(9.0, 11.0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: betaTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Sutol Premium Widget Library — 2026
//  Reusable, animated, design-system-connected
// ─────────────────────────────────────────────

// ── SutolButton ────────────────────────────────

enum SutolButtonVariant { primary, secondary, ghost, destructive }

class SutolButton extends StatefulWidget {
  const SutolButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = SutolButtonVariant.primary,
    this.isLoading = false,
    this.isCompact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SutolButtonVariant variant;
  final bool isLoading;
  final bool isCompact;

  @override
  State<SutolButton> createState() => _SutolButtonState();
}

class _SutolButtonState extends State<SutolButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool enabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    Color border;

    switch (widget.variant) {
      case SutolButtonVariant.primary:
        bg = _pressed
            ? (isDark
                ? SutolDarkColors.primaryPressed
                : SutolLightColors.primaryPressed)
            : _hovered
                ? (isDark
                    ? SutolDarkColors.primaryHover
                    : SutolLightColors.primaryHover)
                : (isDark ? SutolDarkColors.primary : SutolLightColors.primary);
        fg = isDark ? SutolDarkColors.onPrimary : SutolLightColors.onPrimary;
        border = Colors.transparent;
      case SutolButtonVariant.secondary:
        bg = _hovered
            ? (isDark
                ? SutolDarkColors.surfaceElevated
                : SutolLightColors.surfaceSubtle)
            : (isDark ? SutolDarkColors.surface : SutolLightColors.surface);
        fg = isDark ? SutolDarkColors.onSurface : SutolLightColors.onSurface;
        border = isDark ? SutolDarkColors.outline : SutolLightColors.outline;
      case SutolButtonVariant.ghost:
        bg = _hovered
            ? (isDark
                ? SutolDarkColors.surfaceElevated
                : SutolLightColors.surfaceSubtle)
            : Colors.transparent;
        fg = isDark
            ? SutolDarkColors.onSurfaceVariant
            : SutolLightColors.onSurfaceVariant;
        border = Colors.transparent;
      case SutolButtonVariant.destructive:
        bg = _hovered
            ? (isDark
                ? SutolDarkColors.errorContainer
                : SutolLightColors.errorContainer)
            : Colors.transparent;
        fg = isDark ? SutolDarkColors.error : SutolLightColors.error;
        border = isDark ? SutolDarkColors.error : SutolLightColors.error;
    }

    if (!enabled) {
      bg = bg.withValues(alpha: 0.5);
      fg = fg.withValues(alpha: 0.5);
      border = border.withValues(alpha: 0.3);
    }

    final vPad = widget.isCompact ? 8.0 : 10.0;
    final hPad = widget.isCompact ? 14.0 : 18.0;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: SutolMotion.fast,
          curve: SutolMotion.ease,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(SutolRadius.md),
            border: Border.all(color: border, width: 1),
            boxShadow: widget.variant == SutolButtonVariant.primary &&
                    _hovered &&
                    enabled
                ? SutolElevation.primaryGlow
                : SutolElevation.none,
          ),
          transform: _pressed
              ? Matrix4.diagonal3Values(0.97, 0.97, 1)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.isLoading)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  ),
                )
              else if (widget.icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(widget.icon, size: 18, color: fg),
                ),
              Text(
                widget.label,
                style: SutolTypography.labelLarge.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SutolIconButton ────────────────────────────

class SutolIconButton extends StatefulWidget {
  const SutolIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 36,
    this.iconSize = 18,
    this.isSelected = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final bool isSelected;

  @override
  State<SutolIconButton> createState() => _SutolIconButtonState();
}

class _SutolIconButtonState extends State<SutolIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool enabled = widget.onPressed != null;

    final Color bgColor;
    final Color iconColor;

    if (widget.isSelected) {
      bgColor =
          isDark ? SutolDarkColors.primaryLight : SutolLightColors.primaryLight;
      iconColor = isDark ? SutolDarkColors.primary : SutolLightColors.primary;
    } else if (_hovered && enabled) {
      bgColor = isDark
          ? SutolDarkColors.surfaceElevated
          : SutolLightColors.surfaceSubtle;
      iconColor =
          isDark ? SutolDarkColors.onSurface : SutolLightColors.onSurface;
    } else {
      bgColor = Colors.transparent;
      iconColor = isDark
          ? SutolDarkColors.onSurfaceVariant
          : SutolLightColors.onSurfaceVariant;
    }

    Widget button = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: SutolMotion.fast,
          curve: SutolMotion.ease,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(SutolRadius.md),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: enabled ? iconColor : iconColor.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

// ── SutolCard ──────────────────────────────────

class SutolCard extends StatefulWidget {
  const SutolCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsets? padding;

  @override
  State<SutolCard> createState() => _SutolCardState();
}

class _SutolCardState extends State<SutolCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? SutolDarkColors.surface : SutolLightColors.surface;
    final borderColor = widget.isSelected
        ? (isDark ? SutolDarkColors.primary : SutolLightColors.primary)
        : (isDark ? SutolDarkColors.outline : SutolLightColors.outline);
    final shadow = _hovered ? SutolElevation.md : SutolElevation.xs;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: SutolMotion.normal,
          curve: SutolMotion.ease,
          padding: widget.padding ?? const EdgeInsets.all(SutolSpacing.base),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(SutolRadius.lg),
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: shadow,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── SutolChip ──────────────────────────────────

class SutolChip extends StatelessWidget {
  const SutolChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? (isDark
            ? SutolDarkColors.primaryLight
            : SutolLightColors.primaryLight)
        : (isDark
            ? SutolDarkColors.surfaceElevated
            : SutolLightColors.surfaceSubtle);
    final textColor = isSelected
        ? (isDark ? SutolDarkColors.primary : SutolLightColors.primary)
        : (isDark ? SutolDarkColors.onSurface : SutolLightColors.onSurface);
    final borderColor = isSelected
        ? (isDark
            ? SutolDarkColors.primaryContainer
            : SutolLightColors.primaryContainer)
        : (isDark ? SutolDarkColors.outline : SutolLightColors.outline);

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SutolSpacing.md,
        vertical: SutolSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SutolRadius.sm),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: SutolTypography.labelMedium.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      chip = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: chip),
      );
    }

    return chip;
  }
}

// ── SutolBadge ─────────────────────────────────

enum SutolBadgeVariant { info, success, warning, error, neutral }

class SutolBadge extends StatelessWidget {
  const SutolBadge({
    super.key,
    required this.label,
    this.variant = SutolBadgeVariant.neutral,
  });

  final String label;
  final SutolBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    switch (variant) {
      case SutolBadgeVariant.info:
        bg = isDark
            ? SutolDarkColors.infoContainer
            : SutolLightColors.infoContainer;
        fg = isDark
            ? SutolDarkColors.onInfoContainer
            : SutolLightColors.onInfoContainer;
      case SutolBadgeVariant.success:
        bg = isDark
            ? SutolDarkColors.successContainer
            : SutolLightColors.successContainer;
        fg = isDark
            ? SutolDarkColors.onSuccessContainer
            : SutolLightColors.onSuccessContainer;
      case SutolBadgeVariant.warning:
        bg = isDark
            ? SutolDarkColors.warningContainer
            : SutolLightColors.warningContainer;
        fg = isDark
            ? SutolDarkColors.onWarningContainer
            : SutolLightColors.onWarningContainer;
      case SutolBadgeVariant.error:
        bg = isDark
            ? SutolDarkColors.errorContainer
            : SutolLightColors.errorContainer;
        fg = isDark
            ? SutolDarkColors.onErrorContainer
            : SutolLightColors.onErrorContainer;
      case SutolBadgeVariant.neutral:
        bg = isDark
            ? SutolDarkColors.secondaryContainer
            : SutolLightColors.secondaryContainer;
        fg = isDark
            ? SutolDarkColors.onSecondaryContainer
            : SutolLightColors.onSecondaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SutolRadius.xs),
      ),
      child: Text(
        label,
        style: SutolTypography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── SutolDivider ───────────────────────────────

class SutolDivider extends StatelessWidget {
  const SutolDivider({
    super.key,
    this.label,
    this.vertical = false,
    this.indent = 0,
  });

  final String? label;
  final bool vertical;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;

    if (vertical) {
      return Container(
        width: 1,
        color: color,
        margin: EdgeInsets.symmetric(vertical: indent),
      );
    }

    if (label != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: indent),
        child: Row(
          children: <Widget>[
            Expanded(child: Container(height: 1, color: color)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label!,
                style: SutolTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: color)),
          ],
        ),
      );
    }

    return Container(
      height: 1,
      color: color,
      margin: EdgeInsets.symmetric(horizontal: indent),
    );
  }
}

// ── SutolShimmer ───────────────────────────────

class SutolShimmer extends StatefulWidget {
  const SutolShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<SutolShimmer> createState() => _SutolShimmerState();
}

class _SutolShimmerState extends State<SutolShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? SutolDarkColors.surfaceElevated
        : SutolLightColors.surfaceSubtle;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? SutolRadius.sm,
            ),
            gradient: LinearGradient(
              colors: <Color>[
                baseColor,
                baseColor.withValues(alpha: 0.5),
                baseColor,
              ],
              stops: const <double>[0.0, 0.5, 1.0],
              begin: Alignment(-1.5 + 3 * _controller.value, 0),
              end: Alignment(-0.5 + 3 * _controller.value, 0),
            ),
          ),
        );
      },
    );
  }
}

// ── SutolEmptyState ────────────────────────────

class SutolEmptyState extends StatelessWidget {
  const SutolEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SutolSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SutolRadius.xl),
              ),
              child: Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: SutolSpacing.base),
            Text(
              title,
              style: SutolTypography.headlineSmall.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SutolSpacing.sm),
              Text(
                subtitle!,
                style: SutolTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && onAction != null) ...[
              const SizedBox(height: SutolSpacing.lg),
              SutolButton(
                label: action!,
                onPressed: onAction,
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Stagger Animation Helper ───────────────────

class SutolStaggeredFadeIn extends StatelessWidget {
  const SutolStaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = SutolMotion.staggerBase,
    this.duration = SutolMotion.moderate,
  });

  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds:
            duration.inMilliseconds + baseDelay.inMilliseconds * index,
      ),
      curve: SutolMotion.ease,
      builder: (context, value, child) {
        final delayed =
            ((value - (index * 0.08)).clamp(0.0, 1.0) / 0.92).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
