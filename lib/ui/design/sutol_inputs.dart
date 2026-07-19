import 'package:flutter/material.dart';

import 'design_system.dart';

// ─────────────────────────────────────────────
//  Sutol Premium Inputs — 2026
// ─────────────────────────────────────────────

class SutolInput extends StatefulWidget {
  const SutolInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.focusNode,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool readOnly;

  @override
  State<SutolInput> createState() => _SutolInputState();
}

class _SutolInputState extends State<SutolInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? SutolDarkColors.surfaceSubtle
        : SutolLightColors.surfaceSubtle;
    final borderColor = isDark ? SutolDarkColors.outline : SutolLightColors.outline;
    final focusColor = isDark ? SutolDarkColors.primary : SutolLightColors.primary;
    final textColor = isDark ? SutolDarkColors.onSurface : SutolLightColors.onSurface;
    final hintColor = isDark
        ? SutolDarkColors.onSurfaceVariant.withValues(alpha: 0.5)
        : SutolLightColors.onSurfaceVariant.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: SutolTypography.labelMedium.copyWith(
              color: isDark ? SutolDarkColors.onSurfaceVariant : SutolLightColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: SutolMotion.fast,
          curve: SutolMotion.ease,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(SutolRadius.md),
            border: Border.all(
              color: _isFocused ? focusColor : borderColor,
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: focusColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : SutolElevation.xs,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onChanged: widget.onChanged,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            style: SutolTypography.bodyMedium.copyWith(color: textColor),
            cursorColor: focusColor,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: SutolTypography.bodyMedium.copyWith(color: hintColor),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _isFocused ? focusColor : hintColor,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

// ── SutolDropdown ─────────────────────────────────────────────

class SutolDropdown<T> extends StatelessWidget {
  const SutolDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelText,
    this.icon,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? labelText;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? SutolDarkColors.surfaceSubtle
        : SutolLightColors.surfaceSubtle;
    final borderColor = isDark ? SutolDarkColors.outline : SutolLightColors.outline;
    final textColor = isDark ? SutolDarkColors.onSurface : SutolLightColors.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: SutolTypography.labelMedium.copyWith(
              color: isDark ? SutolDarkColors.onSurfaceVariant : SutolLightColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(SutolRadius.md),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: SutolElevation.xs,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              icon: Icon(
                icon ?? Icons.unfold_more_rounded,
                size: 20,
                color: isDark ? SutolDarkColors.onSurfaceVariant : SutolLightColors.onSurfaceVariant,
              ),
              isExpanded: true,
              dropdownColor: isDark ? SutolDarkColors.surface : SutolLightColors.surface,
              style: SutolTypography.bodyMedium.copyWith(color: textColor),
              borderRadius: BorderRadius.circular(SutolRadius.md),
            ),
          ),
        ),
      ],
    );
  }
}
