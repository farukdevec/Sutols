import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/firestore_rest_helper.dart';
import '../services/presentation_loader.dart';
import '../services/web_url_service.dart';
import 'design/design_system.dart';
import 'html_presentation_editor_page.dart';

/// Paylaşım bağlantısından açılan sunumu yükleyip editöre yönlendirir.
/// Proje dokümanı (deck JSON) varsa tam durumla; yoksa (eski sunumlar)
/// slides alt koleksiyonundan basit deck üretilir.
class PresentationOpenPage extends StatefulWidget {
  const PresentationOpenPage({super.key, required this.presentationId});

  final String presentationId;

  @override
  State<PresentationOpenPage> createState() => _PresentationOpenPageState();
}

class _PresentationOpenPageState extends State<PresentationOpenPage> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final doc = await FirestoreRestHelper.getDocument(
        'presentations/${widget.presentationId}',
      );
      if (doc == null) {
        throw const PresentationLoadException(
          'Sunum bulunamadı veya erişiminiz yok.',
        );
      }

      final fields = doc['fields'] as Map<String, dynamic>? ?? {};
      final topic = fields['topic']?['stringValue'] as String? ?? '';

      final result = await loadPresentationForEdit(widget.presentationId);

      final targetUrl = AppRoutes.presentationUrl(
        id: widget.presentationId,
        topic: topic,
      );
      updateBrowserUrl(
        path: targetUrl,
        title: topic.isNotEmpty ? topic : 'Sunum',
      );

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: targetUrl),
          builder: (_) => HtmlPresentationEditorPage(
            controller: result.controller,
            presentationId: widget.presentationId,
            initialUpdatedByName: result.updatedByName,
          ),
        ),
      );
    } on PresentationLoadException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Sunum yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Sunum')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.s32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.link_off_rounded,
                      size: 48,
                      color: colors.textSecondary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      _error ?? 'Sunum yüklenemedi.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
