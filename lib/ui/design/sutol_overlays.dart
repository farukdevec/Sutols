import 'package:flutter/material.dart';

import 'design_system.dart';
import 'sutol_widgets.dart';

// ─────────────────────────────────────────────
//  Sutol Premium Overlays — 2026
//  Dialogs, Toasts, Tooltips
// ─────────────────────────────────────────────

class SutolOverlays {
  SutolOverlays._();

  static void showToast(BuildContext context, String message, {IconData? icon}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? SutolDarkColors.surfaceElevated : const Color(0xFF1E293B);
    final textColor = isDark ? SutolDarkColors.onSurface : Colors.white;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: SutolTypography.bodyMedium.copyWith(color: textColor),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SutolRadius.md)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: SutolMotion.normal,
      pageBuilder: (context, anim1, anim2) {
        return _SutolDialogWidget(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: SutolMotion.spring),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }
}

class _SutolDialogWidget extends StatelessWidget {
  const _SutolDialogWidget({
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final Widget content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? SutolDarkColors.surface : SutolLightColors.surface;
    final outlineColor = isDark ? SutolDarkColors.outline : SutolLightColors.outline;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 400,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width - 32 < 400
                ? MediaQuery.sizeOf(context).width - 32
                : 400,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(SutolRadius.xl),
            border: Border.all(color: outlineColor, width: 1),
            boxShadow: SutolElevation.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: SutolTypography.headlineSmall.copyWith(
                          color: isDark ? SutolDarkColors.onSurface : SutolLightColors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      color: isDark ? SutolDarkColors.onSurfaceVariant : SutolLightColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SutolDivider(),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
              // Footer
              if (confirmText != null || cancelText != null) ...[
                const SutolDivider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (cancelText != null)
                        SutolButton(
                          label: cancelText!,
                          variant: SutolButtonVariant.ghost,
                          onPressed: () {
                            if (onCancel != null) onCancel!();
                            Navigator.of(context).pop();
                          },
                        ),
                      if (cancelText != null && confirmText != null) const SizedBox(width: 12),
                      if (confirmText != null)
                        SutolButton(
                          label: confirmText!,
                          variant: SutolButtonVariant.primary,
                          onPressed: () {
                            if (onConfirm != null) onConfirm!();
                          },
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
