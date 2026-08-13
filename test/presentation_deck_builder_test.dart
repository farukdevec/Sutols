import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
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
