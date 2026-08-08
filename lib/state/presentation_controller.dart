import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/slide_model.dart';
import '../services/presentation_auto_builder.dart';

class PresentationController extends ChangeNotifier {
  static const double _minTextWidthFactor = 0.18;
  static const double _maxTextRightPaddingFactor = 0.06;
  static const int _minTransitionDurationMs = 120;
  static const int _maxTransitionDurationMs = 3000;
  static const double _minZoomScale = 1.1;
  static const double _maxZoomScale = 2.4;
  static const int _maxRevealStep = 9;
  static const double _minComponentWidthFactor = 0.08;
  static const double _minComponentHeightFactor = 0.08;
  static const double _maxComponentWidthFactor = 0.90;
  static const double _maxComponentHeightFactor = 0.88;
  static const int _maxHistoryEntries = 80;

  PresentationController()
      : _pages = <PresentationPage>[
          const PresentationPage(
            id: 'page-1',
            textBlocks: <PresentationTextBlock>[
              PresentationTextBlock(
                id: 'text-1',
                text: '',
                position: Offset(0.12, 0.16),
                fontSize: 48,
                type: PresentationTextType.title,
                widthFactor: 0.34,
              ),
            ],
          ),
        ],
        _pageCounter = 2,
        _textBlockCounter = 2,
        _componentBlockCounter = 1,
        _selectedTextBlockId = 'text-1' {
    _selectedTextBlockIds.add('text-1');
  }

  final List<PresentationPage> _pages;
  int _selectedPageIndex = 0;
  int _pageCounter;
  int _textBlockCounter;
  int _componentBlockCounter;
  String? _selectedTextBlockId;
  String? _selectedComponentBlockId;
  PresentationEffectSettings _effectSettings =
      const PresentationEffectSettings();
  final LinkedHashSet<String> _selectedTextBlockIds = LinkedHashSet<String>();
  final LinkedHashSet<String> _selectedComponentBlockIds =
      LinkedHashSet<String>();
  final List<_PresentationSnapshot> _undoStack = <_PresentationSnapshot>[];
  final List<_PresentationSnapshot> _redoStack = <_PresentationSnapshot>[];
  List<PresentationTextBlock> _copiedTextBlocks =
      const <PresentationTextBlock>[];
  List<PresentationComponentBlock> _copiedComponentBlocks =
      const <PresentationComponentBlock>[];
  bool _historySuspended = false;
  bool _modelOrbitGestureActive = false;

  UnmodifiableListView<PresentationPage> get pages =>
      UnmodifiableListView<PresentationPage>(_pages);

  int get selectedIndex => _selectedPageIndex;

  PresentationPage get selectedPage => _pages[_selectedPageIndex];

  String? get selectedTextBlockId => _selectedTextBlockId;
  Set<String> get selectedTextBlockIds =>
      Set<String>.unmodifiable(_selectedTextBlockIds);
  String? get selectedComponentBlockId => _selectedComponentBlockId;
  Set<String> get selectedComponentBlockIds =>
      Set<String>.unmodifiable(_selectedComponentBlockIds);
  PresentationEffectSettings get effectSettings => _effectSettings;
  int get selectedTextSelectionCount => _selectedTextBlockIds.length;
  int get selectedComponentSelectionCount => _selectedComponentBlockIds.length;
  int get selectedItemCount =>
      _selectedTextBlockIds.length + _selectedComponentBlockIds.length;
  bool get hasMultiSelection => selectedItemCount > 1;
  bool get hasSelection => selectedItemCount > 0;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get canPasteItems =>
      _copiedTextBlocks.isNotEmpty || _copiedComponentBlocks.isNotEmpty;

  PresentationTextBlock? get selectedTextBlock =>
      _selectedTextBlockIds.length == 1 && _selectedComponentBlockIds.isEmpty
          ? selectedPage.findTextBlock(_selectedTextBlockId)
          : null;

  PresentationComponentBlock? get selectedComponentBlock =>
      _selectedComponentBlockIds.length == 1 && _selectedTextBlockIds.isEmpty
          ? selectedPage.findComponentBlock(_selectedComponentBlockId)
          : null;

  bool get canRemovePage => _pages.length > 1;
  bool get canRemoveTextBlock => _selectedTextBlockIds.isNotEmpty;
  bool get canRemoveComponentBlock => _selectedComponentBlockIds.isNotEmpty;
  bool get canRemoveSelection => hasSelection;
  int get selectedPageBlockCount =>
      selectedPage.textBlocks.length + selectedPage.componentBlocks.length;
  int get selectedPageRevealStepCount => revealStepCountForPage(selectedPage);
  int? get selectedRevealStep {
    final steps = <int>{
      ...selectedPage.textBlocks
          .where((block) => _selectedTextBlockIds.contains(block.id))
          .map((block) => block.revealStep),
      ...selectedPage.componentBlocks
          .where((block) => _selectedComponentBlockIds.contains(block.id))
          .map((block) => block.revealStep),
    };
    return steps.length == 1 ? steps.single : null;
  }

  String? get selectedHotspotTargetPageId {
    final targets = <String?>{
      ...selectedPage.textBlocks
          .where((block) => _selectedTextBlockIds.contains(block.id))
          .map((block) => block.hotspotTargetPageId),
      ...selectedPage.componentBlocks
          .where((block) => _selectedComponentBlockIds.contains(block.id))
          .map((block) => block.hotspotTargetPageId),
    };
    return targets.length == 1 ? targets.single : null;
  }

