import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/firestore_rest_helper.dart';
import '../services/presentation_loader.dart';
import '../services/presentation_model_source_resolver.dart';
import '../services/presentation_project_codec.dart';
import '../state/language_controller.dart';
import 'design/design_system.dart';
import 'html_presentation_editor_page.dart';
import 'widgets/share_presentation_dialog.dart';

class PresentationViewPage extends StatefulWidget {
  const PresentationViewPage({
    super.key,
    required this.presentationId,
    this.adminView = false,
  });

  final String presentationId;

  /// Admin panelinden açıldığında true: yazma/işlem amaçlı kontroller
  /// (paylaşım gibi) gizlenir, sayfa salt okunur görüntülenir.
  final bool adminView;

  @override
  State<PresentationViewPage> createState() => _PresentationViewPageState();
}

class _PresentationViewPageState extends State<PresentationViewPage> {
  static const String _apiBase =
      'https://firestore.googleapis.com/v1/projects/sutols/databases/(default)/documents';

  late Future<Map<String, dynamic>> _future;
  Map<String, dynamic>? _shareInfo;

  @override
  void initState() {
    super.initState();
    _future = _fetchPresentation(widget.presentationId);
  }

  Future<Map<String, dynamic>> _fetchPresentation(String presentationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(tr('Lütfen önce giriş yapın.', 'Please sign in first.'));
    }

    final idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse('$_apiBase/presentations/$presentationId'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        '${tr('Sunum yüklenemedi', 'Could not load presentation')} (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    final doc = jsonDecode(response.body) as Map<String, dynamic>;
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};

    _shareInfo = {
      'userId': _stringField(fields, 'userId'),
      'shared': fields['shared']?['booleanValue'] as bool? ?? false,
    };

    String? updatedByName;

    // Editör deck'i varsa (cloud kayıtlı/paylaşılan sunum) onu göster.
    final projectDoc = await FirestoreRestHelper.getDocument(
      'presentations/$presentationId/project/data',
    );
    var slides = <Map<String, dynamic>>[];
    if (projectDoc != null) {
      final projectFields =
          projectDoc['fields'] as Map<String, dynamic>? ?? {};
      final projectJson =
          FirestoreRestHelper.stringField(projectFields, 'json');
      updatedByName =
          FirestoreRestHelper.stringField(projectFields, 'updatedByName');
      if (projectJson.isNotEmpty) {
        try {
          final decoded = PresentationProjectCodec.decodeProject(projectJson);
          await hydratePresentationModelSources(decoded.pages);

          for (final page in decoded.pages) {
            var title = page.textBlocks.isNotEmpty
                ? page.textBlocks.first.text
                : '';
            var content = page.textBlocks
                .skip(1)
                .map((b) => b.text)
                .where((t) => t.isNotEmpty)
                .join('\n');
            // Remove markdown emphasis leftover ("**") and trim
            title = title.replaceAll('*', '').trim();
            content = content.replaceAll('*', '').trim();
            final modelIds = page.componentBlocks
                .map((b) => b.modelAssetId)
                .whereType<String>()
                .toList();
            slides.add({
              'title': title,
              'content': content,
              'layout': page.backgroundKind.name,
              'modelIds': modelIds,
            });
          }
        } catch (_) {
          slides = [];
        }
      }
    }

    // Eski sunumlar için yedek 1: ana belgedeki slides dizisi.
    if (slides.isEmpty && fields['slides'] != null) {
      slides = _slidesField(fields['slides']);
    }

    // Yedek 2: slides alt koleksiyonu (order alanıyla).
    if (slides.isEmpty) {
      try {
        final slideDocs = await FirestoreRestHelper.runQuery({
          'from': [
            {
              'parent': 'presentations/$presentationId',
              'collectionId': 'slides',
            },
          ],
          'orderBy': [
            {'field': {'fieldPath': 'order'}, 'direction': 'ASCENDING'},
          ],
        });
        slides = slideDocs.map<Map<String, dynamic>>((slideDoc) {
          final slideFields =
              slideDoc['fields'] as Map<String, dynamic>? ?? {};
          return {
            'title': FirestoreRestHelper.stringField(slideFields, 'title'),
            'content': FirestoreRestHelper.stringField(slideFields, 'content'),
            'layout': FirestoreRestHelper.stringField(slideFields, 'layout'),
            'modelIds': FirestoreRestHelper.arrayField(slideFields, 'modelIds'),
          };
        }).toList();
      } catch (_) {
        slides = [];
      }
    }

