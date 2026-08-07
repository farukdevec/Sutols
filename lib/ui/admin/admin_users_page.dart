import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../design/design_system.dart';
import 'admin_user_detail_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUser {
  const _AdminUser({
    required this.id,
    required this.photoUrl,
    required this.displayName,
    required this.email,
    required this.role,
    required this.tier,
    required this.status,
    required this.createdAt,
    required this.lastActiveAt,
  });

  final String id;
  final String photoUrl;
  final String displayName;
  final String email;
  final String role;
  final String tier;
  final String status;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  String get effectiveStatus => status.isEmpty ? 'active' : status;

  bool get isSuspended => effectiveStatus == 'suspended';
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final Future<List<_AdminUser>> _future;
  String _query = '';

  static const List<String> _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  @override
  void initState() {
    super.initState();
    _future = _fetchUsers();
  }

  Future<List<_AdminUser>> _fetchUsers() async {
    final docs = await FirestoreRestHelper.listDocuments('users');

    final users = docs.map((doc) {
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};
      return _AdminUser(
        id: (doc['name'] as String? ?? '').split('/').last,
        photoUrl: FirestoreRestHelper.stringField(fields, 'photoUrl'),
        displayName: FirestoreRestHelper.stringField(fields, 'displayName'),
        email: FirestoreRestHelper.stringField(fields, 'email'),
        role: FirestoreRestHelper.stringField(fields, 'role'),
        tier: FirestoreRestHelper.stringField(fields, 'tier'),
        status: FirestoreRestHelper.stringField(fields, 'status'),
        createdAt: _parseDate(FirestoreRestHelper.timestampField(fields, 'createdAt')),
        lastActiveAt:
            _parseDate(FirestoreRestHelper.timestampField(fields, 'lastActiveAt')),
      );
    }).toList();

    users.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return users;
  }

  static DateTime? _parseDate(String iso) {
    final date = DateTime.tryParse(iso);
    return date?.toLocal();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${_months[local.month - 1]} ${local.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s32,
              AppSpacing.s24,
              AppSpacing.s32,
              AppSpacing.s8,
            ),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Kullanıcı ara (ad veya e-posta)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Temizle',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _query = ''),
                      ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<_AdminUser>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s32),
                      child: Text(
                        'Kullanıcılar yüklenemedi: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                final users = snapshot.data ?? [];
                final filtered = users.where((u) {
                  if (_query.isEmpty) return true;
                  return u.displayName.toLowerCase().contains(_query) ||
                      u.email.toLowerCase().contains(_query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Kullanıcı bulunamadı.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.s32),
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                      colors.surfaceElevated,
                    ),
                    dataRowColor: WidgetStatePropertyAll(colors.surface),
                    columns: const [
                      DataColumn(label: Text('Profil')),
                      DataColumn(label: Text('Ad')),
                      DataColumn(label: Text('E-posta')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Plan')),
                      DataColumn(label: Text('Durum')),
                      DataColumn(label: Text('Kayıt Tarihi')),
                      DataColumn(label: Text('Son Giriş')),
                    ],
                    rows: filtered.map((user) {
                      return DataRow(
                        onSelectChanged: (_) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  AdminUserDetailPage(userId: user.id),
                            ),
                          );
                        },
                        cells: [
                          DataCell(_Avatar(user: user)),
                          DataCell(
                            Text(
                              user.displayName.isNotEmpty ? user.displayName : '-',
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              user.email.isNotEmpty ? user.email : '-',
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            _RoleBadge(role: user.role),
                          ),
                          DataCell(
                            _TierBadge(tier: user.tier),
                          ),
                          DataCell(
                            _StatusBadge(isSuspended: user.isSuspended),
                          ),
                          DataCell(
                            Text(
                              _formatDate(user.createdAt),
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatDate(user.lastActiveAt),
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final _AdminUser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (user.photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Image.network(
          user.photoUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialAvatar(user: user, colors: colors),
        ),
      );
    }

    return _InitialAvatar(user: user, colors: colors);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.user, required this.colors});

  final _AdminUser user;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final initial = (user.displayName.isNotEmpty ? user.displayName : user.email)
        .substring(0, 1)
        .toUpperCase();

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.12),
      ),
      child: Text(
        initial,
        style: AppTypography.labelMedium.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final String tier;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final normalized = tier.toLowerCase();
    final color = switch (normalized) {
      'premium' => colors.primary,
      'plus' => const Color(0xFF8E44AD),
      _ => colors.textSecondary,
    };
    final label = switch (normalized) {
      'premium' => 'Premium',
      'plus' => 'Plus',
      _ => 'Ücretsiz',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isSuspended});

  final bool isSuspended;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isSuspended ? colors.danger : colors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isSuspended ? 'Askıda' : 'Aktif',
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final normalized = role.toLowerCase();
    final isAdmin = normalized == 'admin';
    final color = isAdmin ? colors.success : colors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        role.isNotEmpty ? role : '-',
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
