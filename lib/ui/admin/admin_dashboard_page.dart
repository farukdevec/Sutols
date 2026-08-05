import 'package:flutter/material.dart';

import '../design/design_system.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const List<_StatCardData> _cards = [
    _StatCardData(
      title: 'Toplam Kullanıcı',
      icon: Icons.people_outlined,
      color: Color(0xFF1565C0),
    ),
    _StatCardData(
      title: 'Bugünkü Kullanıcı',
      icon: Icons.person_add_alt_1_outlined,
      color: Color(0xFF2E7D32),
    ),
    _StatCardData(
      title: 'Toplam Sunum',
      icon: Icons.slideshow_outlined,
      color: Color(0xFF6A1B9A),
    ),
    _StatCardData(
      title: 'Bugünkü Sunum',
      icon: Icons.today_outlined,
      color: Color(0xFFEF6C00),
    ),
    _StatCardData(
      title: 'Aktif Abonelik',
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFFC9A227),
    ),
    _StatCardData(
      title: 'Aylık Gelir',
      icon: Icons.payments_outlined,
      color: Color(0xFF2E7D32),
    ),
    _StatCardData(
      title: 'AI Gideri',
      icon: Icons.smart_toy_outlined,
      color: Color(0xFFD32F2F),
    ),
    _StatCardData(
      title: 'Net Kar',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF00695C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1200
              ? 4
              : (constraints.maxWidth >= 700 ? 3 : (constraints.maxWidth >= 480 ? 2 : 1));

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.s32),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.s16,
              crossAxisSpacing: AppSpacing.s16,
              childAspectRatio: 1.6,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              return _StatCard(data: _cards[index]);
            },
          );
        },
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
              ],
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
              maxLines: 2,
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
