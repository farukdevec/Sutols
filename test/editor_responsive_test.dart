import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/html_presentation_editor_page.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';
import 'package:sutol/ui/widgets/html_stage/html_page_stage.dart';

import 'package:sutol/services/cookie_consent_service.dart';

void main() {
  // Test ortamının kare Ahem fontu yerine gerçek glif genişlikleriyle ölçüm
  // yapılır. Test MaterialApp'i varsayılan Material temasını (Roboto ailesi)
  // kullanır; SDK'daki Roboto glifleri gerçek cihaz davranışına en yakın
  // ölçüyü verir. Dock'un "Daha fazla"ya taşıma kararları ve rapor bunun
  // üzerine kuruludur.
  setUpAll(() async {
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

  Future<void> pumpAt(
    WidgetTester tester,
    Size size,
  ) async {
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
        home: HtmlPresentationEditorPage(controller: controller),
      ),
    );
    await tester.pump();
    FlutterError.onError = prevOnError;
    if (captured != null) {
      FlutterError.dumpErrorToConsole(captured!, forceReport: true);
    }
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

  testWidgets('arka plan sekmesi 1120px genişlikte taşmaz', (tester) async {
    await pumpAt(tester, const Size(1120, 800));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Arka Planlar'));
    await tester.pumpAndSettle();
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
    final glowControl = find.byKey(
      const ValueKey<String>('selected-text-glow-control'),
    );
    expect(selectionBar, findsOneWidget);
    expect(glowControl, findsOneWidget);
    expect(
      tester.getRect(glowControl).right,
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
          'Sahne Ölçüleri',
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
    expect(find.text('Arka Plan Kutuphanesi'), findsOneWidget);
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
}