  int revealStepCountForPage(PresentationPage page) {
    var maxStep = 0;
    for (final block in page.textBlocks) {
      maxStep = math.max(maxStep, block.revealStep);
    }
    for (final block in page.componentBlocks) {
      maxStep = math.max(maxStep, block.revealStep);
    }
    return maxStep;
  }

  void selectPage(int index) {
    if (index < 0 || index >= _pages.length || index == _selectedPageIndex) {
      return;
    }
    _selectedPageIndex = index;
    _resetSelectionForCurrentPage();
    notifyListeners();
  }

  void selectTextBlock(String textBlockId) {
    if ((_selectedTextBlockId == textBlockId &&
            _selectedTextBlockIds.length == 1 &&
            _selectedComponentBlockIds.isEmpty) ||
        selectedPage.findTextBlock(textBlockId) == null) {
      return;
    }

    _setSingleSelection(textBlockId: textBlockId);
    notifyListeners();
  }

  void selectComponentBlock(String componentBlockId) {
    if ((_selectedComponentBlockId == componentBlockId &&
            _selectedComponentBlockIds.length == 1 &&
            _selectedTextBlockIds.isEmpty) ||
        selectedPage.findComponentBlock(componentBlockId) == null) {
      return;
    }

    _setSingleSelection(componentBlockId: componentBlockId);
    notifyListeners();
  }

  void selectItems({
    Iterable<String> textBlockIds = const <String>[],
    Iterable<String> componentBlockIds = const <String>[],
  }) {
    final nextTextIds = textBlockIds
        .where((id) => selectedPage.findTextBlock(id) != null)
        .toList(growable: false);
    final nextComponentIds = componentBlockIds
        .where((id) => selectedPage.findComponentBlock(id) != null)
        .toList(growable: false);

    _selectedTextBlockIds
      ..clear()
      ..addAll(nextTextIds);
    _selectedComponentBlockIds
      ..clear()
      ..addAll(nextComponentIds);
    _selectedTextBlockId = nextTextIds.firstOrNull;
    _selectedComponentBlockId = nextComponentIds.firstOrNull;
    notifyListeners();
  }

  void clearSelection() {
    if (!hasSelection) {
      return;
    }

    _selectedTextBlockIds.clear();
    _selectedComponentBlockIds.clear();
    _selectedTextBlockId = null;
    _selectedComponentBlockId = null;
    notifyListeners();
  }

  void updateSelectedText(String value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(text: value),
    );
  }

  void updateSelectedFontSize(double value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(fontSize: value),
    );
  }

  void updateSelectedTextType(PresentationTextType value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(type: value),
    );
  }

  void updateSelectedTextStyle(PresentationTextStyle value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(textStyle: value),
    );
  }

  void updateSelectedTextAnimation(PresentationTextAnimation value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(textAnimation: value),
    );
  }

  void updateSelectedTextColor(String? value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(textColorHex: value),
    );
  }

  void updateSelectedGlowIntensity(double value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(glowIntensity: value.clamp(0, 2)),
    );
  }

  void updateSelectedTextBold(bool value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(textBold: value),
    );
  }

  void updateSelectedTextItalic(bool value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(textItalic: value),
    );
  }

  void updateSelectedTextUnderline(bool value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(textUnderline: value),
    );
  }

  void updateSelectedTextAlign(PresentationTextAlign value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(textAlign: value),
    );
  }

  void updateSelectedModelAutoRotate(bool value) {
    final current = selectedComponentBlock;
    if (current == null ||
        current.modelAssetId == null ||
        current.modelAutoRotate == value) {
      return;
    }

    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(modelAutoRotate: value)
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  /// Seçili bileşeni çizim sırasında bir adım öne/arkaya taşır (z-order).
  /// [forward] true ise listenin sonuna (en üste) doğru kayar.
  void moveSelectedComponentLayer({required bool forward}) {
    final current = selectedComponentBlock;
    if (current == null) {
      return;
    }
    final components = List<PresentationComponentBlock>.of(
      selectedPage.componentBlocks,
    );
    final index = components.indexWhere((block) => block.id == current.id);
    if (index < 0) {
      return;
    }
    final target = forward ? index + 1 : index - 1;
    if (target < 0 || target >= components.length) {
      return;
    }
    final moved = components.removeAt(index);
    components.insert(target, moved);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: components),
    );
    notifyListeners();
  }

  void updateSelectedModelAnimationEnabled(bool value) {
    final current = selectedComponentBlock;
    if (current == null ||
        current.modelAssetId == null ||
        current.modelAnimationEnabled == value) {
      return;
    }

    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(modelAnimationEnabled: value)
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void updateSelectedModelOrbitEnabled(bool value) {
    final current = selectedComponentBlock;
    if (current == null ||
        current.modelAssetId == null ||
        current.modelOrbitEnabled == value) {
      return;
    }

    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(modelOrbitEnabled: value)
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void toggleSelectedModelOrbit() {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null) {
      return;
    }
    updateSelectedModelOrbitEnabled(!current!.modelOrbitEnabled);
  }

  void beginSelectedModelOrbitGesture() {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null ||
        !current!.modelOrbitEnabled ||
        _modelOrbitGestureActive) {
      return;
    }
    _recordUndo();
    _modelOrbitGestureActive = true;
  }

  void endSelectedModelOrbitGesture() {
    _modelOrbitGestureActive = false;
  }

  void rotateSelectedModel(Offset delta) {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null || !current!.modelOrbitEnabled) {
      return;
    }

    final nextTheta = (current.modelOrbitTheta - delta.dx * 0.55) % 360;
    final nextPhi =
        (current.modelOrbitPhi + delta.dy * 0.45).clamp(10.0, 170.0).toDouble();
    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(
                  modelOrbitTheta: nextTheta,
                  modelOrbitPhi: nextPhi,
                )
              : block,
        )
        .toList(growable: false);
    final nextPage = selectedPage.copyWith(componentBlocks: nextComponents);
    if (_modelOrbitGestureActive) {
      _pages[_selectedPageIndex] = nextPage;
    } else {
      _replaceSelectedPage(nextPage);
    }
    notifyListeners();
  }

  void updateSelectedBackground(PresentationBackgroundKind value) {
    if (selectedPage.backgroundKind == value) {
      return;
    }
    _replaceSelectedPage(selectedPage.copyWith(backgroundKind: value));
    notifyListeners();
  }

