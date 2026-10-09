import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/services/presentation_readability_service.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  const text = PresentationTextBlock(
      id: 'text',
      text: 'Moleküller',
      position: Offset(.1, .1),
      fontSize: 32,
      type: PresentationTextType.body,
      widthFactor: .4,
      textColorHex: '#ffffff');
  PresentationPage page(PresentationTextBlock block) => PresentationPage(
      id: 'page',
      textBlocks: [block],
      backgroundKind: PresentationBackgroundKind.studioNightSky);
  String encode(PresentationTextBlock block) =>
      PresentationProjectCodec.encodeProject(
          pages: [page(block)],
          effectSettings: const PresentationEffectSettings());
  PresentationTextBlock decode(String source) =>
      PresentationProjectCodec.decodeProject(source)
          .pages
          .single
          .textBlocks
          .single;

  test(
      'surface survives project and both HTML destinations; old files stay clear',
      () {
    final adjusted = text.copyWith(surface: PresentationTextSurface.dark);
    expect(decode(encode(adjusted)).surface, PresentationTextSurface.dark);
    for (final document in [
      buildHtmlStageDocument(page: page(adjusted)),
      buildPresentationExportHtml(pages: [page(adjusted)], compact: false)
    ]) {
      final markup = RegExp(r'<div class="sutol-html-block[^>]+>')
          .firstMatch(document)!
          .group(0)!;
      expect(markup, contains('background-color:#111827;'));
      expect(markup, contains('color:#ffffff;'));
    }
    final old = jsonDecode(encode(adjusted)) as Map<String, dynamic>;
    old['pages'][0]['textBlocks'][0].remove('surface');
    expect(decode(jsonEncode(old)).surface, PresentationTextSurface.none);
    old['pages'][0]['textBlocks'][0]['surface'] = 'invalid';
    expect(decode(jsonEncode(old)).surface, PresentationTextSurface.none);
  });

  test('surface edits preserve content and geometry and have one undo step',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck([page(text)]);
    controller.selectTextBlock(text.id);
    controller.updateSelectedTextSurface(PresentationTextSurface.dark);
    final adjusted = controller.selectedTextBlock!;
    expect(adjusted.text, text.text);
    expect(adjusted.position, text.position);
    expect(adjusted.textColorHex, text.textColorHex);
    controller.updateSelectedTextSurface(PresentationTextSurface.dark);
    controller.undo();
    expect(controller.selectedPage.textBlocks.single.surface,
        PresentationTextSurface.none);
    controller.redo();
    expect(controller.selectedPage.textBlocks.single.surface,
        PresentationTextSurface.dark);
  });

  test('contrast check uses the selected surface rather than the slide color',
      () {
    List<ReadabilityIssueKind> issues(PresentationTextSurface surface) =>
        PresentationReadabilityService.inspect(
            page: page(text.copyWith(surface: surface)),
            aspectRatio: 16 / 9,
            styleFor: (_) => const TextStyle()).map((i) => i.kind).toList();
    expect(issues(PresentationTextSurface.light),
        contains(ReadabilityIssueKind.lowContrast));
    expect(issues(PresentationTextSurface.dark),
        isNot(contains(ReadabilityIssueKind.lowContrast)));
  });
}
