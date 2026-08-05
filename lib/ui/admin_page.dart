import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_rest_helper.dart';
import 'design/design_system.dart';

/// Sadece "admins" koleksiyonunda kendi UID'si bulunan kullanıcıların
/// görebildiği yönetim sayfası. Sayfa açılışında yetki kontrolü yapılır.
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminUserItem {
  const _AdminUserItem({
    required this.id,
    required this.email,
    required this.tier,
    required this.presentationCount,
    required this.status,
  });

  final String id;
  final String email;
  final String tier;
  final int presentationCount;
  final String status;

  String get effectiveStatus => status.isEmpty ? 'active' : status;

  _AdminUserItem copyWith({String? status}) {
    return _AdminUserItem(
      id: id,
      email: email,
      tier: tier,
      presentationCount: presentationCount,
      status: status ?? this.status,
    );
  }
}

class _AdminPageState extends State<AdminPage> {
  bool? _isAdmin;
  bool _loading = true;
  String? _error;
  List<_AdminUserItem> _users = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isAdmin = false);
      return;
    }

    try {
      final doc = await FirestoreRestHelper.getDocument('admins/$uid');
      final allowed = doc != null;
      if (!mounted) return;
      setState(() => _isAdmin = allowed);
      if (allowed) {
        _loadUsers();
      }
    } catch (_) {
      // Best-effort: kontrol hatası yetkisiz say.
      if (!mounted) return;
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // orderBy kullanılmaz (Int64 dartify hatası riski): tüm dokümanlar
      // çekilir, sıralama/filtreleme Dart tarafında yapılır.
      final docs = await FirestoreRestHelper.listDocuments('users');

      final users = docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final id = (doc['name'] as String? ?? '').split('/').last;
        return _AdminUserItem(
          id: id,
          email: FirestoreRestHelper.stringField(fields, 'email'),
          tier: FirestoreRestHelper.stringField(fields, 'tier'),
          presentationCount: int.tryParse(
                FirestoreRestHelper.integerField(fields, 'presentationCount'),
              ) ??
              0,
          status: FirestoreRestHelper.stringField(fields, 'status'),
        );
      }).toList()
        ..sort((a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()));

      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Kullanıcılar yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  Future<void> _toggleStatus(_AdminUserItem user) async {
    final next = user.effectiveStatus == 'suspended' ? 'active' : 'suspended';
    try {
      await FirestoreRestHelper.patchDocument(
        'users/${user.id}',
        {'status': {'stringValue': next}},
        updateMask: const ['status'],
      );
      if (!mounted) return;
      setState(() {
        _users = [
          for (final u in _users)
            if (u.id == user.id) u.copyWith(status: next) else u,
        ];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Durum güncellenemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;

    if (_isAdmin == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isAdmin != true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
              color: colors.danger,
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Yetkiniz yok',
              style: AppTypography.titleLarge.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
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
              hintText: 'E-posta ile ara...',
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
        Expanded(child: _buildUserList(context)),
      ],
    );
  }

  Widget _buildUserList(BuildContext context) {
    final colors = context.colors;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    final filtered = _users
        .where((u) => u.email.toLowerCase().contains(_query))
        .toList();

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

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s32),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final user = filtered[index];
        return _UserTile(user: user, onToggle: () => _toggleStatus(user));
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onToggle});

  final _AdminUserItem user;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSuspended = user.effectiveStatus == 'suspended';
    final statusColor = isSuspended ? colors.danger : colors.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.email.isNotEmpty ? user.email : user.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      Chip(
                        label: Text('Tier: ${user.tier.isEmpty ? 'free' : user.tier}'),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text('${user.presentationCount} sunum'),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(
                          isSuspended ? 'Askıda' : 'Aktif',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: statusColor.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            FilledButton.tonalIcon(
              onPressed: onToggle,
              icon: Icon(
                isSuspended ? Icons.play_circle_outline : Icons.pause_circle_outline,
                size: 18,
              ),
              label: Text(isSuspended ? 'Aktifleştir' : 'Askıya Al'),
            ),
          ],
        ),
      ),
    );
  }
}
