import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/html_presentation_editor_page.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';
import 'package:sutol/ui/widgets/selection_mini_toolbar.dart';

void main() {
  Future<PresentationController> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final controller = PresentationController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: HtmlPresentationEditorPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  // Alt araç iskelesinin dış yüksekliği (64-72px hedefi).
  double dockHeight(WidgetTester tester) {
    return tester
        .getSize(find.byKey(const ValueKey<String>('mobile-tool-dock')))
        .height;
  }

  Rect stageCanvasRect(WidgetTester tester) {
    // Sahnede çok sayıda PresentationPageCanvas vardır (tuval + şerit
    // küçük resimleri); ilki büyük düzenleme tuvalidir.
    return tester.getRect(find.byType(PresentationPageCanvas).first);
  }

  void report(String label, Rect r) {
    debugPrint(
      'GEOMETRY $label: left=${r.left.toStringAsFixed(1)} '
      'top=${r.top.toStringAsFixed(1)} '
      'w=${r.width.toStringAsFixed(1)} h=${r.height.toStringAsFixed(1)}',
    );
  }

  for (final size in <Size>[const Size(360, 800), const Size(390, 844)]) {
    testWidgets('geometry at ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pumpAt(tester, size);
      expect(tester.takeException(), isNull);

      // Başlık: ölçüm (marka satırı + dikey padding, kompakt modda kısalır).
      final headerRect = tester.getRect(
        find.byKey(const ValueKey<String>('mobile-editor-header')),
      );
      final headerH = headerRect.height;

      // Tuval (sahne).
      final canvasRect = stageCanvasRect(tester);

      // Slayt şeridi: tuvalin hemen altında, kalıcı.
      final stripRect = tester.getRect(
        find.byKey(const ValueKey<String>('mobile-slide-strip')),
      );

      // Alt iskele.
      final dockH = dockHeight(tester);

      report('header', headerRect);
      report('canvas', canvasRect);
      report('strip', stripRect);
      report(
          'dock', Rect.fromLTWH(0, size.height - dockH - 6, size.width, dockH));

      debugPrint(
        'GEOMETRY summary @${size.width.toInt()}x${size.height.toInt()}: '
        'header=${headerH.toStringAsFixed(0)}px, '
        'canvas=${canvasRect.width.toStringAsFixed(0)}x'
        '${canvasRect.height.toStringAsFixed(0)}px, '
        'strip=${stripRect.height.toStringAsFixed(0)}px, '
        'dock=$dockH px',
      );

      // 1) 16:9 korunur ve tuval genişliği ekrana yakındır (kırpılmamış).
      expect(
        (canvasRect.width / canvasRect.height - 16 / 9).abs(),
        lessThan(0.02),
        reason: '16:9 bozulmamalı',
      );
      expect(canvasRect.width, greaterThan(size.width * 0.9));
      // 2) Tuval yatayda ortalanmıştır.
      final leftMargin = canvasRect.left;
      final rightMargin = size.width - canvasRect.right;
      expect((leftMargin - rightMargin).abs(), lessThan(2));
      // 3) Tuval, başlık + iskeleden daha fazla yer kaplar (ana odak).
      expect(canvasRect.height, greaterThan(headerH + dockH));
      // 4) Başlık, şerit ve iskele kompakt kalır.
      expect(headerH, lessThan(70));
      expect(stripRect.height, inInclusiveRange(40, 50));
      expect(dockH, inInclusiveRange(64, 72));
      // 4b) Boşluk ritmi: sahne alanı↔şerit ve şerit↔iskele 8-12px.
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
        reason: 'sahne alanı ile şerit arası 8-12px',
      );
      final dockTop = tester
          .getRect(find.byKey(const ValueKey<String>('mobile-tool-dock')))
          .top;
      expect(
        dockTop - stripRect.bottom,
        inInclusiveRange(8, 12),
        reason: 'şerit ile iskele arası 8-12px',
      );
      // 5) Şerit tuvalin altında, iskelenin üstündedir.
      expect(stripRect.top, greaterThan(canvasRect.bottom));
      expect(stripRect.top, lessThan(size.height - dockH - 6));
      // 6) Tuval dikey olarak ortalanmış alanda (header↔şerit).
      final canvasAreaTop = headerRect.bottom + 8;
      final canvasAreaBottom = stripRect.top;
      final topGap = canvasRect.top - canvasAreaTop;
      final bottomGap = canvasAreaBottom - (canvasRect.top + canvasRect.height);
      expect(topGap, greaterThan(20));
      expect(bottomGap, greaterThan(20));
      expect(
        (topGap - bottomGap).abs(),
        lessThan(40),
        reason: 'tuval header↔şerit arasında dengeli ortalanmalı',
      );
      debugPrint(
        'GEOMETRY breathing: üst=${topGap.toStringAsFixed(0)}px '
        'alt=${bottomGap.toStringAsFixed(0)}px',
      );
    });
  }

  testWidgets('formatlama barı seçimle görünür, seçim yokken yer tutmaz', (
    tester,
  ) async {
    await pumpAt(tester, const Size(360, 800));

    // Varsayılan slaytta başlık metni seçilidir → bar görünür ve tuvalin
    // üstünde yüzer.
    final barRect = tester.getRect(find.byType(SelectionContextBar));
    final canvasRect = stageCanvasRect(tester);
    report('selection bar (seçimli)', barRect);
    debugPrint(
      'GEOMETRY selection bar height=${barRect.height.toStringAsFixed(0)}px',
    );
    expect(barRect.height, lessThan(60));
    expect(barRect.top, lessThan(canvasRect.top));
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_ComponentResizeGrip',
      ),
      findsNWidgets(8),
    );
    expect(
      find.byKey(
        const ValueKey<String>('selected-text-animation-control'),
      ),
      findsOneWidget,
    );
    final textFieldHost = find.byKey(
      const ValueKey<String>('selected-text-toolbar-field'),
    );
    expect(textFieldHost, findsOneWidget);
    expect(tester.getRect(textFieldHost).left, lessThan(32));
    expect(find.text('Animasyon yok'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final controller = tester.widget<HtmlPresentationEditorPage>(
      find.byType(HtmlPresentationEditorPage),
    );
    await tester.enterText(
      find.descendant(of: textFieldHost, matching: find.byType(TextField)),
      'Yeni başlık',
    );
    expect(controller.controller.selectedTextBlock!.text, 'Yeni başlık');

    final animationControl = find.byKey(
      const ValueKey<String>('selected-text-animation-control'),
    );
    await tester.ensureVisible(animationControl);
    await tester.tap(animationControl);
    await tester.pumpAndSettle();
    final animationOption = find.byKey(
      const ValueKey<String>('text-animation-option-bilimDramatik'),
    );
    expect(animationOption, findsOneWidget);
    await tester.tap(animationOption);
    await tester.pumpAndSettle();
    expect(
      controller.controller.selectedTextBlock!.textAnimation,
      PresentationTextAnimation.bilimDramatik,
    );
    expect(find.text('Derin ışıma'), findsOneWidget);

    final colorControl = find.byKey(
      const ValueKey<String>('selected-text-color-control'),
    );
    expect(colorControl, findsOneWidget);
    await tester.ensureVisible(colorControl);
    await tester.tap(colorControl);
    await tester.pumpAndSettle();
    final blueOption = find.byKey(
      const ValueKey<String>('text-color-#3B82F6'),
    );
    expect(blueOption, findsOneWidget);
    await tester.tap(blueOption);
    await tester.pumpAndSettle();
    expect(controller.controller.selectedTextBlock!.textColorHex, '#3B82F6');

    final glowControl = find.byKey(
      const ValueKey<String>('selected-text-glow-control'),
    );
    expect(glowControl, findsOneWidget);
    expect(find.byTooltip('Diğer metin ayarları'), findsNothing);
    await tester.ensureVisible(glowControl);
    await tester.tap(glowControl);
    await tester.pumpAndSettle();
    final strongGlowOption = find.byKey(
      const ValueKey<String>('text-glow-1.5'),
    );
    expect(strongGlowOption, findsOneWidget);
    await tester.tap(strongGlowOption);
    await tester.pumpAndSettle();
    expect(controller.controller.selectedTextBlock!.glowIntensity, 1.5);
    expect(strongGlowOption, findsNothing, reason: 'açılır menü kapanmalı');

    // Seçim temizlenince bar tamamen kaybolur (bağlamsal).
    controller.controller.clearSelection();
    await tester.pumpAndSettle();
    expect(find.byType(SelectionContextBar), findsNothing);
  });

  testWidgets('formatlama barı tuvali kaydırmaz (sabit sahne)', (tester) async {
    await pumpAt(tester, const Size(360, 800));

    final controller = tester.widget<HtmlPresentationEditorPage>(
      find.byType(HtmlPresentationEditorPage),
    );
    final canvasTopWithBar = stageCanvasRect(tester).top;

    controller.controller.clearSelection();
    await tester.pumpAndSettle();
    expect(find.byType(SelectionContextBar), findsNothing);

    final canvasTopNoBar = stageCanvasRect(tester).top;
    expect(
      (canvasTopWithBar - canvasTopNoBar).abs(),
      lessThan(1),
      reason: 'bar görünüp kaybolduğunda tuval yerinden oynamamalı',
    );
  });

  testWidgets('slayt şeridi slayt değiştirir ve yeni slayt ekler', (
    tester,
  ) async {
    await pumpAt(tester, const Size(360, 800));
    final controller = tester
        .widget<HtmlPresentationEditorPage>(
          find.byType(HtmlPresentationEditorPage),
        )
        .controller;
    // Yeni sunum tek slaytla başlar; şeritte ikinci küçük resmi görmek için
    // önce bir slayt daha ekleyelim.
    controller.addPage();
    await tester.pumpAndSettle();
    final initialCount = controller.pages.length;

    // Şeritteki tüm küçük resimler görünür.
    for (var i = 0; i < initialCount; i++) {
      expect(
        find.byKey(ValueKey<String>('mobile-slide-strip-thumb-$i')),
        findsOneWidget,
      );
    }

    // Küçük resme dokununca o slayt seçilir.
    await tester.tap(
      find.byKey(const ValueKey<String>('mobile-slide-strip-thumb-1')),
    );
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 1);

    // "+" yeni slayt ekler ve şerit güncellenir.
    await tester.tap(
      find.byKey(const ValueKey<String>('mobile-slide-strip-add')),
    );
    await tester.pumpAndSettle();
    expect(controller.pages.length, initialCount + 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'kıstırma yakınlaştırır, iki parmak kaydırır, tek parmak tuvali yönetir',
      (
    tester,
  ) async {
    await pumpAt(tester, const Size(360, 800));

    final before = stageCanvasRect(tester);
    expect(before.width, lessThan(340));

    // Tek parmak sürükleme: tuvali yakınlaştırmaz (iç jestler çalışır).
    final single = await tester.createGesture();
    await single.down(before.center);
    await single.moveBy(const Offset(0, 40));
    await tester.pump();
    await single.up();
    await tester.pumpAndSettle();
    final afterSingleDrag = stageCanvasRect(tester);
    expect(
      (afterSingleDrag.width - before.width).abs(),
      lessThan(1),
      reason: 'tek parmak sürükleme yakınlaştırma yapmamalı',
    );

    // İki parmak kıstırma: tuval büyür.
    final g1 = await tester.createGesture(pointer: 1);
    final g2 = await tester.createGesture(pointer: 2);
    final center = before.center;
    await g1.down(center - const Offset(30, 0));
    await g2.down(center + const Offset(30, 0));
    await tester.pump();
    await g1.moveBy(const Offset(-60, 0));
    await g2.moveBy(const Offset(60, 0));
    await tester.pump();
    await g1.up();
    await g2.up();
    await tester.pumpAndSettle();

    final zoomed = stageCanvasRect(tester);
    expect(
      zoomed.width,
      greaterThan(before.width + 40),
      reason: 'kıstırma tuvali büyütmeli',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobil başlık marka + tüm kritik kontrolleri doğrudan gösterir', (
    tester,
  ) async {
    for (final size in <Size>[const Size(320, 800), const Size(390, 844)]) {
      await pumpAt(tester, size);

      // Marka: gerçek logo + "Sutols" adı kırpılmadan görünür.
      expect(
        find.byKey(const ValueKey<String>('sutols-wordmark')),
        findsOneWidget,
        reason: 'marka @$size',
      );
      expect(
        find.byWidgetPredicate((w) => w is Image && w.image is AssetImage),
        findsWidgets,
        reason: 'logo asset @$size',
      );

      // Kritik aksiyonlar ⋮ içine saklanmadan doğrudan erişilebilir.
      for (final tooltip in <String>[
        'Geri',
        'Geri al',
        'Yinele',
        'Sunum Modu',
        'Dışa Aktar',
        'Diğer işlemler',
      ]) {
        expect(
          find.byTooltip(tooltip),
          findsOneWidget,
          reason: '"$tooltip" @$size',
        );
      }
      expect(tester.takeException(), isNull, reason: 'header @$size');
    }
  });

  testWidgets('"+" yalnızca slayt şeridinde; iskelede gereksiz ek yok', (
    tester,
  ) async {
    await pumpAt(tester, const Size(390, 844));
    final dock = find.byKey(const ValueKey<String>('mobile-tool-dock'));
    expect(
      find.descendant(of: dock, matching: find.byIcon(Icons.add_rounded)),
      findsNothing,
      reason: 'iskeleye "+" butonu gereksiz (araçlar doğrudan ekler)',
    );
    expect(
      find.byKey(const ValueKey<String>('mobile-slide-strip-add')),
      findsOneWidget,
      reason: 'slayt ekleme "+"sı yalnızca şeritte',
    );
    expect(tester.takeException(), isNull);
  });
}
