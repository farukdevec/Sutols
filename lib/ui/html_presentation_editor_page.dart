import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/slide_model.dart';
import '../services/firestore_rest_helper.dart';
import '../services/local_image_picker.dart';
import '../services/presentation_export_service.dart';
import '../services/presentation_auto_builder.dart';
import '../services/presentation_fullscreen_service.dart';
import '../services/presentation_project_codec.dart';
import '../services/presentation_project_io.dart';
import '../services/presentation_project_store.dart';
import '../services/presentation_tracking_service.dart';
import '../services/remote_image_sources.dart';
import '../services/remote_model_sources.dart';
import '../state/presentation_controller.dart';
import '../state/theme_controller.dart';
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

enum _HtmlToolTab {
  templates,
  backgrounds,
  components,
  text,
  models3d,
  photo,
  transitions,
}

class HtmlPresentationEditorPage extends StatefulWidget {
  const HtmlPresentationEditorPage({
    super.key,
    required this.controller,
    this.presentationId,
    this.initialUpdatedByName,
  });

  final PresentationController controller;

  /// Bağlı Firestore sunum ID'si (varsa kayıt buluta yazılır).
  final String? presentationId;

  /// Açılışta gösterilecek "son düzenleyen" adı.
  final String? initialUpdatedByName;

  @override
  State<HtmlPresentationEditorPage> createState() =>
      _HtmlPresentationEditorPageState();
}

