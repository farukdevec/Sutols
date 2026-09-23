import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';

void main() {
  Widget canvasFor(PresentationTextBlock block, {bool interactive = false}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1000,
          height: 562.5,
          child: PresentationPageCanvas(
            page: PresentationPage(
              id: 'page-1',
              textBlocks: <PresentationTextBlock>[block],
            ),
            interactive: interactive,
            showSurface: false,
            showSelectionBorder: false,
          ),
        ),
      ),
    );
  }

  testWidgets('Flutter text renderer applies persisted alignment and metrics',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const block = PresentationTextBlock(
      id: 'text-1',
      text: 'Aynı yerleşim',
      position: Offset(.1, .2),
      fontSize: 40,
      type: PresentationTextType.body,
      widthFactor: .4,
      heightFactor: .25,
      textAlign: PresentationTextAlign.center,
      verticalAlign: PresentationTextVerticalAlign.bottom,
      overflow: PresentationTextOverflow.clip,
      padding: 20,
      lineHeight: 1.5,
    );

    await tester.pumpWidget(canvasFor(block));

    final text = tester.widget<Text>(find.text('Aynı yerleşim'));
    expect(text.textAlign, TextAlign.center);
    expect(text.style?.fontSize, closeTo(40, .001));
    expect(text.style?.height, 1.5);
    final align = tester.widget<Align>(
      find
          .ancestor(
            of: find.text('Aynı yerleşim'),
            matching: find.byType(Align),
          )
          .first,
    );
    expect(align.alignment, Alignment.bottomCenter);
  });

  testWidgets('shrink overflow reacts to the fixed text box height',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const longText =
        'Bu metin dar ve kısa bir kutuya sığmak için küçülmelidir. '
        'Satır kaydırma genişlik değiştiğinde yeniden hesaplanır.';
    const shrinkBlock = PresentationTextBlock(
      id: 'text-shrink',
      text: longText,
      position: Offset.zero,
      fontSize: 60,
      type: PresentationTextType.body,
      widthFactor: .3,
      heightFactor: .12,
      overflow: PresentationTextOverflow.shrink,
    );
    const clipBlock = PresentationTextBlock(
      id: 'text-clip',
      text: longText,
      position: Offset.zero,
      fontSize: 60,
      type: PresentationTextType.body,
      widthFactor: .3,
      heightFactor: .12,
      overflow: PresentationTextOverflow.clip,
    );

    await tester.pumpWidget(canvasFor(shrinkBlock));
    final shrinkSize =
        tester.widget<Text>(find.text(longText)).style!.fontSize!;
    await tester.pumpWidget(canvasFor(clipBlock));
    final clipSize = tester.widget<Text>(find.text(longText)).style!.fontSize!;

    expect(shrinkSize, lessThan(clipSize));
    expect(clipSize, closeTo(60, .001));
  });

  testWidgets('dar Türkçe başlık minimum punto sonrası kesilmeden büyür',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const title = 'Kişiselleştirilmiş Öğrenme Çözümleri';
    const block = PresentationTextBlock(
      id: 'narrow-turkish-title',
      text: title,
      position: Offset.zero,
      fontSize: 72,
      type: PresentationTextType.title,
      widthFactor: .12,
      heightFactor: .04,
      overflow: PresentationTextOverflow.shrink,
    );

    await tester.pumpWidget(canvasFor(block));

    final renderedText = tester.widget<Text>(find.text(title));
    expect(renderedText.style?.fontSize,
        closeTo(PresentationController.minTextFontSize, .2));
    final textSize = tester.getSize(find.text(title));
    expect(textSize.height, greaterThan(562.5 * block.heightFactor!));
    expect(tester.takeException(), isNull);
  });

  testWidgets('body strong prefix hides markdown markers and stays measured',
      (tester) async {
    const source = '**Fayda:** Kişiselleştirilmiş öğrenme';
    const block = PresentationTextBlock(
      id: 'strong-prefix',
      text: source,
      position: Offset.zero,
      fontSize: 40,
      type: PresentationTextType.body,
      widthFactor: .5,
    );
    await tester.pumpWidget(canvasFor(block));

    final richText = tester.widget<RichText>(find.byType(RichText).last);
    expect(richText.text.toPlainText(), 'Fayda: Kişiselleştirilmiş öğrenme');
    expect(richText.text.toPlainText(), isNot(contains('**')));
  });

  testWidgets('new empty text box is selected and enters editing mode',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var page = const PresentationPage(
      id: 'page-1',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'text-1',
          text: 'Mevcut',
          position: Offset.zero,
          fontSize: 40,
          type: PresentationTextType.body,
          widthFactor: .3,
        ),
      ],
    );
    var selectedId = 'text-1';
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                width: 1000,
                height: 562.5,
                child: PresentationPageCanvas(
                  page: page,
                  selectedTextBlockId: selectedId,
                  interactive: true,
                  showSurface: false,
                  onSelectTextBlock: (_) {},
                  onInlineTextChanged: (_) {},
                ),
              );
            },
          ),
        ),
      ),
    );

    rebuild(() {
      selectedId = 'text-2';
      page = page.copyWith(
        textBlocks: <PresentationTextBlock>[
          ...page.textBlocks,
          const PresentationTextBlock(
            id: 'text-2',
            text: '',
            position: Offset(.2, .2),
            fontSize: 42,
            type: PresentationTextType.body,
            widthFactor: .3,
          ),
        ],
      );
    });
    await tester.pump();
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
        isTrue);
  });

  testWidgets('double click selects all text and enables the editing menu',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const content = 'Tamamını seç';
    const block = PresentationTextBlock(
      id: 'text-double-click',
      text: content,
      position: Offset(.2, .2),
      fontSize: 42,
      type: PresentationTextType.body,
      widthFactor: .4,
    );

    await tester.pumpWidget(canvasFor(block, interactive: true));
    final target = find.text(content);
    final position = tester.getCenter(target);
    await tester.tapAt(position);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(position);
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.controller!.selection,
      const TextSelection(baseOffset: 0, extentOffset: content.length),
    );
    expect(field.strutStyle?.forceStrutHeight, isFalse);
    expect(field.strutStyle?.fontSize, closeTo(42, .001));
    expect(field.cursorHeight, greaterThan(42));
    expect(field.clipBehavior, Clip.none);
    expect(field.contextMenuBuilder, isNotNull);
    final editingPosition = tester.getCenter(find.byType(TextField));
    await tester.tapAt(editingPosition, buttons: 2);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    expect(find.byIcon(Icons.content_paste_rounded), findsOneWidget);
    await tester.tapAt(const Offset(1100, 750));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
  });
}
