import 'package:flutter/material.dart';

import 'design/design_system.dart';
import 'redeem_code_page.dart';

class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Üyelik Planları')),
      backgroundColor: colors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s32),
            child: Column(
              children: [
                Text(
                  'Fikirden sunuma, tek cümlede.',
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Size uygun planı seçin ve sunum üretimini başlatın.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RedeemCodePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.redeem_outlined, size: 18),
                  label: const Text('Bir promosyon kodunuz mu var? Kodunuzu kullanın'),
                ),
                const SizedBox(height: AppSpacing.s32),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      final freeCard = const _MembershipCard(
                        title: 'Ücretsiz',
                        price: '₺0 / ay',
                        features: [
                          'Günde 3 sunum',
                          'Temel model kütüphanesi',
                          '5 slaytlık sunumlar',
                        ],
                        buttonLabel: 'Mevcut Planınız',
                      );
                      final plusCard = const _MembershipCard(
                        title: 'Plus',
                        price: '₺XX / ay',
                        features: [
                          'Günde 15 sunum',
                          'Genişletilmiş model kütüphanesi',
                          '5/8/12 slaytlık sunumlar',
                        ],
                        buttonLabel: 'Yükselt',
                        highlighted: true,
                        buttonEnabled: true,
                      );
                      final premiumCard = const _MembershipCard(
                        title: 'Premium',
                        price: '₺XX / ay',
                        features: [
                          'Sınırsız sunum',
                          'Tüm modellere erişim',
                          'Tüm slayt seçenekleri',
                          'Öncelikli destek',
                        ],
                        buttonLabel: 'Yükselt',
                        buttonEnabled: true,
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: freeCard),
                            const SizedBox(width: AppSpacing.s24),
                            Expanded(child: plusCard),
                            const SizedBox(width: AppSpacing.s24),
                            Expanded(child: premiumCard),
                          ],
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            freeCard,
                            const SizedBox(height: AppSpacing.s24),
                            plusCard,
                            const SizedBox(height: AppSpacing.s24),
                            premiumCard,
                          ],
                        ),
                      );
                    },
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

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.title,
    required this.price,
    required this.features,
    required this.buttonLabel,
    this.highlighted = false,
    this.buttonEnabled = false,
  });

  final String title;
  final String price;
  final List<String> features;
  final String buttonLabel;
  final bool highlighted;
  final bool buttonEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = highlighted ? colors.primary : colors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: highlighted ? colors.primary : colors.border,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: highlighted ? AppShadows.lg : AppShadows.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
              ),
              if (highlighted) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Öne Çıkan',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: AppTypography.titleLarge.copyWith(
                  color: accent,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 18, color: accent),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.s24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: buttonEnabled
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ödeme sistemi yakında aktif olacak')),
                      );
                    }
                  : null,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
