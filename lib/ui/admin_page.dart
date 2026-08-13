import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_rest_helper.dart';
import '../services/presentation_loader.dart';
import '../services/stats_aggregation_service.dart';
import 'design/design_system.dart';
import 'html_presentation_editor_page.dart';

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

class _AdminPresentationItem {
  const _AdminPresentationItem({
    required this.id,
    required this.topic,
    required this.userEmail,
    required this.createdAt,
    required this.slideCount,
    required this.wasEdited,
    required this.wasExported,
    required this.editCount,
    required this.timeSpentSeconds,
  });

  final String id;
  final String topic;
  final String userEmail;
  final DateTime? createdAt;
  final int slideCount;
  final bool wasEdited;
  final bool wasExported;
  final int editCount;
  final int timeSpentSeconds;
}

class _AdminPageState extends State<AdminPage> {
  bool? _isAdmin;
  bool _loading = true;
  String? _error;
  List<_AdminUserItem> _users = [];
  String _query = '';

  List<_AdminPresentationItem> _presentations = [];
  bool _loadingPresentations = false;
  String? _presentationsError;
  bool _statsBusy = false;

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
        _loadPresentations();
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
        ..sort(
            (a, b) => a.email.toLowerCase().compareTo(b.email.toLowerCase()));

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

  Future<void> _loadPresentations() async {
    setState(() {
      _loadingPresentations = true;
      _presentationsError = null;
    });

    try {
      // .where/.orderBy kullanılmaz (Int64 riski): tüm dokümanlar çekilir,
      // sıralama createdAt'e göre Dart tarafında yapılır.
      final docs = await FirestoreRestHelper.listDocuments('presentations');

      final items = docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final id = (doc['name'] as String? ?? '').split('/').last;
        return _AdminPresentationItem(
          id: id,
          topic: FirestoreRestHelper.stringField(fields, 'topic'),
          userEmail: FirestoreRestHelper.stringField(fields, 'userEmail'),
          createdAt: DateTime.tryParse(
            FirestoreRestHelper.timestampField(fields, 'createdAt'),
          ),
          slideCount: int.tryParse(
                FirestoreRestHelper.integerField(fields, 'slideCount'),
              ) ??
              0,
          wasEdited: fields['wasEdited']?['booleanValue'] as bool? ?? false,
          wasExported: fields['wasExported']?['booleanValue'] as bool? ?? false,
          editCount: int.tryParse(
                FirestoreRestHelper.integerField(fields, 'editCount'),
              ) ??
              0,
          timeSpentSeconds: int.tryParse(
                FirestoreRestHelper.integerField(fields, 'timeSpentSeconds'),
              ) ??
              0,
        );
      }).toList()
        ..sort((a, b) {
          final at = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bt = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bt.compareTo(at);
        });

