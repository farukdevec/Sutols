import 'package:flutter/material.dart';

import '../../services/cookie_consent_service.dart';
import '../design/design_system.dart';

/// Çerez onayı bekleyen kullanıcıya (ilk girişte) alt banner gösteren
/// üst sarmalayıcı. Karar verilene kadar kalıcıdır (SnackBar değil).
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
        return Stack(
          children: [
            Positioned.fill(child: widget.child),
            if (state == CookieConsentState.undecided)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: const _CookieConsentBanner(),
              ),
          ],
        );
      },
    );
  }
}

class _CookieConsentBanner extends StatelessWidget {
  const _CookieConsentBanner();

  void _accept() {
    CookieConsentService.instance.accept();
  }

  void _essentialOnly() {
    CookieConsentService.instance.essentialOnly();
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).pushNamed('/gizlilik');
  }

  void _openTerms(BuildContext context) {
    Navigator.of(context).pushNamed('/sartlar');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final narrow = MediaQuery.sizeOf(context).width < 640;

    final privacyLink = TextButton(
      onPressed: () => _openPrivacyPolicy(context),
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: const Text('Gizlilik Politikası'),
    );

    final termsLink = TextButton(
      onPressed: () => _openTerms(context),
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: const Text('Kullanım Şartları'),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.6)),
        ),
        boxShadow: AppShadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(narrow ? AppSpacing.s16 : AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Deneyiminizi geliştiriyoruz',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text.rich(
                TextSpan(
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Sutols, size daha iyi bir sunum oluşturma deneyimi sağlamak '
                          'için temel çerezler ve kullanım verileri (örneğin hangi '
                          'tasarımların işe yaradığı) toplar. Bu veriler, sistemi '
                          'geliştirmek ve size daha iyi öneriler sunmak için kullanılır. '
                          'Devam ederek ',
                    ),
                    WidgetSpan(alignment: PlaceholderAlignment.middle, child: privacyLink),
                    const TextSpan(text: ' ve '),
                    WidgetSpan(alignment: PlaceholderAlignment.middle, child: termsLink),
                    const TextSpan(text: "'nı kabul etmiş olursunuz."),
                  ],
                ),
              ),
              SizedBox(height: narrow ? AppSpacing.s16 : AppSpacing.s24),
              if (narrow) ...[
                FilledButton.icon(
                  onPressed: _accept,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Kabul Et'),
                ),
                const SizedBox(height: AppSpacing.s8),
                OutlinedButton(
                  onPressed: _essentialOnly,
                  child: const Text('Sadece Zorunlu Çerezler'),
                ),
                const SizedBox(height: AppSpacing.s4),
                TextButton(
                  onPressed: () => _openPrivacyPolicy(context),
                  child: const Text('Daha Fazla Bilgi'),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _essentialOnly,
                        child: const Text('Sadece Zorunlu Çerezler'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    TextButton(
                      onPressed: () => _openPrivacyPolicy(context),
                      child: const Text('Daha Fazla Bilgi'),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    FilledButton.icon(
                      onPressed: _accept,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Kabul Et'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}