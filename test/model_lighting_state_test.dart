import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/models/presentation_scene_state.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  const block = PresentationComponentBlock(
      id: 'water',
      modelAssetId: 'sutols-water-molecule',
      position: Offset(.5, .2),
      size: Size(.4, .6),
      modelOrbitTheta: 123,
      modelAnimationTime: 7);
  PresentationPage page(PresentationComponentBlock model) =>
      PresentationPage(id: 'p', textBlocks: [], componentBlocks: [model]);
  String encode(PresentationComponentBlock model) =>
      PresentationProjectCodec.encodeProject(
          pages: [page(model)],
          effectSettings: const PresentationEffectSettings());
  PresentationComponentBlock decode(String source) =>
      PresentationProjectCodec.decodeProject(source)
          .pages
          .single
          .componentBlocks
          .single;

  test('exposure survives codec, HTML and export while old projects inherit',
      () {
    final adjusted = block.copyWith(modelExposure: 1.4);
    expect(decode(encode(adjusted)).modelExposure, 1.4);
    for (final document in [
      buildHtmlStageDocument(page: page(adjusted)),
      buildPresentationExportHtml(pages: [page(adjusted)], compact: false),
    ]) {
      expect(RegExp(r'<model-viewer[^>]+>').firstMatch(document)!.group(0),
          contains('exposure="1.4000"'));
    }
    final old = jsonDecode(encode(adjusted)) as Map<String, dynamic>;
    old['pages'][0]['componentBlocks'][0].remove('modelExposure');
    expect(decode(jsonEncode(old)).modelExposure, isNull);
    expect(PresentationSceneState.effectiveExposure(block),
        findPresentation3DModelAsset(block.modelAssetId!)!.exposure);
    expect(adjusted.copyWith(modelExposure: null).modelExposure, isNull);
  });

  test('invalid values normalize safely without changing camera or animation',
      () {
    expect(
        decode(encode(block.copyWith(modelExposure: double.nan))).modelExposure,
        isNull);
    expect(
        decode(encode(block.copyWith(modelExposure: -10))).modelExposure, .1);
    expect(decode(encode(block.copyWith(modelExposure: 100))).modelExposure, 3);
    final adjusted = PresentationSceneState.normalizeBlock(
        block.copyWith(modelExposure: 1.5));
    expect(adjusted.modelOrbitTheta, 123);
    expect(adjusted.modelAnimationTime, 7);
  });

  test('lighting edits are per instance and a single undo restores the pose',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck([
      PresentationPage(
          id: 'p',
          textBlocks: [],
          componentBlocks: [block, block.copyWith(id: 'other')])
    ]);
    controller.selectComponentBlock('water');
    controller.updateSelectedModelExposure(1.4);
    expect(controller.selectedComponentBlock!.modelExposure, 1.4);
    expect(controller.selectedPage.componentBlocks.last.modelExposure, isNull);
    expect(controller.selectedComponentBlock!.modelOrbitTheta, 123);
    controller.undo();
    expect(controller.selectedPage.componentBlocks.first.modelExposure, isNull);
    expect(controller.selectedPage.componentBlocks.first.modelAnimationTime, 7);
  });
}
