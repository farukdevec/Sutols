import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../design/design_system.dart';

class AdminGlbDownloadsPage extends StatefulWidget {
  const AdminGlbDownloadsPage({super.key});

  @override
  State<AdminGlbDownloadsPage> createState() => _AdminGlbDownloadsPageState();
}

class _GlbDownloadLog {
  const _GlbDownloadLog({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.displayName,
    required this.modelKey,
    required this.downloadedAt,
    required this.source,
  });

  final String id;
  final String userId;
  final String userEmail;
  final String displayName;
  final String modelKey;
  final DateTime? downloadedAt;
  final String source;
}

class _UserGlbStat {
  _UserGlbStat({
    required this.userId,
    required this.userEmail,
    required this.displayName,
  });

  final String userId;
  String userEmail;
  String displayName;
  int downloadCount = 0;
  DateTime? lastDownloadedAt;
  final List<_GlbDownloadLog> logs = [];
}

class _AdminGlbDownloadsPageState extends State<AdminGlbDownloadsPage> {
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

  List<_GlbDownloadLog> _allLogs = [];
  List<_UserGlbStat> _userStats = [];
  final Map<String, String> _userEmailMap = {};
  final Map<String, String> _userNameMap = {};

  static const List<String> _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Fetch user directory for email & display name resolution
      try {
        final userDocs = await FirestoreRestHelper.listDocuments('users');
        for (final doc in userDocs) {
          final uid = (doc['name'] as String? ?? '').split('/').last;
          final fields = doc['fields'] as Map<String, dynamic>? ?? {};
          final email = FirestoreRestHelper.stringField(fields, 'email');
          final name = FirestoreRestHelper.stringField(fields, 'displayName');
          if (uid.isNotEmpty) {
            _userEmailMap[uid] = email;
            _userNameMap[uid] = name.isNotEmpty ? name : (email.isNotEmpty ? email.split('@').first : uid);
          }
        }
      } catch (_) {}

      // 2. Fetch GLB download logs
      final docs = await FirestoreRestHelper.listDocuments('glb_downloads');
      final logs = <_GlbDownloadLog>[];

      for (final doc in docs) {
        final docId = (doc['name'] as String? ?? '').split('/').last;
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};

        final uid = FirestoreRestHelper.stringField(fields, 'userId');
        var email = FirestoreRestHelper.stringField(fields, 'userEmail');
        var name = FirestoreRestHelper.stringField(fields, 'displayName');

        if (email.isEmpty && _userEmailMap.containsKey(uid)) {
          email = _userEmailMap[uid]!;
        }
        if (name.isEmpty && _userNameMap.containsKey(uid)) {
          name = _userNameMap[uid]!;
        }

        final modelKey = FirestoreRestHelper.stringField(fields, 'modelKey');
        final rawDate = FirestoreRestHelper.timestampField(fields, 'downloadedAt');
        final date = DateTime.tryParse(rawDate)?.toLocal();
        final source = FirestoreRestHelper.stringField(fields, 'source');

