import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_matching_service.dart';
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
    expect(pages.single.componentBlocks.single.modelAssetId, 'solar-system');
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
}
