import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/presentation_service.dart';
import 'design/design_system.dart';
import 'redeem_code_page.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  static const Color _plusGold = Color(0xFFC9A227);
  String _tier = 'free';
  bool _loadingPlan = true;

  bool get _hasPlus => PresentationService.hasPlusSlideAccess(_tier);

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loadingPlan = false);
      return;
    }
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final tier = snapshot.data()?['tier'] as String? ?? 'free';
      if (!mounted) return;
      setState(() {
        _tier = tier;
        _loadingPlan = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPlan = false);
    }
  }

  Future<void> _openRedeemCode() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RedeemCodePage()),
    );
    await _loadPlan();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentPlanLabel = _hasPlus ? 'Plus' : 'Ücretsiz';

    return Scaffold(
      appBar: AppBar(title: const Text('Üyelik Planları')),
      backgroundColor: colors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 600
                  ? AppSpacing.s16
                  : AppSpacing.s32,
            ),
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
                const SizedBox(height: AppSpacing.s16),
                Chip(
                  backgroundColor: _hasPlus
                      ? _plusGold.withValues(alpha: 0.14)
                      : colors.surfaceElevated,
                  side: BorderSide(
                    color: _hasPlus ? _plusGold : colors.border,
                  ),
                  avatar: _loadingPlan
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _hasPlus ? Icons.star_rounded : Icons.circle_outlined,
                          size: 16,
                          color: _hasPlus ? _plusGold : colors.textSecondary,
                        ),
                  label: Text(
                    _loadingPlan
                        ? 'Mevcut plan yükleniyor'
                        : 'Mevcut plan: $currentPlanLabel',
                    style: AppTypography.labelMedium.copyWith(
                      color: _hasPlus ? _plusGold : colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                TextButton.icon(
                  onPressed: _openRedeemCode,
                  icon: const Icon(Icons.redeem_outlined, size: 18),
                  label: const Text(
                      'Bir promosyon kodunuz mu var? Kodunuzu kullanın'),
                ),
                const SizedBox(height: AppSpacing.s32),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      final freeCard = _MembershipCard(
                        title: 'Ücretsiz',
                        price: '₺0 / ay',
                        features: const [
                          'Günde 5 sunum',
                          'Temel model kütüphanesi',
                          '1-7 slaytlık sunumlar',
                        ],
                        buttonLabel:
                            !_loadingPlan && !_hasPlus ? 'Mevcut Planınız' : '',
                        isCurrent: !_loadingPlan && !_hasPlus,
                      );
                      final plusCard = _MembershipCard(
                        title: 'Plus',
                        price: '₺XX / ay',
                        features: const [
                          'Günde 15 sunum',
                          'Genişletilmiş model kütüphanesi',
                          '1-30 slaytlık sunumlar',
                        ],
                        buttonLabel: !_loadingPlan && _hasPlus
                            ? 'Mevcut Planınız'
                            : 'Plus’a Geç',
                        highlighted: true,
                        isCurrent: !_loadingPlan && _hasPlus,
                        buttonEnabled: !_loadingPlan && !_hasPlus,
                      );
                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: freeCard),
                            const SizedBox(width: AppSpacing.s24),
                            Expanded(child: plusCard),
                          ],
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            freeCard,
                            const SizedBox(height: AppSpacing.s24),
                            plusCard,
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
    this.isCurrent = false,
  });

  final String title;
  final String price;
  final List<String> features;
  final String buttonLabel;
  final bool highlighted;
  final bool buttonEnabled;
  final bool isCurrent;

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
                style: AppTypography.titleLarge
                    .copyWith(color: colors.textPrimary),
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
              onPressed: isCurrent
                  ? null
                  : buttonEnabled
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Ödeme sistemi yakında aktif olacak')),
                          );
                        }
                      : null,
              child: Text(
                buttonLabel.isEmpty ? 'Plan yükleniyor...' : buttonLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
