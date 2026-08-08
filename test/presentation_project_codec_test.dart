import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_project_codec.dart';

void main() {
  test('round trips presentation project json', () {
    const pages = <PresentationPage>[
      PresentationPage(
        id: 'page-4',
        backgroundKind: PresentationBackgroundKind.solarEnergyScene,
        speakerNotes: 'Konusmaci notu',
        textBlocks: <PresentationTextBlock>[
          PresentationTextBlock(
            id: 'text-7',
            text: 'Gunes',
            position: Offset(0.08, 0.12),
            fontSize: 54,
            type: PresentationTextType.title,
            widthFactor: 0.46,
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
    expect(project.pages.single.textBlocks.single.textBold, isTrue);
    expect(project.pages.single.textBlocks.single.textItalic, isTrue);
    expect(project.pages.single.textBlocks.single.textUnderline, isTrue);
    expect(
      project.pages.single.textBlocks.single.textAlign,
      PresentationTextAlign.center,
    );
    expect(project.pages.single.componentBlocks, hasLength(2));
    expect(project.pages.single.componentBlocks.first.id, 'component-3');
    expect(
      project.pages.single.componentBlocks.first.kind,
      PresentationComponentKind.fizik01,
    );
    expect(project.pages.single.componentBlocks.first.size.width, 0.25);
    expect(project.pages.single.componentBlocks.first.revealStep, 2);
    final modelBlock = project.pages.single.componentBlocks.last;
    expect(modelBlock.id, 'component-4');
    expect(modelBlock.modelAssetId, 'gercekci-dunya');
    expect(modelBlock.modelAnimationEnabled, isFalse);
    expect(modelBlock.modelAutoRotate, isTrue);
    expect(modelBlock.modelOrbitEnabled, isTrue);
    expect(modelBlock.modelOrbitTheta, 45);
    expect(modelBlock.modelOrbitPhi, 60);
    expect(
      project.effectSettings.transitionKind,
      PresentationTransitionKind.zoom,
    );
    expect(project.effectSettings.zoomEnabled, isTrue);
    expect(project.effectSettings.reducedMotion, isTrue);
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
}
