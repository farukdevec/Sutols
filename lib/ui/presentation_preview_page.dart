import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/design_system.dart';
import '../models/slide_model.dart';
import '../services/presentation_fullscreen_service.dart';
import '../services/pointer_lock_service.dart';
import '../state/presentation_controller.dart';
import 'widgets/editor_shell.dart';
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

class _PresentationPreviewPageState extends State<PresentationPreviewPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final FocusNode _focusNode;
  late int _index;
  int _fragmentStep = 0;
  bool _zoomed = false;
  bool _showControls = true;
  bool _presenterMode = false;
  PresentationPage? _transitionFromPage;
  PresentationTransitionKind? _activeTransitionKind;
  StreamSubscription<bool>? _fullscreenSubscription;
  bool _closing = false;
  late final AnimationController _pageTransitionController;
  final Set<LogicalKeyboardKey> _tourMovementKeys = <LogicalKeyboardKey>{};
  Timer? _tourMovementTimer;
  DateTime? _lastTourMovementTick;
  StreamSubscription<Offset>? _pointerLockMovementSubscription;
  StreamSubscription<bool>? _pointerLockChangeSubscription;
  Timer? _tourLookTimer;
  Offset _pendingTourLook = Offset.zero;
  bool _pointerLocked = false;
  bool _tourStarted = false;
  bool _tourNarrationOpen = false;
  bool _returnToTourEditor = false;
  final GlobalKey<_PreviewStageWithOrbitState> _tourStageKey =
      GlobalKey<_PreviewStageWithOrbitState>();
  int _transitionGeneration = 0;
  int _activeTransitionGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Platform view/iframe odağı klavye tuşu bırakma olayını yutabilse bile
    // global donanım klavyesi W/A/S/D durumunu sıfırlar; kullanıcı böylece
    // tuştan elini çektiğinde hareketin sürmesiyle karşılaşmaz.
    HardwareKeyboard.instance.addHandler(_handleGlobalTourMovementKey);
    _focusNode = FocusNode(debugLabel: 'Sutols presentation preview');
    _pageTransitionController = AnimationController(vsync: this, value: 1);
    _index = widget.controller.selectedIndex;
    _showControls = !widget.controller.selectedPage.componentBlocks.any(
      (block) => block.modelAssetId != null && block.modelTourEnabled,
    );
    _fullscreenSubscription = presentationFullscreenChanges().listen(
      (isFullscreen) {
        if (!isFullscreen && mounted) _close();
      },
    );
    _pointerLockMovementSubscription = pointerLockMovements.listen(
      _queueTourLook,
    );
    _pointerLockChangeSubscription = pointerLockChanges.listen((isLocked) {
      if (!isLocked) {
        _stopTourMovement();
        _stopTourLook();
      }
      if (mounted && _pointerLocked != isLocked) {
        setState(() => _pointerLocked = isLocked);
      }
    });
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
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_handleGlobalTourMovementKey);
    unawaited(_fullscreenSubscription?.cancel());
    unawaited(_pointerLockMovementSubscription?.cancel());
    unawaited(_pointerLockChangeSubscription?.cancel());
    _stopTourMovement();
    _stopTourLook();
    if (isPointerLocked) exitPointerLock();
    _focusNode.dispose();
    _pageTransitionController.dispose();
    if (!_returnToTourEditor) exitPresentationFullscreen();
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
    final gapIndex = math.min(_index, clamped);
    final transitionKind = widget.controller.transitionAfterPage(gapIndex);
    final shouldAnimate = transitionKind != PresentationTransitionKind.none &&
        !widget.controller.effectSettings.reducedMotion;
    final generation = ++_transitionGeneration;
    _activeTransitionGeneration = generation;
    final duration = Duration(
      milliseconds: widget.controller.effectSettings.transitionDurationMs,
    );
    _pageTransitionController.duration = duration;
    _pageTransitionController.value = shouldAnimate ? 0 : 1;
    setState(() {
      _transitionFromPage = previousPage;
      _activeTransitionKind = transitionKind;
      _index = clamped;
      _fragmentStep = revealStep.clamp(
        0,
        widget.controller.revealStepCountForPage(
          widget.controller.pages[clamped],
        ),
      );
      _zoomed = false;
    });
    if (!shouldAnimate) {
      setState(() => _transitionFromPage = null);
      return;
    }
    // Safety timer: ensure transition state always cleanly resolves
    Future.delayed(duration + const Duration(milliseconds: 100), () {
      if (!mounted || generation != _transitionGeneration) return;
      if (_transitionFromPage != null) {
        setState(() => _transitionFromPage = null);
      }
    });
  }

  void _startLoadedTransition() {
    final generation = _activeTransitionGeneration;
    if (!mounted ||
        generation != _transitionGeneration ||
        _pageTransitionController.isAnimating) {
      return;
    }
    _pageTransitionController.forward(from: 0).whenComplete(() {
      if (!mounted || generation != _transitionGeneration) return;
      setState(() => _transitionFromPage = null);
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

  void _toggleTourNarration() {
    if (!mounted) return;
    setState(() => _tourNarrationOpen = !_tourNarrationOpen);
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (_updateTourMovementKey(event)) return;

    final key = event.logicalKey;
    if (event is! KeyDownEvent) return;

    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.space) {
      _next();
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.backspace) {
      _previous();
    } else if (key == LogicalKeyboardKey.escape) {
      if (_tourStageKey.currentState?.isTourPointPlacementActive == true) {
        _tourStageKey.currentState?.cancelTourPointPlacement();
        return;
      }
      _close();
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

  bool _handleGlobalTourMovementKey(KeyEvent event) {
    _updateTourMovementKey(event);
    return false;
  }

  bool _updateTourMovementKey(KeyEvent event) {
    final key = event.logicalKey;
    final movementKeys = <LogicalKeyboardKey>{
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyD,
    };
    if (movementKeys.contains(key)) {
      if (event is KeyDownEvent || event is KeyRepeatEvent) {
        if (_tourStageKey.currentState?.hasTour == true &&
            _tourStageKey.currentState?.isTourPointPlacementActive != true) {
          _tourMovementKeys.add(key);
          _lastTourMovementTick ??= DateTime.now();
          _tourMovementTimer ??= Timer.periodic(
            const Duration(milliseconds: 16),
            (_) => _tickTourMovement(),
          );
        }
      } else if (event is KeyUpEvent) {
        _tourMovementKeys.remove(key);
        if (_tourMovementKeys.isEmpty) {
          _stopTourMovement();
        }
      }
      return true;
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _stopTourMovement();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final colors = context.sutolColors;
        final pages = widget.controller.pages;
        final effectSettings = widget.controller.effectSettings;
        final transitionSettings = effectSettings.copyWith(
          transitionKind:
              _activeTransitionKind ?? effectSettings.transitionKind,
        );
        final reduceMotion = _shouldReducePreviewMotion(
          context,
          effectSettings,
        );
        final pageCount = pages.length;
        final safeIndex =
            pageCount == 0 ? 0 : math.min(_index, math.max(0, pageCount - 1));
        final page = pageCount == 0 ? null : pages[safeIndex];
        final isTourPage = page?.componentBlocks.any(
              (block) => block.modelAssetId != null && block.modelTourEnabled,
            ) ??
            false;
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
              onTap: isTourPage
                  ? _engageTour
                  : (effectSettings.zoomEnabled ? null : _next),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _pageTransitionController,
                            builder: (context, _) => _PreviewDeckStage(
                              page: page,
                              transitionFromPage: _transitionFromPage,
                              currentIndex: safeIndex,
                              pageCount: pageCount,
                              currentRevealStep: _fragmentStep,
                              effectSettings: transitionSettings,
                              reduceMotion: reduceMotion,
                              zoomed: _zoomed,
                              onToggleZoom: _toggleZoom,
                              onHotspot: _goToPageId,
                              showHotspots: _showControls,
                              onTransitionReady: _startLoadedTransition,
                              tourStageKey: _tourStageKey,
                              tourMode: isTourPage,
                              onTourSurfacePointPicked: _addTourSurfaceText,
                              onTourSurfacePickMissed: _showTourSurfaceMiss,
                              onTourInteraction: _engageTour,
                              onTourHotspot: _goToPageId,
                            ),
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
                  if (isTourPage && !_tourStarted)
                    _TourStartOverlay(onStart: _engageTour),
                  if (isTourPage)
                    _TourExperienceHud(
                      tourStarted: _tourStarted,
                      onEngage: _engageTour,
                      onReset: () =>
                          _tourStageKey.currentState?.resetTourView(),
                      onEdit: _returnToEditor,
                      onAddText: _startTourPointPlacement,
                      onAddPoint: _startTourPointPlacement,
                      narrationOpen: _tourNarrationOpen,
                      onToggleNarration: _toggleTourNarration,
                      onClose: _close,
                    ),
                  if (isTourPage && _tourNarrationOpen && page != null)
                    _TourNarrationPanel(
                      page: page,
                      currentIndex: safeIndex,
                      pageCount: pageCount,
                      onPrevious: safeIndex > 0 || _fragmentStep > 0
                          ? _previous
                          : null,
                      onNext: safeIndex < pageCount - 1 ||
                              _fragmentStep < maxFragmentStep
                          ? _next
                          : null,
                      onClose: _toggleTourNarration,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _tickTourMovement() {
    final stage = _tourStageKey.currentState;
    if (stage == null || !stage.hasTour || _tourMovementKeys.isEmpty) {
      _stopTourMovement();
      return;
    }
    var forward =
        (_tourMovementKeys.contains(LogicalKeyboardKey.keyW) ? 1.0 : 0.0) -
            (_tourMovementKeys.contains(LogicalKeyboardKey.keyS) ? 1.0 : 0.0);
    var right =
        (_tourMovementKeys.contains(LogicalKeyboardKey.keyD) ? 1.0 : 0.0) -
            (_tourMovementKeys.contains(LogicalKeyboardKey.keyA) ? 1.0 : 0.0);
    if (forward != 0 && right != 0) {
      final diagonal = math.sqrt(0.5);
      forward *= diagonal;
      right *= diagonal;
    }
    // Sabit "her karede adım" yaklaşımı yüksek yenileme hızlı ekranlarda
    // gereğinden çok hızlıydı. Hareketi zamana bağlamak, oyundaki gibi aynı
    // yürüyüş hızını her makinede korur ve hedefin bir anda sıçramasını önler.
    final now = DateTime.now();
    final lastTick = _lastTourMovementTick ?? now;
    _lastTourMovementTick = now;
    final seconds =
        now.difference(lastTick).inMicroseconds.clamp(0, 50000).toDouble() /
            Duration.microsecondsPerSecond;
    // İlk hassas ayar, özellikle geniş Anıtkabir sahnesinde gereğinden
    // temkinli kaldı. Bu değer kontrollü kalırken yürüyüş hissini korur.
    const walkSpeed = 20.0;
    final movement = walkSpeed * seconds;
    stage.moveTour(forward: forward * movement, right: right * movement);
  }

  void _stopTourMovement() {
    _tourMovementKeys.clear();
    _tourMovementTimer?.cancel();
    _tourMovementTimer = null;
    _lastTourMovementTick = null;
  }

  /// Ham fare olayları özellikle yüksek yenileme hızlı farelerde saniyede
  /// yüzlerce kez gelebilir. Bunları 60 FPS'lik kısa paketlere toplamak,
  /// iframe'i gereksiz güncellemeden pürüzsüz kamera hissi sağlar.
  void _queueTourLook(Offset delta) {
    _pendingTourLook += delta;
    _tourLookTimer ??= Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        final look = _pendingTourLook;
        _pendingTourLook = Offset.zero;
        if (look == Offset.zero) {
          _stopTourLook();
          return;
        }
        _tourStageKey.currentState?.lookAroundTour(look);
      },
    );
  }

  void _stopTourLook() {
    _pendingTourLook = Offset.zero;
    _tourLookTimer?.cancel();
    _tourLookTimer = null;
  }

  void _engageTour() {
    // Varsayılan etkileşim pointer-lock değil, model-viewer'ın doğrudan
    // sürükle-bak denetimidir. Bu, iframe içindeki ilk fare hareketinin
    // kaybolmasını önler ve tüm tarayıcılarda anında çalışır.
    if (!_tourStarted && mounted) setState(() => _tourStarted = true);
    _focusNode.requestFocus();
  }

  void _returnToEditor() {
    _returnToTourEditor = true;
    _stopTourMovement();
    _stopTourLook();
    if (isPointerLocked) exitPointerLock();
    _close();
  }

  void _startTourPointPlacement() {
    _stopTourMovement();
    _stopTourLook();
    if (isPointerLocked) exitPointerLock();
    if (mounted) {
      setState(() {
        _pointerLocked = false;
        _tourStarted = true;
      });
    }
    _tourStageKey.currentState?.beginTourPointPlacement();
  }

  void _showTourSurfaceMiss() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bir tur metni için model yüzeyine tıklayın.')),
    );
  }

  Future<void> _addTourSurfaceText(ModelTourSurfacePoint point) async {
    // Çocuk sahne iframe etkileşimini ilk olarak kapatır. Modalı ancak bu
    // değişiklik bir kare boyandıktan sonra açmak, web platform görünümünün
    // diyaloğu yakalayıp bütün ekranı tıklanamaz hale getirmesini önler.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final pages = widget.controller.pages;
    if (_index < 0 || _index >= pages.length) return;
    final page = pages[_index];
    final tourBlock = page.componentBlocks.firstWhere(
      (block) => block.modelAssetId != null && block.modelTourEnabled,
      orElse: () => throw StateError('Tur modeli bulunamadı'),
    );
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? targetPageId;
    final result = await showDialog<({String title, String description, String? target})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('3B tur metni'),
          content: SizedBox(
            width: 390,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Başlık *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: targetPageId,
                  decoration: const InputDecoration(labelText: 'Hedef slayt (isteğe bağlı)'),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Bağlantı yok'),
                    ),
                    ...pages.where((candidate) => candidate.id != page.id).map(
                      (candidate) => DropdownMenuItem<String?>(
                        value: candidate.id,
                        child: Text(candidate.title.isEmpty ? 'İsimsiz slayt' : candidate.title),
                      ),
                    ),
                  ],
                  onChanged: (value) => setDialogState(() => targetPageId = value),
                ),
                const SizedBox(height: 14),
                Text(
                  'Konum: X ${point.x.toStringAsFixed(3)} · Y ${point.y.toStringAsFixed(3)} · Z ${point.z.toStringAsFixed(3)}',
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                Navigator.of(dialogContext).pop((
                  title: title,
                  description: descriptionController.text.trim(),
                  target: targetPageId,
                ));
              },
              child: const Text('3B metni ekle'),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    descriptionController.dispose();
    if (!mounted || result == null) return;
    widget.controller.selectPage(_index);
    widget.controller.selectComponentBlock(tourBlock.id);
    widget.controller.addSelectedModelTourHotspot(
      label: result.title,
      description: result.description,
      targetPageId: result.target,
      x: point.x,
      y: point.y,
      z: point.z,
    );
  }
}

