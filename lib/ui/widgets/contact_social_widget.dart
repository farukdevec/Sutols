import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/url_launcher_service.dart';
import '../design/design_system.dart';

/// Gerçek Instagram Kamera Vektör İkonu (CustomPainter)
class OfficialInstagramIcon extends StatelessWidget {
  const OfficialInstagramIcon({
    super.key,
    this.size = 14,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _InstagramLogoPainter(color: color),
      ),
    );
  }
}

class _InstagramLogoPainter extends CustomPainter {
  const _InstagramLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.11;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(size.width * 0.28),
    );
    canvas.drawRRect(rect, paint);

    // İç mercek çemberi
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.23;
    canvas.drawCircle(center, radius, paint);

    // Sağ üst flaş noktası
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    final dotCenter = Offset(size.width * 0.72, size.height * 0.28);
    final dotRadius = size.width * 0.07;
    canvas.drawCircle(dotCenter, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _InstagramLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Mail ikonu olarak kullanılan Sutols marka logosu
class SutolsMailIcon extends StatelessWidget {
  const SutolsMailIcon({
    super.key,
    this.size = 16,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

/// İletişim Diyaloğunu Açan Yardımcı Fonksiyon
void showSutolContactDialog(BuildContext context) {
  final colors = context.colors;
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: SutolsMailIcon(size: 22),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İletişim & Sosyal Medya',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Bizimle doğrudan bağlantı kurun.',
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              const SutolContactChips(showTitle: false),
              const SizedBox(height: AppSpacing.s16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Shık ve modern Instagram & E-posta iletişim bileşeni.
class SutolContactChips extends StatelessWidget {
  const SutolContactChips({
    super.key,
    this.compact = false,
    this.showTitle = false,
  });

  final bool compact;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showTitle) ...[
          Text(
            'Bizimle İletişime Geçin',
            style: AppTypography.titleMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: compact ? AppSpacing.s8 : AppSpacing.s12,
          runSpacing: compact ? AppSpacing.s8 : AppSpacing.s12,
          children: const [
            _InstagramChip(handle: '@sutolscom'),
            _EmailChip(email: 'contact@sutols.com'),
          ],
        ),
      ],
    );
  }
}

class _InstagramChip extends StatefulWidget {
  const _InstagramChip({required this.handle});

  final String handle;

  @override
  State<_InstagramChip> createState() => _InstagramChipState();
}

class _InstagramChipState extends State<_InstagramChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: 'Instagram\'da Bizi Takip Edin (${widget.handle})',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => UrlLauncherService.openInstagram(widget.handle),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? const Color(0xFFE1306C).withValues(alpha: 0.12)
                  : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFFE1306C).withValues(alpha: 0.5)
                    : colors.border,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE1306C).withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gerçek Instagram İkonu İçeren Gradyan Rozet
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF833AB4),
                        Color(0xFFFD1D1D),
                        Color(0xFFF77737),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: OfficialInstagramIcon(size: 13, color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  widget.handle,
                  style: AppTypography.labelMedium.copyWith(
                    color: _isHovered
                        ? colors.textPrimary
                        : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.s4),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 13,
                  color: _isHovered
                      ? const Color(0xFFE1306C)
                      : colors.textSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailChip extends StatefulWidget {
  const _EmailChip({required this.email});

  final String email;

  @override
  State<_EmailChip> createState() => _EmailChipState();
}

class _EmailChipState extends State<_EmailChip> {
  bool _isHovered = false;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.email));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('${widget.email} kopyalandı!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: 'E-posta Gönder (${widget.email})',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => UrlLauncherService.openEmail(widget.email),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: _isHovered
                  ? colors.primary.withValues(alpha: 0.12)
                  : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: _isHovered
                    ? colors.primary.withValues(alpha: 0.5)
                    : colors.border,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mail İkonu olarak Sutols Marka Logosu
                Container(
                  width: 22,
                  height: 22,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: colors.surfaceElevated,
                    border: Border.all(
                      color: colors.border,
                      width: 1,
                    ),
                  ),
                  child: const SutolsMailIcon(size: 16),
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  widget.email,
                  style: AppTypography.labelMedium.copyWith(
                    color: _isHovered
                        ? colors.textPrimary
                        : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6.0),
                Tooltip(
                  message: 'Adresi Kopyala',
                  child: InkWell(
                    onTap: () => _copyToClipboard(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: _isHovered
                            ? colors.primary
                            : colors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standalone Contact Card for pages like About, Legal, or FAQ.
class SutolContactCard extends StatelessWidget {
  const SutolContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const SutolsMailIcon(size: 20),
              ),
              const SizedBox(width: AppSpacing.s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İletişime Geçin',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Görüşleriniz ve sorularınız için bizimle bağlantı kurun.',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          const SutolContactChips(),
        ],
      ),
    );
  }
}
