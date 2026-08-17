import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_project_codec.dart';
import 'package:sutol/services/remote_model_sources.dart';

void main() {
  test('persists remote model sources used by the project', () {
    const modelId = 'persisted-model-source';
    const modelUrl = 'https://assets.sutols.com/persisted-model.glb';
    RemoteModelSources.registerAll(const <String, String>{modelId: modelUrl});

    final source = PresentationProjectCodec.encodeProject(
      pages: const <PresentationPage>[
        PresentationPage(
          id: 'model-page',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'model-block',
              modelAssetId: modelId,
              position: Offset(0.6, 0.2),
              size: Size(0.3, 0.5),
            ),
          ],
        ),
      ],
      effectSettings: const PresentationEffectSettings(),
    );

    expect(source, contains('"modelSourcesById"'));
    expect(source, contains(modelUrl));
    PresentationProjectCodec.decodeProject(source);
    expect(RemoteModelSources.sourceFor(modelId), modelUrl);
  });

  test('round trips presentation project json', () {
    const pages = <PresentationPage>[
      PresentationPage(
        id: 'page-4',
        backgroundKind: PresentationBackgroundKind.solarEnergyScene,
        speakerNotes: 'Konusmaci notu',
        transitionAfter: PresentationTransitionKind.cover,
        textBlocks: <PresentationTextBlock>[
          PresentationTextBlock(
            id: 'text-7',
            text: 'Gunes',
            position: Offset(0.08, 0.12),
            fontSize: 54,
            type: PresentationTextType.title,
            widthFactor: 0.46,
            heightFactor: 0.22,
            textStyle: PresentationTextStyle.bilimDramatik,
            textAnimation: PresentationTextAnimation.optikDeneysel,
            textColorHex: '#A855F7',
            glowIntensity: 1.6,
            revealStep: 1,
            hotspotTargetPageId: 'page-5',
            textBold: true,
            textItalic: true,
            textUnderline: true,
            textAlign: PresentationTextAlign.center,
          ),
        ],
        componentBlocks: <PresentationComponentBlock>[
          PresentationComponentBlock(
            id: 'component-3',
            kind: PresentationComponentKind.fizik01,
            position: Offset(0.62, 0.24),
            size: Size(0.25, 0.32),
            revealStep: 2,
            hotspotTargetPageId: 'page-5',
          ),
          PresentationComponentBlock(
            id: 'component-4',
            modelAssetId: 'gercekci-dunya',
            modelAnimationEnabled: false,
            modelAutoRotate: true,
            modelOrbitEnabled: true,
            modelOrbitTheta: 45,
            modelOrbitPhi: 60,
            position: Offset(0.1, 0.5),
            size: Size(0.2, 0.3),
          ),
          PresentationComponentBlock(
            id: 'photo-5',
            imageAssetId: 'photo-source-5',
            imageAspectRatio: 0.75,
            position: Offset(0.3, 0.2),
            size: Size(0.24, 0.32),
          ),
        ],
      ),
    ];
    const settings = PresentationEffectSettings(
      transitionKind: PresentationTransitionKind.zoom,
      transitionDurationMs: 640,
      zoomEnabled: true,
      zoomScale: 1.8,
      reducedMotion: true,
    );

    final source = PresentationProjectCodec.encodeProject(
      pages: pages,
      effectSettings: settings,
    );
    final project = PresentationProjectCodec.decodeProject(source);

    expect(project.pages, hasLength(1));
    expect(project.pages.single.id, 'page-4');
    expect(
      project.pages.single.transitionAfter,
      PresentationTransitionKind.cover,
    );
    expect(
      project.pages.single.backgroundKind,
      PresentationBackgroundKind.solarEnergyScene,
    );
    expect(project.pages.single.textBlocks.single.text, 'Gunes');
    expect(
      project.pages.single.textBlocks.single.textStyle,
      PresentationTextStyle.bilimDramatik,
    );
    expect(
      project.pages.single.textBlocks.single.textAnimation,
      PresentationTextAnimation.optikDeneysel,
    );
    expect(project.pages.single.textBlocks.single.textColorHex, '#A855F7');
    expect(project.pages.single.textBlocks.single.glowIntensity, 1.6);
    expect(project.pages.single.textBlocks.single.heightFactor, 0.22);
    expect(project.pages.single.textBlocks.single.textBold, isTrue);
    expect(project.pages.single.textBlocks.single.textItalic, isTrue);
    expect(project.pages.single.textBlocks.single.textUnderline, isTrue);
    expect(
      project.pages.single.textBlocks.single.textAlign,
      PresentationTextAlign.center,
    );
    expect(project.pages.single.componentBlocks, hasLength(3));
    expect(project.pages.single.componentBlocks.first.id, 'component-3');
    expect(
      project.pages.single.componentBlocks.first.kind,
      PresentationComponentKind.fizik01,
    );
    expect(project.pages.single.componentBlocks.first.size.width, 0.25);
    expect(project.pages.single.componentBlocks.first.revealStep, 2);
    final modelBlock = project.pages.single.componentBlocks[1];
    expect(modelBlock.id, 'component-4');
    expect(modelBlock.modelAssetId, 'gercekci-dunya');
    expect(modelBlock.modelAnimationEnabled, isFalse);
    expect(modelBlock.modelAutoRotate, isTrue);
    expect(modelBlock.modelOrbitEnabled, isTrue);
    expect(modelBlock.modelOrbitTheta, 45);
    expect(modelBlock.modelOrbitPhi, 60);
    final imageBlock = project.pages.single.componentBlocks.last;
    expect(imageBlock.modelAssetId, isNull);
    expect(imageBlock.imageAssetId, 'photo-source-5');
    expect(imageBlock.imageAspectRatio, 0.75);
    expect(
      project.effectSettings.transitionKind,
      PresentationTransitionKind.zoom,
    );
    expect(project.effectSettings.zoomEnabled, isTrue);
    expect(project.effectSettings.reducedMotion, isTrue);
  });

  test('migrates legacy photo ids out of the 3D model field', () {
    const source = '''
{"format":"sutol.presentation","version":1,"pages":[{"id":"page-1","backgroundKind":"science","textBlocks":[],"componentBlocks":[{"id":"component-1","kind":"edebiyat01","modelAssetId":"photo-123","position":{"x":0.1,"y":0.1},"size":{"width":0.3,"height":0.2}}]}]}
''';

    final block = PresentationProjectCodec.decodeProject(source)
        .pages
        .single
        .componentBlocks
        .single;
    expect(block.modelAssetId, isNull);
    expect(block.imageAssetId, 'photo-123');
  });

  test('round trips the popular presentation transitions', () {
    const transitions = <PresentationTransitionKind>[
      PresentationTransitionKind.wipe,
      PresentationTransitionKind.split,
      PresentationTransitionKind.reveal,
      PresentationTransitionKind.cover,
      PresentationTransitionKind.uncover,
      PresentationTransitionKind.flip,
    ];

    for (final transition in transitions) {
      final source = PresentationProjectCodec.encodeProject(
        pages: const <PresentationPage>[
          PresentationPage(
            id: 'transition-page',
            textBlocks: <PresentationTextBlock>[],
          ),
        ],
        effectSettings: PresentationEffectSettings(
          transitionKind: transition,
        ),
      );
      final project = PresentationProjectCodec.decodeProject(source);

      expect(project.effectSettings.transitionKind, transition);
    }
  });

  test('uses the standard text style for legacy projects', () {
    final project = PresentationProjectCodec.decodeProject('''
{
  "format": "sutol-project",
  "version": 1,
  "pages": [
    {
      "id": "legacy-page",
      "textBlocks": [
        {
          "id": "legacy-text",
          "text": "Eski metin",
          "position": {"dx": 0.1, "dy": 0.1},
          "fontSize": 42,
          "type": "body",
          "widthFactor": 0.4
        }
      ],
      "componentBlocks": [
        {
          "id": "legacy-model",
          "modelAssetId": "yolcu-ucagi",
          "position": {"dx": 0.2, "dy": 0.2},
          "size": {"width": 0.3, "height": 0.3}
        }
      ]
    }
  ]
}
''');

    expect(
      project.pages.single.textBlocks.single.textStyle,
      PresentationTextStyle.standard,
    );
    expect(
      project.pages.single.textBlocks.single.textAnimation,
      PresentationTextAnimation.none,
    );
    expect(project.pages.single.textBlocks.single.textColorHex, isNull);
    expect(project.pages.single.textBlocks.single.heightFactor, isNull);
    expect(project.pages.single.textBlocks.single.textBold, isFalse);
    expect(project.pages.single.textBlocks.single.textItalic, isFalse);
    expect(project.pages.single.textBlocks.single.textUnderline, isFalse);
    expect(
      project.pages.single.textBlocks.single.textAlign,
      PresentationTextAlign.left,
    );
    final legacyModel = project.pages.single.componentBlocks.single;
    expect(legacyModel.modelAnimationEnabled, isTrue);
    expect(legacyModel.modelAutoRotate, isFalse);
    expect(legacyModel.modelOrbitEnabled, isFalse);
  });

  test('migrates a legacy background to the new topic library', () {
    final project = PresentationProjectCodec.decodeProject('''
{
  "format": "sutol-project",
  "version": 1,
  "pages": [
    {
      "id": "legacy-page",
      "backgroundKind": "chemPremiumGlassware",
      "textBlocks": [],
      "componentBlocks": []
    }
  ]
}
''');

    expect(
      project.pages.single.backgroundKind,
      PresentationBackgroundKind.chemistry,
    );
  });

  test('persists entrance animations for text and visual elements', () {
    final project = PresentationProject(
      pages: const <PresentationPage>[
        PresentationPage(
          id: 'animated-page',
          textBlocks: <PresentationTextBlock>[
            PresentationTextBlock(
              id: 'animated-text',
              text: 'Merhaba',
              position: Offset(.1, .1),
              fontSize: 42,
              type: PresentationTextType.title,
              widthFactor: .4,
              entranceAnimation: PresentationEntranceAnimation.fadeIn,
              animationTrigger: PresentationAnimationTrigger.onClick,
              animationDuration: 1.4,
              animationDelay: .3,
              animationOrder: 2,
              textGrouping: PresentationTextGrouping.byWord,
              groupDelay: .12,
              motionPathPoints: <Offset>[
                Offset.zero,
                Offset(.1, -.2),
                Offset(.2, .15),
                Offset(.4, 0),
              ],
            ),
          ],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'animated-component',
              position: Offset(.3, .3),
              size: Size(.3, .3),
              entranceAnimation: PresentationEntranceAnimation.flyInLeft,
            ),
          ],
        ),
      ],
      effectSettings: const PresentationEffectSettings(),
    );

    final restored = PresentationProjectCodec.decodeProject(
      PresentationProjectCodec.encodeProject(
        pages: project.pages,
        effectSettings: project.effectSettings,
      ),
    );

    expect(
      restored.pages.single.textBlocks.single.entranceAnimation,
      PresentationEntranceAnimation.fadeIn,
    );
    expect(
      restored.pages.single.textBlocks.single.animationTrigger,
      PresentationAnimationTrigger.onClick,
    );
    expect(restored.pages.single.textBlocks.single.animationDuration, 1.4);
    expect(restored.pages.single.textBlocks.single.animationDelay, .3);
    expect(restored.pages.single.textBlocks.single.animationOrder, 2);
    expect(
      restored.pages.single.textBlocks.single.textGrouping,
      PresentationTextGrouping.byWord,
    );
    expect(restored.pages.single.textBlocks.single.groupDelay, .12);
    expect(
      restored.pages.single.textBlocks.single.motionPathPoints,
      const <Offset>[
        Offset.zero,
        Offset(.1, -.2),
        Offset(.2, .15),
        Offset(.4, 0),
      ],
    );
    expect(
      restored.pages.single.componentBlocks.single.entranceAnimation,
      PresentationEntranceAnimation.flyInLeft,
    );
  });
}
