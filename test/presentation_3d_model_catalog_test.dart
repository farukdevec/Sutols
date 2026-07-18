import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/state/presentation_controller.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  test('yolcu uçağı 3B model kataloğunda kayıtlıdır', () {
    final model = findPresentation3DModelAsset('yolcu-ucagi');

    expect(model, isNotNull);
    expect(model!.label, 'Yolcu Uçağı');
    expect(model.category, 'Ulaşım ve Havacılık');
    expect(model.assetPath, 'assets/models/yolcu_ucagi.glb');
    expect(model.hasAnimations, isFalse);
    expect(model.hasRig, isFalse);

    final asset = File(model.assetPath);
    expect(asset.existsSync(), isTrue);
    expect(asset.lengthSync(), model.byteSize);
  });

  test('gerçekçi dünya animasyonlu 3B model olarak kayıtlıdır', () {
    final model = findPresentation3DModelAsset('gercekci-dunya');

    expect(model, isNotNull);
    expect(model!.label, 'Gerçekçi Dünya');
    expect(model.category, 'Coğrafya ve Uzay');
    expect(model.assetPath, 'assets/models/gercekci_dunya.glb');
    expect(model.hasAnimations, isTrue);
    expect(model.hasRig, isFalse);

    final asset = File(model.assetPath);
    expect(asset.existsSync(), isTrue);
    expect(asset.lengthSync(), model.byteSize);
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
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains(sutolModelViewerScriptUrl));
    expect(document, contains('<model-viewer'));
    expect(document, contains('assets/assets/models/yolcu_ucagi.glb'));
    expect(document, contains('camera-controls'));
    expect(document, contains('camera-orbit="0.00deg 75.00deg auto"'));
    expect(document, isNot(contains('auto-rotate')));
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

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('assets/assets/models/gercekci_dunya.glb'));
    expect(document, contains('camera-controls autoplay'));
    expect(document, isNot(contains('auto-rotate')));
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

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('gercekci_dunya.glb'));
    expect(document, isNot(contains('autoplay')));
    expect(document, isNot(contains('auto-rotate')));
  });

  test('kaydedilen 360 derece model açısı HTML çıktısına yansır', () {
    const page = PresentationPage(
      id: 'rotating-model-page',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'earth-model',
          modelAssetId: 'gercekci-dunya',
          modelOrbitTheta: 128.5,
          modelOrbitPhi: 62,
          position: Offset(0.2, 0.2),
          size: Size(0.4, 0.4),
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('camera-controls autoplay'));
    expect(document, contains('camera-orbit="128.50deg 62.00deg auto"'));
    expect(document, isNot(contains('auto-rotate')));
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