class _TourSurfacePlacementPrompt extends StatelessWidget {
  const _TourSurfacePlacementPrompt({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: '3B metin konumu seçiliyor',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xED071426),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x807DD3FC)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 8, 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.add_location_alt_rounded,
                size: 18,
                color: Color(0xFF7DD3FC),
              ),
              const SizedBox(width: 9),
              const Text(
                'Model yüzeyinde metnin konumunu seçin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('İptal'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFA5F3FC),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourStartOverlay extends StatelessWidget {
  const _TourStartOverlay({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x22020B18),
        child: Center(
          child: FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.mouse_rounded),
            label: const Text('Keşfe başla · Modeli sürükle'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _TourExperienceHud extends StatelessWidget {
  const _TourExperienceHud({
    required this.tourStarted,
    required this.onEngage,
    required this.onReset,
    required this.onEdit,
    required this.onAddText,
    required this.onAddPoint,
    required this.narrationOpen,
    required this.onToggleNarration,
    required this.onClose,
  });

  final bool tourStarted;
  final VoidCallback onEngage;
  final VoidCallback onReset;
  final VoidCallback onEdit;
  final VoidCallback onAddText;
  final VoidCallback onAddPoint;
  final bool narrationOpen;
  final VoidCallback onToggleNarration;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18,
      left: 18,
      right: 18,
      child: SafeArea(
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xDC071426),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x4D7DD3FC)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 22,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      tourStarted
                          ? Icons.gamepad_rounded
                          : Icons.explore_rounded,
                      color: const Color(0xFF7DD3FC),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tourStarted
                          ? 'Keşif modu aktif · sürükle + WASD'
                          : 'Sanal tur hazır',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!tourStarted)
                      _TourHudButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'Turu başlat',
                        onPressed: onEngage,
                      )
                    else
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.mouse_rounded,
                            size: 15,
                            color: Color(0xFFA5F3FC),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Sol tuş + sürükle: bak',
                            style: TextStyle(
                              color: Color(0xFFA5F3FC),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Düzenleme araçları tur açıkken de erişilebilir kalır. Bir araç
            // seçildiğinde üst katman fare kilidini güvenle kapatır.
            ...<Widget>[
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xDC071426),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x4D7DD3FC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _TourHudToolButton(
                      icon: Icons.text_fields_rounded,
                      label: '3B metin ekle',
                      onPressed: onAddText,
                    ),
                    const SizedBox(width: 2),
                    _TourHudToolButton(
                      icon: Icons.add_location_alt_rounded,
                      label: 'Nokta yerleştir',
                      onPressed: onAddPoint,
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            _TourHudIconButton(
              tooltip: 'Başlangıç görünümüne dön',
              icon: Icons.center_focus_strong_rounded,
              onPressed: onReset,
            ),
            const SizedBox(width: 8),
            _TourHudIconButton(
              tooltip: narrationOpen
                  ? 'Anlatım panelini kapat'
                  : 'Slayt anlatımını aç',
              icon: narrationOpen
                  ? Icons.speaker_notes_off_rounded
                  : Icons.speaker_notes_rounded,
              onPressed: onToggleNarration,
            ),
            const SizedBox(width: 8),
            _TourHudIconButton(
              tooltip: 'Tur düzenleme araçlarına dön',
              icon: Icons.edit_rounded,
              onPressed: onEdit,
            ),
            const SizedBox(width: 8),
            _TourHudIconButton(
              tooltip: 'Turu kapat',
              icon: Icons.close_rounded,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tur sahnesini kapatmadan konuşmacının sıradaki anlatımını ve slayt
/// akışını erişilebilir tutar. Bu panel yalnızca sunucuya görünür; ziyaretçi
/// model üzerinde serbestçe gezinmeye devam eder.
class _TourNarrationPanel extends StatelessWidget {
  const _TourNarrationPanel({
    required this.page,
    required this.currentIndex,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
  });

  final PresentationPage page;
  final int currentIndex;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onClose;

  String get _narration {
    final notes = page.speakerNotes.trim();
    if (notes.isNotEmpty) return notes;
    final slideText = page.textBlocks
        .map((block) => block.text.trim())
        .where((text) => text.isNotEmpty)
        .take(5)
        .join('\n\n');
    return slideText.isEmpty
        ? 'Bu slayta konuşmacı notu eklenmemiş. Tur noktalarından ilerleyin veya slayt metnini anlatım akışı olarak kullanın.'
        : slideText;
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 36;
    return Positioned(
      top: 96,
      right: 18,
      child: SafeArea(
        child: SizedBox(
          width: math.min(390.0, math.max(0.0, availableWidth)),
          child: Material(
            color: const Color(0xF509172A),
            elevation: 20,
            shadowColor: const Color(0x99000000),
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x667DD3FC)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.record_voice_over_rounded,
                          color: Color(0xFF7DD3FC),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Sunucu anlatımı',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Anlatım panelini kapat',
                          onPressed: onClose,
                          icon: const Icon(Icons.close_rounded),
                          color: const Color(0xFFCFEAFE),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SLAYT ${currentIndex + 1} / $pageCount',
                      style: const TextStyle(
                        color: Color(0xFF7DD3FC),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      page.title.trim().isEmpty
                          ? 'İsimsiz tur sahnesi'
                          : page.title.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0x337DD3FC), height: 1),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _narration,
                          style: const TextStyle(
                            color: Color(0xFFE0F2FE),
                            fontSize: 13,
                            height: 1.48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: onPrevious,
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: const Text('Önceki'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE0F2FE),
                            side: const BorderSide(color: Color(0x667DD3FC)),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: onNext,
                          icon: const Icon(Icons.chevron_right_rounded),
                          label: const Text('Sonraki'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
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

class _TourHudButton extends StatelessWidget {
  const _TourHudButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _TourHudToolButton extends StatelessWidget {
  const _TourHudToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFE0F2FE),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _TourHudIconButton extends StatelessWidget {
  const _TourHudIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xDC071426),
        borderRadius: BorderRadius.circular(12),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: Colors.white,
          splashRadius: 22,
        ),
      ),
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
    required this.onTransitionReady,
    required this.tourStageKey,
    required this.tourMode,
    required this.onTourSurfacePointPicked,
    required this.onTourSurfacePickMissed,
    required this.onTourInteraction,
    required this.onTourHotspot,
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
  final VoidCallback onTransitionReady;
  final GlobalKey<_PreviewStageWithOrbitState> tourStageKey;
  final bool tourMode;
  final ValueChanged<ModelTourSurfacePoint> onTourSurfacePointPicked;
  final VoidCallback onTourSurfacePickMissed;
  final VoidCallback onTourInteraction;
  final ValueChanged<String> onTourHotspot;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion ||
            effectSettings.transitionKind == PresentationTransitionKind.none
        ? SutolMotion.instant
        : Duration(milliseconds: effectSettings.transitionDurationMs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = math.max(0.0, constraints.maxWidth);
        final availableHeight = math.max(0.0, constraints.maxHeight);
        final targetRatio = effectSettings.calculatedAspectRatio;
        double stageWidth;
        double stageHeight;
        if (tourMode) {
          // Tur ekranı sunum oranına hapsolmaz; model, gerçek oyun benzeri
          // keşif için kullanılabilir ekranın tamamını kaplar.
          stageWidth = availableWidth;
          stageHeight = availableHeight;
        } else if (availableWidth / availableHeight > targetRatio) {
          stageHeight = availableHeight;
          stageWidth = stageHeight * targetRatio;
        } else {
          stageWidth = availableWidth;
          stageHeight = stageWidth / targetRatio;
        }
        final isPlayingTransition = transitionFromPage != null &&
            !reduceMotion &&
            effectSettings.transitionKind != PresentationTransitionKind.none;

        return Center(
          child: SizedBox(
            width: stageWidth,
            height: stageHeight,
            child: ClipRRect(
              borderRadius: effectSettings.isPortrait
                  ? BorderRadius.circular(16)
                  : BorderRadius.zero,
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
                      child: isPlayingTransition
                          ? HtmlPageTransitionStage(
                              key: ValueKey<String>(
                                'transition-${transitionFromPage!.id}-${page.id}-${effectSettings.transitionKind.name}',
                              ),
                              from: transitionFromPage!,
                              to: page,
                              kind: effectSettings.transitionKind,
                              durationMs: effectSettings.transitionDurationMs,
                              onReady: onTransitionReady,
                            )
                          : AnimatedScale(
                              scale: zoomed ? effectSettings.zoomScale : 1,
                              duration: reduceMotion
                                  ? SutolMotion.instant
                                  : SutolMotion.moderate,
                              curve: SutolMotion.easeOut,
                              child: _PreviewStageWithOrbit(
                                key: tourStageKey,
                                page: page,
                                transitionFromPage: null,
                                currentRevealStep: currentRevealStep,
                                effectSettings: effectSettings,
                                reduceMotion: reduceMotion,
                                duration: duration,
                                showHotspots: showHotspots,
                                onHotspot: onHotspot,
                                tourMode: tourMode,
                                onTourSurfacePointPicked: onTourSurfacePointPicked,
                                onTourSurfacePickMissed: onTourSurfacePickMissed,
                                onTourInteraction: onTourInteraction,
                                onTourHotspot: onTourHotspot,
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

class _PreviewStageWithOrbit extends StatefulWidget {
  const _PreviewStageWithOrbit({
    super.key,
    required this.page,
    required this.transitionFromPage,
    required this.currentRevealStep,
    required this.effectSettings,
    required this.reduceMotion,
    required this.duration,
    required this.showHotspots,
    required this.onHotspot,
    required this.tourMode,
    required this.onTourSurfacePointPicked,
    required this.onTourSurfacePickMissed,
    required this.onTourInteraction,
    required this.onTourHotspot,
  });

  final PresentationPage page;
  final PresentationPage? transitionFromPage;
  final int currentRevealStep;
  final PresentationEffectSettings effectSettings;
  final bool reduceMotion;
  final Duration duration;
  final bool showHotspots;
  final ValueChanged<String> onHotspot;
  final bool tourMode;
  final ValueChanged<ModelTourSurfacePoint> onTourSurfacePointPicked;
  final VoidCallback onTourSurfacePickMissed;
  final VoidCallback onTourInteraction;
  final ValueChanged<String> onTourHotspot;

  @override
  State<_PreviewStageWithOrbit> createState() => _PreviewStageWithOrbitState();
}

class _OrbitPose {
  const _OrbitPose(
    this.theta,
    this.phi,
    this.targetX,
    this.targetY,
    this.targetZ,
  );

  final double theta;
  final double phi;
  final double targetX;
  final double targetY;
  final double targetZ;
}

class _PreviewStageWithOrbitState extends State<_PreviewStageWithOrbit> {
  final Map<String, _OrbitPose> _orbitOverrides = <String, _OrbitPose>{};
  bool _tourPointPlacementEnabled = false;
  Offset? _tourSurfacePickPosition;
  int _tourSurfacePickGeneration = 0;

  PresentationComponentBlock? get _tourBlock => widget.page.componentBlocks
      .cast<PresentationComponentBlock?>()
      .firstWhere(
        (block) => block?.modelAssetId != null && block!.modelTourEnabled,
        orElse: () => null,
      );

  bool get hasTour => _tourBlock != null;

  void beginTourPointPlacement() {
    if (!hasTour) return;
    setState(() => _tourPointPlacementEnabled = true);
  }

  bool get isTourPointPlacementActive => _tourPointPlacementEnabled;

  void cancelTourPointPlacement() {
    if (!_tourPointPlacementEnabled) return;
    setState(() => _tourPointPlacementEnabled = false);
  }

  void _requestTourSurfacePick(Offset position) {
    if (!_tourPointPlacementEnabled) return;
    setState(() {
      _tourSurfacePickPosition = position;
      _tourSurfacePickGeneration += 1;
    });
  }

  PresentationPage get _effectivePage {
    final tourBlock = _tourBlock;
    if (widget.tourMode && tourBlock != null) {
      final pose = _orbitOverrides[tourBlock.id];
      final focused = tourBlock.copyWith(
        position: Offset.zero,
        size: const Size(1, 1),
        modelOrbitTheta: pose?.theta ?? tourBlock.modelOrbitTheta,
        modelOrbitPhi: pose?.phi ?? tourBlock.modelOrbitPhi,
        modelTargetX: pose?.targetX ?? tourBlock.modelTargetX,
        modelTargetY: pose?.targetY ?? tourBlock.modelTargetY,
        modelTargetZ: pose?.targetZ ?? tourBlock.modelTargetZ,
      );
      return widget.page.copyWith(
        // Tur metinleri Flutter'ın düzenlenebilir rehber katmanında çizilir.
        textBlocks: const <PresentationTextBlock>[],
        componentBlocks: <PresentationComponentBlock>[focused],
      );
    }
    if (_orbitOverrides.isEmpty) {
      return widget.page;
    }
    var changed = false;
    final components = widget.page.componentBlocks.map((block) {
      final pose = _orbitOverrides[block.id];
      if (pose == null) {
        return block;
      }
      changed = true;
      return block.copyWith(
        modelOrbitTheta: pose.theta,
        modelOrbitPhi: pose.phi,
        modelTargetX: pose.targetX,
        modelTargetY: pose.targetY,
        modelTargetZ: pose.targetZ,
      );
    }).toList(growable: false);
    return changed
        ? widget.page.copyWith(componentBlocks: components)
        : widget.page;
  }

  void _handleOrbitDrag(PresentationComponentBlock block, Offset delta) {
    final current = _orbitOverrides[block.id] ??
        _OrbitPose(
          block.modelOrbitTheta,
          block.modelOrbitPhi,
          block.modelTargetX,
          block.modelTargetY,
          block.modelTargetZ,
        );
    setState(() {
      _orbitOverrides[block.id] = _OrbitPose(
        (current.theta - delta.dx * 0.55) % 360,
        (current.phi + delta.dy * 0.45).clamp(10.0, 170.0).toDouble(),
        current.targetX,
        current.targetY,
        current.targetZ,
      );
    });
  }

  void lookAroundTour(Offset delta) {
    final block = _tourBlock;
    if (block == null) return;
    final current = _orbitOverrides[block.id] ??
        _OrbitPose(
          block.modelOrbitTheta,
          block.modelOrbitPhi,
          block.modelTargetX,
          block.modelTargetY,
          block.modelTargetZ,
        );
    setState(() {
      // Tarayıcılar fare kilidindeyken bazı platformlarda büyük movement
      // değerleri gönderebilir. Kısa bir üst sınır, kamerayı bir anda modelin
      // etrafında döndürmek yerine kontrollü ama tam küresel bakış sağlar.
      final horizontal = delta.dx.clamp(-24.0, 24.0).toDouble();
      final vertical = delta.dy.clamp(-24.0, 24.0).toDouble();
      _orbitOverrides[block.id] = _OrbitPose(
        (current.theta - horizontal * 0.24) % 360,
        (current.phi + vertical * 0.20).clamp(8.0, 172.0).toDouble(),
        current.targetX,
        current.targetY,
        current.targetZ,
      );
    });
  }

  void resetTourView() {
    final block = _tourBlock;
    if (block == null) return;
    setState(() => _orbitOverrides.remove(block.id));
  }

  /// Sunum sırasında tur açık modelde kısa bir adım ilerler. Yön, kameranın
  /// anlık bakış açısına göre hesaplanır; böylece editörde kaydedilen rota ile
  /// izleyicinin canlı keşfi aynı davranışı paylaşır.
  bool moveTour({required double forward, required double right}) {
    PresentationComponentBlock? block;
    for (final candidate in widget.page.componentBlocks) {
      if (candidate.modelAssetId != null && candidate.modelTourEnabled) {
        block = candidate;
        break;
      }
    }
    if (block == null) return false;
    final current = _orbitOverrides[block.id] ??
        _OrbitPose(
          block.modelOrbitTheta,
          block.modelOrbitPhi,
          block.modelTargetX,
          block.modelTargetY,
          block.modelTargetZ,
        );
    final theta = current.theta * math.pi / 180;
    final sensitivity = 1 / math.sqrt(block.modelZoom.clamp(0.5, 10.0));
    setState(() {
      _orbitOverrides[block!.id] = _OrbitPose(
        current.theta,
        current.phi,
        // model-viewer'ın kamera hedefi, ekrandaki hareketin ters yönünde
        // ötelenmelidir. Böylece W ileri, D sağ yönünde algılanır.
        (current.targetX -
                forward * sensitivity * math.sin(theta) +
                right * sensitivity * math.cos(theta))
            .clamp(-500.0, 500.0)
            .toDouble(),
        current.targetY,
        (current.targetZ -
                forward * sensitivity * math.cos(theta) -
                right * sensitivity * math.sin(theta))
            .clamp(-500.0, 500.0)
            .toDouble(),
      );
    });
    return true;
  }

  @override
  void didUpdateWidget(covariant _PreviewStageWithOrbit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.id != widget.page.id) {
      _orbitOverrides.clear();
      _tourPointPlacementEnabled = false;
      _tourSurfacePickPosition = null;
    }
  }

  Widget _orbitOverlay(PresentationComponentBlock block, Size stageSize) {
    if (stageSize.width <= 0 || stageSize.height <= 0) {
      return const SizedBox.shrink();
    }
    final minW = math.min(54.0, stageSize.width);
    final minH = math.min(44.0, stageSize.height);
    final width = (block.size.width * stageSize.width)
        .clamp(minW, stageSize.width)
        .toDouble();
    final height = (block.size.height * stageSize.height)
        .clamp(minH, stageSize.height)
        .toDouble();
    final left = (block.position.dx * stageSize.width)
        .clamp(0.0, math.max(0.0, stageSize.width - width))
        .toDouble();
    final top = (block.position.dy * stageSize.height)
        .clamp(0.0, math.max(0.0, stageSize.height - height))
        .toDouble();
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Semantics(
        label: block.modelTourEnabled
            ? 'Sanal tur modeli. Keşfetmek için sürükleyin.'
            : 'Üç boyutlu model. Döndürmek için sürükleyin.',
        child: MouseRegion(
          cursor: SystemMouseCursors.move,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) => _handleOrbitDrag(block, details.delta),
          ),
        ),
      ),
    );
  }

  Widget _tourHint(PresentationComponentBlock block, Size stageSize) {
    final width = (block.size.width * stageSize.width)
        .clamp(0.0, stageSize.width)
        .toDouble();
    final height = (block.size.height * stageSize.height)
        .clamp(0.0, stageSize.height)
        .toDouble();
    final left = (block.position.dx * stageSize.width)
        .clamp(0.0, math.max(0.0, stageSize.width - width))
        .toDouble();
    final top = (block.position.dy * stageSize.height)
        .clamp(0.0, math.max(0.0, stageSize.height - height))
        .toDouble();

    return Positioned(
      left: left + 12,
      top: top + math.max(10.0, height - 46),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xD9142033),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.pan_tool_alt_rounded, size: 15, color: Colors.white),
                SizedBox(width: 7),
                Text(
                  '360° bakış · Fare + WASD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sunum sahnesi önceden yalnızca "Manuel Kontrol" modellerini
    // yakalıyordu. Sanal tur modeli burada da aynı kamera katmanını kullanır;
    // böylece her slaytta kaydedilen bakış açısı korunur ve izleyici modelin
    // üzerinde sürükleyerek çevreyi inceleyebilir.
    final orbitBlocks = widget.page.componentBlocks
        .where(
          (block) =>
              block.modelAssetId != null &&
              block.modelOrbitEnabled &&
              (!widget.tourMode || !block.modelTourEnabled) &&
              block.modelTourHotspots.isEmpty,
        )
        .toList(growable: false);
    // Tur modelleri için giriş tek bir Flutter katmanında tutulur. Bu sayede
    // platform iframe'i HUD'ı kapatmaz; 3B nokta seçimi koordinatı da güvenli
    // postMessage köprüsüyle model-viewer'a aktarılır.
    final tourBlocks = (widget.tourMode
            ? _effectivePage.componentBlocks
            : widget.page.componentBlocks)
        .where(
          (block) => block.modelAssetId != null && block.modelTourEnabled,
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageSize = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            IgnorePointer(
              child: PresentationPageThumbnailCanvas(
                page: _effectivePage,
              ),
            ),
            if (widget.effectSettings.transitionKind ==
                    PresentationTransitionKind.smooth &&
                widget.transitionFromPage != null &&
                !widget.reduceMotion)
              _SmoothModelMorphStage(
                key: ValueKey<String>('smooth-morph-${widget.page.id}'),
                fromPage: widget.transitionFromPage!,
                toPage: _effectivePage,
                visibleRevealStep: widget.currentRevealStep,
                duration: widget.duration,
              )
            else
              HtmlPageStage(
                page: _effectivePage,
                visibleRevealStep: widget.currentRevealStep,
                showBadge: false,
                renderMode: HtmlStageRenderMode.preview,
                tourPointPlacementEnabled:
                    widget.tourMode && _tourPointPlacementEnabled,
                tourSurfacePickPosition: _tourSurfacePickPosition,
                tourSurfacePickGeneration: _tourSurfacePickGeneration,
                // HTML platform görünümü hiçbir tur durumunda fareyi almaz.
                // Böylece 3B metin konumu seçilirken bile HUD, iptal düğmesi
                // ve modal diyaloglar erişilebilir kalır.
                tourInteractionEnabled: false,
                onTourSurfacePointPicked: (point) {
                  if (!_tourPointPlacementEnabled) return;
                  setState(() => _tourPointPlacementEnabled = false);
                  widget.onTourSurfacePointPicked(point);
                },
                onTourSurfacePickMissed: () {
                  if (_tourPointPlacementEnabled) {
                    widget.onTourSurfacePickMissed();
                  }
                },
                onTourInteraction: widget.onTourInteraction,
                onTourHotspot: widget.onTourHotspot,
              ),
            if (widget.tourMode)
              Positioned.fill(
                child: MouseRegion(
                  cursor: _tourPointPlacementEnabled
                      ? SystemMouseCursors.precise
                      : SystemMouseCursors.grab,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: _tourPointPlacementEnabled
                        ? (details) =>
                            _requestTourSurfacePick(details.localPosition)
                        : null,
                    onPanStart: _tourPointPlacementEnabled
                        ? null
                        : (_) => widget.onTourInteraction(),
                    onPanUpdate: _tourPointPlacementEnabled
                        ? null
                        : (details) => lookAroundTour(details.delta),
                  ),
                ),
              ),
            if (!_tourPointPlacementEnabled)
              for (final block in orbitBlocks) _orbitOverlay(block, stageSize),
            if (widget.showHotspots || widget.tourMode)
              for (final block in tourBlocks) _tourHint(block, stageSize),
            if (widget.tourMode && _tourPointPlacementEnabled)
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: _TourSurfacePlacementPrompt(
                    onCancel: cancelTourPointPlacement,
                  ),
                ),
              ),
            if (widget.showHotspots)
              _PreviewHotspotOverlay(
                page: widget.page,
                currentRevealStep: widget.currentRevealStep,
                onHotspot: widget.onHotspot,
              ),
          ],
        );
      },
    );
  }
}

class _SmoothModelMorphStage extends StatefulWidget {
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
  State<_SmoothModelMorphStage> createState() => _SmoothModelMorphStageState();
}

class _SmoothModelMorphStageState extends State<_SmoothModelMorphStage>
    with SingleTickerProviderStateMixin {
  static const int _frameIntervalMicros = 1000000 ~/ 30;

  late final AnimationController _controller;
  late Animation<double> _progress;
  int _lastFrameMicros = -_frameIntervalMicros;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_handleTick);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: SutolMotion.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _SmoothModelMorphStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.fromPage != widget.fromPage ||
        oldWidget.toPage != widget.toPage) {
      _lastFrameMicros = -_frameIntervalMicros;
      _controller.forward(from: 0);
    }
  }

  void _handleTick() {
    final elapsedMicros = _controller.lastElapsedDuration?.inMicroseconds ?? 0;
    final isComplete = _controller.status == AnimationStatus.completed;
    if (!isComplete &&
        elapsedMicros - _lastFrameMicros < _frameIntervalMicros) {
      return;
    }
    _lastFrameMicros = elapsedMicros;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlPageStage(
      page: _interpolateModelPages(
        widget.fromPage,
        widget.toPage,
        _progress.value,
      ),
      visibleRevealStep: widget.visibleRevealStep,
      showBadge: false,
      renderMode: HtmlStageRenderMode.preview,
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
                label:
                    presentationTransitionLabel(effectSettings.transitionKind),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
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
                  color: isSelected
                      ? colors.primary
                      : colors.onSurface.withValues(alpha: 0.24),
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
  final minWidth = math.min(64.0, safeWidth);
  final minHeight = math.min(48.0, safeHeight);
  final width =
      (block.size.width * safeWidth).clamp(minWidth, safeWidth).toDouble();
  final height =
      (block.size.height * safeHeight).clamp(minHeight, safeHeight).toDouble();
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

// ignore: unused_element
Widget _buildPresentationTransitionPair({
  required PresentationTransitionKind kind,
  required double progress,
  required Widget? outgoing,
  required Widget incoming,
}) {
  if (outgoing == null || kind == PresentationTransitionKind.none) {
    return incoming;
  }
  final t = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
  final layers = <Widget>[];

  switch (kind) {
    case PresentationTransitionKind.none:
      return incoming;
    case PresentationTransitionKind.fade:
    case PresentationTransitionKind.smooth:
      layers.addAll(<Widget>[
        Opacity(opacity: 1 - t, child: outgoing),
        Opacity(opacity: t, child: incoming),
      ]);
    case PresentationTransitionKind.slide:
      layers.addAll(<Widget>[
        FractionalTranslation(translation: Offset(-t, 0), child: outgoing),
        FractionalTranslation(
          translation: Offset(1 - t, 0),
          child: incoming,
        ),
      ]);
    case PresentationTransitionKind.cover:
      layers.addAll(<Widget>[
        outgoing,
        FractionalTranslation(
          translation: Offset(1 - t, 0),
          child: incoming,
        ),
      ]);
    case PresentationTransitionKind.uncover:
      layers.addAll(<Widget>[
        incoming,
        FractionalTranslation(translation: Offset(-t, 0), child: outgoing),
      ]);
    case PresentationTransitionKind.wipe:
      layers.addAll(<Widget>[
        outgoing,
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: t,
            child: incoming,
          ),
        ),
      ]);
    case PresentationTransitionKind.split:
      layers.addAll(<Widget>[
        outgoing,
        ClipRect(
          child: Align(
            alignment: Alignment.center,
            widthFactor: t,
            child: incoming,
          ),
        ),
      ]);
    case PresentationTransitionKind.reveal:
      layers.addAll(<Widget>[
        outgoing,
        FractionalTranslation(
          translation: Offset(0, 1 - t),
          child: incoming,
        ),
      ]);
    case PresentationTransitionKind.flip:
    case PresentationTransitionKind.cube3d:
      layers.addAll(<Widget>[
        Transform(
          alignment: Alignment.centerRight,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0012)
            ..rotateY(-1.5708 * t),
          child: Opacity(opacity: 1 - t, child: outgoing),
        ),
        Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0012)
            ..rotateY(1.5708 * (1 - t)),
          child: Opacity(opacity: t, child: incoming),
        ),
      ]);
    default:
      layers.addAll(<Widget>[
        Opacity(
          opacity: 1 - t,
          child: Transform.scale(scale: 1 + (.12 * t), child: outgoing),
        ),
        Opacity(
          opacity: t,
          child: Transform.scale(scale: .88 + (.12 * t), child: incoming),
        ),
      ]);
  }

  return Stack(fit: StackFit.expand, children: layers);
}

