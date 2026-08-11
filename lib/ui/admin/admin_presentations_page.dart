import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../../services/presentation_loader.dart';
import '../design/design_system.dart';
import '../html_presentation_editor_page.dart';

/// Admin panelindeki "Sunumlar" bölümü: tüm kullanıcıların sunumlarını
/// listeler. Bir sunuma tıklanınca salt okunur editörde (Görüntüleme Modu)
/// açılır; geri dönüş oku bu listeye döner.
class AdminPresentationsPage extends StatefulWidget {
  const AdminPresentationsPage({super.key});

  @override
  State<AdminPresentationsPage> createState() => _AdminPresentationsPageState();
}

class _AdminPresentation {
  const _AdminPresentation({
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

class _AdminPresentationsPageState extends State<AdminPresentationsPage> {
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

  late final Future<List<_AdminPresentation>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _fetchPresentations();
  }

  Future<List<_AdminPresentation>> _fetchPresentations() async {
    // .where/.orderBy kullanılmaz (Int64 riski): tüm dokümanlar çekilir,
    // sıralama createdAt'e göre Dart tarafında yapılır.
    final docs = await FirestoreRestHelper.listDocuments('presentations');

    final items = docs.map((doc) {
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};
      return _AdminPresentation(
        id: (doc['name'] as String? ?? '').split('/').last,
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

    return items;
  }

  /// Sunumu salt okunur editörde (Görüntüleme Modu) açar.
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
        title: const Text('Sunumlar'),
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
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Sunum ara (konu veya e-posta)...',
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
            child: FutureBuilder<List<_AdminPresentation>>(
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
                        'Sunumlar yüklenemedi: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                final presentations = snapshot.data ?? [];
                final filtered = presentations.where((p) {
                  if (_query.isEmpty) return true;
                  return p.topic.toLowerCase().contains(_query) ||
                      p.userEmail.toLowerCase().contains(_query);
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryCards(context, presentations),
                    const SizedBox(height: AppSpacing.s16),
                    Expanded(child: _buildList(context, filtered)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    List<_AdminPresentation> presentations,
  ) {
    final colors = context.colors;
    final totalSlides =
        presentations.fold<int>(0, (sum, p) => sum + p.slideCount);
    final totalSeconds =
        presentations.fold<int>(0, (sum, p) => sum + p.timeSpentSeconds);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
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
            icon: Icons.timer_rounded,
            iconColor: const Color(0xFFDC2626),
            value: _formatDurationSeconds(totalSeconds),
            label: 'Toplam Süre',
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<_AdminPresentation> filtered) {
    final colors = context.colors;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'Sunum bulunamadı.' : 'Bu filtreyle sunum bulunamadı.',
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
        final presentation = filtered[index];
        return _PresentationTile(
          presentation: presentation,
          onTap: () => _openInReadOnlyEditor(presentation.id),
          onFormatDate: _formatDate,
        );
      },
    );
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

class _PresentationTile extends StatelessWidget {
  const _PresentationTile({
    required this.presentation,
    required this.onTap,
    required this.onFormatDate,
  });

  final _AdminPresentation presentation;
  final VoidCallback onTap;
  final String Function(DateTime?) onFormatDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final editedColor =
        presentation.wasEdited ? colors.success : colors.textSecondary;
    final exportedColor =
        presentation.wasExported ? colors.success : colors.textSecondary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      presentation.topic.isNotEmpty
                          ? presentation.topic
                          : presentation.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  const Icon(Icons.visibility_outlined, size: 20),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                [
                  presentation.userEmail.isNotEmpty
                      ? presentation.userEmail
                      : 'e-posta yok',
                  if (presentation.createdAt != null)
                    onFormatDate(presentation.createdAt),
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
                  _InfoChip(label: '${presentation.slideCount} slayt'),
                  _InfoChip(
                    label: 'Düzenlendi: ${presentation.wasEdited ? 'Evet' : 'Hayır'}',
                    color: editedColor,
                  ),
                  _InfoChip(
                    label:
                        'Dışa aktarıldı: ${presentation.wasExported ? 'Evet' : 'Hayır'}',
                    color: exportedColor,
                  ),
                  _InfoChip(label: 'Edit: ${presentation.editCount}'),
                  _InfoChip(
                    label:
                        'Süre: ${_formatDurationSeconds(presentation.timeSpentSeconds)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = color ?? colors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
