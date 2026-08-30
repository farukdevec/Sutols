import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/model_asset_service.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/widgets/editor_shell.dart';
import 'package:sutol/ui/widgets/html_stage/html_page_stage.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  test('Anıtkabir animasyonlu 3B model ve küçük resmiyle kayıtlıdır', () {
    final model = findPresentation3DModelAsset('anitkabir');

    expect(model, isNotNull);
    expect(model!.label, 'Anıtkabir');
    expect(model.category, 'Tarih ve Kültür');
    expect(model.assetPath, '/models/anitkabir.glb');
    expect(model.thumbnailPath, '/model_thumbnails/anitkabir.webp?v=2');
    expect(model.hasAnimations, isTrue);
    expect(model.hasRig, isFalse);
    expect(model.supportsVirtualTour, isTrue);
    expect(model.byteSize, 4302048);
    expect(model.exposure, 0.003);
    expect(model.environmentImage, 'neutral');
    expect(ModelAssetService.isLocalAssetPath(model.assetPath), isTrue);
    expect(
      ModelAssetService.thumbnailKey(thumbnailField: model.thumbnailPath),
      '/model_thumbnails/anitkabir.webp?v=2',
    );
  });

  testWidgets('Anıtkabir tuvalde mavi yer tutucu yerine HTML modeli kullanır',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 1000,
          height: 562.5,
          child: PresentationPageCanvas(
            page: PresentationPage(
              id: 'anitkabir-canvas',
              textBlocks: <PresentationTextBlock>[],
              componentBlocks: <PresentationComponentBlock>[
                PresentationComponentBlock(
                  id: 'anitkabir-block',
                  modelAssetId: 'anitkabir',
                  position: Offset(0.2, 0.2),
                  size: Size(0.4, 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(HtmlModelCanvas), findsOneWidget);
    expect(find.byType(HtmlPageStage), findsNothing);
  });

  testWidgets('yalnız ana editör tuvali kesin model kamera kaynağıdır',
      (tester) async {
    const page = PresentationPage(
      id: 'camera-source-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'camera-source-model',
          modelAssetId: 'anitkabir',
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    Future<void> pumpCanvas({required bool capture}) {
      return tester.pumpWidget(
        MaterialApp(
          home: PresentationPageCanvas(
            page: page,
            captureModelCameraState: capture,
          ),
        ),
      );
    }

    await pumpCanvas(capture: false);
    expect(
      tester
          .widget<HtmlModelCanvas>(find.byType(HtmlModelCanvas))
          .cameraStateKey,
      isNull,
    );

    await pumpCanvas(capture: true);
    expect(
      tester
          .widget<HtmlModelCanvas>(find.byType(HtmlModelCanvas))
          .cameraStateKey,
      'camera-source-page:camera-source-model',
    );
  });

  testWidgets('3B modele sağ tıklama bileşen bağlam olayını iletir',
      (tester) async {
    Offset? secondaryTapPosition;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 1000,
          height: 562.5,
          child: PresentationPageCanvas(
            page: const PresentationPage(
              id: 'anitkabir-context-menu',
              textBlocks: <PresentationTextBlock>[],
              componentBlocks: <PresentationComponentBlock>[
                PresentationComponentBlock(
                  id: 'anitkabir-block',
                  modelAssetId: 'anitkabir',
                  position: Offset(0.2, 0.2),
                  size: Size(0.4, 0.4),
                ),
              ],
            ),
            interactive: true,
            onSecondaryTapComponentBlock: (id, position) {
              expect(id, 'anitkabir-block');
              secondaryTapPosition = position;
            },
          ),
        ),
      ),
    );

    final overlay = find.byKey(
      const ValueKey<String>('model-interaction-overlay-anitkabir-block'),
    );
    expect(overlay, findsOneWidget);
    final gesture = await tester.startGesture(
      tester.getCenter(overlay),
      buttons: kSecondaryMouseButton,
    );
    await gesture.up();
    await tester.pump();

    expect(secondaryTapPosition, isNotNull);
  });

  testWidgets('sanal tur modeli birincil fare sürüklemesini kameraya iletir',
      (tester) async {
    var began = false;
    var ended = false;
    var dragDelta = Offset.zero;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 1000,
          height: 562.5,
          child: PresentationPageCanvas(
            page: const PresentationPage(
              id: 'mouse-tour',
              textBlocks: <PresentationTextBlock>[],
              componentBlocks: <PresentationComponentBlock>[
                PresentationComponentBlock(
                  id: 'tour-block',
                  modelAssetId: 'anitkabir',
                  modelTourEnabled: true,
                  position: Offset(0.2, 0.2),
                  size: Size(0.4, 0.4),
                ),
              ],
            ),
            interactive: true,
            selectedComponentBlockId: 'tour-block',
            selectedComponentBlockIds: const <String>{'tour-block'},
            onBeginModelOrbit: (_) => began = true,
            onPanModelTour: (_, delta) => dragDelta += delta,
            onEndModelOrbit: () => ended = true,
          ),
        ),
      ),
    );

    final overlay = find.byKey(
      const ValueKey<String>('model-interaction-overlay-tour-block'),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(overlay),
      buttons: kPrimaryMouseButton,
    );
    await gesture.moveBy(const Offset(70, -35));
    await gesture.up();
    await tester.pump();

    expect(began, isTrue);
    expect(dragDelta.dx, closeTo(70, 0.01));
    expect(dragDelta.dy, closeTo(-35, 0.01));
    expect(ended, isTrue);
  });

  test('arka plansız 3B model sahnesi zorunlu olarak şeffaftır', () {
    const page = PresentationPage(
      id: 'transparent-anitkabir',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'anitkabir-block',
          modelAssetId: 'anitkabir',
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      showBackground: false,
      modelSourcesById: const <String, String>{
        'anitkabir': '/models/anitkabir.glb',
      },
    );

    expect(document, contains('sutol-stage-without-background'));
    expect(document, contains('background: transparent !important;'));
    expect(document, contains('src="/models/anitkabir.glb"'));
    expect(document, contains('tone-mapping="neutral"'));
    expect(document, contains('exposure="0.0030"'));
    expect(document, contains('environment-image="neutral"'));
    expect(document, contains('field-of-view="45.00000deg"'));
    expect(document, contains('camera-orbit="0.00deg 75.00deg 100.00%"'));
  });

  test('3B model 10x yakınlaştırmayı HTML sahnesine aktarır', () {
    const page = PresentationPage(
      id: 'zoomed-model',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'zoomed-anitkabir',
          modelAssetId: 'anitkabir',
          modelZoom: 10,
          modelTargetX: 22,
          modelTargetY: 6,
          modelTargetZ: -18,
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'anitkabir': '/models/anitkabir.glb',
      },
    );

    expect(document, contains('field-of-view="45.00000deg"'));
    expect(document, contains('camera-orbit="0.00deg 75.00deg 10.00%"'));
    expect(document, contains('min-camera-orbit="auto auto 1%"'));
    expect(document, contains('camera-target="auto auto auto"'));
    expect(document, contains('data-sutol-target-x="22.00"'));
    expect(document, contains('data-sutol-target-y="6.00"'));
    expect(document, contains('data-sutol-target-z="-18.00"'));
    expect(document, contains("targetX.toFixed(5) + 'm '"));
    expect(document, contains('Math.min(10, Number(item.modelZoom)'));
  });

  test('yolcu uçağı 3B model kataloğunda kayıtlıdır', () {
    final model = findPresentation3DModelAsset('yolcu-ucagi');

    expect(model, isNotNull);
    expect(model!.label, 'Yolcu Uçağı');
    expect(model.category, 'Ulaşım ve Havacılık');
    expect(model.assetPath, 'assets/models/yolcu_ucagi.glb');
    expect(model.hasAnimations, isFalse);
    expect(model.hasRig, isFalse);
    expect(model.byteSize, 1506520);
  });

  test('gerçekçi dünya animasyonlu 3B model olarak kayıtlıdır', () {
    final model = findPresentation3DModelAsset('gercekci-dunya');

    expect(model, isNotNull);
    expect(model!.label, 'Gerçekçi Dünya');
    expect(model.category, 'Coğrafya ve Uzay');
    expect(model.assetPath, 'assets/models/gercekci_dunya.glb');
    expect(model.hasAnimations, isTrue);
    expect(model.hasRig, isFalse);
    expect(model.byteSize, 4192768);
  });

  test('3B model sahneye seçili ve boyutlandırılabilir bileşen olarak eklenir',
      () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    final model = findPresentation3DModelAsset('yolcu-ucagi')!;

    controller.add3DModelBlock(model);

    final block = controller.selectedComponentBlock;
    expect(block, isNotNull);
    expect(block!.modelAssetId, model.id);
    expect(block.modelAnimationEnabled, isTrue);
    expect(block.modelOrbitEnabled, isFalse);
    expect(block.size, const Size(0.40, 0.40));
    expect(controller.selectedPage.componentBlocks, contains(block));
  });

  test('seçili 3B model animasyonu açılıp kapatılabilir', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(
      findPresentation3DModelAsset('gercekci-dunya')!,
    );

    controller.updateSelectedModelAnimationEnabled(false);

    expect(controller.selectedComponentBlock!.modelAnimationEnabled, isFalse);
    expect(controller.selectedComponentBlock!.modelOrbitEnabled, isFalse);
    expect(controller.canUndo, isTrue);
  });

  test('seçili 3B model fareyle döndürülür ve açısı korunur', () {
    final controller = PresentationController();
    addTearDown(controller.dispose);
    controller.add3DModelBlock(
      findPresentation3DModelAsset('gercekci-dunya')!,
    );

    controller.toggleSelectedModelOrbit();
    controller.beginSelectedModelOrbitGesture();
    controller.rotateSelectedModel(const Offset(20, -10));
    controller.rotateSelectedModel(const Offset(0, 0));
    controller.endSelectedModelOrbitGesture();

    expect(controller.selectedComponentBlock!.modelOrbitEnabled, isTrue);
    expect(controller.selectedComponentBlock!.modelOrbitTheta, 349);
    expect(controller.selectedComponentBlock!.modelOrbitPhi, 70.5);

    controller.undo();
    expect(controller.selectedComponentBlock!.modelOrbitTheta, 0);
    expect(controller.selectedComponentBlock!.modelOrbitPhi, 75);

    controller.toggleSelectedModelOrbit();
    controller.rotateSelectedModel(const Offset(20, 20));
    expect(controller.selectedComponentBlock!.modelOrbitTheta, 0);
    expect(controller.selectedComponentBlock!.modelOrbitPhi, 75);
  });

  test('3B model HTML sahnesinde model-viewer ile gösterilir', () {
    const page = PresentationPage(
      id: 'model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'model-1',
          modelAssetId: 'yolcu-ucagi',
          modelOrbitEnabled: true,
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'yolcu-ucagi': 'https://assets.sutols.com/yolcu_ucagi.glb?token=test',
      },
    );

    expect(document, contains(sutolModelViewerScriptUrl));
    expect(document, contains('<model-viewer'));
    expect(document,
        contains('https://assets.sutols.com/yolcu_ucagi.glb?token=test'));
    expect(document, contains('camera-controls'));
    expect(document, contains('camera-orbit="0.00deg 75.00deg 100.00%"'));
    expect(document, isNot(contains('@font-face')));
    expect(document, isNot(contains(' auto-rotate')));
  });

  test('HTML sahnesi yalnız kullanılan yerel font ailesini içerir', () {
    const page = PresentationPage(
      id: 'filtered-font-page',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'roboto-title',
          text: 'Sutols',
          position: Offset.zero,
          fontSize: 32,
          type: PresentationTextType.title,
          widthFactor: 1,
          textStyle: PresentationTextStyle.googleRoboto,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains("@font-face {\n  font-family: 'Roboto'"));
    expect(
      document,
      isNot(contains("@font-face {\n  font-family: 'Alegreya'")),
    );
  });

  test('sanal tur modeli sunum ve dışa aktarımda sürüklenerek keşfedilebilir',
      () {
    const page = PresentationPage(
      id: 'anitkabir-tour',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'anitkabir-tour-model',
          modelAssetId: 'anitkabir',
          modelTourEnabled: true,
          modelOrbitTheta: 35,
          modelOrbitPhi: 72,
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'anitkabir': '/models/anitkabir.glb',
      },
    );

    expect(document, contains('camera-controls'));
    expect(document, contains('camera-orbit="35.00deg 72.00deg 100.00%"'));
    expect(document, contains('min-camera-orbit="auto 42deg 5%"'));
    expect(document, contains('max-camera-orbit="auto 89deg 250%"'));
    expect(document, contains('interpolation-decay="16"'));
    expect(document, contains('orbit-sensitivity="0.78"'));
    expect(document, contains('disable-pan'));
    expect(document, contains('data-sutol-tour-ground="true"'));
    expect(document, contains('scheduleTourCamera(modelViewer, pose)'));
    expect(document, contains('requestAnimationFrame(function ()'));
  });

  test('turdan çıkınca kaydedilen model sunumda aynı kamerada donar', () {
    const page = PresentationPage(
      id: 'frozen-anitkabir-tour',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'frozen-anitkabir-model',
          modelAssetId: 'anitkabir',
          modelTourEnabled: true,
          modelTourFrozen: true,
          modelAnimationEnabled: false,
          modelAutoRotate: false,
          modelOrbitTheta: 128,
          modelOrbitPhi: 64,
          modelZoom: 3.25,
          modelTargetX: 12,
          modelTargetZ: -7,
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'anitkabir': '/models/anitkabir.glb',
      },
    );
    final modelTag = RegExp(r'<model-viewer[^>]*>').firstMatch(document)![0]!;

    expect(modelTag, isNot(contains('camera-controls')));
    expect(modelTag, isNot(contains('auto-rotate')));
    expect(modelTag, isNot(contains('autoplay')));
    expect(modelTag, contains('camera-orbit="128.00deg 64.00deg 30.77%"'));
    expect(modelTag, contains('data-sutol-target-x="12.00"'));
    expect(modelTag, contains('data-sutol-target-z="-7.00"'));
    expect(document, contains('zoom: Number(item.modelZoom)'));

    // Iframe, GLB geometrisinden önce yüklenebilir. Kamera mesajı bu anda
    // çalıştığında store'daki gerçek target sıfır boyutlu geçici bounding-box
    // ile ezilmemeli; geometriye bağlı clamp yalnız applyModelTarget'ta kalır.
    final scheduler = document.substring(
      document.indexOf('function scheduleTourCamera'),
      document.indexOf('function restoreModelCamera'),
    );
    expect(
      document,
      contains('!Number.isFinite(dimensions.x) || dimensions.x <= 0'),
    );
    expect(scheduler, isNot(contains('viewer.getDimensions()')));
    expect(
      scheduler,
      contains('viewer.dataset.sutolTargetX = targetX.toFixed(5)'),
    );
    expect(
      scheduler,
      contains('owner.dataset.sutolTargetX = targetX.toFixed(5)'),
    );
    expect(scheduler, contains('viewer.jumpCameraToGoal()'));
  });

  test('exact tour camera target is not recomputed for presentation', () {
    const page = PresentationPage(
      id: 'exact-tour-camera',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'exact-tour-model',
          modelAssetId: 'anitkabir',
          modelTourEnabled: true,
          modelTourFrozen: true,
          modelOrbitTheta: 18,
          modelOrbitPhi: 84,
          modelCameraRadius: 17.625,
          modelTurntableRotation: 1.2345,
          modelFieldOfView: 37.25,
          modelTargetX: 41.25,
          modelTargetY: -3.55,
          modelTargetZ: 72.5,
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'anitkabir': '/models/anitkabir.glb',
      },
    );
    final modelTag = RegExp(r'<model-viewer[^>]*>').firstMatch(document)![0]!;

    expect(modelTag, contains('camera-orbit="18.00deg 84.00deg 17.6250000m"'));
    expect(modelTag, contains('data-sutol-target-x="41.25"'));
    expect(modelTag, contains('data-sutol-target-y="-3.55"'));
    expect(modelTag, contains('data-sutol-target-z="72.50"'));
    expect(
      modelTag,
      contains('data-sutol-turntable-rotation="1.23450000"'),
    );
    expect(modelTag, contains('field-of-view="37.25000deg"'));
    expect(modelTag, contains('data-sutol-exact-camera-pose="true"'));
    expect(
        document, contains('viewer.resetTurntableRotation(turntableRotation)'));
    expect(document, contains('hasExactCameraPose ? y'));
    expect(document, contains('? x\n'));
    expect(document, contains('? z\n'));
  });

  test('sunum geçişinde her sayfanın donmuş tur kamerası HTML sahnede korunur',
      () {
    const from = PresentationPage(
      id: 'tour-camera-from',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'tour-model-from',
          modelAssetId: 'anitkabir',
          modelTourEnabled: true,
          modelTourFrozen: true,
          modelAnimationEnabled: false,
          modelOrbitTheta: 25,
          modelOrbitPhi: 60,
          modelZoom: 2,
          modelTargetX: 4,
          modelTargetZ: -3,
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );
    const to = PresentationPage(
      id: 'tour-camera-to',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'tour-model-to',
          modelAssetId: 'anitkabir',
          modelTourEnabled: true,
          modelTourFrozen: true,
          modelAnimationEnabled: false,
          modelOrbitTheta: 210,
          modelOrbitPhi: 88,
          modelZoom: 5,
          modelTargetX: -8,
          modelTargetZ: 6,
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    final document = buildHtmlPageTransitionDocument(
      from: from,
      to: to,
      kind: PresentationTransitionKind.fade,
      durationMs: 600,
      modelSourcesById: const <String, String>{
        'anitkabir': '/models/anitkabir.glb',
      },
    );

    expect(document, contains('camera-orbit="25.00deg 60.00deg 50.00%"'));
    expect(document, contains('data-sutol-target-x="4.00"'));
    expect(document, contains('data-sutol-target-z="-3.00"'));
    expect(document, contains('camera-orbit="210.00deg 88.00deg 20.00%"'));
    expect(document, contains('data-sutol-target-x="-8.00"'));
    expect(document, contains('data-sutol-target-z="6.00"'));
    expect(document, contains('const pendingTourCameras = new Map()'));
    expect(document, contains('window.SutolRestoreModelCamera'));
    expect(document, contains('data-sutol-model-zoom="2.0000"'));
    expect(document, contains('data-sutol-model-zoom="5.0000"'));
  });

  test(
      '3B tur noktası model HTML çıktısına başlık ve slayt bağlantısıyla eklenir',
      () {
    const page = PresentationPage(
      id: 'anitkabir-tour-points',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'anitkabir-tour-model',
          modelAssetId: 'anitkabir',
          modelTourEnabled: true,
          modelTourHotspots: <ModelTourHotspot>[
            ModelTourHotspot(
              id: 'lion-road',
              label: 'Aslanlı Yol',
              kind: ModelTourHotspotKind.text,
              description: 'Tören aksının başlangıcı',
              targetPageId: 'lion-road-slide',
              x: .25,
              y: -.1,
              z: .4,
            ),
          ],
          position: Offset.zero,
          size: Size(1, 1),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'anitkabir': '/models/anitkabir.glb',
      },
    );

    expect(document, contains('slot="hotspot-lion-road"'));
    expect(document, contains('sutol-3d-tour-hotspot is-text'));
    expect(document, contains('Aslanlı Yol'));
    expect(document, contains('data-hotspot-target="lion-road-slide"'));
    expect(document, contains('data-position="0.25000m -0.10000m 0.40000m"'));
    expect(document, isNot(contains('data-sutol-hotspot-x=')));
    expect(document, contains('.sutol-3d-tour-hotspot.is-text'));
  });

  test('tur yüzeyi seçme belgesi gerçek 3B koordinat protokolünü açar', () {
    final document = buildHtmlStageDocument(
      page: const PresentationPage(
        id: 'surface-pick-tour',
        textBlocks: <PresentationTextBlock>[],
        componentBlocks: <PresentationComponentBlock>[],
      ),
      tourPointPlacementEnabled: true,
    );

    expect(document, contains('data-sutol-tour-placement="true"'));
    expect(document, contains('positionAndNormalFromPoint'));
    expect(document, contains('sutol-tour-surface-point'));
    expect(document, contains('sutol-tour-surface-miss'));
    expect(document, contains('sutol-tour-surface-pick'));
    expect(document, contains('document.elementFromPoint'));
    expect(document, contains('sutol-tour-interaction'));
    expect(document, contains('sutol-tour-hotspot'));
    expect(document, contains('sutol-tour-camera'));
  });

  test('3B model yüklenemezse konu bileşeni yedek olarak hazırlanır', () {
    const page = PresentationPage(
      id: 'fallback-model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'remote-model',
          kind: PresentationComponentKind.egitim01,
          modelAssetId: 'uzak-model',
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'uzak-model': 'https://assets.sutols.com/uzak-model.glb?token=test',
      },
    );

    expect(document, contains('sutol-3d-model-fallback'));
    expect(document, contains('sutol-edu01-wrap'));
    expect(document, contains("console.error('Sutols 3B model yüklenemedi'"));
    expect(document, contains('fallback.hidden=false'));
    expect(document, isNot(contains("textContent='3B model yüklenemedi'")));
  });

  test('uploaded photo is rendered as an image, never as a 3D model', () {
    const page = PresentationPage(
      id: 'photo-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'photo-1',
          imageAssetId: 'photo-source-1',
          imageAspectRatio: 0.75,
          position: Offset(0.2, 0.2),
          size: Size(0.24, 0.32),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      imageSourcesById: const <String, String>{
        'photo-source-1': 'data:image/png;base64,TEST',
      },
    );

    expect(document, contains('component-uploaded-image'));
    expect(document, contains('data-sutol-image-id="photo-source-1"'));
    expect(document, isNot(contains('<model-viewer')));
    expect(document, isNot(contains('data-sutol-model-id')));
  });

  test('animasyonlu dünya modeli sahnede otomatik oynatılır', () {
    const page = PresentationPage(
      id: 'animated-model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'earth-model',
          modelAssetId: 'gercekci-dunya',
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'gercekci-dunya':
            'https://assets.sutols.com/gercekci_dunya.glb?token=test',
      },
    );

    expect(document, contains('gercekci_dunya.glb'));
    expect(document, contains('autoplay'));
    expect(document, isNot(contains(' auto-rotate')));
  });

  test('kapatılan model animasyonu HTML sahnesinde oynatılmaz', () {
    const page = PresentationPage(
      id: 'paused-model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'earth-model',
          modelAssetId: 'gercekci-dunya',
          modelAnimationEnabled: false,
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'gercekci-dunya':
            'https://assets.sutols.com/gercekci_dunya.glb?token=test',
      },
    );

    expect(document, contains('gercekci_dunya.glb'));
    expect(document, isNot(contains(' autoplay')));
    expect(document, isNot(contains(' auto-rotate')));
  });

  test('kaydedilen 360 derece model açısı HTML çıktısına yansır', () {
    const page = PresentationPage(
      id: 'rotating-model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'earth-model',
          modelAssetId: 'gercekci-dunya',
          modelOrbitEnabled: true,
          modelOrbitTheta: 128.5,
          modelOrbitPhi: 62,
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      modelSourcesById: const <String, String>{
        'gercekci-dunya':
            'https://assets.sutols.com/gercekci_dunya.glb?token=test',
      },
    );

    expect(document, contains('camera-controls'));
    expect(document, contains('autoplay'));
    expect(document, contains('camera-orbit="128.50deg 62.00deg 100.00%"'));
    expect(document, isNot(contains(' auto-rotate')));
  });

  test('HTML export 3B model için gömülü kaynak kullanır', () {
    const page = PresentationPage(
      id: 'export-model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'model-1',
          modelAssetId: 'yolcu-ucagi',
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildPresentationExportHtml(
      pages: const <PresentationPage>[page],
      modelSourcesById: const <String, String>{
        'yolcu-ucagi': 'data:model/gltf-binary;base64,TEST',
      },
    );

    expect(document, contains(sutolModelViewerScriptUrl));
    expect(document, contains('data:model/gltf-binary;base64,TEST'));
    expect(document, contains('sutol-export-stage'));
    // Export belgesinin de yükleme sonrası hedefi metreye çevirmesi gerekir;
    // aksi halde model sahnesi editörle aynı hedefte açılmaz.
    expect(document, contains('window.SutolApplyModelTarget'));
    expect(document, contains('function renderTourControls()'));
    expect(document, contains('const tourKeys = new Set()'));
    expect(document, contains("arrowup: 'w'"));
    expect(document, contains("arrowright: 'd'"));
    expect(document, contains('const magnitude = Math.hypot(forward, right)'));
    expect(document, contains('const movement = 36.0 * elapsed'));
    expect(document, contains('function requestTourFrame()'));
    expect(document, contains('tourFrame = null;'));
    expect(document, contains('const tourBoundsByViewer = new WeakMap()'));
    expect(document, contains('tourBoundsByViewer.set(viewer, bounds)'));
    expect(
        document,
        isNot(contains(
            'toggleLaser(initialLaserPointer);\n  tourFrame = requestAnimationFrame(tickTour);')));
  });

  test('yumuşak geçiş aynı 3B modelin açılarını HTML içinde dönüştürür', () {
    const pages = <PresentationPage>[
      PresentationPage(
        id: 'front',
        textBlocks: <PresentationTextBlock>[],
        componentBlocks: <PresentationComponentBlock>[
          PresentationComponentBlock(
            id: 'earth-front',
            modelAssetId: 'gercekci-dunya',
            modelOrbitTheta: 0,
            modelOrbitPhi: 75,
            position: Offset(0.25, 0.2),
            size: Size(0.5, 0.5),
          ),
        ],
      ),
      PresentationPage(
        id: 'back',
        textBlocks: <PresentationTextBlock>[],
        componentBlocks: <PresentationComponentBlock>[
          PresentationComponentBlock(
            id: 'earth-back',
            modelAssetId: 'gercekci-dunya',
            modelOrbitTheta: 180,
            modelOrbitPhi: 75,
            position: Offset(0.25, 0.2),
            size: Size(0.5, 0.5),
          ),
        ],
      ),
    ];

    final document = buildPresentationExportHtml(
      pages: pages,
      effectSettings: const PresentationEffectSettings(
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 1400,
      ),
      modelSourcesById: const <String, String>{
        'gercekci-dunya': 'data:model/gltf-binary;base64,EARTH',
      },
    );

    expect(document, contains('transition-smooth'));
    expect(document, contains('beginSmoothTransition'));
    expect(document, contains('data-sutol-orbit-theta="180.00"'));
    expect(document, contains('const transitionDurationMs = 1400'));
    expect(
        document, contains('viewer.dataset.sutolTargetX = targetX.toFixed(2)'));
  });

  test('popüler geçişler HTML sunumuna aktarılır', () {
    const transitions = <PresentationTransitionKind, String>{
      PresentationTransitionKind.wipe: 'transition-wipe',
      PresentationTransitionKind.split: 'transition-split',
      PresentationTransitionKind.reveal: 'transition-reveal',
      PresentationTransitionKind.cover: 'transition-cover',
      PresentationTransitionKind.uncover: 'transition-uncover',
      PresentationTransitionKind.flip: 'transition-flip',
    };

    for (final entry in transitions.entries) {
      final document = buildPresentationExportHtml(
        pages: const <PresentationPage>[],
        effectSettings: PresentationEffectSettings(
          transitionKind: entry.key,
        ),
      );

      expect(document, contains(entry.value));
    }
  });

  test('temel sahne geçişleri gelen ve çıkan slaytı ayrı hareket ettirir', () {
    final document = buildPresentationExportHtml(
      pages: const <PresentationPage>[
        PresentationPage(
          id: 'first',
          textBlocks: <PresentationTextBlock>[],
          transitionAfter: PresentationTransitionKind.cover,
        ),
        PresentationPage(
          id: 'second',
          textBlocks: <PresentationTextBlock>[],
          transitionAfter: PresentationTransitionKind.fade,
        ),
        PresentationPage(id: 'third', textBlocks: <PresentationTextBlock>[]),
      ],
      effectSettings: const PresentationEffectSettings(
        transitionKind: PresentationTransitionKind.slide,
      ),
    );

    expect(document, contains('sutolTransitionFadeIn'));
    expect(document, contains('sutolTransitionFadeOut'));
    expect(document, contains('sutolTransitionPushIn'));
    expect(document, contains('sutolTransitionPushOut'));
    expect(
      document,
      contains(
        '.sutol-export-shell.transition-cover .sutol-export-slide.is-leaving',
      ),
    );
    expect(
      document,
      contains(
        '.sutol-export-shell.transition-uncover .sutol-export-slide.is-leaving',
      ),
    );
    expect(document, contains('beginSceneTransition(index, next)'));
    expect(document, contains('data-transition-after="transition-cover"'));
    expect(document, contains('data-transition-after="transition-fade"'));
    expect(document, contains('transitionSource?.dataset?.transitionAfter'));
  });

  test('tekrarlanan 3B model kaynağı HTML dosyasına bir kez gömülür', () {
    const source = 'data:model/gltf-binary;base64,REPEATED_MODEL_SOURCE';
    final pages = List<PresentationPage>.generate(
      6,
      (index) => PresentationPage(
        id: 'model-page-$index',
        textBlocks: const <PresentationTextBlock>[],
        componentBlocks: <PresentationComponentBlock>[
          PresentationComponentBlock(
            id: 'earth-$index',
            modelAssetId: 'gercekci-dunya',
            position: const Offset(0.2, 0.2),
            size: const Size(0.5, 0.5),
          ),
        ],
      ),
    );

    final document = buildPresentationExportHtml(
      pages: pages,
      modelSourcesById: const <String, String>{
        'gercekci-dunya': source,
      },
    );

    expect(RegExp(source).allMatches(document), hasLength(1));
    expect(
      RegExp('data-sutol-model-source-id="gercekci-dunya"')
          .allMatches(document),
      hasLength(6),
    );
    expect(document, contains('function initializePersistentModels()'));
    expect(document, contains('function preparePersistentModels('));
    expect(
      document,
      contains("if (source && !viewer.hasAttribute('src'))"),
    );
    expect(document, contains('preparePersistentModels(next)'));
  });

  test('kalıcı model havuzu slayt açılarını ve tur duraklarını ayrı saklar',
      () {
    const pages = <PresentationPage>[
      PresentationPage(
        id: 'tour-front',
        textBlocks: <PresentationTextBlock>[],
        componentBlocks: <PresentationComponentBlock>[
          PresentationComponentBlock(
            id: 'anitkabir-front',
            modelAssetId: 'anitkabir',
            modelTourEnabled: true,
            modelOrbitTheta: 24,
            modelOrbitPhi: 81,
            modelTargetX: 3,
            modelTargetZ: -5,
            modelTourHotspots: <ModelTourHotspot>[
              ModelTourHotspot(
                id: 'front-stop',
                label: 'Ön Durak',
                x: 1,
                y: 2,
                z: 3,
              ),
            ],
            position: Offset.zero,
            size: Size(1, 1),
          ),
        ],
      ),
      PresentationPage(
        id: 'tour-back',
        textBlocks: <PresentationTextBlock>[],
        componentBlocks: <PresentationComponentBlock>[
          PresentationComponentBlock(
            id: 'anitkabir-back',
            modelAssetId: 'anitkabir',
            modelTourEnabled: true,
            modelOrbitTheta: 196,
            modelOrbitPhi: 74,
            modelTargetX: -7,
            modelTargetZ: 9,
            modelTourHotspots: <ModelTourHotspot>[
              ModelTourHotspot(
                id: 'back-stop',
                label: 'Arka Durak',
                x: -1,
                y: 4,
                z: 6,
              ),
            ],
            position: Offset.zero,
            size: Size(1, 1),
          ),
        ],
      ),
    ];

    final document = buildPresentationExportHtml(
      pages: pages,
      modelSourcesById: const <String, String>{
        'anitkabir': 'data:model/gltf-binary;base64,ANITKABIR',
      },
    );

    expect(RegExp('base64,ANITKABIR').allMatches(document), hasLength(1));
    expect(document, contains('camera-orbit="24.00deg 81.00deg 100.00%"'));
    expect(document, contains('camera-orbit="196.00deg 74.00deg 100.00%"'));
    expect(document, contains('slot="hotspot-front-stop"'));
    expect(document, contains('slot="hotspot-back-stop"'));
    expect(document, contains('hotspotMarkup: viewer.innerHTML'));
    expect(document, contains('viewer.innerHTML = config.hotspotMarkup'));
    expect(document, contains('config.runtimeCameraOrbit ='));
    expect(document, contains('window.SutolApplyModelTarget?.(viewer)'));
    expect(document, contains('viewer.jumpCameraToGoal?.()'));
  });

  test('3B model proje kaydında korunur', () {
    const page = PresentationPage(
      id: 'saved-model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'model-1',
          modelAssetId: 'yolcu-ucagi',
          modelAnimationEnabled: false,
          modelOrbitEnabled: true,
          modelOrbitTheta: 210,
          modelOrbitPhi: 88,
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final source = PresentationProjectCodec.encodeProject(
      pages: const <PresentationPage>[page],
      effectSettings: const PresentationEffectSettings(),
    );
    final project = PresentationProjectCodec.decodeProject(source);

    expect(
      project.pages.single.componentBlocks.single.modelAssetId,
      'yolcu-ucagi',
    );
    expect(
      project.pages.single.componentBlocks.single.modelAnimationEnabled,
      isFalse,
    );
    expect(
      project.pages.single.componentBlocks.single.modelOrbitEnabled,
      isTrue,
    );
    expect(project.pages.single.componentBlocks.single.modelOrbitTheta, 210);
    expect(project.pages.single.componentBlocks.single.modelOrbitPhi, 88);
  });
}
