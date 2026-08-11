import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../../services/presentation_loader.dart';
import '../design/design_system.dart';
import '../html_presentation_editor_page.dart';
import '../presentation_view_page.dart';

class AdminUserDetailPage extends StatefulWidget {
  const AdminUserDetailPage({super.key, required this.userId});

  final String userId;

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _UsageEntry {
  const _UsageEntry({required this.date, required this.count});

  final String date;
  final int count;
}

class _PresentationEntry {
  const _PresentationEntry({
    required this.id,
    required this.topic,
    required this.slideCount,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final int slideCount;
  final String createdAt;
}

class _UserDetailData {
  const _UserDetailData({
    required this.fields,
    required this.usage,
    required this.presentations,
  });

  final Map<String, dynamic> fields;
  final List<_UsageEntry> usage;
  final List<_PresentationEntry> presentations;
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
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

  static const List<(String, String)> _tierOptions = [
    ('free', 'Ücretsiz (günde 3 sunum)'),
    ('plus', 'Plus (günde 15 sunum)'),
    ('premium', 'Premium (sınırsız)'),
  ];

  _UserDetailData? _data;
  bool _loading = true;
  String? _error;
  bool _saving = false;

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
      final doc = await FirestoreRestHelper.getDocument('users/${widget.userId}');
      if (doc == null) {
        setState(() {
          _loading = false;
          _error = 'Kullanıcı dokümanı bulunamadı.';
        });
        return;
      }
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};

      List<_UsageEntry> usage = [];
      try {
        final usageDocs =
            await FirestoreRestHelper.listDocuments('users/${widget.userId}/usage');
        usage = usageDocs.map((u) {
          final uf = u['fields'] as Map<String, dynamic>? ?? {};
          return _UsageEntry(
            date: FirestoreRestHelper.stringField(uf, 'date'),
            count: int.tryParse(FirestoreRestHelper.integerField(uf, 'count')) ?? 0,
          );
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } catch (_) {
        // Kullanım geçmişi okunamazsa boş bırak.
      }

      List<_PresentationEntry> presentations = [];
      try {
        final presentationDocs = await FirestoreRestHelper.runQuery({
          'from': [
            {'collectionId': 'presentations'},
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': 'userId'},
              'op': 'EQUAL',
              'value': {'stringValue': widget.userId},
            },
          },
        });
        presentations = presentationDocs.map((p) {
          final pf = p['fields'] as Map<String, dynamic>? ?? {};
          return _PresentationEntry(
            id: (p['name'] as String? ?? '').split('/').last,
            topic: FirestoreRestHelper.stringField(pf, 'topic'),
            slideCount:
                int.tryParse(FirestoreRestHelper.integerField(pf, 'slideCount')) ?? 0,
            createdAt: FirestoreRestHelper.timestampField(pf, 'createdAt'),
          );
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (_) {
        // Sunumlar okunamazsa boş bırak.
      }

      setState(() {
        _data = _UserDetailData(fields: fields, usage: usage, presentations: presentations);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Yükleme hatası: $e';
      });
    }
  }

  String _stringField(String key) =>
      FirestoreRestHelper.stringField(_data?.fields ?? const {}, key);

  int _intField(String key) =>
      int.tryParse(FirestoreRestHelper.integerField(_data?.fields ?? const {}, key)) ?? 0;

  String _timestampField(String key) =>
      FirestoreRestHelper.timestampField(_data?.fields ?? const {}, key);

  String get _tier {
    final tier = _stringField('tier');
    return tier.isEmpty ? 'free' : tier;
  }

  String get _status {
    final status = _stringField('status');
    return status.isEmpty ? 'active' : status;
  }

  bool get _isSuspended => _status == 'suspended';

  String get _role {
    final role = _stringField('role');
    return role.isEmpty ? 'user' : role;
  }

  String get _tierLabel {
    for (final (value, label) in _tierOptions) {
      if (value == _tier) return label;
    }
    return _tier;
  }

  Future<void> _patch(Map<String, dynamic> fields, List<String> mask) async {
    setState(() => _saving = true);
    try {
      await FirestoreRestHelper.patchDocument(
        'users/${widget.userId}',
        fields,
        updateMask: mask,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme başarısız: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeTier(String tier) async {
    if (tier == _tier) return;
    final confirmed = await _confirm(
      'Plan değiştiriliyor',
      '${_tierLabel} planından '
      '"${_tierOptions.firstWhere((o) => o.$1 == tier).$2}" planına geçirilsin mi?',
      confirmLabel: 'Değiştir',
    );
    if (confirmed != true) return;
    await _patch(
      {'tier': {'stringValue': tier}},
      const ['tier'],
    );
  }

  Future<void> _toggleSuspend() async {
    final next = _isSuspended ? 'active' : 'suspended';
    final confirmed = await _confirm(
      _isSuspended ? 'Hesabı aktifleştir' : 'Hesabı askıya al',
      _isSuspended
          ? 'Bu kullanıcı yeniden giriş yapabilir ve uygulamayı kullanabilir.'
          : 'Askıya alınan kullanıcı bir sonraki girişinde uygulamaya erişemez. Devam edilsin mi?',
      confirmLabel: _isSuspended ? 'Aktifleştir' : 'Askıya Al',
      destructive: !_isSuspended,
    );
    if (confirmed != true) return;
    await _patch(
      {'status': {'stringValue': next}},
      const ['status'],
    );
  }

  Future<void> _editField(String key, String label, {bool numeric = false}) async {
    final controller = TextEditingController(
      text: numeric
          ? _intField(key).toString()
          : _stringField(key),
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label Düzenle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(hintText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (value == null || value.isEmpty) return;
    if (numeric) {
      final count = int.tryParse(value);
      if (count == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geçerli bir sayı girin.')),
        );
        return;
      }
      await _patch(
        {'presentationCount': {'integerValue': '$count'}},
        const ['presentationCount'],
      );
    } else {
      await _patch(
        {'displayName': {'stringValue': value}},
        const ['displayName'],
      );
    }
  }

  Future<void> _toggleRole() async {
    final next = _role == 'admin' ? 'user' : 'admin';
    final confirmed = await _confirm(
      'Rol değiştiriliyor',
      next == 'admin'
          ? 'Bu kullanıcıya yönetici yetkisi verilecek. Devam edilsin mi?'
          : 'Yönetici yetkisi kaldırılacak. Devam edilsin mi?',
      confirmLabel: 'Değiştir',
    );
    if (confirmed != true) return;
    await _patch(
      {'role': {'stringValue': next}},
      const ['role'],
    );
  }

  Future<bool?> _confirm(
    String title,
    String message, {
    required String confirmLabel,
    bool destructive = false,
  }) {
    final colors = context.colors;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? colors.danger : null,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _openInEditor(String presentationId) async {
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

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
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
        title: const Text('Kullanıcı Detayı'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _data == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error ?? 'Veri bulunamadı.',
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
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileCard(context),
          const SizedBox(height: AppSpacing.s16),
          _buildPlanCard(context),
          const SizedBox(height: AppSpacing.s16),
          _buildActionsCard(context),
          const SizedBox(height: AppSpacing.s16),
          _buildUsageCard(context),
          const SizedBox(height: AppSpacing.s16),
          _buildPresentationsCard(context),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final colors = context.colors;
    final displayName = _stringField('displayName');
    final email = _stringField('email');
    final photoUrl = _stringField('photoUrl');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(photoUrl: photoUrl, displayName: displayName, email: email),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isNotEmpty ? displayName : '(isimsiz)',
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _Badge(
                      label: _role == 'admin' ? 'YÖNETİCİ' : 'KULLANICI',
                      color: _role == 'admin' ? colors.primary : colors.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    _Badge(
                      label: _isSuspended ? 'ASKIDA' : 'AKTİF',
                      color: _isSuspended ? colors.danger : colors.success,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: AppSpacing.s24),
            _infoRow(context, 'UID', widget.userId),
            _infoRow(context, 'E-posta', email.isNotEmpty ? email : '-'),
            _infoRow(context, 'Rol', _role),
            _infoRow(context, 'Durum', _isSuspended ? 'Askıda' : 'Aktif'),
            _infoRow(context, 'Kayıt', _formatDate(_timestampField('createdAt'))),
            _infoRow(context, 'Son giriş', _formatDate(_timestampField('lastActiveAt'))),
            _infoRow(context, 'Sunum sayısı', _intField('presentationCount').toString()),
            _infoRow(
              context,
              'Kullanılan kod',
              _stringField('redeemedCode').isEmpty ? '-' : _stringField('redeemedCode'),
            ),
            _infoRow(context, 'Kod tarihi', _formatDate(_timestampField('redeemedAt'))),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Plan (Tier)'),
            RadioGroup<String>(
              groupValue: _tier,
              onChanged: (tier) {
                if (_saving || tier == null) return;
                _changeTier(tier);
              },
              child: Column(
                children: [
                  for (final (value, label) in _tierOptions)
                    RadioListTile<String>(
                      value: value,
                      title: Text(label),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Yönetim'),
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : _toggleSuspend,
                  icon: Icon(
                    _isSuspended
                        ? Icons.play_circle_outline
                        : Icons.pause_circle_outline,
                    size: 18,
                  ),
                  label: Text(_isSuspended ? 'Aktifleştir' : 'Askıya Al'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : _toggleRole,
                  icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                  label: Text(_role == 'admin' ? 'Yetkiyi Kaldır' : 'Yönetici Yap'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : () => _editField('displayName', 'Ad Soyad'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('İsmi Düzenle'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : () => _editField('presentationCount', 'Sunum Sayısı', numeric: true),
                  icon: const Icon(Icons.numbers_rounded, size: 18),
                  label: const Text('Sunum Sayısını Düzenle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(BuildContext context) {
    final colors = context.colors;
    final usage = _data?.usage ?? const <_UsageEntry>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Günlük Kullanım (${usage.length} gün)'),
            if (usage.isEmpty)
              Text(
                'Kayıt yok.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              )
            else
              for (final entry in usage)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.date,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      _Badge(
                        label: '${entry.count} sunum',
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresentationsCard(BuildContext context) {
    final colors = context.colors;
    final presentations = _data?.presentations ?? const <_PresentationEntry>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Sunumlar (${presentations.length})'),
            if (presentations.isEmpty)
              Text(
                'Sunum yok.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              )
            else
              for (final presentation in presentations)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    presentation.topic.isNotEmpty ? presentation.topic : '(başlıksız)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    [
                      if (presentation.createdAt.isNotEmpty)
                        _formatDate(presentation.createdAt),
                      '${presentation.slideCount} slayt',
                    ].join(' • '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editörde Aç',
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _openInEditor(presentation.id),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PresentationViewPage(presentationId: presentation.id),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photoUrl,
    required this.displayName,
    required this.email,
  });

  final String photoUrl;
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (photoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Image.network(
          photoUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initial(context, colors),
        ),
      );
    }
    return _initial(context, colors);
  }

  Widget _initial(BuildContext context, AppColors colors) {
    final initial = (displayName.isNotEmpty ? displayName : email)
        .substring(0, 1)
        .toUpperCase();
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.12),
      ),
      child: Text(
        initial,
        style: AppTypography.titleMedium.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
