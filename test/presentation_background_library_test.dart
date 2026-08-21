import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_auto_builder.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/ui/widgets/html_stage/background_scene_sources.dart';
import 'package:sutol/ui/widgets/html_stage/html_page_stage.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  test('popular Google Fonts catalog exposes exactly 30 unique families', () {
    expect(popularGoogleFontFamilies.length, 30);
    expect(popularGoogleFontFamilies.values.toSet().length, 30);
    expect(popularGoogleFontFamilies.values.first, 'Roboto');
    expect(popularGoogleFontFamilies.values, contains('Open Sans'));
    expect(popularGoogleFontFamilies.values, contains('Montserrat'));
    expect(popularGoogleFontFamilies.values, contains('Poppins'));

    for (final entry in popularGoogleFontFamilies.entries) {
      final cssClass = presentationGoogleFontClass(entry.key)!;
      expect(sutolHtmlStageStyles, contains('.sutol-html-block.$cssClass'));
      expect(sutolHtmlStageStyles, contains("font-family: '${entry.value}'"));
    }

    final localAssets = RegExp(
      r"assets/assets/fonts/google_fonts/([^')]+)",
    ).allMatches(sutolHtmlStageStyles);
    expect(localAssets.length, 172);
    for (final match in localAssets) {
      expect(
        File('assets/fonts/google_fonts/${match.group(1)}').existsSync(),
        isTrue,
      );
    }
    expect(
      Directory('assets/fonts/google_fonts/licenses')
          .listSync()
          .whereType<File>()
          .length,
      45,
    );
  });

  test('HTML export includes font files only for families used by the deck',
      () {
    const page = PresentationPage(
      id: 'font-subset',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'roboto-text',
          text: 'Yalnızca Roboto',
          position: Offset.zero,
          fontSize: 32,
          widthFactor: 0.8,
          type: PresentationTextType.body,
          textStyle: PresentationTextStyle.googleRoboto,
        ),
      ],
    );

    final document = buildPresentationExportHtml(
      pages: const <PresentationPage>[page],
      compact: false,
    );

    expect(document, contains('google_fonts/roboto-400'));
    expect(document, isNot(contains('google_fonts/lora-400')));
    expect(document, isNot(contains('fonts.googleapis.com/css2')));
  });

  test('library exposes the legacy collection and 20 studio backgrounds', () {
    expect(presentationBackgroundLibrary, hasLength(49));
    expect(
      presentationBackgroundLibrary.map((item) => item.kind).toSet(),
      hasLength(49),
    );
    expect(sutolStudioBackgroundLibrary, hasLength(20));
    expect(
      presentationBackgroundLibrary.every((item) => item.tags.isNotEmpty),
      isTrue,
    );
  });

  test('a page without a selected background uses a plain white scene', () {
    const page = PresentationPage(
      id: 'blank-white',
      textBlocks: <PresentationTextBlock>[],
    );
    expect(page.backgroundKind, PresentationBackgroundKind.plainWhite);
    final scene = presentationBackgroundSceneHtml(page.backgroundKind);
    expect(scene, contains('background: #FFFFFF'));
    final document = buildHtmlStageDocument(page: page);
    expect(document, contains('bg-plain-white'));
  });

  test('every library background embeds its offline scene source', () {
    for (final definition in presentationBackgroundLibrary) {
      final source = presentationBackgroundSceneHtml(definition.kind);
      if (sutolStudioBackgroundLibrary.contains(definition)) {
        expect(source, contains('<svg'), reason: definition.label);
      } else {
        expect(source, contains('sutol-scene'), reason: definition.label);
      }

      final markup = buildHtmlStageMarkup(
        page: PresentationPage(
          id: 'test',
          backgroundKind: definition.kind,
          textBlocks: const <PresentationTextBlock>[],
        ),
      );
      expect(markup, contains('sutol-bg-scene-frame'));
      expect(markup, contains('srcdoc='));
    }
  });

  test('studio backgrounds satisfy the self-contained scene contract', () {
    for (final definition in sutolStudioBackgroundLibrary) {
      final source = presentationBackgroundSceneHtml(definition.kind);

      expect(source, contains('--bg-primary'), reason: definition.label);
      expect(source, contains('--bg-surface'), reason: definition.label);
      expect(source, contains('--bg-accent'), reason: definition.label);
      expect(source, contains('--bg-accent-soft'), reason: definition.label);
      expect(source, contains('aspect-ratio:16/9'), reason: definition.label);
      expect(source, contains('viewBox="0 0 1920 1080"'),
          reason: definition.label);
      expect(source, contains('preserveAspectRatio="xMidYMid slice"'),
          reason: definition.label);
      expect(source, contains('infinite'), reason: definition.label);
      expect(source, contains('prefers-reduced-motion'),
          reason: definition.label);
      expect(source, isNot(contains('<script src=')), reason: definition.label);
      expect(source, isNot(contains('<link rel=')), reason: definition.label);
    }
  });

  test('background thumbnails embed each real scene and freeze after render',
      () {
    for (final definition in presentationBackgroundLibrary) {
      final scene = sutolHtmlBackgroundScene(definition.kind);
      final preview = buildHtmlBackgroundPreviewDocument(definition.kind);
      final fragmentEnd = scene.length < 160 ? scene.length : 160;
      final sceneFragment = scene.substring(0, fragmentEnd);

      expect(preview, contains('data-sutol-background-preview'));
      expect(preview, contains(sceneFragment), reason: definition.label);
      expect(preview.length, greaterThan(scene.length));
      expect(preview, contains('document.getAnimations()'));
      expect(preview, contains('svg.pauseAnimations'));
    }
  });

  test('page background animation setting switches to the frozen scene', () {
    const animatedPage = PresentationPage(
      id: 'animated-background',
      textBlocks: <PresentationTextBlock>[],
      backgroundKind: PresentationBackgroundKind.studioTechnologyAi,
    );
    final animatedDocument = buildHtmlStageDocument(
      page: animatedPage,
      renderMode: HtmlStageRenderMode.preview,
    );
    final frozenDocument = buildHtmlStageDocument(
      page: animatedPage.copyWith(backgroundAnimationEnabled: false),
      renderMode: HtmlStageRenderMode.preview,
    );
    final fasterDocument = buildHtmlStageDocument(
      page: animatedPage.copyWith(backgroundAnimationSpeed: 1.5),
      renderMode: HtmlStageRenderMode.preview,
    );
    final lightVariantDocument = buildHtmlStageDocument(
      page: animatedPage.copyWith(backgroundColorsInverted: true),
      renderMode: HtmlStageRenderMode.preview,
    );

    expect(
      animatedDocument,
      isNot(contains('data-sutol-background-preview-freeze')),
    );
    expect(frozenDocument, contains('data-sutol-background-preview-freeze'));
    expect(
      fasterDocument,
      contains('data-sutol-background-animation-speed=&quot;1.50&quot;'),
    );
    expect(
      lightVariantDocument,
      contains('data-sutol-background-color-variant=&quot;inverted&quot;'),
    );
    expect(
      presentationBackgroundVariantIsDark(
        PresentationBackgroundKind.studioTechnologyAi,
        colorsInverted: true,
      ),
      isFalse,
    );
    expect(
      presentationBackgroundVariantIsDark(
        PresentationBackgroundKind.studioEducationAcademia,
        colorsInverted: true,
      ),
      isTrue,
    );
  });

  testWidgets('background thumbnail forwards taps to selection callback',
      (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 180,
          child: HtmlBackgroundPreview(
            kind: PresentationBackgroundKind.science,
            onTap: () => tapCount += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(HtmlBackgroundPreview));
    expect(tapCount, 1);
  });

  test('light backgrounds are categorized, animated and marked as light', () {
    const lightKinds = <PresentationBackgroundKind>{
      PresentationBackgroundKind.lightCorporate,
      PresentationBackgroundKind.lightEducation,
      PresentationBackgroundKind.lightNature,
      PresentationBackgroundKind.lightTechnology,
      PresentationBackgroundKind.lightCreative,
      PresentationBackgroundKind.lightWarm,
    };

    for (final kind in lightKinds) {
      final definition = presentationBackgroundDefinition(kind)!;
      final source = presentationBackgroundSceneHtml(kind);

      expect(presentationBackgroundIsDark(kind), isFalse);
      expect(definition.category, startsWith('Açık ·'));
      expect(definition.tags, isNotEmpty);
      expect(source, contains('sutol-light-scene'));
      expect(source, contains('@keyframes'));
      expect(source, contains('prefers-reduced-motion:reduce'));
    }
  });

  test('science text styles are emitted with their web fonts', () {
    const page = PresentationPage(
      id: 'science-style',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'title',
          text: 'Mikro Evren',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.bilimDeneysel,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-bilim-deneysel'));
    expect(document, contains("font-family: 'Michroma', monospace"));
    expect(document, contains('fonts.googleapis.com'));
    expect(document, contains('@keyframes glitchGlowBilimDeneysel'));
    expect(document, contains('prefers-reduced-motion: reduce'));
  });

  test('solar energy text styles are emitted with their web fonts', () {
    const page = PresentationPage(
      id: 'solar-style',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'title',
          text: 'Güneş Enerjisi',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.gunesDramatik,
        ),
        PresentationTextBlock(
          id: 'body',
          text: 'Temiz enerji',
          position: Offset(0.1, 0.3),
          fontSize: 34,
          type: PresentationTextType.body,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.gunesDeneysel,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-gunes-dramatik'));
    expect(document, contains('text-style-gunes-deneysel'));
    expect(document, contains("font-family: 'Cinzel', serif"));
    expect(document, contains("font-family: 'Cormorant Garamond', serif"));
    expect(document, contains("font-family: 'Righteous', sans-serif"));
    expect(document, contains('@keyframes sunGlowDramatic'));
    expect(document, contains('@keyframes sunFlareFlicker'));
  });

  test('space technology text styles are emitted with cosmic effects', () {
    const page = PresentationPage(
      id: 'space-style',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'title',
          text: 'Uzay Teknolojileri',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.uzayDeneysel,
        ),
        PresentationTextBlock(
          id: 'body',
          text: 'Yörünge sistemleri',
          position: Offset(0.1, 0.3),
          fontSize: 34,
          type: PresentationTextType.body,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.uzayDramatik,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-uzay-dramatik'));
    expect(document, contains('text-style-uzay-deneysel'));
    expect(document, contains('@keyframes cosmicDeepGlow'));
    expect(document, contains('@keyframes orbitPulseClean'));
    expect(document, contains('@keyframes orbitDrift'));
    expect(document, contains('family=Orbitron:wght@500;700;900'));
  });

  test('optics text styles include mirror and prism effects', () {
    const page = PresentationPage(
      id: 'optics-style',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'title',
          text: 'Optik',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.optikDeneysel,
        ),
        PresentationTextBlock(
          id: 'body',
          text: 'Işığın kırılması',
          position: Offset(0.1, 0.3),
          fontSize: 34,
          type: PresentationTextType.body,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.optikDramatik,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-optik-dramatik'));
    expect(document, contains('text-style-optik-deneysel'));
    expect(document, contains("font-family: 'Marcellus', serif"));
    expect(document, contains("font-family: 'Syne', sans-serif"));
    expect(document, contains('@keyframes mirrorGlowOptikDramatik'));
    expect(document, contains('@keyframes softShineOptikTemiz'));
    expect(document, contains('@keyframes prismShiftOptikDeneysel'));
    expect(document, contains('-webkit-background-clip: text'));
  });

  test('physics lab text styles include flicker and pulse effects', () {
    const page = PresentationPage(
      id: 'physics-style',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'title',
          text: 'Fizik Laboratuvarı',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.fizikDramatik,
        ),
        PresentationTextBlock(
          id: 'body',
          text: 'Deney sonuçları',
          position: Offset(0.1, 0.3),
          fontSize: 34,
          type: PresentationTextType.body,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.fizikDeneysel,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-fizik-dramatik'));
    expect(document, contains('text-style-fizik-deneysel'));
    expect(document, contains("font-family: 'Exo 2', sans-serif"));
    expect(document, contains("font-family: 'IBM Plex Mono', monospace"));
    expect(document, contains('@keyframes flickerFizikDramatik'));
    expect(document, contains('@keyframes pulseFizikTemiz'));
    expect(document, contains('@keyframes pulseFizikDeneysel'));
  });

  test('technology text styles include matrix and data effects', () {
    const page = PresentationPage(
      id: 'technology-style',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'title',
          text: 'Teknoloji',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.teknolojiDramatik,
        ),
        PresentationTextBlock(
          id: 'body',
          text: 'Veri sistemleri',
          position: Offset(0.1, 0.3),
          fontSize: 34,
          type: PresentationTextType.body,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.teknolojiDeneysel,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-teknoloji-dramatik'));
    expect(document, contains('text-style-teknoloji-deneysel'));
    expect(document, contains("font-family: 'JetBrains Mono', monospace"));
    expect(document, contains("font-family: 'Share Tech Mono', monospace"));
    expect(document, contains('@keyframes matrixDeepGlow'));
    expect(document, contains('@keyframes circuitPulseClean'));
    expect(document, contains('@keyframes dataGlitchFlicker'));
  });

  test('font typography and optional effects are emitted independently', () {
    const page = PresentationPage(
      id: 'independent-effects',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'title',
          text: 'Bağımsız Efekt',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.bilimDramatik,
          textAnimation: PresentationTextAnimation.teknolojiDeneysel,
          textColorHex: '#F87171',
          glowIntensity: 1.7,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-bilim-dramatik'));
    expect(document, contains('text-animation-teknoloji-deneysel'));
    expect(document, contains('color:#F87171'));
    expect(document, contains('--sutol-glow:1.70'));
    expect(document, contains('Font presets above define typography only'));
    expect(document, contains('@keyframes sutolEffectFlicker'));
    expect(document, contains('@keyframes sutolEffectSolarFlare'));
    expect(document, contains('@keyframes sutolEffectCosmicBloom'));
    expect(document, contains('@keyframes sutolEffectElectricFlicker'));
    expect(document, contains('@keyframes sutolEffectDataGlitch'));
    expect(document, contains('will-change: transform, opacity'));
  });

  test('inline editing hides only the duplicated HTML text layer', () {
    const page = PresentationPage(
      id: 'inline-editing',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'editing-text',
          text: 'Düzenlenen metin',
          position: Offset(0.1, 0.1),
          fontSize: 48,
          type: PresentationTextType.title,
          widthFactor: 0.6,
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      selectedTextBlockId: 'editing-text',
      inlineEditingTextBlockId: 'editing-text',
    );

    expect(document, contains('is-selected is-inline-editing'));
    expect(document, contains('.sutol-html-block.is-inline-editing {'));
    expect(document, contains('opacity: 0 !important;'));
  });

  test('popular reveal and display animations are available independently', () {
    const page = PresentationPage(
      id: 'display-animations',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'metallic-title',
          text: 'Metalik Başlık',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.6,
          textStyle: PresentationTextStyle.fizikDramatik,
          textAnimation: PresentationTextAnimation.metalikParlama,
          textColorHex: '#CBD5E1',
        ),
        PresentationTextBlock(
          id: 'reveal-body',
          text: 'Yavaşça görünür',
          position: Offset(0.1, 0.3),
          fontSize: 34,
          type: PresentationTextType.body,
          widthFactor: 0.6,
          textAnimation: PresentationTextAnimation.yavasBelirme,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-animation-metalik-parlama'));
    expect(document, contains('text-animation-yavas-belirme'));
    expect(document, contains('@keyframes sutolEffectMetallicShine'));
    expect(document, contains('@keyframes sutolEffectSlowReveal'));
    expect(document, contains('@keyframes sutolEffectTypewriter'));
    expect(document, contains('@keyframes sutolEffectBlurFocus'));
    expect(document, contains('@keyframes sutolEffectFlip3d'));
    expect(document, contains('@keyframes sutolEffectBounceIn'));
    expect(document, contains('@keyframes sutolEffectSpotlightSweep'));
    expect(
      document,
      contains(
        '.sutol-html-block.text-animation-metalik-parlama {\n  background-image: linear-gradient(',
      ),
    );
    expect(
      document,
      contains(
        '.sutol-html-block.text-animation-isik-taramasi {\n  background-image: linear-gradient(',
      ),
    );
  });

  test('text animations run once and remain visible after revealing', () {
    const page = PresentationPage(
      id: 'one-shot-text-animation',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'animated-text',
          text: 'Kalıcı metin',
          position: Offset(0.1, 0.1),
          fontSize: 48,
          type: PresentationTextType.title,
          widthFactor: 0.7,
          textAnimation: PresentationTextAnimation.yavasBelirme,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);
    final effectsStart = document.indexOf(
      '.sutol-html-block[class*="text-animation-"]',
    );
    final effectsEnd = document.indexOf(
      '.sutol-html-block.is-glow-off',
      effectsStart,
    );
    final effectsCss = document.substring(effectsStart, effectsEnd);

    expect(effectsCss, isNot(contains('infinite')));
    expect(effectsCss, contains('1 forwards !important'));
    expect(effectsCss, contains('ease-in-out 1 both'));
    expect(
      effectsCss,
      contains('.sutol-html-block.is-text-animation-complete {'),
    );
    expect(effectsCss, contains('animation-delay: -9999s !important'));
    expect(effectsCss, contains('animation-play-state: paused !important'));
    expect(
      effectsCss,
      isNot(
        contains(
          '.sutol-html-block.is-text-animation-complete {\n  animation: none',
        ),
      ),
    );
    expect(effectsCss, isNot(contains('opacity: 0.38')));
    expect(effectsCss, isNot(contains('opacity: 0.3;')));
    expect(effectsCss, isNot(contains('opacity: 0.28')));
    expect(effectsCss, isNot(contains('opacity: 0.58')));
    expect(effectsCss, isNot(contains('opacity: 0.62')));
    expect(
      effectsCss,
      contains(
        '100% { clip-path: inset(0 0 0 0); transform: translateY(0); filter: blur(0); opacity: 1;',
      ),
    );
  });

  test('previously revealed text does not animate again on the next step', () {
    const page = PresentationPage(
      id: 'reveal-animation-once',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'first-text',
          text: 'İlk metin',
          position: Offset(0.1, 0.1),
          fontSize: 48,
          type: PresentationTextType.title,
          widthFactor: 0.7,
          textAnimation: PresentationTextAnimation.yavasBelirme,
        ),
        PresentationTextBlock(
          id: 'second-text',
          text: 'İkinci metin',
          position: Offset(0.1, 0.3),
          fontSize: 40,
          type: PresentationTextType.body,
          widthFactor: 0.7,
          revealStep: 1,
          textAnimation: PresentationTextAnimation.bulaniktanNet,
        ),
      ],
    );

    final document = buildHtmlStageDocument(
      page: page,
      visibleRevealStep: 1,
    );

    expect(
      document,
      contains(
        'text-animation-yavas-belirme is-text-animation-complete',
      ),
    );
    expect(
      document,
      isNot(
        contains(
          'text-animation-bulaniktan-net is-text-animation-complete',
        ),
      ),
    );
  });

  test('distinct OFL typography families are available without effects', () {
    const styles = <PresentationTextStyle>[
      PresentationTextStyle.openOswald,
      PresentationTextStyle.openPlayfairDisplay,
      PresentationTextStyle.openBebasNeue,
      PresentationTextStyle.openBungee,
      PresentationTextStyle.openCaveat,
      PresentationTextStyle.openUnbounded,
    ];
    final page = PresentationPage(
      id: 'open-fonts',
      textBlocks: List<PresentationTextBlock>.generate(
        styles.length,
        (index) => PresentationTextBlock(
          id: 'font-$index',
          text: 'Çığ ŞÖĞÜİ $index',
          position: Offset(0.05, 0.08 + (index * 0.1)),
          fontSize: 36,
          type: PresentationTextType.title,
          widthFactor: 0.7,
          textStyle: styles[index],
        ),
      ),
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-style-open-oswald'));
    expect(document, contains('text-style-open-playfair-display'));
    expect(document, contains('text-style-open-bebas-neue'));
    expect(document, contains('text-style-open-bungee'));
    expect(document, contains('text-style-open-caveat'));
    expect(document, contains('text-style-open-unbounded'));
    expect(document, contains("font-family: 'Oswald', sans-serif"));
    expect(document, contains("font-family: 'Playfair Display', serif"));
    expect(document, contains("font-family: 'Bungee', sans-serif"));
    expect(document, contains('License: SIL Open Font License 1.1'));
    expect(document, contains('family=Bebas+Neue'));
    expect(document, contains('family=Unbounded:wght@400;700'));
  });

  test('expanded animation library includes cinematic display effects', () {
    const page = PresentationPage(
      id: 'expanded-animations',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'holographic',
          text: 'Holografik Başlık',
          position: Offset(0.1, 0.1),
          fontSize: 54,
          type: PresentationTextType.title,
          widthFactor: 0.7,
          textAnimation: PresentationTextAnimation.holografikDalga,
          textColorHex: '#67E8F9',
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(document, contains('text-animation-holografik-dalga'));
    expect(document, contains('@keyframes sutolEffectCurtainReveal'));
    expect(document, contains('@keyframes sutolEffectCinematicZoom'));
    expect(document, contains('@keyframes sutolEffectZeroGravity'));
    expect(document, contains('@keyframes sutolEffectNeonOutline'));
    expect(document, contains('@keyframes sutolEffectLongShadow'));
    expect(document, contains('@keyframes sutolEffectLiquidWave'));
    expect(document, contains('@keyframes sutolEffectSignalCut'));
    expect(document, contains('@keyframes sutolEffectHolographicWave'));
  });

  test('typewriter animation reveals words in writing order', () {
    const page = PresentationPage(
      id: 'typewriter-words',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'typewriter',
          text: 'İlk kelime sonra gelir',
          position: Offset(0.1, 0.1),
          fontSize: 48,
          type: PresentationTextType.title,
          widthFactor: 0.7,
          textAnimation: PresentationTextAnimation.daktilo,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);

    expect(
      document,
      contains(
        '<span class="sutol-typewriter-word" style="--sutol-word-index:0">İlk</span> '
        '<span class="sutol-typewriter-word" style="--sutol-word-index:1">kelime</span> '
        '<span class="sutol-typewriter-word" style="--sutol-word-index:2">sonra</span> '
        '<span class="sutol-typewriter-word" style="--sutol-word-index:3">gelir</span>',
      ),
    );
    expect(document, contains('@keyframes sutolEffectTypewriterWord'));
    expect(document, contains('animation-delay: calc(var(--sutol-word-index)'));
    expect(document, contains("word.className = 'sutol-typewriter-word'"));
  });

  test('click entrance animations become presentation reveal steps', () {
    const page = PresentationPage(
      id: 'timed-entrance',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'click-text',
          text: 'Tıklayınca göster',
          position: Offset(.1, .1),
          fontSize: 42,
          type: PresentationTextType.title,
          widthFactor: .6,
          entranceAnimation: PresentationEntranceAnimation.fadeIn,
          animationTrigger: PresentationAnimationTrigger.onClick,
          animationDuration: 1.2,
          animationDelay: .4,
        ),
      ],
    );

    final initial = buildHtmlStageDocument(page: page, visibleRevealStep: 0);
    final revealed = buildHtmlStageDocument(page: page, visibleRevealStep: 1);

    expect(initial, isNot(contains('data-sutol-text-id="click-text"')));
    expect(revealed, contains('data-reveal-step="1"'));
    expect(revealed, contains('--sutol-element-duration:1.20s'));
    expect(revealed, contains('--sutol-element-delay:0.40s'));
  });

  test('animation order controls click reveal sequence', () {
    const page = PresentationPage(
      id: 'ordered-entrance',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'second-animation',
          text: 'İkinci',
          position: Offset(.1, .1),
          fontSize: 40,
          type: PresentationTextType.body,
          widthFactor: .4,
          entranceAnimation: PresentationEntranceAnimation.fadeIn,
          animationTrigger: PresentationAnimationTrigger.onClick,
          animationOrder: 2,
        ),
        PresentationTextBlock(
          id: 'first-animation',
          text: 'Birinci',
          position: Offset(.1, .3),
          fontSize: 40,
          type: PresentationTextType.body,
          widthFactor: .4,
          entranceAnimation: PresentationEntranceAnimation.zoomIn,
          animationTrigger: PresentationAnimationTrigger.onClick,
          animationOrder: 1,
        ),
      ],
    );

    final document = buildHtmlStageDocument(page: page);
    expect(
      document,
      contains('data-sutol-text-id="first-animation" data-reveal-step="1"'),
    );
    expect(
      document,
      contains('data-sutol-text-id="second-animation" data-reveal-step="2"'),
    );
  });

  test('emphasis and exit effects stay visible until their click step', () {
    const page = PresentationPage(
      id: 'emphasis-exit',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'pulse-text',
          text: 'Vurgu',
          position: Offset(.1, .1),
          fontSize: 40,
          type: PresentationTextType.body,
          widthFactor: .4,
          entranceAnimation: PresentationEntranceAnimation.pulse,
          animationTrigger: PresentationAnimationTrigger.onClick,
          animationOrder: 1,
        ),
        PresentationTextBlock(
          id: 'exit-text',
          text: 'Çıkış',
          position: Offset(.1, .3),
          fontSize: 40,
          type: PresentationTextType.body,
          widthFactor: .4,
          entranceAnimation: PresentationEntranceAnimation.fadeOut,
          animationTrigger: PresentationAnimationTrigger.onClick,
          animationOrder: 2,
        ),
      ],
    );

    final beforeClick = buildHtmlStageMarkup(
      page: page,
      visibleRevealStep: 0,
      renderMode: HtmlStageRenderMode.preview,
    );
    final afterFirstClick = buildHtmlStageMarkup(
      page: page,
      visibleRevealStep: 1,
      renderMode: HtmlStageRenderMode.preview,
    );

    expect(beforeClick, contains('data-sutol-text-id="pulse-text"'));
    expect(beforeClick,
        contains('entrance-animation-pulse is-element-animation-pending'));
    expect(beforeClick,
        contains('entrance-animation-fade-out is-element-animation-pending'));
    expect(
      afterFirstClick,
      isNot(contains('entrance-animation-pulse is-element-animation-pending')),
    );
    expect(afterFirstClick, contains('data-animation-step="1"'));
  });

  test('exit effects restore the element after the animation finishes', () {
    expect(
      sutolHtmlStageStyles,
      contains('animation: sutolExitFadeOut .8s ease-in 1 none !important'),
    );
    expect(
      sutolHtmlStageStyles,
      contains('animation: sutolExitShrinkOut .8s ease-in 1 none !important'),
    );
    expect(
      sutolHtmlStageStyles,
      contains('animation: sutolExitSpinOut .9s ease-in 1 none !important'),
    );
  });

  test('grouped Turkish text keeps accessible label and staggered spans', () {
    const page = PresentationPage(
      id: 'grouped-text',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'letters',
          text: 'İş güç',
          position: Offset(.1, .1),
          fontSize: 40,
          type: PresentationTextType.body,
          widthFactor: .5,
          entranceAnimation: PresentationEntranceAnimation.fadeIn,
          textGrouping: PresentationTextGrouping.byLetter,
          animationDelay: .2,
          groupDelay: .1,
        ),
      ],
    );

    final markup = buildHtmlStageMarkup(page: page);

    expect(markup, contains('aria-label="İş güç"'));
    expect(
        markup, contains('class="sutol-animation-visual" aria-hidden="true"'));
    expect(
        markup,
        contains(
            'aria-hidden="true" style="--sutol-element-delay:0.20s">İ</span>'));
    expect(markup, contains('--sutol-element-delay:0.30s">ş</span>'));
    expect(markup, contains('--sutol-element-delay:0.70s">ç</span>'));
  });

  test('custom motion path emits editable transform points', () {
    const page = PresentationPage(
      id: 'motion-path',
      textBlocks: <PresentationTextBlock>[
        PresentationTextBlock(
          id: 'moving-text',
          text: 'Hareket',
          position: Offset(.1, .1),
          fontSize: 40,
          type: PresentationTextType.title,
          widthFactor: .4,
          entranceAnimation: PresentationEntranceAnimation.motionCustom,
          motionPathPoints: <Offset>[
            Offset.zero,
            Offset(.1, -.2),
            Offset(.2, .15),
            Offset(.4, 0),
          ],
        ),
      ],
    );

    final markup = buildHtmlStageMarkup(page: page);

    expect(markup, contains('entrance-animation-motion-custom'));
    expect(markup, contains('--sutol-motion-x1:10.00cqw'));
    expect(markup, contains('--sutol-motion-y1:-20.00cqh'));
    expect(sutolHtmlStageStyles, contains('@keyframes sutolMotionCustom'));
    expect(
      sutolHtmlStageStyles,
      contains(
          'animation: sutolMotionCustom 1.8s ease-in-out 1 none !important'),
    );
    expect(
      sutolHtmlStageStyles,
      contains('animation-iteration-count: 1 !important'),
    );
  });

  test('topic tags select their corresponding imported backgrounds', () {
    const cases = <String, PresentationBackgroundKind>{
      'bilimsel araştırma': PresentationBackgroundKind.science,
      'hücre ve genetik': PresentationBackgroundKind.biology,
      'orman ekolojisi': PresentationBackgroundKind.natureEcology,
      'mekanik kuvvet': PresentationBackgroundKind.physics,
      'fotovoltaik panel': PresentationBackgroundKind.solarEnergyScene,
      'anayasa ve mahkeme': PresentationBackgroundKind.lawJustice,
      'meteoroloji ve yağış': PresentationBackgroundKind.climateWeather,
      'yatırım ve bütçe': PresentationBackgroundKind.businessFinance,
      'kimyasal reaksiyon': PresentationBackgroundKind.chemistry,
      'geometri ve denklem': PresentationBackgroundKind.mathematics,
      'ritim ve melodi': PresentationBackgroundKind.musicSound,
      'mercek ve yansıma': PresentationBackgroundKind.optics,
      'doktor ve tedavi': PresentationBackgroundKind.healthMedicine,
      'grafik tasarım': PresentationBackgroundKind.artDesign,
      'turizm rotası': PresentationBackgroundKind.travelGeography,
      'fitness antrenmanı': PresentationBackgroundKind.sportsMovement,
      'antik arkeoloji': PresentationBackgroundKind.historyArchaeology,
      'yapay zeka yazılımı': PresentationBackgroundKind.technology,
      'roket ve uydu': PresentationBackgroundKind.spaceTechnology,
      'açık kurumsal': PresentationBackgroundKind.lightCorporate,
      'açık eğitim': PresentationBackgroundKind.lightEducation,
      'açık doğa': PresentationBackgroundKind.lightNature,
      'açık teknoloji': PresentationBackgroundKind.lightTechnology,
      'açık yaratıcı': PresentationBackgroundKind.lightCreative,
      'açık sıcak': PresentationBackgroundKind.lightWarm,
    };

    for (final entry in cases.entries) {
      final pages = const PresentationAutoBuilder().buildPages(
        <PresentationDraftPage>[
          PresentationDraftPage(title: entry.key, body: ''),
        ],
      );
      expect(pages.single.backgroundKind, entry.value, reason: entry.key);
    }
  });

  test('background tags avoid broad words that cause unrelated matches', () {
    const ambiguousTags = <String>{
      'hava',
      'hak',
      'hareket',
      'iş',
      'ışık',
      'panel',
      'renk',
      'ses',
      'şehir',
      'takım',
      'veri',
    };

    for (final background in presentationBackgroundLibrary) {
      expect(
        background.tags.toSet().intersection(ambiguousTags),
        isEmpty,
        reason: background.label,
      );
    }
  });

  test('every imported component has at least one search tag', () {
    expect(
      presentationComponentDefinitions.where(
        (definition) => definition.tags.isEmpty,
      ),
      isEmpty,
    );
  });

  test('scripted catalog components resolve their local artwork wrapper', () {
    const page = PresentationPage(
      id: 'scripted-components',
      textBlocks: <PresentationTextBlock>[],
      componentBlocks: <PresentationComponentBlock>[
        PresentationComponentBlock(
          id: 'canvas-component',
          kind: PresentationComponentKind.edebiyat27,
          position: Offset.zero,
          size: Size(.25, .25),
        ),
        PresentationComponentBlock(
          id: 'svg-component',
          kind: PresentationComponentKind.genelSunumIs32,
          position: Offset(.3, 0),
          size: Size(.25, .25),
        ),
      ],
    );

    final markup = buildHtmlStageMarkup(page: page);

    expect(
        markup, isNot(contains("currentScript.closest('.sutol-edeb27-wrap')")));
    expect(markup, isNot(contains('currentScript.previousElementSibling')));
    expect(
      markup,
      contains(
        "currentScript.parentElement.querySelector('.sutol-edeb27-wrap')",
      ),
    );
    expect(
      markup,
      contains("querySelector(':scope > :not(style):not(script)')"),
    );
  });

  test('repeated backgrounds are embedded only once in HTML export', () {
    final pages = List<PresentationPage>.generate(
      12,
      (index) => PresentationPage(
        id: 'page-$index',
        textBlocks: const <PresentationTextBlock>[],
        backgroundKind: PresentationBackgroundKind.science,
      ),
    );
    final singlePageDocument = buildPresentationExportHtml(
      pages: pages.take(1).toList(growable: false),
    );
    final repeatedDocument = buildPresentationExportHtml(pages: pages);

    expect(
      RegExp('data-sutol-background-kind="science"')
          .allMatches(repeatedDocument),
      hasLength(12),
    );
    expect(
      RegExp('"science":').allMatches(repeatedDocument),
      hasLength(1),
    );
    expect(repeatedDocument.length, lessThan(singlePageDocument.length * 2));
  });

  test('component category index contains the complete catalog', () {
    final indexedCount = presentationComponentCategories().fold<int>(
      0,
      (count, category) =>
          count + presentationComponentDefinitionsForCategory(category).length,
    );

    expect(indexedCount, presentationComponentDefinitions.length);
  });

  test('template themes cannot add cards behind real components', () {
    final templateRule = sutolHtmlStageStyles.indexOf(
      '.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-html-component',
    );
    final transparentOverride = sutolHtmlStageStyles.indexOf(
      '/* Template themes may style generic component placeholders as cards.',
    );

    expect(templateRule, greaterThanOrEqualTo(0));
    expect(transparentOverride, greaterThan(templateRule));
    expect(
      sutolHtmlStageStyles.substring(transparentOverride),
      contains('background: transparent !important'),
    );
    expect(
      sutolHtmlStageStyles.substring(transparentOverride),
      contains('border: none !important'),
    );
  });

  test('HTML export uses a frameless fullscreen stage with bottom navigation',
      () {
    final document = buildPresentationExportHtml(
      pages: const <PresentationPage>[
        PresentationPage(
          id: 'fullscreen-1',
          textBlocks: <PresentationTextBlock>[],
        ),
        PresentationPage(
          id: 'fullscreen-2',
          textBlocks: <PresentationTextBlock>[],
        ),
      ],
    );

    expect(document, isNot(contains('sutol-export-topbar')));
    expect(document, isNot(contains('sutol-export-counter')));
    expect(document, contains('.sutol-export-shell {'));
    expect(document, contains('width: 100vw'));
    expect(document, contains('height: 100vh'));
    expect(document, contains('id="sutolPrevBtn"'));
    expect(document, contains('id="sutolNextBtn"'));
    expect(
      RegExp('class="sutol-export-dot(?: is-active)?"').allMatches(document),
      hasLength(2),
    );
  });

  test('PDF print export renders every slide as a static landscape page', () {
    final document = buildPresentationExportHtml(
      pages: const <PresentationPage>[
        PresentationPage(
          id: 'print-1',
          textBlocks: <PresentationTextBlock>[],
        ),
        PresentationPage(
          id: 'print-2',
          textBlocks: <PresentationTextBlock>[],
        ),
      ],
      printMode: true,
    );

    expect(
      document,
      matches(RegExp('class="sutol-export-shell [^"]*print-mode"')),
    );
    expect(document, contains('size: 13.333in 7.5in'));
    expect(document, contains('width: 13.333in'));
    expect(document, contains('height: 7.5in'));
    expect(document, contains('page-break-after: always'));
    expect(document, contains('print-color-adjust: exact'));
    expect(document, contains('data-sutol-print-static'));
    expect(document, contains("model.removeAttribute('autoplay')"));
    expect(
      RegExp('data-sutol-render-mode="snapshot"').allMatches(document),
      hasLength(2),
    );
    expect(
      RegExp('class="sutol-export-slide(?: is-active)?"').allMatches(document),
      hasLength(2),
    );
  });

  test('transition document embeds both stages and real CSS keyframes', () {
    const from = PresentationPage(
      id: 'transition-from',
      textBlocks: <PresentationTextBlock>[],
    );
    const to = PresentationPage(
      id: 'transition-to',
      textBlocks: <PresentationTextBlock>[],
    );
    const expectedAnimations = <PresentationTransitionKind, String>{
      PresentationTransitionKind.fade: 'sutolInFade',
      PresentationTransitionKind.slide: 'sutolInPush',
      PresentationTransitionKind.wipe: 'sutolInWipe',
      PresentationTransitionKind.split: 'sutolInSplit',
      PresentationTransitionKind.reveal: 'sutolInReveal',
      PresentationTransitionKind.cube3d: 'sutolInCube',
    };

    for (final entry in expectedAnimations.entries) {
      final document = buildHtmlPageTransitionDocument(
        from: from,
        to: to,
        kind: entry.key,
        durationMs: 725,
      );
      expect(
        RegExp('class="sutol-transition-frame').allMatches(document),
        hasLength(2),
      );
      expect(document, contains('animation-duration:725ms'));
      expect(document, contains('animation-name:${entry.value}'));
      expect(document, contains('@keyframes ${entry.value}'));
    }
  });
}
