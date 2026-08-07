import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/presentation_project_store.dart';
import '../design/design_system.dart';

/// Sunum paylaşım dialogu: bağlantı oluşturur, sahip ise
/// "bağlantıyla düzenlemeye aç" anahtarını yönetir.
class SharePresentationDialog extends StatefulWidget {
  const SharePresentationDialog({
    super.key,
    required this.presentationId,
    required this.isOwner,
    required this.initialShared,
  });

  final String presentationId;
  final bool isOwner;
  final bool initialShared;

  @override
  State<SharePresentationDialog> createState() =>
      _SharePresentationDialogState();
}

class _SharePresentationDialogState extends State<SharePresentationDialog> {
  late bool _shared;
  bool _saving = false;

  String get _link => '${Uri.base.origin}/p/${widget.presentationId}';

  @override
  void initState() {
    super.initState();
    _shared = widget.initialShared;
  }

  Future<void> _toggle(bool value) async {
    setState(() {
      _shared = value;
      _saving = true;
    });
    try {
      await PresentationProjectStore.setShared(widget.presentationId, value);
      if (!mounted) return;
      setState(() => _saving = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _shared = !value;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paylaşım güncellenemedi: $e')),
      );
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bağlantı kopyalandı.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: const Text('Sunumu Paylaş'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isOwner) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Bağlantıyla düzenlemeye aç'),
                subtitle: Text(
                  _shared
                      ? 'Bağlantıya sahip olanlar editörden düzenleyebilir.'
                      : 'Kapalı: yalnızca siz düzenleyebilirsiniz.',
                ),
                value: _shared,
                onChanged: _saving ? null : _toggle,
              ),
              const SizedBox(height: AppSpacing.s8),
            ],
            Text(
              'Paylaşım bağlantısı:',
              style: AppTypography.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                _link,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              widget.isOwner && !_shared
                  ? 'Bağlantıyı açtığınızda kullanıcılar editörden düzenleyebilir; son düzenleyenin adı görünür.'
                  : 'Bağlantıyı kopyalayıp paylaşın. Bağlantıya sahip olanlar sunumu açar.',
              style: AppTypography.labelSmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        FilledButton.icon(
          onPressed: _copy,
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Kopyala'),
        ),
      ],
    );
  }
}
