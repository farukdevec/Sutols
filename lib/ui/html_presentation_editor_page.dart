import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/slide_model.dart';
import '../services/firestore_rest_helper.dart';
import '../services/local_image_picker.dart';
import '../services/model_asset_service.dart';
import '../services/model_repository.dart';

import '../services/presentation_export_service.dart';
import '../services/presentation_auto_builder.dart';
import '../services/presentation_fullscreen_service.dart';
import '../services/presentation_loader.dart';
import '../services/presentation_model_source_resolver.dart';
import '../services/presentation_project_codec.dart';
import '../services/presentation_project_io.dart';
import '../services/presentation_project_store.dart';
import '../services/presentation_tracking_service.dart';
import '../services/remote_image_sources.dart';
import '../services/remote_model_sources.dart';
import '../state/presentation_controller.dart';
import '../state/theme_controller.dart';
import '../state/language_controller.dart';
import 'membership_page.dart';
import 'widgets/signed_thumbnail_image.dart';

import 'my_presentations_page.dart';
import 'presentation_preview_page.dart';
import 'widgets/editor_shell.dart';
import 'widgets/html_stage/html_page_stage.dart';
import 'widgets/selection_mini_toolbar.dart';

import 'design/design_system.dart';
import 'design/sutol_widgets.dart';

extension on BuildContext {
  Color get _htmlInk => sutolColors.onSurface;
  Color get _htmlMuted => sutolColors.onSurfaceVariant;
  Color get _htmlAccent => sutolColors.primary;
  Color get _htmlPanel => sutolColors.surface;
}

bool _isUploadedImageBlock(PresentationComponentBlock block) {
  return block.imageAssetId != null ||
      (block.modelAssetId != null &&
          RemoteImageSources.sourceFor(block.modelAssetId!) != null);
}

const Color _studioHeaderBrandStart = Color(0xFF0A7E82);
const Color _studioHeaderBrandEnd = Color(0xFF006471);
const Color _studioHeaderForeground = Color(0xFFF7FFFF);
const Color _studioHeaderMuted = Color(0xCFFFFFFF);
const Color _studioHeaderControl = Color(0x24FFFFFF);
const Color _studioHeaderBorder = Color(0x42FFFFFF);
const List<BoxShadow> _studioHeaderFadeShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x300A7E82),
    blurRadius: 16,
    spreadRadius: -2,
    offset: Offset(0, 7),
  ),
  BoxShadow(
    color: Color(0x160A7E82),
    blurRadius: 30,
    spreadRadius: -5,
    offset: Offset(0, 15),
  ),
];

enum _HtmlToolTab {
  templates,
  backgrounds,
  components,
  text,
  models3d,
  photo,
  transitions,
  stageDimensions,
}

class HtmlPresentationEditorPage extends StatefulWidget {
  const HtmlPresentationEditorPage({
    super.key,
    required this.controller,
    this.presentationId,
    this.initialUpdatedByName,
    this.adminReadOnly = false,
  });

  final PresentationController controller;

  /// Bağlı Firestore sunum ID'si (varsa kayıt buluta yazılır).
  final String? presentationId;

  /// Açılışta gösterilecek "son düzenleyen" adı.
  final String? initialUpdatedByName;

  /// `true` ise sayfa salt okunur "Görüntüleme Modu"nda açılır:
  /// sunum [presentationId] ile Firestore'dan yüklenir (yükleme tamamlanana
  /// kadar sayfa yükleme ekranı gösterir), tüm düzenleme araçları gizlenir ve
  /// tuval etkileşimsizdir. Dışa aktarma (HTML/PDF) ve sunum modu kullanılabilir.
  final bool adminReadOnly;

  @override
  State<HtmlPresentationEditorPage> createState() =>
      _HtmlPresentationEditorPageState();
}

