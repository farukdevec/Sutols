import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_rest_helper.dart';
import '../services/presentation_loader.dart';
import 'design/design_system.dart';
import 'html_presentation_editor_page.dart';

class MyPresentationsPage extends StatefulWidget {
  const MyPresentationsPage({super.key});

  @override
  State<MyPresentationsPage> createState() => _MyPresentationsPageState();
}

class _PresentationItem {
  const _PresentationItem({
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

class _MyPresentationsPageState extends State<MyPresentationsPage> {
  late final Future<List<_PresentationItem>> _future;

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

  @override
  void initState() {
    super.initState();
    _future = _fetchPresentations();
  }

  Future<List<_PresentationItem>> _fetchPresentations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final docs = await FirestoreRestHelper.runQuery({
      'from': [
        {'collectionId': 'presentations'},
      ],
      'where': {
        'fieldFilter': {
          'field': {'fieldPath': 'userId'},
          'op': 'EQUAL',
          'value': {'stringValue': uid},
        },
      },
      'orderBy': [
        {
          'field': {'fieldPath': 'createdAt'},
          'direction': 'DESCENDING'
        },
      ],
    });

    return docs.map((doc) {
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};
      final id = (doc['name'] as String? ?? '').split('/').last;
      final slideCount = int.tryParse(
            FirestoreRestHelper.integerField(fields, 'slideCount'),
          ) ??
          0;
      return _PresentationItem(
        id: id,
        topic: FirestoreRestHelper.stringField(fields, 'topic'),
        slideCount: slideCount,
        createdAt: FirestoreRestHelper.timestampField(fields, 'createdAt'),
      );
    }).toList();
  }

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Sunumlarım'),
      ),
      body: FutureBuilder<List<_PresentationItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 48,
                      color: colors.textSecondary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Sunumlar şu anda yüklenemiyor.\nLütfen daha sonra tekrar deneyin.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 56,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Henüz sunum oluşturmadınız',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final item = items[index];
              final createdAt = _formatDate(item.createdAt);

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    item.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        if (createdAt.isNotEmpty) createdAt,
                        '${item.slideCount} slayt'
                      ].join(' • '),
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final result = await loadPresentationForEdit(item.id);
                    if (!mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HtmlPresentationEditorPage(
                          controller: result.controller,
                          presentationId: item.id,
                          initialUpdatedByName: result.updatedByName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