    return {
      'topic': _stringField(fields, 'topic'),
      'slides': slides,
      if (updatedByName != null && updatedByName.isNotEmpty)
        'updatedByName': updatedByName,
    };
  }

  static String _stringField(Map<String, dynamic> fields, String key) {
    final value = fields[key];
    if (value is Map<String, dynamic>) {
      final s = value['stringValue'];
      if (s is String) return s;
    }
    return '';
  }

  static List<Map<String, dynamic>> _slidesField(dynamic raw) {
    if (raw is! Map<String, dynamic>) return [];
    final arrayValue = raw['arrayValue'];
    if (arrayValue is! Map<String, dynamic>) return [];
    final values = arrayValue['values'];
    if (values is! List) return [];

    return values.map<Map<String, dynamic>>((item) {
      if (item is! Map<String, dynamic>) return {};
      final mapValue = item['mapValue'];
      if (mapValue is! Map<String, dynamic>) return {};
      final fields = mapValue['fields'];
      if (fields is! Map<String, dynamic>) return {};

      final modelIdsRaw = fields['modelIds'];
      final modelIds = <String>[];
      if (modelIdsRaw is Map<String, dynamic>) {
        final arr = modelIdsRaw['arrayValue'];
        if (arr is Map<String, dynamic> && arr['values'] is List) {
          for (final v in arr['values'] as List) {
            if (v is Map<String, dynamic> && v['stringValue'] is String) {
              modelIds.add(v['stringValue'] as String);
            }
          }
        }
      }

      return {
        'title': _stringField(fields, 'title'),
        'content': _stringField(fields, 'content'),
        'layout': _stringField(fields, 'layout'),
        'modelIds': modelIds,
      };
    }).toList();
  }

  void _openShareDialog() {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = _shareInfo?['userId'] == user?.uid;
    final initialShared = _shareInfo?['shared'] as bool? ?? false;

    showDialog<void>(
      context: context,
      builder: (_) => SharePresentationDialog(
        presentationId: widget.presentationId,
        isOwner: isOwner,
        initialShared: initialShared,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(tr('Sunum', 'Presentation')),
        backgroundColor: colors.surface,
        actions: [
          if (!widget.adminView)
            IconButton(
              tooltip: tr('Editörde Düzenle', 'Edit in Editor'),
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () async {
                final result = await loadPresentationForEdit(widget.presentationId);
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HtmlPresentationEditorPage(
                      controller: result.controller,
                      presentationId: widget.presentationId,
                      initialUpdatedByName: result.updatedByName,
                    ),
                  ),
                );
              },
            ),
          if (_shareInfo != null && !widget.adminView)
            IconButton(
              tooltip: tr('Paylaş', 'Share'),
              icon: const Icon(Icons.share_outlined),
              onPressed: _openShareDialog,
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
                  '${tr('Sunum yüklenemedi', 'Could not load presentation')}: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Text(
                tr('Sunum bulunamadı.', 'Presentation not found.'),
                style: AppTypography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            );
          }

          final slides = (data['slides'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s32),
            children: [
              Text(
                data['topic'] as String? ?? '',
                style: AppTypography.headline.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                [
                  '${slides.length} ${tr('slayt', 'slides')}',
                  '• ${widget.presentationId}',
                  if ((data['updatedByName'] as String? ?? '').isNotEmpty)
                    '• ${tr('Son düzenleme:', 'Last edited by:')} ${data['updatedByName']}',
                ].join(' '),
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              for (final slide in slides)
                _SlideCard(
                  index: slides.indexOf(slide) + 1,
                  slide: slide,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.index, required this.slide});

  final int index;
  final Map<String, dynamic> slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final modelIds = (slide['modelIds'] as List?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$index',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  slide['title'] as String? ?? '',
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          // Render content lines; detect any '**Header:**' patterns and render header bold without showing '**'
          Builder(builder: (context) {
            final content = (slide['content'] as String?) ?? '';
            final lines = content.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  () {
                    final matches = RegExp(r'\*\*([^*]+)\:\*\*').allMatches(line).toList();
                    if (matches.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(line, style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
                      );
                    }

                    // Build TextSpans: text segments and bold headers for each match
                    final spans = <TextSpan>[];
                    var lastIndex = 0;
                    for (final m in matches) {
                      if (m.start > lastIndex) {
                        spans.add(TextSpan(text: line.substring(lastIndex, m.start)));
                      }
                      final header = m.group(1) ?? '';
                      spans.add(TextSpan(text: header + ': ', style: const TextStyle(fontWeight: FontWeight.w700)));
                      lastIndex = m.end;
                    }
                    if (lastIndex < line.length) spans.add(TextSpan(text: line.substring(lastIndex)));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
                          children: spans,
                        ),
                      ),
                    );
                  }(),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.s16),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              Chip(
                label: Text('Layout: ${slide['layout'] ?? '-'}'),
                visualDensity: VisualDensity.compact,
              ),
              if (modelIds.isNotEmpty)
                Chip(
                  label: Text('${modelIds.length} model'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
