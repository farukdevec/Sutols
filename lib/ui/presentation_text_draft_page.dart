import 'package:flutter/material.dart';

import '../services/presentation_auto_builder.dart';
import '../state/presentation_controller.dart';
import 'html_presentation_editor_page.dart';

const Color _draftInk = Color(0xFF142033);
const Color _draftMuted = Color(0xFF6C7890);
const Color _draftAccent = Color(0xFF0B7BFF);
const Color _draftBorder = Color(0xFFDCE5F1);

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
          titleHint: 'Yeni Sayfa',
          bodyHint: 'Bu sayfanin metnini yazin.',
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
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _draftInk,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Sunum Metni',
          style: theme.textTheme.titleLarge?.copyWith(
            color: _draftInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sayfa ekle',
            onPressed: _addPage,
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 28.0 : 14.0;

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      18,
                      horizontalPadding,
                      18,
                    ),
                    itemCount: _pages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: _DraftPageCard(
                            page: _pages[index],
                            index: index,
                            canRemove: _pages.length > 1,
                            onRemove: () => _removePage(index),
                          ),
                        ),
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
  });

  final _DraftPageFields page;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _draftBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                    color: const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCFE0F8)),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _draftAccent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sayfa ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _draftInk,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Sayfayi sil',
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFFD13A3A),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: page.titleController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Baslik',
                hint: page.titleHint,
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                color: _draftInk,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: page.bodyController,
              minLines: 4,
              maxLines: 8,
              decoration: _inputDecoration(
                label: 'Metin',
                hint: page.bodyHint,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _draftInk,
                height: 1.3,
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

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _draftBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 560;
                  final pageLabel = Text(
                    '$pageCount sayfa',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _draftMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                  final addButton = OutlinedButton.icon(
                    onPressed: onAddPage,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Sayfa ekle'),
                  );
                  final createButton = FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Sunumu Olustur'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _draftAccent,
                      foregroundColor: Colors.white,
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        pageLabel,
                        const SizedBox(height: 10),
                        addButton,
                        const SizedBox(height: 8),
                        createButton,
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(child: pageLabel),
                      addButton,
                      const SizedBox(width: 10),
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
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9AA7BC)),
    filled: true,
    fillColor: const Color(0xFFF7F9FD),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _draftBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _draftBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _draftAccent, width: 1.4),
    ),
  );
}
