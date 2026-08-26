import 'dart:collection';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/slide_model.dart';
import '../models/model_tour_runtime.dart';
import '../services/presentation_auto_builder.dart';

class PresentationController extends ChangeNotifier {
  static const double minTextFontSize = 18;
  static const double maxTextFontSize = 320;
  static const double _minTextWidthFactor = 0.18;
  static const int _minTransitionDurationMs = 120;
  static const int _maxTransitionDurationMs = 3000;
  static const double _minZoomScale = 1.1;
  static const double _maxZoomScale = 2.4;
  static const int _maxRevealStep = 9;
  static const double _minComponentWidthFactor = 0.08;
  static const double _minComponentHeightFactor = 0.08;
  // Bunlar sahne sınırı değil, yalnızca aşırı büyük Flutter katmanlarının
  // yanlışlıkla oluşturulmasını önleyen teknik güvenlik eşikleridir.
  static const double _maxComponentWidthFactor = 10;
  static const double _maxComponentHeightFactor = 10;
  static const int _maxHistoryEntries = 80;
  // Sanal tur kamerası zeminin altına inmez. Böylece modelin alt yüzeyi
  // görünmez ve yön kontrolü kutuplarda tersine dönmez. Gerçek zemin hedefi
  // HTML katmanında modelin alt sınırından (Y=0) hesaplanır.
  static const double _tourMinCameraPhi = 42;
  static const double _tourDefaultCameraPhi = 82;
  static const double _tourMaxCameraPhi = 89;
  // Tur hedefleri modelin yerel metresidir. Kesin sınır, model-viewer model
  // yüklenince gerçek bounding box'tan çıkarılır; bu genel sınır yalnızca
  // bozuk proje verisinin çalışma alanını aşmasını engeller.
  static const double _tourMaxTargetMetres = 500;

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
  bool _modelTourPointPlacementEnabled = false;
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
  String? _inlineTextEditingBlockId;
  bool _inlineTextEditHasChanges = false;
  bool _selectionTransformActive = false;
  Timer? _selectionTransformIdleTimer;
  bool _modelOrbitGestureActive = false;
  bool _modelCameraGestureHasNotified = false;
  bool _modelCameraHasPendingUpdate = false;
  final Stopwatch _modelCameraNotifyClock = Stopwatch();
  int _transitionPreviewRevision = 0;
  int? _transitionPreviewGapIndex;

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
  int get transitionPreviewRevision => _transitionPreviewRevision;
  int? get transitionPreviewGapIndex => _transitionPreviewGapIndex;
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

  bool get modelTourPointPlacementEnabled => _modelTourPointPlacementEnabled;

  void setModelTourPointPlacementEnabled(bool value) {
    final canPlace = selectedComponentBlock?.modelAssetId != null;
    final next = value && canPlace;
    if (_modelTourPointPlacementEnabled == next) return;
    _modelTourPointPlacementEnabled = next;
    notifyListeners();
  }

  PresentationEntranceAnimation? get selectedEntranceAnimation {
    final text = selectedTextBlock;
    if (text != null) return text.entranceAnimation;
    return selectedComponentBlock?.entranceAnimation;
  }

  PresentationAnimationTrigger? get selectedAnimationTrigger {
    final text = selectedTextBlock;
    if (text != null) return text.animationTrigger;
    return selectedComponentBlock?.animationTrigger;
  }

  double? get selectedAnimationDuration {
    final text = selectedTextBlock;
    if (text != null) return text.animationDuration;
    return selectedComponentBlock?.animationDuration;
  }

  double? get selectedAnimationDelay {
    final text = selectedTextBlock;
    if (text != null) return text.animationDelay;
    return selectedComponentBlock?.animationDelay;
  }

  PresentationTextGrouping? get selectedTextGrouping =>
      selectedTextBlock?.textGrouping;

  double? get selectedTextGroupDelay => selectedTextBlock?.groupDelay;

