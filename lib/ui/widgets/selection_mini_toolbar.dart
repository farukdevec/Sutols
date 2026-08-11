import 'package:flutter/material.dart';

import '../design/design_system.dart';

/// Tuvalin üstünde duran, seçime bağlı bağlamsal araç çubuğu (Canva tarzı).
/// Tekli seçimde [children] ile gösterilir; seçim yoksa null dönülmesi ve
/// bu widget'ın hiç eklenmemesi gerekir.
class SelectionContextBar extends StatelessWidget {
  const SelectionContextBar({
    super.key,
    required this.children,
  });

  /// Çubuk içeriği (ikon düğmeleri, ayraçlar).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Boş alana dokununca alttaki tuvalin "seçimi temizle" jestine
    // düşmemesi için çubuğun kendi hit alanını tüket.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colors.border),
        ),
        // Dar ekranda taşmaması için yatay kaydırılabilir; geniş ekranda
        // içerik sığdığında scroll devre dışı kalır.
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Bağlamsal araç çubuğundaki açma/kapama (toggle) düğmesi.
class MiniToolToggle extends StatelessWidget {
  const MiniToolToggle({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? colors.surface : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Bağlamsal araç çubuğundaki tek eylemli düğme (toggle olmayan).
class MiniToolAction extends StatelessWidget {
  const MiniToolAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? colors.onSurfaceVariant
                : colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

/// Bağlamsal araç çubuğundaki ince dikey ayraç.
class MiniToolDivider extends StatelessWidget {
  const MiniToolDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: context.colors.border,
    );
  }
}

/// Bağlamsal araç çubuğundaki etiketli toggle (ikon + kısa metin).
class MiniToolLabeledToggle extends StatelessWidget {
  const MiniToolLabeledToggle({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: active ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 17,
                color: active ? colors.surface : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: active ? colors.surface : colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
