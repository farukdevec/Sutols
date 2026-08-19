import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/model_matching_service.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/presentation_deck_builder.dart';

void main() {
  ModelMatch model(String id, int score) => ModelMatch(
        id: id,
        name: id,
        modelUrl: 'https://example.com/$id.glb',
        thumbnailUrl: '',
        score: score,
      );

  test('automatic deck places at most one 3D model on a slide', () {
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Uzay',
      slides: <DeckSlide>[
        DeckSlide(
          title: 'Güneş Sistemi',
          content: 'Gezegenler Güneş çevresinde döner.',
          models: <ModelMatch>[
            model('solar-system', 6),
            model('earth', 4),
            model('moon', 2),
          ],
        ),
      ],
    );

    expect(pages.single.componentBlocks, hasLength(1));
    final modelBlock = pages.single.componentBlocks.single;
    expect(modelBlock.modelAssetId, 'solar-system');
    expect(modelBlock.modelAnimationEnabled, isTrue);
    expect(modelBlock.modelAutoRotate, isTrue);
  });

  test('3D model takes priority over a matching catalog component', () {
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Atom',
      slides: <DeckSlide>[
        DeckSlide(
          title: 'Atom Modeli',
          content: 'Elektronlar çekirdeğin çevresinde bulunur.',
          models: <ModelMatch>[model('atom-3d', 5)],
        ),
      ],
    );

    final visual = pages.single.componentBlocks.single;
    expect(visual.modelAssetId, 'atom-3d');
    expect(presentationComponentCategory(visual.kind), 'Fizik');
  });

  test('model without a usable source falls back to a tagged component', () {
    final pages = PresentationDeckBuilder().buildPages(
      topic: 'Çevre',
      slides: <DeckSlide>[
        DeckSlide(
          title: 'Geri Dönüşüm',
          content: 'Atıklar döngüsel kullanımla yeniden değerlendirilir.',
          models: <ModelMatch>[
            ModelMatch(
              id: 'missing-model',
              name: 'Eksik model',
              modelUrl: '   ',
              thumbnailUrl: '',
              score: 4,
            ),
          ],
          keywords: <String>['geri dönüşüm', 'atık yönetimi'],
        ),
      ],
    );

    final visual = pages.single.componentBlocks.single;
    expect(visual.modelAssetId, isNull);
    expect(visual.kind, PresentationComponentKind.cevreDoga03);
  });

  test('matching component is used only when no 3D model exists', () {
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Atom',
      slides: const <DeckSlide>[
        DeckSlide(
          title: 'Temel Yapı',
          content: 'Konunun ana parçaları açıklanır.',
          models: <ModelMatch>[],
          keywords: <String>['atom', 'elektron', 'çekirdek'],
        ),
      ],
    );

    final visual = pages.single.componentBlocks.single;
    expect(visual.modelAssetId, isNull);
    expect(visual.position.dx, greaterThanOrEqualTo(0.68));
    expect(
      pages.single.textBlocks.every(
        (text) => text.position.dx + text.widthFactor <= visual.position.dx,
      ),
      isTrue,
    );
  });

  test('3D fallback component follows the slide topic metadata', () {
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Fen Bilimleri',
      slides: const <DeckSlide>[
        DeckSlide(
          title: 'Çevre ve Sürdürülebilirlik',
          content:
              'Doğal kaynaklar, enerji verimliliği, atık azaltma ve geri dönüşüm ekosistemleri korur.',
          models: <ModelMatch>[],
          keywords: <String>[
            'sürdürülebilirlik',
            'çevre',
            'geri dönüşüm',
            'enerji verimliliği',
          ],
        ),
      ],
    );

    final visual = pages.single.componentBlocks.single;
    expect(visual.kind, PresentationComponentKind.cevreDoga03);
  });

  test('slide stays text-only when neither model nor component matches', () {
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Qzxv',
      slides: const <DeckSlide>[
        DeckSlide(
          title: 'Qzxv Plmn',
          content: 'Wrty klmn.',
          models: <ModelMatch>[],
        ),
      ],
    );

    expect(pages.single.componentBlocks, isEmpty);
    expect(pages.single.textBlocks.every((text) => text.widthFactor == 0.84),
        isTrue);
  });

  test('model keyword matching normalizes Turkish and close word forms', () {
    final score = ModelMatchingService.keywordMatchScore(
      keywords: const <String>['GÜNEŞ', 'gezegenler'],
      tags: const <String>['güneş', 'gezegen'],
      modelName: 'Güneş Sistemi',
    );

    expect(score, greaterThanOrEqualTo(4));
    expect(
      ModelMatchingService.keywordMatchScore(
        keywords: const <String>['hukuk'],
        tags: const <String>['gezegen', 'uzay'],
        modelName: 'Dünya',
      ),
      0,
    );
  });

  test(
      'presentation category prevents animal decks from using engineering models',
      () {
    const catalog = <ModelCatalogEntry>[
      ModelCatalogEntry(
        id: 'lion',
        name: 'Aslan',
        modelUrl: 'lion.glb',
        thumbnailUrl: '',
        tags: <String>['aslan', 'vahşi hayvan', 'memeli'],
        category: 'Evcil Hayvanlar & Hayvan Dünyası',
        tier: 'free',
      ),
      ModelCatalogEntry(
        id: 'robot-arm',
        name: 'Endüstriyel Robot Kolu',
        modelUrl: 'robot.glb',
        thumbnailUrl: '',
        tags: <String>['mühendislik', 'fabrika', 'robot'],
        category: 'Mühendislik',
        tier: 'free',
      ),
    ];

    final category = ModelMatchingService.inferPresentationCategory(
      models: catalog,
      presentationTitle: 'Hayvanlar Alemi',
    );
    final matches = ModelMatchingService.rankModelsInCategory(
      models: catalog,
      category: category!,
      slideTitle: 'Aslanlar',
      slideBody: 'Vahşi memelilerin yaşamı',
    );

    expect(category, 'Evcil Hayvanlar & Hayvan Dünyası');
    expect(matches.map((match) => match.id), <String>['lion']);
  });

  test('slide title has priority over body while ranking category models', () {
    const catalog = <ModelCatalogEntry>[
      ModelCatalogEntry(
        id: 'lion',
        name: 'Aslan',
        modelUrl: 'lion.glb',
        thumbnailUrl: '',
        tags: <String>['aslan'],
        category: 'Hayvanlar',
        tier: 'free',
      ),
      ModelCatalogEntry(
        id: 'zebra',
        name: 'Zebra',
        modelUrl: 'zebra.glb',
        thumbnailUrl: '',
        tags: <String>['zebra'],
        category: 'Hayvanlar',
        tier: 'free',
      ),
    ];
    final matches = ModelMatchingService.rankModelsInCategory(
      models: catalog,
      category: 'Hayvanlar',
      slideTitle: 'Aslan',
      slideBody: 'Zebra zebra zebra',
    );

    expect(matches.first.id, 'lion');
  });

  test('main deck topic blocks a technology model on an animal slide', () {
    const catalog = <ModelCatalogEntry>[
      ModelCatalogEntry(
        id: 'lion',
        name: 'Aslan',
        modelUrl: 'lion.glb',
        thumbnailUrl: '',
        tags: <String>['aslan', 'hayvan', 'memeli'],
        category: 'Hayvanlar ve Bitkiler',
        tier: 'free',
      ),
      ModelCatalogEntry(
        id: 'mobile-app',
        name: 'Mobil Uygulama',
        modelUrl: 'phone.glb',
        thumbnailUrl: '',
        tags: <String>['mobil', 'uygulama', 'teknoloji'],
        // Simulate an incorrectly categorized remote catalog record.
        category: 'Hayvanlar ve Bitkiler',
        tier: 'free',
      ),
    ];

    final matches = ModelMatchingService.rankModelsInCategory(
      models: catalog,
      category: 'Hayvanlar ve Bitkiler',
      presentationTitle: 'Hayvanlar ve Bitkiler',
      slideTitle: 'Uygulama Adimlari: hayvanlarin bitkilere etkisi',
      slideBody: 'Hayvanlarin bitkilere etkisi degerlendirilir.',
    );

    expect(matches.map((match) => match.id), <String>['lion']);
  });

  test('compound deck topic keeps both animal and Earth model categories', () {
    const catalog = <ModelCatalogEntry>[
      ModelCatalogEntry(
        id: 'lion',
        name: 'Aslan',
        modelUrl: 'lion.glb',
        thumbnailUrl: '',
        tags: <String>['hayvan', 'memeli'],
        category: 'Hayvanlar',
        tier: 'free',
      ),
      ModelCatalogEntry(
        id: 'earth',
        name: 'Dunya',
        modelUrl: 'earth.glb',
        thumbnailUrl: '',
        tags: <String>['dunya', 'gezegen'],
        category: 'Cografya ve Uzay',
        tier: 'free',
      ),
      ModelCatalogEntry(
        id: 'phone',
        name: 'Telefon',
        modelUrl: 'phone.glb',
        thumbnailUrl: '',
        tags: <String>['mobil', 'teknoloji'],
        category: 'Teknoloji',
        tier: 'free',
      ),
    ];

    final categories = ModelMatchingService.inferPresentationCategories(
      models: catalog,
      presentationTitle: 'Hayvanlar alemi ve dunya',
    );

    expect(categories, containsAll(<String>['Hayvanlar', 'Cografya ve Uzay']));
    expect(categories, isNot(contains('Teknoloji')));
  });

  test('a used model is skipped and is never repeated in the same deck', () {
    final matches = <ModelMatch>[
      model('lion', 10),
      model('zebra', 8),
    ];

    expect(
      ModelMatchingService.bestMatchPreferUnused(matches, <String>{'lion'})?.id,
      'zebra',
    );
    expect(
      ModelMatchingService.bestMatchPreferUnused(
        matches,
        <String>{'lion', 'zebra'},
      ),
      isNull,
    );
  });

  test(
      'an unused model from the deck category fills a slide without a direct match',
      () {
    const catalog = <ModelCatalogEntry>[
      ModelCatalogEntry(
        id: 'lion',
        name: 'Aslan',
        modelUrl: 'lion.glb',
        thumbnailUrl: '',
        tags: <String>['aslan'],
        category: 'Hayvanlar',
        tier: 'free',
      ),
      ModelCatalogEntry(
        id: 'robot',
        name: 'Robot',
        modelUrl: 'robot.glb',
        thumbnailUrl: '',
        tags: <String>['robot'],
        category: 'Mühendislik',
        tier: 'free',
      ),
    ];

    final matches = ModelMatchingService.rankModelsInCategory(
      models: catalog,
      category: 'Hayvanlar',
      slideTitle: 'Ekolojik Denge',
      slideBody: 'Canlıların dünya üzerindeki etkileri',
    );

    expect(matches.map((match) => match.id), <String>['lion']);
    expect(matches.single.score, 1);
  });

  test('generated title and body boxes never overlap', () {
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Fen',
      slides: const <DeckSlide>[
        DeckSlide(
          title: 'Bilim, Teknoloji ve Geleceğin Fen Bilimleriyle Şekillenmesi',
          content:
              'Bilimsel bilgi kanıt, ölçüm ve sınanabilir açıklamalarla ilerler.',
          models: <ModelMatch>[],
        ),
      ],
    );

    final title = pages.single.textBlocks.firstWhere(
      (block) => block.type == PresentationTextType.title,
    );
    final body = pages.single.textBlocks.firstWhere(
      (block) => block.type == PresentationTextType.body,
    );

    expect(title.heightFactor, isNotNull);
    expect(title.position.dy + title.heightFactor!, lessThan(body.position.dy));
    expect(body.heightFactor, isNotNull);
    expect(body.position.dy + body.heightFactor!, lessThanOrEqualTo(0.9));
  });
}