      if (!mounted) return;
      setState(() {
        _presentations = items;
        _loadingPresentations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _presentationsError = 'Sunumlar yüklenemedi: $e';
        _loadingPresentations = false;
      });
    }
  }

  Future<void> _updateStats() async {
    setState(() => _statsBusy = true);
    try {
      final summary = await StatsAggregationService().aggregateRecent(days: 7);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Güncellendi: ${summary.presentationsScanned} sunum tarandı, '
            '${summary.slidesRecorded} slayt istatistiğe işlendi, '
            '${summary.slidesSkipped} slayt atlandı '
            '(${summary.skippedNotMature} sunum 24 saatten genç olduğu için atlandı).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İstatistikler güncellenemedi: $e')),
      );
    } finally {
      if (mounted) setState(() => _statsBusy = false);
    }
  }

  Future<void> _toggleStatus(_AdminUserItem user) async {
    final next = user.effectiveStatus == 'suspended' ? 'active' : 'suspended';
    try {
      await FirestoreRestHelper.patchDocument(
        'users/${user.id}',
        {
          'status': {'stringValue': next}
        },
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: const Text('Admin'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kullanıcılar'),
              Tab(text: 'Tüm Sunumlar'),
            ],
          ),
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isAdmin == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isAdmin != true) {
      final colors = context.colors;
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

    return TabBarView(
      children: [
        _buildUsersTab(context),
        _buildPresentationsTab(context),
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context) {
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
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
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

    final filtered =
        _users.where((u) => u.email.toLowerCase().contains(_query)).toList();

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

  Widget _buildPresentationsTab(BuildContext context) {
    return Column(
      children: [
        if (!_loadingPresentations && _presentationsError == null) ...[
          _buildSummaryCards(context),
          const SizedBox(height: AppSpacing.s8),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s32,
            AppSpacing.s16,
            AppSpacing.s32,
            AppSpacing.s8,
          ),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: _statsBusy ? null : _updateStats,
                icon: _statsBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(_statsBusy
                    ? 'Güncelleniyor...'
                    : 'İstatistikleri Güncelle'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Listeyi yenile',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadingPresentations ? null : _loadPresentations,
              ),
            ],
          ),
        ),
        Expanded(child: _buildPresentationList(context)),
      ],
    );
  }

  /// "Tüm Sunumlar" sekmesinin üstündeki özet istatistik kartları: toplam
  /// sunum/slayt, düzenlenen, dışa aktarılan, toplam düzenleme ve süre.
  Widget _buildSummaryCards(BuildContext context) {
    final colors = context.colors;
    final presentations = _presentations;
    final totalSlides =
        presentations.fold<int>(0, (sum, p) => sum + p.slideCount);
    final totalSeconds =
        presentations.fold<int>(0, (sum, p) => sum + p.timeSpentSeconds);
    final totalEdits =
        presentations.fold<int>(0, (sum, p) => sum + p.editCount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s32,
        AppSpacing.s16,
        AppSpacing.s32,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.s12,
        runSpacing: AppSpacing.s12,
        children: [
          _SummaryStatCard(
            icon: Icons.layers_rounded,
            iconColor: colors.primary,
            value: '${presentations.length}',
            label: 'Toplam Sunum',
          ),
          _SummaryStatCard(
            icon: Icons.view_carousel_rounded,
            iconColor: const Color(0xFF0891B2),
            value: '$totalSlides',
            label: 'Toplam Slayt',
          ),
          _SummaryStatCard(
            icon: Icons.edit_rounded,
            iconColor: colors.success,
            value: '${presentations.where((p) => p.wasEdited).length}',
            label: 'Düzenlenen',
          ),
          _SummaryStatCard(
            icon: Icons.download_rounded,
            iconColor: const Color(0xFFD97706),
            value: '${presentations.where((p) => p.wasExported).length}',
            label: 'Dışa Aktarılan',
          ),
          _SummaryStatCard(
            icon: Icons.touch_app_rounded,
            iconColor: const Color(0xFF7C3AED),
            value: '$totalEdits',
            label: 'Toplam Düzenleme',
          ),
          _SummaryStatCard(
            icon: Icons.timer_rounded,
            iconColor: const Color(0xFFDC2626),
            value: _formatDurationSeconds(totalSeconds),
            label: 'Toplam Süre',
          ),
        ],
      ),
    );
  }

  Widget _buildPresentationList(BuildContext context) {
    final colors = context.colors;

    if (_loadingPresentations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_presentationsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Text(
            _presentationsError!,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (_presentations.isEmpty) {
      return Center(
        child: Text(
          'Sunum bulunamadı.',
          style: AppTypography.bodyLarge.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s32),
      itemCount: _presentations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final presentation = _presentations[index];
        return _PresentationTile(
          presentation: presentation,
          onTap: () => _openInReadOnlyEditor(presentation.id),
        );
      },
    );
  }

  /// Sunumu salt okunur editörde (Görüntüleme Modu) açar. Geri dönüş oku bu
  /// sayfaya ("Tüm Sunumlar" listesi) döner.
  Future<void> _openInReadOnlyEditor(String presentationId) async {
    try {
      final result = await loadPresentationForEdit(presentationId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HtmlPresentationEditorPage(
            controller: result.controller,
            presentationId: presentationId,
            initialUpdatedByName: result.updatedByName,
            adminReadOnly: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sunum yüklenemedi: $e')),
      );
    }
  }
}

/// Özet istatistik kartı: ikon rozeti + değer ve etiket.
class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDurationSeconds(int seconds) {
  if (seconds < 60) return '${seconds}sn';
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '${minutes}dk';
  final hours = minutes ~/ 60;
  return '${hours}sa ${minutes % 60}dk';
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onToggle});

  final _AdminUserItem user;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final narrow = MediaQuery.sizeOf(context).width < 480;
    final isSuspended = user.effectiveStatus == 'suspended';
    final statusColor = isSuspended ? colors.danger : colors.success;

    final info = Column(
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
              label: Text(
                'Plan: ${user.tier == 'plus' || user.tier == 'premium' || user.tier == 'pro' ? 'Plus' : 'Ücretsiz'}',
              ),
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
    );

    final action = FilledButton.tonalIcon(
      onPressed: onToggle,
      icon: Icon(
        isSuspended ? Icons.play_circle_outline : Icons.pause_circle_outline,
        size: 18,
      ),
      label: Text(isSuspended ? 'Aktifleştir' : 'Askıya Al'),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  info,
                  const SizedBox(height: AppSpacing.s12),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              )
            : Row(
                children: [
                  Expanded(child: info),
                  const SizedBox(width: AppSpacing.s12),
                  action,
                ],
              ),
      ),
    );
  }
}

class _PresentationTile extends StatelessWidget {
  const _PresentationTile({
    required this.presentation,
    required this.onTap,
  });

  final _AdminPresentationItem presentation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final createdAt = presentation.createdAt;
    final editedColor =
        presentation.wasEdited ? colors.success : colors.textSecondary;
    final exportedColor =
        presentation.wasExported ? colors.success : colors.textSecondary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                presentation.topic.isNotEmpty
                    ? presentation.topic
                    : presentation.id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                [
                  presentation.userEmail.isNotEmpty
                      ? presentation.userEmail
                      : 'e-posta yok',
                  if (createdAt != null) _formatDate(createdAt),
                ].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  Chip(
                    label: Text('${presentation.slideCount} slayt'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(
                      'Düzenlendi: ${presentation.wasEdited ? 'Evet' : 'Hayır'}',
                      style: TextStyle(
                        color: editedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: editedColor.withValues(alpha: 0.5)),
                  ),
                  Chip(
                    label: Text(
                      'Dışa aktarıldı: ${presentation.wasExported ? 'Evet' : 'Hayır'}',
                      style: TextStyle(
                        color: exportedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    side:
                        BorderSide(color: exportedColor.withValues(alpha: 0.5)),
                  ),
                  Chip(
                    label: Text('Edit: ${presentation.editCount}'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(
                      'Süre: ${_formatDurationSeconds(presentation.timeSpentSeconds)}',
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}.${local.month}.${local.year} ${local.hour}:$minute';
  }
}