// Kept for the individual transition widgets used by legacy callers.
// ignore: unused_element
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
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) {
          final outgoing = animation.status == AnimationStatus.reverse;
          return FractionalTranslation(
            translation: outgoing
                ? Offset(curved.value - 1, 0)
                : Offset(1 - curved.value, 0),
            child: child,
          );
        },
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
          axisAlignment: 0.0,
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
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) {
          final outgoing = animation.status == AnimationStatus.reverse;
          return FractionalTranslation(
            translation: outgoing ? Offset.zero : Offset(1 - curved.value, 0),
            child: child,
          );
        },
      );
    case PresentationTransitionKind.uncover:
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) {
          final outgoing = animation.status == AnimationStatus.reverse;
          return FractionalTranslation(
            translation: outgoing ? Offset(curved.value - 1, 0) : Offset.zero,
            child: child,
          );
        },
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
    case PresentationTransitionKind.cube3d:
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) => Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((1 - curved.value) * -1.57),
          child: Opacity(opacity: curved.value, child: child),
        ),
      );
    case PresentationTransitionKind.morph:
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.15, end: 1.0).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.parallax:
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.elastic:
      final elasticCurve = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeIn,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1.0).animate(elasticCurve),
        child: FadeTransition(opacity: curved, child: child),
      );
    case PresentationTransitionKind.glitch:
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.04, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.prism:
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.radialWipe:
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: child,
        ),
      );
    case PresentationTransitionKind.rotateZoom:
      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateZ((1 - curved.value) * -0.5),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(curved),
            child: Opacity(opacity: curved.value, child: child),
          ),
        ),
      );
  }
}

bool _shouldReducePreviewMotion(
  BuildContext _,
  PresentationEffectSettings settings,
) {
  // Sunum geçişleri yalnız kullanıcının uygulama içindeki "azaltılmış
  // hareket" seçimiyle kapatılır. İşletim sistemi ayarını burada otomatik
  // uygulamak, kullanıcı bir geçiş seçtiği halde tüm efektleri görünmez
  // kılıyordu.
  return settings.reducedMotion;
}
