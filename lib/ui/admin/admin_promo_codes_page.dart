import 'package:flutter/material.dart';

import '../../services/firestore_rest_helper.dart';
import '../design/design_system.dart';

/// Admin'in promosyon kodlarını oluşturduğu, kullanımını takip ettiği
/// (usedCount/maxUses) ve süre/aktiflik ayarlarını yönettiği sayfa.
class AdminPromoCodesPage extends StatefulWidget {
  const AdminPromoCodesPage({super.key});

  @override
  State<AdminPromoCodesPage> createState() => _AdminPromoCodesPageState();
}

class _PromoCodeItem {
  const _PromoCodeItem({
    required this.code,
    required this.grantsTier,
    required this.active,
    required this.usedCount,
    required this.expiresAt,
    required this.targetUid,
    this.targetName = '',
    this.maxUses,
  });

  final String code;
  final String grantsTier;
  final bool active;
  final int usedCount;
  final String expiresAt;
  final String targetUid;
  final String targetName;
  final int? maxUses;

  bool get isExpired {
    final date = DateTime.tryParse(expiresAt);
    if (date == null) return false;
    return !date.isAfter(DateTime.now().toUtc());
  }

  _PromoCodeItem copyWith({bool? active}) {
    return _PromoCodeItem(
      code: code,
      grantsTier: grantsTier,
      active: active ?? this.active,
      usedCount: usedCount,
      expiresAt: expiresAt,
      targetUid: targetUid,
      targetName: targetName,
      maxUses: maxUses,
    );
  }
}

class _AdminPromoCodesPageState extends State<AdminPromoCodesPage> {
  bool _loading = true;
  String? _error;
  List<_PromoCodeItem> _codes = [];

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
      final docs = await FirestoreRestHelper.listDocuments('promoCodes');

