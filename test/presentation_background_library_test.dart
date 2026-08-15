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

  test('library exposes the 19 topic and 6 light backgrounds', () {
    expect(presentationBackgroundLibrary, hasLength(25));
    expect(
      presentationBackgroundLibrary.map((item) => item.kind).toSet(),
      hasLength(25),
    );
    expect(
      presentationBackgroundLibrary.every((item) => item.tags.isNotEmpty),
      isTrue,
    );
  });

  test('every library background embeds its offline scene source', () {
    for (final definition in presentationBackgroundLibrary) {
      final source = presentationBackgroundSceneHtml(definition.kind);
      expect(source, contains('sutol-scene'), reason: definition.label);

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
}
