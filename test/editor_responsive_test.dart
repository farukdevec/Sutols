import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/html_presentation_editor_page.dart';
import 'package:sutol/ui/presentation_preview_page.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';
import 'package:sutol/ui/widgets/html_stage/html_page_stage.dart';
import 'package:sutol/ui/widgets/selection_mini_toolbar.dart';

import 'package:sutol/services/cookie_consent_service.dart';

void main() {
  // Test ortamının kare Ahem fontu yerine gerçek glif genişlikleriyle ölçüm
  // yapılır. Test MaterialApp'i varsayılan Material temasını (Roboto ailesi)
  // kullanır; SDK'daki Roboto glifleri gerçek cihaz davranışına en yakın
  // ölçüyü verir. Dock'un "Daha fazla"ya taşıma kararları ve rapor bunun
  // üzerine kuruludur.
  setUpAll(() async {
    if (kIsWeb) return;
    final flutterRoot =
        Platform.environment['FLUTTER_ROOT'] ?? r'C:\src\flutter';
    final fontFile = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    );
    if (fontFile.existsSync()) {
      final bytes = fontFile.readAsBytesSync();
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
    }
  });

  Future<PresentationController> pumpAt(
    WidgetTester tester,
    Size size, {
    ModelCameraPoseReader? modelCameraPoseReader,
  }) async {
    CookieConsentService.instance.state.value = CookieConsentState.accepted;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = PresentationController();
    addTearDown(controller.dispose);

    FlutterErrorDetails? captured;
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      captured ??= details;
      // Test çerçevesinin hata kaydını korumak için varsayılanı da çağır.
      prevOnError?.call(details);
    };
    await tester.pumpWidget(
      MaterialApp(
        home: HtmlPresentationEditorPage(
          controller: controller,
          modelCameraPoseReader: modelCameraPoseReader,
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = prevOnError;
    if (captured != null) {
      FlutterError.dumpErrorToConsole(captured!, forceReport: true);
    }
    return controller;
  }

  /// Birincil dock düğmesini açar.
  Future<void> openDockTool(WidgetTester tester, String label) async {
    final button = find.text(label);
    expect(button, findsWidgets, reason: '"$label" dock düğmesi bulunamadı');
    await tester.ensureVisible(button.first);
    await tester.pumpAndSettle();
    await tester.tap(button.first);
    await tester.pumpAndSettle();
  }

  /// "Daha fazla" menüsünü açar (geniş ekranda etiketli, dar ekranda kompakt ⋯).
  Future<void> openMoreMenu(WidgetTester tester) async {
    final dock = find.byKey(const ValueKey<String>('mobile-tool-dock'));
    final moreButton = find.descendant(
      of: dock,
      matching: find.byIcon(Icons.more_horiz_rounded),
    );
    expect(moreButton, findsOneWidget, reason: 'dock "Daha fazla" butonu');
    final labeled = find.text('Daha fazla');
    if (labeled.evaluate().isNotEmpty) {
      await tester.tap(labeled.first);
    } else {
      await tester.tap(moreButton);
    }
    await tester.pumpAndSettle();
  }

  /// "Daha fazla" menüsündeki aleti açar.
  Future<void> openMoreTool(WidgetTester tester, String menuLabel) async {
    await openMoreMenu(tester);
    await tester.tap(find.text(menuLabel).last);
    await tester.pumpAndSettle();
  }

  /// Alet dock'ta görünüyorsa doğrudan, değilse "Daha fazla" menüsünden açar.
  Future<void> openToolSmart(
    WidgetTester tester, {
    required String dockLabel,
    required String moreLabel,
  }) async {
    if (find.text(dockLabel).evaluate().isNotEmpty) {
      await openDockTool(tester, dockLabel);
    } else if (find.byTooltip(dockLabel).evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip(dockLabel));
      await tester.pumpAndSettle();
    } else {
      await openMoreTool(tester, moreLabel);
    }
  }

  testWidgets('studio header never claims an unsaved local draft is saved',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1280, 720));
    expect(find.text('Yerel taslak'), findsOneWidget);
    expect(find.textContaining('Kaydedildi'), findsNothing);
    controller.updateSelectedText('Henüz kaydedilmemiş değişiklik');
    await tester.pumpAndSettle();
    expect(find.text('Yerel taslak'), findsOneWidget);
    expect(find.textContaining('Kaydedildi'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final w in <double>[320, 360, 375, 390, 414]) {
    testWidgets('editor renders without overflow at ${w.toInt()}px (mobile)', (
      tester,
    ) async {
      await pumpAt(tester, Size(w, 800));
      expect(tester.takeException(), isNull);
      expect(find.byType(HtmlPresentationEditorPage), findsOneWidget);
    });
  }

  testWidgets('editor renders without overflow at 390x844 (mobile)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    expect(find.byType(HtmlPresentationEditorPage), findsOneWidget);
  });

  for (final tool in <(String, String)>[
    ('Metin', 'Metin'),
    ('Modeller', '3B Modeller'),
    ('Bileşen', 'Bileşenler'),
  ]) {
    for (final w in <double>[360, 390]) {
      testWidgets('"${tool.$1}" alet paneli ${w.toInt()}px bottom sheet taşmaz',
          (
        tester,
      ) async {
        await pumpAt(tester, Size(w, 844));
        expect(tester.takeException(), isNull);
        await openToolSmart(
          tester,
          dockLabel: tool.$1,
          moreLabel: tool.$2,
        );
        expect(tester.takeException(), isNull, reason: '${tool.$1} sheet @ $w');
      });
    }
  }

  for (final tool in <String>[
    'Şablonlar',
    'Arka Planlar',
    'Fotoğraf',
    'Geçişler'
  ]) {
    for (final w in <double>[360, 390]) {
      testWidgets(
        '"$tool" (daha fazla) paneli ${w.toInt()}px bottom sheet taşmaz',
        (tester) async {
          await pumpAt(tester, Size(w, 844));
          expect(tester.takeException(), isNull);
          await openMoreTool(tester, tool);
          expect(tester.takeException(), isNull, reason: '$tool sheet @ $w');
        },
      );
    }
  }

  testWidgets('slayt şeridi mobilde taşmaz ve slaytı seçer', (tester) async {
    await pumpAt(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    final controller = tester
        .widget<HtmlPresentationEditorPage>(
          find.byType(HtmlPresentationEditorPage),
        )
        .controller;
    controller.addPage();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('mobile-slide-strip')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(
      find.byKey(const ValueKey<String>('mobile-slide-strip-thumb-1')),
    );
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 1);
  });

  for (final size in <Size>[
    const Size(360, 800),
    const Size(390, 844),
    const Size(414, 896),
  ]) {
    testWidgets(
      'slayt şeridi ${size.width.toInt()}x${size.height.toInt()} kompakt ve hizalı',
      (tester) async {
        await pumpAt(tester, size);
        expect(tester.takeException(), isNull);

        final stripRect = tester.getRect(
          find.byKey(const ValueKey<String>('mobile-slide-strip')),
        );
        expect(stripRect.height, lessThan(50), reason: 'şerit kompakt kalmalı');

        final thumbRect = tester.getRect(
          find.byKey(const ValueKey<String>('mobile-slide-strip-thumb-0')),
        );
        expect(
          (thumbRect.width / thumbRect.height - 16 / 9).abs(),
          lessThan(0.05),
          reason: 'küçük resimler 16:9 olmalı',
        );

        final addRect = tester.getRect(
          find.byKey(const ValueKey<String>('mobile-slide-strip-add')),
        );
        expect(
          (addRect.center.dy - thumbRect.center.dy).abs(),
          lessThan(2),
          reason: '"+" küçük resimlerle aynı hizada olmalı',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('metin seçildiğinde formatlama barı mobilde taşmaz', (
    tester,
  ) async {
    await pumpAt(tester, const Size(360, 844));
    expect(tester.takeException(), isNull);
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.addTextBlock();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'selection bar @ 360px');
    expect(find.text('48'), findsOneWidget, reason: 'font size göstergesi');
  });

  testWidgets('metin seçiliyken metin paneli açılınca taşmaz', (tester) async {
    await pumpAt(tester, const Size(360, 844));
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.addTextBlock();
    await tester.pumpAndSettle();
    await openDockTool(tester, 'Metin');
    expect(tester.takeException(), isNull, reason: 'metin sheet + selection');
  });

  testWidgets('mobil araç paneli klavye açıkken görünür ve taşmasız kalır',
      (tester) async {
    await pumpAt(tester, const Size(390, 844));
    await openToolSmart(tester,
        dockLabel: 'Modeller', moreLabel: '3B Modeller');

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          (widget.decoration?.hintText ?? '').startsWith('Model ara:'),
    );
    expect(searchField, findsOneWidget);
    await tester.ensureVisible(searchField);
    await tester.tap(searchField);
    await tester.enterText(searchField, 'dünya');
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isTrue);
    expect(tester.getRect(searchField).bottom, lessThan(844 - 320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor renders without overflow at 768px (tablet)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(768, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor renders without overflow at 1024px (tablet)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1024, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor renders without overflow at 1150px (dar pencere)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1150, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('text surface menu follows undo and text selection',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1280, 900));
    final block = controller.selectedPage.textBlocks.first;
    controller.selectTextBlock(block.id);
    await tester.pumpAndSettle();
    final control = find.byKey(const ValueKey('selected-text-surface-menu'));
    await tester.ensureVisible(control);
    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Açık yüzey').last);
    await tester.pumpAndSettle();
    expect(
        controller.selectedTextBlock!.surface, PresentationTextSurface.light);
    expect(controller.selectedTextBlock!.text, block.text);
    controller.undo();
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<PopupMenuButton<PresentationTextSurface>>(control)
            .initialValue,
        PresentationTextSurface.none);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paused canvas drag is one undo step through pointer listeners',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1120, 800));
    controller.add3DModelBlock(
        findPresentation3DModelAsset('sutols-water-molecule')!);
    await tester.pumpAndSettle();
    final original = controller.selectedComponentBlock!.position;
    final target =
        tester.getTopLeft(find.byType(HtmlModelCanvas)) + const Offset(24, 24);
    final gesture = await tester.startGesture(target);
    await gesture.moveBy(const Offset(35, 0));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(25, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.selectedComponentBlock!.position, isNot(original));
    controller.undo();
    expect(controller.selectedComponentBlock!.position, original);
    controller.undo();
    expect(controller.selectedPage.componentBlocks, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('model lighting menu edits only exposure and can restore catalog',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1120, 800));
    final model = findPresentation3DModelAsset('sutols-water-molecule')!;
    controller.add3DModelBlock(model);
    await tester.pumpAndSettle();
    final before = controller.selectedComponentBlock!;
    final control = find.byKey(const ValueKey('selected-model-lighting'));
    await tester.ensureVisible(control);
    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daha aydınlık'));
    await tester.pumpAndSettle();
    expect(controller.selectedComponentBlock!.modelExposure,
        (model.exposure * 1.2).clamp(.1, 3));
    expect(
        tester.widget<HtmlModelCanvas>(find.byType(HtmlModelCanvas)).exposure,
        (model.exposure * 1.2).clamp(.1, 3));
    expect(controller.selectedComponentBlock!.modelOrbitTheta,
        before.modelOrbitTheta);
    expect(controller.selectedComponentBlock!.modelAnimationTime,
        before.modelAnimationTime);
    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Katalog aydınlatması'));
    await tester.pumpAndSettle();
    expect(controller.selectedComponentBlock!.modelExposure, isNull);
    expect(
        tester.widget<HtmlModelCanvas>(find.byType(HtmlModelCanvas)).exposure,
        model.exposure);
    expect(tester.takeException(), isNull);
  });

  testWidgets('background tone filter keeps search and selected slide',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1120, 800));
    await tester.tap(find.text('Arka Planlar'));
    await tester.pumpAndSettle();
    final search = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        (widget.decoration?.hintText ?? '').startsWith('Tema ara:'));
    await tester.enterText(search, 'GOKYUZU');
    await tester.pumpAndSettle();
    expect(find.text('Gökyüzü'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('background-tone-dark')));
    await tester.pumpAndSettle();
    expect(find.text('Gökyüzü'), findsNothing);
    expect(controller.selectedPage.backgroundKind,
        PresentationBackgroundKind.plainWhite);
    await tester.tap(find.byKey(const ValueKey('background-tone-all')));
    await tester.pumpAndSettle();
    expect(find.text('Gökyüzü'), findsOneWidget);
    expect(tester.widget<TextField>(search).controller!.text, 'GOKYUZU');
    expect(tester.takeException(), isNull);
  });

  testWidgets('arka plan sekmesi 1120px genişlikte taşmaz', (tester) async {
    final controller = await pumpAt(tester, const Size(1120, 800));
    expect(
      controller.selectedPage.backgroundKind,
      PresentationBackgroundKind.plainWhite,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Arka Planlar'));
    await tester.pumpAndSettle();
    expect(find.text('Sutols Sahne Koleksiyonu'), findsOneWidget);
    expect(find.text('${sutolStudioBackgroundLibrary.length} tema'),
        findsOneWidget);
    expect(find.text('Arka Plansız (Beyaz)'), findsOneWidget);
    expect(find.text('Teknoloji & Yapay Zeka'), findsOneWidget);
    await tester.ensureVisible(find.text('Teknoloji & Yapay Zeka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Teknoloji & Yapay Zeka'));
    await tester.pumpAndSettle();
    expect(
      controller.selectedPage.backgroundKind,
      PresentationBackgroundKind.studioTechnologyAi,
    );
    final liveBackground = tester.widget<HtmlLiveBackground>(
      find.byType(HtmlLiveBackground),
    );
    expect(
      liveBackground.kind,
      PresentationBackgroundKind.studioTechnologyAi,
      reason: 'Büyük önizleme seçilen gerçek HTML sahnesini kullanmalı',
    );
    expect(find.text('Açık Varyant'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('background-color-variant-toggle')),
    );
    await tester.pumpAndSettle();
    expect(controller.selectedPage.backgroundColorsInverted, isTrue);
    expect(
      tester
          .widget<HtmlLiveBackground>(find.byType(HtmlLiveBackground))
          .colorsInverted,
      isTrue,
    );
    expect(find.text('Animasyon Açık'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('background-animation-toggle')),
    );
    await tester.pumpAndSettle();
    expect(controller.selectedPage.backgroundAnimationEnabled, isFalse);
    expect(
      tester
          .widget<MiniToolLabeledToggle>(
            find.byKey(
              const ValueKey<String>('background-animation-toggle'),
            ),
          )
          .label,
      'Animasyon Kapalı',
    );
    expect(
      tester
          .widget<HtmlLiveBackground>(find.byType(HtmlLiveBackground))
          .animationEnabled,
      isFalse,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('background-animation-toggle')),
    );
    await tester.pumpAndSettle();
    final speedSlider = tester.widget<Slider>(
      find.byKey(
        const ValueKey<String>('background-animation-speed-slider'),
      ),
    );
    speedSlider.onChanged!(1.5);
    await tester.pumpAndSettle();
    expect(controller.selectedPage.backgroundAnimationSpeed, 1.5);
    expect(
      tester
          .widget<HtmlLiveBackground>(find.byType(HtmlLiveBackground))
          .animationSpeed,
      1.5,
    );
    expect(find.text('1.5×'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editör sahnesi içerik için gri platform iframe kurmaz', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));
    expect(
      find.byType(HtmlPageStage),
      findsNothing,
      reason:
          'Metin ve görseller Flutter katmanında çizilmeli; yalnızca sabit HTML arka planı kalmalı.',
    );
    expect(find.byType(HtmlLiveBackground), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final w in <double>[700, 760, 800, 860, 900, 1000, 1080]) {
    testWidgets('arka plan paneli ${w.toInt()}px genişlikte taşmaz', (
      tester,
    ) async {
      await pumpAt(tester, Size(w, 800));
      expect(tester.takeException(), isNull, reason: 'initial layout @$w');
      await openMoreTool(tester, 'Arka Planlar');
      expect(tester.takeException(), isNull, reason: 'backgrounds sheet @$w');
    });
  }

  for (final tab in <String>['Şablonlar', 'Bilesenler', 'Geçişler']) {
    testWidgets('dock dar ekranda araçları "Daha fazla"ya taşır, taşmaz', (
      tester,
    ) async {
      const labels = <String>['Metin', 'Modeller', 'Arka Plan', 'Bileşen'];
      int visibleCount() {
        var count = 0;
        for (final l in labels) {
          if (find.text(l).evaluate().isNotEmpty) count++;
        }
        return count;
      }

      await pumpAt(tester, const Size(580, 800));
      expect(visibleCount(), greaterThanOrEqualTo(1),
          reason: 'geniş mobil ekranda araçlar dockta');
      expect(tester.takeException(), isNull);

      await pumpAt(tester, const Size(320, 800));
      final narrowCount = visibleCount();
      expect(narrowCount, lessThanOrEqualTo(2),
          reason: 'dar ekranda taşan araç gizlenir');
      expect(find.text('Metin'), findsOneWidget,
          reason: 'Metin hep dockta kalır');
      expect(tester.takeException(), isNull);

      // Kompakt "⋯" butonu ile "Daha fazla" menüsü yine de açılır.
      await openMoreMenu(tester);
      expect(find.text('Fotoğraf'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dock daraldıkça görünür araç sayısı azalır (kademeli)', (
      tester,
    ) async {
      const labels = <String>['Metin', 'Modeller', 'Arka Plan', 'Bileşen'];
      int visibleCount() {
        var count = 0;
        for (final l in labels) {
          if (find.text(l).evaluate().isNotEmpty) count++;
        }
        return count;
      }

      final counts = <double, int>{};
      for (final w in <double>[320, 360, 390, 414, 580]) {
        await pumpAt(tester, Size(w, 800));
        expect(tester.takeException(), isNull, reason: 'dock @${w.toInt()}px');
        counts[w] = visibleCount();
      }
      expect(counts[320]!, lessThanOrEqualTo(counts[580]!));
      expect(counts[360]!, lessThanOrEqualTo(counts[390]!));
      expect(counts[390]!, lessThanOrEqualTo(counts[414]!));
      expect(counts[414]!, lessThanOrEqualTo(counts[580]!));
    });

    testWidgets('Modeller dock kısayolu modeller panelini açar',
        (tester) async {
      await pumpAt(tester, const Size(390, 844));
      await openToolSmart(tester,
          dockLabel: 'Modeller', moreLabel: '3B Modeller');
      expect(find.byKey(const ValueKey<String>('model-library-panel')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Fotoğraf" menü öğesi hızlı aksiyon sheetini açar', (
      tester,
    ) async {
      await pumpAt(tester, const Size(390, 800));
      await openMoreMenu(tester);
      await tester.tap(find.text('Fotoğraf'));
      await tester.pumpAndSettle();
      expect(find.text('Fotoğraf Ekle'), findsOneWidget);
      expect(find.text('Galeriden / Dosyadan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final size in <Size>[const Size(390, 844), const Size(800, 800)]) {
      testWidgets(
        '"$tab" sekmesi ${size.width.toInt()}px genişlikte taşmaz',
        (tester) async {
          await pumpAt(tester, size);
          expect(tester.takeException(), isNull);
          final menuLabel = switch (tab) {
            'Şablonlar' => 'Şablonlar',
            'Bilesenler' => 'Bileşenler',
            'Geçişler' => 'Geçişler',
            _ => tab,
          };
          if (tab == 'Bilesenler') {
            await openToolSmart(
              tester,
              dockLabel: 'Bileşenler',
              moreLabel: menuLabel,
            );
          } else {
            await openMoreTool(tester, menuLabel);
          }
          expect(tester.takeException(), isNull, reason: '$tab @ $size');
        },
      );
    }
  }

  for (final size in <Size>[const Size(390, 844), const Size(800, 800)]) {
    testWidgets('"Metin" sekmesi ${size.width.toInt()}px genişlikte taşmaz', (
      tester,
    ) async {
      await pumpAt(tester, size);
      expect(tester.takeException(), isNull);
      await openDockTool(tester, 'Metin');
      expect(tester.takeException(), isNull, reason: 'Metin @ $size');
    });
  }

  testWidgets('editor renders without overflow at 1400px (studio)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));
    final brandedHeader = tester.widget<Container>(
      find.byKey(const ValueKey<String>('studio-branded-header')),
    );
    final brandedDecoration = brandedHeader.decoration! as BoxDecoration;
    final headerRect = tester.getRect(
      find.byKey(const ValueKey<String>('studio-branded-header')),
    );
    expect(headerRect.left, 0);
    expect(headerRect.top, 0);
    expect(headerRect.right, 1400);
    expect(find.text('Dosya'), findsNothing);
    final brandedGradient = brandedDecoration.gradient! as LinearGradient;
    expect(
      brandedGradient.colors,
      const <Color>[Color(0xFF0A7E82), Color(0xFF006471)],
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('studio-brand-mark')),
        matching: find.byType(ColorFiltered),
      ),
      findsOneWidget,
    );
    final logoRect = tester.getRect(
      find.byKey(const ValueKey<String>('studio-brand-mark')),
    );
    final titleRect = tester.getRect(
      find.byKey(const ValueKey<String>('studio-presentation-title')),
    );
    expect(logoRect.width, greaterThanOrEqualTo(44));
    expect(logoRect.right, lessThan(titleRect.left));
    expect(find.byKey(const ValueKey<String>('studio-settings-icon')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('studio-profile-icon')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('studio-brand-wordmark')),
        findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('studio-brand-mark')),
    );
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey<String>('brand-menu-home')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('brand-menu-settings')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('brand-menu-presentations')),
      findsOneWidget,
    );
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Sunumlarım'), findsOneWidget);
    await tester.tapAt(const Offset(1390, 890));
    await tester.pumpAndSettle();

    final rail = find.byKey(const ValueKey<String>('studio-tool-rail'));
    final railRect = tester.getRect(rail);
    expect(railRect.top, greaterThan(700));
    expect(railRect.width, greaterThan(railRect.height));
    expect(find.text('Sahneler'), findsOneWidget);
    final selectionBar = find.byKey(
      const ValueKey<String>('selection-context-bar'),
    );
    final effectControl = find.byKey(
      const ValueKey<String>('selected-text-effect-control'),
    );
    expect(selectionBar, findsOneWidget);
    expect(effectControl, findsOneWidget);
    expect(
      tester.getRect(effectControl).right,
      lessThanOrEqualTo(tester.getRect(selectionBar).right - 8),
      reason: 'Üst düzenleme barının son kontrolü görünür kalmalı',
    );
    expect(
        find.descendant(of: rail, matching: find.text('HTML')), findsNothing);
    expect(
        find.descendant(of: rail, matching: find.text('Sunum')), findsNothing);
    expect(
      find.descendant(of: rail, matching: find.text('Disa Aktar')),
      findsNothing,
    );
    expect(find.descendant(of: rail, matching: find.text('PDF')), findsNothing);

    expect(find.text('HTML Disa Aktar'), findsNothing);
    expect(find.text('Kaydet'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('studio-save-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('HTML formatı'), findsOneWidget);
    expect(
      find.text('PDF formatı (animasyonlar çalışmaz)'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'unsupported HTML export reports the limitation and preserves edits',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1400, 900));
    final before = PresentationProjectCodec.encodeProject(
        pages: controller.pages, effectSettings: controller.effectSettings);
    await tester.tap(find.byKey(const ValueKey('studio-save-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HTML formatı'));
    await tester.pumpAndSettle();
    expect(find.text('HTML dışa aktarma web tarayıcısında kullanılabilir.'),
        findsOneWidget);
    expect(
        PresentationProjectCodec.encodeProject(
            pages: controller.pages, effectSettings: controller.effectSettings),
        before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsupported PDF export preserves edits and remains retryable',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1400, 900));
    final before = PresentationProjectCodec.encodeProject(
        pages: controller.pages, effectSettings: controller.effectSettings);
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.byKey(const ValueKey('studio-save-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PDF formatı (animasyonlar çalışmaz)'));
      await tester.pumpAndSettle();
      expect(find.text('PDF dışa aktarma web tarayıcısında kullanılabilir.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    expect(
        PresentationProjectCodec.encodeProject(
            pages: controller.pages, effectSettings: controller.effectSettings),
        before);
  });

  for (final width in [390.0, 623.0]) {
    testWidgets('mobile header menus respond to icon taps at $width',
        (tester) async {
      await pumpAt(tester, Size(width, 800));
      await tester.tap(find.byTooltip('Dışa Aktar'));
      await tester.pumpAndSettle();
      expect(find.text('HTML Dışa Aktar'), findsOneWidget);
      expect(find.text('PDF Olarak Yazdır'), findsOneWidget);
      await tester.tap(find.text('PDF Olarak Yazdır'));
      await tester.pumpAndSettle();
      expect(find.text('PDF dışa aktarma web tarayıcısında kullanılabilir.'),
          findsOneWidget);
      await tester.tap(find.byTooltip('Diğer işlemler'));
      await tester.pumpAndSettle();
      expect(find.text('Projeyi Kaydet'), findsOneWidget);
      expect(find.text('Proje Yükle'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mobile header menus have one working keyboard stop each',
      (tester) async {
    await pumpAt(tester, const Size(390, 844));
    final visited = <FocusNode>{};
    final menuStops = <String, int>{};
    for (var i = 0; i < 80; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final focus = FocusManager.instance.primaryFocus;
      if (focus == null) continue;
      if (!visited.add(focus)) break;
      String? menu;
      focus.context?.visitAncestorElements((element) {
        final widget = element.widget;
        if (widget is PopupMenuButton &&
            ['Dışa Aktar', 'Diğer işlemler'].contains(widget.tooltip)) {
          menu = widget.tooltip;
          return false;
        }
        return true;
      });
      if (menu == null) continue;
      menuStops.update(menu!, (count) => count + 1, ifAbsent: () => 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(
          find.text(menu == 'Dışa Aktar' ? 'PDF Olarak Yazdır' : 'Proje Yükle'),
          findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    }
    expect(menuStops, {'Dışa Aktar': 1, 'Diğer işlemler': 1});
    expect(tester.takeException(), isNull);
  });

  testWidgets('yarım ekranda üst bar ince ve sade kalır', (tester) async {
    await pumpAt(tester, const Size(1000, 800));

    final header = find.byKey(
      const ValueKey<String>('condensed-editor-header'),
    );
    expect(header, findsOneWidget);
    final decoration =
        tester.widget<Container>(header).decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;
    expect(
      gradient.colors,
      const <Color>[Color(0xFF0A7E82), Color(0xFF006471)],
    );
    expect(decoration.boxShadow, hasLength(2));
    expect(decoration.boxShadow!.last.color, const Color(0x160A7E82));
    expect(tester.getSize(header).height, lessThanOrEqualTo(70));
    expect(
      find.byKey(const ValueKey<String>('condensed-brand-mark')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('condensed-brand-mark')),
        matching: find.byType(ColorFiltered),
      ),
      findsOneWidget,
      reason: 'Yarım ekran logosu beyaz marka stilini korumalı',
    );
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    expect(find.text('Dosya'), findsNothing);
    expect(
      find.text(
        'Arka plan, metin, akis ve efekt ayarlarini ayni sahnede duzenle.',
      ),
      findsNothing,
    );
    expect(find.text('HTML / CSS'), findsNothing);
    expect(find.text('Sunum Modu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobil üst bar marka rengini kullanır', (tester) async {
    await pumpAt(tester, const Size(390, 844));

    final header = find.byKey(const ValueKey<String>('mobile-editor-header'));
    final decoration =
        tester.widget<Container>(header).decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;
    expect(
      gradient.colors,
      const <Color>[Color(0xFF0A7E82), Color(0xFF006471)],
    );
    expect(decoration.boxShadow, hasLength(2));
    expect(decoration.boxShadow!.last.color, const Color(0x160A7E82));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('mobile-brand-mark')),
        matching: find.byType(ColorFiltered),
      ),
      findsOneWidget,
      reason: 'Mobil logo beyaz marka stilini korumalı',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('font listesi gerçek eski ve Google fontlarını birlikte gösterir',
      (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));

    expect(find.text('Bilim · Dramatik'), findsNothing);
    expect(find.text('Güneş · Temiz'), findsNothing);
    expect(find.text('Fizik · Deneysel'), findsNothing);
    expect(find.text('Teknoloji · Dramatik'), findsNothing);
    expect(find.text('Oswald'), findsWidgets);
    expect(tester.widget<Text>(find.text('Great Vibes')).style?.fontFamily,
        'Great Vibes');
    expect(tester.widget<Text>(find.text('Dancing Script')).style?.fontFamily,
        'Dancing Script');
    expect(
        tester.widget<Text>(find.text('Lobster')).style?.fontFamily, 'Lobster');
    expect(
        tester.widget<Text>(find.text('Roboto')).style?.fontFamily, 'Roboto');
    await tester.enterText(
      find.widgetWithText(
          TextField, 'Yazı tipi ara: klasik, serif, kaligrafi...'),
      'Roboto',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Roboto'),
      findsNWidgets(2),
      reason: 'Arama metni ve filtrelenen Roboto font satırı görünmeli',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('seçilen font editör metnine ve düzenleme alanına uygulanır', (
    tester,
  ) async {
    final controller = await pumpAt(tester, const Size(1400, 900));
    controller.updateSelectedText('Font önizleme metni');
    await tester.pump();
    await tester.ensureVisible(find.text('Great Vibes'));
    await tester.pump();
    await tester.tap(find.text('Great Vibes'));
    await tester.pump();
    expect(
      controller.selectedTextBlock?.textStyle,
      PresentationTextStyle.klasikGreatVibes,
    );
    controller.updateSelectedFontWeight(300);
    await tester.pump();
    expect(controller.selectedTextBlock?.fontWeight, 300);

    final editorCanvas = find.byKey(
      const ValueKey<String>('editor-page-canvas-page-1'),
    );
    final renderedText = find.descendant(
      of: editorCanvas,
      matching: find.text('Font önizleme metni'),
    );
    expect(renderedText, findsOneWidget);
    expect(
      tester.widget<Text>(renderedText).style?.fontFamily,
      'Great Vibes',
    );
    expect(
        tester.widget<Text>(renderedText).style?.fontWeight, FontWeight.w300);
    expect(
      tester.widget<Text>(renderedText).style?.fontVariations?.single.value,
      300,
    );

    final renderedTextCenter = tester.getCenter(renderedText);
    await tester.tapAt(renderedTextCenter);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(renderedTextCenter);
    await tester.pump();
    final inlineEditor = find.descendant(
      of: editorCanvas,
      matching: find.byType(TextField),
    );
    expect(inlineEditor, findsOneWidget);
    expect(
      tester.widget<TextField>(inlineEditor).style?.fontFamily,
      'Great Vibes',
    );
    expect(
      tester.widget<TextField>(inlineEditor).style?.fontWeight,
      FontWeight.w300,
    );
    expect(
      tester
          .widget<TextField>(inlineEditor)
          .style
          ?.fontVariations
          ?.single
          .value,
      300,
    );

    controller.updateSelectedTextStyle(PresentationTextStyle.googleRobotoMono);
    await tester.pump();
    expect(
      tester.widget<TextField>(inlineEditor).style?.fontFamily,
      'Roboto Mono',
    );

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    // Responsive resize retains the active inline edit rather than replacing
    // it with a display Text widget and losing keyboard focus.
    final mobileInlineEditor = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.controller?.text == 'Font önizleme metni');
    expect(mobileInlineEditor, findsOneWidget);
    final mobileStyle = tester.widget<TextField>(mobileInlineEditor).style;
    expect(mobileStyle?.fontFamily, 'Roboto Mono');
    expect(mobileStyle?.fontWeight, FontWeight.w300);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('yazı ağırlığı ve efekti sunum modunda ve mobilde korunur', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.updateSelectedText('Sunum ağırlık önizlemesi');
    controller.updateSelectedFontWeight(900);
    controller.updateSelectedTextEffect(PresentationTextEffect.shimmer);

    await tester.pumpWidget(
      MaterialApp(
        home: PresentationPreviewPage(
          controller: controller,
          useFullscreen: false,
        ),
      ),
    );
    await tester.pump();

    Text previewText() => tester.widget<Text>(
          find.text('Sunum ağırlık önizlemesi'),
        );

    expect(previewText().style?.fontWeight, FontWeight.w900);
    expect(previewText().style?.fontVariations?.single.value, 900);
    expect(find.byType(ShaderMask), findsNothing);
    await tester.pump(const Duration(milliseconds: 700));
    final shimmerSpan = previewText().textSpan! as TextSpan;
    expect(
      shimmerSpan.children
          ?.whereType<TextSpan>()
          .any((span) => span.style?.shadows?.isNotEmpty ?? false),
      isTrue,
      reason: 'Işıltı dalgası en az bir harfi ayrı olarak parlatmalı',
    );

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    expect(previewText().style?.fontWeight, FontWeight.w900);
    expect(previewText().style?.fontVariations?.single.value, 900);
    expect(find.byType(ShaderMask), findsNothing);

    controller.updateSelectedTextEffect(PresentationTextEffect.blink);
    await tester.pump();
    expect(find.byType(ShaderMask), findsNothing);
    expect(
      find.ancestor(
        of: find.text('Sunum ağırlık önizlemesi'),
        matching: find.byType(Opacity),
      ),
      findsWidgets,
    );

    controller.updateSelectedTextEffect(PresentationTextEffect.neonPulse);
    await tester.pump();
    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('metin panelinin en üstündeki buton yeni metni ekleyip seçer', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));
    final controller = tester
        .widget<HtmlPresentationEditorPage>(
          find.byType(HtmlPresentationEditorPage),
        )
        .controller;
    final initialCount = controller.selectedPage.textBlocks.length;
    final addButton = find.byKey(
      const ValueKey<String>('add-text-box-button'),
    );

    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(controller.selectedPage.textBlocks.length, initialCount + 1);
    expect(controller.selectedTextBlock, isNotNull);
    expect(
      controller.selectedTextBlock,
      same(controller.selectedPage.textBlocks.last),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('bileşen kütüphanesi studio yan panelinin tamamını kullanır', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));
    await tester.tap(find.text('Bileşen').first);
    await tester.pumpAndSettle();

    final inspectorRect = tester.getRect(
      find.byKey(const ValueKey<String>('studio-inspector-panel')),
    );
    final libraryRect = tester.getRect(
      find.byKey(const ValueKey<String>('component-library-panel')),
    );
    final resultsRect = tester.getRect(
      find.byKey(const ValueKey<String>('component-library-results')),
    );

    expect(libraryRect.bottom, closeTo(inspectorRect.bottom - 16, 1));
    expect(resultsRect.bottom, closeTo(libraryRect.bottom, 1));
    expect(resultsRect.height, greaterThan(500));
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('component-library-results'),
        ),
        matching: find.byType(ExpansionTile),
      ),
      findsNothing,
      reason: 'Bileşenler kategori açılırları olmadan düz listelenmeli',
    );

    final searchField = find.descendant(
      of: find.byKey(const ValueKey<String>('component-library-panel')),
      matching: find.byType(TextField),
    );
    await tester.enterText(searchField, 'Mürekkep Akan Kalem');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('component-library-results'),
        ),
        matching: find.text('Mürekkep Akan Kalem'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('3B model kütüphanesi studio yan panelini homojen doldurur', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));
    await tester.tap(find.text('3D Modeller').first);
    await tester.pump();

    final inspectorRect = tester.getRect(
      find.byKey(const ValueKey<String>('studio-inspector-panel')),
    );
    final libraryRect = tester.getRect(
      find.byKey(const ValueKey<String>('model-library-panel')),
    );
    final resultsRect = tester.getRect(
      find.byKey(const ValueKey<String>('model-library-results')),
    );

    expect(libraryRect.bottom, closeTo(inspectorRect.bottom - 16, 1));
    expect(resultsRect.bottom, closeTo(libraryRect.bottom - 14, 1));
    expect(resultsRect.height, greaterThan(500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('model capability filters preserve search and can be cleared',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await pumpAt(tester, const Size(1400, 900));
    await tester.tap(find.text('3D Modeller').first);
    await tester.pumpAndSettle();
    final search = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Model ara: isim, etiket, kategori...');
    await tester.enterText(search, 'Su Molekülü');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('model-capability-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animasyonlu').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Bu özellik ve arama filtreleriyle'),
        findsOneWidget);
    expect((tester.widget<TextField>(search).controller!).text, 'Su Molekülü');
    await tester.tap(find.byKey(const ValueKey('model-capability-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tüm özellikler').last);
    await tester.pumpAndSettle();
    expect(find.text('Su Molekülü'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('küçük resmi olmayan paket 3B modelleri kütüphanede görünür', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await pumpAt(tester, const Size(1400, 900));
    await tester.tap(find.text('3D Modeller').first);
    await tester.pumpAndSettle();
    final search = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Model ara: isim, etiket, kategori...');
    for (final item in <(String, String)>[
      ('anitkabir', 'Anıtkabir'),
      ('yolcu-ucagi', 'Yolcu Uçağı'),
      ('gercekci-dunya', 'Gerçekçi Dünya')
    ]) {
      // Search brings an off-screen entry into the virtualized result list.
      await tester.enterText(search, item.$2);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey<String>('model-card-${item.$1}')),
          findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'rejecting a model suggestion preserves the slide and supports undo',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1400, 900));
    controller.selectTextBlock(controller.selectedPage.textBlocks.first.id);
    controller.updateSelectedText('Atom elektron çekirdek');
    await tester.pumpAndSettle();
    await tester.tap(find.text('3D Modeller').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Slayta uygun'));
    await tester.tap(find.text('Slayta uygun'));
    await tester.pumpAndSettle();
    final before = PresentationProjectCodec.encodeProject(
        pages: controller.pages, effectSettings: controller.effectSettings);
    final dismiss =
        find.byKey(const ValueKey('dismiss-model-suggestion-sutols-bohr-atom'));
    await tester.ensureVisible(dismiss);
    await tester.tap(dismiss);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('model-card-sutols-bohr-atom')),
        findsNothing);
    expect(
        PresentationProjectCodec.encodeProject(
            pages: controller.pages, effectSettings: controller.effectSettings),
        before);
    await tester.tap(find.descendant(
        of: find.byType(SnackBar), matching: find.byType(TextButton)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('model-card-sutols-bohr-atom')),
        findsOneWidget);
    await tester.tap(dismiss);
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Gizlenen önerileri geri getirin'), findsOneWidget);
    final reset = find.byKey(const ValueKey('restore-model-suggestions'));
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('model-card-sutols-bohr-atom')),
        findsOneWidget);
    await tester.tap(dismiss);
    await tester.pumpAndSettle();
    controller.updateSelectedText('Atom elektron çekirdek yapısı');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('model-card-sutols-bohr-atom')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slayta uygun öneriler açıklanır ve metin değişince güncellenir',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1400, 900));
    controller.selectTextBlock(controller.selectedPage.textBlocks.first.id);
    controller.updateSelectedText('Atom elektron çekirdek');
    await tester.pumpAndSettle();
    await tester.tap(find.text('3D Modeller').first);
    await tester.pumpAndSettle();
    final before = controller.selectedPage.componentBlocks.length;
    await tester.ensureVisible(find.text('Slayta uygun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Slayta uygun'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('model-card-sutols-bohr-atom')),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((w) =>
            w is Tooltip && (w.message ?? '').startsWith('Eşleşen kelimeler:')),
        findsWidgets);
    expect(controller.selectedPage.componentBlocks.length, before);
    controller.updateSelectedText('Şiir ve edebiyat');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('model-card-sutols-bohr-atom')),
        findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('benzer model keşfi aramayı sıfırlar ve slaytı değiştirmez',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1400, 900));
    await tester.tap(find.text('3D Modeller').first);
    await tester.pumpAndSettle();
    final search = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Model ara: isim, etiket, kategori...');
    await tester.enterText(search, 'Güneş Paneli');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    final before = controller.selectedPage.componentBlocks.length;
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey<String>('model-card-sutols-solar-panel')),
        matching: find.byTooltip('Benzerlerini göster')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    expect(find.text('Benzer modeller'), findsOneWidget);
    expect(find.text('Benzerleri: Güneş Paneli'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('model-card-sutols-solar-panel')),
        findsNothing);
    expect(controller.selectedPage.componentBlocks.length, before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop brand menu opens quick guide without changing the deck',
      (tester) async {
    final controller = await pumpAt(tester, const Size(1400, 900));
    final pages = controller.pages.toList();
    await tester.tap(find.byKey(const ValueKey<String>('studio-brand-mark')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('brand-menu-guide')));
    await tester.pumpAndSettle();
    expect(find.text('Fikrini slaytlara dönüştür'), findsOneWidget);
    await tester.tap(find.text('Kapat'));
    await tester.pumpAndSettle();
    expect(controller.pages, orderedEquals(pages));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'short desktop switches into and out of the model panel without infinite constraints',
      (tester) async {
    await pumpAt(tester, const Size(1280, 720));
    await tester.tap(find.text('3D Modeller').first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('model-library-panel')),
        findsOneWidget);
    final canvas =
        find.byKey(const ValueKey<String>('editor-page-canvas-page-1'));
    expect(tester.getSize(canvas).width, greaterThan(400));
    expect(tester.getSize(canvas).height, greaterThan(220));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Metin').first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'scene thumbnail uses a poster and never creates a live model canvas',
      (tester) async {
    const page =
        PresentationPage(id: 'poster', textBlocks: [], componentBlocks: [
      PresentationComponentBlock(
          id: 'water',
          modelAssetId: 'sutols-water-molecule',
          position: Offset.zero,
          size: Size(1, 1),
          modelAutoRotate: true),
    ]);
    await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
            width: 160,
            height: 90,
            child: PresentationPageThumbnailCanvas(page: page))));
    await tester.pumpAndSettle();
    expect(find.byType(HtmlModelCanvas), findsNothing);
    expect(
        find.byWidgetPredicate(
            (w) => w is PresentationPageCanvas && w.staticPreview),
        findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is TickerMode && !w.enabled),
        findsWidgets);
    expect(page.componentBlocks.single.modelAutoRotate, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('model favorisi eklemek slayta model eklemez ve filtrede bulunur',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await pumpAt(tester, const Size(1400, 900));
    await tester.tap(find.text('3D Modeller').first);
    await tester.pumpAndSettle();
    final search = find.byWidgetPredicate((widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Model ara: isim, etiket, kategori...');
    await tester.enterText(search, 'Güneş Paneli');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    final before = controller.selectedPage.componentBlocks.length;
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey<String>('model-card-sutols-solar-panel')),
        matching: find.byTooltip('Favorilere ekle')));
    await tester.pumpAndSettle();
    expect(controller.selectedPage.componentBlocks.length, before);
    await tester.tap(find.text('Favoriler'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('model-card-sutols-solar-panel')),
        findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey<String>('model-card-sutols-solar-panel')),
        matching: find.byTooltip('Favoriden çıkar')));
    await tester.pumpAndSettle();
    expect(find.text('Yıldız düğmesiyle favori modeller ekleyin.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('şablon kartları canlı sahne yerine statik küçük resim kullanır',
      (
    tester,
  ) async {
    await pumpAt(tester, const Size(1400, 900));
    await tester.tap(find.text('Şablon').first);
    await tester.pumpAndSettle();

    final academicThumbnail = find.byKey(
      const ValueKey<String>('template-preview-academic'),
    );
    expect(academicThumbnail, findsOneWidget);
    expect(
      find.descendant(
        of: academicThumbnail,
        matching: find.byType(HtmlPageStage),
      ),
      findsNothing,
      reason: 'Şablon thumbnail içinde HTML/iframe sahnesi kurulmamalı',
    );
    expect(tester.takeException(), isNull);
  });

  // Son kontrol: hedeflenen ekran genişliklerinde mobil kompozisyon bütünü.
  const reportSizes = <Size>[
    Size(320, 800),
    Size(360, 800),
    Size(375, 812),
    Size(390, 844),
    Size(414, 896),
  ];

  for (final size in reportSizes) {
    testWidgets(
      'mobil kompozisyon kontrolü ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await pumpAt(tester, size);
        expect(tester.takeException(), isNull, reason: 'ilk yerleşim @$size');

        // Header: yazısız Sutols amblemi ve kritik kontroller doğrudan.
        expect(
          find.byKey(const ValueKey<String>('mobile-brand-mark')),
          findsOneWidget,
          reason: 'marka @$size',
        );
        for (final tooltip in <String>[
          'Geri al',
          'Yinele',
          'Sunum Modu',
          'Dışa Aktar',
        ]) {
          expect(
            find.byTooltip(tooltip),
            findsOneWidget,
            reason: '"$tooltip" header da @$size',
          );
        }

        // Tuval: büyük, 16:9, yatayda ortalanmış, kırpılmamış.
        final canvasRect = tester.getRect(
          find.byType(PresentationPageCanvas).first,
        );
        expect(
          (canvasRect.width / canvasRect.height - 16 / 9).abs(),
          lessThan(0.02),
          reason: 'tuval 16:9 @$size',
        );
        expect(
          canvasRect.width,
          greaterThan(size.width * 0.9),
          reason: 'tuval ekranın ≥%90 genişliğinde @$size',
        );
        expect(
          (canvasRect.left - (size.width - canvasRect.right)).abs(),
          lessThan(2),
          reason: 'tuval ortalanmış @$size',
        );

        // Slayt şeridi: tuval alanının hemen altında (8-12px), 48px kompakt.
        final stripRect = tester.getRect(
          find.byKey(const ValueKey<String>('mobile-slide-strip')),
        );
        expect(stripRect.height, inInclusiveRange(40, 50));
        final stageCardRect = tester.getRect(
          find
              .byWidgetPredicate(
                (w) => w.runtimeType.toString() == '_HtmlStageCard',
              )
              .first,
        );
        expect(
          stripRect.top - stageCardRect.bottom,
          inInclusiveRange(8, 12),
          reason: 'şerit tuval alanına 8-12px yakın @$size',
        );

        // "+" yalnızca şeritte; iskelede yok.
        final dock = find.byKey(const ValueKey<String>('mobile-tool-dock'));
        expect(
          find.descendant(of: dock, matching: find.byIcon(Icons.add_rounded)),
          findsNothing,
          reason: 'iskelede "+" olmamalı @$size',
        );
        expect(
          find.byKey(const ValueKey<String>('mobile-slide-strip-add')),
          findsOneWidget,
        );

        // Dock araçları: öncelik sırasıyla görünür; gizlenenler menüde.
        const labels = <String>[
          'Şablon',
          'Arka Plan',
          'Metin',
          'Modeller',
          'Bileşen'
        ];
        final visible =
            labels.where((l) => find.text(l).evaluate().isNotEmpty).toList();
        expect(visible, isNotEmpty, reason: 'dock boş olmamalı @$size');
        for (final l in labels) {
          if (!visible.contains(l)) {
            // Gizlenen araç "Daha fazla" menüsünde erişilebilir olmalı.
            await openMoreMenu(tester);
            final menuText = switch (l) {
              'Arka Plan' => 'Arka Planlar',
              'Bileşen' => 'Bileşenler',
              'Modeller' => '3B Modeller',
              'Şablon' => 'Şablonlar',
              _ => l,
            };
            expect(
              find.text(menuText),
              findsWidgets,
              reason: 'gizlenen "$l" ($menuText) menüde olmalı @$size',
            );
            await tester.tapAt(const Offset(10, 10));
            await tester.pumpAndSettle();
          }
        }

        // Menü içeriği: tüm sabit kategoriler + yeni Ses/Animasyonlar.
        await openMoreMenu(tester);
        final menuItems = <String>[
          'Şablonlar',
          'Arka Planlar',
          'Geçişler',
          'Fotoğraf',
          'Ses',
          'Animasyonlar',
        ];
        for (final m in menuItems) {
          expect(
            find.text(m),
            findsWidgets,
            reason: 'menü öğesi "$m" @$size',
          );
        }
        // Dock'ta görünen araçlar menüde tekrarlanmaz (aynı işlev iki buton).
        if (visible.contains('Metin')) {
          expect(find.text('Metin'), findsOneWidget,
              reason: 'Metin tek @$size');
        }
        if (visible.contains('Modeller')) {
          expect(find.text('Modeller'), findsWidgets,
              reason: 'Modeller dockta @$size');
        }
        final inMenu = <String>[
          for (final l in labels)
            if (!visible.contains(l) && find.text(l).evaluate().isNotEmpty) l,
          for (final m in menuItems)
            if (find.text(m).evaluate().isNotEmpty) m,
        ];
        final moreLabeled = find.text('Daha fazla').evaluate().isNotEmpty;
        debugPrint(
          'MOBILE REPORT @${size.width.toInt()}x${size.height.toInt()}: '
          'dock=[${visible.join(', ')}] '
          'canvas=${canvasRect.width.toStringAsFixed(0)}x'
          '${canvasRect.height.toStringAsFixed(0)}px '
          'moreButton=${moreLabeled ? 'label' : 'icon'} '
          'more=[${inMenu.join(', ')}]',
        );
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'rapor @$size');
      },
    );
  }

  testWidgets('"Ses" menü öğesi Arka Planlar (Müzik ve Ses) panelini açar', (
    tester,
  ) async {
    await pumpAt(tester, const Size(390, 844));
    await openMoreMenu(tester);
    await tester.tap(find.text('Ses').last);
    await tester.pumpAndSettle();
    expect(find.text('Arka Plan Kütüphanesi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Animasyonlar" menü öğesi öğe animasyonu panelini açar', (
    tester,
  ) async {
    await pumpAt(tester, const Size(390, 844));
    await openMoreMenu(tester);
    await tester.tap(find.text('Animasyonlar').last);
    await tester.pumpAndSettle();
    expect(find.text('Öğe Animasyonu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'FPS sanal turda WASD ve oklar bakış yönünde hızlı hareket eder',
    (tester) async {
      final controller = await pumpAt(tester, const Size(1440, 900));
      controller.add3DModelBlock(
        const Presentation3DModelAsset(
          id: 'anitkabir',
          label: 'FPS test model',
          assetPath: 'https://example.com/fps.glb',
          category: 'Test',
          tags: <String>[],
          byteSize: 0,
          sha256: '',
        ),
      );
      controller.updateSelectedModelTourEnabled(true);
      await tester.pump();
      expect(controller.selectedComponentBlock!.modelOrbitTheta, 0);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
      for (var frame = 0; frame < 8; frame += 1) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
      await tester.pump();

      var model = controller.selectedComponentBlock!;
      expect(model.modelTargetX, greaterThan(1));
      expect(model.modelTargetZ, lessThan(-1));

      final afterWasdX = model.modelTargetX;
      final afterWasdZ = model.modelTargetZ;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      for (var frame = 0; frame < 8; frame += 1) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      model = controller.selectedComponentBlock!;
      expect(model.modelTargetX, lessThan(afterWasdX - 1));
      expect(model.modelTargetZ, greaterThan(afterWasdZ + 1));
    },
  );

  testWidgets('ESC sanal tur kamerasını editör sahnesine kalıcı yazar', (
    tester,
  ) async {
    final controller = await pumpAt(tester, const Size(1440, 900));
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    await tester.pump();

    final tourToggle = find.byKey(const ValueKey<String>('model-tour-toggle'));
    tester.widget<MiniToolLabeledToggle>(tourToggle).onTap();
    await tester.pump();

    expect(controller.selectedComponentBlock!.modelTourEnabled, isTrue);
    expect(find.byType(HtmlPresentationEditorPage), findsOneWidget);
    expect(find.byType(PresentationPreviewPage), findsNothing);
    expect(find.text('Görünümü Kaydet'), findsOneWidget);

    controller.lookAroundSelectedModelTour(const Offset(36, -12));
    controller.moveSelectedModelTour(forward: 8, right: 3);
    controller.updateSelectedModelZoom(2.4);
    final tourPose = controller.selectedComponentBlock!;

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    final committed = controller.selectedComponentBlock!;
    expect(committed.modelTourEnabled, isTrue);
    expect(committed.modelTourFrozen, isTrue);
    expect(committed.modelOrbitTheta, tourPose.modelOrbitTheta);
    expect(committed.modelOrbitPhi, tourPose.modelOrbitPhi);
    expect(committed.modelTargetX, tourPose.modelTargetX);
    expect(committed.modelTargetY, tourPose.modelTargetY);
    expect(committed.modelTargetZ, tourPose.modelTargetZ);
    expect(committed.modelZoom, tourPose.modelZoom);

    final restored = PresentationProjectCodec.decodeProject(
      PresentationProjectCodec.encodeProject(
        pages: controller.pages,
        effectSettings: controller.effectSettings,
      ),
    ).pages.single.componentBlocks.single;
    expect(restored.modelOrbitTheta, committed.modelOrbitTheta);
    expect(restored.modelOrbitPhi, committed.modelOrbitPhi);
    expect(restored.modelTargetX, committed.modelTargetX);
    expect(restored.modelTargetY, committed.modelTargetY);
    expect(restored.modelTargetZ, committed.modelTargetZ);
    expect(restored.modelZoom, committed.modelZoom);
    expect(restored.modelTourFrozen, isTrue);
  });

  testWidgets('sayfa değişince 3B editör sahnesi canlı tutulur', (
    tester,
  ) async {
    final controller = await pumpAt(tester, const Size(1440, 900));
    final firstPageId = controller.selectedPage.id;
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.lookAroundSelectedModelTour(const Offset(72, -18));
    controller.moveSelectedModelTour(forward: 15, right: 4);
    controller.updateSelectedModelZoom(2.8);
    final expected = controller.selectedComponentBlock!;

    controller.addPage();
    await tester.pump();
    expect(
      find.byKey(
        ValueKey<String>('editor-page-canvas-$firstPageId'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    controller.selectPage(0);
    await tester.pump();
    final restored = controller.selectedPage.componentBlocks.single;
    expect(restored.modelOrbitTheta, expected.modelOrbitTheta);
    expect(restored.modelOrbitPhi, expected.modelOrbitPhi);
    expect(restored.modelTargetX, expected.modelTargetX);
    expect(restored.modelTargetZ, expected.modelTargetZ);
    expect(restored.modelZoom, expected.modelZoom);
  });

  testWidgets('Sanal Turu Kapat son kamera pozunu model üzerinde dondurur', (
    tester,
  ) async {
    final controller = await pumpAt(tester, const Size(1440, 900));
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    await tester.pump();

    final tourToggle = find.byKey(const ValueKey<String>('model-tour-toggle'));
    tester.widget<MiniToolLabeledToggle>(tourToggle).onTap();
    await tester.pump();

    controller.lookAroundSelectedModelTour(const Offset(-48, 16));
    controller.moveSelectedModelTour(forward: 11, right: -4);
    controller.updateSelectedModelZoom(3.2);
    final tourPose = controller.selectedComponentBlock!;

    tester.widget<MiniToolLabeledToggle>(tourToggle).onTap();
    await tester.pump();

    final frozen = controller.selectedComponentBlock!;
    expect(frozen.modelTourEnabled, isTrue);
    expect(frozen.modelTourFrozen, isTrue);
    expect(frozen.modelOrbitTheta, tourPose.modelOrbitTheta);
    expect(frozen.modelOrbitPhi, tourPose.modelOrbitPhi);
    expect(frozen.modelTargetX, tourPose.modelTargetX);
    expect(frozen.modelTargetY, tourPose.modelTargetY);
    expect(frozen.modelTargetZ, tourPose.modelTargetZ);
    expect(frozen.modelZoom, tourPose.modelZoom);
    expect(find.text('Turu Düzenle'), findsOneWidget);
  });

  testWidgets('Sunum Modu editör kamera stateini birebir kopyalar', (
    tester,
  ) async {
    ModelViewerCameraPose? renderedPose;
    final controller = await pumpAt(
      tester,
      const Size(1440, 900),
      modelCameraPoseReader: (_) => renderedPose,
    );
    controller.add3DModelBlock(presentation3DModelCatalog.first);
    controller.updateSelectedModelTourEnabled(true);
    controller.lookAroundSelectedModelTour(const Offset(-138, 24));
    controller.moveSelectedModelTour(forward: 17, right: -9);
    controller.updateSelectedModelZoom(3.7);
    final controllerPose = controller.selectedComponentBlock!;
    renderedPose = ModelViewerCameraPose(
      theta: controllerPose.modelOrbitTheta,
      phi: controllerPose.modelOrbitPhi,
      radius: 17.625,
      targetX: controllerPose.modelTargetX,
      targetY: -1.75,
      targetZ: controllerPose.modelTargetZ,
      turntableRotation: 1.2345,
      fieldOfView: 37.25,
    );
    await tester.pump();

    await tester.tap(find.text('Sunum Modu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PresentationPreviewPage), findsOneWidget);
    final previewCanvas = tester
        .widgetList<PresentationPageCanvas>(
          find.byType(PresentationPageCanvas, skipOffstage: false),
        )
        .firstWhere(
          (canvas) => canvas.page.componentBlocks.single.modelTourFrozen,
        );
    final rendered = previewCanvas.page.componentBlocks.single;
    expect(rendered.modelOrbitTheta, renderedPose.theta);
    expect(rendered.modelOrbitPhi, renderedPose.phi);
    expect(rendered.modelTargetX, renderedPose.targetX);
    expect(rendered.modelTargetY, renderedPose.targetY);
    expect(rendered.modelTargetZ, renderedPose.targetZ);
    expect(rendered.modelZoom, controllerPose.modelZoom);
    expect(rendered.modelCameraRadius, renderedPose.radius);
    expect(
      rendered.modelTurntableRotation,
      renderedPose.turntableRotation,
    );
    expect(rendered.modelFieldOfView, renderedPose.fieldOfView);
    expect(
        rendered.modelAnimationEnabled, controllerPose.modelAnimationEnabled);

    final editorModel = controller.selectedComponentBlock!;
    expect(editorModel.modelOrbitTheta, renderedPose.theta);
    expect(editorModel.modelTargetX, renderedPose.targetX);
    expect(editorModel.modelTargetY, renderedPose.targetY);
    expect(editorModel.modelTargetZ, renderedPose.targetZ);
    expect(editorModel.modelCameraRadius, renderedPose.radius);
    expect(
      editorModel.modelTurntableRotation,
      renderedPose.turntableRotation,
    );
    expect(editorModel.modelFieldOfView, renderedPose.fieldOfView);
    expect(editorModel.modelTourFrozen, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
  });
}