  List<Offset>? get selectedMotionPathPoints {
    final text = selectedTextBlock;
    if (text != null) return text.motionPathPoints;
    return selectedComponentBlock?.motionPathPoints;
  }

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
    final clickAnimationCount = <Object>[
      ...page.textBlocks,
      ...page.componentBlocks,
    ].where((block) {
      if (block is PresentationTextBlock) {
        return block.entranceAnimation != PresentationEntranceAnimation.none &&
            block.animationTrigger == PresentationAnimationTrigger.onClick;
      }
      final component = block as PresentationComponentBlock;
      return component.entranceAnimation !=
              PresentationEntranceAnimation.none &&
          component.animationTrigger == PresentationAnimationTrigger.onClick;
    }).length;
    return maxStep + clickAnimationCount;
  }

  void selectPage(int index) {
    if (index < 0 || index >= _pages.length || index == _selectedPageIndex) {
      return;
    }
    // Kamera jestinin son throttled bildirimi henüz çizilmemiş olabilir.
    // Sayfa indeksini değiştirmeden önce onu mevcut sayfaya tamamlamak,
    // geri dönüldüğünde son bakış açısının bir önceki frame'e dönmesini önler.
    endSelectedModelOrbitGesture();
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
    final current = selectedTextBlock;
    if (current == null || current.text == value) {
      return;
    }

    // Inline editing must not rebuild the whole editor (or create an undo
    // record) for every character. The TextField owns its live value; we
    // commit one coherent change when editing ends.
    if (_inlineTextEditingBlockId == current.id) {
      if (!_inlineTextEditHasChanges) {
        _recordUndo();
        _inlineTextEditHasChanges = true;
      }
      _replaceSelectedTextBlockWithoutHistory(current.copyWith(text: value));
      return;
    }
    _replaceSelectedTextBlock(
      current.copyWith(text: value),
    );
  }

  void beginInlineTextEditing(String blockId) {
    _inlineTextEditingBlockId = blockId;
    _inlineTextEditHasChanges = false;
  }

  void finishInlineTextEditing(String? blockId) {
    if (blockId != null && _inlineTextEditingBlockId != blockId) {
      return;
    }
    final changed = _inlineTextEditHasChanges;
    _inlineTextEditingBlockId = null;
    _inlineTextEditHasChanges = false;
    if (changed) notifyListeners();
  }

  void updateSelectedFontSize(double value) {
    _replaceSelectedTextBlock(
      selectedTextBlock?.copyWith(
        fontSize: value.clamp(minTextFontSize, maxTextFontSize).toDouble(),
      ),
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

  void updateSelectedEntranceAnimation(PresentationEntranceAnimation value) {
    final nextOrder = _nextEntranceAnimationOrder();
    final text = selectedTextBlock;
    if (text != null) {
      if (text.entranceAnimation == value) return;
      _replaceSelectedTextBlock(
        text.copyWith(
          entranceAnimation: value,
          animationOrder: value == PresentationEntranceAnimation.none
              ? 0
              : (text.animationOrder > 0 ? text.animationOrder : nextOrder),
          textAnimation: value == PresentationEntranceAnimation.none
              ? text.textAnimation
              : PresentationTextAnimation.none,
        ),
      );
      return;
    }
    final component = selectedComponentBlock;
    if (component == null || component.entranceAnimation == value) return;
    final nextComponents = selectedPage.componentBlocks
        .map((block) => block.id == component.id
            ? block.copyWith(
                entranceAnimation: value,
                animationOrder: value == PresentationEntranceAnimation.none
                    ? 0
                    : (block.animationOrder > 0
                        ? block.animationOrder
                        : nextOrder),
              )
            : block)
        .toList(growable: false);
    _replaceSelectedPage(
        selectedPage.copyWith(componentBlocks: nextComponents));
    notifyListeners();
  }

  void updateSelectedAnimationTiming({
    PresentationAnimationTrigger? trigger,
    double? duration,
    double? delay,
  }) {
    final safeDuration = duration?.clamp(.1, 5).toDouble();
    final safeDelay = delay?.clamp(0, 5).toDouble();
    final text = selectedTextBlock;
    if (text != null) {
      _replaceSelectedTextBlock(
        text.copyWith(
          animationTrigger: trigger,
          animationDuration: safeDuration,
          animationDelay: safeDelay,
        ),
      );
      return;
    }
    final component = selectedComponentBlock;
    if (component == null) return;
    final nextComponents = selectedPage.componentBlocks
        .map((block) => block.id == component.id
            ? block.copyWith(
                animationTrigger: trigger,
                animationDuration: safeDuration,
                animationDelay: safeDelay,
              )
            : block)
        .toList(growable: false);
    _replaceSelectedPage(
        selectedPage.copyWith(componentBlocks: nextComponents));
    notifyListeners();
  }

  void updateSelectedTextGrouping({
    PresentationTextGrouping? grouping,
    double? groupDelay,
  }) {
    final text = selectedTextBlock;
    if (text == null) return;
    _replaceSelectedTextBlock(
      text.copyWith(
        textGrouping: grouping,
        groupDelay: groupDelay?.clamp(.05, .5).toDouble(),
      ),
    );
  }

  void updateSelectedMotionPathPoints(List<Offset> points) {
    if (points.length != 4) return;
    final safePoints = points
        .map((point) => Offset(
              point.dx.clamp(-.6, .6).toDouble(),
              point.dy.clamp(-.6, .6).toDouble(),
            ))
        .toList(growable: false);
    final text = selectedTextBlock;
    if (text != null) {
      _replaceSelectedTextBlock(text.copyWith(motionPathPoints: safePoints));
      return;
    }
    final component = selectedComponentBlock;
    if (component == null) return;
    final nextComponents = selectedPage.componentBlocks
        .map((block) => block.id == component.id
            ? block.copyWith(motionPathPoints: safePoints)
            : block)
        .toList(growable: false);
    _replaceSelectedPage(
        selectedPage.copyWith(componentBlocks: nextComponents));
    notifyListeners();
  }

  int _nextEntranceAnimationOrder() {
    var maxOrder = 0;
    for (final block in selectedPage.textBlocks) {
      maxOrder = math.max(maxOrder, block.animationOrder);
    }
    for (final block in selectedPage.componentBlocks) {
      maxOrder = math.max(maxOrder, block.animationOrder);
    }
    return maxOrder + 1;
  }

  void reorderEntranceAnimations(List<String> orderedTargetIds) {
    final orders = <String, int>{
      for (var i = 0; i < orderedTargetIds.length; i += 1)
        orderedTargetIds[i]: i + 1,
    };
    final nextPage = selectedPage.copyWith(
      textBlocks: selectedPage.textBlocks
          .map((block) => orders[block.id] == null
              ? block
              : block.copyWith(animationOrder: orders[block.id]))
          .toList(growable: false),
      componentBlocks: selectedPage.componentBlocks
          .map((block) => orders[block.id] == null
              ? block
              : block.copyWith(animationOrder: orders[block.id]))
          .toList(growable: false),
    );
    _replaceSelectedPage(nextPage);
    notifyListeners();
  }

  void selectAnimationTarget(String targetId) {
    if (selectedPage.findTextBlock(targetId) != null) {
      selectTextBlock(targetId);
    } else if (selectedPage.findComponentBlock(targetId) != null) {
      selectComponentBlock(targetId);
    }
  }

  Future<void> previewEntranceAnimations({String? targetId}) async {
    final original = selectedPage;
    bool matches(String id) => targetId == null || targetId == id;
    final resetPage = original.copyWith(
      textBlocks: original.textBlocks
          .map((block) => matches(block.id)
              ? block.copyWith(
                  entranceAnimation: PresentationEntranceAnimation.none,
                )
              : block)
          .toList(growable: false),
      componentBlocks: original.componentBlocks
          .map((block) => matches(block.id)
              ? block.copyWith(
                  entranceAnimation: PresentationEntranceAnimation.none,
                )
              : block)
          .toList(growable: false),
    );
    _pages[_selectedPageIndex] = resetPage;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_selectedPageIndex >= _pages.length ||
        _pages[_selectedPageIndex].id != original.id) {
      return;
    }
    _pages[_selectedPageIndex] = original;
    notifyListeners();
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
              ? block.copyWith(
                  modelAutoRotate: value,
                  modelTourEnabled: value ? false : block.modelTourEnabled,
                )
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void updateSelectedModelRotationSpeed(double value) {
    final current = selectedComponentBlock;
    if (current == null || current.modelAssetId == null) {
      return;
    }
    final clamped = value.clamp(5.0, 120.0).toDouble();
    if (current.modelRotationSpeed == clamped) {
      return;
    }

    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(modelRotationSpeed: clamped)
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void updateSelectedModelZoom(double value) {
    final current = selectedComponentBlock;
    if (current == null || current.modelAssetId == null) return;
    final clamped = value.clamp(0.5, 10.0).toDouble();
    if (current.modelZoom == clamped) return;

    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(
                  modelZoom: clamped,
                  // Yeni zoom yÃ¼zdesi uygulandÄ±ÄŸÄ±nda eski metre yarÄ±Ã§apÄ± artÄ±k
                  // geÃ§erli deÄŸildir. Model yÃ¼klendiÄŸinde gerÃ§ek yarÄ±Ã§ap tekrar
                  // okunup sunumdan Ã¶nce kaydedilir.
                  modelCameraRadius: null,
                )
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

  /// Seçili bileşeni doğrudan en öne veya en arkaya taşır.
  void moveSelectedComponentToEdge({required bool forward}) {
    final current = selectedComponentBlock;
    if (current == null) {
      return;
    }
    final components = List<PresentationComponentBlock>.of(
      selectedPage.componentBlocks,
    );
    final index = components.indexWhere((block) => block.id == current.id);
    if (index < 0 ||
        (forward && index == components.length - 1) ||
        (!forward && index == 0)) {
      return;
    }
    final moved = components.removeAt(index);
    if (forward) {
      components.add(moved);
    } else {
      components.insert(0, moved);
    }
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: components),
    );
    notifyListeners();
  }

  /// Seçili görseli veya 3B modeli slaydın tamamına yayar ve en altta tutar.
  void setSelectedVisualAsBackground() {
    final current = selectedComponentBlock;
    if (current == null ||
        (current.imageAssetId == null && current.modelAssetId == null)) {
      return;
    }
    final components = List<PresentationComponentBlock>.of(
      selectedPage.componentBlocks,
    );
    final index = components.indexWhere((block) => block.id == current.id);
    if (index < 0) {
      return;
    }
    final background = components.removeAt(index).copyWith(
          position: Offset.zero,
          size: const Size(1, 1),
        );
    components.insert(0, background);
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
              ? block.copyWith(
                  modelOrbitEnabled: value,
                  modelTourEnabled: value ? false : block.modelTourEnabled,
                )
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

  void updateSelectedModelTourEnabled(bool value) {
    final current = selectedComponentBlock;
    final asset = findPresentation3DModelAsset(current?.modelAssetId ?? '');
    if (current == null ||
        current.modelAssetId == null ||
        (value && asset?.supportsVirtualTour != true) ||
        (current.modelTourEnabled == value &&
            (!value || !current.modelTourFrozen))) {
      return;
    }
    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(
                  modelTourEnabled: value,
                  modelTourFrozen: false,
                  modelOrbitEnabled: value ? false : block.modelOrbitEnabled,
                  modelAutoRotate: value ? false : block.modelAutoRotate,
                  // Sanal tur zeminde dolaşır; kameranın alt yüzeye geçmesi
                  // hem modelin tabanını gösterir hem de sağ/sol yönlerini
                  // ters hissettirir. Bu nedenle yalnızca insan göz
                  // hizasındaki güvenli açı aralığı korunur.
                  modelOrbitPhi: value
                      ? (block.modelTourFrozen
                          ? block.modelOrbitPhi
                              .clamp(_tourMinCameraPhi, _tourMaxCameraPhi)
                              .toDouble()
                          : math.max(
                              _tourDefaultCameraPhi,
                              block.modelOrbitPhi
                                  .clamp(_tourMinCameraPhi, _tourMaxCameraPhi)
                                  .toDouble(),
                            ))
                      : block.modelOrbitPhi,
                )
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void resetSelectedModelTourPosition() {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null ||
        (current!.modelTargetX == 0 &&
            current.modelTargetY == 0 &&
            current.modelTargetZ == 0)) {
      return;
    }
    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(
                  modelTargetX: 0,
                  modelTargetY: 0,
                  modelTargetZ: 0,
                )
              : block,
        )
        .toList(growable: false);
    _replaceSelectedPage(
      selectedPage.copyWith(componentBlocks: nextComponents),
    );
    notifyListeners();
  }

  void addSelectedModelTourHotspot({
    String label = 'Yeni tur noktası',
    ModelTourHotspotKind kind = ModelTourHotspotKind.point,
    String description = '',
    double x = 0,
    double y = 0,
    double z = 0,
    String? targetPageId,
  }) {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null) return;
    final hotspot = ModelTourHotspot(
      id: 'tour-hotspot-${DateTime.now().microsecondsSinceEpoch}',
      label: label.trim().isEmpty ? 'Yeni tur noktası' : label.trim(),
      kind: kind,
      description: description.trim(),
      x: x.clamp(-500.0, 500.0).toDouble(),
      y: y.clamp(-500.0, 500.0).toDouble(),
      z: z.clamp(-500.0, 500.0).toDouble(),
      targetPageId: targetPageId != selectedPage.id &&
              _pages.any((page) => page.id == targetPageId)
          ? targetPageId
          : null,
    );
    final components = selectedPage.componentBlocks.map((block) {
      return block.id == current!.id
          ? block.copyWith(
              modelTourEnabled: true,
              modelTourHotspots: <ModelTourHotspot>[
                ...block.modelTourHotspots,
                hotspot,
              ],
            )
          : block;
    }).toList(growable: false);
    _replaceSelectedPage(selectedPage.copyWith(componentBlocks: components));
    notifyListeners();
  }

  void updateSelectedModelTourHotspot(ModelTourHotspot updated) {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null) return;
    final components = selectedPage.componentBlocks.map((block) {
      if (block.id != current!.id) return block;
      return block.copyWith(
        modelTourHotspots: block.modelTourHotspots
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false),
      );
    }).toList(growable: false);
    _replaceSelectedPage(selectedPage.copyWith(componentBlocks: components));
    notifyListeners();
  }

  void removeSelectedModelTourHotspot(String hotspotId) {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null) return;
    final components = selectedPage.componentBlocks.map((block) {
      if (block.id != current!.id) return block;
      return block.copyWith(
        modelTourHotspots: block.modelTourHotspots
            .where((item) => item.id != hotspotId)
            .toList(growable: false),
      );
    }).toList(growable: false);
    _replaceSelectedPage(selectedPage.copyWith(componentBlocks: components));
    notifyListeners();
  }

  void beginSelectedModelOrbitGesture() {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null ||
        (!current!.modelOrbitEnabled &&
            (!current.modelTourEnabled || current.modelTourFrozen)) ||
        _modelOrbitGestureActive) {
      return;
    }
    _recordUndo();
    _modelOrbitGestureActive = true;
    _modelCameraGestureHasNotified = false;
    _modelCameraHasPendingUpdate = false;
    _modelCameraNotifyClock
      ..reset()
      ..start();
  }

  void endSelectedModelOrbitGesture() {
    if (!_modelOrbitGestureActive) return;
    final shouldNotify = _modelCameraHasPendingUpdate;
    _modelOrbitGestureActive = false;
    _modelCameraGestureHasNotified = false;
    _modelCameraHasPendingUpdate = false;
    _modelCameraNotifyClock
      ..stop()
      ..reset();
    // Tuş bırakmak yeni bir kamera durumu üretmez. Koşulsuz bildirim,
    // platform model-viewer'ını attribute'lardan yeniden kurup görünümü
    // başlangıç kamerasına sıçratabiliyordu. Sadece henüz boyanmamış son
    // hareket varsa onu gönder.
    if (shouldNotify) notifyListeners();
  }

  void _notifyModelCameraChanged() {
    _modelCameraHasPendingUpdate = true;
    if (!_modelOrbitGestureActive) {
      notifyListeners();
      _modelCameraHasPendingUpdate = false;
      return;
    }
    // Pointer olayları 100 Hz'i aşabilir. Tüm editörü her olayda yeniden
    // çizmek yerine model kamerasını ekran yenileme hızına yakın güncelle.
    if (_modelCameraGestureHasNotified &&
        _modelCameraNotifyClock.elapsedMicroseconds < 16000) {
      return;
    }
    _modelCameraGestureHasNotified = true;
    _modelCameraNotifyClock
      ..reset()
      ..start();
    notifyListeners();
    _modelCameraHasPendingUpdate = false;
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
    _notifyModelCameraChanged();
  }

  void lookAroundSelectedModelTour(Offset delta) {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null ||
        !current!.modelTourEnabled ||
        current.modelTourFrozen) {
      return;
    }

    final next = ModelTourRuntime.look(
      ModelTourPose(
        theta: current.modelOrbitTheta,
        phi: current.modelOrbitPhi,
        x: current.modelTargetX,
        y: current.modelTargetY,
        z: current.modelTargetZ,
      ),
      horizontalPixels: delta.dx,
      verticalPixels: delta.dy,
    );
    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(
                  modelOrbitTheta: next.theta,
                  modelOrbitPhi: next.phi,
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
    _notifyModelCameraChanged();
  }

  void moveSelectedModelTour({double forward = 0, double right = 0}) {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null ||
        !current!.modelTourEnabled ||
        current.modelTourFrozen) return;
    if (forward == 0 && right == 0) return;

    final zoomSensitivity = 1 / math.sqrt(current.modelZoom.clamp(0.5, 10.0));
    final next = ModelTourRuntime.move(
      ModelTourPose(
        theta: current.modelOrbitTheta,
        phi: current.modelOrbitPhi,
        x: current.modelTargetX,
        y: current.modelTargetY,
        z: current.modelTargetZ,
      ),
      forwardMeters: forward * zoomSensitivity,
      rightMeters: right * zoomSensitivity,
    );
    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(
                  modelTargetX: next.x
                      .clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres)
                      .toDouble(),
                  modelTargetZ: next.z
                      .clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres)
                      .toDouble(),
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
    _notifyModelCameraChanged();
  }

  /// Sanal turda oluşan son kamera pozunu ilgili slayttaki modele
  /// kaydeder. Böylece turdan çıkıldığında sunum sahnesi aynı görünümde kalır.
  void saveModelTourPose({
    required String pageId,
    required String blockId,
    required ModelTourPose pose,
    double? zoom,
    bool freeze = false,
  }) {
    final pageIndex = _pages.indexWhere((page) => page.id == pageId);
    if (pageIndex < 0) return;
    final page = _pages[pageIndex];
    final blockIndex = page.componentBlocks.indexWhere(
      (block) =>
          block.id == blockId &&
          block.modelAssetId != null &&
          block.modelTourEnabled,
    );
    if (blockIndex < 0) return;

    final current = page.componentBlocks[blockIndex];
    final theta = pose.theta % 360;
    final phi = pose.phi.clamp(_tourMinCameraPhi, _tourMaxCameraPhi).toDouble();
    final targetX =
        pose.x.clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres).toDouble();
    final targetY =
        pose.y.clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres).toDouble();
    final targetZ =
        pose.z.clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres).toDouble();
    final savedZoom = (zoom ?? current.modelZoom).clamp(0.5, 10.0).toDouble();
    if (current.modelOrbitTheta == theta &&
        current.modelOrbitPhi == phi &&
        current.modelTargetX == targetX &&
        current.modelTargetY == targetY &&
        current.modelTargetZ == targetZ &&
        current.modelZoom == savedZoom &&
        (!freeze || current.modelTourFrozen)) return;

    _recordUndo();
    final components =
        List<PresentationComponentBlock>.of(page.componentBlocks);
    components[blockIndex] = current.copyWith(
      modelOrbitTheta: theta,
      modelOrbitPhi: phi,
      modelTargetX: targetX,
      modelTargetY: targetY,
      modelTargetZ: targetZ,
      modelZoom: savedZoom,
      modelTourFrozen: freeze ? true : current.modelTourFrozen,
      modelAutoRotate: freeze ? false : current.modelAutoRotate,
      modelAnimationEnabled: freeze ? false : current.modelAnimationEnabled,
    );
    _pages[pageIndex] = page.copyWith(componentBlocks: components);
    notifyListeners();
  }

  /// Editör içindeki canlı sanal tur kamerasını normal sahne kamerası olarak
  /// sabitler. Kamera state'inin tek kaynağı PresentationComponentBlock'tur;
  /// bu nedenle burada sabitlenen değerler proje JSON'una da doğrudan girer.
  bool commitSelectedModelTourPose() {
    final current = selectedComponentBlock;
    if (current?.modelAssetId == null ||
        !current!.modelTourEnabled ||
        current.modelTourFrozen) {
      return false;
    }
    // Kapatma bir WASD/fare gesture'ının ortasında gelmişse son bekleyen
    // controller güncellemesini önce tamamla.
    endSelectedModelOrbitGesture();
    saveModelTourPose(
      pageId: selectedPage.id,
      blockId: current.id,
      pose: ModelTourPose(
        theta: current.modelOrbitTheta,
        phi: current.modelOrbitPhi,
        x: current.modelTargetX,
        y: current.modelTargetY,
        z: current.modelTargetZ,
      ),
      zoom: current.modelZoom,
      freeze: true,
    );
    return true;
  }

  /// Sunum başlamadan önce bütün sayfalardaki tur kameralarını kendi kayıtlı
  /// pozlarında sabitler. Her blok ayrı ayrı güncellendiği için aynı modelin
  /// farklı sayfalardaki hedef, açı ve zoom değerleri birbirine karışmaz.
  bool commitAllModelTourPoses() {
    endSelectedModelOrbitGesture();
    var changed = false;
    for (var pageIndex = 0; pageIndex < _pages.length; pageIndex++) {
      final page = _pages[pageIndex];
      var pageChanged = false;
      final components = page.componentBlocks.map((block) {
        if (block.modelAssetId == null ||
            !block.modelTourEnabled ||
            block.modelTourFrozen) {
          return block;
        }
        changed = true;
        pageChanged = true;
        return block.copyWith(
          modelTourFrozen: true,
          modelAutoRotate: false,
          modelAnimationEnabled: false,
        );
      }).toList(growable: false);
      if (pageChanged) {
        _pages[pageIndex] = page.copyWith(componentBlocks: components);
      }
    }
    if (changed) notifyListeners();
    return changed;
  }

  /// EditÃ¶rde ekranda duran model-viewer kameralarÄ±nÄ± proje state'ine alÄ±r.
  /// Component kimlikleri sunum genelinde benzersizdir; her slayt kendi blok
  /// kaydÄ±nÄ± aldÄ±ÄŸÄ± iÃ§in aynÄ± GLB'nin farklÄ± aÃ§Ä±larÄ± birbirini ezmez.
  bool syncRenderedModelCameraPoses(
    Map<String, ModelViewerCameraPose> posesByBlockId,
  ) {
    if (posesByBlockId.isEmpty) return false;
    var changed = false;
    for (var pageIndex = 0; pageIndex < _pages.length; pageIndex++) {
      final page = _pages[pageIndex];
      var pageChanged = false;
      final components = page.componentBlocks.map((block) {
        final pose = posesByBlockId[block.id];
        if (pose == null || block.modelAssetId == null) return block;
        final theta = pose.theta % 360;
        final phi = pose.phi
            .clamp(
              block.modelTourEnabled ? _tourMinCameraPhi : 10.0,
              block.modelTourEnabled ? _tourMaxCameraPhi : 170.0,
            )
            .toDouble();
        final radius = pose.radius.isFinite && pose.radius > 0
            ? pose.radius.clamp(0.001, 100000).toDouble()
            : block.modelCameraRadius;
        final targetX = block.modelTourEnabled
            ? pose.targetX
                .clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres)
                .toDouble()
            : block.modelTargetX;
        final targetY = block.modelTourEnabled
            ? pose.targetY
                .clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres)
                .toDouble()
            : block.modelTargetY;
        final targetZ = block.modelTourEnabled
            ? pose.targetZ
                .clamp(-_tourMaxTargetMetres, _tourMaxTargetMetres)
                .toDouble()
            : block.modelTargetZ;
        if (block.modelOrbitTheta == theta &&
            block.modelOrbitPhi == phi &&
            block.modelCameraRadius == radius &&
            block.modelTargetX == targetX &&
            block.modelTargetY == targetY &&
            block.modelTargetZ == targetZ) {
          return block;
        }
        changed = true;
        pageChanged = true;
        return block.copyWith(
          modelOrbitTheta: theta,
          modelOrbitPhi: phi,
          modelCameraRadius: radius,
          modelTargetX: targetX,
          modelTargetY: targetY,
          modelTargetZ: targetZ,
        );
      }).toList(growable: false);
      if (pageChanged) {
        _pages[pageIndex] = page.copyWith(componentBlocks: components);
      }
    }
    if (changed) notifyListeners();
    return changed;
  }

  void updateSelectedBackground(PresentationBackgroundKind value) {
    if (selectedPage.backgroundKind == value) {
      return;
    }
    _replaceSelectedPage(
      selectedPage.copyWith(
        backgroundKind: value,
        backgroundColorsInverted: false,
      ),
    );
    notifyListeners();
  }

  void updateSelectedBackgroundAnimationEnabled(bool value) {
    if (selectedPage.backgroundAnimationEnabled == value) {
      return;
    }
    _replaceSelectedPage(
      selectedPage.copyWith(backgroundAnimationEnabled: value),
    );
    notifyListeners();
  }

  void updateSelectedBackgroundAnimationSpeed(double value) {
    final nextValue = value.clamp(0.25, 2.0).toDouble();
    if ((selectedPage.backgroundAnimationSpeed - nextValue).abs() < 0.001) {
      return;
    }
    _replaceSelectedPage(
      selectedPage.copyWith(backgroundAnimationSpeed: nextValue),
    );
    notifyListeners();
  }

  void updateSelectedBackgroundColorsInverted(bool value) {
    if (selectedPage.backgroundColorsInverted == value) {
      return;
    }
    _replaceSelectedPage(
      selectedPage.copyWith(backgroundColorsInverted: value),
    );
    notifyListeners();
  }

  void updateAllPageBackgrounds(PresentationBackgroundKind value) {
    if (_pages.every((page) => page.backgroundKind == value)) {
      return;
    }
    _recordUndo();
    final updatedPages = _pages
        .map(
          (page) => page.copyWith(
            backgroundKind: value,
            backgroundColorsInverted: false,
          ),
        )
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
        backgroundColorsInverted: config.backgroundKind == null
            ? page.backgroundColorsInverted
            : false,
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

      return updatedPage;
    }).toList(growable: false);

    _pages
      ..clear()
      ..addAll(updatedPages);
    notifyListeners();
  }

  void applySutolTemplate(SutolTemplateModel template) {
    _recordUndo();
    final headingStyle =
        presentationFontFamilyStyle(template.fontPair['heading'] ?? '');
    final bodyStyle =
        presentationFontFamilyStyle(template.fontPair['body'] ?? '');

    final primaryColor =
        template.colorPalette.isNotEmpty ? template.colorPalette[0] : null;
    final accentColor = template.colorPalette.length > 1
        ? template.colorPalette[1]
        : primaryColor;

    final backgroundKind = switch (template.category.toLowerCase()) {
      'kurumsal' => template.id.contains('koyu')
          ? PresentationBackgroundKind.businessFinance
          : PresentationBackgroundKind.lightCorporate,
      'yaratıcı' => template.id.contains('neon')
          ? PresentationBackgroundKind.technology
          : PresentationBackgroundKind.lightCreative,
      'minimal' => PresentationBackgroundKind.lightCorporate,
      'eğitim' => PresentationBackgroundKind.lightEducation,
      'pazarlama' => PresentationBackgroundKind.businessFinance,
      _ => PresentationBackgroundKind.science,
    };

    final updatedPages = _pages.map((page) {
      final updatedTextBlocks = page.textBlocks.map((block) {
        if (block.type == PresentationTextType.title) {
          return block.copyWith(
            textStyle: headingStyle,
            textColorHex: primaryColor,
          );
        } else if (block.type == PresentationTextType.subtitle) {
          return block.copyWith(
            textStyle: headingStyle,
            textColorHex: accentColor,
          );
        } else {
          return block.copyWith(
            textStyle: bodyStyle,
          );
        }
      }).toList(growable: false);

      return page.copyWith(
        templateId: template.id,
        backgroundKind: backgroundKind,
        textBlocks: updatedTextBlocks,
      );
    }).toList(growable: false);

    _pages
      ..clear()
      ..addAll(updatedPages);
    notifyListeners();
  }

  void applyFontPairToDeck(
      PresentationTextStyle headingStyle, PresentationTextStyle bodyStyle) {
    _recordUndo();
    final updatedPages = _pages.map((page) {
      final updatedTextBlocks = page.textBlocks.map((block) {
        if (block.type == PresentationTextType.title) {
          return block.copyWith(textStyle: headingStyle);
        } else {
          return block.copyWith(textStyle: bodyStyle);
        }
      }).toList(growable: false);
      return page.copyWith(textBlocks: updatedTextBlocks);
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
      if (value != PresentationTransitionKind.none && _pages.length > 1) {
        _transitionPreviewGapIndex =
            _selectedPageIndex.clamp(0, _pages.length - 2);
        _transitionPreviewRevision += 1;
        notifyListeners();
      }
      return;
    }
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(transitionKind: value);
    if (value != PresentationTransitionKind.none && _pages.length > 1) {
      _transitionPreviewGapIndex =
          _selectedPageIndex.clamp(0, _pages.length - 2);
      _transitionPreviewRevision += 1;
    }
    notifyListeners();
  }

  void applyTransitionToAllPages(PresentationTransitionKind value) {
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(transitionKind: value);
    for (var i = 0; i < _pages.length; i++) {
      _pages[i] = _pages[i].copyWith(transitionAfter: value);
    }
    if (value != PresentationTransitionKind.none && _pages.length > 1) {
      _transitionPreviewGapIndex =
          _selectedPageIndex.clamp(0, _pages.length - 2);
      _transitionPreviewRevision += 1;
    }
    notifyListeners();
  }

  void updateTransitionAfterPage(
    int pageIndex,
    PresentationTransitionKind value,
  ) {
    if (pageIndex < 0 || pageIndex >= _pages.length - 1) return;
    final page = _pages[pageIndex];
    if (page.transitionAfter == value) {
      if (value != PresentationTransitionKind.none) {
        _transitionPreviewGapIndex = pageIndex;
        _transitionPreviewRevision += 1;
        notifyListeners();
      }
      return;
    }
    _recordUndo();
    _pages[pageIndex] = page.copyWith(transitionAfter: value);
    if (value != PresentationTransitionKind.none) {
      _transitionPreviewGapIndex = pageIndex;
      _transitionPreviewRevision += 1;
    }
    notifyListeners();
  }

  PresentationTransitionKind transitionAfterPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= _pages.length - 1) {
      return PresentationTransitionKind.none;
    }
    return _pages[pageIndex].transitionAfter ?? _effectSettings.transitionKind;
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

  void updateAutoPlayIntervalSec(int value) {
    if (_effectSettings.autoPlayIntervalSec == value) return;
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(autoPlayIntervalSec: value);
    notifyListeners();
  }

  void updateLoop(bool value) {
    if (_effectSettings.loop == value) return;
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(loop: value);
    notifyListeners();
  }

  void updateShowProgressBar(bool value) {
    if (_effectSettings.showProgressBar == value) return;
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(showProgressBar: value);
    notifyListeners();
  }

  void updateEnableLaserPointer(bool value) {
    if (_effectSettings.enableLaserPointer == value) return;
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(enableLaserPointer: value);
    notifyListeners();
  }

  void updateEnableSoundEffects(bool value) {
    if (_effectSettings.enableSoundEffects == value) return;
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(enableSoundEffects: value);
    notifyListeners();
  }

  void updateAspectRatio(String value) {
    if (_effectSettings.aspectRatio == value) return;
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(aspectRatio: value);
    notifyListeners();
  }

  void updateStageDimensions({
    required String aspectRatio,
    double? customWidth,
    double? customHeight,
  }) {
    final newWidth = customWidth ?? _effectSettings.customWidth;
    final newHeight = customHeight ?? _effectSettings.customHeight;
    if (_effectSettings.aspectRatio == aspectRatio &&
        _effectSettings.customWidth == newWidth &&
        _effectSettings.customHeight == newHeight) {
      return;
    }
    _recordUndo();
    _effectSettings = _effectSettings.copyWith(
      aspectRatio: aspectRatio,
      customWidth: newWidth,
      customHeight: newHeight,
    );
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
    final sourcePage = selectedPage;
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
        backgroundKind: sourcePage.backgroundKind,
        backgroundAnimationEnabled: sourcePage.backgroundAnimationEnabled,
        backgroundAnimationSpeed: sourcePage.backgroundAnimationSpeed,
        backgroundColorsInverted: sourcePage.backgroundColorsInverted,
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

  void addPageAfter(int index) {
    if (index < 0 || index >= _pages.length) {
      addPage();
      return;
    }
    _recordUndo();
    final sourcePage = _pages[index];
    final textBlock = _createTextBlock(
      text: '',
      position: const Offset(0.12, 0.16),
      fontSize: 48,
      type: PresentationTextType.title,
      widthFactor: 0.34,
    );
    final newPage = PresentationPage(
      id: 'page-$_pageCounter',
      textBlocks: <PresentationTextBlock>[textBlock],
      backgroundKind: sourcePage.backgroundKind,
      backgroundAnimationEnabled: sourcePage.backgroundAnimationEnabled,
      backgroundAnimationSpeed: sourcePage.backgroundAnimationSpeed,
      backgroundColorsInverted: sourcePage.backgroundColorsInverted,
    );
    _pageCounter += 1;
    final insertIndex = index + 1;
    _pages.insert(insertIndex, newPage);
    _selectedPageIndex = insertIndex;
    _setSingleSelection(textBlockId: textBlock.id);
    notifyListeners();
  }

  void duplicatePage(int index) {
    if (index < 0 || index >= _pages.length) {
      return;
    }
    _recordUndo();
    final source = _pages[index];
    final duplicatedTextBlocks = source.textBlocks.map((tb) {
      return tb.copyWith(id: 'text-${_textBlockCounter++}');
    }).toList(growable: false);
    final duplicatedComponentBlocks = source.componentBlocks.map((cb) {
      return cb.copyWith(id: 'component-${_componentBlockCounter++}');
    }).toList(growable: false);
    final newPage = PresentationPage(
      id: 'page-$_pageCounter',
      textBlocks: duplicatedTextBlocks,
      componentBlocks: duplicatedComponentBlocks,
      backgroundKind: source.backgroundKind,
      backgroundAnimationEnabled: source.backgroundAnimationEnabled,
      backgroundAnimationSpeed: source.backgroundAnimationSpeed,
      backgroundColorsInverted: source.backgroundColorsInverted,
      speakerNotes: source.speakerNotes,
    );
    _pageCounter += 1;
    final insertIndex = index + 1;
    _pages.insert(insertIndex, newPage);
    _selectedPageIndex = insertIndex;
    _resetSelectionForCurrentPage();
    notifyListeners();
  }

  void movePageUp(int index) {
    if (index <= 0 || index >= _pages.length) {
      return;
    }
    _recordUndo();
    final page = _pages.removeAt(index);
    _pages.insert(index - 1, page);
    _selectedPageIndex = index - 1;
    _resetSelectionForCurrentPage();
    notifyListeners();
  }

  void movePageDown(int index) {
    if (index < 0 || index >= _pages.length - 1) {
      return;
    }
    _recordUndo();
    final page = _pages.removeAt(index);
    _pages.insert(index + 1, page);
    _selectedPageIndex = index + 1;
    _resetSelectionForCurrentPage();
    notifyListeners();
  }

  void reorderPage(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _pages.length ||
        newIndex < 0 ||
        newIndex > _pages.length ||
        oldIndex == newIndex) {
      return;
    }
    _recordUndo();
    final page = _pages.removeAt(oldIndex);
    final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    _pages.insert(insertIndex, page);
    _selectedPageIndex = insertIndex;
    _resetSelectionForCurrentPage();
    notifyListeners();
  }

  void removePageAt(int index) {
    if (!canRemovePage || index < 0 || index >= _pages.length) {
      return;
    }
    _recordUndo();
    final removedPageId = _pages[index].id;
    _pages.removeAt(index);
    _clearHotspotsTargeting(removedPageId);
    _selectedPageIndex = math.min(index, _pages.length - 1);
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
      modelAnimationEnabled: true,
      modelAutoRotate: true,
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

  void addUploadedImageBlock(
    String imageAssetId, {
    double aspectRatio = 16 / 9,
  }) {
    final page = selectedPage;
    final blockCount = page.componentBlocks.length;
    const stageAspectRatio = 16 / 9;
    final safeAspectRatio = aspectRatio.clamp(0.3, 4.0).toDouble();
    var heightFactor = 0.52;
    var widthFactor = heightFactor * safeAspectRatio / stageAspectRatio;
    if (widthFactor > 0.54) {
      widthFactor = 0.54;
      heightFactor = widthFactor * stageAspectRatio / safeAspectRatio;
    }
    if (heightFactor > 0.62) {
      heightFactor = 0.62;
      widthFactor = heightFactor * safeAspectRatio / stageAspectRatio;
    }
    final cascadeOffset = (blockCount % 3) * 0.025;
    final nextX = (0.5 - widthFactor / 2 + cascadeOffset)
        .clamp(0.04, 0.96 - widthFactor)
        .toDouble();
    final nextY = (0.5 - heightFactor / 2 + cascadeOffset)
        .clamp(0.05, 0.95 - heightFactor)
        .toDouble();
    final componentBlock = PresentationComponentBlock(
      id: 'component-$_componentBlockCounter',
      imageAssetId: imageAssetId,
      imageAspectRatio: safeAspectRatio,
      position: Offset(nextX, nextY),
      size: Size(widthFactor, heightFactor),
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
        block.position.dx + 0.03,
        block.position.dy + 0.04,
      );
      return block.copyWith(
        id: 'text-${_textBlockCounter++}',
        position: nextPosition,
      );
    }).toList(growable: false);
    final insertedComponentBlocks = componentBlocks.map((block) {
      final nextPosition = Offset(
        block.position.dx + 0.03,
        block.position.dy + 0.04,
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
    _beginSelectionTransform();
    _moveSelection(delta, canvasSize);
  }

  void _beginSelectionTransform() {
    _selectionTransformIdleTimer?.cancel();
    if (!_selectionTransformActive) {
      _recordUndo();
      _selectionTransformActive = true;
    }
    _selectionTransformIdleTimer = Timer(const Duration(milliseconds: 180), () {
      _selectionTransformActive = false;
    });
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

    final deltaX = delta.dx / canvasSize.width;
    final deltaY = delta.dy / canvasSize.height;

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
    final nextPage = selectedPage.copyWith(
      textBlocks: nextBlocks,
      componentBlocks: nextComponents,
    );
    if (_selectionTransformActive) {
      _pages[_selectedPageIndex] = nextPage;
    } else {
      _replaceSelectedPage(nextPage);
    }
    notifyListeners();
  }

  void resizeSelectedTextByHandle(
    Offset delta,
    Size canvasSize, {
    required double renderedHeightFactor,
    required bool fromLeft,
    required bool fromTop,
    required bool fromRight,
    required bool fromBottom,
  }) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return;
    }

    final current = selectedTextBlock;
    if (current == null) {
      return;
    }
    _beginSelectionTransform();

    final deltaX = delta.dx / canvasSize.width;
    final deltaY = delta.dy / canvasSize.height;
    var left = current.position.dx;
    var top = current.position.dy;
    var right = left + current.widthFactor;
    final currentHeight = current.heightFactor ?? renderedHeightFactor;
    var bottom = top + currentHeight;

    if (fromLeft) left += deltaX;
    if (fromRight) right += deltaX;
    if (fromTop) top += deltaY;
    if (fromBottom) bottom += deltaY;

    const minHeight = 0.06;

    if (fromLeft) {
      left = math.min(left, right - _minTextWidthFactor);
    }
    if (fromRight) {
      right = math.max(right, left + _minTextWidthFactor);
    }
    if (fromTop) {
      top = math.min(top, bottom - minHeight);
    }
    if (fromBottom) {
      bottom = math.max(bottom, top + minHeight);
    }

    final nextHeight = bottom - top;
    final resizeVertically = fromTop || fromBottom;
    final nextFontSize = resizeVertically && currentHeight > 0
        ? (current.fontSize * (nextHeight / currentHeight))
            .clamp(minTextFontSize, maxTextFontSize)
            .toDouble()
        : current.fontSize;

    _replaceSelectedTextBlockWithoutHistory(
      current.copyWith(
        position: Offset(left, top),
        widthFactor: right - left,
        heightFactor: resizeVertically ? nextHeight : current.heightFactor,
        fontSize: nextFontSize,
      ),
    );
    notifyListeners();
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
    final nextPosition = current.position;
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
    _beginSelectionTransform();

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

    if (fromLeft) {
      left = left
          .clamp(
            right - _maxComponentWidthFactor,
            right - _minComponentWidthFactor,
          )
          .toDouble();
    }
    if (fromRight) {
      right = right
          .clamp(
            left + _minComponentWidthFactor,
            left + _maxComponentWidthFactor,
          )
          .toDouble();
    }
    if (fromTop) {
      top = top
          .clamp(
            bottom - _maxComponentHeightFactor,
            bottom - _minComponentHeightFactor,
          )
          .toDouble();
    }
    if (fromBottom) {
      bottom = bottom
          .clamp(
            top + _minComponentHeightFactor,
            top + _maxComponentHeightFactor,
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
    final nextPosition = Offset(left, top);

    final nextComponents = selectedPage.componentBlocks
        .map(
          (block) => block.id == current.id
              ? block.copyWith(position: nextPosition, size: nextSize)
              : block,
        )
        .toList(growable: false);

    _pages[_selectedPageIndex] =
        selectedPage.copyWith(componentBlocks: nextComponents);
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

  void _replaceSelectedTextBlockWithoutHistory(
      PresentationTextBlock nextBlock) {
    final current = selectedTextBlock;
    if (current == null) return;
    _pages[_selectedPageIndex] = selectedPage.copyWith(
      textBlocks: selectedPage.textBlocks
          .map((block) => block.id == current.id ? nextBlock : block)
          .toList(growable: false),
    );
  }

  @override
  void dispose() {
    _selectionTransformIdleTimer?.cancel();
    super.dispose();
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
        final clearsComponentTarget =
            block.hotspotTargetPageId == removedPageId;
        final clearsTourTarget = block.modelTourHotspots.any(
          (hotspot) => hotspot.targetPageId == removedPageId,
        );
        if (!clearsComponentTarget && !clearsTourTarget) {
          return block;
        }
        changed = true;
        return block.copyWith(
          hotspotTargetPageId:
              clearsComponentTarget ? null : block.hotspotTargetPageId,
          modelTourHotspots: block.modelTourHotspots
              .map(
                (hotspot) => hotspot.targetPageId == removedPageId
                    ? hotspot.copyWith(targetPageId: null)
                    : hotspot,
              )
              .toList(growable: false),
        );
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
    return value.clamp(_minTextWidthFactor, 10).toDouble();
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
