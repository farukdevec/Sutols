import 'package:flutter/material.dart';

import '../design/design_system.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  static const List<_AnalyticsCardData> _cards = [
    _AnalyticsCardData(
      title: 'DAU',
      icon: Icons.person_pin_outlined,
      color: Color(0xFF1565C0),
    ),
    _AnalyticsCardData(
      title: 'WAU',
      icon: Icons.groups_outlined,
      color: Color(0xFF2E7D32),
    ),
    _AnalyticsCardData(
      title: 'MAU',
      icon: Icons.group_outlined,
      color: Color(0xFF6A1B9A),
    ),
    _AnalyticsCardData(
      title: 'Yeni Kullanıcı',
      icon: Icons.person_add_alt_1_outlined,
      color: Color(0xFFEF6C00),
    ),
    _AnalyticsCardData(
      title: 'Ortalama Oturum',
      icon: Icons.timer_outlined,
      color: Color(0xFF00838F),
    ),
    _AnalyticsCardData(
      title: 'Sunum Sayısı',
      icon: Icons.slideshow_outlined,
      color: Color(0xFFC9A227),
    ),
    _AnalyticsCardData(
      title: 'En Çok Kullanılan Şablon',
      icon: Icons.dashboard_customize_outlined,
      color: Color(0xFFD32F2F),
    ),
    _AnalyticsCardData(
      title: 'En Çok Kullanılan AI Modeli',
      icon: Icons.smart_toy_outlined,
      color: Color(0xFF00695C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Analytics'),
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
              return _AnalyticsCard(data: _cards[index]);
            },
          );
        },
      ),
    );
  }
}

class _AnalyticsCardData {
  const _AnalyticsCardData({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.data});

  final _AnalyticsCardData data;

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
