import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/slide_model.dart';
import '../services/presentation_export_service.dart';
import '../services/presentation_auto_builder.dart';
import '../services/presentation_fullscreen_service.dart';
import '../services/presentation_project_io.dart';
import '../state/presentation_controller.dart';
import 'presentation_preview_page.dart';
import 'widgets/editor_shell.dart';
import 'widgets/html_stage/html_page_stage.dart';

import 'design/design_system.dart';

extension on BuildContext {
  Color get _htmlInk => sutolColors.onSurface;
  Color get _htmlMuted => sutolColors.onSurfaceVariant;
  Color get _htmlAccent => sutolColors.primary;
  Color get _htmlPanel => sutolColors.surface;
}

enum _HtmlToolTab {
  templates,
  backgrounds,
  components,
  text,
  models3d,
  transitions,
}

class HtmlPresentationEditorPage extends StatefulWidget {
  const HtmlPresentationEditorPage({
    super.key,
    required this.controller,
  });

  final PresentationController controller;

  @override
  State<HtmlPresentationEditorPage> createState() =>
      _HtmlPresentationEditorPageState();
}

class _HtmlPresentationEditorPageState
    extends State<HtmlPresentationEditorPage> {
  late final TextEditingController _textController;
  _HtmlToolTab _activeTab = _HtmlToolTab.text;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncTextField);
    _textController = TextEditingController(
      text: widget.controller.selectedTextBlock?.text ?? '',
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncTextField);
    _textController.dispose();
    super.dispose();
  }

  void _syncTextField() {
    final nextText = widget.controller.selectedTextBlock?.text ?? '';
    if (_textController.text == nextText) {
      return;
    }

    _textController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  void _setTab(_HtmlToolTab tab) {
    if (_activeTab == tab) {
      return;
    }
    setState(() {
      _activeTab = tab;
    });
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _exportPresentation() async {
    await exportPresentationAsHtml(
      pages: widget.controller.pages.toList(growable: false),
      effectSettings: widget.controller.effectSettings,
    );
    _showSnack('Sunum tek HTML dosyasi olarak disa aktarildi.');
  }

  Future<void> _exportPdfPresentation() async {
    await exportPresentationAsPdfViaPrint(
      pages: widget.controller.pages.toList(growable: false),
      effectSettings: widget.controller.effectSettings,
    );
    _showSnack('PDF icin yazdirma penceresi acildi.');
  }

  Future<void> _saveProject() async {
    await savePresentationProjectAsJson(
      pages: widget.controller.pages.toList(growable: false),
      effectSettings: widget.controller.effectSettings,
    );
    _showSnack('Sutol proje dosyasi indirildi.');
  }

  Future<void> _loadProject() async {
    try {
      final project = await loadPresentationProjectFromJson();
      if (project == null) {
        return;
      }
      widget.controller.replaceDeck(
        project.pages,
        effectSettings: project.effectSettings,
      );
      _showSnack('Sutol proje dosyasi yuklendi.');
    } catch (_) {
      _showSnack('Proje dosyasi okunamadi.');
    }
  }

  Future<void> _openPresentationPreview() async {
    await requestPresentationFullscreen();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PresentationPreviewPage(
          controller: widget.controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
              widget.controller.undo,
          const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
              widget.controller.undo,
          const SingleActivator(LogicalKeyboardKey.keyY, control: true):
              widget.controller.redo,
          const SingleActivator(LogicalKeyboardKey.keyY, meta: true):
              widget.controller.redo,
          const SingleActivator(
            LogicalKeyboardKey.keyZ,
            control: true,
            shift: true,
          ): widget.controller.redo,
          const SingleActivator(
            LogicalKeyboardKey.keyZ,
            meta: true,
            shift: true,
          ): widget.controller.redo,
        },
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final pageCount = widget.controller.pages.length;
            final blockCount = widget.controller.selectedPageBlockCount;
            return Scaffold(
              body: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isStudioWide = constraints.maxWidth >= 1320;

                      if (isStudioWide) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                          child: Column(
                            children: <Widget>[
                              _HtmlStudioHeader(
                                pageCount: pageCount,
                                blockCount: blockCount,
                                onPreview: _openPresentationPreview,
                                onExport: _exportPresentation,
                                onExportPdf: _exportPdfPresentation,
                                onSave: _saveProject,
                                onLoad: _loadProject,
                                onUndo: widget.controller.undo,
                                onRedo: widget.controller.redo,
                                canUndo: widget.controller.canUndo,
                                canRedo: widget.controller.canRedo,
                                onAddText: widget.controller.addTextBlock,
                                onRemoveText: widget.controller.removeSelectedTextBlock,
                                canRemoveText: widget.controller.canRemoveTextBlock,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _HtmlStudioLayout(
                                  controller: widget.controller,
                                  textController: _textController,
                                  activeTab: _activeTab,
                                  onTabChanged: _setTab,
                                  onPreview: _openPresentationPreview,
                                  onExport: _exportPresentation,
                                  onExportPdf: _exportPdfPresentation,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: <Widget>[
                            _HtmlHeader(
                              pageCount: pageCount,
                              blockCount: blockCount,
                              onPreview: _openPresentationPreview,
                              onExport: _exportPresentation,
                              onExportPdf: _exportPdfPresentation,
                              onSave: _saveProject,
                              onLoad: _loadProject,
                              onUndo: widget.controller.undo,
                              onRedo: widget.controller.redo,
                              canUndo: widget.controller.canUndo,
                              canRedo: widget.controller.canRedo,
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final isWide =
                                      innerConstraints.maxWidth >= 1080;

                                  if (isWide) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 238,
                                          child: _HtmlPageSidebar(
                                            controller: widget.controller,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _HtmlWorkbench(
                                            controller: widget.controller,
                                            textController: _textController,
                                            activeTab: _activeTab,
                                            onTabChanged: _setTab,
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 214,
                                        child: _HtmlPageSidebar(
                                          controller: widget.controller,
                                          compact: true,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: _HtmlWorkbench(
                                          controller: widget.controller,
                                          textController: _textController,
                                          activeTab: _activeTab,
                                          onTabChanged: _setTab,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HtmlHeader extends StatelessWidget {
  const _HtmlHeader({
    required this.pageCount,
    required this.blockCount,
    required this.onPreview,
    required this.onExport,
    required this.onExportPdf,
    required this.onSave,
    required this.onLoad,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
  });

  final int pageCount;
  final int blockCount;
  final VoidCallback onPreview;
  final VoidCallback onExport;
  final VoidCallback onExportPdf;
  final VoidCallback onSave;
  final VoidCallback onLoad;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'HTML Sunum Duzenleme Alani',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context._htmlInk,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Arka plan, metin, akis ve efekt ayarlarini ayni sahnede duzenle.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context._htmlMuted,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
    final actions = <Widget>[
      _HeaderBadge(
        icon: Icons.layers_rounded,
        label: '$pageCount Sayfa',
      ),
      _HeaderBadge(
        icon: Icons.notes_rounded,
        label: '$blockCount Metin',
      ),
      _HeaderBadge(
        icon: Icons.html_rounded,
        label: 'HTML / CSS',
      ),
      _HistoryButtons(
        onUndo: onUndo,
        onRedo: onRedo,
        canUndo: canUndo,
        canRedo: canRedo,
      ),
      _HeaderAction(
        icon: Icons.slideshow_rounded,
        label: 'Sunum Modu',
        onTap: onPreview,
      ),
      _FileMenuButton(
        onSave: onSave,
        onLoad: onLoad,
        onExportHtml: onExport,
        onExportPdf: onExportPdf,
        
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: context._htmlInk,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: title),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (var i = 0; i < actions.length; i += 1) ...[
                            if (i > 0) const SizedBox(width: 10),
                            actions[i],
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: context._htmlInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: title),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: actions,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: context._htmlInk),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context._htmlInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context._htmlAccent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: context.sutolColors.onPrimary),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sutolColors.surface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _FileMenuAction {
  save,
  load,
  exportHtml,
  exportPdf,
}

class _FileMenuButton extends StatelessWidget {
  const _FileMenuButton({
    required this.onSave,
    required this.onLoad,
    required this.onExportHtml,
    required this.onExportPdf,
  });

  final VoidCallback onSave;
  final VoidCallback onLoad;
  final VoidCallback onExportHtml;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final background = context.sutolColors.surfaceSubtle;
    final foreground = context._htmlInk;
    final border = Border.all(color: context.sutolColors.outline);

    return PopupMenuButton<_FileMenuAction>(
      tooltip: 'Dosya islemleri',
      onSelected: (action) {
        switch (action) {
          case _FileMenuAction.save:
            onSave();
            break;
          case _FileMenuAction.load:
            onLoad();
            break;
          case _FileMenuAction.exportHtml:
            onExportHtml();
            break;
          case _FileMenuAction.exportPdf:
            onExportPdf();
            break;
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<_FileMenuAction>>[
        PopupMenuItem<_FileMenuAction>(
          value: _FileMenuAction.save,
          child: ListTile(
            leading: Icon(Icons.save_alt_rounded),
            title: Text('Projeyi Kaydet'),
          ),
        ),
        PopupMenuItem<_FileMenuAction>(
          value: _FileMenuAction.load,
          child: ListTile(
            leading: Icon(Icons.upload_file_rounded),
            title: Text('Proje Yukle'),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<_FileMenuAction>(
          value: _FileMenuAction.exportHtml,
          child: ListTile(
            leading: Icon(Icons.html_rounded),
            title: Text('HTML Disa Aktar'),
          ),
        ),
        PopupMenuItem<_FileMenuAction>(
          value: _FileMenuAction.exportPdf,
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_rounded),
            title: Text('PDF Olarak Yazdir'),
          ),
        ),
      ],
      child: Semantics(
        button: true,
        label: 'Dosya islemleri',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.folder_open_rounded, size: 18, color: foreground),
              const SizedBox(width: 8),
              Text(
                'Dosya',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryButtons extends StatelessWidget {
  const _HistoryButtons({
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    final background = context.sutolColors.surfaceSubtle;
    final borderColor = context.sutolColors.outline;
    final enabledColor = context._htmlInk;
    final disabledColor = context._htmlMuted.withValues(alpha: 0.52);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: 'Geri al',
            onPressed: canUndo ? onUndo : null,
            icon: Icon(
              Icons.undo_rounded,
              color: canUndo ? enabledColor : disabledColor,
            ),
          ),
          IconButton(
            tooltip: 'Yinele',
            onPressed: canRedo ? onRedo : null,
            icon: Icon(
              Icons.redo_rounded,
              color: canRedo ? enabledColor : disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HtmlStudioHeader extends StatelessWidget {
  const _HtmlStudioHeader({
    required this.pageCount,
    required this.blockCount,
    required this.onPreview,
    required this.onExport,
    required this.onExportPdf,
    required this.onSave,
    required this.onLoad,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
    required this.onAddText,
    required this.onRemoveText,
    required this.canRemoveText,
  });

  final int pageCount;
  final int blockCount;
  final VoidCallback onPreview;
  final VoidCallback onExport;
  final VoidCallback onExportPdf;
  final VoidCallback onSave;
  final VoidCallback onLoad;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onAddText;
  final VoidCallback onRemoveText;
  final bool canRemoveText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: <Widget>[
          _StudioHeaderIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Image.asset('assets/images/logo.png', height: 28),
          const SizedBox(width: 10),
          Text(
            'Sutol',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context._htmlInk,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.02,
                ),
          ),
          const SizedBox(width: 18),
          _FileMenuButton(
            onSave: onSave,
            onLoad: onLoad,
            onExportHtml: onExport,
            onExportPdf: onExportPdf,
            
          ),
          const SizedBox(width: 8),
          _HistoryButtons(
            onUndo: onUndo,
            onRedo: onRedo,
            canUndo: canUndo,
            canRedo: canRedo,
            
          ),
          const Spacer(),
          _ToolbarAction(
            icon: Icons.add_rounded,
            onTap: onAddText,
          ),
          const SizedBox(width: 8),
          _ToolbarAction(
            icon: Icons.delete_outline_rounded,
            onTap: canRemoveText ? onRemoveText : null,
            destructive: true,
          ),
          const SizedBox(width: 12),
          _StudioPreviewButton(onTap: onPreview),
          const SizedBox(width: 8),
          _StudioExportButton(onTap: onExport),
        ],
      ),
    );
  }
}

class _StudioHeaderIconButton extends StatelessWidget {
  const _StudioHeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sutolColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, color: context._htmlInk),
        ),
      ),
    );
  }
}

class _StudioHeaderMenuChip extends StatelessWidget {
  const _StudioHeaderMenuChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context._htmlInk,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _StudioHeaderInfoChip extends StatelessWidget {
  const _StudioHeaderInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: context._htmlInk),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context._htmlInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StudioPreviewButton extends StatelessWidget {
  const _StudioPreviewButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sutolColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.slideshow_rounded,
                color: context._htmlInk,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Sunum Modu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context._htmlInk,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudioExportButton extends StatelessWidget {
  const _StudioExportButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context._htmlAccent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.download_rounded,
                color: context.sutolColors.onPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'HTML Disa Aktar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.sutolColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlStudioLayout extends StatelessWidget {
  const _HtmlStudioLayout({
    required this.controller,
    required this.textController,
    required this.activeTab,
    required this.onTabChanged,
    required this.onPreview,
    required this.onExport,
    required this.onExportPdf,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onTabChanged;
  final VoidCallback onPreview;
  final VoidCallback onExport;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _HtmlToolRail(
          activeTab: activeTab,
          onTabChanged: onTabChanged,
          onPreview: onPreview,
          onExport: onExport,
          onExportPdf: onExportPdf,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _HtmlStageWorkspace(
            controller: controller,
            textController: textController,
            activeTab: activeTab,
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 320,
          child: _HtmlInspectorPanel(
            controller: controller,
            textController: textController,
            activeTab: activeTab,
          ),
        ),
      ],
    );
  }
}

class _HtmlToolRail extends StatelessWidget {
  const _HtmlToolRail({
    required this.activeTab,
    required this.onTabChanged,
    required this.onPreview,
    required this.onExport,
    required this.onExportPdf,
  });

  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onTabChanged;
  final VoidCallback onPreview;
  final VoidCallback onExport;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final primaryActions = <Widget>[
            _RailButton(
              label: 'Şablon',
              icon: Icons.dashboard_customize_rounded,
              isSelected: activeTab == _HtmlToolTab.templates,
              onTap: () => onTabChanged(_HtmlToolTab.templates),
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: 'Arka Plan',
              icon: Icons.wallpaper_rounded,
              isSelected: activeTab == _HtmlToolTab.backgrounds,
              onTap: () => onTabChanged(_HtmlToolTab.backgrounds),
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: 'Bilesen',
              icon: Icons.widgets_rounded,
              isSelected: activeTab == _HtmlToolTab.components,
              onTap: () => onTabChanged(_HtmlToolTab.components),
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: 'Metin',
              icon: Icons.text_fields_rounded,
              isSelected: activeTab == _HtmlToolTab.text,
              onTap: () => onTabChanged(_HtmlToolTab.text),
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: '3D Modeller',
              icon: Icons.view_in_ar_rounded,
              isSelected: activeTab == _HtmlToolTab.models3d,
              onTap: () => onTabChanged(_HtmlToolTab.models3d),
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: 'Geçişler',
              icon: Icons.animation_rounded,
              isSelected: activeTab == _HtmlToolTab.transitions,
              onTap: () => onTabChanged(_HtmlToolTab.transitions),
            ),
          ];
          final secondaryActions = <Widget>[
            _RailButton(
              label: 'HTML',
              icon: Icons.html_rounded,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: 'Sunum',
              icon: Icons.slideshow_rounded,
              accent: const Color(0xFFEFFDFD),
              iconColor: const Color(0xFF0891B2),
              onTap: onPreview,
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: 'Disa Aktar',
              icon: Icons.download_rounded,
              accent: const Color(0xFFEEF5FF),
              iconColor: context._htmlAccent,
              onTap: onExport,
            ),
            const SizedBox(height: 10),
            _RailButton(
              label: 'PDF',
              icon: Icons.picture_as_pdf_rounded,
              accent: const Color(0xFFFFF6EE),
              iconColor: const Color(0xFFD97706),
              onTap: onExportPdf,
            ),
          ];

          if (constraints.maxHeight < 760) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ...primaryActions,
                  const SizedBox(height: 10),
                  ...secondaryActions,
                ],
              ),
            );
          }

          return Column(
            children: <Widget>[
              ...primaryActions,
              const Spacer(),
              ...secondaryActions,
            ],
          );
        },
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.accent,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? accent;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        accent ?? (isSelected ? const Color(0xFFEDF4FF) : Colors.transparent);
    final borderColor =
        isSelected ? const Color(0xFFD4E4FF) : Colors.transparent;
    final effectiveIconColor =
        iconColor ?? (isSelected ? context._htmlAccent : context._htmlMuted);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, color: effectiveIconColor, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? context._htmlInk : context._htmlMuted,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlInspectorPanel extends StatelessWidget {
  const _HtmlInspectorPanel({
    required this.controller,
    required this.textController,
    required this.activeTab,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _studioPanelTitle(activeTab),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context._htmlInk,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _studioPanelSubtitle(activeTab, controller),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context._htmlMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InspectorStatChip(
                icon: Icons.layers_rounded,
                label: '${controller.pages.length} Sayfa',
              ),
              _InspectorStatChip(
                icon: Icons.select_all_rounded,
                label: '${controller.selectedItemCount} Secili',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: activeTab == _HtmlToolTab.text
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HtmlTextControls(
                          controller: controller,
                          textController: textController,
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        _HtmlTextEffectControls(controller: controller),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _HtmlControlPanel(
                        key: ValueKey<_HtmlToolTab>(activeTab),
                        controller: controller,
                        textController: textController,
                        activeTab: activeTab,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InspectorStatChip extends StatelessWidget {
  const _InspectorStatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: context._htmlInk),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context._htmlInk,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _HtmlStageWorkspace extends StatelessWidget {
  const _HtmlStageWorkspace({
    required this.controller,
    required this.textController,
    required this.activeTab,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _HtmlStageCard(
                    controller: controller,
                  ),
                ),
                const SizedBox(height: 14),
                _HtmlPageFilmstrip(
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HtmlPageFilmstrip extends StatelessWidget {
  const _HtmlPageFilmstrip({
    required this.controller,
  });

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 138,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.sutolColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.sutolColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sayfalar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.selectedIndex + 1} / ${controller.pages.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context._htmlMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.pages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _HtmlStudioPageThumb(
                    page: page,
                    index: index,
                    isSelected: index == controller.selectedIndex,
                    onTap: () => controller.selectPage(index),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: <Widget>[
              _SidebarAction(
                icon: Icons.add_rounded,
                onTap: controller.addPage,
              ),
              const SizedBox(height: 8),
              _SidebarAction(
                icon: Icons.remove_rounded,
                onTap: controller.canRemovePage
                    ? controller.removeSelectedPage
                    : null,
                subtle: true,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StudioHeaderInfoChip(
                icon: Icons.layers_rounded,
                label: '${controller.pages.length} Sayfa',
              ),
              const SizedBox(height: 8),
              _StudioHeaderInfoChip(
                icon: Icons.text_fields_rounded,
                label: '${controller.selectedPageBlockCount} Metin',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HtmlStudioPageThumb extends StatelessWidget {
  const _HtmlStudioPageThumb({
    required this.page,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final PresentationPage page;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Material(
        color: isSelected ? const Color(0xFFEEF5FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? context._htmlAccent : context.sutolColors.outline,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: IgnorePointer(
                      child: PresentationPageCanvas(
                        page: page,
                        showHint: false,
                        showSelectionBorder: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${index + 1}. Sayfa',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context._htmlInk,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HtmlPageSidebar extends StatelessWidget {
  const _HtmlPageSidebar({
    required this.controller,
    this.compact = false,
  });

  final PresentationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context._htmlPanel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.sutolColors.outline),
        boxShadow: context.elevation2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Sayfalar',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _SidebarAction(
                icon: Icons.add_rounded,
                onTap: controller.addPage,
              ),
              const SizedBox(width: 8),
              _SidebarAction(
                icon: Icons.remove_rounded,
                onTap: controller.canRemovePage
                    ? controller.removeSelectedPage
                    : null,
                subtle: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: compact
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.pages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return SizedBox(
                        width: 194,
                        child: _HtmlPageCard(
                          page: page,
                          index: index,
                          isSelected: index == controller.selectedIndex,
                          onTap: () => controller.selectPage(index),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    itemCount: controller.pages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return _HtmlPageCard(
                        page: page,
                        index: index,
                        isSelected: index == controller.selectedIndex,
                        onTap: () => controller.selectPage(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarAction extends StatelessWidget {
  const _SidebarAction({
    required this.icon,
    required this.onTap,
    this.subtle = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: subtle ? context.sutolColors.surfaceSubtle : context.sutolColors.surfaceTinted,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Opacity(
          opacity: onTap == null ? 0.45 : 1,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: context._htmlInk),
          ),
        ),
      ),
    );
  }
}

class _HtmlPageCard extends StatelessWidget {
  const _HtmlPageCard({
    required this.page,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final PresentationPage page;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F6FF) : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? context._htmlAccent : context.sutolColors.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Sayfa ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: IgnorePointer(
                  child: PresentationPageCanvas(
                    page: page,
                    showHint: false,
                    showSelectionBorder: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HtmlWorkbench extends StatelessWidget {
  const _HtmlWorkbench({
    required this.controller,
    required this.textController,
    required this.activeTab,
    required this.onTabChanged,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: context._htmlPanel,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.sutolColors.outline),
        boxShadow: context.elevation2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _HtmlTopToolbar(
            controller: controller,
            textController: textController,
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _HtmlStageCard(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _HtmlTopToolbar extends StatelessWidget {
  const _HtmlTopToolbar({
    required this.controller,
    required this.textController,
    required this.activeTab,
    required this.onTabChanged,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceTinted,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1180;
          final controls = AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _HtmlControlPanel(
              key: ValueKey<_HtmlToolTab>(activeTab),
              controller: controller,
              textController: textController,
              activeTab: activeTab,
            ),
          );

          if (isWide) {
            return Row(
              children: <Widget>[
                SizedBox(
                  width: 376,
                  child: _HtmlTabStrip(
                    activeTab: activeTab,
                    onTabChanged: onTabChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 42,
                  color: context.sutolColors.outline,
                ),
                const SizedBox(width: 12),
                Expanded(child: controls),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _HtmlTabStrip(
                activeTab: activeTab,
                onTabChanged: onTabChanged,
              ),
              const SizedBox(height: 10),
              controls,
            ],
          );
        },
      ),
    );
  }
}

class _HtmlTabStrip extends StatelessWidget {
  const _HtmlTabStrip({
    required this.activeTab,
    required this.onTabChanged,
  });

  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.sutolColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _HtmlTabButton(
              label: 'Şablonlar',
              icon: Icons.dashboard_customize_rounded,
              isSelected: activeTab == _HtmlToolTab.templates,
              onTap: () => onTabChanged(_HtmlToolTab.templates),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: 'Arka Planlar',
              icon: Icons.wallpaper_rounded,
              isSelected: activeTab == _HtmlToolTab.backgrounds,
              onTap: () => onTabChanged(_HtmlToolTab.backgrounds),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: 'Bilesenler',
              icon: Icons.widgets_rounded,
              isSelected: activeTab == _HtmlToolTab.components,
              onTap: () => onTabChanged(_HtmlToolTab.components),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: 'Metin',
              icon: Icons.text_fields_rounded,
              isSelected: activeTab == _HtmlToolTab.text,
              onTap: () => onTabChanged(_HtmlToolTab.text),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: '3D Modeller',
              icon: Icons.view_in_ar_rounded,
              isSelected: activeTab == _HtmlToolTab.models3d,
              onTap: () => onTabChanged(_HtmlToolTab.models3d),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: 'Geçişler',
              icon: Icons.animation_rounded,
              isSelected: activeTab == _HtmlToolTab.transitions,
              onTap: () => onTabChanged(_HtmlToolTab.transitions),
            ),
          ],
        ),
      ),
    );
  }
}

class _HtmlTabButton extends StatelessWidget {
  const _HtmlTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? context._htmlAccent : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : context._htmlInk,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : context._htmlInk,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlControlPanel extends StatelessWidget {
  const _HtmlControlPanel({
    super.key,
    required this.controller,
    required this.textController,
    required this.activeTab,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case _HtmlToolTab.templates:
        return _HtmlTemplateControls(controller: controller);
      case _HtmlToolTab.backgrounds:
        return _HtmlBackgroundControls(
          controller: controller,
        );
      case _HtmlToolTab.components:
        return _HtmlComponentControls(
          controller: controller,
        );
      case _HtmlToolTab.text:
        return _HtmlTextControls(
          controller: controller,
          textController: textController,
        );
      case _HtmlToolTab.models3d:
        return _Html3DModelControls(controller: controller);
      case _HtmlToolTab.transitions:
        return _HtmlTransitionControls(controller: controller);
    }
  }
}

class _Html3DModelControls extends StatelessWidget {
  const _Html3DModelControls({required this.controller});

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    final selectedModelId = controller.selectedComponentBlock?.modelAssetId;
    final canRemoveModel = selectedModelId != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.sutolColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _ToolbarBadge(
                icon: Icons.view_in_ar_rounded,
                label: '3D Model Kütüphanesi',
              ),
              const SizedBox(width: 10),
              _ToolbarChip(label: '${presentation3DModelCatalog.length} model'),
              const Spacer(),
              _ToolbarAction(
                icon: Icons.delete_outline_rounded,
                onTap: canRemoveModel
                    ? controller.removeSelectedComponentBlock
                    : null,
                destructive: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final model in presentation3DModelCatalog)
            _Model3DLibraryCard(
              model: model,
              isSelected: selectedModelId == model.id,
              onAdd: () => controller.add3DModelBlock(model),
            ),
        ],
      ),
    );
  }
}

class _HtmlTransitionControls extends StatelessWidget {
  const _HtmlTransitionControls({required this.controller});

  final PresentationController controller;

  static const _popularTransitions = <PresentationTransitionKind>[
    PresentationTransitionKind.smooth,
    PresentationTransitionKind.fade,
    PresentationTransitionKind.slide,
    PresentationTransitionKind.wipe,
    PresentationTransitionKind.split,
    PresentationTransitionKind.reveal,
    PresentationTransitionKind.cover,
    PresentationTransitionKind.uncover,
    PresentationTransitionKind.zoom,
    PresentationTransitionKind.flip,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final cardWidth = columns == 2
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Popüler Geçişler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              'Sunumlarda en sık tercih edilen 10 geçişten birini seç.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context._htmlMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final kind in _popularTransitions)
                  SizedBox(
                    width: cardWidth,
                    child: _TransitionLibraryCard(
                      kind: kind,
                      isSelected:
                          controller.effectSettings.transitionKind == kind,
                      onTap: () {
                        controller.updateTransitionKind(kind);
                        controller.updateTransitionDuration(
                          kind == PresentationTransitionKind.smooth
                              ? 1400
                              : 620,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TransitionLibraryCard extends StatelessWidget {
  const _TransitionLibraryCard({
    required this.kind,
    required this.isSelected,
    required this.onTap,
  });

  final PresentationTransitionKind kind;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF0F6FF) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? context._htmlAccent : context.sutolColors.outline,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF0B7BFF), Color(0xFF7047EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  presentationTransitionIcon(kind),
                  color: context.sutolColors.surface,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      presentationTransitionLabel(kind),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      presentationTransitionSubtitle(kind),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context._htmlMuted,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: context._htmlAccent,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Model3DLibraryCard extends StatelessWidget {
  const _Model3DLibraryCard({
    required this.model,
    required this.isSelected,
    required this.onAdd,
  });

  final Presentation3DModelAsset model;
  final bool isSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? context.sutolColors.primaryLight : context.sutolColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? context.sutolColors.primary : context.sutolColors.outline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 68,
                height: 58,
                decoration: BoxDecoration(
                  color: context.sutolColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.sutolColors.outlineVariant),
                ),
                child: Icon(
                  model.icon,
                  color: context.sutolColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${model.category} · ${(model.byteSize / (1024 * 1024)).toStringAsFixed(1)} MB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context._htmlMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      model.hasAnimations
                          ? 'Animasyonlu GLB'
                          : 'Etkileşimli, otomatik dönen GLB',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF247BCE),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.add_circle_rounded,
                color: context._htmlAccent,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlTemplateControls extends StatelessWidget {
  const _HtmlTemplateControls({required this.controller});

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    final templates = PresentationTemplate.values
        .where((template) => template != PresentationTemplate.automatic)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _ToolbarBadge(
          icon: Icons.dashboard_customize_rounded,
          label: 'Sunum Şablonları',
        ),
        const SizedBox(height: 10),
        Text(
          'Şablon seçimi tüm slaytlara uygulanır. Metinleriniz ve bileşenleriniz korunur.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context._htmlMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 14),
        for (final template in templates) ...<Widget>[
          _TemplatePresetCard(
            template: template,
            isSelected: controller.pages.every(
              (page) =>
                  page.backgroundKind == presentationTemplateBackground(template),
            ),
            onTap: () {
              final background = presentationTemplateBackground(template);
              if (background != null) {
                controller.updateAllPageBackgrounds(background);
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TemplatePresetCard extends StatelessWidget {
  const _TemplatePresetCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final PresentationTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = presentationTemplateBackground(template)!;
    final previewColors = presentationBackgroundPreviewColors(background);
    return Material(
      color: isSelected ? const Color(0xFFF0F6FF) : context.sutolColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? context._htmlAccent : context.sutolColors.outline,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: LinearGradient(colors: previewColors),
                ),
                child: Icon(
                  presentationBackgroundIcon(background),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      presentationTemplateLabel(template),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      presentationTemplateDescription(template),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context._htmlMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                color: context._htmlAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlBackgroundControls extends StatelessWidget {
  const _HtmlBackgroundControls({
    required this.controller,
  });

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedPage.backgroundKind;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final columns = constraints.maxWidth >= 760
            ? 4
            : constraints.maxWidth >= 520
                ? 3
                : constraints.maxWidth >= 330
                    ? 2
                    : 1;
        final cardWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (gap * (columns - 1))) / columns;
        final lightDefinitions = presentationBackgroundLibrary
            .where(
                (definition) => !presentationBackgroundIsDark(definition.kind))
            .toList(growable: false);
        final topicDefinitions = presentationBackgroundLibrary
            .where(
                (definition) => presentationBackgroundIsDark(definition.kind))
            .toList(growable: false);

        Widget backgroundGroup(
          String title,
          IconData icon,
          List<PresentationBackgroundDefinition> definitions,
        ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ToolbarBadge(icon: icon, label: title),
              const SizedBox(height: 10),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (final definition in definitions)
                    SizedBox(
                      width: cardWidth,
                      child: _BackgroundPresetCard(
                        kind: definition.kind,
                        isSelected: selected == definition.kind,
                        onTap: () => controller
                            .updateSelectedBackground(definition.kind),
                      ),
                    ),
                ],
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _ToolbarBadge(
              icon: Icons.wallpaper_rounded,
              label: 'Arka Plan Kütüphanesi',
            ),
            const SizedBox(height: 14),
            backgroundGroup(
              'Açık ve Ferah',
              Icons.light_mode_rounded,
              lightDefinitions,
            ),
            const SizedBox(height: 18),
            backgroundGroup(
              'Koyu Konu Temaları',
              Icons.dark_mode_rounded,
              topicDefinitions,
            ),
          ],
        );
      },
    );
  }
}

class _BackgroundPresetCard extends StatelessWidget {
  const _BackgroundPresetCard({
    required this.kind,
    required this.isSelected,
    required this.onTap,
  });

  final PresentationBackgroundKind kind;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = presentationBackgroundPreviewColors(kind);

    return Material(
      color: context.sutolColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? context._htmlAccent : context.sutolColors.outline,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1F0B7BFF),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _BackgroundPresetPreview(
                    kind: kind,
                    colors: colors,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Icon(
                    presentationBackgroundIcon(kind),
                    size: 16,
                    color: isSelected ? context._htmlAccent : context._htmlMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      presentationBackgroundLabel(kind),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                presentationBackgroundCategory(kind),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context._htmlMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundPresetPreview extends StatelessWidget {
  const _BackgroundPresetPreview({
    required this.kind,
    required this.colors,
  });

  final PresentationBackgroundKind kind;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _BackgroundPreviewPainter(kind: kind),
          ),
        ),
      ],
    );
  }
}

class _BackgroundPreviewPainter extends CustomPainter {
  const _BackgroundPreviewPainter({
    required this.kind,
  });

  final PresentationBackgroundKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.16);

    for (var x = w / 8; x < w; x += w / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }
    for (var y = h / 5; y < h; y += h / 5) {
      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }

    _drawPackPreview(canvas, size, kind);
  }

  void _drawPackPreview(
      Canvas canvas, Size size, PresentationBackgroundKind kind) {
    final accent = presentationBackgroundPreviewColors(kind).last;
    switch (presentationBackgroundCategory(kind)) {
      case 'Teknoloji':
        _drawStarNetwork(canvas, size, accent);
      case 'Matematik':
        _drawOrbit(canvas, size, accent);
      case 'Kimya':
        _drawBioStars(canvas, size);
      case 'Cografya':
        _drawGeoPreview(canvas, size, accent);
      default:
        _drawOrbit(canvas, size, accent);
    }
  }

  void _drawGeoPreview(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.70);
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.70)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.46,
          size.width * 0.48, size.height * 0.66)
      ..quadraticBezierTo(size.width * 0.66, size.height * 0.84,
          size.width * 0.86, size.height * 0.54);
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      8,
      Paint()..color = color.withValues(alpha: 0.78),
    );
  }

  void _drawOrbit(Canvas canvas, Size size, Color color) {
    final center = Offset(size.width * 0.68, size.height * 0.38);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: 0.72);
    for (final scale in <double>[0.75, 1.0, 1.25]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(scale * 0.65);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * 0.35 * scale,
          height: size.height * 0.18 * scale,
        ),
        paint,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, 4, Paint()..color = color);
  }

  void _drawStarNetwork(Canvas canvas, Size size, Color color) {
    final points = <Offset>[
      Offset(size.width * 0.18, size.height * 0.25),
      Offset(size.width * 0.42, size.height * 0.42),
      Offset(size.width * 0.64, size.height * 0.24),
      Offset(size.width * 0.82, size.height * 0.62),
      Offset(size.width * 0.28, size.height * 0.72),
    ];
    final line = Paint()
      ..color = color.withValues(alpha: 0.32)
      ..strokeWidth = 1.1;
    for (var i = 0; i < points.length - 1; i += 1) {
      canvas.drawLine(points[i], points[i + 1], line);
    }
    final dot = Paint()..color = color.withValues(alpha: 0.9);
    for (final point in points) {
      canvas.drawCircle(point, 2.6, dot);
    }
  }

  void _drawBioStars(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFF8CE0D1).withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.36, size.height * 0.48),
        width: size.width * 0.28,
        height: size.height * 0.44,
      ),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.67, size.height * 0.38),
      3,
      Paint()..color = const Color(0xFFFFD166),
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPreviewPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}

class _HtmlComponentControls extends StatelessWidget {
  const _HtmlComponentControls({
    required this.controller,
  });

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    final categories = presentationComponentCategories();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.sutolColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _ToolbarBadge(
                icon: Icons.widgets_rounded,
                label: 'Bilesen Kutuphanesi',
              ),
              const SizedBox(width: 10),
              _ToolbarChip(
                  label: '${presentationComponentDefinitions.length} bilesen'),
              const Spacer(),
              _ToolbarAction(
                icon: Icons.delete_outline_rounded,
                onTap: controller.canRemoveComponentBlock
                    ? controller.removeSelectedComponentBlock
                    : null,
                destructive: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 420,
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final definitions =
                    presentationComponentDefinitionsForCategory(category);
                return _ComponentCategorySection(
                  category: category,
                  definitions: definitions,
                  controller: controller,
                  initiallyExpanded: index == 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentCategorySection extends StatefulWidget {
  const _ComponentCategorySection({
    required this.category,
    required this.definitions,
    required this.controller,
    required this.initiallyExpanded,
  });

  final String category;
  final List<PresentationComponentDefinition> definitions;
  final PresentationController controller;
  final bool initiallyExpanded;

  @override
  State<_ComponentCategorySection> createState() =>
      _ComponentCategorySectionState();
}

class _ComponentCategorySectionState extends State<_ComponentCategorySection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.sutolColors.primaryLight),
      ),
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: (expanded) {
          if (_expanded != expanded) {
            setState(() => _expanded = expanded);
          }
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        leading: Icon(
          widget.definitions.isEmpty
              ? Icons.widgets_rounded
              : presentationComponentIcon(widget.definitions.first.kind),
          color: context._htmlAccent,
        ),
        title: Text(
          widget.category,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context._htmlInk,
                fontWeight: FontWeight.w900,
              ),
        ),
        subtitle: Text(
          '${widget.definitions.length} bilesen',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context._htmlMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        children: _expanded
            ? <Widget>[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 640
                        ? (constraints.maxWidth - 10) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.definitions
                          .map(
                            (definition) => SizedBox(
                              width: cardWidth,
                              child: _ComponentLibraryCard(
                                definition: definition,
                                onAdd: () =>
                                    widget.controller.addComponentBlock(
                                  definition.kind,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
              ]
            : const <Widget>[],
      ),
    );
  }
}

class _ComponentLibraryCard extends StatelessWidget {
  const _ComponentLibraryCard({
    required this.definition,
    required this.onAdd,
  });

  final PresentationComponentDefinition definition;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final subtitle = definition.tags.isEmpty
        ? definition.description
        : definition.tags.take(5).join(', ');

    return Material(
      color: context.sutolColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.sutolColors.outline),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 58,
                height: 46,
                decoration: BoxDecoration(
                  color: context.sutolColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.sutolColors.outlineVariant),
                ),
                child: Icon(
                  presentationComponentIcon(definition.kind),
                  color: context._htmlAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      definition.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context._htmlMuted,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.add_circle_rounded,
                color: context._htmlAccent,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarBadge extends StatelessWidget {
  const _ToolbarBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceTinted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sutolColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: context.sutolColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context._htmlInk,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  const _ToolbarChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context._htmlInk,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: destructive ? const Color(0xFFFFF4F4) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Opacity(
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: destructive
                    ? const Color(0xFFFFD8D8)
                    : context.sutolColors.outline,
              ),
            ),
            child: Icon(
              icon,
              color: destructive ? const Color(0xFFD13A3A) : context._htmlInk,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _HtmlTextEffectControls extends StatelessWidget {
  const _HtmlTextEffectControls({required this.controller});

  final PresentationController controller;

  static const List<_TextColorOption> _colors = <_TextColorOption>[
    _TextColorOption(label: 'Otomatik', hex: null, color: Color(0xFFFFFFFF)),
    _TextColorOption(label: 'Beyaz', hex: '#F8FBFF', color: Color(0xFFF8FBFF)),
    _TextColorOption(
        label: 'Camgöbeği', hex: '#67E8F9', color: Color(0xFF67E8F9)),
    _TextColorOption(label: 'Mavi', hex: '#3B82F6', color: Color(0xFF3B82F6)),
    _TextColorOption(label: 'Mor', hex: '#A855F7', color: Color(0xFFA855F7)),
    _TextColorOption(label: 'Sarı', hex: '#FBBF24', color: Color(0xFFFBBF24)),
    _TextColorOption(
        label: 'Turuncu', hex: '#FB923C', color: Color(0xFFFB923C)),
    _TextColorOption(
        label: 'Kırmızı', hex: '#F87171', color: Color(0xFFF87171)),
    _TextColorOption(label: 'Yeşil', hex: '#22C55E', color: Color(0xFF22C55E)),
    _TextColorOption(label: 'Nane', hex: '#34D399', color: Color(0xFF34D399)),
  ];

  @override
  Widget build(BuildContext context) {
    final block = controller.selectedTextBlock;
    final enabled = block != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _ToolbarBadge(
          icon: Icons.auto_awesome_rounded,
          label: 'Metin Efektleri',
        ),
        const SizedBox(height: 18),
        _ControlFieldShell(
          label: 'Animasyon',
          child: DropdownButtonFormField<PresentationTextAnimation>(
            key: ValueKey<String>(
              'animation-${block?.textAnimation.name ?? 'none'}',
            ),
            initialValue: block?.textAnimation,
            onChanged: !enabled
                ? null
                : (value) {
                    if (value != null) {
                      controller.updateSelectedTextAnimation(value);
                    }
                  },
            dropdownColor: context.sutolColors.surface,
            borderRadius: BorderRadius.circular(14),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            style: TextStyle(
              color: context._htmlInk,
              fontWeight: FontWeight.w700,
            ),
            decoration: _inputDecoration('Animasyon seç'),
            items: PresentationTextAnimation.values
                .map(
                  (animation) => DropdownMenuItem<PresentationTextAnimation>(
                    value: animation,
                    child: Text(
                      _textAnimationLabel(animation),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Renk',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context._htmlInk,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: _colors
              .map(
                (option) => _TextColorSwatch(
                  option: option,
                  isSelected: enabled && block.textColorHex == option.hex,
                  enabled: enabled,
                  onTap: () => controller.updateSelectedTextColor(option.hex),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: context.sutolColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.sutolColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.brightness_7_rounded,
                    size: 18,
                    color: context._htmlAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Parlaklık',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Text(
                    enabled ? '${(block.glowIntensity * 100).round()}%' : '—',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context._htmlMuted,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              Slider(
                value: block?.glowIntensity ?? 0,
                min: 0,
                max: 2,
                divisions: 20,
                onChanged:
                    enabled ? controller.updateSelectedGlowIntensity : null,
              ),
              Text(
                '0% parlama olmadan, 200% en güçlü parlama ile gösterir.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context._htmlMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextColorOption {
  const _TextColorOption({
    required this.label,
    required this.hex,
    required this.color,
  });

  final String label;
  final String? hex;
  final Color color;
}

class _TextColorSwatch extends StatelessWidget {
  const _TextColorSwatch({
    required this.option,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final _TextColorOption option;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: option.label,
      child: Opacity(
        opacity: enabled ? 1 : 0.42,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: option.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? context._htmlAccent : context.sutolColors.outline,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x330B7BFF),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: option.hex == null
                ? Icon(
                    Icons.auto_awesome_rounded,
                    color: context._htmlInk,
                    size: 18,
                  )
                : isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: option.color.computeLuminance() > 0.55
                            ? context._htmlInk
                            : Colors.white,
                        size: 20,
                      )
                    : null,
          ),
        ),
      ),
    );
  }
}

class _HtmlTextControls extends StatelessWidget {
  const _HtmlTextControls({
    required this.controller,
    required this.textController,
  });

  final PresentationController controller;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final selectedTextBlock = controller.selectedTextBlock;
    final selectedTextCount = controller.selectedTextSelectionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _ToolbarBadge(
          icon: Icons.text_fields_rounded,
          label: 'Metin Katmanı',
        ),
        if (selectedTextCount > 1) ...[
          const SizedBox(height: 8),
          _ToolbarChip(label: '$selectedTextCount metin seçili'),
        ],
        const SizedBox(height: 12),
        _TextFieldControl(
          controller: textController,
          enabled: selectedTextBlock != null,
          onChanged: controller.updateSelectedText,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _TypeDropdownControl(
                value: selectedTextBlock?.textStyle,
                onChanged: selectedTextBlock == null
                    ? null
                    : (value) {
                        if (value != null) {
                          controller.updateSelectedTextStyle(value);
                        }
                      },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _SizeStepperControl(
                value: selectedTextBlock?.fontSize.round(),
                onDecrease: selectedTextBlock == null
                    ? null
                    : () => controller.updateSelectedFontSize(
                          math.max(18, selectedTextBlock.fontSize - 2),
                        ),
                onIncrease: selectedTextBlock == null
                    ? null
                    : () => controller.updateSelectedFontSize(
                          math.min(120, selectedTextBlock.fontSize + 2),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TextFieldControl extends StatelessWidget {
  const _TextFieldControl({
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ControlFieldShell(
      label: 'Metin',
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        style: TextStyle(
          color: context._htmlInk,
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration('Buraya metin yazin'),
      ),
    );
  }
}

class _TypeDropdownControl extends StatelessWidget {
  const _TypeDropdownControl({
    required this.value,
    required this.onChanged,
  });

  final PresentationTextStyle? value;
  final ValueChanged<PresentationTextStyle?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _ControlFieldShell(
      label: 'Yazı Stili',
      child: DropdownButtonFormField<PresentationTextStyle>(
        key: ValueKey<String>('text-style-${value?.name ?? 'none'}'),
        initialValue: value,
        onChanged: onChanged,
        isDense: true,
        dropdownColor: context.sutolColors.surface,
        borderRadius: BorderRadius.circular(14),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: TextStyle(
          color: context._htmlInk,
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration('Yazı stili'),
        items: PresentationTextStyle.values
            .map(
              (style) => DropdownMenuItem<PresentationTextStyle>(
                value: style,
                child: Text(
                  _htmlTextStyleLabel(style),
                  style: TextStyle(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _SizeStepperControl extends StatelessWidget {
  const _SizeStepperControl({
    required this.value,
    this.onDecrease,
    this.onIncrease,
  });

  final int? value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return _ControlFieldShell(
      label: 'Boyut',
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.sutolColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.sutolColors.outline),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onDecrease,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.remove_rounded, color: context._htmlInk, size: 20),
            ),
            Expanded(
              child: Center(
                child: Text(
                  value?.toString() ?? '-',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrease,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.add_rounded, color: context._htmlInk, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlFieldShell extends StatelessWidget {
  const _ControlFieldShell({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context._htmlInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        child,
      ],
    );
  }
}

class _HtmlStageCard extends StatelessWidget {
  const _HtmlStageCard({
    required this.controller,
  });

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = _shouldReduceHtmlMotion(
      context,
      controller.effectSettings,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = math.max(0.0, constraints.maxWidth - 8);
          final availableHeight = math.max(0.0, constraints.maxHeight - 8);
          final stageWidth = math.min(
            availableWidth,
            availableHeight * (16 / 9),
          );
          final stageHeight = stageWidth / (16 / 9);

          return Center(
            child: SizedBox(
              width: stageWidth,
              height: stageHeight,
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : Duration(
                        milliseconds:
                            controller.effectSettings.transitionDurationMs,
                      ),
                transitionBuilder: (child, animation) =>
                    _buildHtmlPreviewTransition(
                  kind: controller.effectSettings.transitionKind,
                  animation: animation,
                  reduceMotion: reduceMotion,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey<String>('stage-${controller.selectedPage.id}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        HtmlPageStage(
                          key: ValueKey<String>(
                              'html-${controller.selectedPage.id}'),
                          page: controller.selectedPage,
                          selectedTextBlockId: controller.selectedTextBlockId,
                          selectedComponentBlockId:
                              controller.selectedComponentBlockId,
                          renderMode: reduceMotion
                              ? HtmlStageRenderMode.snapshot
                              : HtmlStageRenderMode.preview,
                        ),
                        PresentationPageCanvas(
                          page: controller.selectedPage,
                          selectedTextBlockId: controller.selectedTextBlockId,
                          selectedTextBlockIds: controller.selectedTextBlockIds,
                          selectedComponentBlockId:
                              controller.selectedComponentBlockId,
                          selectedComponentBlockIds:
                              controller.selectedComponentBlockIds,
                          interactive: true,
                          showHint: true,
                          showSurface: false,
                          showEmptyState: false,
                          textOpacity: 0,
                          onSelectTextBlock: controller.selectTextBlock,
                          onSelectComponentBlock:
                              controller.selectComponentBlock,
                          onDragSelectedText: controller.moveSelectedText,
                          onInlineTextChanged: controller.updateSelectedText,
                          onResizeSelectedTextWidth:
                              controller.resizeSelectedTextWidth,
                          onResizeSelectedComponent:
                              controller.resizeSelectedComponentByHandle,
                          onMarqueeSelectionChanged: ({
                            required textBlockIds,
                            required componentBlockIds,
                          }) =>
                              controller.selectItems(
                            textBlockIds: textBlockIds,
                            componentBlockIds: componentBlockIds,
                          ),
                          onClearSelection: controller.clearSelection,
                          onSecondaryTapTextBlock: (itemId, globalPosition) {
                            if (!controller.selectedTextBlockIds
                                .contains(itemId)) {
                              controller.selectTextBlock(itemId);
                            }
                            _showStageItemContextMenu(
                              context,
                              controller,
                              globalPosition,
                            );
                          },
                          onSecondaryTapComponentBlock:
                              (itemId, globalPosition) {
                            if (!controller.selectedComponentBlockIds
                                .contains(itemId)) {
                              controller.selectComponentBlock(itemId);
                            }
                            _showStageItemContextMenu(
                              context,
                              controller,
                              globalPosition,
                            );
                          },
                          onToggleModelOrbit: (itemId) {
                            if (controller.selectedComponentBlockId != itemId) {
                              controller.selectComponentBlock(itemId);
                            }
                            controller.toggleSelectedModelOrbit();
                          },
                          onRotateModel: (itemId, delta) {
                            if (controller.selectedComponentBlockId != itemId) {
                              controller.selectComponentBlock(itemId);
                            }
                            controller.rotateSelectedModel(delta);
                          },
                          onBeginModelOrbit: (itemId) {
                            if (controller.selectedComponentBlockId != itemId) {
                              controller.selectComponentBlock(itemId);
                            }
                            controller.beginSelectedModelOrbitGesture();
                          },
                          onEndModelOrbit:
                              controller.endSelectedModelOrbitGesture,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _StageItemContextAction {
  copy,
  paste,
  duplicate,
  delete,
}

Future<void> _showStageItemContextMenu(
  BuildContext context,
  PresentationController controller,
  Offset globalPosition,
) async {
  final overlay = Overlay.of(context).context.findRenderObject();
  if (overlay is! RenderBox) {
    return;
  }

  final action = await showMenu<_StageItemContextAction>(
    context: context,
    color: context.sutolColors.surface,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFDCE5F1)),
    ),
    position: RelativeRect.fromRect(
      Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 1, 1),
      Offset.zero & overlay.size,
    ),
    items: <PopupMenuEntry<_StageItemContextAction>>[
      const PopupMenuItem<_StageItemContextAction>(
        value: _StageItemContextAction.copy,
        child: _StageContextMenuRow(
          icon: Icons.content_copy_rounded,
          label: 'Kopyala',
        ),
      ),
      PopupMenuItem<_StageItemContextAction>(
        value: controller.canPasteItems ? _StageItemContextAction.paste : null,
        enabled: controller.canPasteItems,
        child: const _StageContextMenuRow(
          icon: Icons.content_paste_rounded,
          label: 'Yapıştır',
        ),
      ),
      const PopupMenuItem<_StageItemContextAction>(
        value: _StageItemContextAction.duplicate,
        child: _StageContextMenuRow(
          icon: Icons.control_point_duplicate_rounded,
          label: 'Çoğalt',
        ),
      ),
      const PopupMenuDivider(),
      const PopupMenuItem<_StageItemContextAction>(
        value: _StageItemContextAction.delete,
        child: _StageContextMenuRow(
          icon: Icons.delete_outline_rounded,
          label: 'Sil',
          destructive: true,
        ),
      ),
    ],
  );

  if (action == null || !context.mounted) {
    return;
  }

  switch (action) {
    case _StageItemContextAction.copy:
      controller.copySelectedItems();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Seçili öğeler kopyalandı.'),
            duration: Duration(milliseconds: 1400),
          ),
        );
    case _StageItemContextAction.paste:
      controller.pasteCopiedItems();
    case _StageItemContextAction.duplicate:
      controller.duplicateSelectedItems();
    case _StageItemContextAction.delete:
      controller.removeSelectedItems();
  }
}

class _StageContextMenuRow extends StatelessWidget {
  const _StageContextMenuRow({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFD73A49) : context._htmlInk;
    return SizedBox(
      width: 150,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 11),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHtmlPreviewTransition({
  required PresentationTransitionKind kind,
  required Animation<double> animation,
  required bool reduceMotion,
  required Widget child,
}) {
  if (reduceMotion || kind == PresentationTransitionKind.none) {
    return child;
  }

  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  switch (kind) {
    case PresentationTransitionKind.none:
      return child;
    case PresentationTransitionKind.smooth:
      final smooth = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutSine,
        reverseCurve: Curves.easeInOutSine,
      );
      return FadeTransition(
        opacity: smooth,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.995, end: 1).animate(smooth),
          child: child,
        ),
      );
    case PresentationTransitionKind.fade:
      return FadeTransition(opacity: curved, child: child);
    case PresentationTransitionKind.slide:
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.zoom:
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.convex:
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    case PresentationTransitionKind.concave:
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    case PresentationTransitionKind.wipe:
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) => ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: curved.value,
            child: child,
          ),
        ),
      );
    case PresentationTransitionKind.split:
      return ClipRect(
        child: SizeTransition(
          sizeFactor: curved,
          axis: Axis.horizontal,
          axisAlignment: 0,
          child: child,
        ),
      );
    case PresentationTransitionKind.reveal:
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.cover:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    case PresentationTransitionKind.uncover:
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.18, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.flip:
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((1 - curved.value) * -0.7),
          child: Opacity(opacity: curved.value, child: child),
        ),
      );
  }
}

bool _shouldReduceHtmlMotion(
  BuildContext context,
  PresentationEffectSettings settings,
) {
  return settings.reducedMotion ||
      (MediaQuery.maybeOf(context)?.disableAnimations ?? false);
}

String _studioPanelTitle(_HtmlToolTab tab) {
  switch (tab) {
    case _HtmlToolTab.templates:
      return 'Sunum Şablonları';
    case _HtmlToolTab.backgrounds:
      return 'Arka Plan Kutuphanesi';
    case _HtmlToolTab.components:
      return 'Bilesen Kutuphanesi';
    case _HtmlToolTab.text:
      return 'Metin Duzenleme';
    case _HtmlToolTab.models3d:
      return '3D Modeller';
    case _HtmlToolTab.transitions:
      return 'Geçişler';
  }
}

String _studioPanelSubtitle(
  _HtmlToolTab tab,
  PresentationController controller,
) {
  switch (tab) {
    case _HtmlToolTab.templates:
      return 'Tek bir seçimle tüm slaytların görsel temasını değiştir.';
    case _HtmlToolTab.backgrounds:
      return 'Ornek HTML sunumlardan cikarilan kaliteli sahne arka planlarini sec.';
    case _HtmlToolTab.components:
      return 'Ornek sunumlardaki fizik, optik, gunes, uzay ve mikro animasyonlari slayta ekle.';
    case _HtmlToolTab.text:
      return controller.selectedTextSelectionCount > 1
          ? 'Birden fazla metin secili. Tekil icerik duzenleme yerine toplu tasima kullanilabilir.'
          : 'Metin araçları sunum sahnesinin üst bölümüne taşındı.';
    case _HtmlToolTab.models3d:
      return 'GLB modellerini sahneye ekle, taşı ve çerçevesinden boyutlandır.';
    case _HtmlToolTab.transitions:
      return 'Slayt değişimini hissettirmeyen akıcı sahne geçişlerini uygula.';
  }
}

InputDecoration _inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: SutolLightColors.onSurfaceVariant),
    isDense: true,
    filled: true,
    fillColor: SutolLightColors.surfaceSubtle,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: SutolLightColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: SutolLightColors.outline),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: SutolLightColors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: SutolLightColors.primary, width: 1.2),
    ),
  );
}

String _htmlTextStyleLabel(PresentationTextStyle style) {
  switch (style) {
    case PresentationTextStyle.standard:
      return 'Varsayılan';
    case PresentationTextStyle.bilimDramatik:
      return 'Bilim · Dramatik';
    case PresentationTextStyle.bilimTemiz:
      return 'Bilim · Temiz';
    case PresentationTextStyle.bilimDeneysel:
      return 'Bilim · Deneysel';
    case PresentationTextStyle.gunesDramatik:
      return 'Güneş · Dramatik';
    case PresentationTextStyle.gunesTemiz:
      return 'Güneş · Temiz';
    case PresentationTextStyle.gunesDeneysel:
      return 'Güneş · Deneysel';
    case PresentationTextStyle.uzayDramatik:
      return 'Uzay · Dramatik';
    case PresentationTextStyle.uzayTemiz:
      return 'Uzay · Temiz';
    case PresentationTextStyle.uzayDeneysel:
      return 'Uzay · Deneysel';
    case PresentationTextStyle.optikDramatik:
      return 'Optik · Dramatik';
    case PresentationTextStyle.optikTemiz:
      return 'Optik · Temiz';
    case PresentationTextStyle.optikDeneysel:
      return 'Optik · Deneysel';
    case PresentationTextStyle.fizikDramatik:
      return 'Fizik · Dramatik';
    case PresentationTextStyle.fizikTemiz:
      return 'Fizik · Temiz';
    case PresentationTextStyle.fizikDeneysel:
      return 'Fizik · Deneysel';
    case PresentationTextStyle.teknolojiDramatik:
      return 'Teknoloji · Dramatik';
    case PresentationTextStyle.teknolojiTemiz:
      return 'Teknoloji · Temiz';
    case PresentationTextStyle.teknolojiDeneysel:
      return 'Teknoloji · Deneysel';
    case PresentationTextStyle.openOswald:
      return 'Oswald';
    case PresentationTextStyle.openPlayfairDisplay:
      return 'Playfair Display';
    case PresentationTextStyle.openBebasNeue:
      return 'Bebas Neue';
    case PresentationTextStyle.openBungee:
      return 'Bungee';
    case PresentationTextStyle.openCaveat:
      return 'Caveat';
    case PresentationTextStyle.openUnbounded:
      return 'Unbounded';
  }
}

String _textAnimationLabel(PresentationTextAnimation animation) {
  switch (animation) {
    case PresentationTextAnimation.none:
      return 'Animasyon yok';
    case PresentationTextAnimation.bilimDramatik:
      return 'Derin ışıma';
    case PresentationTextAnimation.bilimTemiz:
      return 'Yumuşak nabız';
    case PresentationTextAnimation.bilimDeneysel:
      return 'Dijital glitch';
    case PresentationTextAnimation.gunesDramatik:
      return 'Işık patlaması';
    case PresentationTextAnimation.gunesTemiz:
      return 'Işık nefesi';
    case PresentationTextAnimation.gunesDeneysel:
      return 'Parlama titreşimi';
    case PresentationTextAnimation.uzayDramatik:
      return 'Perspektif ışıması';
    case PresentationTextAnimation.uzayTemiz:
      return 'Yatay hareket nabzı';
    case PresentationTextAnimation.uzayDeneysel:
      return 'Yörüngesel kayma';
    case PresentationTextAnimation.optikDramatik:
      return 'Ayna ışıması';
    case PresentationTextAnimation.optikTemiz:
      return 'Yumuşak parlama';
    case PresentationTextAnimation.optikDeneysel:
      return 'Prizma geçişi';
    case PresentationTextAnimation.fizikDramatik:
      return 'Elektrik titreşimi';
    case PresentationTextAnimation.fizikTemiz:
      return 'Enerji dalgası';
    case PresentationTextAnimation.fizikDeneysel:
      return 'Ölçek nabzı';
    case PresentationTextAnimation.teknolojiDramatik:
      return 'Matrix ışıması';
    case PresentationTextAnimation.teknolojiTemiz:
      return 'Devre taraması';
    case PresentationTextAnimation.teknolojiDeneysel:
      return 'Veri glitch';
    case PresentationTextAnimation.metalikParlama:
      return 'Metalik parlama';
    case PresentationTextAnimation.yavasBelirme:
      return 'Yavaş yazı reveal';
    case PresentationTextAnimation.daktilo:
      return 'Daktilo yazımı';
    case PresentationTextAnimation.bulaniktanNet:
      return 'Bulanıktan nete';
    case PresentationTextAnimation.ucBoyutluDonus:
      return '3B dönüşlü giriş';
    case PresentationTextAnimation.ziplayarakGiris:
      return 'Zıplayarak giriş';
    case PresentationTextAnimation.isikTaramasi:
      return 'Spot ışığı taraması';
    case PresentationTextAnimation.perdeAcilisi:
      return 'Merkezden perde açılışı';
    case PresentationTextAnimation.sinematikYaklasma:
      return 'Sinematik yaklaşma';
    case PresentationTextAnimation.yercekimsizSuzulme:
      return 'Yerçekimsiz süzülme';
    case PresentationTextAnimation.neonKontur:
      return 'Neon kontur';
    case PresentationTextAnimation.golgeEkstruzyonu:
      return 'Uzun gölge ekstrüzyonu';
    case PresentationTextAnimation.siviDalga:
      return 'Sıvı dalga';
    case PresentationTextAnimation.kesikSinyal:
      return 'Kesik sinyal';
    case PresentationTextAnimation.holografikDalga:
      return 'Holografik dalga';
  }
}
