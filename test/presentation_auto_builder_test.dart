import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_auto_builder.dart';

void main() {
  test('builds atom themed page from atom title', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(title: 'Atom', body: ''),
      ],
    );

    expect(pages, hasLength(1));
    expect(pages.single.backgroundKind, PresentationBackgroundKind.science);
    expect(pages.single.componentBlocks, hasLength(1));
    expect(
      presentationComponentCategory(pages.single.componentBlocks.single.kind),
      'Fizik',
    );
  });

  test('skips blank pages and builds solar photon themed page', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(title: '', body: ''),
        PresentationDraftPage(
          title: '',
          body: 'Gunesten gelen fotonlar panellerde enerjiye donusur.',
        ),
      ],
    );

    expect(pages, hasLength(1));
    expect(
      pages.single.backgroundKind,
      PresentationBackgroundKind.solarEnergyScene,
    );
    expect(pages.single.componentBlocks, isNotEmpty);
    expect(pages.single.componentBlocks, hasLength(1));
  });

  test('uses fallback background when only former component words match', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(title: 'Bilimsel Icatlar', body: ''),
      ],
    );

    expect(pages, hasLength(1));
    expect(
      pages.single.backgroundKind,
      PresentationBackgroundKind.science,
    );
    expect(pages.single.componentBlocks, isEmpty);
  });

  test('matches english solar photon words', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(
          title: 'Solar Photon Flow',
          body: 'Sunlight carries photon energy to a solar panel.',
        ),
      ],
    );

    expect(pages, hasLength(1));
    expect(
      pages.single.backgroundKind,
      PresentationBackgroundKind.solarEnergyScene,
    );
    expect(pages.single.componentBlocks, isNotEmpty);
  });

  test('matches fuzzy typo words', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(
          title: '',
          body: 'Fotn akisi ve molekul hareketi gunes enerjisini anlatir.',
        ),
      ],
    );

    expect(pages, hasLength(1));
    expect(
      pages.single.backgroundKind,
      PresentationBackgroundKind.solarEnergyScene,
    );
    expect(pages.single.componentBlocks, isNotEmpty);
  });

  test('matches english space orbit words', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(
          title: 'Space Orbit',
          body: 'A satellite follows an orbit around the planet.',
        ),
      ],
    );

    expect(pages, hasLength(1));
    expect(
      pages.single.backgroundKind,
      PresentationBackgroundKind.spaceTechnology,
    );
    expect(pages.single.componentBlocks, isNotEmpty);
  });

  test('places components from catalog tags', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(
          title: 'Seyahat Plani',
          body: 'Turizm destinasyon rotasi, pasaport ve vize adimlari.',
        ),
      ],
    );

    expect(pages, hasLength(1));
    expect(
      pages.single.componentBlocks.map(
        (block) => presentationComponentCategory(block.kind),
      ),
      contains('Turizm / Seyahat'),
    );
  });

  test('places continuation components from new tags', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(
          title: 'Kuantum Bilgisayar',
          body: 'Qubit ve superpozisyon kavramlari kenar agi ile anlatilir.',
        ),
        PresentationDraftPage(
          title: 'Pulsar',
          body:
              'Notron yildizi ve manyetosfer kozmik arka plan isimasini etkiler.',
        ),
      ],
    );

    expect(pages, hasLength(2));
    expect(
      pages.first.componentBlocks.map(
        (block) => presentationComponentCategory(block.kind),
      ),
      contains('Teknoloji / Bilgisayar'),
    );
    expect(
      pages.last.componentBlocks.map(
        (block) => presentationComponentCategory(block.kind),
      ),
      contains('Astronomi'),
    );
  });

  test('does not select backgrounds from words hidden in unrelated text', () {
    const cases = <(String, PresentationBackgroundKind)>[
      ('Sunum hakkında genel bilgiler', PresentationBackgroundKind.lawJustice),
      ('Havaalanı ulaşım planı', PresentationBackgroundKind.climateWeather),
      ('Renkli veri tabanı modeli', PresentationBackgroundKind.artDesign),
    ];

    for (final entry in cases) {
      final pages = const PresentationAutoBuilder().buildPages(
        <PresentationDraftPage>[
          PresentationDraftPage(title: entry.$1, body: ''),
        ],
      );

      expect(
        pages.single.backgroundKind,
        isNot(entry.$2),
        reason: entry.$1,
      );
    }
  });

  test('uses specific background phrases over broad neighboring topics', () {
    const cases = <String, PresentationBackgroundKind>{
      'Güneş ışığı ve fotovoltaik enerji':
          PresentationBackgroundKind.solarEnergyScene,
      'Işık fiziği, mercek ve yansıma': PresentationBackgroundKind.optics,
      'İşlemci mimarisi ve veritabanı': PresentationBackgroundKind.technology,
      'Spor takımı ve antrenman': PresentationBackgroundKind.sportsMovement,
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

  test('newly tagged history and astronomy components match their topics', () {
    const cases = <String, String>{
      'Arkeolojik kazı katmanları': 'Tarih',
      'Kara delik ve yığılma diski': 'Astronomi',
    };

    for (final entry in cases.entries) {
      final pages = const PresentationAutoBuilder().buildPages(
        <PresentationDraftPage>[
          PresentationDraftPage(title: entry.key, body: ''),
        ],
      );

      expect(
        pages.single.componentBlocks.map(
          (block) => presentationComponentCategory(block.kind),
        ),
        contains(entry.value),
        reason: entry.key,
      );
    }
  });

  test('splits long content into readable continuation slides', () {
    final body = List<String>.filled(90, 'okunabilir').join(' ');
    final pages = const PresentationAutoBuilder().buildPages(
      <PresentationDraftPage>[
        PresentationDraftPage(title: 'Uzun içerik', body: body),
      ],
    );

    expect(pages, hasLength(greaterThan(1)));
    expect(pages.first.textBlocks.last.text.length, lessThanOrEqualTo(280));
    expect(pages.last.textBlocks.first.text, contains('(devam)'));
  });

  test('uses the selected template background and minimal layout', () {
    final pages = const PresentationAutoBuilder().buildPages(
      const <PresentationDraftPage>[
        PresentationDraftPage(title: 'Özet', body: 'Kısa açıklama'),
      ],
      template: PresentationTemplate.minimal,
    );

    expect(pages.single.backgroundKind, PresentationBackgroundKind.lightWarm);
    expect(pages.single.componentBlocks, isEmpty);
    expect(pages.single.textBlocks.first.widthFactor, 0.84);
  });

  test('every template exposes a representative real slide preview', () {
    for (final template in PresentationTemplate.values.where(
      (template) => template != PresentationTemplate.automatic,
    )) {
      final preview = presentationTemplatePreviewPage(template);
      final config = templateConfig(template);

      expect(preview.id, 'template-preview-${template.name}');
      expect(preview.backgroundKind, config.backgroundKind);
      expect(preview.textBlocks, hasLength(2));
      expect(preview.textBlocks.first.textStyle, config.titleTextStyle);
      expect(preview.textBlocks.last.textStyle, config.bodyTextStyle);
      expect(
        preview.componentBlocks.map((block) => block.kind),
        config.componentKinds,
      );
      expect(identical(preview, presentationTemplatePreviewPage(template)),
          isTrue);
    }
  });
}