class _HtmlPresentationEditorPageState
    extends State<HtmlPresentationEditorPage> {
  final FocusNode _editorFocusNode = FocusNode();
  late final TextEditingController _textController;
  _HtmlToolTab _activeTab = _HtmlToolTab.text;
  String? _lastEditorLabel;

  PresentationTrackingService? _trackingInstance;

  /// Sunum kaydı servisi yalnızca gerektiğinde oluşturulur; böylece editörün
  /// açılışı Firebase/Firestore başlangıcına bağlı kalmaz.
  PresentationTrackingService get _tracking =>
      _trackingInstance ??= PresentationTrackingService();

  /// Editörün açıldığı an (sayfada geçirilen süreyi ölçmek için).
  DateTime _openedAt = DateTime.now();

  /// Son izlenen deck içerik imzası: gerçek düzenlemeleri seçim
  /// değişikliklerinden ayırt etmek için kullanılır.
  String _trackedSignature = '';

  /// Studio (geniş) düzende detay paneli açık mı? (Canva tarzı aç/kapat.)
  bool _inspectorOpen = true;

  /// Geniş studio düzeni aktif mi? (Toggle davranışı için build sırasında güncellenir.)
  bool _studioWide = false;

  /// Mobil tuval: kıstırma ile yakınlaştırma (1..3) ve yakınlaştırınca kaydırma.
  double _mobileCanvasZoom = 1.0;
  Offset _mobileCanvasPan = Offset.zero;
  double _mobileZoomStartScale = 1.0;
  String? _lastMobilePageId;

  /// Çoklu dokunma sırasında tuval içi jestler kapatılır (kıstırma sahne
  /// katmanına geçer); parmaklar kalkınca tekrar açılır.
  bool _multiTouchActive = false;

  /// Mobil tuvaldeki "boş alanda sürükle" ipucu: ilk açılışta kısa süre
  /// görünür, etkileşimle ya da süre dolunca kaybolur.
  bool _showMobileHint = true;
  Timer? _hintTimer;

  /// Salt okunur (admin) mod: Firestore'dan yükleme durumu.
  bool _adminLoading = false;
  String? _adminLoadError;

  /// İndirilecek sunumun konu / dosya adı (kullanıcı düzenleyebilir).
  String _presentationFileName = 'Sutols Sunumu';

  /// Sunum sayfalarındaki ilk metin bloğundan konu / dosya adını çözer.
  void _resolvePresentationFileName() {
    for (final page in widget.controller.pages) {
      for (final block in page.textBlocks) {
        final value = block.text.trim();
        if (value.isNotEmpty) {
          final name = value.length > 64 ? value.substring(0, 64) : value;
          if (name != _presentationFileName) {
            setState(() => _presentationFileName = name);
          }
          return;
        }
      }
    }
  }

  void _onMobileScaleStart(ScaleStartDetails details) {
    _mobileZoomStartScale = _mobileCanvasZoom;
    _dismissMobileHint();
  }

  void _onMobileScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _mobileCanvasZoom =
          (_mobileZoomStartScale * details.scale).clamp(1.0, 3.0);
      _mobileCanvasPan += details.focalPointDelta / _mobileCanvasZoom;
    });
  }

  void _dismissMobileHint() {
    _hintTimer?.cancel();
    if (_showMobileHint) {
      setState(() => _showMobileHint = false);
    }
  }

  void _onMobileScaleEnd(ScaleEndDetails details) {
    _hintTimer?.cancel();
  }

  void _onMobileMultiTouchChanged(bool multi) {
    if (_multiTouchActive == multi) {
      return;
    }
    setState(() => _multiTouchActive = multi);
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
    _openedAt = DateTime.now();
    _trackedSignature = _deckSignature();
    widget.controller.addListener(_syncTextField);
    widget.controller.addListener(_syncTabWithSelection);
    widget.controller.addListener(_onMobilePageChanged);
    widget.controller.addListener(_trackEdits);
    _lastMobilePageId = widget.controller.selectedPage.id;
    _textController = TextEditingController(
      text: widget.controller.selectedTextBlock?.text ?? '',
    );
    final initial = widget.initialUpdatedByName;
    if (initial != null && initial.trim().isNotEmpty) {
      _lastEditorLabel = initial.trim();
    }
    _hintTimer = Timer(const Duration(seconds: 6), _dismissMobileHint);
    _resolvePresentationFileName();
    _hydrateModels();
    if (widget.adminReadOnly) {
      _adminLoading = true;
      _loadAdminPresentation();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editorFocusNode.requestFocus();
        final isMobile = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;
        if (isMobile) {
          final currentRatio = widget.controller.effectSettings.aspectRatio;
          if (currentRatio.isEmpty) {
            widget.controller.updateStageDimensions(aspectRatio: '16:9');
          }
        }
      }
    });
  }

  Future<void> _hydrateModels() async {
    await hydratePresentationModelSources(widget.controller.pages);
    if (mounted) {
      setState(() {});
    }
  }


  /// Salt okunur (admin) mod: sunumu verilen presentationId ile Firestore'dan
  /// mevcut yükleme mantığını kullanarak mevcut controller'a yükler.
  Future<void> _loadAdminPresentation() async {
    final presentationId = widget.presentationId;
    if (presentationId == null) {
      setState(() {
        _adminLoading = false;
        _adminLoadError = 'Sunum kimliği (presentationId) belirtilmedi.';
      });
      return;
    }
    try {
      final result = await loadPresentationForEdit(
        presentationId,
        controller: widget.controller,
      );
      if (!mounted) return;
      setState(() {
        _adminLoading = false;
        _adminLoadError = null;
        if (result.updatedByName != null &&
            result.updatedByName!.trim().isNotEmpty) {
          _lastEditorLabel = result.updatedByName!.trim();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _adminLoading = false;
        _adminLoadError = 'Sunum yüklenemedi: $e';
      });
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    _editorFocusNode.dispose();
    _hintTimer?.cancel();
    widget.controller.removeListener(_syncTextField);
    widget.controller.removeListener(_syncTabWithSelection);
    widget.controller.removeListener(_onMobilePageChanged);
    widget.controller.removeListener(_trackEdits);
    _textController.dispose();
    final presentationId = widget.presentationId;
    if (presentationId != null && !widget.adminReadOnly) {
      final seconds = DateTime.now().difference(_openedAt).inSeconds;
      if (seconds > 0) {
        _tracking.addTimeSpent(presentationId, seconds);
      }
    }
    super.dispose();
  }

  /// Deck içeriğinin imzasını üretir: gerçek düzenlemeler (metin, stil,
  /// model, yerleşim, arka plan, geçiş vb.) imzayı değiştirir, seçim gibi
  /// salt görünüm olayları değiştirmez.
  String _deckSignature() {
    final controller = widget.controller;
    final buf = StringBuffer();
    buf.write(controller.pages.length);
    final settings = controller.effectSettings;
    buf
      ..write(
          '|${settings.transitionKind.index}|${settings.transitionDurationMs}')
      ..write(
          '|${settings.zoomEnabled}|${settings.zoomScale.toStringAsFixed(3)}')
      ..write('|${settings.reducedMotion}');
    for (final page in controller.pages) {
      buf
        ..write(
            '\n${page.id}|${page.backgroundKind.index}|${page.speakerNotes}');
      for (final text in page.textBlocks) {
        buf
          ..write(
              '\nT:${text.id}|${text.text}|${text.position.dx.toStringAsFixed(3)}')
          ..write('|${text.position.dy.toStringAsFixed(3)}|${text.fontSize}')
          ..write(
              '|${text.type.index}|${text.widthFactor}|${text.heightFactor}|${text.textStyle.index}')
          ..write('|${text.textAnimation.index}|${text.textColorHex}')
          ..write('|${text.glowIntensity}|${text.revealStep}')
          ..write('|${text.hotspotTargetPageId}|${text.textBold}')
          ..write(
              '|${text.textItalic}|${text.textUnderline}|${text.textAlign.index}');
      }
      for (final block in page.componentBlocks) {
        buf
          ..write(
              '\nC:${block.id}|${block.kind.index}|${block.modelAssetId}|${block.imageAssetId}|${block.imageAspectRatio}')
          ..write('|${block.modelAnimationEnabled}|${block.modelAutoRotate}')
          ..write('|${block.modelOrbitEnabled}'
              '|${block.modelOrbitTheta.toStringAsFixed(3)}|${block.modelOrbitPhi.toStringAsFixed(3)}')
          ..write(
              '|${block.position.dx.toStringAsFixed(3)}|${block.position.dy.toStringAsFixed(3)}')
          ..write(
              '|${block.size.width.toStringAsFixed(3)}|${block.size.height.toStringAsFixed(3)}')
          ..write('|${block.revealStep}|${block.hotspotTargetPageId}');
      }
    }
    return buf.toString();
  }

  /// Kullanıcı sunumu gerçekten düzenlediğinde Firebase'e işler
  /// (wasEdited: true, editCount: +1). presentationId yoksa (yerel proje)
  /// hiçbir şey yapmaz.
  void _trackEdits() {
    if (widget.adminReadOnly) {
      return;
    }
    final presentationId = widget.presentationId;
    if (presentationId == null) {
      return;
    }
    final signature = _deckSignature();
    if (signature == _trackedSignature) {
      return;
    }
    _trackedSignature = signature;
    _tracking.markEdited(presentationId);
  }

  /// Slayt değişince mobil tuvali yeniden sığdırma görünümüne döndürür.
  void _onMobilePageChanged() {
    final controller = widget.controller;
    final pageId = controller.selectedPage.id;
    if (pageId == _lastMobilePageId) {
      return;
    }
    _lastMobilePageId = pageId;
    if (_mobileCanvasZoom != 1.0 || _mobileCanvasPan != Offset.zero) {
      setState(() {
        _mobileCanvasZoom = 1.0;
        _mobileCanvasPan = Offset.zero;
      });
    }
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

  /// Tekli seçim değiştiğinde sol paneli seçili öğenin türüne göre
  /// ilgili sekmeye otomatik geçirir (Canva tarzı bağlamsal panel).
  String? _lastAutoTabSelectionKey;

  void _syncTabWithSelection() {
    final controller = widget.controller;
    String? selectionKey;
    _HtmlToolTab? targetTab;
    final textBlock = controller.selectedTextBlock;
    final componentBlock = controller.selectedComponentBlock;
    if (textBlock != null) {
      selectionKey = 'text:${textBlock.id}';
      targetTab = _HtmlToolTab.text;
    } else if (componentBlock != null) {
      selectionKey = 'component:${componentBlock.id}';
      targetTab = _isUploadedImageBlock(componentBlock)
          ? _HtmlToolTab.photo
          : componentBlock.modelAssetId != null
              ? _HtmlToolTab.models3d
              : _HtmlToolTab.components;
    }
    if (selectionKey == null) {
      _lastAutoTabSelectionKey = null;
      return;
    }
    if (selectionKey == _lastAutoTabSelectionKey) {
      return;
    }
    _lastAutoTabSelectionKey = selectionKey;
    if (targetTab != _activeTab || !_inspectorOpen) {
      setState(() {
        _activeTab = targetTab!;
        _inspectorOpen = true;
      });
    }
  }

  void _setTab(_HtmlToolTab tab) {
    if (tab == _activeTab) {
      // Aynı ikona tekrar tıklandı: studio modunda panel açılır/kapanır.
      if (_studioWide) {
        setState(() => _inspectorOpen = !_inspectorOpen);
      }
      return;
    }
    setState(() {
      _activeTab = tab;
      _inspectorOpen = true;
    });
  }

  /// Mobil/tablet: alt araç iskelesinden seçilen aracın panelini alttan
  /// açılan sheet içinde gösterir. Tuval arka planda korunur.
  void _openMobileToolSheet(_HtmlToolTab tab) {
    setState(() => _activeTab = tab);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (sheetContext) => _HtmlMobileToolSheet(
        controller: widget.controller,
        textController: _textController,
        tab: tab,
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Dock'taki "Fotoğraf" kısayolu: cihazdan seçim ya da daha önce yüklenen
  /// fotoğraf kütüphanesi (Medya paneli) arasında hızlı aksiyon sunar.
  Future<void> _openMobilePhotoActions() async {
    final action = await showModalBottomSheet<_MobilePhotoQuickAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (sheetContext) => _MobilePhotoQuickSheet(
        onPicked: () =>
            Navigator.of(sheetContext).pop(_MobilePhotoQuickAction.pick),
        onLibrary: () =>
            Navigator.of(sheetContext).pop(_MobilePhotoQuickAction.library),
      ),
    );
    switch (action) {
      case _MobilePhotoQuickAction.pick:
        await _pickPhotoFromDevice();
      case _MobilePhotoQuickAction.library:
        _openMobileToolSheet(_HtmlToolTab.photo);
      case null:
        break;
    }
  }

  /// Cihazdan bir fotoğraf seçip slayta ekler.
  Future<void> _pickPhotoFromDevice() async {
    try {
      final entry = await pickLocalPhotoIntoController(widget.controller);
      if (entry != null) {
        _showSnack('Fotoğraf slayta eklendi.');
      }
    } catch (e) {
      _showSnack('Fotoğraf yüklenemedi: $e');
    }
  }

  /// Konu / sunum adını kullanıcıdan alıp günceller.
  Future<void> _editPresentationFileName() async {
    final controller = TextEditingController(text: _presentationFileName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sunum Konusu'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Konu / Sunum Adı',
            hintText: 'Örn: Tarih ve Arkeoloji',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              controller.text.trim(),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _presentationFileName = result);
    }
  }

  Future<void> _exportPresentation() async {
    _resolvePresentationFileName();
    final presentationId = widget.presentationId;
    if (presentationId != null && !widget.adminReadOnly) {
      _tracking.markExported(presentationId);
    }
    final cleanName = _presentationFileName.trim().isEmpty
        ? 'Sutols Sunumu'
        : _presentationFileName.trim();
    final fileName = '$cleanName.html';
    await exportPresentationAsHtml(
      pages: widget.controller.pages.toList(growable: false),
      effectSettings: widget.controller.effectSettings,
      fileName: fileName,
      title: _presentationFileName,
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
    if (widget.adminReadOnly) {
      _showSnack('Salt okunur görüntüleme modunda kayıt yapılamaz.');
      return;
    }
    final presentationId = widget.presentationId;
    if (presentationId != null) {
      final json = PresentationProjectCodec.encodeProject(
        pages: widget.controller.pages.toList(growable: false),
        effectSettings: widget.controller.effectSettings,
      );
      try {
        await PresentationProjectStore.saveProject(
          presentationId: presentationId,
          json: json,
        );
        final user = FirebaseAuth.instance.currentUser;
        final name = user != null && (user.displayName ?? '').trim().isNotEmpty
            ? user.displayName!.trim()
            : (user?.email ?? '');
        if (mounted) {
          setState(() => _lastEditorLabel = name);
          _showSnack('Sunum buluta kaydedildi.');
        }
      } catch (e) {
        _showSnack('Buluta kaydedilemedi: $e');
      }
      return;
    }

    await savePresentationProjectAsJson(
      pages: widget.controller.pages.toList(growable: false),
      effectSettings: widget.controller.effectSettings,
    );
    _showSnack('Sutols proje dosyasi indirildi.');
  }

  Future<void> _loadProject() async {
    if (widget.adminReadOnly) {
      _showSnack('Salt okunur görüntüleme modunda proje yükleme yapılamaz.');
      return;
    }
    try {
      final project = await loadPresentationProjectFromJson();
      if (project == null) {
        return;
      }
      await hydratePresentationModelSources(project.pages);
      widget.controller.replaceDeck(
        project.pages,
        effectSettings: project.effectSettings,
      );
      _showSnack('Sutols proje dosyasi yuklendi.');
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

  bool get _isEditingText {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;
    final context = primaryFocus.context;
    if (context == null) return false;
    return context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_isEditingText) return false;
    if (widget.adminReadOnly) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      if (widget.controller.hasSelection) {
        widget.controller.removeSelectedItems();
        return true;
      }
    }
    return false;
  }

  void _handleDeleteShortcut() {
    if (_isEditingText) return;
    if (widget.controller.hasSelection) {
      widget.controller.removeSelectedItems();
    } else if (widget.controller.canRemovePage) {
      widget.controller.removeSelectedPage();
    }
  }

  void _handleDuplicateShortcut() {
    if (_isEditingText) return;
    if (widget.controller.hasSelection) {
      widget.controller.duplicateSelectedItems();
    } else {
      widget.controller.duplicatePage(widget.controller.selectedIndex);
    }
  }

  void _handlePrevPageShortcut() {
    if (_isEditingText) return;
    if (widget.controller.selectedIndex > 0) {
      widget.controller.selectPage(widget.controller.selectedIndex - 1);
    }
  }

  void _handleNextPageShortcut() {
    if (_isEditingText) return;
    if (widget.controller.selectedIndex < widget.controller.pages.length - 1) {
      widget.controller.selectPage(widget.controller.selectedIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adminReadOnly && (_adminLoading || _adminLoadError != null)) {
      return _AdminReadOnlyStatusPage(
        loading: _adminLoading,
        error: _adminLoadError,
        onRetry: _adminLoading ? null : _loadAdminPresentation,
      );
    }

    return Focus(
      focusNode: _editorFocusNode,
      autofocus: true,
      canRequestFocus: true,
      child: CallbackShortcuts(
        bindings: widget.adminReadOnly
            ? const <ShortcutActivator, VoidCallback>{}
            : <ShortcutActivator, VoidCallback>{
                // Undo / Redo
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

                // Kopyala / Yapıştır / Kes
                const SingleActivator(LogicalKeyboardKey.keyC, control: true):
                    widget.controller.copySelectedItems,
                const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
                    widget.controller.copySelectedItems,
                const SingleActivator(LogicalKeyboardKey.keyV, control: true):
                    widget.controller.pasteCopiedItems,
                const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
                    widget.controller.pasteCopiedItems,
                const SingleActivator(LogicalKeyboardKey.keyX, control: true):
                    widget.controller.cutSelectedItems,
                const SingleActivator(LogicalKeyboardKey.keyX, meta: true):
                    widget.controller.cutSelectedItems,

                // Çoğalt
                const SingleActivator(LogicalKeyboardKey.keyD, control: true):
                    _handleDuplicateShortcut,
                const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
                    _handleDuplicateShortcut,

                // Tümünü seç
                const SingleActivator(LogicalKeyboardKey.keyA, control: true):
                    widget.controller.selectAllItems,
                const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
                    widget.controller.selectAllItems,

                // Kaydet
                const SingleActivator(LogicalKeyboardKey.keyS, control: true):
                    _saveProject,
                const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
                    _saveProject,

                // Sil
                const SingleActivator(LogicalKeyboardKey.delete):
                    _handleDeleteShortcut,
                const SingleActivator(LogicalKeyboardKey.backspace):
                    _handleDeleteShortcut,

                // Seçimi temizle
                const SingleActivator(LogicalKeyboardKey.escape):
                    widget.controller.clearSelection,

                // Sunum Modu (F5 / Ctrl+Enter)
                const SingleActivator(LogicalKeyboardKey.f5):
                    _openPresentationPreview,
                const SingleActivator(LogicalKeyboardKey.enter, control: true):
                    _openPresentationPreview,
                const SingleActivator(LogicalKeyboardKey.enter, meta: true):
                    _openPresentationPreview,

                // Slayt Gezinme Kısayolları (Yukarı / Aşağı Oklar)
                const SingleActivator(LogicalKeyboardKey.arrowUp):
                    _handlePrevPageShortcut,
                const SingleActivator(LogicalKeyboardKey.arrowLeft):
                    _handlePrevPageShortcut,
                const SingleActivator(LogicalKeyboardKey.pageUp):
                    _handlePrevPageShortcut,
                const SingleActivator(LogicalKeyboardKey.arrowDown):
                    _handleNextPageShortcut,
                const SingleActivator(LogicalKeyboardKey.arrowRight):
                    _handleNextPageShortcut,
                const SingleActivator(LogicalKeyboardKey.pageDown):
                    _handleNextPageShortcut,
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
                      final isMobile =
                          constraints.maxWidth < AppBreakpoints.mobile;
                      // Toggle davranışı için mevcut düzen bilgisini sakla.
                      _studioWide = isStudioWide;

                      if (isStudioWide) {
                        return Column(
                          children: <Widget>[
                            _HtmlStudioHeader(
                              pageCount: pageCount,
                              blockCount: blockCount,
                              onPreview: _openPresentationPreview,
                              onExport: _exportPresentation,
                              onExportPdf: _exportPdfPresentation,
                              onUndo: widget.controller.undo,
                              onRedo: widget.controller.redo,
                              canUndo: widget.controller.canUndo,
                              canRedo: widget.controller.canRedo,
                              onAddText: widget.controller.addTextBlock,
                              onRemoveText:
                                  widget.controller.removeSelectedTextBlock,
                              canRemoveText:
                                  widget.controller.canRemoveTextBlock,
                              lastEditorLabel: _lastEditorLabel,
                              adminReadOnly: widget.adminReadOnly,
                              presentationFileName: _presentationFileName,
                              onEditFileName: _editPresentationFileName,
                              onOpenStageDimensions: () =>
                                  _showStageDimensionsDialog(
                                context,
                                widget.controller,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: _HtmlStudioLayout(
                                  controller: widget.controller,
                                  textController: _textController,
                                  activeTab: _activeTab,
                                  panelOpen: _inspectorOpen,
                                  onTabChanged: _setTab,
                                  adminReadOnly: widget.adminReadOnly,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.all(isMobile ? 4 : 14),
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
                              lastEditorLabel: _lastEditorLabel,
                              adminReadOnly: widget.adminReadOnly,
                              presentationFileName: _presentationFileName,
                              onEditFileName: _editPresentationFileName,
                            ),
                            SizedBox(height: isMobile ? 8 : 14),
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
                                          width:
                                              innerConstraints.maxWidth >= 1320
                                                  ? 238
                                                  : 200,
                                          child: _HtmlPageSidebar(
                                            controller: widget.controller,
                                            readOnly: widget.adminReadOnly,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _HtmlWorkbench(
                                            controller: widget.controller,
                                            textController: _textController,
                                            activeTab: _activeTab,
                                            onTabChanged: _setTab,
                                            readOnly: widget.adminReadOnly,
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  // <1080 (telefon + tablet): mobil-first
                                  // kompozisyon. Tuval ana odaktır; tüm
                                  // seçim panelleri alt iskeleden açılan
                                  // bottom sheet'lerde yaşar.
                                  return _HtmlMobileLayout(
                                    controller: widget.controller,
                                    textController: _textController,
                                    activeTab: _activeTab,
                                    onOpenTool: _openMobileToolSheet,
                                    onOpenPhotoQuick: _openMobilePhotoActions,
                                    canvasZoom: _mobileCanvasZoom,
                                    canvasPan: _mobileCanvasPan,
                                    onScaleStart: _onMobileScaleStart,
                                    onScaleUpdate: _onMobileScaleUpdate,
                                    onScaleEnd: _onMobileScaleEnd,
                                    onMultiTouchChanged:
                                        _onMobileMultiTouchChanged,
                                    canvasInteractive: !_multiTouchActive &&
                                        !widget.adminReadOnly,
                                    showHint: _showMobileHint &&
                                        _mobileCanvasZoom <= 1.0001,
                                    readOnly: widget.adminReadOnly,
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
    this.lastEditorLabel,
    this.adminReadOnly = false,
    this.presentationFileName = 'Sutols Sunumu',
    this.onEditFileName,
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
  final String? lastEditorLabel;
  final String presentationFileName;
  final VoidCallback? onEditFileName;

  /// Salt okunur (admin) mod: düzenleme araçları gizlenir, yerine kırmızı
  /// "GÖRÜNTÜLEME MODU (Admin)" rozeti gösterilir.
  final bool adminReadOnly;

  @override
  Widget build(BuildContext context) {
    final title = InkWell(
      onTap: onEditFileName,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: onEditFileName != null
              ? context.sutolColors.surfaceSubtle
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    presentationFileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: context._htmlInk,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (onEditFileName != null)
                  Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: context._htmlMuted,
                  ),
              ],
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
        ),
      ),
    );
    final actions = <Widget>[
      _HeaderBadge(
        icon: Icons.layers_rounded,
        label: '$pageCount ${tr('Sayfa', 'Pages')}',
      ),
      _HeaderBadge(
        icon: Icons.notes_rounded,
        label: '$blockCount ${tr('Metin', 'Texts')}',
      ),
      _HeaderBadge(
        icon: Icons.html_rounded,
        label: 'HTML / CSS',
      ),
      if (lastEditorLabel != null && lastEditorLabel!.isNotEmpty)
        _HeaderBadge(
          icon: Icons.edit_rounded,
          label: '${tr('Son düzenleme:', 'Last edited:')} $lastEditorLabel',
        ),
      const _SettingsMenuButton(),
      if (!adminReadOnly)
        _HistoryButtons(
          onUndo: onUndo,
          onRedo: onRedo,
          canUndo: canUndo,
          canRedo: canRedo,
        ),
      _HeaderAction(
        icon: Icons.slideshow_rounded,
        label: tr('Sunum Modu', 'Presentation Mode'),
        onTap: onPreview,
      ),
      if (adminReadOnly)
        _HeaderAction(
          icon: Icons.html_rounded,
          label: tr('HTML Disa Aktar', 'Export HTML'),
          onTap: onExport,
        ),
      if (adminReadOnly) const _AdminReadOnlyBadge(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < AppBreakpoints.mobile;
        final compact = constraints.maxWidth < 980;
        final condensed = constraints.maxWidth < 1900;

        // Mobil (<600): marka header'ı — geri, Sutols logosu + adı; ardından
        // geri al/yinele, sunum modu (▶), dışa aktarma (↓) ve diğer işlemler
        // (⋮: görünüm, kaydet, yükle). Çok dar ekranlarda (<340) ikonlar
        // kompakt boyuta iner; kritik aksiyonlar (sunum, dışa aktarma,
        // geri al) hep doğrudan görünür kalır.
        if (mobile) {
          void handleAction(_MobileHeaderAction action) {
            switch (action) {
              case _MobileHeaderAction.preview:
                onPreview();
              case _MobileHeaderAction.settings:
                _showEditorSettings(context);
              case _MobileHeaderAction.save:
                onSave();
              case _MobileHeaderAction.load:
                onLoad();
              case _MobileHeaderAction.exportHtml:
                onExport();
              case _MobileHeaderAction.exportPdf:
                onExportPdf();
            }
          }

          final compact = constraints.maxWidth < 600;
          final iconSize = compact
              ? (constraints.maxWidth < 340 ? 30.0 : 34.0)
              : 40.0;

          return Container(
            key: const ValueKey<String>('mobile-editor-header'),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[
                  _studioHeaderBrandStart,
                  _studioHeaderBrandEnd,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _studioHeaderBorder),
              boxShadow: _studioHeaderFadeShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _MobileHeaderIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Geri',
                      size: iconSize,
                      branded: true,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    _HeaderBrandMark(
                      key: const ValueKey<String>('mobile-brand-mark'),
                      size: compact ? 36 : 50,
                      branded: true,
                      showLabel: false,
                    ),
                  ],
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (!adminReadOnly)
                          _MobileHistoryButtons(
                            onUndo: onUndo,
                            onRedo: onRedo,
                            canUndo: canUndo,
                            canRedo: canRedo,
                            size: iconSize,
                            branded: true,
                          ),
                        _MobileHeaderIconButton(
                          tooltip: 'Sunum Modu',
                          icon: Icons.slideshow_rounded,
                          size: iconSize,
                          branded: true,
                          onTap: onPreview,
                        ),
                        PopupMenuButton<_MobileHeaderAction>(
                          tooltip: 'Dışa Aktar',
                          padding: EdgeInsets.zero,
                          onSelected: handleAction,
                          itemBuilder: (context) =>
                              <PopupMenuEntry<_MobileHeaderAction>>[
                            PopupMenuItem<_MobileHeaderAction>(
                              value: _MobileHeaderAction.exportHtml,
                              child: const ListTile(
                                leading: Icon(Icons.html_rounded),
                                title: Text('HTML Dışa Aktar'),
                              ),
                            ),
                            PopupMenuItem<_MobileHeaderAction>(
                              value: _MobileHeaderAction.exportPdf,
                              child: const ListTile(
                                leading: Icon(Icons.picture_as_pdf_rounded),
                                title: Text('PDF Olarak Yazdır'),
                              ),
                            ),
                          ],
                          child: _MobileHeaderIconButton(
                            icon: Icons.download_rounded,
                            tooltip: '',
                            size: iconSize,
                            branded: true,
                            onTap: () {},
                          ),
                        ),
                        if (adminReadOnly)
                          const _AdminReadOnlyBadge(compact: true)
                        else
                          PopupMenuButton<_MobileHeaderAction>(
                            tooltip: 'Diğer işlemler',
                            padding: EdgeInsets.zero,
                            onSelected: handleAction,
                            itemBuilder: (context) =>
                                <PopupMenuEntry<_MobileHeaderAction>>[
                              PopupMenuItem<_MobileHeaderAction>(
                                value: _MobileHeaderAction.settings,
                                child: const ListTile(
                                  leading: Icon(Icons.settings_outlined),
                                  title: Text('Ayarlar'),
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem<_MobileHeaderAction>(
                                value: _MobileHeaderAction.save,
                                child: const ListTile(
                                  leading: Icon(Icons.save_alt_rounded),
                                  title: Text('Projeyi Kaydet'),
                                ),
                              ),
                              PopupMenuItem<_MobileHeaderAction>(
                                value: _MobileHeaderAction.load,
                                child: const ListTile(
                                  leading: Icon(Icons.upload_file_rounded),
                                  title: Text('Proje Yükle'),
                                ),
                              ),
                            ],
                            child: _MobileHeaderIconButton(
                              icon: Icons.more_vert_rounded,
                              tooltip: '',
                              size: iconSize,
                              branded: true,
                              onTap: () {},
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (condensed) {
          final condensedActions = <Widget>[
            _HeaderAction(
              icon: Icons.slideshow_rounded,
              label: tr('Sunum Modu', 'Presentation Mode'),
              onTap: onPreview,
              branded: true,
            ),
            if (adminReadOnly)
              _HeaderAction(
                icon: Icons.html_rounded,
                label: tr('HTML Disa Aktar', 'Export HTML'),
                onTap: onExport,
                branded: true,
              ),
            if (adminReadOnly) const _AdminReadOnlyBadge(compact: true),
            if (!adminReadOnly)
              _HistoryButtons(
                onUndo: onUndo,
                onRedo: onRedo,
                canUndo: canUndo,
                canRedo: canRedo,
                branded: true,
              ),
            const _SettingsMenuButton(branded: true),
            _HeaderBadge(
              icon: Icons.layers_rounded,
              label: '$pageCount ${tr('Sayfa', 'Pages')}',
              branded: true,
            ),
          ];
          final titleWidth =
              (constraints.maxWidth * 0.22).clamp(160.0, 300.0).toDouble();

          return Container(
            key: const ValueKey<String>('condensed-editor-header'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[
                  _studioHeaderBrandStart,
                  _studioHeaderBrandEnd,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _studioHeaderBorder),
              boxShadow: _studioHeaderFadeShadow,
            ),
            child: Row(
              children: <Widget>[
                _HeaderBrandMark(
                  key: const ValueKey<String>('condensed-brand-mark'),
                  size: 48,
                  branded: true,
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: titleWidth,
                  child: InkWell(
                    onTap: onEditFileName,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              presentationFileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: _studioHeaderForeground,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          if (onEditFileName != null) ...<Widget>[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.edit_rounded,
                              size: 15,
                              color: _studioHeaderMuted,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for (var i = 0;
                            i < condensedActions.length;
                            i += 1) ...<Widget>[
                          if (i > 0) const SizedBox(width: 8),
                          condensedActions[i],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

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
                        _HeaderBrandMark(
                          size: 44,
                          branded: false,
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
                    _HeaderBrandMark(
                      size: 44,
                      branded: false,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: title),
                    // Aksiyonlar genişliği aşarsa alt satıra düşebilmeli;
                    // Flexible olmadan Row yatayda taşar.
                    Flexible(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: actions,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// Kırmızı "GÖRÜNTÜLEME MODU (Admin)" rozeti. Üst barda "Kaydet" yerine
/// gösterilir; salt okunur modun düzenlenemez olduğunu vurgular.
class _AdminReadOnlyBadge extends StatelessWidget {
  const _AdminReadOnlyBadge({this.compact = false});

  /// Dar ekranlar için: kısa metin ve ince dolgu.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = compact ? 'GÖRÜNTÜLEME' : 'GÖRÜNTÜLEME MODU (Admin)';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 8 : 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.visibility_rounded,
            size: compact ? 16 : 18,
            color: Colors.white,
          ),
          SizedBox(width: compact ? 5 : 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 11 : 13,
                ),
          ),
        ],
      ),
    );
  }
}

/// Salt okunur (admin) modun yükleme / hata ekranı. Yükleme tamamlanana kadar
/// spinner, hata durumunda yeniden dene + geri dön eylemleri gösterir.
class _AdminReadOnlyStatusPage extends StatelessWidget {
  const _AdminReadOnlyStatusPage({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: loading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Sunum yükleniyor...'),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error ?? 'Sunum yüklenemedi.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Geri Dön'),
                        ),
                        if (onRetry != null) ...<Widget>[
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Yeniden Dene'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Çoklu dokunma kapısı: ikinci parmak inince [onMultiTouch] true bildirilir
/// (tuval içi jestler kapatılır, kıstırma sahne katmanındaki scale tanıyıcıya
/// geçer); parmaklar kalkınca false ile eski haline döner.
class _MultiTouchGate extends StatefulWidget {
  const _MultiTouchGate({
    required this.onMultiTouch,
    required this.child,
  });

  final ValueChanged<bool> onMultiTouch;
  final Widget child;

  @override
  State<_MultiTouchGate> createState() => _MultiTouchGateState();
}

class _MultiTouchGateState extends State<_MultiTouchGate> {
  final Set<int> _activePointers = <int>{};

  void _sync(bool multi) {
    if (mounted) {
      widget.onMultiTouch(multi);
    }
  }

  void _track(PointerEvent event, {required bool down}) {
    final before = _activePointers.length >= 2;
    if (down) {
      _activePointers.add(event.pointer);
    } else {
      _activePointers.remove(event.pointer);
    }
    final after = _activePointers.length >= 2;
    if (before != after) {
      _sync(after);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _track(e, down: true),
      onPointerUp: (e) => _track(e, down: false),
      onPointerCancel: (e) => _track(e, down: false),
      child: widget.child,
    );
  }
}

/// Mobil-first çalışma alanı (telefon + tablet, <1080).
///
/// Hiyerarşi: başlık → bağlamsal formatlama barı (yalnızca seçimde, sahnenin
/// üstünde yüzer) → tuval → slayt küçük resim şeridi → alt araç iskelesi.
/// Bağlamsal bar ve ipucu tuvali asla kalıcı olarak küçültmez; panel içerikleri
/// yalnızca alt iskeleden açılan bottom sheet'lerde yaşar.
class _HtmlMobileLayout extends StatelessWidget {
  const _HtmlMobileLayout({
    required this.controller,
    required this.textController,
    required this.activeTab,
    required this.onOpenTool,
    required this.onOpenPhotoQuick,
    required this.canvasZoom,
    required this.canvasPan,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.onMultiTouchChanged,
    required this.canvasInteractive,
    required this.showHint,
    this.readOnly = false,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onOpenTool;

  /// Dock'taki "Fotoğraf" kısayolunun hızlı aksiyon sheet'ini açması.
  final VoidCallback onOpenPhotoQuick;
  final double canvasZoom;
  final Offset canvasPan;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;
  final ValueChanged<bool> onMultiTouchChanged;
  final bool canvasInteractive;
  final bool showHint;

  /// Salt okunur (admin) mod: alt araç iskelesi ve bağlamsal bar gizlenir,
  /// tuval etkileşimsiz olur ve şeritte sayfa ekle kapatılır.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 8 : 2,
                    isTablet ? 6 : 2,
                    isTablet ? 8 : 2,
                    0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: onScaleStart,
                    onScaleUpdate: onScaleUpdate,
                    onScaleEnd: onScaleEnd,
                    child: _MultiTouchGate(
                      onMultiTouch: onMultiTouchChanged,
                      child: ClipRect(
                        child: _HtmlStageCard(
                          controller: controller,
                          canvasZoom: canvasZoom,
                          canvasPan: canvasPan,
                          showHint: showHint,
                          interactive: canvasInteractive,
                          readOnly: readOnly,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (!readOnly)
                Positioned(
                  left: 12,
                  right: 12,
                  top: 10,
                  child: IgnorePointer(
                    ignoring: canvasZoom > 1.0001,
                    child: _SelectionContextBarSection(
                      controller: controller,
                      textController: textController,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _HtmlMobileSlideStrip(
          controller: controller,
          readOnly: readOnly,
        ),
        if (!readOnly) ...<Widget>[
          const SizedBox(height: 8),
          _HtmlMobileToolDock(
            controller: controller,
            activeTab: activeTab,
            onOpenTool: onOpenTool,
            onOpenPhotoQuick: onOpenPhotoQuick,
          ),
        ],
      ],
    );
  }
}

/// Tuvalin altındaki kalıcı slayt şeridi: yatay kaydırılabilir kompakt
/// önizlemeler; seçili slayt vurgulanır ve otomatik olarak görünüme getirilir.
/// Normal slayt gezinmesi buradan yapılır (alt iskelede "Slaytlar" yoktur).
class _HtmlMobileSlideStrip extends StatefulWidget {
  const _HtmlMobileSlideStrip({
    required this.controller,
    this.readOnly = false,
  });

  final PresentationController controller;

  /// Salt okunur (admin) mod: "Yeni Slayt" butonu gizlenir.
  final bool readOnly;

  @override
  State<_HtmlMobileSlideStrip> createState() => _HtmlMobileSlideStripState();
}

class _HtmlMobileSlideStripState extends State<_HtmlMobileSlideStrip> {
  static const double _thumbWidth = 64;
  static const double _gap = 8;

  final ScrollController _scrollController = ScrollController();
  late int _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = widget.controller.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant _HtmlMobileSlideStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = widget.controller.selectedIndex;
    if (selected == _lastSelectedIndex) {
      return;
    }
    _lastSelectedIndex = selected;
    if (!_scrollController.hasClients) {
      return;
    }
    final viewport = _scrollController.position.viewportDimension;
    final target =
        (selected * (_thumbWidth + _gap) - (viewport - _thumbWidth) / 2)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('mobile-slide-strip'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.controller.pages.length,
              separatorBuilder: (_, __) => const SizedBox(width: _gap),
              itemBuilder: (context, index) {
                final page = widget.controller.pages[index];
                return _SlideStripThumb(
                  page: page,
                  index: index,
                  isSelected: index == widget.controller.selectedIndex,
                  onTap: () => widget.controller.selectPage(index),
                  onLongPress: !widget.readOnly && widget.controller.canRemovePage
                      ? () => _confirmDeleteCurrentSlide(context, widget.controller, index)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          if (!widget.readOnly) ...<Widget>[
            if (widget.controller.canRemovePage) ...<Widget>[
              IconButton(
                key: const ValueKey<String>('mobile-slide-strip-delete'),
                tooltip: 'Sahneyi Sil',
                onPressed: () => _confirmDeleteCurrentSlide(context, widget.controller),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  minimumSize: const Size(36, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
              ),
              const SizedBox(width: 4),
            ],
            IconButton(
              key: const ValueKey<String>('mobile-slide-strip-add'),
              tooltip: 'Yeni Slayt',
              onPressed: widget.controller.addPage,
              style: IconButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                minimumSize: const Size(36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mobil slayt silme onay diyaloğu.
Future<void> _confirmDeleteCurrentSlide(
  BuildContext context,
  PresentationController controller, [
  int? targetIndex,
]) async {
  final index = targetIndex ?? controller.selectedIndex;
  if (!controller.canRemovePage) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('En az 1 sahne bulunmalıdır.')),
    );
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sahneyi Sil'),
      content: Text('${index + 1}. sahneyi silmek istediğinizden emin misiniz?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Sil'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    controller.removePageAt(index);
  }
}

/// Şeritteki tek bir slayt küçük resmi: 16:9 önizleme + numara rozeti.
/// İçerik, gerçek tuval ile aynı oranda küçültülür (dev metin bindirmesi
/// olmaz); seçili slayt belirgin border, gölge ve arka plan farkıyla ayrılır.
class _SlideStripThumb extends StatelessWidget {
  const _SlideStripThumb({
    required this.page,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  static const double _width = 64;
  static const double _height = 36;

  /// Küçük resmin oluşturulduğu mantıksal 16:9 tuval boyutu; gerçek tuvaldeki
  /// piksel tabanlı yazı boyutlarının önizlemede aynı oranda küçülmesini sağlar.
  static const Size _logicalCanvasSize = Size(360, 202.5);

  final PresentationPage page;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey<String>('mobile-slide-strip-thumb-$index'),
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: _width,
        height: _height,
        padding: EdgeInsets.all(isSelected ? 1 : 0),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: IgnorePointer(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _logicalCanvasSize.width,
                    height: _logicalCanvasSize.height,
                    child: PresentationPageCanvas(
                      page: page,
                      showHint: false,
                      showSelectionBorder: false,
                      showEmptyState: false,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary
                      : Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isSelected ? context.colors.onPrimary : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
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

/// Alt araç iskelesi: Metin, Fotoğraf, Medya, 3B Modeller, Bileşenler ve
/// "Daha fazla"
/// (fotoğraf yükle, şablon, arka plan, geçiş, ses vb.).
/// Dar ekranlarda sığmayan araçlar öncelik sırasına göre "Daha fazla"
/// menüsüne taşınır; yatay kaydırma yoktur. Slayt gezinmesi tuvalin altındaki
/// kalıcı küçük resim şeridinde yapılır.
class _HtmlMobileToolDock extends StatelessWidget {
  const _HtmlMobileToolDock({
    required this.controller,
    required this.activeTab,
    required this.onOpenTool,
    required this.onOpenPhotoQuick,
  });

  final PresentationController controller;
  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onOpenTool;

  /// "Daha fazla" menüsündeki "Fotoğraf Yükle" kısayolunun hızlı aksiyon
  /// sheet'ini açması (cihazdan seçim ya da Medya kütüphanesi).
  final VoidCallback onOpenPhotoQuick;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selectedText = controller.selectedTextBlock;
        final selectedComponent = controller.selectedComponentBlock;

        final tools = <_MobileDockTool>[];

        if (selectedText != null) {
          tools.addAll(<_MobileDockTool>[
            _MobileDockTool(
              icon: Icons.edit_note_rounded,
              label: tr('Metin', 'Text'),
              selected: activeTab == _HtmlToolTab.text,
              onTap: () => onOpenTool(_HtmlToolTab.text),
            ),
            _MobileDockTool(
              icon: Icons.palette_rounded,
              label: tr('Stil', 'Style'),
              selected: activeTab == _HtmlToolTab.text,
              onTap: () => onOpenTool(_HtmlToolTab.text),
            ),
            _MobileDockTool(
              icon: Icons.delete_outline_rounded,
              label: tr('Öğeyi Sil', 'Delete Item'),
              selected: false,
              onTap: () => controller.removeSelectedTextBlock(),
            ),
            _MobileDockTool(
              icon: Icons.close_rounded,
              label: tr('Kapat', 'Close'),
              selected: false,
              onTap: () => controller.clearSelection(),
            ),
          ]);
        } else if (selectedComponent != null) {
          tools.addAll(<_MobileDockTool>[
            _MobileDockTool(
              icon: Icons.palette_rounded,
              label: tr('Stil', 'Style'),
              selected: activeTab == _HtmlToolTab.components,
              onTap: () => onOpenTool(_HtmlToolTab.components),
            ),
            _MobileDockTool(
              icon: Icons.image_rounded,
              label: tr('Fotoğraf', 'Photo'),
              selected: false,
              onTap: onOpenPhotoQuick,
            ),
            _MobileDockTool(
              icon: Icons.delete_outline_rounded,
              label: tr('Öğeyi Sil', 'Delete Item'),
              selected: false,
              onTap: () => controller.removeSelectedComponentBlock(),
            ),
            _MobileDockTool(
              icon: Icons.close_rounded,
              label: tr('Kapat', 'Close'),
              selected: false,
              onTap: () => controller.clearSelection(),
            ),
          ]);
        } else {
          tools.addAll(<_MobileDockTool>[
            _MobileDockTool(
              icon: Icons.dashboard_customize_rounded,
              label: tr('Şablon', 'Template'),
              selected: activeTab == _HtmlToolTab.templates,
              onTap: () => onOpenTool(_HtmlToolTab.templates),
            ),
            _MobileDockTool(
              icon: Icons.wallpaper_rounded,
              label: tr('Arka Plan', 'Background'),
              selected: activeTab == _HtmlToolTab.backgrounds,
              onTap: () => onOpenTool(_HtmlToolTab.backgrounds),
            ),
            _MobileDockTool(
              icon: Icons.text_fields_rounded,
              label: tr('Metin', 'Text'),
              selected: activeTab == _HtmlToolTab.text,
              onTap: () => controller.addTextBlock(),
            ),
            _MobileDockTool(
              icon: Icons.view_in_ar_rounded,
              label: tr('Modeller', 'Models'),
              selected: activeTab == _HtmlToolTab.models3d,
              onTap: () => onOpenTool(_HtmlToolTab.models3d),
            ),
            _MobileDockTool(
              icon: Icons.widgets_rounded,
              label: tr('Bileşen', 'Component'),
              selected: activeTab == _HtmlToolTab.components,
              onTap: () => onOpenTool(_HtmlToolTab.components),
            ),
            _MobileDockTool(
              icon: Icons.delete_outline_rounded,
              label: tr('Sahne Sil', 'Delete Slide'),
              selected: false,
              onTap: () => _confirmDeleteCurrentSlide(context, controller),
            ),
          ]);
        }

        final moreSelected = const <_HtmlToolTab>{
          _HtmlToolTab.stageDimensions,
          _HtmlToolTab.templates,
          _HtmlToolTab.backgrounds,
          _HtmlToolTab.transitions,
        }.contains(activeTab);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Container'ın yatay padding'i Row'un gerçek kullanılabilir alanını
            // daraltır. Hesabı dış genişlikle yapmak 320-390px cihazlarda son
            // chip'in taşmasına ve dokunma hedeflerinin üst üste binmesine neden
            // oluyordu.
            final available = math.max(0, constraints.maxWidth - 16);
            final gap = _MobileDockButton.chipGap;
            final compactMoreWidth = _MobileDockButton.compactWidth;
            final fullMoreWidth = _dockChipWidth(context, 'Daha fazla');
            final widths = <double>[
              for (final t in tools) _dockChipWidth(context, t.label)
            ];
            final toolsWidth = widths.fold<double>(0, (sum, w) => sum + w + gap);
            final fullFits = toolsWidth + fullMoreWidth <= available;
            final compactFits = toolsWidth + compactMoreWidth <= available;
            final visible = <int>[];
            if (fullFits || compactFits) {
              visible.addAll(List<int>.generate(tools.length, (i) => i));
            } else {
              double used = 0;
              for (var i = 0; i < tools.length; i++) {
                if (used + widths[i] + gap + compactMoreWidth <= available) {
                  visible.add(i);
                  used += widths[i] + gap;
                } else {
                  break;
                }
              }
            }
            return Container(
              key: const ValueKey<String>('mobile-tool-dock'),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
                boxShadow: context.elevation2,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  // Araçlar dar ekranda azalsa bile iskele boyunca eşit dağılır;
                  // solda "devasa boşluk" oluşmaz.
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for (final i in visible)
                      Padding(
                        padding: EdgeInsets.only(right: gap),
                        child: _MobileDockButton(
                          icon: tools[i].icon,
                          label: tools[i].label,
                          selected: tools[i].selected,
                          onTap: tools[i].onTap,
                        ),
                      ),
                    PopupMenuButton<_MobileMoreTool>(
                      tooltip: 'Daha fazla araç',
                      onSelected: (tool) => _handleMore(context, tool),
                      itemBuilder: (context) {
                        // Dar ekranda dock'a sığmayan araçlar (öncelik sırasıyla)
                        // menünün başına düşer; böylece hiçbir araç kaybolmaz.
                        final hiddenLabels = tools
                            .asMap()
                            .entries
                            .where((e) => !visible.contains(e.key))
                            .map((e) => e.value.label)
                            .toSet();
                        final entries = <PopupMenuEntry<_MobileMoreTool>>[];
                        for (final entry in tools.asMap().entries) {
                          if (!visible.contains(entry.key)) {
                            final tool = entry.value;
                            entries.add(PopupMenuItem<_MobileMoreTool>(
                              value: switch (tool.label) {
                                'Metin' => _MobileMoreTool.text,
                                'Fotoğraf' => _MobileMoreTool.photoUpload,
                                'Medya' => _MobileMoreTool.media,
                                'Modeller' || '3B Modeller' => _MobileMoreTool.models3d,
                                'Sahne Ölçüleri' || 'Ölçü' => _MobileMoreTool.stageDimensions,
                                _ => _MobileMoreTool.components,
                              },
                              child: ListTile(
                                leading: Icon(tool.icon),
                                title: Text(tool.label),
                              ),
                            ));
                          }
                        }
                        void add(
                          _MobileMoreTool value,
                          IconData icon,
                          String label,
                        ) {
                          entries.add(PopupMenuItem<_MobileMoreTool>(
                            value: value,
                            child: ListTile(
                              leading: Icon(icon),
                              title: Text(label),
                            ),
                          ));
                        }

                        add(
                          _MobileMoreTool.templates,
                          Icons.dashboard_customize_rounded,
                          'Şablonlar',
                        );
                        add(
                          _MobileMoreTool.backgrounds,
                          Icons.wallpaper_rounded,
                          'Arka Planlar',
                        );
                        if (!hiddenLabels.contains('Bileşenler') && !hiddenLabels.contains('Bileşen')) {
                          add(
                            _MobileMoreTool.components,
                            Icons.widgets_rounded,
                            'Bileşenler',
                          );
                        }
                        if (!hiddenLabels.contains('Modeller') && !hiddenLabels.contains('3B Modeller')) {
                          add(
                            _MobileMoreTool.models3d,
                            Icons.view_in_ar_rounded,
                            '3B Modeller',
                          );
                        }
                        add(
                          _MobileMoreTool.transitions,
                          Icons.animation_rounded,
                          'Geçişler',
                        );
                        if (!hiddenLabels.contains('Fotoğraf') && !hiddenLabels.contains('Fotoğraf Yükle')) {
                          add(
                            _MobileMoreTool.photoUpload,
                            Icons.add_a_photo_rounded,
                            'Fotoğraf',
                          );
                        }
                        add(
                          _MobileMoreTool.animations,
                          Icons.auto_awesome_rounded,
                          'Animasyonlar',
                        );
                        add(
                          _MobileMoreTool.audio,
                          Icons.music_note_rounded,
                          'Ses',
                        );
                        add(
                          _MobileMoreTool.stageDimensions,
                          Icons.aspect_ratio_rounded,
                          'Sahne Ölçüleri',
                        );
                        return entries;
                      },
                      child: _MobileDockButton(
                        icon: Icons.more_horiz_rounded,
                        label: fullFits ? 'Daha fazla' : '',
                        selected: moreSelected,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleMore(BuildContext context, _MobileMoreTool tool) {
    switch (tool) {
      case _MobileMoreTool.photoUpload:
        onOpenPhotoQuick();
      case _MobileMoreTool.text:
        onOpenTool(_HtmlToolTab.text);
      case _MobileMoreTool.media:
        onOpenTool(_HtmlToolTab.photo);
      case _MobileMoreTool.components:
        onOpenTool(_HtmlToolTab.components);
      case _MobileMoreTool.templates:
        onOpenTool(_HtmlToolTab.templates);
      case _MobileMoreTool.backgrounds:
        onOpenTool(_HtmlToolTab.backgrounds);
      case _MobileMoreTool.models3d:
        onOpenTool(_HtmlToolTab.models3d);
      case _MobileMoreTool.transitions:
        onOpenTool(_HtmlToolTab.transitions);
      case _MobileMoreTool.animations:
        onOpenTool(_HtmlToolTab.transitions);
      case _MobileMoreTool.audio:
        onOpenTool(_HtmlToolTab.backgrounds);
      case _MobileMoreTool.stageDimensions:
        onOpenTool(_HtmlToolTab.stageDimensions);
    }
  }
}

/// Label'lı bir dock chip'inin tahmini genişliği (ölçüm tabanlı).
double _dockChipWidth(BuildContext context, String label) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: _dockLabelStyle(context)),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  return math.max(
    _MobileDockButton.miniWidth,
    _MobileDockButton.paddingH * 2 +
        math.max(_MobileDockButton.iconSize, painter.width),
  );
}

/// Dock label'leri için ortak tipografi (ölçüm ile görsel tutarlı).
TextStyle _dockLabelStyle(BuildContext context) {
  return (Theme.of(context).textTheme.labelSmall ??
          const TextStyle(fontSize: _MobileDockButton.labelFontSize))
      .copyWith(
    color: context.sutolColors.onSurfaceVariant,
    fontWeight: FontWeight.w800,
    fontSize: _MobileDockButton.labelFontSize,
  );
}

class _MobileDockTool {
  const _MobileDockTool({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
}

class _MobileDockButton extends StatelessWidget {
  const _MobileDockButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;

  /// `null` ise dokunuş tüketilmez (örn. PopupMenuButton'ın çocuğu olarak
  /// kullanıldığında menünün açılması için dokunuş üst elemana iletilir).
  final VoidCallback? onTap;
  final bool selected;

  static const double iconSize = 19;
  static const double iconGap = 3;
  static const double paddingH = 8;
  static const double paddingV = 8;
  static const double miniWidth = 56;
  static const double compactWidth = 44;
  static const double chipGap = 4;
  static const double labelFontSize = 10;

  @override
  Widget build(BuildContext context) {
    final iconOnly = label.isEmpty;
    final foreground =
        selected ? context._htmlAccent : context.sutolColors.onSurfaceVariant;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = selected
        ? (isDark
            ? context.colors.primary.withValues(alpha: 0.18)
            : const Color(0xFFEDF4FF))
        : Colors.transparent;
    final borderColor = selected
        ? (isDark
            ? context.colors.primary.withValues(alpha: 0.4)
            : const Color(0xFFD4E4FF))
        : Colors.transparent;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: BoxConstraints(
            minWidth: iconOnly ? compactWidth : miniWidth,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: iconOnly ? 20 : iconSize, color: foreground),
              if (!iconOnly) ...<Widget>[
                const SizedBox(height: iconGap),
                Text(
                  label,
                  maxLines: 1,
                  style: _dockLabelStyle(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock'taki "Fotoğraf" kısayolu için hızlı aksiyon sheet'i: cihazdan seçim
/// ya da daha önce yüklenen fotoğraf kütüphanesi arasında seçim sunar.
/// (Kamera desteği yoktur; fotoğraflar sistem dosya/galeri seçiciyle alınır.)
class _MobilePhotoQuickSheet extends StatelessWidget {
  const _MobilePhotoQuickSheet({
    required this.onPicked,
    required this.onLibrary,
  });

  final VoidCallback onPicked;
  final VoidCallback onLibrary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
        boxShadow: context.elevation2,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Fotoğraf Ekle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 14),
            _MobilePhotoQuickOption(
              icon: Icons.photo_library_rounded,
              title: 'Galeriden / Dosyadan',
              subtitle: 'Cihazından fotoğraf seç, slayta eklensin',
              onTap: onPicked,
            ),
            const SizedBox(height: 8),
            _MobilePhotoQuickOption(
              icon: Icons.collections_rounded,
              title: 'Fotoğraf Kütüphanem',
              subtitle: 'Daha önce yüklediğin fotoğraflar',
              onTap: onLibrary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobilePhotoQuickOption extends StatelessWidget {
  const _MobilePhotoQuickOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.sutolColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: context._htmlAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context._htmlMuted,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.sutolColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alt iskeleden açılan alet paneli bottom sheet'i.
/// Ekranın en fazla ~%70'ini kaplar; başlık + kapatma ve kendi içinde
/// kaydırılabilen içerik taşır. Tuval arka planda görünür kalır.
class _HtmlMobileToolSheet extends StatefulWidget {
  const _HtmlMobileToolSheet({
    super.key,
    required this.controller,
    required this.textController,
    required this.tab,
    required this.onClose,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab tab;
  final VoidCallback onClose;

  @override
  State<_HtmlMobileToolSheet> createState() => _HtmlMobileToolSheetState();
}

class _HtmlMobileToolSheetState extends State<_HtmlMobileToolSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final expanded = notification.extent > 0.50;
        if (expanded != _isExpanded) {
          setState(() {
            _isExpanded = expanded;
          });
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: keyboardInset > 0 ? 0.85 : 0.40,
        minChildSize: 0.22,
        maxChildSize: 0.88,
        snap: true,
        snapSizes: const <double>[0.40, 0.88],
        builder: (context, scrollController) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(26)),
                    boxShadow: context.elevation2,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            margin: const EdgeInsets.only(top: 10, bottom: 4),
                            decoration: BoxDecoration(
                              color: context.colors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 8, 4),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                _htmlToolIcon(widget.tab),
                                size: 20,
                                color: context._htmlAccent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _studioPanelTitle(widget.tab),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: context._htmlInk,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Kapat',
                                onPressed: widget.onClose,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: context.sutolColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: widget.controller,
                            builder: (context, _) => _HtmlControlPanel(
                              key: ValueKey<_HtmlToolTab>(widget.tab),
                              controller: widget.controller,
                              textController: widget.textController,
                              activeTab: widget.tab,
                              isExpanded: _isExpanded,
                              scrollController: scrollController,
                            ),
                          ),
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

IconData _htmlToolIcon(_HtmlToolTab tab) {
  switch (tab) {
    case _HtmlToolTab.templates:
      return Icons.dashboard_customize_rounded;
    case _HtmlToolTab.backgrounds:
      return Icons.wallpaper_rounded;
    case _HtmlToolTab.components:
      return Icons.widgets_rounded;
    case _HtmlToolTab.text:
      return Icons.text_fields_rounded;
    case _HtmlToolTab.models3d:
      return Icons.view_in_ar_rounded;
    case _HtmlToolTab.photo:
      return Icons.add_photo_alternate_rounded;
    case _HtmlToolTab.transitions:
      return Icons.animation_rounded;
    case _HtmlToolTab.stageDimensions:
      return Icons.aspect_ratio_rounded;
  }
}

/// Slayt listesi bottom sheet'i: yatay küçük önizlemeler + ekle/sil.
class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.icon,
    required this.label,
    this.branded = false,
  });

  final IconData icon;
  final String label;
  final bool branded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color:
            branded ? _studioHeaderControl : context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: branded ? _studioHeaderBorder : context.sutolColors.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 18,
            color: branded ? _studioHeaderForeground : context._htmlInk,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: branded ? _studioHeaderForeground : context._htmlInk,
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
    this.branded = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool branded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: branded ? _studioHeaderControl : context._htmlAccent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: branded
                    ? _studioHeaderForeground
                    : context.sutolColors.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: branded
                          ? _studioHeaderForeground
                          : context.sutolColors.surface,
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

/// Mobil başlıktaki "⋯" overflow menüsünün eylemleri.
enum _MobileHeaderAction {
  preview,
  settings,
  save,
  load,
  exportHtml,
  exportPdf,
}

/// Mobil alt iskeledeki "Daha fazla" menüsünün aletleri.
enum _MobileMoreTool {
  photoUpload,
  text,
  media,
  components,
  templates,
  backgrounds,
  models3d,
  transitions,

  /// "Animasyonlar" → Geçişler (slayt animasyonları) paneli.
  animations,

  /// "Ses" → Arka Planlar (müzik ve ses) paneli.
  audio,

  /// "Sahne Ölçüleri" → Dikey mobil, standart 16:9, özel ölçü seçimi.
  stageDimensions,
}

/// Mobil "Fotoğraf" hızlı aksiyonunun seçenekleri.
enum _MobilePhotoQuickAction { pick, library }

Future<void> _showEditorSettings(BuildContext context) {
  final langController = LanguageController.instance;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => ValueListenableBuilder<AppLanguage>(
      valueListenable: langController.currentLanguage,
      builder: (context, currentLang, _) {
        return AlertDialog(
          title: Text(langController.tr('Ayarlar', 'Settings')),
          contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.instance.mode,
                  builder: (context, mode, _) {
                    final isDark = mode == ThemeMode.dark;
                    return ListTile(
                      key: const ValueKey<String>('settings-dark-theme'),
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: Text(langController.tr('Koyu Tema', 'Dark Mode')),
                      subtitle: Text(
                        isDark
                            ? langController.tr('Açık', 'On')
                            : langController.tr('Kapalı', 'Off'),
                      ),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ThemeController.instance.toggle(),
                      ),
                      onTap: ThemeController.instance.toggle,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  key: const ValueKey<String>('settings-language'),
                  leading: const Icon(Icons.language_outlined),
                  title: Text(langController.tr('Dil / Language', 'Language')),
                  subtitle: Text(
                    currentLang == AppLanguage.en ? 'English' : 'Türkçe',
                  ),
                  trailing: SegmentedButton<AppLanguage>(
                    segments: const [
                      ButtonSegment<AppLanguage>(
                        value: AppLanguage.tr,
                        label: Text('TR'),
                      ),
                      ButtonSegment<AppLanguage>(
                        value: AppLanguage.en,
                        label: Text('EN'),
                      ),
                    ],
                    selected: {currentLang},
                    onSelectionChanged: (Set<AppLanguage> selected) {
                      if (selected.isNotEmpty) {
                        langController.setLanguage(selected.first);
                      }
                    },
                  ),
                ),
                if (langController.detectedLocationInfo != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            langController.tr(
                              'Konum: ${langController.detectedLocationInfo}',
                              'Location: ${langController.detectedLocationInfo}',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                ListTile(
                  key: const ValueKey<String>('settings-plans'),
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(langController.tr('Planlar', 'Plans')),
                  subtitle: Text(
                    langController.tr(
                      'Üyelik seçeneklerini görüntüle',
                      'View membership options',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MembershipPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(langController.tr('Kapat', 'Close')),
            ),
          ],
        );
      },
    ),
  );
}

class _SettingsMenuButton extends StatelessWidget {
  const _SettingsMenuButton({this.branded = false, this.compact = false});

  final bool branded;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = branded ? _studioHeaderForeground : context._htmlInk;
    return Material(
      color: branded ? _studioHeaderControl : context.sutolColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: const ValueKey<String>('editor-settings-button'),
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showEditorSettings(context),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: 11,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.settings_outlined, size: 18, color: foreground),
              if (!branded && !compact) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  'Ayarlar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
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
    this.branded = false,
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;
  final bool branded;

  @override
  Widget build(BuildContext context) {
    final background =
        branded ? _studioHeaderControl : context.sutolColors.surfaceSubtle;
    final borderColor =
        branded ? _studioHeaderBorder : context.sutolColors.outline;
    final enabledColor = branded ? _studioHeaderForeground : context._htmlInk;
    final disabledColor = branded
        ? _studioHeaderMuted.withValues(alpha: 0.48)
        : context._htmlMuted.withValues(alpha: 0.52);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
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

/// Mobil header'daki kompakt ikon düğmesi (40px hedef alanı; header yüksekliği
/// 56-60px bandında kalır).
class _MobileHeaderIconButton extends StatelessWidget {
  const _MobileHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.enabled = true,
    this.size = 40,
    this.branded = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool enabled;
  final double size;
  final bool branded;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size(size, size),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(
        icon,
        size: 20,
        color: enabled
            ? branded
                ? _studioHeaderForeground
                : context._htmlInk
            : branded
                ? _studioHeaderMuted.withValues(alpha: 0.45)
                : context._htmlMuted.withValues(alpha: 0.45),
      ),
    );
  }
}

/// Mobil header'daki kompakt geri al / yinele çifti (doğrudan erişilebilir).
class _MobileHistoryButtons extends StatelessWidget {
  const _MobileHistoryButtons({
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
    this.size = 40,
    this.branded = false,
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;

  /// Çok dar ekranlarda (<340) kompakt boyut.
  final double size;
  final bool branded;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _MobileHeaderIconButton(
          icon: Icons.undo_rounded,
          tooltip: 'Geri al',
          enabled: canUndo,
          onTap: onUndo,
          size: size,
          branded: branded,
        ),
        _MobileHeaderIconButton(
          icon: Icons.redo_rounded,
          tooltip: 'Yinele',
          enabled: canRedo,
          onTap: onRedo,
          size: size,
          branded: branded,
        ),
      ],
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
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
    required this.onAddText,
    required this.onRemoveText,
    required this.canRemoveText,
    this.lastEditorLabel,
    this.adminReadOnly = false,
    this.presentationFileName = 'Sutols Sunumu',
    this.onEditFileName,
    this.onOpenStageDimensions,
  });

  final int pageCount;
  final int blockCount;
  final VoidCallback onPreview;
  final VoidCallback onExport;
  final VoidCallback onExportPdf;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onAddText;
  final VoidCallback onRemoveText;
  final bool canRemoveText;
  final String? lastEditorLabel;
  final String presentationFileName;
  final VoidCallback? onEditFileName;
  final VoidCallback? onOpenStageDimensions;

  /// Salt okunur (admin) mod: düzenleme araçları gizlenir, yerine kırmızı
  /// "GÖRÜNTÜLEME MODU (Admin)" rozeti gösterilir.
  final bool adminReadOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('studio-branded-header'),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            _studioHeaderBrandStart,
            _studioHeaderBrandEnd,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: _studioHeaderBorder),
        boxShadow: _studioHeaderFadeShadow,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Geri',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: _studioHeaderForeground,
            ),
          ),
          const SizedBox(width: 4),
          _HeaderBrandMark(
            key: const ValueKey<String>('studio-brand-mark'),
            size: 46,
            branded: true,
          ),
          const SizedBox(width: 18),
          SizedBox(
            key: const ValueKey<String>('studio-presentation-title'),
            width: 260,
            child: InkWell(
              onTap: onEditFileName,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _studioHeaderControl,
                  border: Border.all(color: _studioHeaderBorder),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        presentationFileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _studioHeaderForeground,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (onEditFileName != null)
                      Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: _studioHeaderMuted,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          if (adminReadOnly) const _AdminReadOnlyBadge(),
          if (adminReadOnly) const SizedBox(width: 8),
          if (!adminReadOnly)
            _HistoryButtons(
              onUndo: onUndo,
              onRedo: onRedo,
              canUndo: canUndo,
              canRedo: canRedo,
              branded: true,
            ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                lastEditorLabel == null || lastEditorLabel!.isEmpty
                    ? 'Kaydedildi'
                    : 'Kaydedildi · $lastEditorLabel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _studioHeaderMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: _studioHeaderMuted,
              ),
            ],
          ),
          const SizedBox(width: 14),
          const _SettingsMenuButton(branded: true, compact: true),
          if (!adminReadOnly) ...<Widget>[
            const SizedBox(width: 8),
            _ToolbarAction(
              icon: Icons.aspect_ratio_rounded,
              onTap: onOpenStageDimensions,
            ),
            const SizedBox(width: 8),
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
          ],
          const SizedBox(width: 8),
          _StudioSaveButton(
            onExportHtml: onExport,
            onExportPdf: onExportPdf,
          ),
          const SizedBox(width: 8),
          _StudioPreviewButton(onTap: onPreview),
        ],
      ),
    );
  }
}

enum _HeaderBrandMenuAction { home, settings, presentations }

class _HeaderBrandMark extends StatelessWidget {
  const _HeaderBrandMark({
    super.key,
    required this.size,
    required this.branded,
    this.showLabel = true,
  });

  final double size;
  final bool branded;
  final bool showLabel;

  void _handleSelection(
    BuildContext context,
    _HeaderBrandMenuAction action,
  ) {
    switch (action) {
      case _HeaderBrandMenuAction.home:
        Navigator.of(context).popUntil((route) => route.isFirst);
      case _HeaderBrandMenuAction.settings:
        showDialog<void>(
          context: context,
          builder: (dialogContext) => const _HeaderSettingsDialog(),
        );
      case _HeaderBrandMenuAction.presentations:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const MyPresentationsPage(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<_HeaderBrandMenuAction>(
      tooltip: 'Sutols menüsü',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      color: colors.surfaceElevated,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      onSelected: (action) => _handleSelection(context, action),
      itemBuilder: (context) => <PopupMenuEntry<_HeaderBrandMenuAction>>[
        PopupMenuItem<_HeaderBrandMenuAction>(
          key: const ValueKey<String>('brand-menu-home'),
          value: _HeaderBrandMenuAction.home,
          child: _HeaderBrandMenuItem(
            icon: Icons.home_outlined,
            label: tr('Ana Sayfa', 'Home'),
          ),
        ),
        PopupMenuItem<_HeaderBrandMenuAction>(
          key: const ValueKey<String>('brand-menu-settings'),
          value: _HeaderBrandMenuAction.settings,
          child: _HeaderBrandMenuItem(
            icon: Icons.settings_outlined,
            label: tr('Ayarlar', 'Settings'),
          ),
        ),
        PopupMenuItem<_HeaderBrandMenuAction>(
          key: const ValueKey<String>('brand-menu-presentations'),
          value: _HeaderBrandMenuAction.presentations,
          child: _HeaderBrandMenuItem(
            icon: Icons.slideshow_outlined,
            label: tr('Sunumlarım', 'My Presentations'),
          ),
        ),
      ],
      child: Semantics(
        key: showLabel ? null : const ValueKey<String>('sutols-wordmark'),
        button: true,
        label: 'Sutols menüsünü aç',
        child: SizedBox(
          height: size,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size * 0.08,
              vertical: size * 0.08,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SutolsBrandLockup(
                  height: size * 0.84,
                  showWordmark: showLabel,
                  color: branded ? _studioHeaderForeground : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBrandMenuItem extends StatelessWidget {
  const _HeaderBrandMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: context._htmlMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context._htmlInk,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _HeaderSettingsDialog extends StatelessWidget {
  const _HeaderSettingsDialog();

  @override
  Widget build(BuildContext context) {
    final langController = LanguageController.instance;
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: langController.currentLanguage,
      builder: (context, currentLang, _) {
        return AlertDialog(
          title: Text(langController.tr('Ayarlar', 'Settings')),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeController.instance.mode,
                  builder: (context, mode, _) {
                    final isDark = mode == ThemeMode.dark;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      ),
                      title: Text(langController.tr('Koyu tema', 'Dark mode')),
                      subtitle: Text(
                        isDark
                            ? langController.tr('Açık', 'On')
                            : langController.tr('Kapalı', 'Off'),
                      ),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ThemeController.instance.toggle(),
                      ),
                      onTap: ThemeController.instance.toggle,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: const Icon(Icons.language_outlined),
                  title: Text(langController.tr('Dil / Language', 'Language')),
                  subtitle: Text(
                    currentLang == AppLanguage.en ? 'English' : 'Türkçe',
                  ),
                  trailing: SegmentedButton<AppLanguage>(
                    segments: const [
                      ButtonSegment<AppLanguage>(
                        value: AppLanguage.tr,
                        label: Text('TR'),
                      ),
                      ButtonSegment<AppLanguage>(
                        value: AppLanguage.en,
                        label: Text('EN'),
                      ),
                    ],
                    selected: {currentLang},
                    onSelectionChanged: (Set<AppLanguage> selected) {
                      if (selected.isNotEmpty) {
                        langController.setLanguage(selected.first);
                      }
                    },
                  ),
                ),
                if (langController.detectedLocationInfo != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            langController.tr(
                              'Konum: ${langController.detectedLocationInfo}',
                              'Location: ${langController.detectedLocationInfo}',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(langController.tr('Kapat', 'Close')),
            ),
          ],
        );
      },
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
        color: _studioHeaderControl,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _studioHeaderBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: _studioHeaderForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _studioHeaderForeground,
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
      color: _studioHeaderForeground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.slideshow_rounded,
                color: _studioHeaderBrandEnd,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Sunum Modu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _studioHeaderBrandEnd,
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

class _StudioSaveButton extends StatelessWidget {
  const _StudioSaveButton({
    required this.onExportHtml,
    required this.onExportPdf,
  });

  final VoidCallback onExportHtml;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_FileMenuAction>(
      key: const ValueKey<String>('studio-save-button'),
      tooltip: 'Kaydet',
      onSelected: (action) {
        switch (action) {
          case _FileMenuAction.exportHtml:
            onExportHtml();
            break;
          case _FileMenuAction.exportPdf:
            onExportPdf();
            break;
          case _FileMenuAction.save:
          case _FileMenuAction.load:
            break;
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<_FileMenuAction>>[
        PopupMenuItem<_FileMenuAction>(
          key: ValueKey<String>('save-as-html'),
          value: _FileMenuAction.exportHtml,
          child: ListTile(
            leading: Icon(Icons.html_rounded),
            title: Text('HTML formatı'),
          ),
        ),
        PopupMenuItem<_FileMenuAction>(
          key: ValueKey<String>('save-as-pdf'),
          value: _FileMenuAction.exportPdf,
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_rounded),
            title: Text('PDF formatı (animasyonlar çalışmaz)'),
          ),
        ),
      ],
      child: Material(
        color: _studioHeaderControl,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.save_alt_rounded,
                color: _studioHeaderForeground,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Kaydet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _studioHeaderForeground,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _studioHeaderForeground,
                size: 18,
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
    required this.panelOpen,
    required this.onTabChanged,
    this.adminReadOnly = false,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;

  /// Detay paneli açık mı? (Kapalıyken tuval tüm genişliği kullanır.)
  final bool panelOpen;
  final ValueChanged<_HtmlToolTab> onTabChanged;

  /// Salt okunur (admin) mod: ikon şeridi ve detay paneli gizlenir,
  /// tuval tam genişlikte salt okunur gösterilir.
  final bool adminReadOnly;

  @override
  Widget build(BuildContext context) {
    if (adminReadOnly) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _HtmlStageWorkspace(
              controller: controller,
              textController: textController,
              activeTab: activeTab,
              readOnly: true,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: 244,
          child: _HtmlPageSidebar(controller: controller),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: _HtmlStageWorkspace(
                  controller: controller,
                  textController: textController,
                  activeTab: activeTab,
                  showFilmstrip: false,
                ),
              ),
              const SizedBox(height: 8),
              _HtmlToolRail(
                activeTab: activeTab,
                onTabChanged: onTabChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.ease,
            alignment: Alignment.centerRight,
            child: panelOpen
                ? SizedBox(
                    width: 292,
                    child: _HtmlInspectorPanel(
                      controller: controller,
                      textController: textController,
                      activeTab: activeTab,
                    ),
                  )
                : const SizedBox(width: 0, height: double.infinity),
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
  });

  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('studio-tool-rail'),
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _RailButton(
              label: tr('Şablon', 'Template'),
              icon: Icons.dashboard_customize_rounded,
              isSelected: activeTab == _HtmlToolTab.templates,
              onTap: () => onTabChanged(_HtmlToolTab.templates),
            ),
            const SizedBox(width: 8),
            _RailButton(
              label: tr('Arka Plan', 'Background'),
              icon: Icons.wallpaper_rounded,
              isSelected: activeTab == _HtmlToolTab.backgrounds,
              onTap: () => onTabChanged(_HtmlToolTab.backgrounds),
            ),
            const SizedBox(width: 8),
            _RailButton(
              label: tr('Bileşen', 'Component'),
              icon: Icons.widgets_rounded,
              isSelected: activeTab == _HtmlToolTab.components,
              onTap: () => onTabChanged(_HtmlToolTab.components),
            ),
            const SizedBox(width: 8),
            _RailButton(
              label: tr('Metin', 'Text'),
              icon: Icons.text_fields_rounded,
              isSelected: activeTab == _HtmlToolTab.text,
              onTap: () => onTabChanged(_HtmlToolTab.text),
            ),
            const SizedBox(width: 8),
            _RailButton(
              label: tr('3D Modeller', '3D Models'),
              icon: Icons.view_in_ar_rounded,
              isSelected: activeTab == _HtmlToolTab.models3d,
              onTap: () => onTabChanged(_HtmlToolTab.models3d),
            ),
            const SizedBox(width: 8),
            _RailButton(
              label: tr('Fotoğraf', 'Photo'),
              icon: Icons.add_photo_alternate_rounded,
              isSelected: activeTab == _HtmlToolTab.photo,
              onTap: () => onTabChanged(_HtmlToolTab.photo),
            ),
            const SizedBox(width: 8),
            _RailButton(
              label: tr('Geçişler', 'Transitions'),
              icon: Icons.animation_rounded,
              isSelected: activeTab == _HtmlToolTab.transitions,
              onTap: () => onTabChanged(_HtmlToolTab.transitions),
            ),
            const SizedBox(width: 8),
            _RailButton(
              label: tr('Sahne Ölçüsü', 'Canvas Size'),
              icon: Icons.aspect_ratio_rounded,
              isSelected: activeTab == _HtmlToolTab.stageDimensions,
              onTap: () => onTabChanged(_HtmlToolTab.stageDimensions),
            ),
          ],
        ),
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
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? (isDark
            ? context.colors.primary.withValues(alpha: 0.18)
            : const Color(0xFFEAF7F7))
        : Colors.transparent;
    final borderColor = isSelected
        ? (isDark
            ? context.colors.primary.withValues(alpha: 0.5)
            : const Color(0xFFB9E1E3))
        : Colors.transparent;
    final effectiveIconColor = isSelected
        ? context._htmlAccent
        : (isDark ? context.colors.textSecondary : context._htmlMuted);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 94,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, color: effectiveIconColor, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? (isDark ? context.colors.textPrimary : context._htmlInk)
                          : (isDark ? context.colors.textSecondary : context._htmlMuted),
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w700,
                      fontSize: 10.5,
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
      key: const ValueKey<String>('studio-inspector-panel'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                _htmlToolIcon(activeTab),
                size: 20,
                color: context._htmlAccent,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _studioPanelTitle(activeTab),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: activeTab == _HtmlToolTab.text
                ? SingleChildScrollView(
                    child: _HtmlTextControls(
                      controller: controller,
                      textController: textController,
                    ),
                  )
                : activeTab == _HtmlToolTab.components
                    ? _HtmlComponentControls(
                        controller: controller,
                        expandResults: true,
                      )
                    : activeTab == _HtmlToolTab.models3d
                        ? _Html3DModelControls(
                            controller: controller,
                            expandResults: true,
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

class _HtmlStageWorkspace extends StatelessWidget {
  const _HtmlStageWorkspace({
    required this.controller,
    required this.textController,
    required this.activeTab,
    this.readOnly = false,
    this.showFilmstrip = true,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;

  /// Salt okunur (admin) mod: bağlamsal araç çubuğu gizlenir, tuval
  /// etkileşimsiz olur ve filmşeritte sayfa ekle/sil kapatılır.
  final bool readOnly;
  final bool showFilmstrip;

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
                if (!readOnly)
                  _SelectionContextBarSection(
                    controller: controller,
                    textController: textController,
                  ),
                Expanded(
                  child: _HtmlStageCard(
                    controller: controller,
                    readOnly: readOnly,
                  ),
                ),
                if (showFilmstrip) ...<Widget>[
                  const SizedBox(height: 14),
                  _HtmlPageFilmstrip(
                    controller: controller,
                    readOnly: readOnly,
                  ),
                ],
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
    this.readOnly = false,
  });

  final PresentationController controller;

  /// Salt okunur (admin) mod: sayfa ekle/sil butonları gizlenir.
  final bool readOnly;

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
          if (!readOnly)
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
          if (!readOnly) const SizedBox(width: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 148,
      child: Material(
        color: isSelected
            ? (isDark
                ? context.colors.primary.withValues(alpha: 0.18)
                : const Color(0xFFEEF5FF))
            : (isDark ? context.colors.surfaceElevated : Colors.white),
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
                color: isSelected
                    ? context._htmlAccent
                    : context.sutolColors.outline,
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
    this.readOnly = false,
  });

  final PresentationController controller;

  /// Salt okunur (admin) mod: sayfa ekle/sil butonları gizlenir.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        if (!readOnly) {
          _showPageContextMenu(
            context,
            details.globalPosition,
            controller,
            controller.selectedIndex,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Sahneler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context._htmlInk,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Icon(Icons.sort_rounded, size: 20, color: context._htmlMuted),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: animation.value * 6,
                    color: Colors.transparent,
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) => Transform.scale(
                        scale: 1.0 + animation.value * 0.05,
                        child: child,
                      ),
                    ),
                  );
                },
                itemCount: controller.pages.length,
                onReorder: (oldIndex, newIndex) {
                  controller.reorderPage(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return KeyedSubtree(
                    key: ValueKey<String>('reorder-page-${page.id}'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ReorderableDelayedDragStartListener(
                          index: index,
                          enabled: !readOnly,
                          child: _HtmlPageCard(
                            page: page,
                            index: index,
                            isSelected: index == controller.selectedIndex,
                            onTap: () => controller.selectPage(index),
                            controller: controller,
                            readOnly: readOnly,
                          ),
                        ),
                        _SlideInsertButton(
                          onPressed: () => controller.addPageAfter(index),
                          readOnly: readOnly,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!readOnly) ...<Widget>[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.addPage,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Yeni sahne'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: controller.canRemovePage
                    ? controller.removeSelectedPage
                    : null,
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                label: const Text('Seçili sahneyi sil'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlideInsertButton extends StatefulWidget {
  const _SlideInsertButton({
    required this.onPressed,
    this.readOnly = false,
  });

  final VoidCallback onPressed;
  final bool readOnly;

  @override
  State<_SlideInsertButton> createState() => _SlideInsertButtonState();
}

class _SlideInsertButtonState extends State<_SlideInsertButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) return const SizedBox(height: 6);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: _isHovered ? 2 : 1,
                color: _isHovered
                    ? context._htmlAccent
                    : Colors.black.withValues(alpha: 0.08),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: _isHovered ? 10 : 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? context._htmlAccent
                      : (Theme.of(context).brightness == Brightness.dark
                          ? context.colors.surfaceElevated
                          : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered
                        ? context._htmlAccent
                        : context.sutolColors.outline.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  boxShadow: _isHovered
                      ? <BoxShadow>[
                          BoxShadow(
                            color: context._htmlAccent.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: _isHovered ? Colors.white : context._htmlInk,
                    ),
                    if (_isHovered) ...<Widget>[
                      const SizedBox(width: 4),
                      const Text(
                        'Slayt Ekle',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPageContextMenu(
  BuildContext context,
  Offset globalPosition,
  PresentationController controller,
  int index,
) {
  final RenderBox? overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;

  showMenu<String>(
    context: context,
    position: RelativeRect.fromRect(
      globalPosition & const Size(1, 1),
      Offset.zero & overlay.size,
    ),
    items: <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: 'add',
        child: Row(
          children: const <Widget>[
            Icon(Icons.add_circle_outline_rounded, size: 18),
            SizedBox(width: 10),
            Text('Araya Yeni Slayt Ekle'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'duplicate',
        child: Row(
          children: const <Widget>[
            Icon(Icons.content_copy_rounded, size: 18),
            SizedBox(width: 10),
            Text('Slaytı Çoğalt'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'move_up',
        enabled: index > 0,
        child: Row(
          children: const <Widget>[
            Icon(Icons.arrow_upward_rounded, size: 18),
            SizedBox(width: 10),
            Text('Yukarı Taşı'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'move_down',
        enabled: index < controller.pages.length - 1,
        child: Row(
          children: const <Widget>[
            Icon(Icons.arrow_downward_rounded, size: 18),
            SizedBox(width: 10),
            Text('Aşağı Taşı'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'delete',
        enabled: controller.canRemovePage,
        child: Row(
          children: const <Widget>[
            Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Slaytı Sil', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    ],
  ).then((value) {
    if (value == null) return;
    switch (value) {
      case 'add':
        controller.addPageAfter(index);
        break;
      case 'duplicate':
        controller.duplicatePage(index);
        break;
      case 'move_up':
        controller.movePageUp(index);
        break;
      case 'move_down':
        controller.movePageDown(index);
        break;
      case 'delete':
        controller.removePageAt(index);
        break;
    }
  });
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
      color: subtle
          ? context.sutolColors.surfaceSubtle
          : context.sutolColors.surfaceTinted,
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
    required this.controller,
    this.readOnly = false,
  });

  final PresentationPage page;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final PresentationController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (details) {
        if (!readOnly) {
          _showPageContextMenu(
            context,
            details.globalPosition,
            controller,
            index,
          );
        }
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                    ? context.colors.primary.withValues(alpha: 0.18)
                    : const Color(0xFFEAF7F7))
                : (Theme.of(context).brightness == Brightness.dark
                    ? context.colors.surface
                    : const Color(0xFFF8FAFD)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected ? context._htmlAccent : context.sutolColors.outline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!readOnly)
                        ReorderableDragStartListener(
                          index: index,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.drag_handle_rounded,
                                size: 18,
                                color: context._htmlMuted,
                              ),
                            ),
                          ),
                        ),
                      Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context._htmlInk,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  if (!readOnly)
                    InkWell(
                      onTapDown: (details) => _showPageContextMenu(
                        context,
                        details.globalPosition,
                        controller,
                        index,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: context._htmlMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
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
    this.readOnly = false,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onTabChanged;

  /// Salt okunur (admin) mod: sekmeli araç çubuğu ve bağlamsal bar gizlenir,
  /// tuval salt okunur gösterilir.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final stage = _HtmlStageCard(
      controller: controller,
      readOnly: readOnly,
    );
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
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          if (!readOnly) ...<Widget>[
            _HtmlTopToolbar(
              controller: controller,
              textController: textController,
              activeTab: activeTab,
              onTabChanged: onTabChanged,
            ),
            const SizedBox(height: 12),
            _SelectionContextBarSection(
              controller: controller,
              textController: textController,
            ),
          ],
          Expanded(child: stage),
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
                // Kontrol listeleri (örn. şablonlar) çok uzun olabilir;
                // yüksekliği sınırlayıp dikey kaydırılabilir yap.
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(child: controls),
                  ),
                ),
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
              // Dar ekranda kontrol paneli tuvali ezdirmemeli: sınırlı
              // yükseklik + dikey kaydırma.
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(child: controls),
              ),
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
              label: tr('Şablonlar', 'Templates'),
              icon: Icons.dashboard_customize_rounded,
              isSelected: activeTab == _HtmlToolTab.templates,
              onTap: () => onTabChanged(_HtmlToolTab.templates),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: tr('Arka Planlar', 'Backgrounds'),
              icon: Icons.wallpaper_rounded,
              isSelected: activeTab == _HtmlToolTab.backgrounds,
              onTap: () => onTabChanged(_HtmlToolTab.backgrounds),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: tr('Bilesenler', 'Components'),
              icon: Icons.widgets_rounded,
              isSelected: activeTab == _HtmlToolTab.components,
              onTap: () => onTabChanged(_HtmlToolTab.components),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: tr('Metin', 'Text'),
              icon: Icons.text_fields_rounded,
              isSelected: activeTab == _HtmlToolTab.text,
              onTap: () => onTabChanged(_HtmlToolTab.text),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: tr('3D Modeller', '3D Models'),
              icon: Icons.view_in_ar_rounded,
              isSelected: activeTab == _HtmlToolTab.models3d,
              onTap: () => onTabChanged(_HtmlToolTab.models3d),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: tr('Fotoğraf', 'Photos'),
              icon: Icons.add_photo_alternate_rounded,
              isSelected: activeTab == _HtmlToolTab.photo,
              onTap: () => onTabChanged(_HtmlToolTab.photo),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: tr('Geçişler', 'Transitions'),
              icon: Icons.animation_rounded,
              isSelected: activeTab == _HtmlToolTab.transitions,
              onTap: () => onTabChanged(_HtmlToolTab.transitions),
            ),
            const SizedBox(width: 6),
            _HtmlTabButton(
              label: tr('Sahne Ölçüsü', 'Canvas Size'),
              icon: Icons.aspect_ratio_rounded,
              isSelected: activeTab == _HtmlToolTab.stageDimensions,
              onTap: () => onTabChanged(_HtmlToolTab.stageDimensions),
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
    this.isExpanded = false,
    this.scrollController,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;
  final bool isExpanded;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case _HtmlToolTab.templates:
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          child: _HtmlTemplateControls(controller: controller),
        );
      case _HtmlToolTab.backgrounds:
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          child: _HtmlBackgroundControls(controller: controller),
        );
      case _HtmlToolTab.components:
        return _HtmlComponentControls(
          controller: controller,
          isExpanded: isExpanded,
          scrollController: scrollController,
        );
      case _HtmlToolTab.text:
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: _HtmlTextControls(
            controller: controller,
            textController: textController,
          ),
        );
      case _HtmlToolTab.models3d:
        return _Html3DModelControls(
          controller: controller,
          isExpanded: isExpanded,
          scrollController: scrollController,
        );
      case _HtmlToolTab.photo:
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          child: _HtmlPhotoControls(controller: controller),
        );
      case _HtmlToolTab.transitions:
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: _HtmlTransitionControls(
            controller: controller,
          ),
        );
      case _HtmlToolTab.stageDimensions:
        return _HtmlStageDimensionsControls(
          controller: controller,
          isExpanded: isExpanded,
          scrollController: scrollController,
        );
    }
  }
}

class _Html3DModelControls extends StatefulWidget {
  const _Html3DModelControls({
    required this.controller,
    this.expandResults = false,
    this.isExpanded = false,
    this.scrollController,
  });

  final PresentationController controller;
  final bool expandResults;
  final bool isExpanded;
  final ScrollController? scrollController;

  @override
  State<_Html3DModelControls> createState() => _Html3DModelControlsState();
}

class _Html3DModelControlsState extends State<_Html3DModelControls> {
  final TextEditingController _searchController = TextEditingController();
  List<ModelCatalogEntry> _models = const <ModelCatalogEntry>[];
  bool _loading = true;
  String? _error;
  String _query = '';
  String _category = '';
  String _userTier = 'free';

  static int _tierRank(String tier) => switch (tier) {
        'plus' || 'premium' || 'pro' => 1,
        _ => 0,
      };

  bool _isLocked(ModelCatalogEntry model) =>
      _tierRank(_userTier) < _tierRank(model.tier);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Kullanıcının planını best-effort oku; hata olsa bile model yükleme
      // akışını bozmamalı (kilit kontrolü "free" varsayımıyla çalışır).
      var userTier = 'free';
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          final userDoc = await FirestoreRestHelper.getDocument('users/$uid');
          final userFields = userDoc?['fields'] as Map<String, dynamic>? ?? {};
          final tier = FirestoreRestHelper.stringField(userFields, 'tier');
          if (tier.isNotEmpty) userTier = tier;
        } catch (_) {
          // Best-effort: tier okunamadıysa "free" varsayılır.
        }
      }

      // Katalog uygulama oturumu boyunca repository'de tutulur. Arama,
      // kategori filtresi ve sıralama bu bellek içi liste üzerinde yapılır.
      final models = await ModelRepository.instance.getModels();
      if (!mounted) return;
      setState(() {
        _models = models;
        _userTier = userTier;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Modeller yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  List<ModelCatalogEntry> get _filtered {
    final query = _query.trim().toLowerCase();
    return _models.where((model) {
      if (_category.isNotEmpty && model.category != _category) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return model.name.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Future<void> _add(ModelCatalogEntry model) async {
    if (_isLocked(model)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu model planınızda dahil değil'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Yetkili imzalı URL edin; yetki verilemezse bloğu ekleme.
    final signedUrl = await ModelAssetService.generateSignedUrl(model.modelUrl);
    if (signedUrl == null || signedUrl.isEmpty || !signedUrl.contains('token=')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model yetkilendirmesi başarısız oldu. Lütfen tekrar deneyin.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    RemoteModelSources.registerAll(<String, String>{model.id: signedUrl});
    widget.controller.add3DModelBlock(
      Presentation3DModelAsset(
        id: model.id,
        label: model.name,
        assetPath: signedUrl,
        category: model.category.isEmpty ? '3B Model' : model.category,
        tags: model.tags,
        byteSize: 0,
        sha256: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedModelId =
        widget.controller.selectedComponentBlock?.modelAssetId;
    final filtered = _filtered;
    const categories = <(String, String)>[
      ('', 'Tümü'),
      ('analiz-modeli', 'Analiz Modeli'),
      ('grafik', 'Grafik'),
      ('diyagram', 'Diyagram'),
      ('sembol', 'Sembol'),
      ('ikon-3d', 'İkon 3D'),
      ('diger', 'Diğer'),
    ];

    final isExpandedMode = widget.expandResults || widget.isExpanded;

    return Container(
      key: const ValueKey<String>('model-library-panel'),
      width: double.infinity,
      height: double.infinity,
      padding: isExpandedMode ? const EdgeInsets.all(14) : const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.sutolColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ModelSearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final (value, label) in categories) ...<Widget>[
                  SutolChip(
                    label: label,
                    isSelected: _category == value,
                    onTap: () => setState(() => _category = value),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          if (isExpandedMode) ...<Widget>[
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Text(
                  _loading
                      ? 'Yükleniyor...'
                      : '${filtered.length} model${_query.isNotEmpty ? ' bulundu' : ''}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context._htmlMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Yenile',
                  iconSize: 18,
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Expanded(
            child: KeyedSubtree(
              key: const ValueKey<String>('model-library-results'),
              child: _buildBody(context, filtered, selectedModelId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<ModelCatalogEntry> filtered,
    String? selectedModelId,
  ) {
    if (_loading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = _gridColumns(constraints.maxWidth);
          final cellWidth =
              (constraints.maxWidth - (columns - 1) * 10) / columns;
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            shrinkWrap: !widget.expandResults && !widget.isExpanded,
            physics: const ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: cellWidth + 28,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AspectRatio(
                    aspectRatio: 1,
                    child: SutolShimmer(borderRadius: 12),
                  ),
                  const SizedBox(height: 6),
                  SutolShimmer(height: 10, borderRadius: 4),
                ],
              );
            },
          );
        },
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.cloud_off_rounded,
                  color: context._htmlMuted, size: 28),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context._htmlMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Icon(Icons.search_off_rounded, color: context._htmlMuted, size: 28),
            const SizedBox(height: 8),
            Text(
              _query.isEmpty && _category.isEmpty
                  ? 'Bulutta model bulunamadı.'
                  : 'Bu filtrelerle model bulunamadı.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context._htmlMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    // Kompakt mod: Sağa doğru kaydırılabilir yatay liste
    if (!widget.expandResults && !widget.isExpanded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : 148.0;
          final height = maxH.clamp(60.0, 148.0);
          return SizedBox(
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final model = filtered[index];
                return Container(
                  width: (height * 0.75).clamp(80.0, 110.0),
                  margin: const EdgeInsets.only(right: 10),
                  child: _Model3DLibraryCard(
                    model: Presentation3DModelAsset(
                      id: model.id,
                      label: model.name,
                      assetPath: model.modelUrl,
                      category: model.category.isEmpty ? '3B Model' : model.category,
                      tags: model.tags,
                      byteSize: 0,
                      sha256: '',
                    ),
                    thumbnailUrl: ModelAssetService.thumbnailKey(
                      thumbnailField: model.thumbnailUrl,
                      modelId: model.id,
                    ),
                    isSelected: selectedModelId == model.id,
                    locked: _isLocked(model),
                    onTap: () => _add(model),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    // Uzatılmış mod: Dikeyde aşağı kaydırılabilir ızgara
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _gridColumns(constraints.maxWidth);
        final cellWidth = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return GridView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(bottom: 8),
          shrinkWrap: !widget.expandResults && !widget.isExpanded,
          physics: widget.scrollController != null
              ? const AlwaysScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: cellWidth + 28,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final model = filtered[index];
            return _Model3DLibraryCard(
              model: Presentation3DModelAsset(
                id: model.id,
                label: model.name,
                assetPath: model.modelUrl,
                category: model.category.isEmpty ? '3B Model' : model.category,
                tags: model.tags,
                byteSize: 0,
                sha256: '',
              ),
              thumbnailUrl: ModelAssetService.thumbnailKey(
                thumbnailField: model.thumbnailUrl,
                modelId: model.id,
              ),
              isSelected: selectedModelId == model.id,
              locked: _isLocked(model),
              onTap: () => _add(model),
            );
          },
        );
      },
    );
  }

  static int _gridColumns(double width) {
    if (width >= 560) return 4;
    if (width >= 400) return 3;
    return 2;
  }
}

class _ModelSearchField extends StatelessWidget {
  const _ModelSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Model ara: isim, etiket, kategori...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search_rounded, size: 18, color: context._htmlMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w600,
                  ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context._htmlMuted,
                      fontWeight: FontWeight.w500,
                    ),
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Temizle',
              iconSize: 16,
              visualDensity: VisualDensity.compact,
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
    );
  }
}

/// Cihazdan bir fotoğraf seçer, kaynaklara kaydeder, slayta blok olarak ekler
/// ve yüklenen fotoğraf kaydını döner. Seçim iptal edilirse `null` döner.
Future<_UploadedPhotoEntry?> pickLocalPhotoIntoController(
  PresentationController controller,
) async {
  final picked = await pickLocalImage();
  if (picked == null) return null;
  final sourceId = 'photo-${DateTime.now().millisecondsSinceEpoch}';
  RemoteImageSources.register(sourceId, picked.dataUrl);
  controller.addUploadedImageBlock(
    sourceId,
    aspectRatio: picked.aspectRatio,
  );
  return _UploadedPhotoEntry(
    id: sourceId,
    name: picked.name,
    dataUrl: picked.dataUrl,
    sizeBytes: picked.sizeBytes,
    aspectRatio: picked.aspectRatio,
  );
}

class _HtmlPhotoControls extends StatefulWidget {
  const _HtmlPhotoControls({required this.controller});

  final PresentationController controller;

  @override
  State<_HtmlPhotoControls> createState() => _HtmlPhotoControlsState();
}

class _HtmlPhotoControlsState extends State<_HtmlPhotoControls> {
  final List<_UploadedPhotoEntry> _photos = <_UploadedPhotoEntry>[];
  bool _picking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    RemoteImageSources.all.forEach((id, dataUrl) {
      _photos.add(
        _UploadedPhotoEntry(id: id, dataUrl: dataUrl, name: id),
      );
    });
  }

  Future<void> _pickPhoto() async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final entry = await pickLocalPhotoIntoController(widget.controller);
      if (entry == null) return;
      if (!mounted) return;
      setState(() => _photos.add(entry));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _removePhoto(_UploadedPhotoEntry photo) {
    RemoteImageSources.remove(photo.id);
    setState(() {
      _photos.removeWhere((entry) => entry.id == photo.id);
      if (_error != null && !_photos.any((e) => e.id == photo.id)) {
        _error = null;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.sutolColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.sutolColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ToolbarBadge(
                icon: Icons.add_photo_alternate_rounded,
                label: 'Fotoğraf Yükle',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _picking ? null : _pickPhoto,
                icon: _picking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.upload_rounded,
                        size: 18,
                        color: context._htmlAccent,
                      ),
                label: Text(
                    _picking ? 'Yükleniyor...' : 'Cihazdan Fotoğraf Yükle'),
              ),
              const SizedBox(height: 8),
              Text(
                'PNG, JPG, WebP, GIF. En fazla 6 MB.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context._htmlMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context._htmlAccent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ToolbarBadge(
          icon: Icons.photo_library_rounded,
          label: 'Yüklenen Fotoğraflar (${_photos.length})',
        ),
        const SizedBox(height: 10),
        if (_photos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Henüz fotoğraf yüklemedin. Bir fotoğraf seç, otomatik olarak slayta eklenir.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context._htmlMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          )
        else
          for (final photo in _photos)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _UploadedPhotoCard(
                photo: photo,
                onAdd: () => widget.controller.addUploadedImageBlock(
                  photo.id,
                  aspectRatio: photo.aspectRatio,
                ),
                onRemove: () => _removePhoto(photo),
              ),
            ),
      ],
    );
  }
}

class _UploadedPhotoEntry {
  const _UploadedPhotoEntry({
    required this.id,
    required this.name,
    required this.dataUrl,
    this.sizeBytes = 0,
    this.aspectRatio = 16 / 9,
  });

  final String id;
  final String name;
  final String dataUrl;
  final int sizeBytes;
  final double aspectRatio;
}

class _UploadedPhotoCard extends StatelessWidget {
  const _UploadedPhotoCard({
    required this.photo,
    required this.onAdd,
    required this.onRemove,
  });

  final _UploadedPhotoEntry photo;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.sutolColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              photo.dataUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (errorContext, error, stackTrace) => Container(
                width: 56,
                height: 56,
                color: context.sutolColors.surfaceSubtle,
                child: const Icon(Icons.image_not_supported_rounded),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  photo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  photo.sizeBytes > 0
                      ? '${(photo.sizeBytes / 1024).toStringAsFixed(0)} KB'
                      : 'Oturum fotografı',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context._htmlMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Slayta Ekle',
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          IconButton(
            tooltip: 'Kaldır',
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline_rounded),
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
    final effectSettings = controller.effectSettings;
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

  List<Color> _iconGradientColors(BuildContext context) {
    if (isSelected) {
      return const <Color>[Color(0xFF0F172A), Color(0xFF1E293B)];
    }
    switch (kind) {
      case PresentationTransitionKind.none:
        return const <Color>[Color(0xFF64748B), Color(0xFF475569)];
      case PresentationTransitionKind.cube3d:
      case PresentationTransitionKind.rotateZoom:
      case PresentationTransitionKind.flip:
      case PresentationTransitionKind.convex:
      case PresentationTransitionKind.concave:
        return const <Color>[Color(0xFF1E1B4B), Color(0xFF312E81)];
      case PresentationTransitionKind.morph:
      case PresentationTransitionKind.smooth:
      case PresentationTransitionKind.fade:
      case PresentationTransitionKind.zoom:
        return const <Color>[Color(0xFF0F172A), Color(0xFF2563EB)];
      default:
        return const <Color>[Color(0xFF1E293B), Color(0xFF334155)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: _iconGradientColors(context),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isSelected
          ? (isDark
              ? context.colors.primary.withValues(alpha: 0.18)
              : const Color(0xFFF0F6FF))
          : (isDark ? context.colors.surfaceElevated : Colors.white),
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 2 : 0,
      shadowColor: context._htmlAccent.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? context._htmlAccent
                  : context.sutolColors.outline.withValues(alpha: 0.7),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: gradient,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  presentationTransitionIcon(kind),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      presentationTransitionLabel(kind),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                    ),
                    if (MediaQuery.sizeOf(context).width >= 480) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        presentationTransitionSubtitle(kind),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context._htmlMuted,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? context._htmlAccent : context._htmlMuted,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Model3DLibraryCard extends StatefulWidget {
  const _Model3DLibraryCard({
    required this.model,
    required this.thumbnailUrl,
    required this.isSelected,
    required this.locked,
    required this.onTap,
  });

  final Presentation3DModelAsset model;
  final String thumbnailUrl;
  final bool isSelected;
  final bool locked;
  final VoidCallback onTap;

  @override
  State<_Model3DLibraryCard> createState() => _Model3DLibraryCardState();
}

class _Model3DLibraryCardState extends State<_Model3DLibraryCard> {
  bool _hovered = false;

  static const List<Color> _fallbackPalette = <Color>[
    Color(0xFF1565C0),
    Color(0xFF00897B),
    Color(0xFF6A1B9A),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
  ];

  Color _fallbackColor() {
    final hue = widget.model.label.hashCode & 0x7FFFFFFF;
    return _fallbackPalette[hue % _fallbackPalette.length];
  }

  /// Thumbnail yüklenemezse model adının ilk harfini renkli kutuda gösterir.
  Widget _letterBox(BuildContext context) {
    final color = _fallbackColor();
    final label = widget.model.label.trim();
    return Container(
      color: color.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: Text(
        label.isNotEmpty ? label.characters.first.toUpperCase() : '?',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _thumbnail(BuildContext context) {
    final key = ModelAssetService.thumbnailKey(
      thumbnailField: widget.thumbnailUrl,
      modelId: widget.model.id,
    );

    if (key.isEmpty) {
      return _letterBox(context);
    }
    return SignedThumbnailImage(
      assetKey: key,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? SutolDarkColors.surfaceSubtle
            : SutolLightColors.surfaceSubtle,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorBuilder: (context) => _letterBox(context),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.045 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: context.sutolColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? context.sutolColors.primary
                  : context.sutolColors.outline,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: _hovered ? SutolElevation.md : SutolElevation.none,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        _thumbnail(context),
                        if (widget.isSelected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (widget.locked)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Tooltip(
                    message: widget.model.label,
                    waitDuration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        widget.model.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: widget.locked
                                  ? context._htmlMuted
                                  : context._htmlInk,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
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
          'Şablon seçimi tüm slaytlara uygulanır. Metinleriniz, bileşenleriniz ve animasyonlarınız korunur.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context._htmlMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        // === TEMPLATES COLLECTION (templates/{templateId}) ===
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'KOLEKSİYON ŞABLONLARI',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context._htmlAccent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
          ),
        ),
        for (final sutolTemplate in sutolTemplateCatalog) ...<Widget>[
          _SutolCollectionTemplateCard(
            template: sutolTemplate,
            isSelected: controller.pages.isNotEmpty &&
                controller.pages.every(
                  (page) => page.templateId == sutolTemplate.id,
                ),
            onTap: () {
              controller.applySutolTemplate(sutolTemplate);
            },
          ),
          const SizedBox(height: 10),
        ],

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'STİL PRESETLERİ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context._htmlMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
          ),
        ),
        for (final template in templates) ...<Widget>[
          _TemplatePresetCard(
            template: template,
            isSelected: controller.pages.every(
              (page) =>
                  page.backgroundKind ==
                  presentationTemplateBackground(template),
            ),
            onTap: () {
              controller.applyTemplate(template);
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SutolCollectionTemplateCard extends StatelessWidget {
  const _SutolCollectionTemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final SutolTemplateModel template;
  final bool isSelected;
  final VoidCallback onTap;

  Color _parseHexColor(String hex) {
    final clean = hex.replaceAll('#', '');
    final val = int.tryParse(clean, radix: 16) ?? 0xFF000000;
    return Color(0xFF000000 | val);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isSelected
          ? (isDark
              ? context.colors.primary.withValues(alpha: 0.18)
              : const Color(0xFFF0F6FF))
          : context.sutolColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? context._htmlAccent
                  : context.sutolColors.outline,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context._htmlAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      template.category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context._htmlAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  for (final hex in template.colorPalette) ...<Widget>[
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: _parseHexColor(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black12,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${template.fontPair['heading']} + ${template.fontPair['body']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context._htmlMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context._htmlMuted,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isSelected
          ? (isDark
              ? context.colors.primary.withValues(alpha: 0.18)
              : const Color(0xFFF0F6FF))
          : context.sutolColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? context._htmlAccent
                  : context.sutolColors.outline,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 112,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _StaticTemplateThumbnail(
                      key: ValueKey<String>(
                        'template-preview-${template.name}',
                      ),
                      template: template,
                    ),
                  ),
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
                    // Dar ekranlarda (telefon) açıklamayı gizle: mobil kartlar
                    // öncelikle küçük ve okunaklı olmalı.
                    if (MediaQuery.sizeOf(context).width >= 480) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        presentationTemplateDescription(template),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context._htmlMuted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
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

/// Lightweight, non-animated template thumbnail.
///
/// Template lists previously instantiated one HTML iframe per card. This
/// Flutter-only snapshot preserves the template's palette and visual identity
/// without loading background scripts, animations or full slide documents.
class _StaticTemplateThumbnail extends StatelessWidget {
  const _StaticTemplateThumbnail({
    super.key,
    required this.template,
  });

  final PresentationTemplate template;

  @override
  Widget build(BuildContext context) {
    final backgroundKind = presentationTemplateBackground(template) ??
        PresentationBackgroundKind.science;
    final colors = presentationBackgroundPreviewColors(backgroundKind);
    final isDark = presentationBackgroundIsDark(backgroundKind);
    final foreground = isDark ? Colors.white : const Color(0xFF172033);
    final muted = foreground.withValues(alpha: 0.58);
    final accent = colors.last;

    return Semantics(
      image: true,
      label: '${presentationTemplateLabel(template)} şablon önizlemesi',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomPaint(
          painter: _StaticTemplateThumbnailPainter(
            lineColor: foreground.withValues(alpha: isDark ? 0.09 : 0.11),
            accentColor: accent.withValues(alpha: isDark ? 0.34 : 0.24),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                left: 10,
                top: 10,
                right: 42,
                child: Text(
                  'Yeni Bir\nBakış',
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TemplateThumbnailLine(color: muted, width: 42),
                    const SizedBox(height: 3),
                    _TemplateThumbnailLine(color: muted, width: 30),
                  ],
                ),
              ),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: foreground.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    presentationBackgroundIcon(backgroundKind),
                    size: 14,
                    color: foreground.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateThumbnailLine extends StatelessWidget {
  const _TemplateThumbnailLine({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _StaticTemplateThumbnailPainter extends CustomPainter {
  const _StaticTemplateThumbnailPainter({
    required this.lineColor,
    required this.accentColor,
  });

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.7;
    for (var x = size.width / 6; x < size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = size.height / 4; y < size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.68),
      size.height * 0.23,
      accentPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.93, size.height * 0.37),
      size.height * 0.15,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StaticTemplateThumbnailPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor ||
        accentColor != oldDelegate.accentColor;
  }
}

class _HtmlBackgroundControls extends StatefulWidget {
  const _HtmlBackgroundControls({
    required this.controller,
  });

  final PresentationController controller;

  @override
  State<_HtmlBackgroundControls> createState() =>
      _HtmlBackgroundControlsState();
}

class _HtmlBackgroundControlsState extends State<_HtmlBackgroundControls> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  bool _matches(
    PresentationBackgroundDefinition definition,
    String query,
  ) {
    return presentationBackgroundLabel(definition.kind)
            .toLowerCase()
            .contains(query) ||
        presentationBackgroundCategory(definition.kind)
            .toLowerCase()
            .contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final selected = controller.selectedPage.backgroundKind;
    final query = _query.trim().toLowerCase();

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
            .where((definition) => query.isEmpty || _matches(definition, query))
            .toList(growable: false);
        final topicDefinitions = presentationBackgroundLibrary
            .where(
                (definition) => presentationBackgroundIsDark(definition.kind))
            .where((definition) => query.isEmpty || _matches(definition, query))
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
            _ModelSearchField(
              controller: _searchController,
              hintText: 'Arka plan ara: isim, kategori...',
              onChanged: (value) => setState(() => _query = value),
              onClear: _clearSearch,
            ),
            const SizedBox(height: 14),
            if (lightDefinitions.isEmpty && topicDefinitions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Eşleşen arka plan bulunamadı.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context._htmlMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
            else ...<Widget>[
              if (lightDefinitions.isNotEmpty) ...[
                backgroundGroup(
                  'Açık ve Ferah',
                  Icons.light_mode_rounded,
                  lightDefinitions,
                ),
                const SizedBox(height: 18),
              ],
              if (topicDefinitions.isNotEmpty)
                backgroundGroup(
                  'Koyu Konu Temaları',
                  Icons.dark_mode_rounded,
                  topicDefinitions,
                ),
            ],
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
              color: isSelected
                  ? context._htmlAccent
                  : context.sutolColors.outline,
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
                  child: HtmlBackgroundPreview(
                    kind: kind,
                    onTap: onTap,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Icon(
                    presentationBackgroundIcon(kind),
                    size: 16,
                    color:
                        isSelected ? context._htmlAccent : context._htmlMuted,
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

class _HtmlComponentControls extends StatefulWidget {
  const _HtmlComponentControls({
    required this.controller,
    this.expandResults = false,
    this.isExpanded = false,
    this.scrollController,
  });

  final PresentationController controller;
  final bool expandResults;
  final bool isExpanded;
  final ScrollController? scrollController;

  @override
  State<_HtmlComponentControls> createState() => _HtmlComponentControlsState();
}

class _HtmlComponentControlsState extends State<_HtmlComponentControls> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  bool _matches(PresentationComponentDefinition definition, String query) {
    return definition.label.toLowerCase().contains(query) ||
        definition.category.toLowerCase().contains(query) ||
        definition.description.toLowerCase().contains(query) ||
        definition.tags.any(
          (tag) => tag.toLowerCase().contains(query),
        );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final categories = presentationComponentCategories();
    final query = _query.trim().toLowerCase();
    final definitionsByKind =
        <PresentationComponentKind, PresentationComponentDefinition>{
      for (final category in categories)
        for (final definition
            in presentationComponentDefinitionsForCategory(category))
          definition.kind: definition,
    };
    final allDefinitions = definitionsByKind.values.toList(growable: false)
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    final visibleDefinitions = query.isEmpty
        ? allDefinitions
        : allDefinitions
            .where((definition) => _matches(definition, query))
            .toList(growable: false);

    final isExpandedMode = widget.expandResults || widget.isExpanded;

    final Widget results;
    if (visibleDefinitions.isEmpty) {
      results = Center(
        child: Text(
          'Eşleşen bileşen bulunamadı.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context._htmlMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
    } else if (!isExpandedMode) {
      // Kompakt mod: Sağa doğru kaydırılabilir yatay liste
      results = SizedBox(
        height: 124,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: visibleDefinitions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final definition = visibleDefinitions[index];
            return SizedBox(
              width: 220,
              child: _ComponentLibraryCard(
                definition: definition,
                onAdd: () => controller.addComponentBlock(definition.kind),
              ),
            );
          },
        ),
      );
    } else {
      // Uzatılmış mod: Dikeyde aşağı kaydırılabilir liste
      results = ListView.separated(
        controller: widget.scrollController,
        itemCount: visibleDefinitions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final definition = visibleDefinitions[index];
          return _ComponentLibraryCard(
            definition: definition,
            onAdd: () => controller.addComponentBlock(definition.kind),
          );
        },
      );
    }

    return Container(
      key: const ValueKey<String>('component-library-panel'),
      width: double.infinity,
      height: isExpandedMode ? double.infinity : null,
      padding:
          isExpandedMode ? EdgeInsets.zero : const EdgeInsets.all(12),
      decoration: isExpandedMode
          ? null
          : BoxDecoration(
              color: context.sutolColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.sutolColors.outline),
            ),
      child: Column(
        mainAxisSize:
            isExpandedMode ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ModelSearchField(
            controller: _searchController,
            hintText: 'Bileşen ara: isim, etiket, kategori...',
            onChanged: (value) => setState(() => _query = value),
            onClear: _clearSearch,
          ),
          const SizedBox(height: 12),
          if (isExpandedMode)
            Expanded(
              child: KeyedSubtree(
                key: const ValueKey<String>('component-library-results'),
                child: results,
              ),
            )
          else
            SizedBox(
              key: const ValueKey<String>('component-library-results'),
              height: 130,
              child: results,
            ),
        ],
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
                    if (MediaQuery.sizeOf(context).width >= 480) ...<Widget>[
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
        children: <Widget>[
          Icon(icon, size: 16, color: context.sutolColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
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
      color: destructive ? const Color(0x28FFD7D7) : _studioHeaderControl,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    destructive ? const Color(0x70FFD7D7) : _studioHeaderBorder,
              ),
            ),
            child: Icon(
              icon,
              color: destructive
                  ? const Color(0xFFFFE4E4)
                  : _studioHeaderForeground,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

Color? _parseTextColorHex(String? hex) {
  if (hex == null || hex.trim().isEmpty) return null;
  var clean = hex.trim().replaceAll('#', '');
  if (clean.startsWith('0x') || clean.startsWith('0X')) {
    clean = clean.substring(2);
  }
  if (clean.length == 3) {
    clean = '${clean[0]}${clean[0]}${clean[1]}${clean[1]}${clean[2]}${clean[2]}';
  }
  if (clean.length == 6) {
    clean = 'FF$clean';
  }
  if (clean.length == 8) {
    final val = int.tryParse(clean, radix: 16);
    if (val != null) return Color(val);
  }
  return null;
}

String _colorToTextHex(Color color) {
  final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '#${r}${g}${b}'.toUpperCase();
}

const List<_TextColorOption> _textColorOptions = <_TextColorOption>[
  _TextColorOption(label: 'Otomatik', hex: null, color: Color(0xFFFFFFFF)),
  _TextColorOption(label: 'Beyaz', hex: '#F8FBFF', color: Color(0xFFF8FBFF)),
  _TextColorOption(label: 'Açık Gri', hex: '#E2E8F0', color: Color(0xFFE2E8F0)),
  _TextColorOption(
      label: 'Camgöbeği', hex: '#67E8F9', color: Color(0xFF67E8F9)),
  _TextColorOption(label: 'Mavi', hex: '#3B82F6', color: Color(0xFF3B82F6)),
  _TextColorOption(label: 'Mor', hex: '#A855F7', color: Color(0xFFA855F7)),
  _TextColorOption(label: 'Pembe', hex: '#EC4899', color: Color(0xFFEC4899)),
  _TextColorOption(label: 'Sarı', hex: '#FBBF24', color: Color(0xFFFBBF24)),
  _TextColorOption(label: 'Turuncu', hex: '#FB923C', color: Color(0xFFFB923C)),
  _TextColorOption(label: 'Kırmızı', hex: '#F87171', color: Color(0xFFF87171)),
  _TextColorOption(label: 'Yeşil', hex: '#22C55E', color: Color(0xFF22C55E)),
  _TextColorOption(label: 'Nane', hex: '#34D399', color: Color(0xFF34D399)),
  _TextColorOption(label: 'Koyu Gri', hex: '#334155', color: Color(0xFF334155)),
  _TextColorOption(label: 'Siyah', hex: '#000000', color: Color(0xFF000000)),
];

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

class _TextColorPickerPanel extends StatefulWidget {
  const _TextColorPickerPanel({
    super.key,
    required this.controller,
    required this.currentHex,
  });

  final PresentationController controller;
  final String? currentHex;

  @override
  State<_TextColorPickerPanel> createState() => _TextColorPickerPanelState();
}

class _TextColorPickerPanelState extends State<_TextColorPickerPanel> {
  late TextEditingController _hexController;
  late double _hue;
  late double _saturation;
  late double _value;
  bool _isAuto = true;
  String? _lastExternalHex;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController();
    _updateFromHex(widget.currentHex, isExternal: true);
  }

  @override
  void didUpdateWidget(covariant _TextColorPickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentHex != oldWidget.currentHex &&
        widget.currentHex != _lastExternalHex) {
      _updateFromHex(widget.currentHex, isExternal: true);
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateFromHex(String? hex, {bool isExternal = false}) {
    _lastExternalHex = hex;
    if (hex == null || hex.trim().isEmpty) {
      setState(() {
        _isAuto = true;
        _hue = 210.0;
        _saturation = 1.0;
        _value = 1.0;
        if (isExternal) {
          _hexController.text = '';
        }
      });
    } else {
      final parsed = _parseTextColorHex(hex);
      if (parsed != null) {
        final hsv = HSVColor.fromColor(parsed);
        final cleanHex = _colorToTextHex(parsed);
        setState(() {
          _isAuto = false;
          _hue = hsv.hue;
          _saturation = hsv.saturation;
          _value = hsv.value;
          if (isExternal) {
            _hexController.text = cleanHex;
          }
        });
      } else if (isExternal) {
        setState(() {
          _hexController.text = hex.toUpperCase();
        });
      }
    }
  }

  Color get _displayColor {
    if (_isAuto) return const Color(0xFFFFFFFF);
    return HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
  }

  void _selectColor(Color color, {String? hexCode}) {
    final hex = hexCode ?? _colorToTextHex(color);
    final hsv = HSVColor.fromColor(color);
    setState(() {
      _isAuto = false;
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
      _hexController.text = hex;
    });
    _lastExternalHex = hex;
    widget.controller.updateSelectedTextColor(hex);
  }

  void _selectAuto() {
    setState(() {
      _isAuto = true;
      _hexController.text = '';
    });
    _lastExternalHex = null;
    widget.controller.updateSelectedTextColor(null);
  }

  void _onHexInputChanged(String val) {
    final clean = val.trim();
    if (clean.isEmpty) {
      _selectAuto();
      return;
    }
    final parsed = _parseTextColorHex(clean);
    if (parsed != null) {
      final formattedHex = _colorToTextHex(parsed);
      final hsv = HSVColor.fromColor(parsed);
      setState(() {
        _isAuto = false;
        _hue = hsv.hue;
        _saturation = hsv.saturation;
        _value = hsv.value;
      });
      _lastExternalHex = formattedHex;
      widget.controller.updateSelectedTextColor(formattedHex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildHexInputField(context),
        const SizedBox(height: 12),
        _buildVisualPicker(context),
        const SizedBox(height: 12),
        _buildPresetSwatches(context),
      ],
    );
  }

  Widget _buildHexInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAuto ? context.sutolColors.outline : context._htmlAccent,
          width: _isAuto ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isAuto ? Colors.white : _displayColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.sutolColors.outline),
              boxShadow: _isAuto
                  ? null
                  : <BoxShadow>[
                      BoxShadow(
                        color: _displayColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: _isAuto
                ? Text(
                    'A',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context._htmlInk,
                          fontWeight: FontWeight.w900,
                        ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'HEX Renk Kodu',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context._htmlMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextField(
                  controller: _hexController,
                  onChanged: _onHexInputChanged,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                  decoration: InputDecoration(
                    hintText: 'Otomatik (#HEX)',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context._htmlMuted,
                          fontStyle: FontStyle.italic,
                        ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (!_isAuto)
            IconButton(
              tooltip: 'Otomatik renge sıfırla',
              icon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: _selectAuto,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildVisualPicker(BuildContext context) {
    final pureHueColor = HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.maxWidth;
            const boxHeight = 110.0;
            final thumbX = (_saturation * boxWidth - 10).clamp(0.0, boxWidth - 20.0);
            final thumbY = ((1.0 - _value) * boxHeight - 10).clamp(0.0, boxHeight - 20.0);
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onPanUpdate: (details) {
                  final sat = (details.localPosition.dx / boxWidth).clamp(0.0, 1.0);
                  final val = (1.0 - (details.localPosition.dy / boxHeight)).clamp(0.0, 1.0);
                  _selectColor(HSVColor.fromAHSV(1.0, _hue, sat, val).toColor());
                },
                onPanDown: (details) {
                  final sat = (details.localPosition.dx / boxWidth).clamp(0.0, 1.0);
                  final val = (1.0 - (details.localPosition.dy / boxHeight)).clamp(0.0, 1.0);
                  _selectColor(HSVColor.fromAHSV(1.0, _hue, sat, val).toColor());
                },
                child: Container(
                  height: boxHeight,
                  color: pureHueColor,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[Colors.white, Color(0x00FFFFFF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[Color(0x00000000), Colors.black],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: thumbX,
                        top: thumbY,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _displayColor,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(color: Colors.black38, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final sliderWidth = constraints.maxWidth;
            final thumbX = ((_hue / 360.0) * sliderWidth - 8).clamp(0.0, sliderWidth - 16.0);
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onPanUpdate: (details) {
                  final h = ((details.localPosition.dx / sliderWidth) * 360.0).clamp(0.0, 360.0);
                  _selectColor(HSVColor.fromAHSV(1.0, h, _saturation, _value).toColor());
                },
                onPanDown: (details) {
                  final h = ((details.localPosition.dx / sliderWidth) * 360.0).clamp(0.0, 360.0);
                  _selectColor(HSVColor.fromAHSV(1.0, h, _saturation, _value).toColor());
                },
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFFFF0000),
                        Color(0xFFFFFF00),
                        Color(0xFF00FF00),
                        Color(0xFF00FFFF),
                        Color(0xFF0000FF),
                        Color(0xFFFF00FF),
                        Color(0xFFFF0000),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: thumbX,
                        top: 1,
                        bottom: 1,
                        child: Container(
                          width: 16,
                          decoration: BoxDecoration(
                            color: pureHueColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(color: Colors.black26, blurRadius: 3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPresetSwatches(BuildContext context) {
    final currentHexUpper = widget.currentHex?.toUpperCase();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final option in _textColorOptions) ...<Widget>[
          InkWell(
            onTap: () {
              if (option.hex == null) {
                _selectAuto();
              } else {
                _selectColor(option.color, hexCode: option.hex);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Tooltip(
              message: option.label + (option.hex != null ? ' (${option.hex})' : ''),
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: option.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (option.hex == null && _isAuto) ||
                            (option.hex != null && currentHexUpper == option.hex!.toUpperCase())
                        ? context._htmlAccent
                        : context.sutolColors.outline,
                    width: (option.hex == null && _isAuto) ||
                            (option.hex != null && currentHexUpper == option.hex!.toUpperCase())
                        ? 2.5
                        : 1,
                  ),
                ),
                child: option.hex == null
                    ? Text(
                        'A',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: context._htmlInk,
                              fontWeight: FontWeight.w900,
                            ),
                      )
                    : ((currentHexUpper == option.hex!.toUpperCase())
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: option.color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          )
                        : null),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HtmlTextControls extends StatefulWidget {
  const _HtmlTextControls({
    required this.controller,
    required this.textController,
  });

  final PresentationController controller;
  final TextEditingController textController;

  @override
  State<_HtmlTextControls> createState() => _HtmlTextControlsState();
}

class _HtmlTextControlsState extends State<_HtmlTextControls> {
  final TextEditingController _fontSearchController = TextEditingController();
  String _fontQuery = '';

  @override
  void dispose() {
    _fontSearchController.dispose();
    super.dispose();
  }

  void _clearFontSearch() {
    _fontSearchController.clear();
    setState(() => _fontQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final textController = widget.textController;
    final selectedTextBlock = controller.selectedTextBlock;
    final selectedTextCount = controller.selectedTextSelectionCount;
    final fontQuery = _fontQuery.trim().toLowerCase();
    final availableFontStyles = presentationFontLibraryStyles;
    final fontStyles = fontQuery.isEmpty
        ? availableFontStyles
        : availableFontStyles
            .where(
              (style) =>
                  _htmlTextStyleLabel(style).toLowerCase().contains(fontQuery),
            )
            .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          key: const ValueKey<String>('add-text-box-button'),
          onPressed: controller.addTextBlock,
          icon: const Icon(Icons.add_rounded, size: 21),
          label: const Text('Metin Kutusu Ekle'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: context._htmlAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 14),
        if (selectedTextCount > 1) ...<Widget>[
          Text(
            '$selectedTextCount metin seçili',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context._htmlMuted,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
        ],
        _TextFieldControl(
          controller: textController,
          enabled: selectedTextBlock != null,
          onChanged: controller.updateSelectedText,
        ),
        const SizedBox(height: 18),
        Text(
          'Metin Rengi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context._htmlInk,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        _TextColorPickerPanel(
          controller: controller,
          currentHex: selectedTextBlock?.textColorHex,
        ),
        const SizedBox(height: 18),
        Text(
          'Yazı Tipleri',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context._htmlInk,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        _ModelSearchField(
          controller: _fontSearchController,
          hintText: 'Yazı tipi ara: klasik, serif, kaligrafi...',
          onChanged: (value) => setState(() => _fontQuery = value),
          onClear: _clearFontSearch,
        ),
        const SizedBox(height: 12),
        if (fontStyles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Eşleşen yazı tipi bulunamadı.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context._htmlMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          )
        else
          for (final style in fontStyles)
            _FontListTile(
              label: _htmlTextStyleLabel(style),
              fontFamily: presentationFontFamily(style),
              selected: selectedTextBlock?.textStyle == style,
              enabled: selectedTextBlock != null,
              onTap: () => controller.updateSelectedTextStyle(style),
            ),
      ],
    );
  }
}

/// Sol paneldeki büyük font liste satırı.
class _FontListTile extends StatelessWidget {
  const _FontListTile({
    required this.label,
    required this.fontFamily,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String? fontFamily;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: selected
                  ? context._htmlAccent.withValues(alpha: 0.10)
                  : context.sutolColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? context._htmlAccent
                    : context.sutolColors.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          color: context._htmlInk,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: context._htmlAccent,
                  ),
              ],
            ),
          ),
        ),
      ),
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
        decoration: _inputDecoration(context, 'Buraya metin yazın'),
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

class _HtmlStageCard extends StatefulWidget {
  const _HtmlStageCard({
    required this.controller,
    this.canvasZoom = 1,
    this.canvasPan = Offset.zero,
    this.showHint = false,
    this.interactive = true,
    this.readOnly = false,
  });

  final PresentationController controller;

  /// Mobil kıstırma yakınlaştırması (1 = sığdır). Yalnızca mobil düzende 1'den
  /// büyüktür; geniş düzenlerde varsayılan 1 kalır.
  final double canvasZoom;

  /// Yakınlaşınca kaydırma uzaklığı (tuval yerel koordinatında).
  final Offset canvasPan;

  final bool showHint;

  /// Tuval içi düzenleme jestleri (sürükleme, çoklu seçim, dokunma). Çoklu
  /// dokunma sırasında kapatılıp kıstırmanın sahne katmanına geçmesi sağlanır.
  final bool interactive;

  /// Salt okunur (admin) mod: tuval katmanı tüm jestlere (seçim, sürükleme,
  /// çoklu seçim, bağlam menüleri) kapatılır; yalnızca görüntüleme kalır.
  final bool readOnly;

  @override
  State<_HtmlStageCard> createState() => _HtmlStageCardState();
}

class _HtmlStageCardState extends State<_HtmlStageCard> {
  String? _inlineEditingTextBlockId;

  void _setInlineEditingTextBlock(String? blockId) {
    if (_inlineEditingTextBlockId == blockId || !mounted) return;
    setState(() => _inlineEditingTextBlockId = blockId);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = _shouldReduceHtmlMotion(
      context,
      widget.controller.effectSettings,
    );
    final zoom = math.max(1.0, widget.canvasZoom);

    // Yakınlaşınca tuvali sabitleyen çağrıların sürükleme deltalarını
    // görsel ölçekle böler; parmak 1:1 takip etmeye devam eder. Seçim
    // dikdörtgeni localPosition tabanlıdır ve dönüşüm altında otomatik
    // doğru kalır (burada değiştirilmez).
    Offset localDelta(Offset delta) => zoom > 1.0001 ? delta / zoom : delta;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final targetRatio = widget.controller.effectSettings.calculatedAspectRatio;
          final availableWidth = math.max(0.0, constraints.maxWidth);
          final availableHeight = math.max(0.0, constraints.maxHeight);
          double stageWidth;
          double stageHeight;
          if (availableWidth / availableHeight > targetRatio) {
            stageHeight = availableHeight;
            stageWidth = stageHeight * targetRatio;
          } else {
            stageWidth = availableWidth;
            stageHeight = stageWidth / targetRatio;
          }

          // Yakınlaşınca tuvali kutu içinde tutacak şekilde kaydırmayı sınırla.
          final maxPanX = math.max(
            0.0,
            (stageWidth * zoom - constraints.maxWidth) / 2,
          );
          final maxPanY = math.max(
            0.0,
            (stageHeight * zoom - constraints.maxHeight) / 2,
          );
          final pan = Offset(
            widget.canvasPan.dx.clamp(-maxPanX, maxPanX),
            widget.canvasPan.dy.clamp(-maxPanY, maxPanY),
          );

          final stage = SizedBox(
            width: stageWidth,
            height: stageHeight,
            // Editör sahnesi slayt değişimlerinde canlı kalır. HtmlPageStage
            // yeni belgeyi arka planda hazırlayıp hazır olduğunda değiştirir;
            // widget'ı page id ile yeniden yaratmak arada gri iframe karesi
            // gösteriyordu. Sunum modundaki gerçek geçişler ayrı akıştadır.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  IgnorePointer(
                    child: HtmlPageStage(
                      page: widget.controller.selectedPage,
                      selectedTextBlockId:
                          widget.controller.selectedTextBlockId,
                      inlineEditingTextBlockId: _inlineEditingTextBlockId,
                      selectedComponentBlockId:
                          widget.controller.selectedComponentBlockId,
                      renderMode: reduceMotion
                          ? HtmlStageRenderMode.snapshot
                          : HtmlStageRenderMode.preview,
                    ),
                  ),
                  if (widget.readOnly)
                    IgnorePointer(
                      child: PresentationPageCanvas(
                        page: widget.controller.selectedPage,
                        selectedTextBlockId:
                            widget.controller.selectedTextBlockId,
                        selectedTextBlockIds:
                            widget.controller.selectedTextBlockIds,
                        selectedComponentBlockId:
                            widget.controller.selectedComponentBlockId,
                        selectedComponentBlockIds:
                            widget.controller.selectedComponentBlockIds,
                        interactive: false,
                        showHint: false,
                        showSurface: false,
                        showEmptyState: false,
                        textOpacity: 0,
                      ),
                    )
                  else
                    PresentationPageCanvas(
                      page: widget.controller.selectedPage,
                      selectedTextBlockId:
                          widget.controller.selectedTextBlockId,
                      selectedTextBlockIds:
                          widget.controller.selectedTextBlockIds,
                      selectedComponentBlockId:
                          widget.controller.selectedComponentBlockId,
                      selectedComponentBlockIds:
                          widget.controller.selectedComponentBlockIds,
                      interactive: widget.interactive,
                      showHint: widget.showHint,
                      showSurface: false,
                      showEmptyState: false,
                      textOpacity: 0,
                      onSelectTextBlock: widget.controller.selectTextBlock,
                      onSelectComponentBlock:
                          widget.controller.selectComponentBlock,
                      onDragSelectedText: (delta, size) =>
                          widget.controller.moveSelectedText(
                        localDelta(delta),
                        size,
                      ),
                      onInlineTextChanged: widget.controller.updateSelectedText,
                      onInlineEditingChanged: _setInlineEditingTextBlock,
                      onResizeSelectedText: (delta, size,
                              {required renderedHeightFactor,
                              required fromLeft,
                              required fromTop,
                              required fromRight,
                              required fromBottom}) =>
                          widget.controller.resizeSelectedTextByHandle(
                        localDelta(delta),
                        size,
                        renderedHeightFactor: renderedHeightFactor,
                        fromLeft: fromLeft,
                        fromTop: fromTop,
                        fromRight: fromRight,
                        fromBottom: fromBottom,
                      ),
                      onResizeSelectedComponent: (delta, size,
                              {required fromLeft,
                              required fromTop,
                              required fromRight,
                              required fromBottom}) =>
                          widget.controller.resizeSelectedComponentByHandle(
                        localDelta(delta),
                        size,
                        fromLeft: fromLeft,
                        fromTop: fromTop,
                        fromRight: fromRight,
                        fromBottom: fromBottom,
                      ),
                      onMarqueeSelectionChanged: ({
                        required textBlockIds,
                        required componentBlockIds,
                      }) =>
                          widget.controller.selectItems(
                        textBlockIds: textBlockIds,
                        componentBlockIds: componentBlockIds,
                      ),
                      onClearSelection: widget.controller.clearSelection,
                      onSecondaryTapTextBlock: (itemId, globalPosition) {
                        if (!widget.controller.selectedTextBlockIds
                            .contains(itemId)) {
                          widget.controller.selectTextBlock(itemId);
                        }
                        _showStageItemContextMenu(
                          context,
                          widget.controller,
                          globalPosition,
                        );
                      },
                      onSecondaryTapComponentBlock: (itemId, globalPosition) {
                        if (!widget.controller.selectedComponentBlockIds
                            .contains(itemId)) {
                          widget.controller.selectComponentBlock(itemId);
                        }
                        _showStageItemContextMenu(
                          context,
                          widget.controller,
                          globalPosition,
                        );
                      },
                      onSecondaryTapCanvas: (globalPosition) {
                        _showCanvasContextMenu(
                          context,
                          widget.controller,
                          globalPosition,
                        );
                      },
                      onToggleModelOrbit: (itemId) {
                        if (widget.controller.selectedComponentBlockId !=
                            itemId) {
                          widget.controller.selectComponentBlock(itemId);
                        }
                        widget.controller.toggleSelectedModelOrbit();
                      },
                      onRotateModel: (itemId, delta) {
                        if (widget.controller.selectedComponentBlockId !=
                            itemId) {
                          widget.controller.selectComponentBlock(itemId);
                        }
                        widget.controller
                            .rotateSelectedModel(localDelta(delta));
                      },
                      onBeginModelOrbit: (itemId) {
                        if (widget.controller.selectedComponentBlockId !=
                            itemId) {
                          widget.controller.selectComponentBlock(itemId);
                        }
                        widget.controller.beginSelectedModelOrbitGesture();
                      },
                      onEndModelOrbit:
                          widget.controller.endSelectedModelOrbitGesture,
                    ),
                ],
              ),
            ),
          );
          return Center(
            child: zoom > 1.0001 || pan != Offset.zero
                ? Transform.translate(
                    offset: pan,
                    child: Transform.scale(
                      scale: zoom,
                      alignment: Alignment.center,
                      child: stage,
                    ),
                  )
                : stage,
          );
        },
      ),
    );
  }
}

/// Seçime bağlı bağlamsal araç çubuğu (Canva tarzı yatay üst bar).
/// Tekli seçimde seçili öğenin türüne göre hızlı ayarları gösterir;
/// seçim yoksa ya da çoklu seçimde gizlenir.
class _SelectionContextBarSection extends StatelessWidget {
  const _SelectionContextBarSection({
    required this.controller,
    required this.textController,
  });

  final PresentationController controller;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        final textBlock = controller.selectedTextBlock;
        final componentBlock = controller.selectedComponentBlock;
        List<Widget>? children;
        String? contentKey;
        if (textBlock != null) {
          contentKey = 'text:${textBlock.id}:$compact';
          children = _textChildren(context, textBlock, compact: compact);
        } else if (componentBlock != null) {
          contentKey = 'component:${componentBlock.id}';
          children = _isUploadedImageBlock(componentBlock)
              ? _imageChildren()
              : componentBlock.modelAssetId != null
                  ? _modelChildren(context, componentBlock)
                  : _componentChildren();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: children == null
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey<String>(contentKey!),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SelectionContextBar(children: children),
                ),
        );
      },
    );
  }

  List<Widget> _textChildren(BuildContext context, PresentationTextBlock block,
      {required bool compact}) {
    return <Widget>[
      _SelectedTextToolbarField(
        controller: textController,
        onChanged: controller.updateSelectedText,
        compact: compact,
      ),
      const MiniToolDivider(),
      MiniToolAction(
        icon: Icons.remove_rounded,
        tooltip: 'Yazı Boyutunu Küçült',
        onTap: block.fontSize > 18
            ? () => controller.updateSelectedFontSize(
                  math.max(18, block.fontSize - 2),
                )
            : null,
      ),
      SizedBox(
        width: 32,
        child: Center(
          child: Tooltip(
            message: 'Yazı Boyutu',
            child: Text(
              '${block.fontSize.round()}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
      MiniToolAction(
        icon: Icons.add_rounded,
        tooltip: 'Yazı Boyutunu Büyüt',
        onTap: block.fontSize < PresentationController.maxTextFontSize
            ? () => controller.updateSelectedFontSize(
                  math.min(
                    PresentationController.maxTextFontSize,
                    block.fontSize + 2,
                  ),
                )
            : null,
      ),
      const MiniToolDivider(),
      MiniToolToggle(
        icon: Icons.format_bold_rounded,
        tooltip: 'Kalın',
        active: block.textBold,
        onTap: () => controller.updateSelectedTextBold(!block.textBold),
      ),
      MiniToolToggle(
        icon: Icons.format_italic_rounded,
        tooltip: 'İtalik',
        active: block.textItalic,
        onTap: () => controller.updateSelectedTextItalic(!block.textItalic),
      ),
      MiniToolToggle(
        icon: Icons.format_underline_rounded,
        tooltip: 'Altı Çizili',
        active: block.textUnderline,
        onTap: () =>
            controller.updateSelectedTextUnderline(!block.textUnderline),
      ),
      const MiniToolDivider(),
      MiniToolToggle(
        icon: Icons.format_align_left_rounded,
        tooltip: 'Sola Hizala',
        active: block.textAlign == PresentationTextAlign.left,
        onTap: () =>
            controller.updateSelectedTextAlign(PresentationTextAlign.left),
      ),
      MiniToolToggle(
        icon: Icons.format_align_center_rounded,
        tooltip: 'Ortala',
        active: block.textAlign == PresentationTextAlign.center,
        onTap: () =>
            controller.updateSelectedTextAlign(PresentationTextAlign.center),
      ),
      MiniToolToggle(
        icon: Icons.format_align_right_rounded,
        tooltip: 'Sağa Hizala',
        active: block.textAlign == PresentationTextAlign.right,
        onTap: () =>
            controller.updateSelectedTextAlign(PresentationTextAlign.right),
      ),
      const MiniToolDivider(),
      _TextAnimationPopupButton(
        key: const ValueKey<String>('selected-text-animation-control'),
        controller: controller,
        current: block.textAnimation,
        compact: compact,
      ),
      const MiniToolDivider(),
      _TextColorPopupButton(
        key: const ValueKey<String>('selected-text-color-control'),
        controller: controller,
        currentHex: block.textColorHex,
      ),
      const MiniToolDivider(),
      _TextGlowPopupButton(
        key: const ValueKey<String>('selected-text-glow-control'),
        controller: controller,
        current: block.glowIntensity,
        compact: compact,
      ),
    ];
  }

  List<Widget> _modelChildren(
    BuildContext context,
    PresentationComponentBlock block,
  ) {
    return <Widget>[
      MiniToolLabeledToggle(
        icon: Icons.autorenew_rounded,
        label: 'Kendi Etrafında Dönme',
        active: block.modelAutoRotate,
        onTap: () =>
            controller.updateSelectedModelAutoRotate(!block.modelAutoRotate),
      ),
      // Dönme hızı çubuğu: yalnızca dönme aktifken görünür; model-viewer'ın
      // rotation-per-second değeri (°/sn).
      if (block.modelAutoRotate) ...<Widget>[
        const SizedBox(width: 4),
        Tooltip(
          message: 'Dönme Hızı',
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.speed_rounded,
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: block.modelRotationSpeed,
                      min: 5,
                      max: 120,
                      onChanged: controller.updateSelectedModelRotationSpeed,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${block.modelRotationSpeed.round()}°/sn',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      const SizedBox(width: 4),
      MiniToolLabeledToggle(
        icon: Icons.movie_rounded,
        label: 'Model Animasyonu',
        active: block.modelAnimationEnabled,
        onTap: () => controller
            .updateSelectedModelAnimationEnabled(!block.modelAnimationEnabled),
      ),
      const SizedBox(width: 4),
      MiniToolLabeledToggle(
        icon: Icons.open_with_rounded,
        label: 'Manuel Kontrol',
        active: block.modelOrbitEnabled,
        onTap: () => controller
            .updateSelectedModelOrbitEnabled(!block.modelOrbitEnabled),
      ),
    ];
  }

  List<Widget> _componentChildren() {
    return <Widget>[
      MiniToolAction(
        icon: Icons.flip_to_front_rounded,
        tooltip: 'Öne Getir',
        onTap: () => controller.moveSelectedComponentLayer(forward: true),
      ),
      MiniToolAction(
        icon: Icons.flip_to_back_rounded,
        tooltip: 'Arkaya Gönder',
        onTap: () => controller.moveSelectedComponentLayer(forward: false),
      ),
      const MiniToolDivider(),
      MiniToolAction(
        icon: Icons.delete_outline_rounded,
        tooltip: 'Sil',
        onTap: controller.removeSelectedComponentBlock,
      ),
    ];
  }

  List<Widget> _imageChildren() {
    return <Widget>[
      const MiniToolAction(
        icon: Icons.photo_rounded,
        tooltip: 'Fotoğraf',
        onTap: null,
      ),
      const MiniToolDivider(),
      MiniToolAction(
        icon: Icons.flip_to_front_rounded,
        tooltip: 'Öne Getir',
        onTap: () => controller.moveSelectedComponentLayer(forward: true),
      ),
      MiniToolAction(
        icon: Icons.flip_to_back_rounded,
        tooltip: 'Arkaya Gönder',
        onTap: () => controller.moveSelectedComponentLayer(forward: false),
      ),
      const MiniToolDivider(),
      MiniToolAction(
        icon: Icons.delete_outline_rounded,
        tooltip: 'Fotoğrafı Sil',
        onTap: controller.removeSelectedComponentBlock,
      ),
    ];
  }
}

class _SelectedTextToolbarField extends StatelessWidget {
  const _SelectedTextToolbarField({
    required this.controller,
    required this.onChanged,
    required this.compact,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey<String>('selected-text-toolbar-field'),
      width: compact ? 150 : 230,
      height: 36,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context._htmlInk,
              fontWeight: FontWeight.w700,
            ),
        decoration: InputDecoration(
          hintText: 'Metin yazın',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          filled: true,
          fillColor: context.sutolColors.surfaceSubtle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.sutolColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.sutolColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context._htmlAccent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _TextAnimationPopupButton extends StatelessWidget {
  const _TextAnimationPopupButton({
    super.key,
    required this.controller,
    required this.current,
    required this.compact,
  });

  final PresentationController controller;
  final PresentationTextAnimation current;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final active = current != PresentationTextAnimation.none;
    final colors = context.colors;
    return PopupMenuButton<PresentationTextAnimation>(
      tooltip: 'Metin animasyonu',
      initialValue: current,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(
        minWidth: 230,
        maxWidth: 280,
        maxHeight: 360,
      ),
      onSelected: controller.updateSelectedTextAnimation,
      itemBuilder: (context) => <PopupMenuEntry<PresentationTextAnimation>>[
        for (final animation in PresentationTextAnimation.values)
          CheckedPopupMenuItem<PresentationTextAnimation>(
            key: ValueKey<String>('text-animation-option-${animation.name}'),
            value: animation,
            checked: animation == current,
            child: Text(_textAnimationLabel(animation)),
          ),
      ],
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.animation_rounded,
              size: 17,
              color: active ? colors.surface : colors.onSurfaceVariant,
            ),
            if (!compact) ...<Widget>[
              const SizedBox(width: 7),
              Text(
                _textAnimationLabel(current),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: active ? colors.surface : colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(width: 5),
            ],
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: active ? colors.surface : colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextColorPopupButton extends StatelessWidget {
  const _TextColorPopupButton({
    super.key,
    required this.controller,
    required this.currentHex,
  });

  final PresentationController controller;
  final String? currentHex;

  @override
  Widget build(BuildContext context) {
    final currentColor = _parseTextColorHex(currentHex);
    return Tooltip(
      message: 'Metin Rengi (Color Picker & HEX)',
      child: InkWell(
        onTap: () {
          _showTextColorPickerDialog(context, controller, currentHex);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.sutolColors.outline),
          ),
          child: Container(
            width: 21,
            height: 21,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: currentColor ?? Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: context.sutolColors.outline),
            ),
            child: currentColor == null
                ? Text(
                    'A',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context._htmlInk,
                          fontWeight: FontWeight.w900,
                        ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

void _showTextColorPickerDialog(
  BuildContext context,
  PresentationController controller,
  String? currentHex,
) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: context.colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: context.sutolColors.outline),
        ),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.palette_rounded, size: 20, color: context._htmlAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Metin Rengi Seçin',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context._htmlInk,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _TextColorPickerPanel(
                  controller: controller,
                  currentHex: currentHex,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Metin parlaklığını modal pencere oluşturmadan doğrudan ayarlar.
class _TextGlowPopupButton extends StatelessWidget {
  const _TextGlowPopupButton({
    super.key,
    required this.controller,
    required this.current,
    required this.compact,
  });

  static final Map<double, String> _options = <double, String>{
    0: 'Kapalı',
    0.5: 'Hafif',
    1: 'Normal',
    1.5: 'Güçlü',
    2: 'Çok güçlü',
  };

  final PresentationController controller;
  final double current;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selectedValue = _options.keys.reduce(
      (a, b) => (current - a).abs() <= (current - b).abs() ? a : b,
    );
    final active = current > 0;
    final colors = context.colors;
    return PopupMenuButton<double>(
      tooltip: 'Metin parlaklığı',
      initialValue: selectedValue,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 190, maxWidth: 220),
      onSelected: controller.updateSelectedGlowIntensity,
      itemBuilder: (context) => <PopupMenuEntry<double>>[
        for (final option in _options.entries)
          CheckedPopupMenuItem<double>(
            key: ValueKey<String>('text-glow-${option.key}'),
            value: option.key,
            checked: option.key == selectedValue,
            child: Text(option.value),
          ),
      ],
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.brightness_7_rounded,
              size: 17,
              color: active ? colors.surface : colors.onSurfaceVariant,
            ),
            if (!compact) ...<Widget>[
              const SizedBox(width: 7),
              Text(
                'Parlaklık',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: active ? colors.surface : colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: active ? colors.surface : colors.onSurfaceVariant,
            ),
          ],
        ),
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

enum _CanvasContextAction {
  paste,
  selectAll,
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

Future<void> _showCanvasContextMenu(
  BuildContext context,
  PresentationController controller,
  Offset globalPosition,
) async {
  final overlay = Overlay.of(context).context.findRenderObject();
  if (overlay is! RenderBox) {
    return;
  }

  final action = await showMenu<_CanvasContextAction>(
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
    items: <PopupMenuEntry<_CanvasContextAction>>[
      PopupMenuItem<_CanvasContextAction>(
        value: controller.canPasteItems ? _CanvasContextAction.paste : null,
        enabled: controller.canPasteItems,
        child: const _StageContextMenuRow(
          icon: Icons.content_paste_rounded,
          label: 'Yapıştır',
        ),
      ),
      const PopupMenuItem<_CanvasContextAction>(
        value: _CanvasContextAction.selectAll,
        child: _StageContextMenuRow(
          icon: Icons.select_all_rounded,
          label: 'Tümünü Seç',
        ),
      ),
    ],
  );

  if (action == null || !context.mounted) {
    return;
  }

  switch (action) {
    case _CanvasContextAction.paste:
      controller.pasteCopiedItems();
    case _CanvasContextAction.selectAll:
      controller.selectAllItems();
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
    case _HtmlToolTab.photo:
      return 'Fotoğraflar';
    case _HtmlToolTab.transitions:
      return 'Geçişler';
    case _HtmlToolTab.stageDimensions:
      return 'Sahne Ölçüleri';
  }
}

InputDecoration _inputDecoration(BuildContext context, String hintText) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final surfaceColor = isDark
      ? context.colors.surfaceElevated
      : SutolLightColors.surfaceSubtle;
  final borderColor =
      isDark ? context.colors.border : SutolLightColors.outline;
  final focusColor = context.colors.primary;
  final hintColor = isDark
      ? context.colors.textSecondary.withValues(alpha: 0.6)
      : SutolLightColors.onSurfaceVariant;

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: hintColor),
    isDense: true,
    filled: true,
    fillColor: surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: focusColor, width: 1.2),
    ),
  );
}

String _htmlTextStyleLabel(PresentationTextStyle style) {
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
      return presentationGoogleFontFamily(style) ?? style.name;
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


class _QuickStageDimensionChip extends StatelessWidget {
  const _QuickStageDimensionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isSelected
          ? (isDark ? context.colors.primary.withValues(alpha: 0.2) : const Color(0xFFE0F2FE))
          : (highlight ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)) : Colors.transparent),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? context.colors.primary
                  : (highlight
                      ? context.colors.primary.withValues(alpha: 0.4)
                      : context.sutolColors.outline.withValues(alpha: 0.5)),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? context.colors.primary
                    : (highlight ? context.colors.primary : context._htmlInk),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? context.colors.primary
                      : (highlight ? context.colors.primary : context._htmlInk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showStageDimensionsDialog(
  BuildContext context,
  PresentationController controller,
) async {
  final currentSettings = controller.effectSettings;
  String selectedPreset = currentSettings.aspectRatio;
  final widthController = TextEditingController(
    text: currentSettings.customWidth.round().toString(),
  );
  final heightController = TextEditingController(
    text: currentSettings.customHeight.round().toString(),
  );

  Widget buildContent(BuildContext ctx, StateSetter setState) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final primaryColor = ctx.colors.primary;

    double calculateCurrentRatio() {
      if (selectedPreset == 'custom') {
        final w = double.tryParse(widthController.text) ?? 1920;
        final h = double.tryParse(heightController.text) ?? 1080;
        return h > 0 ? (w / h).clamp(0.2, 5.0) : 1.777;
      }
      switch (selectedPreset) {
        case '9:16':
          return 9 / 16;
        case '4:3':
          return 4 / 3;
        case '1:1':
          return 1 / 1;
        case '16:9':
        default:
          return 16 / 9;
      }
    }

    final ratio = calculateCurrentRatio();
    final isPortrait = ratio < 1.0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        primaryColor,
                        primaryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.aspect_ratio_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sahne Ölçüleri & Format',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ctx._htmlInk,
                            ),
                      ),
                      Text(
                        'Sunum tuval boyutunu ve formatını özelleştirin',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: ctx._htmlMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'HAZIR FORMATLAR (PRESETS)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: ctx._htmlMuted,
              ),
            ),
            const SizedBox(height: 10),
            _StageDimensionPresetCard(
              title: 'Mobil Dikey',
              subtitle: 'Telefonlar için dikey responsive HTML sahne (1080×1920 px)',
              icon: Icons.smartphone_rounded,
              isSelected: selectedPreset == '9:16',
              badgeText: '9:16',
              highlight: true,
              onTap: () {
                setState(() => selectedPreset = '9:16');
                controller.updateStageDimensions(aspectRatio: '9:16');
              },
            ),
            const SizedBox(height: 8),
            _StageDimensionPresetCard(
              title: 'Standart Sunum',
              subtitle: 'Masaüstü, TV & Projeksiyon ekranları (1920×1080 px)',
              icon: Icons.desktop_windows_rounded,
              isSelected: selectedPreset == '16:9',
              badgeText: '16:9',
              onTap: () {
                setState(() => selectedPreset = '16:9');
                controller.updateStageDimensions(aspectRatio: '16:9');
              },
            ),
            const SizedBox(height: 8),
            _StageDimensionPresetCard(
              title: 'Klasik Sunum',
              subtitle: 'Klasik ekranlar & PDF çıktısı (1024×768 px)',
              icon: Icons.aspect_ratio_rounded,
              isSelected: selectedPreset == '4:3',
              badgeText: '4:3',
              onTap: () {
                setState(() => selectedPreset = '4:3');
                controller.updateStageDimensions(aspectRatio: '4:3');
              },
            ),
            const SizedBox(height: 8),
            _StageDimensionPresetCard(
              title: 'Kare Format',
              subtitle: 'Sosyal medya & tablet kart formatı (1080×1080 px)',
              icon: Icons.crop_square_rounded,
              isSelected: selectedPreset == '1:1',
              badgeText: '1:1',
              onTap: () {
                setState(() => selectedPreset = '1:1');
                controller.updateStageDimensions(aspectRatio: '1:1');
              },
            ),
            const SizedBox(height: 8),
            _StageDimensionPresetCard(
              title: 'Özel Sahne Ölçüsü',
              subtitle: 'Piksel bazlı genişlik ve yükseklik tanımlayın',
              icon: Icons.tune_rounded,
              isSelected: selectedPreset == 'custom',
              badgeText: 'Özel',
              onTap: () => setState(() => selectedPreset = 'custom'),
            ),
            if (selectedPreset == 'custom') ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : primaryColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'PİKSEL BOYUTLARI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: widthController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(ctx, '1920')
                                .copyWith(labelText: 'Genişlik (px)'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '×',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(ctx, '1080')
                                .copyWith(labelText: 'Yükseklik (px)'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Dynamic Live Banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isPortrait
                    ? (isDark
                        ? const Color(0xFF0F291E)
                        : const Color(0xFFECFDF5))
                    : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPortrait
                      ? const Color(0xFF10B981)
                      : primaryColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: isPortrait ? 26 : 42,
                    height: isPortrait ? 42 : 26,
                    decoration: BoxDecoration(
                      color: isPortrait
                          ? const Color(0xFF10B981)
                          : primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPortrait
                          ? Icons.smartphone_rounded
                          : Icons.laptop_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          isPortrait
                              ? '📱 Mobil Dikey Sahne Modu'
                              : '🖥️ Yatay / Masaüstü Sahne Modu',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: isPortrait
                                ? (isDark ? Colors.white : const Color(0xFF065F46))
                                : ctx._htmlInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Görünüm Oranı: ${ratio.toStringAsFixed(2)}:1 • ${isPortrait ? "Telefon ekranları için optimize edildi" : "Standart sunumlar için optimize edildi"}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isPortrait
                                ? (isDark
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFF047857))
                                : ctx._htmlMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Uygula'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                  ),
                  onPressed: () {
                    final customW =
                        double.tryParse(widthController.text) ?? 1920;
                    final customH =
                        double.tryParse(heightController.text) ?? 1080;
                    controller.updateStageDimensions(
                      aspectRatio: selectedPreset,
                      customWidth: customW,
                      customHeight: customH,
                    );
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final isMobileScreen = MediaQuery.sizeOf(context).width < 600;

  if (isMobileScreen) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E2D)
          : Colors.white,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) => buildContent(ctx, setState),
          ),
        );
      },
    );
  } else {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: 520,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (ctx, setState) => buildContent(ctx, setState),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StageDimensionPresetCard extends StatelessWidget {
  const _StageDimensionPresetCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeText,
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badgeText;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = context.colors.primary;

    return Material(
      color: isSelected
          ? (isDark ? primaryColor.withValues(alpha: 0.18) : const Color(0xFFEFF6FF))
          : (isDark ? context.colors.surfaceElevated : Colors.white),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (highlight
                      ? primaryColor.withValues(alpha: 0.5)
                      : context.sutolColors.outline.withValues(alpha: 0.5)),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : (highlight
                          ? primaryColor.withValues(alpha: 0.15)
                          : (isDark ? Colors.white10 : const Color(0xFFF1F5F9))),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : (highlight ? primaryColor : context._htmlInk),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isSelected ? primaryColor : context._htmlInk,
                            ),
                          ),
                        ),
                        if (badgeText != null) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: highlight
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : (isSelected
                                      ? primaryColor.withValues(alpha: 0.15)
                                      : Colors.grey.withValues(alpha: 0.15)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: highlight || isSelected
                                    ? primaryColor
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: context._htmlMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? primaryColor : context._htmlMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlStageDimensionsControls extends StatelessWidget {
  const _HtmlStageDimensionsControls({
    required this.controller,
    this.isExpanded = false,
    this.scrollController,
  });

  final PresentationController controller;
  final bool isExpanded;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final effectSettings = controller.effectSettings;
    final currentRatio = effectSettings.aspectRatio;

    const presets = <(String, String, String, IconData, String)>[
      (
        '9:16',
        'Mobil Dikey',
        '1080×1920 px • Telefon ekranları',
        Icons.smartphone_rounded,
        '9:16',
      ),
      (
        '16:9',
        'Standart Sunum',
        '1920×1080 px • Masaüstü & TV ekranları',
        Icons.desktop_windows_rounded,
        '16:9',
      ),
      (
        '4:3',
        'Klasik Sunum',
        '1024×768 px • Klasik projeksiyon',
        Icons.aspect_ratio_rounded,
        '4:3',
      ),
      (
        '1:1',
        'Kare Format',
        '1080×1080 px • Sosyal medya & kart',
        Icons.crop_square_rounded,
        '1:1',
      ),
    ];

    return ListView(
      controller: scrollController,
      shrinkWrap: !isExpanded,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'SAHNE ÖLÇÜLERİ VE FORMAT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: context._htmlMuted,
              ),
            ),
            if (currentRatio != 'custom')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Aktif: $currentRatio',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final (ratio, label, subtitle, icon, badge) in presets) ...<Widget>[
          _StageDimensionPresetCard(
            title: label,
            subtitle: subtitle,
            icon: icon,
            isSelected: currentRatio == ratio,
            badgeText: badge,
            highlight: ratio == '9:16',
            onTap: () => controller.updateStageDimensions(aspectRatio: ratio),
          ),
          const SizedBox(height: 10),
        ],
        _StageDimensionPresetCard(
          title: 'Özel Sahne Ölçüsü',
          subtitle: currentRatio == 'custom'
              ? 'Özel (${effectSettings.customWidth.toInt()}×${effectSettings.customHeight.toInt()} px)'
              : 'Genişlik ve yükseklik piksel değerlerini elle ayarla',
          icon: Icons.tune_rounded,
          isSelected: currentRatio == 'custom',
          badgeText: 'Özel',
          onTap: () => _showStageDimensionsDialog(context, controller),
        ),
      ],
    );
  }
}
