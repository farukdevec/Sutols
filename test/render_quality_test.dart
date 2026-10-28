import 'package:sutol/services/model_render_budget.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:flutter/material.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/state/presentation_controller.dart';

void main() {
  test('GPU scaler floors honor the highest visible shared quality', () {
    expect(modelMinimumRenderScale(PresentationRenderQuality.economy), .4);
    expect(modelMinimumRenderScale(PresentationRenderQuality.balanced), .5);
    expect(modelMinimumRenderScale(PresentationRenderQuality.high), .79);
    expect(sharedModelMinimumRenderScale([]), .5);
    expect(
        sharedModelMinimumRenderScale([PresentationRenderQuality.economy]), .4);
    expect(
        sharedModelMinimumRenderScale([
          PresentationRenderQuality.economy,
          PresentationRenderQuality.high
        ]),
        .79);
  });

  const page = PresentationPage(id: 'legacy-page', textBlocks: []);
  test(
      'reduced export preserves interactive 3D while print snapshots need no model module',
      () {
    const page = PresentationPage(
        id: 'reduced-export',
        textBlocks: [],
        componentBlocks: [
          PresentationComponentBlock(
              id: 'water',
              modelAssetId: 'sutols-water-molecule',
              position: Offset.zero,
              size: Size(1, 1),
              modelOrbitEnabled: true,
              modelAutoRotate: true),
        ]);
    final reduced = buildPresentationExportHtml(
        pages: [page],
        compact: false,
        effectSettings: const PresentationEffectSettings(reducedMotion: true));
    expect(reduced, contains('<model-viewer'));
    expect(reduced, contains('camera-controls'));
    expect(reduced, isNot(contains(' auto-rotate auto-rotate-delay')));
    expect(reduced, contains('data-sutol-reduced-motion-media'));
    final print = buildPresentationExportHtml(
        pages: [page], compact: false, printMode: true);
    expect(print, contains('class="sutol-model-poster"'));
    expect(print, isNot(contains('<model-viewer')));
    expect(print, isNot(contains(sutolModelViewerScriptTag)));
  });
  test('print embeds the matching poster and keeps identity on fetch failure',
      () {
    final page = PresentationPage(
        id: 'embedded-poster',
        textBlocks: [],
        componentBlocks: [
          PresentationComponentBlock(
              id: 'model',
              kind: PresentationComponentKind.values.first,
              modelAssetId: 'sutols-dna-helix',
              position: Offset.zero,
              size: const Size(1, 1))
        ]);
    final id = page.componentBlocks.single.modelAssetId!;
    final embedded = buildPresentationExportHtml(
        pages: [page],
        printMode: true,
        compact: false,
        modelPosterSourcesById: {id: 'data:image/webp;base64,AAAA'});
    expect(embedded, contains('src="data:image/webp;base64,AAAA"'));
    expect(embedded, isNot(contains('src="/model_thumbnails/')));
    final missing = buildPresentationExportHtml(
        pages: [page],
        printMode: true,
        compact: false,
        modelPosterSourcesById: {id: 'unavailable'});
    expect(missing, contains('3D ·'));
    expect(missing, isNot(contains('src="/model_thumbnails/')));
  });

  test('snapshot uses the matching local poster without a live model or loader',
      () {
    const page =
        PresentationPage(id: 'poster', textBlocks: [], componentBlocks: [
      PresentationComponentBlock(
          id: 'water',
          modelAssetId: 'sutols-water-molecule',
          position: Offset.zero,
          size: Size(1, 1)),
      PresentationComponentBlock(
          id: 'unknown',
          modelAssetId: 'unknown-remote-model',
          position: Offset.zero,
          size: Size(1, 1)),
    ]);
    final doc = buildHtmlStageDocument(
        page: page, renderMode: HtmlStageRenderMode.snapshot);
    expect(doc,
        contains('src="/model_thumbnails/original-v1/water-molecule.png"'));
    expect(doc, contains('aria-label="unknown-remote-model"'));
    expect(doc, contains('3D · unknown-remote-model'));
    expect(doc, isNot(contains('<model-viewer')));
    expect(doc, isNot(contains(sutolModelViewerScriptTag)));
    expect(doc, isNot(contains('water-molecule-lite.glb')));
  });
  test('quality persists and legacy projects retain balanced rendering', () {
    final encoded = PresentationProjectCodec.encodeProject(
        pages: [page],
        effectSettings: const PresentationEffectSettings(
            renderQuality: PresentationRenderQuality.economy));
    expect(
        PresentationProjectCodec.decodeProject(encoded)
            .effectSettings
            .renderQuality,
        PresentationRenderQuality.economy);
    final legacy = jsonDecode(encoded) as Map<String, dynamic>;
    (legacy['effectSettings'] as Map).remove('renderQuality');
    expect(
        PresentationProjectCodec.decodeProject(jsonEncode(legacy))
            .effectSettings
            .renderQuality,
        PresentationRenderQuality.balanced);
  });
  test('quality can be undone without changing deck content', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck([page]);
    controller.setRenderQuality(PresentationRenderQuality.economy);
    expect(controller.effectSettings.renderQuality,
        PresentationRenderQuality.economy);
    controller.undo();
    expect(controller.effectSettings.renderQuality,
        PresentationRenderQuality.balanced);
    expect(controller.pages.single.id, 'legacy-page');
  });
  test(
      'high quality changes only known local variants; economy removes shadows and rotation',
      () {
    const modelPage =
        PresentationPage(id: 'model-page', textBlocks: [], componentBlocks: [
      PresentationComponentBlock(
          id: 'water',
          modelAssetId: 'sutols-water-molecule',
          position: Offset.zero,
          size: Size(1, 1),
          modelAutoRotate: true,
          modelAnimationTime: 2.75),
    ]);
    final high = buildHtmlStageDocument(
        page: modelPage, renderQuality: PresentationRenderQuality.high);
    expect(high, contains('water-molecule-quality.glb'));
    expect(high, contains('const floor = 0.79'));
    expect(high, contains('data-sutol-model-render-budget'));
    final economy = buildHtmlStageDocument(
        page: modelPage, renderQuality: PresentationRenderQuality.economy);
    expect(economy, contains('shadow-intensity="0.0"'));
    expect(economy, contains('const floor = 0.4'));
    expect(economy, isNot(contains(' auto-rotate auto-rotate-delay')));
    expect(economy, contains('this.currentTime=2.75'));
    expect(
        modelSourceForRender(
            'sutols-water-molecule', 'data:model/gltf-binary;base64,AAAA',
            highQuality: true),
        'data:model/gltf-binary;base64,AAAA');
  });
  test(
      'visual preset changes rendering in one undo step and preserves page data',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck([page]);
    controller.applyVisualProfile(PresentationVisualProfile.calm);
    expect(controller.effectSettings.reducedMotion, isTrue);
    expect(controller.effectSettings.renderQuality,
        PresentationRenderQuality.economy);
    expect(controller.pages.single, same(page));
    controller.undo();
    expect(controller.effectSettings.reducedMotion, isFalse);
    expect(controller.effectSettings.renderQuality,
        PresentationRenderQuality.balanced);
  });
  test(
      'reduced motion preserves content and camera but removes continuous model motion',
      () {
    const page =
        PresentationPage(id: 'motion', textBlocks: [], componentBlocks: [
      PresentationComponentBlock(
          id: 'atom',
          modelAssetId: 'sutols-bohr-atom',
          position: Offset.zero,
          size: Size(1, 1),
          modelAutoRotate: true,
          modelAnimationEnabled: true,
          modelAnimationTime: 2.5),
    ]);
    final doc = buildHtmlStageDocument(page: page, reducedMotion: true);
    expect(doc, contains('sutol-stage-reduced-motion'));
    expect(doc, isNot(contains(' auto-rotate auto-rotate-delay')));
    expect(doc, isNot(contains(' autoplay')));
    expect(doc, contains('this.currentTime=2.5'));
  });
  test(
      'animation clip and elapsed time survive camera sync and project round trip',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.replaceDeck(const [
      PresentationPage(id: 'animated', textBlocks: [], componentBlocks: [
        PresentationComponentBlock(
            id: 'block',
            modelAssetId: 'anitkabir',
            position: Offset.zero,
            size: Size(1, 1))
      ])
    ]);
    controller.syncRenderedModelCameraPoses(const {
      'animated:block': ModelViewerCameraPose(
          theta: 30,
          phi: 75,
          radius: 10,
          targetX: 0,
          targetY: 0,
          targetZ: 0,
          animationName: 'Walk',
          animationTime: 2.75)
    });
    final source = PresentationProjectCodec.encodeProject(
        pages: controller.pages, effectSettings: controller.effectSettings);
    final block = PresentationProjectCodec.decodeProject(source)
        .pages
        .single
        .componentBlocks
        .single;
    expect(block.modelAnimationName, 'Walk');
    expect(block.modelAnimationTime, 2.75);
  });
}
