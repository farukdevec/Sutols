import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../models/slide_model.dart';
import '../../services/remote_image_sources.dart';
import '../../services/remote_model_sources.dart';
import '../../state/language_controller.dart';
import '../../state/presentation_controller.dart';
import '../design/design_system.dart';
import '../design/sutol_widgets.dart';

typedef EditorStageBuilder = Widget Function(
  BuildContext context,
  PresentationController controller,
);

typedef CanvasMultiSelectionChanged = void Function({
  required List<String> textBlockIds,
  required List<String> componentBlockIds,
});

typedef CanvasComponentResizeChanged = void Function(
  Offset delta,
  Size canvasSize, {
  required bool fromLeft,
  required bool fromTop,
  required bool fromRight,
  required bool fromBottom,
});

typedef CanvasItemSecondaryTap = void Function(
  String itemId,
  Offset globalPosition,
);

bool _isCanvasImageBlock(PresentationComponentBlock block) {
  return block.imageAssetId != null ||
      (block.modelAssetId != null &&
          RemoteImageSources.sourceFor(block.modelAssetId!) != null);
}

bool _isRenderableCanvasModelBlock(PresentationComponentBlock block) {
  final modelId = block.modelAssetId;
  return modelId != null && RemoteModelSources.hasSignedSource(modelId);
}

typedef CanvasTextResizeChanged = void Function(
  Offset delta,
  Size canvasSize, {
  required double renderedHeightFactor,
  required bool fromLeft,
  required bool fromTop,
  required bool fromRight,
  required bool fromBottom,
});

typedef CanvasSecondaryTap = void Function(Offset globalPosition);

typedef CanvasModelRotate = void Function(String itemId, Offset delta);

enum _EditorToolTab {
  text,
  pages,
}

class PresentationEditorShell extends StatefulWidget {
  const PresentationEditorShell({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.stageTitle,
    required this.stageHint,
    required this.stageBuilder,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.trailing,
  }) : assert(
          primaryActionLabel == null || onPrimaryAction != null,
          'Primary action callback is required when label is provided.',
        );

  final PresentationController controller;
  final String title;
  final String subtitle;
  final String stageTitle;
  final String stageHint;
  final EditorStageBuilder stageBuilder;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final Widget? trailing;

  @override
  State<PresentationEditorShell> createState() =>
      _PresentationEditorShellState();
}

