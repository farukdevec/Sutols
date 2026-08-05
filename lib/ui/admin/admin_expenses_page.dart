import 'package:flutter/material.dart';

import '../design/design_system.dart';

class AdminExpensesPage extends StatelessWidget {
  const AdminExpensesPage({super.key});

  static const List<_ExpenseCardData> _cards = [
    _ExpenseCardData(
      title: 'Gemini',
      icon: Icons.auto_awesome_outlined,
      color: Color(0xFF6A1B9A),
    ),
    _ExpenseCardData(
      title: 'Firebase',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFFF8F00),
    ),
    _ExpenseCardData(
      title: 'Cloudflare',
      icon: Icons.cloud_outlined,
      color: Color(0xFF1565C0),
    ),
    _ExpenseCardData(
      title: 'Hosting',
      icon: Icons.dns_outlined,
      color: Color(0xFF00838F),
    ),
    _ExpenseCardData(
      title: 'Domain',
      icon: Icons.language_outlined,
      color: Color(0xFF2E7D32),
    ),
    _ExpenseCardData(
      title: 'Other',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF616161),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 3
              : (constraints.maxWidth >= 480 ? 2 : 1);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s32),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppSpacing.s16,
                  crossAxisSpacing: AppSpacing.s16,
                  childAspectRatio: 1.8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return _ExpenseCard(data: _cards[index]);
                },
              ),
              const SizedBox(height: AppSpacing.s32),
              _TotalExpensesCard(),
            ],
          );
        },
      ),
    );
  }
}

class _ExpenseCardData {
  const _ExpenseCardData({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.data});

  final _ExpenseCardData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(data.icon, size: 22, color: data.color),
            ),
            const Spacer(),
            Text(
              '0',
              style: AppTypography.display.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalExpensesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 26,
                color: colors.danger,
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Text(
              'Toplam Gider',
              style: AppTypography.titleMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '0',
              style: AppTypography.headline.copyWith(
                color: colors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
