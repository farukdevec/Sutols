import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_readability_service.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/widgets/presentation_readability_button.dart';

void main() {
  List<PresentationReadabilityIssue> inspect(PresentationTextBlock block) =>
      PresentationReadabilityService.inspect(
          page: PresentationPage(id: 'p', textBlocks: [block]),
          aspectRatio: 16 / 9,
          styleFor: (_) => const TextStyle());
  const base = PresentationTextBlock(
      id: 'text',
      text: 'Kısa metin',
      position: Offset(.1, .1),
      fontSize: 30,
      type: PresentationTextType.body,
      widthFactor: .8,
      heightFactor: .3);

  test('empty and short readable text do not trigger density warnings', () {
    expect(inspect(base.copyWith(text: '')), isEmpty);
    expect(inspect(base).map((i) => i.kind),
        isNot(contains(ReadabilityIssueKind.longText)));
  });
  test('long title and body are reported without mutating the source', () {
    final text = List.filled(100, 'elektron').join(' ');
    final block = base.copyWith(text: text);
    expect(inspect(block).map((i) => i.kind),
        contains(ReadabilityIssueKind.longText));
    expect(block.text, text);
    expect(
        inspect(base.copyWith(
                type: PresentationTextType.title,
                text: List.filled(19, 'kelime').join(' ')))
            .map((i) => i.kind),
        contains(ReadabilityIssueKind.longText));
  });
  test('small font and outside-stage geometry are flagged independently', () {
    expect(
        inspect(base.copyWith(fontSize: 12, position: const Offset(.8, .9)))
            .map((i) => i.kind),
        containsAll([
          ReadabilityIssueKind.smallFont,
          ReadabilityIssueKind.outsideStage
        ]));
  });
  test('a tight bounded box is reported even at the shrink readability floor',
      () {
    expect(inspect(base.copyWith(heightFactor: .01)).map((i) => i.kind),
        contains(ReadabilityIssueKind.tightBox));
    expect(
        inspect(base.copyWith(
                heightFactor: .01, overflow: PresentationTextOverflow.clip))
            .map((i) => i.kind),
        contains(ReadabilityIssueKind.tightBox));
  });
  test('explicit contrast catches pale text on a flat background only', () {
    expect(inspect(base.copyWith(textColorHex: '#eeeeee')).map((i) => i.kind),
        contains(ReadabilityIssueKind.lowContrast));
    expect(inspect(base.copyWith(textColorHex: '#111111')).map((i) => i.kind),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
    expect(inspect(base.copyWith(textColorHex: 'invalid')).map((i) => i.kind),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
    final dark = PresentationReadabilityService.inspect(
        page: PresentationPage(
            id: 'p',
            textBlocks: [base.copyWith(textColorHex: '#111111')],
            backgroundColorsInverted: true),
        aspectRatio: 16 / 9,
        styleFor: (_) => const TextStyle());
    expect(dark.map((i) => i.kind), contains(ReadabilityIssueKind.lowContrast));
    final animated = PresentationReadabilityService.inspect(
        page: PresentationPage(
            id: 'p',
            textBlocks: [base.copyWith(textColorHex: '#eeeeee')],
            backgroundKind: PresentationBackgroundKind.science),
        aspectRatio: 16 / 9,
        styleFor: (_) => const TextStyle());
    expect(animated.map((i) => i.kind),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
  });

  test('a separate static model keeps the flat-background contrast check', () {
    const model = PresentationComponentBlock(
        id: 'model', position: Offset(.65, .1), size: Size(.3, .6));
    final text = base.copyWith(widthFactor: .4, textColorHex: '#eeeeee');
    List<ReadabilityIssueKind> contrast(PresentationTextBlock block,
            PresentationComponentBlock component) =>
        PresentationReadabilityService.inspect(
                page: PresentationPage(
                    id: 'p', textBlocks: [block], componentBlocks: [component]),
                aspectRatio: 16 / 9,
                styleFor: (_) => const TextStyle())
            .map((issue) => issue.kind)
            .toList();
    expect(contrast(text, model), contains(ReadabilityIssueKind.lowContrast));
    expect(contrast(text, model.copyWith(position: const Offset(.2, .1))),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
    expect(contrast(text.copyWith(heightFactor: null), model),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
    expect(contrast(text.copyWith(rotationDegrees: 45), model),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
    expect(
        contrast(
            text.copyWith(overflow: PresentationTextOverflow.expand), model),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
    expect(contrast(text, model.copyWith(size: const Size(-1, .3))),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
    expect(text.textColorHex, '#eeeeee');
    expect(model.position, const Offset(.65, .1));
  });

  for (final width in [320.0, 1200.0]) {
    testWidgets('readability dialog preserves content and fits ${width}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = PresentationController();
      addTearDown(controller.dispose);
      controller.selectTextBlock(controller.selectedPage.textBlocks.first.id);
      final text = List.filled(100, 'elektron').join(' ');
      controller.updateSelectedText(text);
      final before =
          controller.selectedPage.textBlocks.map((b) => b.text).toList();
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Center(
                  child:
                      PresentationReadabilityButton(controller: controller)))));
      await tester.tap(find.byKey(const ValueKey('readability-check-button')));
      await tester.pumpAndSettle();
      expect(find.text('Slayt okunurluğu'), findsOneWidget);
      expect(find.text('Metin uzun. Ayrı bir slayta bölmeyi düşünün.'),
          findsOneWidget);
      await tester.tap(find.text('Kapat'));
      await tester.pumpAndSettle();
      expect(controller.selectedPage.textBlocks.map((b) => b.text).toList(),
          before);
      expect(tester.takeException(), isNull);
    });
  }
}