class _PresentationEditorShellState extends State<PresentationEditorShell> {
  late final TextEditingController _textController;
  _EditorToolTab _activeTab = _EditorToolTab.text;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncTextField);
    _textController = TextEditingController(
      text: widget.controller.selectedTextBlock?.text ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant PresentationEditorShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_syncTextField);
    widget.controller.addListener(_syncTextField);
    _syncTextField();
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

  void _setTab(_EditorToolTab tab) {
    if (_activeTab == tab) {
      return;
    }
    setState(() {
      _activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              color: context.background,
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isStudioWide = constraints.maxWidth >= 1180;

                  if (isStudioWide) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                      child: Column(
                        children: <Widget>[
                          _EditorStudioHeader(
                            title: widget.title,
                            subtitle: widget.subtitle,
                            controller: widget.controller,
                            primaryActionLabel: widget.primaryActionLabel,
                            onPrimaryAction: widget.onPrimaryAction,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _EditorStudioLayout(
                              controller: widget.controller,
                              textController: _textController,
                              stageTitle: widget.stageTitle,
                              stageHint: widget.stageHint,
                              stageBuilder: widget.stageBuilder,
                              activeTab: _activeTab,
                              onTabChanged: _setTab,
                              primaryActionLabel: widget.primaryActionLabel,
                              onPrimaryAction: widget.onPrimaryAction,
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
                        _EditorHeader(
                          title: widget.title,
                          subtitle: widget.subtitle,
                          pageCount: widget.controller.pages.length,
                          blockCount: widget.controller.selectedPageBlockCount,
                          trailing: widget.trailing,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, innerConstraints) {
                              final isWide = innerConstraints.maxWidth >= 980;

                              if (isWide) {
                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 220,
                                      child: _PageSidebar(
                                        controller: widget.controller,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _EditorWorkspace(
                                        controller: widget.controller,
                                        textController: _textController,
                                        stageTitle: widget.stageTitle,
                                        stageHint: widget.stageHint,
                                        stageBuilder: widget.stageBuilder,
                                        primaryActionLabel:
                                            widget.primaryActionLabel,
                                        onPrimaryAction: widget.onPrimaryAction,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 214,
                                    child: _PageSidebar(
                                      controller: widget.controller,
                                      compact: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: _EditorWorkspace(
                                      controller: widget.controller,
                                      textController: _textController,
                                      stageTitle: widget.stageTitle,
                                      stageHint: widget.stageHint,
                                      stageBuilder: widget.stageBuilder,
                                      primaryActionLabel:
                                          widget.primaryActionLabel,
                                      onPrimaryAction: widget.onPrimaryAction,
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
    );
  }
}

class _EditorStudioHeader extends StatelessWidget {
  const _EditorStudioHeader({
    required this.title,
    required this.subtitle,
    required this.controller,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final String title;
  final String subtitle;
  final PresentationController controller;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: context.decoration.cardElevated(
        color: context.surface,
        elevation: 1,
      ),
      child: Row(
        children: <Widget>[
          SutolIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          const SutolsBrandLockup(height: 34),
          const SizedBox(width: 18),
          const SutolChip(label: 'Dosya'),
          const SizedBox(width: 8),
          const SutolChip(label: 'Metin Sahnesi'),
          const SizedBox(width: 8),
          const SutolChip(label: 'Duzenleme'),
          const Spacer(),
          SutolChip(
            icon: Icons.layers_rounded,
            label: '${controller.pages.length} Sayfa',
          ),
          const SizedBox(width: 8),
          SutolChip(
            icon: Icons.text_fields_rounded,
            label: '${controller.selectedPageBlockCount} Metin',
          ),
          const SizedBox(width: 8),
          SutolChip(
            icon: Icons.select_all_rounded,
            label: '${controller.selectedItemCount} Secili',
          ),
          if (primaryActionLabel != null &&
              onPrimaryAction != null) ...<Widget>[
            const SizedBox(width: 12),
            SutolButton(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction,
              icon: Icons.play_circle_fill_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _EditorStudioLayout extends StatelessWidget {
  const _EditorStudioLayout({
    required this.controller,
    required this.textController,
    required this.stageTitle,
    required this.stageHint,
    required this.stageBuilder,
    required this.activeTab,
    required this.onTabChanged,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final String stageTitle;
  final String stageHint;
  final EditorStageBuilder stageBuilder;
  final _EditorToolTab activeTab;
  final ValueChanged<_EditorToolTab> onTabChanged;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _EditorToolRail(
          activeTab: activeTab,
          onTabChanged: onTabChanged,
          primaryActionLabel: primaryActionLabel,
          onPrimaryAction: onPrimaryAction,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 318,
          child: _EditorInspectorPanel(
            controller: controller,
            textController: textController,
            activeTab: activeTab,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _EditorStudioWorkspace(
            controller: controller,
            stageTitle: stageTitle,
            stageHint: stageHint,
            stageChild: stageBuilder(context, controller),
          ),
        ),
      ],
    );
  }
}

class _EditorToolRail extends StatelessWidget {
  const _EditorToolRail({
    required this.activeTab,
    required this.onTabChanged,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final _EditorToolTab activeTab;
  final ValueChanged<_EditorToolTab> onTabChanged;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: context.decoration.cardElevated(
        color: context.surface,
        elevation: 1,
      ),
      child: Column(
        children: <Widget>[
          _EditorRailButton(
            label: 'Metin',
            icon: Icons.text_fields_rounded,
            isSelected: activeTab == _EditorToolTab.text,
            onTap: () => onTabChanged(_EditorToolTab.text),
          ),
          const SizedBox(height: 12),
          _EditorRailButton(
            label: 'Sayfalar',
            icon: Icons.view_carousel_rounded,
            isSelected: activeTab == _EditorToolTab.pages,
            onTap: () => onTabChanged(_EditorToolTab.pages),
          ),
          const Spacer(),
          if (primaryActionLabel != null && onPrimaryAction != null)
            SutolIconButton(
              icon: Icons.play_circle_fill_rounded,
              onPressed: onPrimaryAction,
              tooltip: primaryActionLabel,
            ),
        ],
      ),
    );
  }
}

class _EditorRailButton extends StatelessWidget {
  const _EditorRailButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? context.primaryLight : Colors.transparent;
    final fgColor = isSelected ? context.primary : context.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radiusMd),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(context.radiusMd),
          border: Border(
            left: BorderSide(
              color: isSelected ? context.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: fgColor, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fgColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorInspectorPanel extends StatelessWidget {
  const _EditorInspectorPanel({
    required this.controller,
    required this.textController,
    required this.activeTab,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _EditorToolTab activeTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: context.decoration.cardElevated(
        color: context.surface,
        elevation: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _editorPanelTitle(activeTab),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _editorPanelSubtitle(activeTab, controller),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              SutolChip(
                icon: Icons.layers_rounded,
                label: '${controller.pages.length} Sayfa',
              ),
              SutolChip(
                icon: Icons.select_all_rounded,
                label: '${controller.selectedItemCount} Secili',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _EditorStudioControlPanel(
                  key: ValueKey<_EditorToolTab>(activeTab),
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

class _EditorStudioWorkspace extends StatelessWidget {
  const _EditorStudioWorkspace({
    required this.controller,
    required this.stageTitle,
    required this.stageHint,
    required this.stageChild,
  });

  final PresentationController controller;
  final String stageTitle;
  final String stageHint;
  final Widget stageChild;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: context.decoration.cardElevated(
            color: context.surface,
            elevation: 1,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      stageTitle,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: context.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.hasMultiSelection
                          ? '${controller.selectedItemCount} oge secili. Herhangi birini surukleyerek grubu birlikte tasiyabilirsin.'
                          : stageHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SutolChip(
                icon: Icons.notes_rounded,
                label: 'Sayfa ${controller.selectedIndex + 1}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: context.decoration.cardElevated(
              color: context.surface,
              elevation: 2,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _StageSurface(
                    child: stageChild,
                  ),
                ),
                const SizedBox(height: 14),
                _EditorFilmstrip(
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

class _EditorStudioControlPanel extends StatelessWidget {
  const _EditorStudioControlPanel({
    super.key,
    required this.controller,
    required this.textController,
    required this.activeTab,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _EditorToolTab activeTab;

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case _EditorToolTab.text:
        return _EditorTextInspectorControls(
          controller: controller,
          textController: textController,
        );
      case _EditorToolTab.pages:
        return _EditorPageInspectorControls(
          controller: controller,
        );
    }
  }
}

class _EditorTextInspectorControls extends StatelessWidget {
  const _EditorTextInspectorControls({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            const SutolBadge(
              label: 'Metin Katmanı',
              variant: SutolBadgeVariant.info,
            ),
            if (selectedTextCount > 1)
              SutolBadge(
                label: '$selectedTextCount metin seçili',
                variant: SutolBadgeVariant.neutral,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _LabeledTextField(
          label: 'Metin',
          controller: textController,
          enabled: selectedTextBlock != null,
          onChanged: controller.updateSelectedText,
        ),
        const SizedBox(height: 12),
        _LabeledDropdown(
          label: 'Yazi Stili',
          value: selectedTextBlock?.textStyle,
          onChanged: selectedTextBlock == null
              ? null
              : (value) {
                  if (value != null) {
                    controller.updateSelectedTextStyle(value);
                  }
                },
        ),
        const SizedBox(height: 12),
        _LabeledFontSizeStepper(
          label: 'Boyut',
          value: selectedTextBlock?.fontSize.round(),
          onDecrease: selectedTextBlock == null
              ? null
              : () => controller.updateSelectedFontSize(
                    math.max(18, selectedTextBlock.fontSize - 2),
                  ),
          onIncrease: selectedTextBlock == null
              ? null
              : () => controller.updateSelectedFontSize(
                    math.min(
                      PresentationController.maxTextFontSize,
                      selectedTextBlock.fontSize + 2,
                    ),
                  ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: SutolButton(
                icon: Icons.add_rounded,
                label: 'Metin Ekle',
                variant: SutolButtonVariant.secondary,
                isCompact: true,
                onPressed: controller.addTextBlock,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SutolButton(
                icon: Icons.delete_outline_rounded,
                label: 'Sil',
                variant: SutolButtonVariant.destructive,
                isCompact: true,
                onPressed: controller.canRemoveTextBlock
                    ? controller.removeSelectedTextBlock
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditorPageInspectorControls extends StatelessWidget {
  const _EditorPageInspectorControls({
    required this.controller,
  });

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            SutolBadge(
              label: 'Sayfa Kontrolleri',
              variant: SutolBadgeVariant.info,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: SutolButton(
                icon: Icons.add_rounded,
                label: 'Yeni Sayfa',
                variant: SutolButtonVariant.secondary,
                isCompact: true,
                onPressed: controller.addPage,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SutolButton(
                icon: Icons.remove_rounded,
                label: 'Sayfa Sil',
                variant: SutolButtonVariant.destructive,
                isCompact: true,
                onPressed: controller.canRemovePage
                    ? controller.removeSelectedPage
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: context.decoration.cardElevated(
            color: context.surfaceVariant,
            elevation: 0,
          ),
          child: Text(
            'Alt taraftaki sayfa seridinden sayfalar arasinda hizli gecis yapabilirsin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _EditorFilmstrip extends StatelessWidget {
  const _EditorFilmstrip({
    required this.controller,
  });

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: context.decoration.cardElevated(
        color: context.surfaceVariant,
        elevation: 0,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 138,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: context.decoration.cardElevated(
              color: context.surface,
              elevation: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sayfalar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.selectedIndex + 1} / ${controller.pages.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.pages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _EditorStudioPageThumb(
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
              SutolIconButton(
                icon: Icons.add_rounded,
                onPressed: controller.addPage,
              ),
              const SizedBox(height: 8),
              SutolIconButton(
                icon: Icons.remove_rounded,
                onPressed: controller.canRemovePage
                    ? controller.removeSelectedPage
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditorStudioPageThumb extends StatelessWidget {
  const _EditorStudioPageThumb({
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
        color: isSelected ? context.primaryLight : context.surface,
        borderRadius: BorderRadius.circular(context.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.radiusLg),
          child: AnimatedContainer(
            duration: context.motion.fast,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.radiusLg),
              border: Border.all(
                color: isSelected ? context.primary : context.outline,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(context.radiusMd),
                    child: IgnorePointer(
                      child: PresentationPageThumbnailCanvas(
                        page: page,
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
                          color: context.onSurface,
                          fontWeight: FontWeight.w700,
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

String _editorPanelTitle(_EditorToolTab tab) {
  switch (tab) {
    case _EditorToolTab.text:
      return 'Metin Kutuphanesi';
    case _EditorToolTab.pages:
      return 'Sayfa Yoneticisi';
  }
}

String _editorPanelSubtitle(
  _EditorToolTab tab,
  PresentationController controller,
) {
  switch (tab) {
    case _EditorToolTab.text:
      return controller.selectedTextSelectionCount > 1
          ? 'Birden fazla metin secili. Tekil icerik yerine toplu tasima kullanabilirsin.'
          : 'Yazilari ekle, tipini belirle ve boyutunu ayarla.';
    case _EditorToolTab.pages:
      return 'Sayfa olustur, sil ve alttaki seritten hizli gecis yap.';
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.title,
    required this.subtitle,
    required this.pageCount,
    required this.blockCount,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final int pageCount;
  final int blockCount;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: context.decoration.cardElevated(
        color: context.surface,
        elevation: 1,
      ),
      child: Row(
        children: <Widget>[
          SutolIconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_back_rounded,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SutolChip(icon: Icons.layers_rounded, label: '$pageCount Sayfa'),
              SutolChip(icon: Icons.notes_rounded, label: '$blockCount Metin'),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }
}

class _PageSidebar extends StatelessWidget {
  const _PageSidebar({
    required this.controller,
    this.compact = false,
  });

  final PresentationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.decoration.cardElevated(
        color: context.surface,
        elevation: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Sayfalar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              SutolIconButton(
                icon: Icons.add_rounded,
                onPressed: controller.addPage,
              ),
              const SizedBox(width: 8),
              SutolIconButton(
                icon: Icons.remove_rounded,
                onPressed: controller.canRemovePage
                    ? controller.removeSelectedPage
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: compact
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.pages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return SizedBox(
                        width: 188,
                        child: _PageThumbnail(
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return _PageThumbnail(
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

class _PageThumbnail extends StatelessWidget {
  const _PageThumbnail({
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
      borderRadius: BorderRadius.circular(context.radiusLg),
      child: AnimatedContainer(
        duration: context.motion.fast,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryLight : context.surface,
          borderRadius: BorderRadius.circular(context.radiusLg),
          border: Border.all(
            color: isSelected ? context.primary : context.outline,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Sayfa ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radiusMd),
                child: IgnorePointer(
                  child: PresentationPageThumbnailCanvas(
                    page: page,
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

class _EditorWorkspace extends StatelessWidget {
  const _EditorWorkspace({
    required this.controller,
    required this.textController,
    required this.stageTitle,
    required this.stageHint,
    required this.stageBuilder,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final String stageTitle;
  final String stageHint;
  final EditorStageBuilder stageBuilder;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.decoration.cardElevated(
        color: context.surface,
        elevation: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _WorkspaceToolbar(
            controller: controller,
            textController: textController,
            title: stageTitle,
          ),
          if (stageHint.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              stageHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: _StageSurface(
              child: stageBuilder(context, controller),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  controller.hasMultiSelection
                      ? '${controller.selectedItemCount} oge secili. Birini surukleyerek birlikte tasiyabilirsin.'
                      : controller.selectedTextBlock != null
                          ? 'Kutuyu surukleyebilir, sag tutamactan yatayda genisletip daraltabilirsin.'
                          : 'Bos alanda surukleyerek coklu secim yapabilir veya yeni metin ekleyebilirsin.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (primaryActionLabel != null && onPrimaryAction != null)
                SutolButton(
                  label: primaryActionLabel!,
                  onPressed: onPrimaryAction,
                  icon: Icons.play_circle_fill_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkspaceToolbar extends StatelessWidget {
  const _WorkspaceToolbar({
    required this.controller,
    required this.textController,
    required this.title,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final String title;

  @override
  Widget build(BuildContext context) {
    final selectedTextBlock = controller.selectedTextBlock;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1040;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 280,
                child: _LabeledTextField(
                  label: 'Metin',
                  controller: textController,
                  enabled: selectedTextBlock != null,
                  onChanged: controller.updateSelectedText,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 168,
                child: _LabeledDropdown(
                  label: 'Yazi Stili',
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
              const SizedBox(width: 12),
              SizedBox(
                width: 130,
                child: _LabeledFontSizeStepper(
                  label: 'Boyut',
                  value: selectedTextBlock?.fontSize.round(),
                  onDecrease: selectedTextBlock == null
                      ? null
                      : () => controller.updateSelectedFontSize(
                            math.max(18, selectedTextBlock.fontSize - 2),
                          ),
                  onIncrease: selectedTextBlock == null
                      ? null
                      : () => controller.updateSelectedFontSize(
                            math.min(
                              PresentationController.maxTextFontSize,
                              selectedTextBlock.fontSize + 2,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              SutolIconButton(
                icon: Icons.add_rounded,
                onPressed: controller.addTextBlock,
              ),
              const SizedBox(width: 8),
              SutolIconButton(
                icon: Icons.delete_outline_rounded,
                onPressed: controller.canRemoveTextBlock
                    ? controller.removeSelectedTextBlock
                    : null,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: context.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: math.min(constraints.maxWidth, 280),
                  child: _LabeledTextField(
                    label: 'Metin',
                    controller: textController,
                    enabled: selectedTextBlock != null,
                    onChanged: controller.updateSelectedText,
                  ),
                ),
                SizedBox(
                  width: 168,
                  child: _LabeledDropdown(
                    label: 'Yazi Stili',
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
                SizedBox(
                  width: 130,
                  child: _LabeledFontSizeStepper(
                    label: 'Boyut',
                    value: selectedTextBlock?.fontSize.round(),
                    onDecrease: selectedTextBlock == null
                        ? null
                        : () => controller.updateSelectedFontSize(
                              math.max(18, selectedTextBlock.fontSize - 2),
                            ),
                    onIncrease: selectedTextBlock == null
                        ? null
                        : () => controller.updateSelectedFontSize(
                              math.min(
                                PresentationController.maxTextFontSize,
                                selectedTextBlock.fontSize + 2,
                              ),
                            ),
                  ),
                ),
                SutolIconButton(
                  icon: Icons.add_rounded,
                  onPressed: controller.addTextBlock,
                ),
                SutolIconButton(
                  icon: Icons.delete_outline_rounded,
                  onPressed: controller.canRemoveTextBlock
                      ? controller.removeSelectedTextBlock
                      : null,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _LabeledControl(
      label: label,
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        style: TextStyle(
          color: context.onSurface,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: tr('Buraya metin yazın', 'Type text here'),
          hintStyle: TextStyle(color: context.onSurfaceVariant),
          isDense: true,
          filled: true,
          fillColor: context.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide: BorderSide(color: context.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide: BorderSide(color: context.outline),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide:
                BorderSide(color: context.outline.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide: BorderSide(color: context.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final PresentationTextStyle? value;
  final ValueChanged<PresentationTextStyle?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _LabeledControl(
      label: label,
      child: DropdownButtonFormField<PresentationTextStyle>(
        initialValue: value,
        onChanged: onChanged,
        isDense: true,
        dropdownColor: context.surface,
        borderRadius: BorderRadius.circular(context.radiusMd),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: TextStyle(
          color: context.onSurface,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: context.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide: BorderSide(color: context.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide: BorderSide(color: context.outline),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide:
                BorderSide(color: context.outline.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.radiusMd),
            borderSide: BorderSide(color: context.primary, width: 1.5),
          ),
        ),
        items: presentationFontLibraryStyles
            .map(
              (style) => DropdownMenuItem<PresentationTextStyle>(
                value: style,
                child: Text(
                  _textStyleLabel(style),
                  style: TextStyle(
                    color: context.onSurface,
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

class _LabeledFontSizeStepper extends StatelessWidget {
  const _LabeledFontSizeStepper({
    required this.label,
    required this.value,
    this.onDecrease,
    this.onIncrease,
  });

  final String label;
  final int? value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return _LabeledControl(
      label: label,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: BorderRadius.circular(context.radiusMd),
          border: Border.all(color: context.outline),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onDecrease,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.remove_rounded, color: context.onSurface),
            ),
            Expanded(
              child: Center(
                child: Text(
                  value?.toString() ?? '-',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrease,
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.add_rounded, color: context.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledControl extends StatelessWidget {
  const _LabeledControl({
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
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        child,
      ],
    );
  }
}

class _StageSurface extends StatelessWidget {
  const _StageSurface({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stageWidth = math.min(
          constraints.maxWidth,
          constraints.maxHeight * (16 / 9),
        );
        final stageHeight = stageWidth / (16 / 9);

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: stageWidth,
            height: stageHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>(_stageKey(child)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _stageKey(Widget child) {
    return '${child.key ?? child.runtimeType}';
  }
}

class PresentationPageCanvas extends StatefulWidget {
  const PresentationPageCanvas({
    super.key,
    required this.page,
    this.selectedTextBlockId,
    this.selectedTextBlockIds = const <String>{},
    this.selectedComponentBlockId,
    this.selectedComponentBlockIds = const <String>{},
    this.interactive = false,
    this.showHint = false,
    this.showSurface = true,
    this.showSelectionBorder = true,
    this.textOpacity = 1,
    this.showEmptyState = true,
    this.onSelectTextBlock,
    this.onDragSelectedText,
    this.onInlineTextChanged,
    this.onInlineEditingChanged,
    this.onResizeSelectedText,
    this.onResizeSelectedComponent,
    this.onMarqueeSelectionChanged,
    this.onClearSelection,
    this.onSelectComponentBlock,
    this.onSecondaryTapTextBlock,
    this.onSecondaryTapComponentBlock,
    this.onSecondaryTapCanvas,
    this.onToggleModelOrbit,
    this.onRotateModel,
    this.onBeginModelOrbit,
    this.onEndModelOrbit,
  });

  final PresentationPage page;
  final String? selectedTextBlockId;
  final Set<String> selectedTextBlockIds;
  final String? selectedComponentBlockId;
  final Set<String> selectedComponentBlockIds;
  final bool interactive;
  final bool showHint;
  final bool showSurface;
  final bool showSelectionBorder;
  final double textOpacity;
  final bool showEmptyState;
  final ValueChanged<String>? onSelectTextBlock;
  final void Function(Offset delta, Size canvasSize)? onDragSelectedText;
  final ValueChanged<String>? onInlineTextChanged;
  final ValueChanged<String?>? onInlineEditingChanged;
  final CanvasTextResizeChanged? onResizeSelectedText;
  final CanvasComponentResizeChanged? onResizeSelectedComponent;
  final CanvasMultiSelectionChanged? onMarqueeSelectionChanged;
  final VoidCallback? onClearSelection;
  final ValueChanged<String>? onSelectComponentBlock;
  final CanvasItemSecondaryTap? onSecondaryTapTextBlock;
  final CanvasItemSecondaryTap? onSecondaryTapComponentBlock;
  final CanvasSecondaryTap? onSecondaryTapCanvas;
  final ValueChanged<String>? onToggleModelOrbit;
  final CanvasModelRotate? onRotateModel;
  final ValueChanged<String>? onBeginModelOrbit;
  final VoidCallback? onEndModelOrbit;

  @override
  State<PresentationPageCanvas> createState() => _PresentationPageCanvasState();
}

/// Küçük kartlarda tuvali doğrudan dar ölçülerde yeniden düzenlemek yerine
/// 1000x562.5 referans sahnesini tek parça halinde ölçekler. Böylece yazı,
/// boşluk ve bileşen oranları ana sahneyle aynı kalır; minimum font/padding
/// sınırları küçük önizlemede metinleri üst üste bindirmez.
class PresentationPageThumbnailCanvas extends StatelessWidget {
  const PresentationPageThumbnailCanvas({
    super.key,
    required this.page,
  });

  final PresentationPage page;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 1000,
        height: 562.5,
        child: PresentationPageCanvas(
          page: page,
          showHint: false,
          showSelectionBorder: false,
        ),
      ),
    );
  }
}

class _CanvasSelectionResult {
  const _CanvasSelectionResult({
    required this.textBlockIds,
    required this.componentBlockIds,
  });

  final List<String> textBlockIds;
  final List<String> componentBlockIds;
}

enum _ComponentResizeHandle {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

class _PresentationPageCanvasState extends State<PresentationPageCanvas> {
  late final TextEditingController _inlineTextController;
  late final FocusNode _inlineFocusNode;
  String? _editingBlockId;
  Offset? _selectionDragStart;
  Offset? _selectionDragCurrent;

  @override
  void initState() {
    super.initState();
    _inlineTextController = TextEditingController();
    _inlineFocusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant PresentationPageCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final editingBlock = widget.page.findTextBlock(_editingBlockId);
    if (editingBlock == null) {
      final wasEditing = _editingBlockId != null;
      _inlineFocusNode.unfocus();
      _editingBlockId = null;
      if (wasEditing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onInlineEditingChanged?.call(null);
        });
      }
      return;
    }

    if (_inlineTextController.text != editingBlock.text) {
      final nextText = editingBlock.text;
      _inlineTextController.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
  }

  @override
  void dispose() {
    _inlineFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _inlineTextController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!_inlineFocusNode.hasFocus && _editingBlockId != null) {
      setState(() {
        _editingBlockId = null;
      });
      widget.onInlineEditingChanged?.call(null);
    }
  }

  void _startInlineEditing(PresentationTextBlock block) {
    widget.onSelectTextBlock?.call(block.id);
    final nextText = block.text;
    _inlineTextController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    setState(() {
      _editingBlockId = block.id;
    });
    widget.onInlineEditingChanged?.call(block.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _inlineFocusNode.requestFocus();
    });
  }

  void _stopInlineEditing() {
    if (_editingBlockId == null) {
      return;
    }
    setState(() {
      _editingBlockId = null;
    });
    widget.onInlineEditingChanged?.call(null);
    _inlineFocusNode.unfocus();
  }

  Rect? get _selectionRect {
    final start = _selectionDragStart;
    final current = _selectionDragCurrent;
    if (start == null || current == null) {
      return null;
    }

    return Rect.fromPoints(start, current);
  }

  Set<String> _effectiveSelectedTextIds() {
    if (widget.selectedTextBlockIds.isNotEmpty) {
      return widget.selectedTextBlockIds;
    }
    if (widget.selectedTextBlockId != null) {
      return <String>{widget.selectedTextBlockId!};
    }
    return const <String>{};
  }

  Set<String> _effectiveSelectedComponentIds() {
    if (widget.selectedComponentBlockIds.isNotEmpty) {
      return widget.selectedComponentBlockIds;
    }
    if (widget.selectedComponentBlockId != null) {
      return <String>{widget.selectedComponentBlockId!};
    }
    return const <String>{};
  }

  void _startSelectionDrag(DragStartDetails details) {
    if (!widget.interactive || _editingBlockId != null) {
      return;
    }

    _deferredSetState(() {
      _selectionDragStart = details.localPosition;
      _selectionDragCurrent = details.localPosition;
    });
  }

  void _updateSelectionDrag(DragUpdateDetails details) {
    if (_selectionDragStart == null) {
      return;
    }

    _deferredSetState(() {
      _selectionDragCurrent = details.localPosition;
    });
  }

  /// Jest iptalleri (ör. çoklu dokunmada tuval etkileşimi kapatılırken)
  /// build kilidi sırasında gelebilir; o durumda güncelleme sonraki kareye
  /// ertelenir.
  void _deferredSetState(VoidCallback fn) {
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(fn);
        }
      });
      return;
    }
    setState(fn);
  }

  void _endSelectionDrag(Size canvasSize) {
    final selectionRect = _selectionRect;
    final shouldSelect = selectionRect != null &&
        selectionRect.width.abs() >= 8 &&
        selectionRect.height.abs() >= 8;

    if (shouldSelect) {
      final result = _collectSelectionFromRect(selectionRect, canvasSize);
      widget.onMarqueeSelectionChanged?.call(
        textBlockIds: result.textBlockIds,
        componentBlockIds: result.componentBlockIds,
      );
    }

    _deferredSetState(() {
      _selectionDragStart = null;
      _selectionDragCurrent = null;
    });
  }

  _CanvasSelectionResult _collectSelectionFromRect(
    Rect selectionRect,
    Size canvasSize,
  ) {
    final selectedTextIds = <String>[];
    final selectedComponentIds = <String>[];

    for (final block in widget.page.textBlocks) {
      if (_textBlockRect(block, canvasSize).overlaps(selectionRect)) {
        selectedTextIds.add(block.id);
      }
    }
    for (final block in widget.page.componentBlocks) {
      if (_componentBlockRect(block, canvasSize).overlaps(selectionRect)) {
        selectedComponentIds.add(block.id);
      }
    }

    return _CanvasSelectionResult(
      textBlockIds: selectedTextIds,
      componentBlockIds: selectedComponentIds,
    );
  }

  Rect _textBlockRect(PresentationTextBlock block, Size canvasSize) {
    final displayText = block.text.trim().isEmpty
        ? tr('Buraya metin yazın', 'Type text here')
        : block.text;
    final paddingX = math.max(10.0, canvasSize.width * 0.014);
    final paddingY = math.max(8.0, canvasSize.height * 0.016);
    final baseFontSize =
        (block.fontSize * canvasSize.width / 1000).clamp(14.0, 320.0);
    final adjustedFontSize = _fontSizeForType(block.type, baseFontSize);
    final maxBoxWidth = math.max(72.0, canvasSize.width * 0.82);
    final minBoxWidth = math.min(
      maxBoxWidth,
      math.max(72.0, canvasSize.width * (widget.interactive ? 0.18 : 0.12)),
    );
    final boxWidth = (block.widthFactor * canvasSize.width)
        .clamp(minBoxWidth, maxBoxWidth)
        .toDouble();
    final leftPosition = (block.position.dx * canvasSize.width)
        .clamp(0.0, math.max(0.0, canvasSize.width - boxWidth))
        .toDouble();
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: _fontWeightForType(block.type),
              fontSize: adjustedFontSize,
              height: _lineHeightForType(block.type),
              letterSpacing: _letterSpacingForType(block.type),
            ),
      ),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: math.max(0, boxWidth - (paddingX * 2)));

    final naturalHeight = textPainter.height + (paddingY * 2);
    final maxH = math.max(1.0, canvasSize.height * 0.86);
    final minH = math.min(44.0, maxH);
    final boxHeight = block.heightFactor == null
        ? naturalHeight
        : (block.heightFactor! * canvasSize.height)
            .clamp(minH, maxH)
            .toDouble();
    return Rect.fromLTWH(
      leftPosition,
      block.position.dy * canvasSize.height,
      boxWidth,
      boxHeight,
    );
  }

  Rect _componentBlockRect(
    PresentationComponentBlock block,
    Size canvasSize,
  ) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return Rect.zero;
    }
    final minW = math.min(54.0, canvasSize.width);
    final minH = math.min(44.0, canvasSize.height);
    final width = (block.size.width * canvasSize.width)
        .clamp(minW, canvasSize.width)
        .toDouble();
    final height = (block.size.height * canvasSize.height)
        .clamp(minH, canvasSize.height)
        .toDouble();
    final left = (block.position.dx * canvasSize.width)
        .clamp(0.0, math.max(0.0, canvasSize.width - width))
        .toDouble();
    final top = (block.position.dy * canvasSize.height)
        .clamp(0.0, math.max(0.0, canvasSize.height - height))
        .toDouble();
    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final blocks = widget.page.textBlocks;
        final componentBlocks = widget.page.componentBlocks;
        final selectedTextIds = _effectiveSelectedTextIds();
        final selectedComponentIds = _effectiveSelectedComponentIds();
        final selectionRect = _selectionRect;

        return Stack(
          children: <Widget>[
            if (widget.interactive)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    widget.onClearSelection?.call();
                    _stopInlineEditing();
                  },
                  onSecondaryTapDown: (details) {
                    widget.onClearSelection?.call();
                    _stopInlineEditing();
                    widget.onSecondaryTapCanvas?.call(details.globalPosition);
                  },
                  onPanStart: _startSelectionDrag,
                  onPanUpdate: _updateSelectionDrag,
                  onPanEnd: (_) => _endSelectionDrag(canvasSize),
                  onPanCancel: () => _endSelectionDrag(canvasSize),
                ),
              ),
            if (widget.showHint && widget.interactive)
              Positioned(
                top: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFDCE5F1)),
                  ),
                  child: Text(
                    'Bos alanda surukle: coklu secim, cerceveden boyutlandir',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            if (widget.interactive && _editingBlockId != null)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _stopInlineEditing,
                ),
              ),
            if (blocks.isEmpty &&
                componentBlocks.isEmpty &&
                widget.showEmptyState)
              Center(
                child: Text(
                  'Metin veya bilesen ekleyin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            for (final block in componentBlocks)
              _PageComponentBlock(
                block: block,
                canvasSize: canvasSize,
                isSelected: selectedComponentIds.contains(block.id),
                interactive: widget.interactive,
                showSelectionBorder: widget.showSelectionBorder,
                // Keep real photos visible in Flutter while the HTML layer
                // refreshes. This prevents an empty/grey Pexels placeholder.
                opacity: _isCanvasImageBlock(block) ? 1 : widget.textOpacity,
                showResizeHandles: widget.interactive &&
                    selectedTextIds.isEmpty &&
                    selectedComponentIds.length == 1 &&
                    widget.onResizeSelectedComponent != null,
                onTap: widget.onSelectComponentBlock == null
                    ? null
                    : () => widget.onSelectComponentBlock!(block.id),
                onSecondaryTapDown: widget.onSecondaryTapComponentBlock == null
                    ? null
                    : (details) => widget.onSecondaryTapComponentBlock!(
                          block.id,
                          details.globalPosition,
                        ),
                onToggleOrbit: widget.onToggleModelOrbit == null
                    ? null
                    : () => widget.onToggleModelOrbit!(block.id),
                onOrbitPanStart: widget.interactive &&
                        _isRenderableCanvasModelBlock(block) &&
                        !_isCanvasImageBlock(block) &&
                        block.modelOrbitEnabled &&
                        widget.onRotateModel != null
                    ? (_) {
                        if (!selectedComponentIds.contains(block.id)) {
                          widget.onSelectComponentBlock?.call(block.id);
                        }
                        widget.onBeginModelOrbit?.call(block.id);
                      }
                    : null,
                onOrbitPanUpdate: widget.interactive &&
                        _isRenderableCanvasModelBlock(block) &&
                        !_isCanvasImageBlock(block) &&
                        block.modelOrbitEnabled &&
                        widget.onRotateModel != null
                    ? (details) =>
                        widget.onRotateModel!(block.id, details.delta)
                    : null,
                onOrbitPanEnd: widget.interactive &&
                        _isRenderableCanvasModelBlock(block) &&
                        !_isCanvasImageBlock(block) &&
                        block.modelOrbitEnabled &&
                        widget.onRotateModel != null
                    ? (_) => widget.onEndModelOrbit?.call()
                    : null,
                onPanUpdate:
                    widget.interactive && widget.onDragSelectedText != null
                        ? (details) {
                            if (!selectedComponentIds.contains(block.id)) {
                              widget.onSelectComponentBlock?.call(block.id);
                            }
                            widget.onDragSelectedText!(
                              details.delta,
                              canvasSize,
                            );
                          }
                        : null,
                onResizeUpdate: widget.interactive &&
                        widget.onResizeSelectedComponent != null
                    ? (handle, details) {
                        if (!selectedComponentIds.contains(block.id)) {
                          widget.onSelectComponentBlock?.call(block.id);
                        }
                        widget.onResizeSelectedComponent!(
                          details.delta,
                          canvasSize,
                          fromLeft: _componentResizeFromLeft(handle),
                          fromTop: _componentResizeFromTop(handle),
                          fromRight: _componentResizeFromRight(handle),
                          fromBottom: _componentResizeFromBottom(handle),
                        );
                      }
                    : null,
              ),
            for (final block in blocks)
              _PageTextBlock(
                block: block,
                canvasSize: canvasSize,
                isSelected: selectedTextIds.contains(block.id),
                isEditing: _editingBlockId == block.id,
                interactive: widget.interactive,
                showSelectionBorder: widget.showSelectionBorder,
                darkSurface: _isDarkCanvasBackground(
                  widget.page,
                ),
                textOpacity: widget.textOpacity,
                editingController:
                    _editingBlockId == block.id ? _inlineTextController : null,
                editingFocusNode:
                    _editingBlockId == block.id ? _inlineFocusNode : null,
                onTap: widget.onSelectTextBlock == null
                    ? null
                    : () => widget.onSelectTextBlock!(block.id),
                onDoubleTap: widget.interactive
                    ? () => _startInlineEditing(block)
                    : null,
                onSecondaryTapDown: widget.onSecondaryTapTextBlock == null
                    ? null
                    : (details) => widget.onSecondaryTapTextBlock!(
                          block.id,
                          details.globalPosition,
                        ),
                onPanUpdate: widget.interactive &&
                        _editingBlockId != block.id &&
                        widget.onDragSelectedText != null
                    ? (details) {
                        if (!selectedTextIds.contains(block.id)) {
                          widget.onSelectTextBlock?.call(block.id);
                        }
                        widget.onDragSelectedText!(details.delta, canvasSize);
                      }
                    : null,
                onResizeUpdate: widget.interactive &&
                        _editingBlockId != block.id &&
                        widget.onResizeSelectedText != null
                    ? (handle, details, renderedHeightFactor) {
                        if (!selectedTextIds.contains(block.id)) {
                          widget.onSelectTextBlock?.call(block.id);
                        }
                        widget.onResizeSelectedText!(
                          details.delta,
                          canvasSize,
                          renderedHeightFactor: renderedHeightFactor,
                          fromLeft: _componentResizeFromLeft(handle),
                          fromTop: _componentResizeFromTop(handle),
                          fromRight: _componentResizeFromRight(handle),
                          fromBottom: _componentResizeFromBottom(handle),
                        );
                      }
                    : null,
                onInlineTextChanged: widget.onInlineTextChanged,
                onEditingFinished: _stopInlineEditing,
              ),
            if (selectionRect != null)
              Positioned.fromRect(
                rect: selectionRect,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.onSurface.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );

    if (!widget.showSurface) {
      return content;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: presentationBackgroundVariantPreviewColors(
            widget.page.backgroundKind,
            colorsInverted: widget.page.backgroundColorsInverted,
          ),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: _CanvasBackgroundPreview(
              kind: widget.page.backgroundKind,
              colorsInverted: widget.page.backgroundColorsInverted,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isDarkCanvasBackground(widget.page)
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE3E9F2),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _PageGridPainter(
                darkMode: _isDarkCanvasBackground(widget.page),
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class _PageTextBlock extends StatelessWidget {
  const _PageTextBlock({
    required this.block,
    required this.canvasSize,
    required this.isSelected,
    required this.isEditing,
    required this.interactive,
    required this.showSelectionBorder,
    required this.darkSurface,
    required this.textOpacity,
    this.editingController,
    this.editingFocusNode,
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
    this.onPanUpdate,
    this.onResizeUpdate,
    this.onInlineTextChanged,
    this.onEditingFinished,
  });

  final PresentationTextBlock block;
  final Size canvasSize;
  final bool isSelected;
  final bool isEditing;
  final bool interactive;
  final bool showSelectionBorder;
  final bool darkSurface;
  final double textOpacity;
  final TextEditingController? editingController;
  final FocusNode? editingFocusNode;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureDragUpdateCallback? onPanUpdate;
  final void Function(
    _ComponentResizeHandle handle,
    DragUpdateDetails details,
    double renderedHeightFactor,
  )? onResizeUpdate;
  final ValueChanged<String>? onInlineTextChanged;
  final VoidCallback? onEditingFinished;

  @override
  Widget build(BuildContext context) {
    final displayText = block.text.trim().isEmpty
        ? tr('Buraya metin yazın', 'Type text here')
        : block.text;
    final paddingX = math.max(10.0, canvasSize.width * 0.014);
    final paddingY = math.max(8.0, canvasSize.height * 0.016);
    final baseFontSize =
        (block.fontSize * canvasSize.width / 1000).clamp(14.0, 320.0);
    final adjustedFontSize = _fontSizeForType(block.type, baseFontSize);
    final maxBoxWidth = math.max(72.0, canvasSize.width * 0.82);
    final minBoxWidth = math.min(
      maxBoxWidth,
      math.max(72.0, canvasSize.width * (interactive ? 0.18 : 0.12)),
    );
    final boxWidth = (block.widthFactor * canvasSize.width)
        .clamp(minBoxWidth, maxBoxWidth)
        .toDouble();
    final leftPosition = (block.position.dx * canvasSize.width)
        .clamp(0.0, math.max(0.0, canvasSize.width - boxWidth))
        .toDouble();
    final effectiveTextAlpha = textOpacity <= 0
        ? 0.0
        : block.text.trim().isEmpty
            ? math.max(0.42, textOpacity * 0.52)
            : textOpacity;
    final resolvedTextColor = _presentationTextColor(block.textColorHex) ??
        (darkSurface ? Colors.white : context.onSurface);
    final textColor = resolvedTextColor.withValues(
      alpha: effectiveTextAlpha,
    );
    final displayStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: textColor,
          fontWeight: _fontWeightForType(block.type),
          fontSize: adjustedFontSize,
          height: _lineHeightForType(block.type),
          letterSpacing: _letterSpacingForType(block.type),
        );
    final editingStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: resolvedTextColor,
          fontWeight: _fontWeightForType(block.type),
          fontSize: adjustedFontSize,
          height: _lineHeightForType(block.type),
          letterSpacing: _letterSpacingForType(block.type),
        );
    final blockChild = isEditing
        ? TextField(
            controller: editingController,
            focusNode: editingFocusNode,
            autofocus: true,
            minLines: 1,
            maxLines: null,
            onChanged: onInlineTextChanged,
            style: editingStyle,
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: tr('Buraya metin yazın', 'Type text here'),
              hintStyle: TextStyle(
                color: resolvedTextColor.withValues(alpha: 0.52),
                fontWeight: FontWeight.w600,
              ),
            ),
            cursorColor: context.primary,
          )
        : Text(
            displayText,
            style: displayStyle,
          );
    final textPainter = TextPainter(
      text: TextSpan(text: displayText, style: displayStyle),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: math.max(0, boxWidth - (paddingX * 2)));
    final naturalHeight = textPainter.height + (paddingY * 2);
    final maxH = math.max(1.0, canvasSize.height * 0.86);
    final minH = math.min(44.0, maxH);
    final boxHeight = block.heightFactor == null
        ? naturalHeight
        : (block.heightFactor! * canvasSize.height)
            .clamp(minH, maxH)
            .toDouble();
    final topPosition = (block.position.dy * canvasSize.height)
        .clamp(0.0, math.max(0.0, canvasSize.height - boxHeight))
        .toDouble();
    final showResizeHandles =
        interactive && isSelected && !isEditing && onResizeUpdate != null;
    final gripHitSize = showResizeHandles ? 40.0 : 0.0;
    final gripInset = gripHitSize / 2;

    return Positioned(
      left: leftPosition - gripInset,
      top: topPosition - gripInset,
      width: boxWidth + gripHitSize,
      height: boxHeight + gripHitSize,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: gripInset,
            top: gripInset,
            width: boxWidth,
            height: boxHeight,
            child: MouseRegion(
              cursor: interactive
                  ? (isSelected
                      ? SystemMouseCursors.move
                      : SystemMouseCursors.click)
                  : MouseCursor.defer,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onTap,
                onDoubleTap: onDoubleTap,
                onSecondaryTapDown: onSecondaryTapDown,
                onPanStart: (details) {
                  if (!isSelected) onTap?.call();
                },
                onPanUpdate: onPanUpdate,
                child: AnimatedContainer(
                  duration: isSelected
                      ? Duration.zero
                      : const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingX,
                    vertical: paddingY,
                  ),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: showSelectionBorder && isSelected
                        ? context.primary.withValues(
                            alpha: isEditing ? 0.04 : 0.08,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: showSelectionBorder
                          ? (isSelected ? context.primary : Colors.transparent)
                          : Colors.transparent,
                      width: isSelected ? 1.6 : 1,
                    ),
                  ),
                  child: blockChild,
                ),
              ),
            ),
          ),
          if (showResizeHandles)
            for (final handle in _ComponentResizeHandle.values)
              _ComponentResizeGrip(
                handle: handle,
                onPanUpdate: onResizeUpdate == null
                    ? null
                    : (details) => onResizeUpdate!(
                          handle,
                          details,
                          boxHeight / canvasSize.height,
                        ),
              ),
        ],
      ),
    );
  }
}

Color? _presentationTextColor(String? hex) {
  if (hex == null || hex.trim().isEmpty) return null;
  var value = hex.trim().replaceAll('#', '');
  if (value.startsWith('0x') || value.startsWith('0X')) {
    value = value.substring(2);
  }
  if (value.length == 3) {
    value = '${value[0]}${value[0]}${value[1]}${value[1]}'
        '${value[2]}${value[2]}';
  }
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final colorValue = int.tryParse(value, radix: 16);
  return colorValue == null ? null : Color(colorValue);
}

class _PageComponentBlock extends StatelessWidget {
  const _PageComponentBlock({
    required this.block,
    required this.canvasSize,
    required this.isSelected,
    required this.interactive,
    required this.showSelectionBorder,
    required this.opacity,
    required this.showResizeHandles,
    this.onTap,
    this.onSecondaryTapDown,
    this.onToggleOrbit,
    this.onOrbitPanStart,
    this.onOrbitPanUpdate,
    this.onOrbitPanEnd,
    this.onPanUpdate,
    this.onResizeUpdate,
  });

  final PresentationComponentBlock block;
  final Size canvasSize;
  final bool isSelected;
  final bool interactive;
  final bool showSelectionBorder;
  final double opacity;
  final bool showResizeHandles;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final VoidCallback? onToggleOrbit;
  final GestureDragStartCallback? onOrbitPanStart;
  final GestureDragUpdateCallback? onOrbitPanUpdate;
  final GestureDragEndCallback? onOrbitPanEnd;
  final GestureDragUpdateCallback? onPanUpdate;
  final void Function(_ComponentResizeHandle handle, DragUpdateDetails details)?
      onResizeUpdate;

  @override
  Widget build(BuildContext context) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return const SizedBox.shrink();
    }
    final isImage = _isCanvasImageBlock(block);
    final imageSourceId = block.imageAssetId ?? block.modelAssetId;
    final imageSource = imageSourceId == null
        ? null
        : RemoteImageSources.sourceFor(imageSourceId);
    final minW = math.min(54.0, canvasSize.width);
    final minH = math.min(44.0, canvasSize.height);
    final width = (block.size.width * canvasSize.width)
        .clamp(minW, canvasSize.width)
        .toDouble();
    final height = (block.size.height * canvasSize.height)
        .clamp(minH, canvasSize.height)
        .toDouble();
    final left = (block.position.dx * canvasSize.width)
        .clamp(0.0, math.max(0.0, canvasSize.width - width))
        .toDouble();
    final top = (block.position.dy * canvasSize.height)
        .clamp(0.0, math.max(0.0, canvasSize.height - height))
        .toDouble();
    final visibleOpacity = opacity.clamp(0.0, 1.0).toDouble();
    final showHandles = showSelectionBorder && isSelected && showResizeHandles;
    final gripHitSize = showHandles ? 40.0 : 0.0;
    final gripInset = gripHitSize / 2;

    return Positioned(
      left: left - gripInset,
      top: top - gripInset,
      width: width + gripHitSize,
      height: height + gripHitSize,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: gripInset,
            top: gripInset,
            width: width,
            height: height,
            child: MouseRegion(
              cursor: interactive
                  ? (_isRenderableCanvasModelBlock(block) &&
                          block.modelOrbitEnabled
                      ? SystemMouseCursors.grab
                      : isSelected
                          ? SystemMouseCursors.move
                          : SystemMouseCursors.click)
                  : MouseCursor.defer,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onTap,
                onSecondaryTapDown: onSecondaryTapDown,
                onPanStart: onOrbitPanStart ??
                    (onPanUpdate == null
                        ? null
                        : (_) {
                            if (!isSelected) onTap?.call();
                          }),
                onPanUpdate: onOrbitPanUpdate ?? onPanUpdate,
                onPanEnd: onOrbitPanEnd,
                onPanCancel: onOrbitPanEnd == null
                    ? null
                    : () => onOrbitPanEnd!(
                          DragEndDetails(velocity: Velocity.zero),
                        ),
                child: AnimatedContainer(
                  duration: isSelected
                      ? Duration.zero
                      : const Duration(milliseconds: 140),
                  decoration: BoxDecoration(
                    color: isSelected && showSelectionBorder
                        ? context.primary
                            .withValues(alpha: isImage ? 0.025 : 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(isImage ? 8 : 18),
                    border: Border.all(
                      color: showSelectionBorder && isSelected
                          ? context.primary
                          : Colors.transparent,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Opacity(
                    opacity: visibleOpacity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isImage ? 6 : 16),
                      child: isImage && imageSource != null
                          ? Image.network(
                              imageSource,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            )
                          : isImage
                              ? const SizedBox.expand()
                              : !_isRenderableCanvasModelBlock(block)
                                  ? CustomPaint(
                                      painter: ComponentBlockPreviewPainter(
                                          kind: block.kind),
                                    )
                                  : DecoratedBox(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: <Color>[
                                            Color(0xFF13294B),
                                            Color(0xFF247BCE),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          findPresentation3DModelAsset(
                                                block.modelAssetId!,
                                              )?.icon ??
                                              Icons.view_in_ar_rounded,
                                          color: Colors.white,
                                          size: 34,
                                        ),
                                      ),
                                    ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showHandles &&
              _isRenderableCanvasModelBlock(block) &&
              !isImage &&
              onToggleOrbit != null)
            Align(
              alignment: Alignment.center,
              child: Tooltip(
                message: block.modelOrbitEnabled
                    ? 'Fareyle incelemeyi kapat'
                    : 'Fareyle 360° incele',
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: onToggleOrbit,
                    onPanStart: onOrbitPanStart,
                    onPanUpdate: onOrbitPanUpdate,
                    onPanEnd: onOrbitPanEnd,
                    onPanCancel: onOrbitPanEnd == null
                        ? null
                        : () => onOrbitPanEnd!(
                              DragEndDetails(velocity: Velocity.zero),
                            ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: block.modelOrbitEnabled
                              ? const <Color>[
                                  Color(0xE6087CF0),
                                  Color(0xE67047EB),
                                ]
                              : const <Color>[
                                  Color(0xEFFFFFFF),
                                  Color(0xE8EEF5FF),
                                ],
                        ),
                        border: Border.all(
                          color: block.modelOrbitEnabled
                              ? Colors.white
                              : context.primary,
                          width: 1.5,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x38000000),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          if (block.modelOrbitEnabled) ...<Widget>[
                            const Icon(
                              Icons.threesixty_rounded,
                              size: 31,
                              color: Colors.white,
                            ),
                            const Icon(
                              Icons.pan_tool_alt_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                          ] else ...<Widget>[
                            Icon(
                              Icons.threesixty_rounded,
                              size: 31,
                              color: context.primary,
                            ),
                            Icon(
                              Icons.touch_app_rounded,
                              size: 16,
                              color: context.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showHandles)
            for (final handle in _ComponentResizeHandle.values)
              _ComponentResizeGrip(
                handle: handle,
                onPanUpdate: onResizeUpdate == null
                    ? null
                    : (details) => onResizeUpdate!(handle, details),
              ),
        ],
      ),
    );
  }
}

class _ComponentResizeGrip extends StatelessWidget {
  const _ComponentResizeGrip({
    required this.handle,
    this.onPanUpdate,
  });

  final _ComponentResizeHandle handle;
  final GestureDragUpdateCallback? onPanUpdate;

  @override
  Widget build(BuildContext context) {
    final isHorizontal = handle == _ComponentResizeHandle.left ||
        handle == _ComponentResizeHandle.right;
    final isVertical = handle == _ComponentResizeHandle.top ||
        handle == _ComponentResizeHandle.bottom;

    return Align(
      alignment: _componentResizeAlignment(handle),
      child: MouseRegion(
        cursor: _componentResizeCursor(handle),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: onPanUpdate,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Container(
                width: isVertical ? 24 : 14,
                height: isHorizontal ? 24 : 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: context.primary, width: 1.6),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Alignment _componentResizeAlignment(_ComponentResizeHandle handle) {
  switch (handle) {
    case _ComponentResizeHandle.topLeft:
      return Alignment.topLeft;
    case _ComponentResizeHandle.top:
      return Alignment.topCenter;
    case _ComponentResizeHandle.topRight:
      return Alignment.topRight;
    case _ComponentResizeHandle.right:
      return Alignment.centerRight;
    case _ComponentResizeHandle.bottomRight:
      return Alignment.bottomRight;
    case _ComponentResizeHandle.bottom:
      return Alignment.bottomCenter;
    case _ComponentResizeHandle.bottomLeft:
      return Alignment.bottomLeft;
    case _ComponentResizeHandle.left:
      return Alignment.centerLeft;
  }
}

MouseCursor _componentResizeCursor(_ComponentResizeHandle handle) {
  switch (handle) {
    case _ComponentResizeHandle.topLeft:
    case _ComponentResizeHandle.bottomRight:
      return SystemMouseCursors.resizeUpLeftDownRight;
    case _ComponentResizeHandle.topRight:
    case _ComponentResizeHandle.bottomLeft:
      return SystemMouseCursors.resizeUpRightDownLeft;
    case _ComponentResizeHandle.left:
    case _ComponentResizeHandle.right:
      return SystemMouseCursors.resizeLeftRight;
    case _ComponentResizeHandle.top:
    case _ComponentResizeHandle.bottom:
      return SystemMouseCursors.resizeUpDown;
  }
}

bool _componentResizeFromLeft(_ComponentResizeHandle handle) {
  return handle == _ComponentResizeHandle.left ||
      handle == _ComponentResizeHandle.topLeft ||
      handle == _ComponentResizeHandle.bottomLeft;
}

bool _componentResizeFromTop(_ComponentResizeHandle handle) {
  return handle == _ComponentResizeHandle.top ||
      handle == _ComponentResizeHandle.topLeft ||
      handle == _ComponentResizeHandle.topRight;
}

bool _componentResizeFromRight(_ComponentResizeHandle handle) {
  return handle == _ComponentResizeHandle.right ||
      handle == _ComponentResizeHandle.topRight ||
      handle == _ComponentResizeHandle.bottomRight;
}

bool _componentResizeFromBottom(_ComponentResizeHandle handle) {
  return handle == _ComponentResizeHandle.bottom ||
      handle == _ComponentResizeHandle.bottomLeft ||
      handle == _ComponentResizeHandle.bottomRight;
}

class ComponentBlockPreviewPainter extends CustomPainter {
  const ComponentBlockPreviewPainter({
    required this.kind,
  });

  final PresentationComponentKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    if (presentationComponentIsSticker(kind) &&
        !presentationComponentIsAssetPack(kind)) {
      _drawSticker(canvas, size);
      return;
    }

    final colors = presentationComponentPreviewColors(kind);
    final bg = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final accent = colors.last;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, size.width * 0.006)
      ..color = accent.withValues(alpha: 0.78);
    final fill = Paint()..color = accent.withValues(alpha: 0.72);
    final category = presentationComponentCategory(kind);

    if (category == 'Fizik') {
      _drawPhysics(canvas, size, paint, fill);
    } else if (category == 'Optik') {
      _drawOptics(canvas, size, paint);
    } else if (category == 'Gunes') {
      _drawSolar(canvas, size, paint, fill);
    } else if (category == 'Uzay') {
      _drawSpace(canvas, size, paint, fill);
    } else {
      _drawScience(canvas, size, paint, fill);
    }
  }

  void _drawSticker(Canvas canvas, Size size) {
    _drawScience(
      canvas,
      size,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.3, size.width * 0.006)
        ..color = const Color(0xFFFFD166).withValues(alpha: 0.78),
      Paint()..color = const Color(0xFFFFD166).withValues(alpha: 0.72),
    );
  }

  void _drawPhysics(Canvas canvas, Size size, Paint paint, Paint fill) {
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.62),
      Offset(size.width * 0.84, size.height * 0.48),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.48, size.height * 0.76)
        ..lineTo(size.width * 0.56, size.height * 0.76)
        ..lineTo(size.width * 0.52, size.height * 0.58)
        ..close(),
      fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.70, size.height * 0.34),
      size.shortestSide * 0.11,
      paint,
    );
  }

  void _drawOptics(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF7EFFF5).withValues(alpha: 0.78);
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.28),
      Offset(size.width * 0.48, size.height * 0.52),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.52),
      Offset(size.width * 0.88, size.height * 0.30),
      paint,
    );
    paint.color = const Color(0xFFFF7EB3).withValues(alpha: 0.78);
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.16),
      Offset(size.width * 0.48, size.height * 0.86),
      paint,
    );
  }

  void _drawSolar(Canvas canvas, Size size, Paint paint, Paint fill) {
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      size.shortestSide * 0.12,
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.62,
          size.width * 0.58,
          size.height * 0.16,
        ),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawSpace(Canvas canvas, Size size, Paint paint, Paint fill) {
    final planet = Paint()..color = const Color(0xFFFFB347);
    canvas.drawCircle(
      Offset(size.width * 0.70, size.height * 0.30),
      size.shortestSide * 0.14,
      planet,
    );
    final rocket = Path()
      ..moveTo(size.width * 0.34, size.height * 0.24)
      ..quadraticBezierTo(size.width * 0.48, size.height * 0.48,
          size.width * 0.32, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.48,
          size.width * 0.34, size.height * 0.24)
      ..close();
    canvas.drawPath(
        rocket, Paint()..color = Colors.white.withValues(alpha: 0.82));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.26, size.height * 0.74),
        width: size.width * 0.08,
        height: size.height * 0.20,
      ),
      fill,
    );
  }

  void _drawScience(Canvas canvas, Size size, Paint paint, Paint fill) {
    final center = Offset(size.width * 0.50, size.height * 0.50);
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.52,
        height: size.height * 0.52,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(cardRect, paint);
    canvas.drawCircle(center, size.shortestSide * 0.10, fill);
  }

  @override
  bool shouldRepaint(covariant ComponentBlockPreviewPainter oldDelegate) {
    return oldDelegate.kind != kind;
  }
}

class _CanvasBackgroundPreview extends StatelessWidget {
  const _CanvasBackgroundPreview({
    required this.kind,
    required this.colorsInverted,
  });

  final PresentationBackgroundKind kind;
  final bool colorsInverted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CanvasBackgroundPreviewPainter(
        kind: kind,
        colorsInverted: colorsInverted,
      ),
    );
  }
}

class _CanvasBackgroundPreviewPainter extends CustomPainter {
  const _CanvasBackgroundPreviewPainter({
    required this.kind,
    required this.colorsInverted,
  });

  final PresentationBackgroundKind kind;
  final bool colorsInverted;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = presentationBackgroundVariantPreviewColors(
      kind,
      colorsInverted: colorsInverted,
    ).last;
    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.28),
      size.shortestSide * 0.20,
      glowPaint,
    );

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, size.width * 0.0016)
      ..color = accent.withValues(alpha: 0.34);

    _drawPackPreview(canvas, size, linePaint, accent);
  }

  void _drawPackPreview(
    Canvas canvas,
    Size size,
    Paint paint,
    Color accent,
  ) {
    paint.color = accent.withValues(alpha: 0.52);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.30),
      size.shortestSide * 0.08,
      Paint()..color = accent.withValues(alpha: 0.58),
    );
    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.46,
        size.width * 0.54,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.84,
        size.width * 0.88,
        size.height * 0.54,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CanvasBackgroundPreviewPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.colorsInverted != colorsInverted;
  }
}

class _PageGridPainter extends CustomPainter {
  const _PageGridPainter({
    required this.darkMode,
  });

  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = darkMode
          ? Colors.white.withValues(alpha: 0.055)
          : const Color(0xFFF0F4FA)
      ..strokeWidth = 1;
    final guidePaint = Paint()
      ..color = darkMode
          ? Colors.white.withValues(alpha: 0.10)
          : const Color(0xFFE7EDF6)
      ..strokeWidth = 1.2;

    const int divisions = 8;
    for (var index = 1; index < divisions; index += 1) {
      final dx = size.width * index / divisions;
      final dy = size.height * index / divisions;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), linePaint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
    }

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PageGridPainter oldDelegate) {
    return oldDelegate.darkMode != darkMode;
  }
}

bool _isDarkCanvasBackground(PresentationPage page) {
  return presentationBackgroundVariantIsDark(
    page.backgroundKind,
    colorsInverted: page.backgroundColorsInverted,
  );
}

String _textStyleLabel(PresentationTextStyle style) {
  final googleFontFamily = presentationGoogleFontFamily(style);
  if (googleFontFamily != null) return googleFontFamily;
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
    case PresentationTextStyle.klasikTinos:
      return 'Tinos (Times New Roman)';
    case PresentationTextStyle.klasikArimo:
      return 'Arimo (Arial)';
    case PresentationTextStyle.klasikCousine:
      return 'Cousine (Courier New)';
    case PresentationTextStyle.klasikCarlito:
      return 'Carlito (Calibri)';
    case PresentationTextStyle.klasikCaladea:
      return 'Caladea (Cambria)';
    case PresentationTextStyle.klasikEBGaramond:
      return 'EB Garamond';
    case PresentationTextStyle.klasikLibreBaskerville:
      return 'Libre Baskerville';
    case PresentationTextStyle.klasikAlegreya:
      return 'Alegreya';
    case PresentationTextStyle.klasikPTSerif:
      return 'PT Serif';
    case PresentationTextStyle.klasikMerriweather:
      return 'Merriweather';
    case PresentationTextStyle.klasikLora:
      return 'Lora';
    case PresentationTextStyle.klasikGreatVibes:
      return 'Great Vibes';
    case PresentationTextStyle.klasikDancingScript:
      return 'Dancing Script';
    case PresentationTextStyle.klasikPacifico:
      return 'Pacifico';
    case PresentationTextStyle.klasikLobster:
      return 'Lobster';
    default:
      return style.name;
  }
}

FontWeight _fontWeightForType(PresentationTextType type) {
  switch (type) {
    case PresentationTextType.title:
      return FontWeight.w800;
    case PresentationTextType.subtitle:
      return FontWeight.w700;
    case PresentationTextType.body:
      return FontWeight.w600;
  }
}

double _fontSizeForType(PresentationTextType type, double fontSize) {
  switch (type) {
    case PresentationTextType.title:
      return fontSize;
    case PresentationTextType.subtitle:
      return fontSize * 0.9;
    case PresentationTextType.body:
      return fontSize * 0.82;
  }
}

double _lineHeightForType(PresentationTextType type) {
  switch (type) {
    case PresentationTextType.title:
      return 1.06;
    case PresentationTextType.subtitle:
      return 1.12;
    case PresentationTextType.body:
      return 1.24;
  }
}

double _letterSpacingForType(PresentationTextType type) {
  switch (type) {
    case PresentationTextType.title:
      return -0.4;
    case PresentationTextType.subtitle:
      return -0.1;
    case PresentationTextType.body:
      return 0;
  }
}
