import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/presentation_feedback_service.dart';
import '../design/design_system.dart';

class PresentationFeedbackDialog extends StatefulWidget {
  const PresentationFeedbackDialog({super.key, required this.presentationId});

  final String presentationId;

  @override
  State<PresentationFeedbackDialog> createState() =>
      _PresentationFeedbackDialogState();
}

class _PresentationFeedbackDialogState extends State<PresentationFeedbackDialog> {
  final _noteController = TextEditingController();
  final _feedbackService = PresentationFeedbackService();
  final Map<String, int> _ratings = <String, int>{
    'model': 0,
    'text': 0,
    'visual': 0,
    'template': 0,
  };
  bool _submitting = false;

  bool get _isComplete => _ratings.values.every((value) => value > 0);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isComplete || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _feedbackService.submit(
        presentationId: widget.presentationId,
        modelRating: _ratings['model']!,
        textRating: _ratings['text']!,
        visualRating: _ratings['visual']!,
        templateRating: _ratings['template']!,
        note: _noteController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geri bildirim gönderilemedi: $error'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.asset(
                      'assets/images/logo.webp',
                      fit: BoxFit.contain,
                      semanticLabel: 'Sutols',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Sunum nasıl oldu?', style: AppTypography.titleLarge.copyWith(color: colors.textPrimary)),
                  ),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Yıldızlarınız, yapay zekâ ile oluşturulan sunumları daha iyi hale getirmemize yardımcı olur.',
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 20),
              _RatingRow(label: 'Modeller', icon: Icons.smart_toy_outlined, value: _ratings['model']!, onChanged: (value) => setState(() => _ratings['model'] = value)),
              _RatingRow(label: 'Metinler', icon: Icons.subject_rounded, value: _ratings['text']!, onChanged: (value) => setState(() => _ratings['text'] = value)),
              _RatingRow(label: 'Görseller', icon: Icons.image_outlined, value: _ratings['visual']!, onChanged: (value) => setState(() => _ratings['visual'] = value)),
              _RatingRow(label: 'Şablon', icon: Icons.dashboard_customize_outlined, value: _ratings['template']!, onChanged: (value) => setState(() => _ratings['template'] = value)),
              const SizedBox(height: 18),
              Focus(
                onKeyEvent: (_, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    _submit();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 1000,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Notunuz (isteğe bağlı)',
                    hintText: 'Geliştirmemiz için bir not bırakın…',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _isComplete && !_submitting ? _submit : null,
                icon: _submitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(_submitting ? 'Gönderiliyor…' : 'Değerlendirmeyi gönder'),
              ),
              if (!_isComplete) ...[
                const SizedBox(height: 8),
                Text('Göndermek için her alanı yıldızlayın.', textAlign: TextAlign.center, style: AppTypography.labelMedium.copyWith(color: colors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.label, required this.icon, required this.value, required this.onChanged});

  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          SizedBox(width: 82, child: Text(label, style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600))),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List<Widget>.generate(5, (index) {
                final star = index + 1;
                return Semantics(
                  button: true,
                  label: '$label için $star yıldız',
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onChanged(star),
                    icon: Icon(star <= value ? Icons.star_rounded : Icons.star_outline_rounded, color: star <= value ? const Color(0xFFFFB300) : colors.textSecondary),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
