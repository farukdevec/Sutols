import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/html_presentation_editor_page.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';

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

  for (final tool in <String>['Metin', 'Medya', 'Şekil']) {
    for (final w in <double>[360, 390]) {
      testWidgets('"$tool" alet paneli ${w.toInt()}px bottom sheet taşmaz', (
        tester,
      ) async {
        await pumpAt(tester, Size(w, 844));
        expect(tester.takeException(), isNull);
        final moreLabel = switch (tool) {
          'Şekil' => 'Bileşenler',
          _ => tool,
        };
        await openToolSmart(
          tester,
          dockLabel: tool,
          moreLabel: moreLabel,
        );
        expect(tester.takeException(), isNull, reason: '$tool sheet @ $w');
      });
    }
  }

  for (final tool in <String>['Şablonlar', 'Arka Planlar', '3B Modeller', 'Geçişler']) {
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
    final controller = tester.widget<HtmlPresentationEditorPage>(
      find.byType(HtmlPresentationEditorPage),
    ).controller;
    controller.addPage();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('mobile-slide-strip')), findsOneWidget);
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
    const labels = <String>['Metin', 'Fotoğraf', 'Medya', 'Şekil'];
    int visibleCount() {
      var count = 0;
      for (final l in labels) {
        if (find.text(l).evaluate().isNotEmpty) count++;
      }
      return count;
    }

    await pumpAt(tester, const Size(800, 800));
    expect(visibleCount(), 4, reason: 'geniş ekranda tüm araçlar dockta');
    expect(tester.takeException(), isNull);

    await pumpAt(tester, const Size(320, 800));
    final narrowCount = visibleCount();
    expect(narrowCount, lessThan(4), reason: 'dar ekranda taşan araç gizlenir');
    expect(find.text('Metin'), findsOneWidget, reason: 'Metin hep dockta kalır');
    expect(tester.takeException(), isNull);

    // Kompakt "⋯" butonu ile "Daha fazla" menüsü yine de açılır.
    await openMoreMenu(tester);
    expect(find.text('Fotoğraf Yükle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dock daraldıkça görünür araç sayısı azalır (kademeli)', (
    tester,
  ) async {
    const labels = <String>['Metin', 'Fotoğraf', 'Medya', 'Şekil'];
    int visibleCount() {
      var count = 0;
      for (final l in labels) {
        if (find.text(l).evaluate().isNotEmpty) count++;
      }
      return count;
    }

    final counts = <double, int>{};
    for (final w in <double>[320, 360, 390, 414, 800]) {
      await pumpAt(tester, Size(w, 800));
      expect(tester.takeException(), isNull, reason: 'dock @${w.toInt()}px');
      counts[w] = visibleCount();
    }
    expect(counts[320]!, lessThan(counts[800]!));
    expect(counts[360]!, lessThanOrEqualTo(counts[390]!));
    expect(counts[390]!, lessThanOrEqualTo(counts[414]!));
    expect(counts[414]!, lessThanOrEqualTo(counts[800]!));
  });

  testWidgets('Fotoğraf dock kısayolu hızlı aksiyon sheeti açar', (tester) async {
    await pumpAt(tester, const Size(390, 844));
    expect(find.text('Fotoğraf'), findsOneWidget);
    await openDockTool(tester, 'Fotoğraf');
    expect(find.text('Fotoğraf Ekle'), findsOneWidget);
    expect(find.text('Galeriden / Dosyadan'), findsOneWidget);
    expect(find.text('Fotoğraf Kütüphanem'), findsOneWidget);

    // "Fotoğraf Kütüphanem" → Medya (fotoğraf) panelini açar.
    await tester.tap(find.text('Fotoğraf Kütüphanem'));
    await tester.pumpAndSettle();
    expect(find.text('Fotoğraf Yükle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Fotoğraf Yükle" menü öğesi hızlı aksiyon sheetini açar', (
    tester,
  ) async {
    await pumpAt(tester, const Size(320, 800));
    await openMoreMenu(tester);
    await tester.tap(find.text('Fotoğraf Yükle'));
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
              dockLabel: 'Şekil',
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

        // Header: Sutols logosu + adı, tüm kritik kontroller doğrudan.
        expect(find.text('Sutols'), findsOneWidget, reason: 'marka @$size');
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
          find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_HtmlStageCard',
          ).first,
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
        const labels = <String>['Metin', 'Fotoğraf', 'Medya', 'Şekil'];
        final visible =
            labels
                .where((l) => find.text(l).evaluate().isNotEmpty)
                .toList();
        expect(visible, isNotEmpty, reason: 'dock boş olmamalı @$size');
        for (final l in labels) {
          if (!visible.contains(l)) {
            // Gizlenen araç "Daha fazla" menüsünde erişilebilir olmalı.
            await openMoreMenu(tester);
            expect(
              find.text(l),
              findsWidgets,
              reason: 'gizlenen "$l" menüde olmalı @$size',
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
          if (visible.contains('Şekil')) 'Bileşenler',
          '3B Modeller',
          'Geçişler',
          'Fotoğraf Yükle',
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
          expect(find.text('Metin'), findsOneWidget, reason: 'Metin tek @$size');
        }
        if (visible.contains('Medya')) {
          expect(find.text('Medya'), findsOneWidget, reason: 'Medya tek @$size');
        }
        if (visible.contains('Şekil')) {
          expect(
            find.text('Şekil'),
            findsOneWidget,
            reason: 'Şekil dock ta da menüde değil @$size',
          );
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

  testWidgets('"Animasyonlar" menü öğesi Geçişler panelini açar', (
    tester,
  ) async {
    await pumpAt(tester, const Size(390, 844));
    await openMoreMenu(tester);
    await tester.tap(find.text('Animasyonlar').last);
    await tester.pumpAndSettle();
    expect(find.text('Geçişler'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
