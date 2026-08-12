import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/firestore_rest_helper.dart';
import '../services/presentation_project_codec.dart';
import 'design/design_system.dart';
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
      throw Exception('Lütfen önce giriş yapın.');
    }

    final idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse('$_apiBase/presentations/$presentationId'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Sunum yüklenemedi (HTTP ${response.statusCode}): ${response.body}');
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
          for (final page in decoded.pages) {
            final title = page.textBlocks.isNotEmpty
                ? page.textBlocks.first.text
                : '';
            final content = page.textBlocks
                .skip(1)
                .map((b) => b.text)
                .where((t) => t.isNotEmpty)
                .join('\n');
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
    // Admin için kural bazen 403 dönebilir (rule değişimi geçiş dönemi);
    // hata durumunda boş listeyle devam et, değilse kullanıcının görmesi
    // gereken slaytlar yok zaten (ana belge/project doluysa).
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
        // Kural 403 döndürürse sessizce yut: yukarıdaki yedeklerden
        // slayt gelmişse onlarla devam edilir, yoksa boş liste gösterilir.
      }
    }

    return {
      'topic': _stringField(fields, 'topic'),
      'slides': slides,
      'updatedByName': updatedByName ?? '',
    };
  }

  Future<void> _openShareDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    final info = _shareInfo;
    if (user == null || info == null) return;

    await showDialog<void>(
      context: context,
      builder: (_) => SharePresentationDialog(
        presentationId: widget.presentationId,
        isOwner: info['userId'] == user.uid,
        initialShared: info['shared'] == true,
      ),
    );
    if (!mounted) return;
    setState(() {
      _future = _fetchPresentation(widget.presentationId);
    });
  }

  static List<Map<String, dynamic>> _slidesField(dynamic field) {
    final values = field?['arrayValue']?['values'] as List? ?? const [];
    return values.map((value) {
      final fields =
          (value as Map<String, dynamic>)['mapValue']?['fields'] as Map<String, dynamic>? ?? {};
      return {
        'title': _stringField(fields, 'title'),
        'content': _stringField(fields, 'content'),
        'layout': _stringField(fields, 'layout'),
        'modelIds': _stringArrayField(fields, 'modelIds'),
      };
    }).toList();
  }

  static String _stringField(Map<String, dynamic> fields, String key) {
    return fields[key]?['stringValue'] as String? ?? '';
  }

  static List<String> _stringArrayField(Map<String, dynamic> fields, String key) {
    final values = fields[key]?['arrayValue']?['values'] as List? ?? const [];
    return values
        .map((v) => (v as Map<String, dynamic>)['stringValue'] as String? ?? '')
        .where((v) => v.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Sunum'),
        backgroundColor: colors.surface,
        actions: [
          if (_shareInfo != null && !widget.adminView)
            IconButton(
              tooltip: 'Paylaş',
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
                  'Sunum yüklenemedi: ${snapshot.error}',
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
                'Sunum bulunamadı.',
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
                  '${slides.length} slayt',
                  '• ${widget.presentationId}',
                  if ((data['updatedByName'] as String? ?? '').isNotEmpty)
                    '• Son düzenleme: ${data['updatedByName']}',
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
          Text(
            slide['content'] as String? ?? '',
            style: AppTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
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
