import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../design/design_system.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _DashboardData {
  const _DashboardData({
    required this.totalUsers,
    required this.todayUsers,
    required this.totalPresentations,
    required this.todayPresentations,
    required this.activeSubscriptions,
  });

  final int totalUsers;
  final int todayUsers;
  final int totalPresentations;
  final int todayPresentations;
  final int activeSubscriptions;
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  _DashboardData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final isToday = (String iso) {
        final date = DateTime.tryParse(iso);
        if (date == null) return false;
        final local = date.toLocal();
        return local.year == now.year &&
            local.month == now.month &&
            local.day == now.day;
      };

      final userDocs = await FirestoreRestHelper.listDocuments('users');
      var totalUsers = 0;
      var todayUsers = 0;
      var activeSubscriptions = 0;
      var presentationCountSum = 0;

      for (final doc in userDocs) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        totalUsers += 1;
        final lastActiveAt =
            FirestoreRestHelper.timestampField(fields, 'lastActiveAt');
        if (lastActiveAt.isNotEmpty && isToday(lastActiveAt)) {
          todayUsers += 1;
        }
        final tier = FirestoreRestHelper.stringField(fields, 'tier');
        if (tier.isNotEmpty && tier != 'free') {
          activeSubscriptions += 1;
        }
        presentationCountSum +=
            int.tryParse(
                  FirestoreRestHelper.integerField(fields, 'presentationCount'),
                ) ??
                0;
      }

      // Sunumlar listelenebiliyorsa gerçek toplam/bugünkü sayılar,
      // listelenemezse kullanıcıların presentationCount toplamına düş.
      var totalPresentations = 0;
      var todayPresentations = 0;
      var hasPresentationList = false;
      try {
        final presentationDocs =
            await FirestoreRestHelper.listDocuments('presentations');
        hasPresentationList = true;
        for (final doc in presentationDocs) {
          final fields = doc['fields'] as Map<String, dynamic>? ?? {};
          totalPresentations += 1;
          final createdAt =
              FirestoreRestHelper.timestampField(fields, 'createdAt');
          if (createdAt.isNotEmpty && isToday(createdAt)) {
            todayPresentations += 1;
          }
        }
      } catch (_) {
        totalPresentations = presentationCountSum;
      }

      setState(() {
        _data = _DashboardData(
          totalUsers: totalUsers,
          todayUsers: todayUsers,
          totalPresentations: totalPresentations,
          todayPresentations: hasPresentationList ? todayPresentations : 0,
          activeSubscriptions: activeSubscriptions,
        );
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Veriler yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        OutlinedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1200
                          ? 4
                          : (constraints.maxWidth >= 700
                              ? 3
                              : (constraints.maxWidth >= 480 ? 2 : 1));

                      final values = <String, String>{
                        'totalUsers': '${_data!.totalUsers}',
                        'todayUsers': '${_data!.todayUsers}',
                        'totalPresentations': '${_data!.totalPresentations}',
                        'todayPresentations': '${_data!.todayPresentations}',
                        'activeSubscriptions': '${_data!.activeSubscriptions}',
                        'monthlyRevenue': '—',
                        'aiExpense': '—',
                        'netProfit': '—',
                      };

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.s32),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: AppSpacing.s16,
                          crossAxisSpacing: AppSpacing.s16,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          return _StatCard(
                            data: _cards[index],
                            value: values[_cards[index].key] ?? '—',
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }

  static const List<_StatCardData> _cards = [
    _StatCardData(
      key: 'totalUsers',
      title: 'Toplam Kullanıcı',
      icon: Icons.people_outlined,
      color: Color(0xFF1565C0),
    ),
    _StatCardData(
      key: 'todayUsers',
      title: 'Bugünkü Kullanıcı',
      icon: Icons.person_add_alt_1_outlined,
      color: Color(0xFF2E7D32),
    ),
    _StatCardData(
      key: 'totalPresentations',
      title: 'Toplam Sunum',
      icon: Icons.slideshow_outlined,
      color: Color(0xFF6A1B9A),
    ),
    _StatCardData(
      key: 'todayPresentations',
      title: 'Bugünkü Sunum',
      icon: Icons.today_outlined,
      color: Color(0xFFEF6C00),
    ),
    _StatCardData(
      key: 'activeSubscriptions',
      title: 'Aktif Abonelik',
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFFC9A227),
    ),
    _StatCardData(
      key: 'monthlyRevenue',
      title: 'Aylık Gelir',
      icon: Icons.payments_outlined,
      color: Color(0xFF2E7D32),
    ),
    _StatCardData(
      key: 'aiExpense',
      title: 'AI Gideri',
      icon: Icons.smart_toy_outlined,
      color: Color(0xFFD32F2F),
    ),
    _StatCardData(
      key: 'netProfit',
      title: 'Net Kar',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF00695C),
    ),
  ];
}

class _StatCardData {
  const _StatCardData({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String key;
  final String title;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data, required this.value});

  final _StatCardData data;
  final String value;

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
              value,
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
