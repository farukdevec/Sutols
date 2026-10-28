import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/models/presentation_scene_state.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  const original = PresentationComponentBlock(
      id: 'water',
      modelAssetId: 'sutols-water-molecule',
      position: Offset.zero,
      size: Size(1, 1),
      modelAnimationName: 'Spin',
      modelOrbitTheta: 720,
      modelTurntableRotation: -360,
      modelAnimationTime: 12.5);
  test('scene identity preserves valid pose and nullable clip reset', () {
    final state =
        PresentationSceneState.fromComponent(pageId: 'page', block: original);
    expect(state.pageId, 'page');
    expect(state.blockId, 'water');
    expect(state.assetVersion, isNotEmpty);
    expect(state.block.modelOrbitTheta, 720);
    expect(state.block.modelTurntableRotation, -360);
    expect(state.block.modelAnimationName, 'Spin');
    expect(
        original.copyWith(modelAnimationName: null).modelAnimationName, isNull);
    expect(original.copyWith(modelZoom: 2).modelAnimationName, 'Spin');
  });
  test(
      'malformed native pose is safe in editor HTML and export, then round trips',
      () {
    final block = original.copyWith(
        modelOrbitTheta: double.nan,
        modelOrbitPhi: double.infinity,
        modelTargetX: double.nan,
        modelCameraRadius: double.infinity,
        modelFieldOfView: double.nan,
        modelAnimationTime: double.infinity,
        modelZoom: -20,
        modelAnimationName: '  ');
    final page = PresentationPage(
        id: 'bad-pose', textBlocks: [], componentBlocks: [block]);
    final document = buildHtmlStageDocument(page: page);
    final exported = buildPresentationExportHtml(pages: [page], compact: false);
    for (final markup in [document, exported]) {
      final modelTag =
          RegExp(r'<model-viewer[^>]+>').firstMatch(markup)!.group(0)!;
      expect(modelTag, isNot(contains('NaN')));
      expect(modelTag, isNot(contains('Infinity')));
    }
    final encoded = PresentationProjectCodec.encodeProject(
        pages: [page], effectSettings: const PresentationEffectSettings());
    expect(jsonDecode(encoded)['sceneStateVersion'],
        PresentationSceneState.version);
    final restored = PresentationProjectCodec.decodeProject(encoded)
        .pages
        .single
        .componentBlocks
        .single;
    expect(restored.modelOrbitTheta, 0);
    expect(restored.modelOrbitPhi, 75);
    expect(restored.modelFieldOfView, 45);
    expect(restored.modelZoom, .5);
    expect(restored.modelCameraRadius, isNull);
    expect(restored.modelAnimationName, isNull);
    expect(restored.modelAnimationTime, 0);
  });
  test('legacy project without scene marker retains its valid camera and clip',
      () {
    final encoded = PresentationProjectCodec.encodeProject(pages: [
      const PresentationPage(
          id: 'old', textBlocks: [], componentBlocks: [original])
    ], effectSettings: const PresentationEffectSettings());
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    data.remove('sceneStateVersion');
    final restored = PresentationProjectCodec.decodeProject(jsonEncode(data))
        .pages
        .single
        .componentBlocks
        .single;
    expect(restored.modelOrbitTheta, 720);
    expect(restored.modelAnimationTime, 12.5);
    expect(restored.modelAnimationName, 'Spin');
  });
}
