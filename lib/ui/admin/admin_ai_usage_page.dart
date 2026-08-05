import 'package:flutter/material.dart';

import '../design/design_system.dart';

class AdminAiUsagePage extends StatelessWidget {
  const AdminAiUsagePage({super.key});

  static const List<_UsageCardData> _cards = [
    _UsageCardData(
      title: 'Toplam Token',
      icon: Icons.token_outlined,
      color: Color(0xFF6A1B9A),
    ),
    _UsageCardData(
      title: 'Input Token',
      icon: Icons.input_rounded,
      color: Color(0xFF1565C0),
    ),
    _UsageCardData(
      title: 'Output Token',
      icon: Icons.output_rounded,
      color: Color(0xFFEF6C00),
    ),
    _UsageCardData(
      title: 'Toplam İstek',
      icon: Icons.api_outlined,
      color: Color(0xFF2E7D32),
    ),
    _UsageCardData(
      title: 'Bugünkü İstek',
      icon: Icons.today_outlined,
      color: Color(0xFF00838F),
    ),
    _UsageCardData(
      title: 'Tahmini Maliyet',
      icon: Icons.payments_outlined,
      color: Color(0xFFC9A227),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('AI Usage'),
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
                  return _UsageCard(data: _cards[index]);
                },
              ),
              const SizedBox(height: AppSpacing.s32),
              Text(
                'En Çok Kullanan Kullanıcılar',
                style: AppTypography.titleLarge.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  child: Column(
                    children: [
                      DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          colors.surfaceElevated,
                        ),
                        dataRowColor: WidgetStatePropertyAll(colors.surface),
                        columns: const [
                          DataColumn(label: Text('Kullanıcı')),
                          DataColumn(label: Text('Toplam Token')),
                          DataColumn(label: Text('İstek Sayısı')),
                        ],
                        rows: const [],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.s24),
                        child: Text(
                          'Henüz veri yok',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UsageCardData {
  const _UsageCardData({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.data});

  final _UsageCardData data;

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
