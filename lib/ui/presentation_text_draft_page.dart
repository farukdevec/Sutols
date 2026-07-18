import 'package:flutter/material.dart';

import '../services/presentation_auto_builder.dart';
import '../state/presentation_controller.dart';
import 'html_presentation_editor_page.dart';

class PresentationTextDraftPage extends StatefulWidget {
  const PresentationTextDraftPage({
    super.key,
    required this.controller,
  });

  final PresentationController controller;

  @override
  State<PresentationTextDraftPage> createState() =>
      _PresentationTextDraftPageState();
}

class _PresentationTextDraftPageState extends State<PresentationTextDraftPage> {
  late final List<_DraftPageFields> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <_DraftPageFields>[_DraftPageFields()];
  }

  @override
  void dispose() {
    for (final page in _pages) {
      page.dispose();
    }
    super.dispose();
  }

  void _addPage() {
    setState(() {
      _pages.add(
        _DraftPageFields(
          titleHint: 'Sayfa basligi',
          bodyHint: 'Bu sayfada anlatmak istediginiz metni yazin.',
        ),
      );
    });
  }

  void _removePage(int index) {
    if (_pages.length == 1) {
      return;
    }

    setState(() {
      _pages.removeAt(index).dispose();
    });
  }

  void _createPresentation() {
    final drafts = _pages
        .map(
          (page) => PresentationDraftPage(
            title: page.titleController.text,
            body: page.bodyController.text,
          ),
        )
        .toList(growable: false);
    final generatedPages = const PresentationAutoBuilder().buildPages(drafts);

    if (generatedPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir sayfaya metin yazin.'),
        ),
      );
      return;
    }

    widget.controller.replaceDeck(generatedPages);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HtmlPresentationEditorPage(
          controller: widget.controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sunum Metni',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sayfa ekle',
            onPressed: _addPage,
            icon: const Icon(Icons.add_rounded),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = context.spacing.md;

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      16,
                    ),
                    itemCount: _pages.length,
                    separatorBuilder: (_, __) => SizedBox(height: context.spacing.md),
                    itemBuilder: (context, index) {
                      return _DraftPageCard(
                        page: _pages[index],
                        index: index,
                        canRemove: _pages.length > 1,
                        onRemove: () => _removePage(index),
                        maxWidth: constraints.maxWidth < 720 ? constraints.maxWidth : 720,
                      );
                    },
                  ),
                ),
                _DraftBottomBar(
                  pageCount: _pages.length,
                  onAddPage: _addPage,
                  onCreate: _createPresentation,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DraftPageFields {
  _DraftPageFields({
    this.titleHint = 'Sayfa basligi',
    this.bodyHint = 'Bu sayfada anlatmak istediginiz metni yazin.',
  })  : titleController = TextEditingController(),
        bodyController = TextEditingController();

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String titleHint;
  final String bodyHint;

  void dispose() {
    titleController.dispose();
    bodyController.dispose();
  }
}

class _DraftPageCard extends StatelessWidget {
  const _DraftPageCard({
    required this.page,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.maxWidth,
  });

  final _DraftPageFields page;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sutolColors = context.sutolColors;

    return AnimatedContainer(
      duration: context.motion.fast,
      curve: context.motion.defaultCurve,
      decoration: context.decoration.cardElevated(
        color: theme.colorScheme.surface,
        elevation: 1,
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sutolColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: sutolColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: context.spacing.sm),
                Expanded(
                  child: Text(
                    'Sayfa ${index + 1}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Sayfayi sil',
                  onPressed: canRemove ? onRemove : null,
                  icon: Icon(Icons.delete_outline_rounded, size: 20),
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            SizedBox(height: context.spacing.md),
            TextField(
              controller: page.titleController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Baslik',
                hint: page.titleHint,
                theme: theme,
              ),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            TextField(
              controller: page.bodyController,
              minLines: 4,
              maxLines: 8,
              decoration: _inputDecoration(
                label: 'Metin',
                hint: page.bodyHint,
                theme: theme,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftBottomBar extends StatelessWidget {
  const _DraftBottomBar({
    required this.pageCount,
    required this.onAddPage,
    required this.onCreate,
  });

  final int pageCount;
  final VoidCallback onAddPage;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sutolColors = context.sutolColors;

    return Container(
      decoration: context.decoration.panel(),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.spacing.md,
            context.spacing.sm,
            context.spacing.md,
            context.spacing.sm,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 560;
                  final pageLabel = Text(
                    '$pageCount sayfa',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                  final addButton = OutlinedButton.icon(
                    onPressed: onAddPage,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Sayfa ekle', style: TextStyle(fontSize: 13)),
                  );
                  final createButton = FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text('Sunumu Olustur', style: TextStyle(fontSize: 13)),
                    style: FilledButton.styleFrom(
                      backgroundColor: sutolColors.seed,
                      foregroundColor: Colors.white,
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        pageLabel,
                        SizedBox(height: context.spacing.sm),
                        addButton,
                        SizedBox(height: context.spacing.xs),
                        createButton,
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(child: pageLabel),
                      addButton,
                      SizedBox(width: context.spacing.sm),
                      createButton,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required ThemeData theme,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: TextStyle(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      fontSize: 14,
    ),
    filled: true,
    fillColor: theme.colorScheme.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
  );
}