class _HtmlPresentationEditorPageState
    extends State<HtmlPresentationEditorPage> {
  late final TextEditingController _textController;
  _HtmlToolTab _activeTab = _HtmlToolTab.text;
  String? _lastEditorLabel;

  final PresentationTrackingService _tracking =
      PresentationTrackingService();

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
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    widget.controller.removeListener(_syncTextField);
    widget.controller.removeListener(_syncTabWithSelection);
    widget.controller.removeListener(_onMobilePageChanged);
    widget.controller.removeListener(_trackEdits);
    _textController.dispose();
    final presentationId = widget.presentationId;
    if (presentationId != null) {
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
      ..write('|${settings.transitionKind.index}|${settings.transitionDurationMs}')
      ..write('|${settings.zoomEnabled}|${settings.zoomScale.toStringAsFixed(3)}')
      ..write('|${settings.reducedMotion}');
    for (final page in controller.pages) {
      buf
        ..write('\n${page.id}|${page.backgroundKind.index}|${page.speakerNotes}');
      for (final text in page.textBlocks) {
        buf
          ..write('\nT:${text.id}|${text.text}|${text.position.dx.toStringAsFixed(3)}')
          ..write('|${text.position.dy.toStringAsFixed(3)}|${text.fontSize}')
          ..write('|${text.type.index}|${text.widthFactor}|${text.textStyle.index}')
          ..write('|${text.textAnimation.index}|${text.textColorHex}')
          ..write('|${text.glowIntensity}|${text.revealStep}')
          ..write('|${text.hotspotTargetPageId}|${text.textBold}')
          ..write('|${text.textItalic}|${text.textUnderline}|${text.textAlign.index}');
      }
      for (final block in page.componentBlocks) {
        buf
          ..write('\nC:${block.id}|${block.kind.index}|${block.modelAssetId}')
          ..write('|${block.modelAnimationEnabled}|${block.modelAutoRotate}')
          ..write('|${block.modelOrbitEnabled}'
              '|${block.modelOrbitTheta.toStringAsFixed(3)}|${block.modelOrbitPhi.toStringAsFixed(3)}')
          ..write('|${block.position.dx.toStringAsFixed(3)}|${block.position.dy.toStringAsFixed(3)}')
          ..write('|${block.size.width.toStringAsFixed(3)}|${block.size.height.toStringAsFixed(3)}')
          ..write('|${block.revealStep}|${block.hotspotTargetPageId}');
      }
    }
    return buf.toString();
  }

  /// Kullanıcı sunumu gerçekten düzenlediğinde Firebase'e işler
  /// (wasEdited: true, editCount: +1). presentationId yoksa (yerel proje)
  /// hiçbir şey yapmaz.
  void _trackEdits() {
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
      targetTab = componentBlock.modelAssetId != null
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

  Future<void> _exportPresentation() async {
    final presentationId = widget.presentationId;
    if (presentationId != null) {
      _tracking.markExported(presentationId);
    }
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
        final name = user != null &&
                (user.displayName ?? '').trim().isNotEmpty
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
    try {
      final project = await loadPresentationProjectFromJson();
      if (project == null) {
        return;
      }
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

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
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
              widget.controller.duplicateSelectedItems,
          const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
              widget.controller.duplicateSelectedItems,

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
              widget.controller.removeSelectedItems,
          const SingleActivator(LogicalKeyboardKey.backspace):
              widget.controller.removeSelectedItems,

          // Seçimi temizle
          const SingleActivator(LogicalKeyboardKey.escape):
              widget.controller.clearSelection,
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
                                lastEditorLabel: _lastEditorLabel,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _HtmlStudioLayout(
                                  controller: widget.controller,
                                  textController: _textController,
                                  activeTab: _activeTab,
                                  panelOpen: _inspectorOpen,
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
                                    canvasInteractive: !_multiTouchActive,
                                    showHint:
                                        _showMobileHint &&
                                        _mobileCanvasZoom <= 1.0001,
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
      if (lastEditorLabel != null && lastEditorLabel!.isNotEmpty)
        _HeaderBadge(
          icon: Icons.edit_rounded,
          label: 'Son düzenleme: $lastEditorLabel',
        ),
      _ThemeToggleButton(),
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
        final mobile = constraints.maxWidth < AppBreakpoints.mobile;
        final compact = constraints.maxWidth < 980;

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
              case _MobileHeaderAction.theme:
                ThemeController.instance.toggle();
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

          final compact = constraints.maxWidth < 340;
          final iconSize = compact ? 36.0 : 40.0;
          final popupConstraints = BoxConstraints.tightFor(
            width: iconSize,
            height: iconSize,
          );

          return Container(
            key: const ValueKey<String>('mobile-editor-header'),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: <Widget>[
                _MobileHeaderIconButton(
                  tooltip: 'Geri',
                  icon: Icons.arrow_back_rounded,
                  size: compact ? 40 : 44,
                  onTap: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: compact ? 0 : 2),
                Image.asset(
                  'assets/images/logo.png',
                  height: compact ? 22 : 24,
                ),
                SizedBox(width: compact ? 5 : 7),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sutols',
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context._htmlInk,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ),
                ),
                _MobileHistoryButtons(
                  onUndo: onUndo,
                  onRedo: onRedo,
                  canUndo: canUndo,
                  canRedo: canRedo,
                  size: iconSize,
                ),
                _MobileHeaderIconButton(
                  tooltip: 'Sunum Modu',
                  icon: Icons.slideshow_rounded,
                  size: iconSize,
                  onTap: onPreview,
                ),
                PopupMenuButton<_MobileHeaderAction>(
                  tooltip: 'Dışa Aktar',
                  padding: EdgeInsets.zero,
                  constraints: popupConstraints,
                  iconSize: 20,
                  icon: Icon(
                    Icons.download_rounded,
                    color: context._htmlInk,
                  ),
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
                ),
                PopupMenuButton<_MobileHeaderAction>(
                  tooltip: 'Diğer işlemler',
                  padding: EdgeInsets.zero,
                  constraints: popupConstraints,
                  iconSize: 20,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: context._htmlInk,
                  ),
                  onSelected: handleAction,
                  itemBuilder: (context) =>
                      <PopupMenuEntry<_MobileHeaderAction>>[
                        PopupMenuItem<_MobileHeaderAction>(
                          value: _MobileHeaderAction.theme,
                          child: const ListTile(
                            leading: Icon(Icons.dark_mode_rounded),
                            title: Text('Görünümü Değiştir'),
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 10,
                child: IgnorePointer(
                  ignoring: canvasZoom > 1.0001,
                  child: _SelectionContextBarSection(controller: controller),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _HtmlMobileSlideStrip(controller: controller),
        const SizedBox(height: 8),
        _HtmlMobileToolDock(
          activeTab: activeTab,
          onOpenTool: onOpenTool,
          onOpenPhotoQuick: onOpenPhotoQuick,
        ),
      ],
    );
  }
}

/// Tuvalin altındaki kalıcı slayt şeridi: yatay kaydırılabilir kompakt
/// önizlemeler; seçili slayt vurgulanır ve otomatik olarak görünüme getirilir.
/// Normal slayt gezinmesi buradan yapılır (alt iskelede "Slaytlar" yoktur).
class _HtmlMobileSlideStrip extends StatefulWidget {
  const _HtmlMobileSlideStrip({required this.controller});

  final PresentationController controller;

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
    final target = (selected * (_thumbWidth + _gap) -
            (viewport - _thumbWidth) / 2)
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
                );
              },
            ),
          ),
          const SizedBox(width: 6),
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
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey<String>('mobile-slide-strip-thumb-$index'),
      onTap: onTap,
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
                    color: isSelected
                        ? context.colors.onPrimary
                        : Colors.white,
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

/// Alt araç iskelesi: Metin, Medya, 3B Modeller, Şekil ve "Daha fazla"
/// (fotoğraf yükle, şablon, arka plan, geçiş, ses vb.).
/// Dar ekranlarda sığmayan araçlar öncelik sırasına göre "Daha fazla"
/// menüsüne taşınır; yatay kaydırma yoktur. Slayt gezinmesi tuvalin altındaki
/// kalıcı küçük resim şeridinde yapılır.
class _HtmlMobileToolDock extends StatelessWidget {
  const _HtmlMobileToolDock({
    required this.activeTab,
    required this.onOpenTool,
    required this.onOpenPhotoQuick,
  });

  final _HtmlToolTab activeTab;
  final ValueChanged<_HtmlToolTab> onOpenTool;

  /// "Daha fazla" menüsündeki "Fotoğraf Yükle" kısayolunun hızlı aksiyon
  /// sheet'ini açması (cihazdan seçim ya da Medya kütüphanesi).
  final VoidCallback onOpenPhotoQuick;

  @override
  Widget build(BuildContext context) {
    final tools = <_MobileDockTool>[
      _MobileDockTool(
        icon: Icons.text_fields_rounded,
        label: 'Metin',
        selected: activeTab == _HtmlToolTab.text,
        onTap: () => onOpenTool(_HtmlToolTab.text),
      ),
      _MobileDockTool(
        icon: Icons.add_photo_alternate_rounded,
        label: 'Medya',
        selected: activeTab == _HtmlToolTab.photo,
        onTap: () => onOpenTool(_HtmlToolTab.photo),
      ),
      _MobileDockTool(
        icon: Icons.view_in_ar_rounded,
        label: '3B Modeller',
        selected: activeTab == _HtmlToolTab.models3d,
        onTap: () => onOpenTool(_HtmlToolTab.models3d),
      ),
      _MobileDockTool(
        icon: Icons.widgets_rounded,
        label: 'Şekil',
        selected: activeTab == _HtmlToolTab.components,
        onTap: () => onOpenTool(_HtmlToolTab.components),
      ),
    ];
    final moreSelected = const <_HtmlToolTab>{
      _HtmlToolTab.templates,
      _HtmlToolTab.backgrounds,
      _HtmlToolTab.transitions,
    }.contains(activeTab);

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final gap = _MobileDockButton.chipGap;
        final compactMoreWidth = _MobileDockButton.compactWidth;
        final fullMoreWidth = _dockChipWidth(context, 'Daha fazla');
        final widths =
            <double>[for (final t in tools) _dockChipWidth(context, t.label)];
        final toolsWidth =
            widths.fold<double>(0, (sum, w) => sum + w + gap);
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
                onSelected: _handleMore,
                itemBuilder: (context) {
                  // Dar ekranda dock'a sığmayan araçlar (öncelik sırasıyla)
                  // menünün başına düşer; böylece hiçbir araç kaybolmaz.
                  final hiddenLabels =
                      tools.asMap().entries
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
                          'Medya' => _MobileMoreTool.media,
                          '3B Modeller' => _MobileMoreTool.models3d,
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
                  // "Şekil" dock'ta görünüyorsa "Bileşenler" menüde ayrıca
                  // yer alır; gizliyse aynı panel zaten menüdeki "Şekil"dir.
                  if (!hiddenLabels.contains('Şekil')) {
                    add(
                      _MobileMoreTool.components,
                      Icons.widgets_rounded,
                      'Bileşenler',
                    );
                  }
                  // "3B Modeller" dock'ta görünmüyorsa menüde yer alır.
                  if (!hiddenLabels.contains('3B Modeller')) {
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
                  add(
                    _MobileMoreTool.photoUpload,
                    Icons.add_a_photo_rounded,
                    'Fotoğraf Yükle',
                  );
                  add(
                    _MobileMoreTool.audio,
                    Icons.music_note_rounded,
                    'Ses',
                  );
                  add(
                    _MobileMoreTool.animations,
                    Icons.auto_awesome_rounded,
                    'Animasyonlar',
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
        );
      },
    );
  }

  void _handleMore(_MobileMoreTool tool) {
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
      case _MobileMoreTool.audio:
        onOpenTool(_HtmlToolTab.backgrounds);
      case _MobileMoreTool.animations:
        onOpenTool(_HtmlToolTab.transitions);
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
        _MobileDockButton.iconSize +
        _MobileDockButton.iconGap +
        painter.width,
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
    final foreground = selected
        ? context._htmlAccent
        : context.sutolColors.onSurfaceVariant;
    final background =
        selected ? const Color(0xFFEDF4FF) : Colors.transparent;
    final borderColor = selected ? const Color(0xFFD4E4FF) : Colors.transparent;
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
class _HtmlMobileToolSheet extends StatelessWidget {
  const _HtmlMobileToolSheet({
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
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.72;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720, maxHeight: sheetHeight),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 8, 4),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        _toolSheetIcon(tab),
                        size: 20,
                        color: context._htmlAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _studioPanelTitle(tab),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: context._htmlInk,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Kapat',
                        onPressed: onClose,
                        icon: Icon(
                          Icons.close_rounded,
                          color: context.sutolColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      child: _HtmlControlPanel(
                        key: ValueKey<_HtmlToolTab>(tab),
                        controller: controller,
                        textController: textController,
                        activeTab: tab,
                      ),
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

  static IconData _toolSheetIcon(_HtmlToolTab tab) {
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
    }
  }
}

/// Slayt listesi bottom sheet'i: yatay küçük önizlemeler + ekle/sil.
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

/// Mobil başlıktaki "⋯" overflow menüsünün eylemleri.
enum _MobileHeaderAction {
  preview,
  theme,
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

  /// "Ses" → Arka Planlar (Müzik ve Ses kategorisi).
  audio,

  /// "Animasyonlar" → Geçişler (slayt animasyonları) paneli.
  animations,
}

/// Mobil "Fotoğraf" hızlı aksiyonunun seçenekleri.
enum _MobilePhotoQuickAction { pick, library }

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Material(
          color: context.sutolColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: ThemeController.instance.toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 18,
                    color: context._htmlInk,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDark ? 'Açık Tema' : 'Koyu Tema',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context._htmlInk,
                          fontWeight: FontWeight.w700,
                        ),
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

/// Mobil header'daki kompakt ikon düğmesi (40px hedef alanı; header yüksekliği
/// 56-60px bandında kalır).
class _MobileHeaderIconButton extends StatelessWidget {
  const _MobileHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.enabled = true,
    this.size = 40,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 20,
        color: enabled
            ? context._htmlInk
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
  });

  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;

  /// Çok dar ekranlarda (<340) kompakt boyut.
  final double size;

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
        ),
        _MobileHeaderIconButton(
          icon: Icons.redo_rounded,
          tooltip: 'Yinele',
          enabled: canRedo,
          onTap: onRedo,
          size: size,
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
    required this.onSave,
    required this.onLoad,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
    required this.onAddText,
    required this.onRemoveText,
    required this.canRemoveText,
    this.lastEditorLabel,
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
  final String? lastEditorLabel;

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
            'Sutols',
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
          if (lastEditorLabel != null && lastEditorLabel!.isNotEmpty) ...[
            _StudioHeaderInfoChip(
              icon: Icons.edit_rounded,
              label: 'Son düzenleme: $lastEditorLabel',
            ),
            const SizedBox(width: 8),
          ],
          _ThemeToggleButton(),
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
    required this.panelOpen,
    required this.onTabChanged,
    required this.onPreview,
    required this.onExport,
    required this.onExportPdf,
  });

  final PresentationController controller;
  final TextEditingController textController;
  final _HtmlToolTab activeTab;

  /// Detay paneli açık mı? (Kapalıyken tuval tüm genişliği kullanır.)
  final bool panelOpen;
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
        const SizedBox(width: 12),
        // Detay paneli: ikon şeridinin hemen yanında açılır/kapanır.
        // Kapalıyken genişlik 0'a iner (tuval genişler), açıkken 300px.
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.ease,
            alignment: Alignment.centerLeft,
            child: panelOpen
                ? SizedBox(
                    width: 300,
                    child: _HtmlInspectorPanel(
                      controller: controller,
                      textController: textController,
                      activeTab: activeTab,
                    ),
                  )
                : const SizedBox(width: 0, height: double.infinity),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HtmlStageWorkspace(
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
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
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
              label: 'Fotoğraf',
              icon: Icons.add_photo_alternate_rounded,
              isSelected: activeTab == _HtmlToolTab.photo,
              onTap: () => onTabChanged(_HtmlToolTab.photo),
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

          // Birincil + ikincil butonlar toplamda ~1060px tutar; bu
          // yüksekliğin altında Spacer yerine kaydırılabilir düzen kullan.
          if (constraints.maxHeight < 1080) {
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
                      fontSize: 11,
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
                    child: _HtmlTextControls(
                      controller: controller,
                      textController: textController,
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
                _SelectionContextBarSection(controller: controller),
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
  });

  final PresentationController controller;

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
            child: ListView.separated(
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
    final stage = _HtmlStageCard(controller: controller);
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
          _HtmlTopToolbar(
            controller: controller,
            textController: textController,
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
          const SizedBox(height: 12),
          _SelectionContextBarSection(controller: controller),
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
              label: 'Fotoğraf',
              icon: Icons.add_photo_alternate_rounded,
              isSelected: activeTab == _HtmlToolTab.photo,
              onTap: () => onTabChanged(_HtmlToolTab.photo),
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
      case _HtmlToolTab.photo:
        return _HtmlPhotoControls(controller: controller);
      case _HtmlToolTab.transitions:
        return _HtmlTransitionControls(controller: controller);
    }
  }
}

class _CloudModelEntry {
  const _CloudModelEntry({
    required this.id,
    required this.name,
    required this.modelUrl,
    required this.thumbnailUrl,
    required this.tags,
    required this.category,
    required this.tier,
  });

  final String id;
  final String name;
  final String modelUrl;
  final String thumbnailUrl;
  final List<String> tags;
  final String category;

  /// Kullanıcı planı: "free" | "plus" | "premium". Boşsa "free" sayılır.
  final String tier;
}

class _Html3DModelControls extends StatefulWidget {
  const _Html3DModelControls({required this.controller});

  final PresentationController controller;

  @override
  State<_Html3DModelControls> createState() => _Html3DModelControlsState();
}

class _Html3DModelControlsState extends State<_Html3DModelControls> {
  final TextEditingController _searchController = TextEditingController();
  List<_CloudModelEntry> _models = const <_CloudModelEntry>[];
  bool _loading = true;
  String? _error;
  String _query = '';
  String _category = '';
  String _userTier = 'free';

  static int _tierRank(String tier) => switch (tier) {
        'premium' => 2,
        'plus' => 1,
        _ => 0,
      };

  bool _isLocked(_CloudModelEntry model) =>
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
          final userFields =
              userDoc?['fields'] as Map<String, dynamic>? ?? {};
          final tier = FirestoreRestHelper.stringField(userFields, 'tier');
          if (tier.isNotEmpty) userTier = tier;
        } catch (_) {
          // Best-effort: tier okunamadıysa "free" varsayılır.
        }
      }

      // Buluttaki tüm modeller: models koleksiyonu (rules: herkes okuyabilir).
      // .where/.orderBy kullanılmaz (Int64 dartify riski) — tümü tek seferde
      // çekilir, filtre/arama/sıralama Dart tarafında yapılır.
      final docs = await FirestoreRestHelper.listDocuments('models');
      final models = <_CloudModelEntry>[];
      for (final doc in docs) {
        final id = (doc['name'] as String? ?? '').split('/').last;
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final name = FirestoreRestHelper.stringField(fields, 'name');
        final modelUrl = FirestoreRestHelper.stringField(fields, 'modelUrl');
        if (id.isEmpty || modelUrl.isEmpty) {
          continue;
        }
        models.add(_CloudModelEntry(
          id: id,
          name: name.isEmpty ? id : name,
          modelUrl: modelUrl,
          thumbnailUrl:
              FirestoreRestHelper.stringField(fields, 'thumbnailUrl'),
          tags: FirestoreRestHelper.arrayField(fields, 'tags'),
          category: FirestoreRestHelper.stringField(fields, 'category'),
          tier: FirestoreRestHelper.stringField(fields, 'tier'),
        ));
      }
      models.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
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

  List<_CloudModelEntry> get _filtered {
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

  void _add(_CloudModelEntry model) {
    if (_isLocked(model)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu model planınızda dahil değil'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // Sahnenin çözebilmesi için R2 kaynağını kayıt defterine işle,
    // ardından tuval üzerine 3B blok olarak ekle.
    RemoteModelSources.registerAll(<String, String>{model.id: model.modelUrl});
    widget.controller.add3DModelBlock(
      Presentation3DModelAsset(
        id: model.id,
        label: model.name,
        assetPath: model.modelUrl,
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
          _ModelSearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: _buildBody(context, filtered, selectedModelId),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<_CloudModelEntry> filtered,
    String? selectedModelId,
  ) {
    if (_loading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = _gridColumns(constraints.maxWidth);
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
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
            Icon(Icons.search_off_rounded,
                color: context._htmlMuted, size: 28),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _gridColumns(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 8),
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
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
              thumbnailUrl: model.thumbnailUrl.isEmpty
                  ? 'https://assets.sutols.com/thumbnails/${model.id}.webp'
                  : model.thumbnailUrl,
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
  controller.addUploadedImageBlock(sourceId);
  return _UploadedPhotoEntry(
    id: sourceId,
    name: picked.name,
    dataUrl: picked.dataUrl,
    sizeBytes: picked.sizeBytes,
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
                label: Text(_picking ? 'Yükleniyor...' : 'Cihazdan Fotoğraf Yükle'),
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
                onAdd: () =>
                    widget.controller.addUploadedImageBlock(photo.id),
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
  });

  final String id;
  final String name;
  final String dataUrl;
  final int sizeBytes;
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
                    if (MediaQuery.sizeOf(context).width >= 480) ...<Widget>[
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
    // Thumbnail boşsa doğrudan harf kutusuna düş (network hatası UI'ı
    // bozmasın).
    if (widget.thumbnailUrl.isEmpty) {
      return _letterBox(context);
    }
    return Image.network(
      widget.thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? SutolDarkColors.surfaceSubtle
              : SutolLightColors.surfaceSubtle,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _letterBox(context),
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
                  AspectRatio(
                    aspectRatio: 1,
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
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
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
        const SizedBox(height: 14),
        for (final template in templates) ...<Widget>[
          _TemplatePresetCard(
            template: template,
            isSelected: controller.pages.every(
              (page) =>
                  page.backgroundKind == presentationTemplateBackground(template),
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

class _HtmlBackgroundControls extends StatefulWidget {
  const _HtmlBackgroundControls({
    required this.controller,
  });

  final PresentationController controller;

  @override
  State<_HtmlBackgroundControls> createState() => _HtmlBackgroundControlsState();
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
            .where((definition) =>
                query.isEmpty || _matches(definition, query))
            .toList(growable: false);
        final topicDefinitions = presentationBackgroundLibrary
            .where(
                (definition) => presentationBackgroundIsDark(definition.kind))
            .where((definition) =>
                query.isEmpty || _matches(definition, query))
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

class _HtmlComponentControls extends StatefulWidget {
  const _HtmlComponentControls({
    required this.controller,
  });

  final PresentationController controller;

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

    final searchResults = query.isEmpty
        ? null
        : <PresentationComponentDefinition>[
            for (final category in categories)
              ...presentationComponentDefinitionsForCategory(category)
                  .where((definition) => _matches(definition, query)),
          ];

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
          _ModelSearchField(
            controller: _searchController,
            hintText: 'Bileşen ara: isim, etiket, kategori...',
            onChanged: (value) => setState(() => _query = value),
            onClear: _clearSearch,
          ),
          const SizedBox(height: 12),
          if (searchResults == null)
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
            )
          else if (searchResults.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Eşleşen bileşen bulunamadı.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context._htmlMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            )
          else
            SizedBox(
              height: 420,
              child: ListView.separated(
                itemCount: searchResults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final definition = searchResults[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth >= 640
                          ? (constraints.maxWidth - 10) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          SizedBox(
                            width: cardWidth,
                            child: _ComponentLibraryCard(
                              definition: definition,
                              onAdd: () => controller
                                  .addComponentBlock(definition.kind),
                            ),
                          ),
                        ],
                      );
                    },
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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

const List<_TextColorOption> _textColorOptions = <_TextColorOption>[
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
    final fontStyles = fontQuery.isEmpty
        ? PresentationTextStyle.values
        : PresentationTextStyle.values
            .where(
              (style) =>
                  _htmlTextStyleLabel(style).toLowerCase().contains(fontQuery),
            )
            .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _ToolbarBadge(
              icon: Icons.text_fields_rounded,
              label: 'Metin Katmanı',
            ),
            if (selectedTextCount > 1)
              _ToolbarChip(label: '$selectedTextCount metin seçili'),
          ],
        ),
        const SizedBox(height: 12),
        _TextFieldControl(
          controller: textController,
          enabled: selectedTextBlock != null,
          onChanged: controller.updateSelectedText,
        ),
        const SizedBox(height: 18),
        Text(
          'Yazı Tipleri',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context._htmlInk,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Boyut, biçim, renk ve animasyon ayarları üst çubukta.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context._htmlMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
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
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
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
                          fontWeight: FontWeight.w700,
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
        decoration: _inputDecoration('Buraya metin yazin'),
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
    this.canvasZoom = 1,
    this.canvasPan = Offset.zero,
    this.showHint = false,
    this.interactive = true,
  });

  final PresentationController controller;

  /// Mobil kıstırma yakınlaştırması (1 = sığdır). Yalnızca mobil düzende 1'den
  /// büyüktür; geniş düzenlerde varsayılan 1 kalır.
  final double canvasZoom;

  /// Yakınlaştırınca kaydırma uzaklığı (tuval yerel koordinatında).
  final Offset canvasPan;

  final bool showHint;

  /// Tuval içi düzenleme jestleri (sürükleme, çoklu seçim, dokunma). Çoklu
  /// dokunma sırasında kapatılıp kıstırmanın sahne katmanına geçmesi sağlanır.
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = _shouldReduceHtmlMotion(
      context,
      controller.effectSettings,
    );
    final zoom = math.max(1.0, canvasZoom);

    // Yakınlaşınca tuvali sabitleyen çağrıların sürükleme deltalarını
    // görsel ölçekle böler; parmak 1:1 takip etmeye devam eder. Seçim
    // dikdörtgeni localPosition tabanlıdır ve dönüşüm altında otomatik
    // doğru kalır (burada değiştirilmez).
    Offset localDelta(Offset delta) =>
        zoom > 1.0001 ? delta / zoom : delta;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      decoration: BoxDecoration(
        color: context.sutolColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.sutolColors.outline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = math.max(0.0, constraints.maxWidth);
          final availableHeight = math.max(0.0, constraints.maxHeight);
          final stageWidth = math.min(
            availableWidth,
            availableHeight * (16 / 9),
          );
          final stageHeight = stageWidth / (16 / 9);

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
            canvasPan.dx.clamp(-maxPanX, maxPanX),
            canvasPan.dy.clamp(-maxPanY, maxPanY),
          );

          return Center(
            child: Transform.translate(
              offset: pan,
              child: Transform.scale(
                scale: zoom,
                alignment: Alignment.center,
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
                          interactive: interactive,
                          showHint: showHint,
                          showSurface: false,
                          showEmptyState: false,
                          textOpacity: 0,
                          onSelectTextBlock: controller.selectTextBlock,
                          onSelectComponentBlock:
                              controller.selectComponentBlock,
                          onDragSelectedText: (delta, size) =>
                              controller.moveSelectedText(
                            localDelta(delta),
                            size,
                          ),
                          onInlineTextChanged: controller.updateSelectedText,
                          onResizeSelectedTextWidth: (deltaX, size) =>
                              controller.resizeSelectedTextWidth(
                            localDelta(Offset(deltaX, 0)).dx,
                            size,
                          ),
                          onResizeSelectedComponent: (delta, size,
                                  {required fromLeft,
                                  required fromTop,
                                  required fromRight,
                                  required fromBottom}) =>
                              controller.resizeSelectedComponentByHandle(
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
                          onSecondaryTapCanvas: (globalPosition) {
                            _showCanvasContextMenu(
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
                            controller.rotateSelectedModel(localDelta(delta));
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
          ),
        ),
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
  const _SelectionContextBarSection({required this.controller});

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    final textBlock = controller.selectedTextBlock;
    final componentBlock = controller.selectedComponentBlock;
    List<Widget>? children;
    String? contentKey;
    if (textBlock != null) {
      contentKey = 'text:${textBlock.id}';
      children = _textChildren(context, textBlock);
    } else if (componentBlock != null) {
      contentKey = 'component:${componentBlock.id}';
      children = componentBlock.modelAssetId != null
          ? _modelChildren(componentBlock)
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
  }

  List<Widget> _textChildren(
    BuildContext context,
    PresentationTextBlock block,
  ) {
    return <Widget>[
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
        onTap: block.fontSize < 120
            ? () => controller.updateSelectedFontSize(
                  math.min(120, block.fontSize + 2),
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
      _MiniTextMoreButton(
        controller: controller,
        onAnimation: () => _showTextAnimationSheet(context),
        onColor: () => _showTextColorSheet(context),
        onGlow: () => _showGlowDialog(context),
      ),
    ];
  }

  /// Animasyon seçici: ikincil ayarlar "⋮" menüsünden açılır; birincil
  /// formatlama barını kalabalıklaştırmaz.
  void _showTextAnimationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _HtmlTextAnimationSheet(
        controller: controller,
      ),
    );
  }

  void _showTextColorSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _HtmlTextColorSheet(
        controller: controller,
      ),
    );
  }

  void _showGlowDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final block = controller.selectedTextBlock;
            return AlertDialog(
              title: const Text('Parlaklık'),
              content: block == null
                  ? const Text('Metin seçili değil.')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Slider(
                          value: block.glowIntensity,
                          min: 0,
                          max: 2,
                          divisions: 20,
                          onChanged: controller.updateSelectedGlowIntensity,
                        ),
                        Text(
                          '%${(block.glowIntensity * 100).round()}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _modelChildren(PresentationComponentBlock block) {
    return <Widget>[
      MiniToolLabeledToggle(
        icon: Icons.autorenew_rounded,
        label: 'Kendi Etrafında Dönme',
        active: block.modelAutoRotate,
        onTap: () =>
            controller.updateSelectedModelAutoRotate(!block.modelAutoRotate),
      ),
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
        onTap: () =>
            controller.updateSelectedModelOrbitEnabled(!block.modelOrbitEnabled),
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
}

/// Bağlamsal metin barındaki "⋮": animasyon, renk ve parlaklık gibi ikincil
/// ayarlar buradan açılır (birincil barı kalabalıklaştırmaz).
class _MiniTextMoreButton extends StatelessWidget {
  const _MiniTextMoreButton({
    required this.controller,
    required this.onAnimation,
    required this.onColor,
    required this.onGlow,
  });

  final PresentationController controller;
  final VoidCallback onAnimation;
  final VoidCallback onColor;
  final VoidCallback onGlow;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MiniTextMoreAction>(
      tooltip: 'Diğer metin ayarları',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      iconSize: 17,
      icon: Icon(
        Icons.more_horiz_rounded,
        color: context.sutolColors.onSurfaceVariant,
      ),
      onSelected: (action) {
        switch (action) {
          case _MiniTextMoreAction.animation:
            onAnimation();
          case _MiniTextMoreAction.color:
            onColor();
          case _MiniTextMoreAction.glow:
            onGlow();
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<_MiniTextMoreAction>>[
        PopupMenuItem<_MiniTextMoreAction>(
          value: _MiniTextMoreAction.animation,
          height: 46,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.animation_rounded),
            title: Text('Animasyon'),
          ),
        ),
        PopupMenuItem<_MiniTextMoreAction>(
          value: _MiniTextMoreAction.color,
          height: 46,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.palette_rounded),
            title: Text('Renk'),
          ),
        ),
        PopupMenuItem<_MiniTextMoreAction>(
          value: _MiniTextMoreAction.glow,
          height: 46,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.brightness_7_rounded),
            title: Text('Parlaklık'),
          ),
        ),
      ],
    );
  }
}

enum _MiniTextMoreAction {
  animation,
  color,
  glow,
}

/// "⋮" menüsündeki Animasyon seçici: seçili metnin giriş animasyonu.
class _HtmlTextAnimationSheet extends StatelessWidget {
  const _HtmlTextAnimationSheet({required this.controller});

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 380),
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.border),
          boxShadow: context.elevation2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Metin Animasyonu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context._htmlInk,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final current =
                      controller.selectedTextBlock?.textAnimation;
                  return ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      for (final animation
                          in PresentationTextAnimation.values)
                        ListTile(
                          dense: true,
                          leading: Icon(
                            animation == current
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 20,
                            color: animation == current
                                ? context.colors.primary
                                : context.sutolColors.onSurfaceVariant,
                          ),
                          title: Text(
                            _textAnimationLabel(animation),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: context._htmlInk,
                                  fontWeight: animation == current
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                          ),
                          onTap: () {
                            controller.updateSelectedTextAnimation(animation);
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "⋮" menüsündeki Renk seçici: seçili metin için renk paleti.
class _HtmlTextColorSheet extends StatelessWidget {
  const _HtmlTextColorSheet({required this.controller});

  final PresentationController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.border),
          boxShadow: context.elevation2,
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final currentHex = controller.selectedTextBlock?.textColorHex;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Yazı Rengi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context._htmlInk,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    for (final option in _textColorOptions)
                      GestureDetector(
                        key: ValueKey<String>(
                          'text-color-${option.hex ?? 'auto'}',
                        ),
                        onTap: () {
                          controller.updateSelectedTextColor(option.hex);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: option.color,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: currentHex == option.hex
                                  ? context.colors.primary
                                  : context.sutolColors.outline,
                              width: currentHex == option.hex ? 3 : 1,
                            ),
                          ),
                          child: currentHex == option.hex
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: option.hex == null
                                      ? context._htmlInk
                                      : const Color(0xFF1A2233),
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
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
    case _HtmlToolTab.photo:
      return 'Fotoğraflar';
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
    case _HtmlToolTab.photo:
      return 'Cihazindan fotograf yukle ve slayta yerlesin.';
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