        logs.add(_GlbDownloadLog(
          id: docId,
          userId: uid,
          userEmail: email,
          displayName: name,
          modelKey: modelKey,
          downloadedAt: date,
          source: source.isNotEmpty ? source : 'link',
        ));
      }

      logs.sort((a, b) {
        final aTime = a.downloadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.downloadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      // 3. Aggregate per user
      final statMap = <String, _UserGlbStat>{};
      for (final log in logs) {
        final uid = log.userId.isNotEmpty ? log.userId : 'anonymous';
        final stat = statMap.putIfAbsent(
          uid,
          () => _UserGlbStat(
            userId: uid,
            userEmail: log.userEmail,
            displayName: log.displayName.isNotEmpty ? log.displayName : (log.userEmail.isNotEmpty ? log.userEmail : uid),
          ),
        );

        if (stat.userEmail.isEmpty && log.userEmail.isNotEmpty) {
          stat.userEmail = log.userEmail;
        }
        if ((stat.displayName.isEmpty || stat.displayName == uid) && log.displayName.isNotEmpty) {
          stat.displayName = log.displayName;
        }

        stat.downloadCount++;
        stat.logs.add(log);

        if (stat.lastDownloadedAt == null || (log.downloadedAt != null && log.downloadedAt!.isAfter(stat.lastDownloadedAt!))) {
          stat.lastDownloadedAt = log.downloadedAt;
        }
      }

      final statList = statMap.values.toList()
        ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));

      setState(() {
        _allLogs = logs;
        _userStats = statList;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'GLB indirme verileri yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${_months[local.month - 1]} ${local.year} $hh:$mm';
  }

  List<_UserGlbStat> get _filteredUserStats {
    if (_searchQuery.trim().isEmpty) return _userStats;
    final q = _searchQuery.trim().toLowerCase();
    return _userStats.where((s) {
      final name = s.displayName.toLowerCase();
      final email = s.userEmail.toLowerCase();
      final uid = s.userId.toLowerCase();
      final hasMatchingModel = s.logs.any((l) => l.modelKey.toLowerCase().contains(q));
      return name.contains(q) || email.contains(q) || uid.contains(q) || hasMatchingModel;
    }).toList();
  }

  int get _totalDownloads => _allLogs.length;
  int get _uniqueUsersCount => _userStats.length;
  int get _uniqueModelsCount => _allLogs.map((l) => l.modelKey).toSet().length;

  void _showUserLogsModal(_UserGlbStat stat) {
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colors.primary.withValues(alpha: 0.15),
                        child: Text(
                          stat.displayName.isNotEmpty ? stat.displayName[0].toUpperCase() : 'U',
                          style: AppTypography.titleMedium.copyWith(color: colors.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat.displayName,
                              style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                            ),
                            if (stat.userEmail.isNotEmpty)
                              Text(
                                stat.userEmail,
                                style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${stat.downloadCount} İndirme',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    itemCount: stat.logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = stat.logs[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.view_in_ar_rounded, color: Colors.blue, size: 22),
                        ),
                        title: Text(
                          log.modelKey.isNotEmpty ? log.modelKey : 'Bilinmeyen GLB Modeli',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Tarih: ${_formatDate(log.downloadedAt)} • Kaynak: ${log.source}',
                          style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
                        ),
                        trailing: const Icon(Icons.download_done_rounded, color: Colors.green, size: 20),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filteredStats = _filteredUserStats;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('GLB İndirmeleri & Kullanıcı Sayacı'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _loadData,
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
                          style: AppTypography.bodyLarge.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        OutlinedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.s24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 900 ? 3 : 1;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: columns,
                            mainAxisSpacing: AppSpacing.s16,
                            crossAxisSpacing: AppSpacing.s16,
                            childAspectRatio: 2.5,
                            children: [
                              _StatCard(
                                title: 'Toplam GLB İndirme',
                                value: '$_totalDownloads',
                                icon: Icons.download_rounded,
                                color: const Color(0xFF1565C0),
                              ),
                              _StatCard(
                                title: 'İndiren Kullanıcılar',
                                value: '$_uniqueUsersCount',
                                icon: Icons.group_outlined,
                                color: const Color(0xFF2E7D32),
                              ),
                              _StatCard(
                                title: 'İndirilen GLB Çeşidi',
                                value: '$_uniqueModelsCount',
                                icon: Icons.view_in_ar_rounded,
                                color: const Color(0xFF6A1B9A),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Search & Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Kullanıcı adı, e-posta veya GLB dosya adı ara...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: colors.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s16),

                    // User Download Counter List
                    Expanded(
                      child: filteredStats.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'Henüz GLB model indirme kaydı yok.'
                                    : 'Aramanızla eşleşen kullanıcı bulunamadı.',
                                style: AppTypography.bodyLarge.copyWith(color: colors.textSecondary),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s8),
                              itemCount: filteredStats.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
                              itemBuilder: (context, index) {
                                final stat = filteredStats[index];
                                return Card(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s16,
                                      vertical: AppSpacing.s8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: colors.primary.withValues(alpha: 0.12),
                                      child: Text(
                                        stat.displayName.isNotEmpty
                                            ? stat.displayName[0].toUpperCase()
                                            : 'U',
                                        style: AppTypography.titleMedium.copyWith(color: colors.primary),
                                      ),
                                    ),
                                    title: Text(
                                      stat.displayName,
                                      style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
                                    ),
                                    subtitle: Text(
                                      'E-posta: ${stat.userEmail.isNotEmpty ? stat.userEmail : stat.userId}\nSon İndirme: ${_formatDate(stat.lastDownloadedAt)}',
                                      style: AppTypography.labelMedium.copyWith(color: colors.textSecondary),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.s12,
                                            vertical: AppSpacing.s4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(AppRadius.full),
                                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                                          ),

                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.download_rounded, size: 16, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${stat.downloadCount} İndirme',
                                                style: AppTypography.bodyMedium.copyWith(
                                                  color: Colors.green.shade800,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.s8),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right_rounded),
                                          tooltip: 'İndirme Detayları',
                                          onPressed: () => _showUserLogsModal(stat),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showUserLogsModal(stat),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: AppSpacing.s16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