      final codes = docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final code = (doc['name'] as String? ?? '').split('/').last;
        return _PromoCodeItem(
          code: code,
          grantsTier: FirestoreRestHelper.stringField(fields, 'grantsTier'),
          active: fields['active']?['booleanValue'] as bool? ?? false,
          usedCount: int.tryParse(
                FirestoreRestHelper.integerField(fields, 'usedCount'),
              ) ??
              0,
          expiresAt: FirestoreRestHelper.timestampField(fields, 'expiresAt'),
          targetUid: FirestoreRestHelper.stringField(fields, 'targetUid'),
          targetName: FirestoreRestHelper.stringField(fields, 'targetName'),
          maxUses:
              int.tryParse(FirestoreRestHelper.integerField(fields, 'maxUses')),
        );
      }).toList()
        ..sort((a, b) => a.code.toLowerCase().compareTo(b.code.toLowerCase()));

      if (!mounted) return;
      setState(() {
        _codes = codes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Kodlar yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  Future<void> _createCode() async {
    final draft = await showDialog<_NewCode>(
      context: context,
      builder: (_) => const _CreateCodeDialog(),
    );
    if (draft == null || !mounted) return;

    try {
      await FirestoreRestHelper.createDocument(
        'promoCodes',
        draft.code,
        draft.toFields(),
      );
      if (!mounted) return;
      _showMessage('Kod oluşturuldu: ${draft.code}', isError: false);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Kod oluşturulamadı: $e', isError: true);
    }
  }

  Future<void> _toggleActive(_PromoCodeItem item) async {
    final next = !item.active;
    try {
      await FirestoreRestHelper.patchDocument(
        'promoCodes/${item.code}',
        {'active': {'booleanValue': next}},
        updateMask: const ['active'],
      );
      if (!mounted) return;
      setState(() {
        _codes = [
          for (final c in _codes)
            if (c.code == item.code) c.copyWith(active: next) else c,
        ];
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Durum güncellenemedi: $e', isError: true);
    }
  }

  Future<void> _delete(_PromoCodeItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kodu Sil'),
        content: Text('"${item.code}" kodu silinsin mi? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await FirestoreRestHelper.deleteDocument('promoCodes/${item.code}');
      if (!mounted) return;
      _showMessage('Kod silindi: ${item.code}', isError: false);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Silme başarısız: $e', isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.danger : colors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Promosyon Kodları'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
          IconButton(
            tooltip: 'Yeni Kod',
            icon: const Icon(Icons.add_rounded),
            onPressed: _createCode,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Yeni Kod',
        onPressed: _createCode,
        child: const Icon(Icons.add_rounded),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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

    if (_codes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 56,
              color: colors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Henüz kod tanımlanmadı.',
              style: AppTypography.titleMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Sağ alttaki + butonu ile ilk kodunuzu oluşturun.',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s24),
      itemCount: _codes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final item = _codes[index];
        return _CodeTile(
          item: item,
          onToggleActive: () => _toggleActive(item),
          onDelete: () => _delete(item),
        );
      },
    );
  }
}

class _CodeTile extends StatelessWidget {
  const _CodeTile({
    required this.item,
    required this.onToggleActive,
    required this.onDelete,
  });

  final _PromoCodeItem item;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final narrow = MediaQuery.sizeOf(context).width < 480;
    final expired = item.isExpired;
    final statusColor = item.active ? colors.success : colors.textSecondary;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.code,
          style: AppTypography.titleMedium.copyWith(
            color: colors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            Chip(
              label: Text(
                item.grantsTier == 'premium'
                    ? 'Premium'
                    : item.grantsTier == 'plus'
                        ? 'Plus'
                        : 'Tier: ${item.grantsTier.isEmpty ? '-' : item.grantsTier}',
              ),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                item.maxUses != null
                    ? 'Kullanım: ${item.usedCount}/${item.maxUses}'
                    : 'Kullanım: ${item.usedCount}',
                style: TextStyle(
                  color: item.maxUses != null &&
                          item.usedCount >= item.maxUses!
                      ? colors.danger
                      : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                expired
                    ? 'Süresi doldu'
                    : item.expiresAt.isEmpty
                        ? 'Süresiz'
                        : 'Bitiş: ${_formatDate(item.expiresAt)}',
                style: TextStyle(
                  color: expired ? colors.danger : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                color: expired
                    ? colors.danger.withValues(alpha: 0.5)
                    : colors.border,
              ),
            ),
            Chip(
              label: Text(
                item.active ? 'Aktif' : 'Pasif',
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
        if (item.targetUid.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            item.targetName.isNotEmpty
                ? 'Hedef: ${item.targetName} (${item.targetUid})'
                : 'Hedef: ${item.targetUid}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.tonalIcon(
          onPressed: onToggleActive,
          icon: Icon(
            item.active ? Icons.pause_circle_outline : Icons.play_circle_outline,
            size: 18,
          ),
          label: Text(item.active ? 'Pasifleştir' : 'Aktifleştir'),
        ),
        const SizedBox(width: AppSpacing.s8),
        IconButton(
          tooltip: 'Sil',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
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
                  Align(alignment: Alignment.centerRight, child: actions),
                ],
              )
            : Row(
                children: [
                  Expanded(child: info),
                  const SizedBox(width: AppSpacing.s12),
                  actions,
                ],
              ),
      ),
    );
  }

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day.$month.${local.year}';
  }
}

/// Yeni kod oluşturma formunun sonucu.
class _NewCode {
  const _NewCode({
    required this.code,
    required this.tier,
    this.expiresAt,
    this.maxUses,
    this.targetUid = '',
    this.targetName = '',
  });

  final String code;
  final String tier;
  final DateTime? expiresAt;
  final int? maxUses;
  final String targetUid;
  final String targetName;

  Map<String, dynamic> toFields() {
    final fields = <String, dynamic>{
      'grantsTier': {'stringValue': tier},
      'active': {'booleanValue': true},
      'usedCount': {'integerValue': '0'},
      'createdAt': {'timestampValue': FirestoreRestHelper.nowTimestamp()},
    };
    if (expiresAt != null) {
      final endOfDay =
          DateTime(expiresAt!.year, expiresAt!.month, expiresAt!.day, 23, 59, 59)
              .toUtc();
      fields['expiresAt'] = {'timestampValue': FirestoreRestHelper.toFirestoreTimestamp(endOfDay)};
    }
    if (maxUses != null) {
      fields['maxUses'] = {'integerValue': '$maxUses'};
    }
    if (targetUid.isNotEmpty) {
      fields['targetUid'] = {'stringValue': targetUid};
    }
    if (targetName.isNotEmpty) {
      fields['targetName'] = {'stringValue': targetName};
    }
    return fields;
  }
}

class _UserOption {
  const _UserOption({
    required this.uid,
    required this.name,
    required this.email,
  });

  final String uid;
  final String name;
  final String email;

  String get label => name.isNotEmpty ? name : (email.isNotEmpty ? email : uid);
}

class _CreateCodeDialog extends StatefulWidget {
  const _CreateCodeDialog();

  @override
  State<_CreateCodeDialog> createState() => _CreateCodeDialogState();
}

class _CreateCodeDialogState extends State<_CreateCodeDialog> {
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _maxUsesCtrl = TextEditingController();
  final TextEditingController _targetCtrl = TextEditingController();
  String _tier = 'premium';
  DateTime? _expiresAt;

  List<_UserOption> _users = [];
  bool _usersLoaded = false;
  _UserOption? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _maxUsesCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final docs = await FirestoreRestHelper.listDocuments('users');
      final users = docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        return _UserOption(
          uid: (doc['name'] as String? ?? '').split('/').last,
          name: FirestoreRestHelper.stringField(fields, 'displayName'),
          email: FirestoreRestHelper.stringField(fields, 'email'),
        );
      }).toList()
        ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _users = users;
        _usersLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _usersLoaded = true);
    }
  }

  List<_UserOption> get _matches {
    final query = _targetCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _users
        .where((u) =>
            u.uid.toLowerCase().contains(query) ||
            u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query))
        .take(5)
        .toList();
  }

  void _selectUser(_UserOption user) {
    setState(() {
      _selectedUser = user;
      _targetCtrl.text = user.label;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUser = null;
      _targetCtrl.clear();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _expiresAt = picked);
    }
  }

  void _submit() {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showError('Kod gerekli.');
      return;
    }

    final maxUsesText = _maxUsesCtrl.text.trim();
    int? maxUses;
    if (maxUsesText.isNotEmpty) {
      maxUses = int.tryParse(maxUsesText);
      if (maxUses == null || maxUses < 1) {
        _showError('Kullanım limiti 1 veya daha büyük olmalı.');
        return;
      }
    }

    final rawTarget = _targetCtrl.text.trim();
    Navigator.of(context).pop(
      _NewCode(
        code: code,
        tier: _tier,
        expiresAt: _expiresAt,
        maxUses: maxUses,
        targetUid: _selectedUser?.uid ?? rawTarget,
        targetName: _selectedUser?.name ?? '',
      ),
    );
  }

  void _showError(String message) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final matches = _matches;

    return AlertDialog(
      title: const Text('Yeni Promosyon Kodu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Kod',
                hintText: 'YAZ_KODU123',
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Vereceği Plan',
              style: AppTypography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'plus', label: Text('Plus')),
                ButtonSegment(value: 'premium', label: Text('Premium')),
              ],
              selected: {_tier},
              onSelectionChanged: (selection) =>
                  setState(() => _tier = selection.first),
            ),
            const SizedBox(height: AppSpacing.s16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(
                _expiresAt == null
                    ? 'Bitiş Tarihi (boş = süresiz)'
                    : 'Bitiş: ${_expiresAt!.day}.${_expiresAt!.month}.${_expiresAt!.year}',
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            TextField(
              controller: _maxUsesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kullanım Limiti (boş = sınırsız)',
                hintText: 'örn. 50',
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            TextField(
              controller: _targetCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Hedef Kullanıcı (opsiyonel)',
                hintText: 'İsim veya e-posta yazın, hesabı seçin',
              ),
            ),
            if (_selectedUser != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 18, color: Colors.green),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedUser!.label,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'UID: ${_selectedUser!.uid}',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Seçimi kaldır',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: _clearSelection,
                    ),
                  ],
                ),
              ),
            ] else if (matches.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s8),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    for (final user in matches)
                      InkWell(
                        onTap: () => _selectUser(user),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.label,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${user.email.isNotEmpty ? '${user.email} • ' : ''}UID: ${user.uid}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ] else if (_targetCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                _usersLoaded
                    ? 'Eşleşen hesap yok. Yazılan değer UID olarak kaydedilir.'
                    : 'Hesaplar yükleniyor...',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}