import 'dart:ui';
import 'package:flutter/material.dart';

import '../../services/cookie_consent_service.dart';
import '../design/design_system.dart';

/// Çerez onayı katmanı — uygulama ana widget'ını sarmalar
class CookieConsentHost extends StatefulWidget {
  const CookieConsentHost({super.key, required this.child});

  final Widget child;

  @override
  State<CookieConsentHost> createState() => _CookieConsentHostState();
}

class _CookieConsentHostState extends State<CookieConsentHost> {
  @override
  void initState() {
    super.initState();
    CookieConsentService.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CookieConsentState>(
      valueListenable: CookieConsentService.instance.state,
      builder: (context, state, _) {
        final bool showBanner = state == CookieConsentState.undecided;

        return Stack(
          children: [
            Positioned.fill(child: widget.child),
            if (showBanner)
              const Align(
                alignment: Alignment.bottomCenter,
                child: _CookieConsentBanner(),
              ),
          ],
        );
      },
    );
  }
}

class _CookieConsentBanner extends StatefulWidget {
  const _CookieConsentBanner();

  @override
  State<_CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<_CookieConsentBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openPreferencesModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CookiePreferencesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>() ??
        (isDark ? AppColors.dark : AppColors.light);

    final bgColor = isDark
        ? const Color(0xFA0F172A)
        : const Color(0xFAFFFFFF);
    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 20),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 840;

                return Container(
                  constraints: const BoxConstraints(maxWidth: 860),
                  margin: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 24,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: EdgeInsets.all(isCompact ? 16 : 18),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                              blurRadius: 20,
                              spreadRadius: -2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: isCompact
                            ? _buildMobileLayout(context, appColors, isDark)
                            : _buildDesktopLayout(context, appColors, isDark),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, AppColors appColors, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconBadge(appColors, isDark),
        const SizedBox(width: 14),
        Expanded(
          child: _buildDescription(context, appColors, isDark),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCustomizeButton(context, appColors, isDark),
              _buildEssentialButton(appColors, isDark),
              _buildAcceptAllButton(context, appColors, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, AppColors appColors, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconBadge(appColors, isDark),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDescription(context, appColors, isDark),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAcceptAllButton(context, appColors, isDark, isFullWidth: true),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildEssentialButton(appColors, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildCustomizeButton(context, appColors, isDark)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconBadge(AppColors appColors, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.cookie_outlined,
        color: appColors.textSecondary,
        size: 18,
      ),
    );
  }

  Widget _buildDescription(
      BuildContext context, AppColors appColors, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çerez Tercihleriniz ve Gizliliğiniz',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: appColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text:
                    'Sutols, platform performansını ve deneyiminizi iyileştirmek için çerezler kullanır. ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/gizlilik');
                  },
                  child: Text(
                    'Gizlilik Politikası',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizeButton(
      BuildContext context, AppColors appColors, bool isDark) {
    return OutlinedButton.icon(
      onPressed: () => _openPreferencesModal(context),
      icon: Icon(
        Icons.tune_rounded,
        size: 14,
        color: appColors.textPrimary,
      ),
      label: Text(
        'Özelleştir',
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: appColors.textPrimary,
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildEssentialButton(AppColors appColors, bool isDark) {
    return OutlinedButton(
      onPressed: () {
        CookieConsentService.instance.essentialOnly();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: appColors.textSecondary,
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Sadece Zorunlu',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: appColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAcceptAllButton(
      BuildContext context, AppColors appColors, bool isDark,
      {bool isFullWidth = false}) {
    final button = ElevatedButton(
      onPressed: () {
        CookieConsentService.instance.accept();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? appColors.primary : const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Tümünü Kabul Et',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Çerez Tercihleri Modalı (Sheet)
class _CookiePreferencesSheet extends StatefulWidget {
  const _CookiePreferencesSheet();

  @override
  State<_CookiePreferencesSheet> createState() =>
      _CookiePreferencesSheetState();
}

class _CookiePreferencesSheetState extends State<_CookiePreferencesSheet> {
  bool _analyticsAllowed = true;

  @override
  void initState() {
    super.initState();
    _analyticsAllowed = CookieConsentService.instance.analyticsAllowed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>() ??
        (isDark ? AppColors.dark : AppColors.light);

    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: appColors.textPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Çerez Tercihleri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: appColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: appColors.textSecondary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Kapat',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Kullanılan çerez türlerini inceleyebilir ve tercihlerinizi güncelleyebilirsiniz.',
              style: TextStyle(
                fontSize: 12.5,
                color: appColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 14),

            // Zorunlu Çerezler
            _buildPreferenceTile(
              appColors: appColors,
              isDark: isDark,
              title: 'Zorunlu Çerezler',
              subtitle:
                  'Oturum yönetimi ve güvenlik için gereklidir. Devre dışı bırakılamaz.',
              value: true,
              onChanged: null,
            ),

            const SizedBox(height: 12),

            // Analitik Çerezler
            _buildPreferenceTile(
              appColors: appColors,
              isDark: isDark,
              title: 'Analitik & Performans Çerezleri',
              subtitle:
                  'Kullanım istatistiklerini anonim olarak ölçümleyerek platformu geliştirmemize yardımcı olur.',
              value: _analyticsAllowed,
              onChanged: (val) {
                setState(() {
                  _analyticsAllowed = val;
                });
              },
            ),

            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    CookieConsentService.instance.essentialOnly();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Tümünü Reddet',
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_analyticsAllowed) {
                      CookieConsentService.instance.accept();
                    } else {
                      CookieConsentService.instance.essentialOnly();
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? appColors.primary : const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Seçimleri Kaydet',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required AppColors appColors,
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: appColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? appColors.primary : const Color(0xFF0F172A),
          ),
        ],
      ),
    );
  }
}