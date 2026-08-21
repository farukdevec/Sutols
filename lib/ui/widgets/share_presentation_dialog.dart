import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../routes.dart';
import '../../services/presentation_project_store.dart';
import '../../state/language_controller.dart';
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

  String get _link {
    final path = AppRoutes.presentationUrl(id: widget.presentationId, topic: '');
    return '${Uri.base.origin}$path';
  }

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
        SnackBar(
          content: Text(
            '${tr('Paylaşım güncellenemedi', 'Could not update sharing')}: $e',
          ),
        ),
      );
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr('Bağlantı kopyalandı.', 'Link copied to clipboard.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: Text(tr('Sunumu Paylaş', 'Share Presentation')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isOwner) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  tr('Bağlantıyla düzenlemeye aç', 'Allow editing via link'),
                ),
                subtitle: Text(
                  _shared
                      ? tr(
                          'Bağlantıya sahip olanlar editörden düzenleyebilir.',
                          'Anyone with the link can edit in the editor.',
                        )
                      : tr(
                          'Kapalı: yalnızca siz düzenleyebilirsiniz.',
                          'Off: Only you can edit.',
                        ),
                ),
                value: _shared,
                onChanged: _saving ? null : _toggle,
              ),
              const SizedBox(height: AppSpacing.s8),
            ],
            Text(
              tr('Paylaşım bağlantısı:', 'Share link:'),
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
                  ? tr(
                      'Bağlantıyı açtığınızda kullanıcılar editörden düzenleyebilir; son düzenleyenin adı görünür.',
                      'When enabled, anyone with the link can edit in the editor; the last editor\'s name will be displayed.',
                    )
                  : tr(
                      'Bağlantıyı kopyalayıp paylaşın. Bağlantıya sahip olanlar sunumu açar.',
                      'Copy and share the link. Anyone with the link can open the presentation.',
                    ),
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
          child: Text(tr('Kapat', 'Close')),
        ),
        FilledButton.icon(
          onPressed: _copy,
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: Text(tr('Kopyala', 'Copy Link')),
        ),
      ],
    );
  }
}
