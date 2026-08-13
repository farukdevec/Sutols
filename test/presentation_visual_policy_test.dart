import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/fallback_slide_generator.dart';
import 'package:sutol/services/model_matching_service.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/presentation_deck_builder.dart';
import 'package:sutol/services/presentation_project_codec.dart';

void main() {
  List<ModelCatalogEntry> loadRealModelCatalog() {
    final decoded = jsonDecode(
      File('functions/scripts/models-tagged.json').readAsStringSync(),
    ) as List<dynamic>;
    final models = decoded.map((value) {
      final json = value as Map<String, dynamic>;
      final fileName = json['fileName'] as String;
      return ModelCatalogEntry(
        id: fileName.replaceAll(RegExp(r'\.glb$', caseSensitive: false), ''),
        name: json['name'] as String,
        modelUrl: json['modelUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        tags: (json['tags'] as List<dynamic>).cast<String>(),
        category: json['category'] as String? ?? '',
        tier: json['tier'] as String? ?? 'free',
      );
    }).toList(growable: false);
    expect(models, hasLength(1037));
    expect(models.map((model) => model.id).toSet(), hasLength(1037));
    return models;
  }

  test('30 sayfalık fen sunumu gerçek katalogda görsel politikasını korur', () {
    final catalog = loadRealModelCatalog();
    final generated = FallbackSlideGenerator.generatePresentation(
      'Fen',
      slideCount: 30,
    );
    final usedModelIds = <String>{};
    final selectedBySlide = <ModelMatch?>[];
    final deckSlides = generated.slides.map((slide) {
      final matches = ModelMatchingService.rankCatalogModels(
        models: catalog,
        keywords: slide.keywords,
      );
      final selected = ModelMatchingService.bestMatchPreferUnused(
        matches,
        usedModelIds,
      );
      if (selected != null) usedModelIds.add(selected.id);
      selectedBySlide.add(selected);
      return DeckSlide(
        title: slide.title,
        content: slide.content,
        keywords: slide.keywords,
        models: selected == null ? const [] : [selected],
      );
    }).toList(growable: false);

    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Fen',
      slides: deckSlides,
    );

    expect(pages, hasLength(30));
    expect(
      pages.every((page) => page.componentBlocks.length <= 1),
      isTrue,
      reason:
          'Bir slaytta model ve bileşen birlikte veya birden fazla olmamalı.',
    );

    for (var index = 0; index < pages.length; index += 1) {
      final selected = selectedBySlide[index];
      final visuals = pages[index].componentBlocks;
      if (selected != null) {
        expect(visuals, hasLength(1));
        expect(visuals.single.modelAssetId, selected.id);
      } else if (visuals.isNotEmpty) {
        expect(visuals.single.modelAssetId, isNull);
      }
    }

    // Katalogda farklı fen alt konuları için yeterli model bulunduğunda aynı
    // genel modelin bütün sunuma kopyalanmadığını da güvenceye alır.
    final modelIds = pages
        .expand((page) => page.componentBlocks)
        .map((block) => block.modelAssetId)
        .whereType<String>()
        .toList(growable: false);
    expect(modelIds, isNotEmpty);
    expect(modelIds.toSet().length, greaterThan(10));

    // İlk oluşturulan deck buluta yazılan proje JSON'undan geri açıldığında
    // görsel kuralı ve model/bileşen ayrımı korunmalı.
    final source = PresentationProjectCodec.encodeProject(
      pages: pages,
      effectSettings: const PresentationEffectSettings(),
    );
    final restored = PresentationProjectCodec.decodeProject(source);
    expect(restored.pages, hasLength(30));
    expect(
      restored.pages.every((page) => page.componentBlocks.length <= 1),
      isTrue,
    );
    expect(
      restored.pages
          .expand((page) => page.componentBlocks)
          .where((block) => block.modelAssetId != null)
          .length,
      modelIds.length,
    );
  });

  test('model yoksa bileşen, ikisi de yoksa yalnızca metin kullanır', () {
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Fen',
      slides: <DeckSlide>[
        DeckSlide(
          title: 'Atomun Yapısı',
          content: 'Elektron ve çekirdek ilişkisi incelenir.',
          keywords: <String>['atom', 'elektron', 'çekirdek'],
          models: <ModelMatch>[],
        ),
        DeckSlide(
          title: 'Qzxv Plmn',
          content: 'Wrty klmn.',
          keywords: <String>['qzxv'],
          models: <ModelMatch>[],
        ),
      ],
    );

    expect(pages.first.componentBlocks, hasLength(1));
    expect(pages.first.componentBlocks.single.modelAssetId, isNull);
    expect(pages.last.componentBlocks, isEmpty);
  });

  test('model varsa bileşenden önce gelir ve yalnızca bir model yerleşir', () {
    final models = <ModelMatch>[
      ModelMatch(
        id: 'atom-modeli',
        name: 'Atom Modeli',
        modelUrl: 'https://example.com/atom.glb',
        thumbnailUrl: '',
        score: 8,
      ),
      ModelMatch(
        id: 'elektron-modeli',
        name: 'Elektron Modeli',
        modelUrl: 'https://example.com/electron.glb',
        thumbnailUrl: '',
        score: 6,
      ),
    ];
    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Fen',
      slides: <DeckSlide>[
        DeckSlide(
          title: 'Atomun Yapısı',
          content: 'Elektron ve çekirdek ilişkisi incelenir.',
          keywords: <String>['atom', 'elektron', 'çekirdek'],
          models: models,
        ),
      ],
    );

    expect(pages.single.componentBlocks, hasLength(1));
    expect(pages.single.componentBlocks.single.modelAssetId, 'atom-modeli');
  });
}
