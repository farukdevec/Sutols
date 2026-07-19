import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/design_system.dart';
import '../models/slide_model.dart';
import '../services/presentation_fullscreen_service.dart';
import '../state/presentation_controller.dart';
import 'widgets/html_stage/html_page_stage.dart';

class PresentationPreviewPage extends StatefulWidget {
  const PresentationPreviewPage({
    super.key,
    required this.controller,
  });

  final PresentationController controller;

  @override
  State<PresentationPreviewPage> createState() =>
      _PresentationPreviewPageState();
}

class _PresentationPreviewPageState extends State<PresentationPreviewPage> {
  late final FocusNode _focusNode;
  late int _index;
  int _fragmentStep = 0;
  bool _zoomed = false;
  bool _showControls = true;
  bool _presenterMode = false;
  PresentationPage? _transitionFromPage;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Sutol presentation preview');
    _index = widget.controller.selectedIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNode.requestFocus();
      requestPresentationFullscreen();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    exitPresentationFullscreen();
    super.dispose();
  }

  void _goTo(
    int nextIndex, {
    int revealStep = 0,
  }) {
    final pageCount = widget.controller.pages.length;
    if (pageCount == 0) {
      return;
    }
    final clamped = nextIndex.clamp(0, pageCount - 1).toInt();
    if (clamped == _index) {
      return;
    }
    final previousPage = widget.controller.pages[_index];
    setState(() {
      _transitionFromPage = previousPage;
      _index = clamped;
      _fragmentStep = revealStep.clamp(
        0,
        widget.controller.revealStepCountForPage(
          widget.controller.pages[clamped],
        ),
      );
      _zoomed = false;
    });
  }

  void _goToPageId(String pageId) {
    final index =
        widget.controller.pages.indexWhere((page) => page.id == pageId);
    if (index >= 0) {
      _goTo(index);
    }
  }

  void _next() {
    final pages = widget.controller.pages;
    if (pages.isEmpty) {
      return;
    }
    final safeIndex = math.min(_index, pages.length - 1);
    final maxStep = widget.controller.revealStepCountForPage(pages[safeIndex]);
    if (_fragmentStep < maxStep) {
      setState(() {
        _fragmentStep += 1;
        _zoomed = false;
      });
      return;
    }
    _goTo(safeIndex + 1);
  }

  void _previous() {
    if (_fragmentStep > 0) {
      setState(() {
        _fragmentStep -= 1;
        _zoomed = false;
      });
      return;
    }

    final previousIndex = _index - 1;
    if (previousIndex < 0 || previousIndex >= widget.controller.pages.length) {
      return;
    }
    final previousPage = widget.controller.pages[previousIndex];
    _goTo(
      previousIndex,
      revealStep: widget.controller.revealStepCountForPage(previousPage),
    );
  }

  void _toggleZoom() {
    if (!widget.controller.effectSettings.zoomEnabled) {
      return;
    }
    setState(() {
      _zoomed = !_zoomed;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _togglePresenterMode() {
    setState(() {
      _presenterMode = !_presenterMode;
      _showControls = true;
    });
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.space) {
      _next();
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.backspace) {
      _previous();
    } else if (key == LogicalKeyboardKey.escape) {
      _zoomed ? _toggleZoom() : _close();
    } else if (key == LogicalKeyboardKey.keyZ ||
        key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.add) {
      _toggleZoom();
    } else if (key == LogicalKeyboardKey.keyF) {
      requestPresentationFullscreen();
    } else if (key == LogicalKeyboardKey.keyH) {
      _toggleControls();
    } else if (key == LogicalKeyboardKey.keyP ||
        key == LogicalKeyboardKey.keyN) {
      _togglePresenterMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final colors = context.sutolColors;
        final pages = widget.controller.pages;
        final effectSettings = widget.controller.effectSettings;
        final reduceMotion = _shouldReducePreviewMotion(
          context,
          effectSettings,
        );
        final pageCount = pages.length;
        final safeIndex =
            pageCount == 0 ? 0 : math.min(_index, math.max(0, pageCount - 1));
        final page = pageCount == 0 ? null : pages[safeIndex];
        final maxFragmentStep =
            page == null ? 0 : widget.controller.revealStepCountForPage(page);
        if (_fragmentStep > maxFragmentStep) {
          _fragmentStep = maxFragmentStep;
        }

        return Scaffold(
          backgroundColor: colors.background,
          body: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.background,
                    ),
                    child: page == null
                        ? Center(
                            child: Text(
                              'Sunumda sayfa yok.',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          )
                        : _PreviewDeckStage(
                            page: page,
                            transitionFromPage: _transitionFromPage,
                            currentIndex: safeIndex,
                            pageCount: pageCount,
                            currentRevealStep: _fragmentStep,
                            effectSettings: effectSettings,
                            reduceMotion: reduceMotion,
                            zoomed: _zoomed,
                            onToggleZoom: _toggleZoom,
                            onHotspot: _goToPageId,
                            showHotspots: _showControls,
                          ),
                  ),
                  if (_showControls && _presenterMode)
                    _PreviewTopBar(
                      currentIndex: safeIndex,
                      pageCount: pageCount,
                      currentRevealStep: _fragmentStep,
                      maxRevealStep: maxFragmentStep,
                      effectSettings: effectSettings,
                      zoomed: _zoomed,
                      hasNotes: page?.speakerNotes.trim().isNotEmpty ?? false,
                      presenterMode: _presenterMode,
                      onClose: _close,
                      onToggleZoom:
                          effectSettings.zoomEnabled ? _toggleZoom : null,
                      onFullscreen: requestPresentationFullscreen,
                      onTogglePresenter: _togglePresenterMode,
                    ),
                  if (_showControls && _presenterMode && page != null)
                    _PreviewPresenterPanel(
                      page: page,
                      nextPage: safeIndex + 1 < pageCount
                          ? pages[safeIndex + 1]
                          : null,
                    ),
                  if (_showControls && pageCount > 0)
                    _PreviewBottomBar(
                      currentIndex: safeIndex,
                      pageCount: pageCount,
                      onPrevious:
                          safeIndex > 0 || _fragmentStep > 0 ? _previous : null,
                      onNext: safeIndex < pageCount - 1 ||
                              _fragmentStep < maxFragmentStep
                          ? _next
                          : null,
                      onSelect: _goTo,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewDeckStage extends StatelessWidget {
  const _PreviewDeckStage({
    required this.page,
    required this.transitionFromPage,
    required this.currentIndex,
    required this.pageCount,
    required this.currentRevealStep,
    required this.effectSettings,
    required this.reduceMotion,
    required this.zoomed,
    required this.onToggleZoom,
    required this.onHotspot,
    required this.showHotspots,
  });

  final PresentationPage page;
  final PresentationPage? transitionFromPage;
  final int currentIndex;
  final int pageCount;
  final int currentRevealStep;
  final PresentationEffectSettings effectSettings;
  final bool reduceMotion;
  final bool zoomed;
  final VoidCallback onToggleZoom;
  final ValueChanged<String> onHotspot;
  final bool showHotspots;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion ||
            effectSettings.transitionKind == PresentationTransitionKind.none
        ? SutolMotion.instant
        : Duration(milliseconds: effectSettings.transitionDurationMs);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ClipRect(
            child: Semantics(
              label: 'Sunum sayfasi ${currentIndex + 1} / $pageCount',
              button: effectSettings.zoomEnabled,
              hint: effectSettings.zoomEnabled
                  ? (zoomed ? 'Zoomu kapat' : 'Zoom yap')
                  : null,
              onTap: effectSettings.zoomEnabled ? onToggleZoom : null,
              child: MouseRegion(
                cursor: effectSettings.zoomEnabled
                    ? (zoomed
                        ? SystemMouseCursors.zoomOut
                        : SystemMouseCursors.zoomIn)
                    : SystemMouseCursors.basic,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: effectSettings.zoomEnabled ? onToggleZoom : null,
                  child: AnimatedSwitcher(
                    duration: duration,
                    transitionBuilder: (child, animation) =>
                        _buildPreviewTransition(
                      kind: effectSettings.transitionKind,
                      animation: animation,
                      reduceMotion: reduceMotion,
                      child: child,
                    ),
                    child: KeyedSubtree(
                      key: ValueKey<String>('preview-${page.id}'),
                      child: AnimatedScale(
                        scale: zoomed ? effectSettings.zoomScale : 1,
                        duration: reduceMotion
                            ? SutolMotion.instant
                            : SutolMotion.moderate,
                        curve: SutolMotion.easeOut,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            if (effectSettings.transitionKind ==
                                    PresentationTransitionKind.smooth &&
                                transitionFromPage != null &&
                                !reduceMotion)
                              _SmoothModelMorphStage(
                                key: ValueKey<String>(
                                  'smooth-morph-${page.id}',
                                ),
                                fromPage: transitionFromPage!,
                                toPage: page,
                                visibleRevealStep: currentRevealStep,
                                duration: duration,
                              )
                            else
                              HtmlPageStage(
                                page: page,
                                visibleRevealStep: currentRevealStep,
                                showBadge: false,
                                renderMode: HtmlStageRenderMode.preview,
                              ),
                            if (showHotspots)
                              _PreviewHotspotOverlay(
                                page: page,
                                currentRevealStep: currentRevealStep,
                                onHotspot: onHotspot,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SmoothModelMorphStage extends StatelessWidget {
  const _SmoothModelMorphStage({
    super.key,
    required this.fromPage,
    required this.toPage,
    required this.visibleRevealStep,
    required this.duration,
  });

  final PresentationPage fromPage;
  final PresentationPage toPage;
  final int visibleRevealStep;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: SutolMotion.easeInOut,
      builder: (context, progress, _) => HtmlPageStage(
        page: _interpolateModelPages(fromPage, toPage, progress),
        visibleRevealStep: visibleRevealStep,
        showBadge: false,
        renderMode: HtmlStageRenderMode.preview,
      ),
    );
  }
}

PresentationPage _interpolateModelPages(
  PresentationPage from,
  PresentationPage to,
  double progress,
) {
  final availableSources = <PresentationComponentBlock>[
    ...from.componentBlocks.where((block) => block.modelAssetId != null),
  ];
  final nextComponents = to.componentBlocks.map((target) {
    if (target.modelAssetId == null) {
      return target;
    }
    final sourceIndex = availableSources.indexWhere(
      (source) => source.modelAssetId == target.modelAssetId,
    );
    if (sourceIndex < 0) {
      return target;
    }
    final source = availableSources.removeAt(sourceIndex);
    final thetaDelta =
        ((target.modelOrbitTheta - source.modelOrbitTheta + 540) % 360) - 180;
    return target.copyWith(
      position: Offset.lerp(source.position, target.position, progress),
      size: Size.lerp(source.size, target.size, progress),
      modelOrbitTheta: source.modelOrbitTheta + thetaDelta * progress,
      modelOrbitPhi: source.modelOrbitPhi +
          (target.modelOrbitPhi - source.modelOrbitPhi) * progress,
    );
  }).toList(growable: false);
  return to.copyWith(componentBlocks: nextComponents);
}

class _PreviewHotspotOverlay extends StatelessWidget {
  const _PreviewHotspotOverlay({
    required this.page,
    required this.currentRevealStep,
    required this.onHotspot,
  });

  final PresentationPage page;
  final int currentRevealStep;
  final ValueChanged<String> onHotspot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            for (final block in page.textBlocks)
              if (_isPreviewHotspotVisible(
                revealStep: block.revealStep,
                currentRevealStep: currentRevealStep,
                targetPageId: block.hotspotTargetPageId,
                currentPageId: page.id,
              ))
                _PreviewHotspotRegion(
                  rect: _textHotspotRect(block, size),
                  label: block.text.trim().isEmpty ? 'Hotspot' : block.text,
                  onTap: () => onHotspot(block.hotspotTargetPageId!),
                ),
            for (final block in page.componentBlocks)
              if (_isPreviewHotspotVisible(
                revealStep: block.revealStep,
                currentRevealStep: currentRevealStep,
                targetPageId: block.hotspotTargetPageId,
                currentPageId: page.id,
              ))
                _PreviewHotspotRegion(
                  rect: _componentHotspotRect(block, size),
                  label: presentationComponentLabel(block.kind),
                  onTap: () => onHotspot(block.hotspotTargetPageId!),
                ),
          ],
        );
      },
    );
  }
}

class _PreviewHotspotRegion extends StatelessWidget {
  const _PreviewHotspotRegion({
    required this.rect,
    required this.label,
    required this.onTap,
  });

  final Rect rect;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sutolColors;
    return Positioned.fromRect(
      rect: rect,
      child: Tooltip(
        message: label,
        child: Semantics(
          label: label,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(SutolRadius.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SutolRadius.lg),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(context.sm),
                    child: Icon(
                      Icons.ads_click_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewTopBar extends StatelessWidget {
  const _PreviewTopBar({
    required this.currentIndex,
    required this.pageCount,
    required this.currentRevealStep,
    required this.maxRevealStep,
    required this.effectSettings,
    required this.zoomed,
    required this.hasNotes,
    required this.presenterMode,
    required this.onClose,
    required this.onToggleZoom,
    required this.onFullscreen,
    required this.onTogglePresenter,
  });

  final int currentIndex;
  final int pageCount;
  final int currentRevealStep;
  final int maxRevealStep;
  final PresentationEffectSettings effectSettings;
  final bool zoomed;
  final bool hasNotes;
  final bool presenterMode;
  final VoidCallback onClose;
  final VoidCallback? onToggleZoom;
  final VoidCallback onFullscreen;
  final VoidCallback onTogglePresenter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.lg, context.md, context.lg, 0),
          child: Row(
            children: <Widget>[
              _PreviewControlButton(
                icon: Icons.close_rounded,
                label: 'Cikis',
                onTap: onClose,
              ),
              SizedBox(width: context.md),
              _PreviewInfoPill(
                icon: Icons.slideshow_rounded,
                label: '${currentIndex + 1} / $pageCount',
              ),
              SizedBox(width: context.md),
              _PreviewInfoPill(
                icon: presentationTransitionIcon(effectSettings.transitionKind),
                label: presentationTransitionLabel(effectSettings.transitionKind),
              ),
              if (maxRevealStep > 0) ...<Widget>[
                SizedBox(width: context.md),
                _PreviewInfoPill(
                  icon: Icons.auto_awesome_rounded,
                  label: '$currentRevealStep / $maxRevealStep',
                ),
              ],
              const Spacer(),
              _PreviewControlButton(
                icon: presenterMode
                    ? Icons.speaker_notes_off_rounded
                    : Icons.speaker_notes_rounded,
                label: hasNotes || presenterMode ? 'Notlar' : 'Presenter',
                onTap: onTogglePresenter,
              ),
              SizedBox(width: context.md),
              if (onToggleZoom != null) ...<Widget>[
                _PreviewControlButton(
                  icon: zoomed
                      ? Icons.zoom_in_map_rounded
                      : Icons.zoom_out_map_rounded,
                  label: zoomed ? 'Zoom Kapat' : 'Zoom',
                  onTap: onToggleZoom!,
                ),
                SizedBox(width: context.md),
              ],
              _PreviewControlButton(
                icon: Icons.fullscreen_rounded,
                label: 'Tam Ekran',
                onTap: onFullscreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPresenterPanel extends StatelessWidget {
  const _PreviewPresenterPanel({
    required this.page,
    required this.nextPage,
  });

  final PresentationPage page;
  final PresentationPage? nextPage;

  @override
  Widget build(BuildContext context) {
    final notes = page.speakerNotes.trim();
    final colors = context.sutolColors;

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.xl, 74, context.xl, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SutolRadius.xl),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.all(context.xl),
                  decoration: context.decoration.glass(
                    borderRadius: SutolRadius.xl,
                    opacity: 0.7,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sunucu Notu',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                      SizedBox(height: context.sm),
                      Text(
                        notes.isEmpty ? 'Not yok.' : notes,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              height: 1.5,
                            ),
                      ),
                      SizedBox(height: context.xl),
                      Text(
                        'Sonraki',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                      SizedBox(height: context.xs),
                      Text(
                        nextPage == null
                            ? 'Sunum sonu'
                            : _previewPageTitle(nextPage!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewBottomBar extends StatelessWidget {
  const _PreviewBottomBar({
    required this.currentIndex,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  final int currentIndex;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.xl, 0, context.xl, context.xl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SutolRadius.full),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: context.decoration.glass(
                  borderRadius: SutolRadius.full,
                  opacity: 0.6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _PreviewIconButton(
                      icon: Icons.arrow_back_rounded,
                      label: 'Onceki slayt',
                      onTap: onPrevious,
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List<Widget>.generate(
                            pageCount,
                            (index) => _PreviewDot(
                              index: index,
                              isSelected: index == currentIndex,
                              label: 'Slayt ${index + 1}',
                              onTap: () => onSelect(index),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PreviewIconButton(
                      icon: Icons.arrow_forward_rounded,
                      label: 'Sonraki slayt',
                      onTap: onNext,
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

class _PreviewInfoPill extends StatelessWidget {
  const _PreviewInfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.sutolColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(SutolRadius.full),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(SutolRadius.full),
            border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: colors.onSurfaceVariant, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewControlButton extends StatefulWidget {
  const _PreviewControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_PreviewControlButton> createState() => _PreviewControlButtonState();
}

class _PreviewControlButtonState extends State<_PreviewControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.sutolColors;
    return Tooltip(
      message: widget.label,
      child: Semantics(
        label: widget.label,
        button: true,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SutolRadius.full),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: AnimatedContainer(
                  duration: context.motionFast,
                  curve: context.motionDefaultCurve,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? colors.surface.withValues(alpha: 0.6)
                        : colors.surface.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(SutolRadius.full),
                    border: Border.all(
                      color: _isHovered
                          ? colors.outline.withValues(alpha: 0.4)
                          : colors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(widget.icon, color: colors.onSurface, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewIconButton extends StatefulWidget {
  const _PreviewIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_PreviewIconButton> createState() => _PreviewIconButtonState();
}

class _PreviewIconButtonState extends State<_PreviewIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.sutolColors;
    final enabled = widget.onTap != null;
    return Tooltip(
      message: widget.label,
      child: Semantics(
        label: widget.label,
        button: true,
        enabled: enabled,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: context.motionFast,
              curve: context.motionDefaultCurve,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: enabled && _isHovered
                    ? colors.surface.withValues(alpha: 0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: context.motionFast,
                  opacity: enabled ? 1.0 : 0.4,
                  child: Icon(widget.icon, color: colors.onSurface, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewDot extends StatelessWidget {
  const _PreviewDot({
    required this.index,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sutolColors;
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: AnimatedContainer(
                duration: context.motionFast,
                curve: context.motionDefaultCurve,
                width: isSelected ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(SutolRadius.full),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _isPreviewHotspotVisible({
  required int revealStep,
  required int currentRevealStep,
  required String? targetPageId,
  required String currentPageId,
}) {
  return targetPageId != null &&
      targetPageId.isNotEmpty &&
      targetPageId != currentPageId &&
      revealStep <= currentRevealStep;
}

Rect _textHotspotRect(
  PresentationTextBlock block,
  Size size,
) {
  final safeWidth = math.max(size.width, 1.0);
  final safeHeight = math.max(size.height, 1.0);
  final minWidth = math.min(80.0, safeWidth);
  final minHeight = math.min(48.0, safeHeight);
  final width =
      (block.widthFactor * safeWidth).clamp(minWidth, safeWidth).toDouble();
  final normalizedText = block.text.trim();
  final estimatedLines = math.max(1, (normalizedText.length / 26).ceil());
  final stageScale = (safeWidth / 1000).clamp(0.72, 1.45).toDouble();
  final typeHeightFactor = switch (block.type) {
    PresentationTextType.title => 1.26,
    PresentationTextType.subtitle => 1.18,
    PresentationTextType.body => 1.08,
  };
  final rawHeight =
      block.fontSize * stageScale * typeHeightFactor * estimatedLines;
  final height = rawHeight.clamp(minHeight, safeHeight).toDouble();
  final maxLeft = math.max(0.0, safeWidth - width);
  final maxTop = math.max(0.0, safeHeight - height);

  return Rect.fromLTWH(
    (block.position.dx * safeWidth).clamp(0.0, maxLeft).toDouble(),
    (block.position.dy * safeHeight).clamp(0.0, maxTop).toDouble(),
    width,
    height,
  );
}

Rect _componentHotspotRect(
  PresentationComponentBlock block,
  Size size,
) {
  final safeWidth = math.max(size.width, 1.0);
  final safeHeight = math.max(size.height, 1.0);
  final width =
      (block.size.width * safeWidth).clamp(64.0, safeWidth).toDouble();
  final height =
      (block.size.height * safeHeight).clamp(48.0, safeHeight).toDouble();
  final maxLeft = math.max(0.0, safeWidth - width);
  final maxTop = math.max(0.0, safeHeight - height);

  return Rect.fromLTWH(
    (block.position.dx * safeWidth).clamp(0.0, maxLeft).toDouble(),
    (block.position.dy * safeHeight).clamp(0.0, maxTop).toDouble(),
    width,
    height,
  );
}

String _previewPageTitle(PresentationPage page) {
  for (final block in page.textBlocks) {
    final value = block.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (value.isNotEmpty) {
      return value.length > 72 ? '${value.substring(0, 69)}...' : value;
    }
  }
  return 'Bos slayt';
}

Widget _buildPreviewTransition({
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
    curve: SutolMotion.easeOut,
    reverseCurve: SutolMotion.easeIn,
  );

  switch (kind) {
    case PresentationTransitionKind.none:
      return child;
    case PresentationTransitionKind.smooth:
      final smooth = CurvedAnimation(
        parent: animation,
        curve: SutolMotion.smooth,
        reverseCurve: SutolMotion.smooth,
      );
      return FadeTransition(opacity: smooth, child: child);
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
          scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
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

bool _shouldReducePreviewMotion(
  BuildContext context,
  PresentationEffectSettings settings,
) {
  return settings.reducedMotion ||
      (MediaQuery.maybeOf(context)?.disableAnimations ?? false);
}