void updateAllPageBackgrounds(PresentationBackgroundKind value) {
    if (_pages.every((page) => page.backgroundKind == value)) {
      return;
    }
    _recordUndo();
    final updatedPages = _pages
        .map((page) => page.copyWith(backgroundKind: value))
        .toList(growable: false);
    _pages
      ..clear()
      ..addAll(updatedPages);
    notifyListeners();
  }

  void applyTemplate(PresentationTemplate template) {
    final config = _templateConfig(template);
    _recordUndo();

    final updatedPages = _pages.map((page) {
      var updatedPage = page.copyWith(
        backgroundKind: config.backgroundKind ?? page.backgroundKind,
      );

      // Apply text styles and animations to all text blocks
      final updatedTextBlocks = updatedPage.textBlocks.map((block) {
        var newBlock = block;
        if (block.type == PresentationTextType.title) {
          newBlock = newBlock.copyWith(
            textStyle: config.titleTextStyle,
            textAnimation: config.titleTextAnimation,
            textColorHex: config.titleTextColor,
            glowIntensity: config.glowIntensity,
            fontSize: (block.fontSize * config.fontScale).clamp(18.0, 120.0),
          );
        } else {
          newBlock = newBlock.copyWith(
            textStyle: config.bodyTextStyle,
            textAnimation: config.bodyTextAnimation,
            textColorHex: config.bodyTextColor,
            glowIntensity: config.glowIntensity,
            fontSize: (block.fontSize * config.fontScale).clamp(18.0, 120.0),
          );
        }
        return newBlock;
      }).toList(growable: false);

      updatedPage = updatedPage.copyWith(textBlocks: updatedTextBlocks);

      // Update transition settings
      _effectSettings = _effectSettings.copyWith(
        transitionKind: config.transitionKind,
        transitionDurationMs: config.transitionDurationMs,
      );

      return updatedPage;
    }).toList(growable: false);

    _pages
      ..clear()
      ..addAll(updatedPages);
    notifyListeners();
  }

  void updateSelectedPageNotes(String value) {
    if (selectedPage.speakerNotes == value) {
      return;
    }
    _replaceSelectedPage(selectedPage.copyWith(speakerNotes: value));
    notifyListeners();
  }

  void updateSelectedRevealStep(double value) {
    final nextStep = value.round().clamp(0, _maxRevealStep).toInt();
    if (!hasSelection) {
      return;
    }

    var changed = false;
    final nextBlocks = selectedPage.textBlocks.map((block) {
      if (!_selectedTextBlockIds.contains(block.id) ||
          block.revealStep == nextStep) {
        return block;
      }
      changed = true;
      return block.copyWith(revealStep: nextStep);
    }).toList(growable: false);
    final nextComponents = selectedPage.componentBlocks.map((block) {
      if (!_selectedComponentBlockIds.contains(block.id) ||
          block.revealStep == nextStep) {
        return block;
      }
      changed = true;
      return block.copyWith(revealStep: nextStep);
    }).toList(growable: false);

    if (!changed) {
      return;
    }
    _replaceSelectedPage(
      selectedPage.copyWith(
        textBlocks: nextBlocks,
        componentBlocks: nextComponents,
      ),
    );
    notifyListeners();
  }

  void updateSelectedHotspotTarget(String? pageId) {
    if (!hasSelection) {
      return;
    }

    final normalizedTarget = pageId != null &&
            pageId != selectedPage.id &&
            _pages.any((page) => page.id == pageId)
        ? pageId
        : null;

    var changed = false;
    final nextBlocks = selectedPage.textBlocks.map((block) {
      if (!_selectedTextBlockIds.contains(block.id) ||
          block.hotspotTargetPageId == normalizedTarget) {
        return block;
      }
      changed = true;
      return block.copyWith(hotspotTargetPageId: normalizedTarget);
    }).toList(growable: false);
    final nextComponents = selectedPage.componentBlocks.map((block) {
      if (!_selectedComponentBlockIds.contains(block.id) ||
          block.hotspotTargetPageId == normalizedTarget) {
        return block;
      }
      changed = true;
      return block.copyWith(hotspotTargetPageId: normalizedTarget);
    }).toList(growable: false);

    if (!changed) {
      return;
    }
    _replaceSelectedPage(
      selectedPage.copyWith(
        textBlocks: nextBlocks,
        componentBlocks: nextComponents,
      ),
    );
    notifyListeners();
  }

  void updateTransitionKind(PresentationTransitionKind value) {
    if (_effectSettings.transitionKind == value) {
      return;
    }
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(transitionKind: value);
    notifyListeners();
  }

  void updateTransitionDuration(double value) {
    final nextDuration = value
        .round()
        .clamp(_minTransitionDurationMs, _maxTransitionDurationMs)
        .toInt();
    if (_effectSettings.transitionDurationMs == nextDuration) {
      return;
    }
    _recordUndo();
    _effectSettings =
        _effectSettings.copyWith(transitionDurationMs: nextDuration);
    notifyListeners();
  }

  void updateZoomEnabled(bool value) {
    if (_effectSettings.zoomEnabled == value) {
      return;
    }
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(zoomEnabled: value);
    notifyListeners();
  }

  void updateZoomScale(double value) {
    final nextScale = value.clamp(_minZoomScale, _maxZoomScale).toDouble();
    if (_effectSettings.zoomScale == nextScale) {
      return;
    }
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(zoomScale: nextScale);
    notifyListeners();
  }

  void updateReducedMotion(bool value) {
    if (_effectSettings.reducedMotion == value) {
      return;
    }
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(reducedMotion: value);
    notifyListeners();
  }

  void updateSelectedTextWidth(double value) {
    final current = selectedTextBlock;
    if (current == null) {
      return;
    }

    _replaceSelectedTextBlock(
      current.copyWith(
        widthFactor: _clampWidthFactor(value, current.position.dx),
      ),
    );
  }

  void replaceDeck(
    List<PresentationPage> pages, {
    PresentationEffectSettings? effectSettings,
  }) {
    if (pages.isEmpty) {
      return;
    }

    _pages
      ..clear()
      ..addAll(pages);
    if (effectSettings != null) {
      _effectSettings = effectSettings;
    }
    _selectedPageIndex = 0;
    _pageCounter = _nextCounterForPrefix(
      _pages.map((page) => page.id),
      'page-',
    );
    _textBlockCounter = _nextCounterForPrefix(
      _pages.expand((page) => page.textBlocks).map((block) => block.id),
      'text-',
    );
    _componentBlockCounter = _nextCounterForPrefix(
      _pages.expand((page) => page.componentBlocks).map((block) => block.id),
      'component-',
    );
    _selectedTextBlockIds.clear();
    _selectedComponentBlockIds.clear();
    _selectedTextBlockId = null;
    _selectedComponentBlockId = null;
    _resetSelectionForCurrentPage();
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) {
      return;
    }

    final current = _captureSnapshot();
    final previous = _undoStack.removeLast();
    _redoStack.add(current);
    _restoreSnapshot(previous);
    notifyListeners();
  }

  void redo() {
    if (!canRedo) {
      return;
    }

    final current = _captureSnapshot();
    final next = _redoStack.removeLast();
    _undoStack.add(current);
    _restoreSnapshot(next);
    notifyListeners();
  }

  void addPage() {
    _recordUndo();
    final inheritedBackground = selectedPage.backgroundKind;
    final textBlock = _createTextBlock(
      text: '',
      position: const Offset(0.12, 0.16),
      fontSize: 48,
      type: PresentationTextType.title,
      widthFactor: 0.34,
    );
    _pages.add(
      PresentationPage(
        id: 'page-$_pageCounter',
        textBlocks: <PresentationTextBlock>[textBlock],
        backgroundKind: inheritedBackground,
      ),
    );
    _pageCounter += 1;
    _selectedPageIndex = _pages.length - 1;
    _setSingleSelection(textBlockId: textBlock.id);
    notifyListeners();
  }

  void removeSelectedPage() {
    if (!canRemovePage) {
      return;
    }
    _recordUndo();
    final removedPageId = selectedPage.id;
    _pages.removeAt(_selectedPageIndex);
    _clearHotspotsTargeting(removedPageId);
    if (_selectedPageIndex >= _pages.length) {
      _selectedPageIndex = _pages.length - 1;
    }
    _resetSelectionForCurrentPage();
    notifyListeners();
  }

  void addTextBlock() {
    final page = selectedPage;
    final blockCount = page.textBlocks.length;
    final nextX = (0.12 + (blockCount % 3) * 0.08).clamp(0.08, 0.68);
    final nextY = (0.16 + (blockCount % 4) * 0.12).clamp(0.08, 0.76);
    final textBlock = _createTextBlock(
      text: '',
      position: Offset(nextX.toDouble(), nextY.toDouble()),
      fontSize: 42,
      type: PresentationTextType.body,
      widthFactor: 0.28,
    );
    _replaceSelectedPage(
      page.copyWith(
        textBlocks: <PresentationTextBlock>[
          ...page.textBlocks,
          textBlock,
        ],
      ),
    );
    _setSingleSelection(textBlockId: textBlock.id);
    notifyListeners();
  }

  void addComponentBlock(PresentationComponentKind kind) {
    final page = selectedPage;
    final blockCount = page.componentBlocks.length;
    final nextX = (0.56 + (blockCount % 3) * 0.04).clamp(0.08, 0.70);
    final nextY = (0.18 + (blockCount % 4) * 0.09).clamp(0.08, 0.68);
    final componentBlock = PresentationComponentBlock(
      id: 'component-$_componentBlockCounter',
      kind: kind,
      position: Offset(nextX.toDouble(), nextY.toDouble()),
      size: const Size(0.28, 0.28),
    );
    _componentBlockCounter += 1;
    _replaceSelectedPage(
      page.copyWith(
        componentBlocks: <PresentationComponentBlock>[
          ...page.componentBlocks,
          componentBlock,
        ],
      ),
    );
    _setSingleSelection(componentBlockId: componentBlock.id);
    notifyListeners();
  }

  void add3DModelBlock(Presentation3DModelAsset model) {
    final page = selectedPage;
    final blockCount = page.componentBlocks.length;
    final nextX = (0.50 + (blockCount % 3) * 0.04).clamp(0.08, 0.58);
    final nextY = (0.16 + (blockCount % 4) * 0.08).clamp(0.08, 0.54);
    final componentBlock = PresentationComponentBlock(
      id: 'component-$_componentBlockCounter',
      modelAssetId: model.id,
      modelOrbitEnabled: false,
      position: Offset(nextX.toDouble(), nextY.toDouble()),
      size: const Size(0.40, 0.40),
    );
    _componentBlockCounter += 1;
    _replaceSelectedPage(
      page.copyWith(
        componentBlocks: <PresentationComponentBlock>[
          ...page.componentBlocks,
          componentBlock,
        ],
      ),
    );
    _setSingleSelection(componentBlockId: componentBlock.id);
    notifyListeners();
  }

  void addUploadedImageBlock(String imageAssetId) {
    final page = selectedPage;
    final blockCount = page.componentBlocks.length;
    final nextX = (0.50 + (blockCount % 3) * 0.04).clamp(0.08, 0.58);
    final nextY = (0.16 + (blockCount % 4) * 0.08).clamp(0.08, 0.54);
    final componentBlock = PresentationComponentBlock(
      id: 'component-$_componentBlockCounter',
      modelAssetId: imageAssetId,
      position: Offset(nextX.toDouble(), nextY.toDouble()),
      size: const Size(0.38, 0.26),
    );
    _componentBlockCounter += 1;
    _replaceSelectedPage(
      page.copyWith(
        componentBlocks: <PresentationComponentBlock>[
          ...page.componentBlocks,
          componentBlock,
        ],
      ),
    );
    _setSingleSelection(componentBlockId: componentBlock.id);
    notifyListeners();
  }

  void removeSelectedTextBlock() {
    if (_selectedTextBlockIds.isEmpty) {
      return;
    }

    final removedIds = Set<String>.from(_selectedTextBlockIds);
    final nextBlocks = selectedPage.textBlocks
        .where((block) => !removedIds.contains(block.id))
        .toList(growable: false);
    _replaceSelectedPage(selectedPage.copyWith(textBlocks: nextBlocks));
    _selectedTextBlockIds.clear();
    _normalizeSelectionAfterMutation(fallbackToFirst: true);
    notifyListeners();
  }

  void removeSelectedComponentBlock() {
    if (_selectedComponentBlockIds.isEmpty) {
      return;
    }

    final removedIds = Set<String>.from(_selectedComponentBlockIds);
    final nextBlocks = selectedPage.componentBlocks
        .where((block) => !removedIds.contains(block.id))
        .toList(growable: false);
    _replaceSelectedPage(selectedPage.copyWith(componentBlocks: nextBlocks));
    _selectedComponentBlockIds.clear();
    _normalizeSelectionAfterMutation(fallbackToFirst: true);
    notifyListeners();
  }

  void removeSelectedItems() {
    if (!hasSelection) {
      return;
    }

    final removedTextIds = Set<String>.from(_selectedTextBlockIds);
    final removedComponentIds = Set<String>.from(_selectedComponentBlockIds);
    final nextTextBlocks = selectedPage.textBlocks
        .where((block) => !removedTextIds.contains(block.id))
        .toList(growable: false);
    final nextComponentBlocks = selectedPage.componentBlocks
        .where((block) => !removedComponentIds.contains(block.id))
        .toList(growable: false);

    _replaceSelectedPage(
      selectedPage.copyWith(
        textBlocks: nextTextBlocks,
        componentBlocks: nextComponentBlocks,
      ),
    );
    _selectedTextBlockIds.clear();
    _selectedComponentBlockIds.clear();
    _normalizeSelectionAfterMutation(fallbackToFirst: true);
    notifyListeners();
  }

  void copySelectedItems() {
    if (!hasSelection) {
      return;
    }

    _copiedTextBlocks = selectedPage.textBlocks
        .where((block) => _selectedTextBlockIds.contains(block.id))
        .toList(growable: false);
    _copiedComponentBlocks = selectedPage.componentBlocks
        .where((block) => _selectedComponentBlockIds.contains(block.id))
        .toList(growable: false);
  }

  void pasteCopiedItems() {
    if (!canPasteItems) {
      return;
    }
    _insertCopiedItems(
      textBlocks: _copiedTextBlocks,
      componentBlocks: _copiedComponentBlocks,
    );
  }

  void cutSelectedItems() {
    if (!hasSelection) {
      return;
    }
    copySelectedItems();
    removeSelectedItems();
  }

  void duplicateSelectedItems() {
    if (!hasSelection) {
      return;
    }

    _insertCopiedItems(
      textBlocks: selectedPage.textBlocks
          .where((block) => _selectedTextBlockIds.contains(block.id))
          .toList(growable: false),
      componentBlocks: selectedPage.componentBlocks
          .where((block) => _selectedComponentBlockIds.contains(block.id))
          .toList(growable: false),
    );
  }

  void selectAllItems() {
    final page = selectedPage;
    _selectedTextBlockIds
      ..clear()
      ..addAll(page.textBlocks.map((b) => b.id));
    _selectedComponentBlockIds
      ..clear()
      ..addAll(page.componentBlocks.map((b) => b.id));
    _selectedTextBlockId = page.textBlocks.firstOrNull?.id;
    _selectedComponentBlockId = page.componentBlocks.firstOrNull?.id;
    notifyListeners();
  }

  void _insertCopiedItems({
    required List<PresentationTextBlock> textBlocks,
    required List<PresentationComponentBlock> componentBlocks,
  }) {
    if (textBlocks.isEmpty && componentBlocks.isEmpty) {
      return;
    }

    final insertedTextBlocks = textBlocks.map((block) {
      final nextPosition = Offset(
        (block.position.dx + 0.03)
            .clamp(0.04, _maxLeftPositionForWidth(block.widthFactor))
            .toDouble(),
        (block.position.dy + 0.04).clamp(0.05, 0.84).toDouble(),
      );
      return block.copyWith(
        id: 'text-${_textBlockCounter++}',
        position: nextPosition,
      );
    }).toList(growable: false);
    final insertedComponentBlocks = componentBlocks.map((block) {
      final nextPosition = Offset(
        (block.position.dx + 0.03)
            .clamp(0.04, _maxLeftPositionForWidth(block.size.width))
            .toDouble(),
        (block.position.dy + 0.04)
            .clamp(0.05, _maxTopPositionForHeight(block.size.height))
            .toDouble(),
      );
      return block.copyWith(
        id: 'component-${_componentBlockCounter++}',
        position: nextPosition,
      );
    }).toList(growable: false);

    _replaceSelectedPage(
      selectedPage.copyWith(
        textBlocks: <PresentationTextBlock>[
          ...selectedPage.textBlocks,
          ...insertedTextBlocks,
        ],
        componentBlocks: <PresentationComponentBlock>[
          ...selectedPage.componentBlocks,
          ...insertedComponentBlocks,
        ],
      ),
    );
    _selectedTextBlockIds
      ..clear()
      ..addAll(insertedTextBlocks.map((block) => block.id));
    _selectedComponentBlockIds
      ..clear()
      ..addAll(insertedComponentBlocks.map((block) => block.id));
    _selectedTextBlockId = insertedTextBlocks.firstOrNull?.id;
    _selectedComponentBlockId = insertedComponentBlocks.firstOrNull?.id;
    notifyListeners();
  }

  void moveSelectedText(Offset delta, Size canvasSize) {
    _moveSelection(delta, canvasSize);
  }

  void _moveSelection(Offset delta, Size canvasSize) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return;
    }

    final selectedTextBlocks = selectedPage.textBlocks
        .where((block) => _selectedTextBlockIds.contains(block.id))
        .toList(growable: false);
    final selectedComponentBlocks = selectedPage.componentBlocks
        .where((block) => _selectedComponentBlockIds.contains(block.id))
        .toList(growable: false);
    if (selectedTextBlocks.isEmpty && selectedComponentBlocks.isEmpty) {
      return;
    }

    var minDeltaX = double.negativeInfinity;
    var maxDeltaX = double.infinity;
    var minDeltaY = double.negativeInfinity;
    var maxDeltaY = double.infinity;

    for (final block in selectedTextBlocks) {
      minDeltaX = math.max(minDeltaX, 0.04 - block.position.dx);
      maxDeltaX = math.min(
        maxDeltaX,
        _maxLeftPositionForWidth(block.widthFactor) - block.position.dx,
      );
      minDeltaY = math.max(minDeltaY, 0.05 - block.position.dy);
      maxDeltaY = math.min(maxDeltaY, 0.84 - block.position.dy);
    }
    for (final block in selectedComponentBlocks) {
      minDeltaX = math.max(minDeltaX, 0.04 - block.position.dx);
      maxDeltaX = math.min(
        maxDeltaX,
        _maxLeftPositionForWidth(block.size.width) - block.position.dx,
      );
      minDeltaY = math.max(minDeltaY, 0.05 - block.position.dy);
      maxDeltaY = math.min(
        maxDeltaY,
        _maxTopPositionForHeight(block.size.height) - block.position.dy,
      );
    }

    final deltaX = (delta.dx / canvasSize.width).clamp(minDeltaX, maxDeltaX);
    final deltaY = (delta.dy / canvasSize.height).clamp(minDeltaY, maxDeltaY);

    final nextBlocks = selectedPage.textBlocks
        .map(
          (block) => _selectedTextBlockIds.contains(block.id)
              ? block.copyWith(
                  position: Offset(
                    block.position.dx + deltaX,
                    block.position.dy + deltaY,
                  ),
                )
              : block,
        )
        .toList(growable: false);
    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => _selectedComponentBlockIds.contains(block.id)
              ? block.copyWith(
                  position: Offset(
                    block.position.dx + deltaX,
                    block.position.dy + deltaY,
                  ),
                )
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(
        textBlocks: nextBlocks,
        componentBlocks: nextComponents,
      ),
    );
    notifyListeners();
  }

  void resizeSelectedTextWidth(double deltaX, Size canvasSize) {
    if (canvasSize.width <= 0) {
      return;
    }

    final current = selectedTextBlock;
    if (current == null) {
      return;
    }

    final nextWidth = current.widthFactor + deltaX / canvasSize.width;
    _replaceSelectedTextBlock(
      current.copyWith(
        widthFactor: _clampWidthFactor(nextWidth, current.position.dx),
      ),
    );
  }

  void scaleSelectedComponent(double scale) {
    final current = selectedComponentBlock;
    if (current == null) {
      return;
    }

    final nextWidth = (current.size.width * scale)
        .clamp(_minComponentWidthFactor, _maxComponentWidthFactor)
        .toDouble();
    final nextHeight = (current.size.height * scale)
        .clamp(_minComponentHeightFactor, _maxComponentHeightFactor)
        .toDouble();
    final nextSize = Size(nextWidth, nextHeight);
    final nextPosition = Offset(
      current.position.dx
          .clamp(0.04, _maxLeftPositionForWidth(nextWidth))
          .toDouble(),
      current.position.dy
          .clamp(0.05, _maxTopPositionForHeight(nextHeight))
          .toDouble(),
    );
    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(position: nextPosition, size: nextSize)
              : block,
        )
        .toList(growable: false);

    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void resizeSelectedComponentByHandle(
    Offset delta,
    Size canvasSize, {
    required bool fromLeft,
    required bool fromTop,
    required bool fromRight,
    required bool fromBottom,
  }) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return;
    }

    final current = selectedComponentBlock;
    if (current == null) {
      return;
    }

    final deltaX = delta.dx / canvasSize.width;
    final deltaY = delta.dy / canvasSize.height;
    var left = current.position.dx;
    var top = current.position.dy;
    var right = current.position.dx + current.size.width;
    var bottom = current.position.dy + current.size.height;

    if (fromLeft) {
      left += deltaX;
    }
    if (fromRight) {
      right += deltaX;
    }
    if (fromTop) {
      top += deltaY;
    }
    if (fromBottom) {
      bottom += deltaY;
    }

    const minLeft = 0.04;
    const minTop = 0.05;
    const maxRight = 1 - _maxTextRightPaddingFactor;
    const maxBottom = 0.95;

    if (fromLeft) {
      left = left
          .clamp(
            math.max(minLeft, right - _maxComponentWidthFactor),
            right - _minComponentWidthFactor,
          )
          .toDouble();
    }
    if (fromRight) {
      right = right
          .clamp(
            left + _minComponentWidthFactor,
            math.min(maxRight, left + _maxComponentWidthFactor),
          )
          .toDouble();
    }
    if (fromTop) {
      top = top
          .clamp(
            math.max(minTop, bottom - _maxComponentHeightFactor),
            bottom - _minComponentHeightFactor,
          )
          .toDouble();
    }
    if (fromBottom) {
      bottom = bottom
          .clamp(
            top + _minComponentHeightFactor,
            math.min(maxBottom, top + _maxComponentHeightFactor),
          )
          .toDouble();
    }

    final nextSize = Size(
      (right - left).clamp(
        _minComponentWidthFactor,
        _maxComponentWidthFactor,
      ),
      (bottom - top).clamp(
        _minComponentHeightFactor,
        _maxComponentHeightFactor,
      ),
    );
    final nextPosition = Offset(
      left.clamp(minLeft, _maxLeftPositionForWidth(nextSize.width)).toDouble(),
      top.clamp(minTop, _maxTopPositionForHeight(nextSize.height)).toDouble(),
    );

    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(position: nextPosition, size: nextSize)
              : block,
        )
        .toList(growable: false);

    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void _recordUndo() {
    if (_historySuspended) {
      return;
    }

    _undoStack.add(_captureSnapshot());
    if (_undoStack.length > _maxHistoryEntries) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  _PresentationSnapshot _captureSnapshot() {
    return _PresentationSnapshot(
      pages: List<PresentationPage>.unmodifiable(_pages),
      selectedPageIndex: _selectedPageIndex,
      pageCounter: _pageCounter,
      textBlockCounter: _textBlockCounter,
      componentBlockCounter: _componentBlockCounter,
      selectedTextBlockId: _selectedTextBlockId,
      selectedComponentBlockId: _selectedComponentBlockId,
      selectedTextBlockIds: List<String>.unmodifiable(_selectedTextBlockIds),
      selectedComponentBlockIds:
          List<String>.unmodifiable(_selectedComponentBlockIds),
      effectSettings: _effectSettings,
    );
  }

  void _restoreSnapshot(_PresentationSnapshot snapshot) {
    _historySuspended = true;
    _pages
      ..clear()
      ..addAll(snapshot.pages);
    _selectedPageIndex = snapshot.selectedPageIndex
        .clamp(0, math.max(0, _pages.length - 1))
        .toInt();
    _pageCounter = snapshot.pageCounter;
    _textBlockCounter = snapshot.textBlockCounter;
    _componentBlockCounter = snapshot.componentBlockCounter;
    _selectedTextBlockId = snapshot.selectedTextBlockId;
    _selectedComponentBlockId = snapshot.selectedComponentBlockId;
    _selectedTextBlockIds
      ..clear()
      ..addAll(snapshot.selectedTextBlockIds);
    _selectedComponentBlockIds
      ..clear()
      ..addAll(snapshot.selectedComponentBlockIds);
    _effectSettings = snapshot.effectSettings;
    _normalizeSelectionAfterMutation(fallbackToFirst: true);
    _historySuspended = false;
  }

  void _replaceSelectedPage(PresentationPage page) {
    _recordUndo();
    _pages[_selectedPageIndex] = page;
  }

  void _setSingleSelection({
    String? textBlockId,
    String? componentBlockId,
  }) {
    _selectedTextBlockIds.clear();
    _selectedComponentBlockIds.clear();

    if (textBlockId != null) {
      _selectedTextBlockIds.add(textBlockId);
    }
    if (componentBlockId != null) {
      _selectedComponentBlockIds.add(componentBlockId);
    }

    _selectedTextBlockId = textBlockId;
    _selectedComponentBlockId = componentBlockId;
  }

  void _replaceSelectedTextBlock(PresentationTextBlock? nextBlock) {
    final current = selectedTextBlock;
    if (current == null || nextBlock == null) {
      return;
    }

    final nextBlocks = selectedPage.textBlocks
        .map((block) => block.id == current.id ? nextBlock : block)
        .toList(growable: false);
    _replaceSelectedPage(selectedPage.copyWith(textBlocks: nextBlocks));
    notifyListeners();
  }

  void _clearHotspotsTargeting(String removedPageId) {
    for (var i = 0; i < _pages.length; i += 1) {
      final page = _pages[i];
      var changed = false;
      final nextBlocks = page.textBlocks.map((block) {
        if (block.hotspotTargetPageId != removedPageId) {
          return block;
        }
        changed = true;
        return block.copyWith(hotspotTargetPageId: null);
      }).toList(growable: false);
      final nextComponents = page.componentBlocks.map((block) {
        if (block.hotspotTargetPageId != removedPageId) {
          return block;
        }
        changed = true;
        return block.copyWith(hotspotTargetPageId: null);
      }).toList(growable: false);
      if (changed) {
        _pages[i] = page.copyWith(
          textBlocks: nextBlocks,
          componentBlocks: nextComponents,
        );
      }
    }
  }

  PresentationTextBlock _createTextBlock({
    required String text,
    required Offset position,
    required double fontSize,
    required PresentationTextType type,
    required double widthFactor,
  }) {
    final textBlock = PresentationTextBlock(
      id: 'text-$_textBlockCounter',
      text: text,
      position: position,
      fontSize: fontSize,
      type: type,
      widthFactor: widthFactor,
    );
    _textBlockCounter += 1;
    return textBlock;
  }

  double _clampWidthFactor(double value, double positionX) {
    final maxWidth = (1 - positionX - _maxTextRightPaddingFactor)
        .clamp(_minTextWidthFactor, 0.82)
        .toDouble();
    return value.clamp(_minTextWidthFactor, maxWidth).toDouble();
  }

  double _maxLeftPositionForWidth(double widthFactor) {
    return (1 - widthFactor - _maxTextRightPaddingFactor)
        .clamp(0.04, 0.76)
        .toDouble();
  }

  double _maxTopPositionForHeight(double heightFactor) {
    return (1 - heightFactor - 0.05).clamp(0.05, 0.86).toDouble();
  }

  int _nextCounterForPrefix(Iterable<String> ids, String prefix) {
    var maxNumericId = 0;
    var count = 0;
    for (final id in ids) {
      count += 1;
      if (!id.startsWith(prefix)) {
        continue;
      }
      final numericId = int.tryParse(id.substring(prefix.length));
      if (numericId != null) {
        maxNumericId = math.max(maxNumericId, numericId);
      }
    }
    return math.max(maxNumericId + 1, count + 1);
  }

  void _normalizeSelectionAfterMutation({required bool fallbackToFirst}) {
    final existingTextIds =
        selectedPage.textBlocks.map((block) => block.id).toSet();
    final existingComponentIds =
        selectedPage.componentBlocks.map((block) => block.id).toSet();

    _selectedTextBlockIds.removeWhere((id) => !existingTextIds.contains(id));
    _selectedComponentBlockIds
        .removeWhere((id) => !existingComponentIds.contains(id));

    _selectedTextBlockId = _selectedTextBlockIds.contains(_selectedTextBlockId)
        ? _selectedTextBlockId
        : _selectedTextBlockIds.firstOrNull;
    _selectedComponentBlockId =
        _selectedComponentBlockIds.contains(_selectedComponentBlockId)
            ? _selectedComponentBlockId
            : _selectedComponentBlockIds.firstOrNull;

    if (!fallbackToFirst || hasSelection) {
      return;
    }

    _resetSelectionForCurrentPage();
  }

  void _resetSelectionForCurrentPage() {
    final firstTextId = selectedPage.textBlocks.firstOrNull?.id;
    final firstComponentId = selectedPage.componentBlocks.firstOrNull?.id;
    if (firstTextId != null) {
      _setSingleSelection(textBlockId: firstTextId);
    } else {
      _setSingleSelection(componentBlockId: firstComponentId);
    }
  }

  PresentationTemplateConfig _templateConfig(PresentationTemplate template) {
    return templateConfig(template);
  }

  Offset _componentPositionForTemplate(int index, int existingCount) {
    final startX = 0.65 + (existingCount % 3) * 0.04;
    final startY = 0.18 + (index % 4) * 0.12;
    return Offset(startX.clamp(0.08, 0.70).toDouble(), startY.clamp(0.08, 0.68).toDouble());
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

@immutable
class _PresentationSnapshot {
  const _PresentationSnapshot({
    required this.pages,
    required this.selectedPageIndex,
    required this.pageCounter,
    required this.textBlockCounter,
    required this.componentBlockCounter,
    required this.selectedTextBlockId,
    required this.selectedComponentBlockId,
    required this.selectedTextBlockIds,
    required this.selectedComponentBlockIds,
    required this.effectSettings,
  });

  final List<PresentationPage> pages;
  final int selectedPageIndex;
  final int pageCounter;
  final int textBlockCounter;
  final int componentBlockCounter;
  final String? selectedTextBlockId;
  final String? selectedComponentBlockId;
  final List<String> selectedTextBlockIds;
  final List<String> selectedComponentBlockIds;
  final PresentationEffectSettings effectSettings;
}
