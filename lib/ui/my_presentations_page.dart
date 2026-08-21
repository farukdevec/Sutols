import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/firestore_rest_helper.dart';
import '../services/presentation_loader.dart';
import '../state/language_controller.dart';
import '../services/web_url_service.dart';
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
      return _PresentationItem(
        id: id,
        topic: FirestoreRestHelper.stringField(fields, 'topic'),
        slideCount: int.tryParse(
              FirestoreRestHelper.integerField(fields, 'slideCount'),
            ) ??
            0,
        createdAt: FirestoreRestHelper.timestampField(fields, 'createdAt'),
      );
    }).toList();
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    if (LanguageController.instance.isEnglish) {
      return '${date.day}/${date.month}/${date.year}';
    }
    final monthName = _months[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Title(
      title: '${tr('Sunumlarım', 'My Presentations')} – Sutols',
      color: colors.accent,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(tr('Sunumlarım', 'My Presentations')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Geri',
            onPressed: () => AppRoutes.handleAppBack(context),
          ),
        ),
      body: currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    tr(
                      'Sunumlarınızı görmek için lütfen giriş yapın',
                      'Please sign in to view your presentations',
                    ),
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.login),
                    icon: const Icon(Icons.login_rounded),
                    label: Text(tr('Giriş Yap', 'Sign In')),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<_PresentationItem>>(
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
                            tr(
                              'Sunumlar şu anda yüklenemiyor.\nLütfen daha sonra tekrar deneyin.',
                              'Presentations cannot be loaded right now.\nPlease try again later.',
                            ),
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
                          tr(
                            'Henüz sunum oluşturmadınız',
                            'You haven\'t created any presentations yet',
                          ),
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
                        '${item.slideCount} ${tr('slayt', 'slides')}'
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
                    final targetRoute = AppRoutes.presentationUrl(
                      id: item.id,
                      topic: item.topic,
                    );
                    updateBrowserUrl(path: targetRoute, title: item.topic);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: RouteSettings(name: targetRoute),
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
      ),
    );
  }
}
