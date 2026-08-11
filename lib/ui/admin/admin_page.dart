import 'package:flutter/material.dart';

import '../design/design_system.dart';
import 'admin_ai_usage_page.dart';
import 'admin_analytics_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_expenses_page.dart';
import 'admin_payments_page.dart';
import 'admin_presentations_page.dart';
import 'admin_promo_codes_page.dart';
import 'admin_users_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  static const List<_AdminMenuItem> _items = [
    _AdminMenuItem(title: 'Dashboard', icon: Icons.dashboard_outlined),
    _AdminMenuItem(title: 'Users', icon: Icons.people_outlined),
    _AdminMenuItem(title: 'Payments', icon: Icons.payments_outlined),
    _AdminMenuItem(title: 'Expenses', icon: Icons.receipt_long_outlined),
    _AdminMenuItem(title: 'AI Usage', icon: Icons.smart_toy_outlined),
    _AdminMenuItem(title: 'Analytics', icon: Icons.insights_outlined),
    _AdminMenuItem(title: 'Sunumlar', icon: Icons.slideshow_outlined),
    _AdminMenuItem(title: 'Promosyon Kodları', icon: Icons.confirmation_number_outlined),
    _AdminMenuItem(title: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.s32),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: AppSpacing.s16,
          crossAxisSpacing: AppSpacing.s16,
          childAspectRatio: 1.4,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _AdminCard(
            item: item,
            onTap: () {
              final Widget page = switch (item.title) {
                'Dashboard' => const AdminDashboardPage(),
                'Users' => const AdminUsersPage(),
                'Payments' => const AdminPaymentsPage(),
                'Expenses' => const AdminExpensesPage(),
                'AI Usage' => const AdminAiUsagePage(),
                'Analytics' => const AdminAnalyticsPage(),
                'Sunumlar' => const AdminPresentationsPage(),
                'Promosyon Kodları' => const AdminPromoCodesPage(),
                _ => _EmptySectionPage(title: item.title),
              };
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => page),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminMenuItem {
  const _AdminMenuItem({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.item, required this.onTap});

  final _AdminMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 32, color: colors.primary),
              const SizedBox(height: AppSpacing.s12),
              Text(
                item.title,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySectionPage extends StatelessWidget {
  const _EmptySectionPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text(title)),
      body: const SizedBox.shrink(),
    );
  }
}
