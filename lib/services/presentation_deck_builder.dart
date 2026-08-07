import 'package:flutter/widgets.dart';

import '../models/slide_model.dart';
import '../state/presentation_controller.dart';
import 'model_matching_service.dart';
import 'presentation_keyword_catalog.dart';
import 'remote_model_sources.dart';

/// Gemini + model eşleştirme çıktısından gerçek bir sunum destesi (deck)
/// üretir. Metin blokları sola, 3B modeller sağa yerleştirilir.
class PresentationDeckBuilder {
  const PresentationDeckBuilder();

  List<PresentationPage> buildPages({
    required String topic,
    required List<DeckSlide> slides,
  }) {
    final sources = <String, String>{};
    for (final slide in slides) {
      for (final model in slide.models) {
        sources[model.id] = model.modelUrl;
      }
    }
    RemoteModelSources.registerAll(sources);

    var pageCounter = 1;
    var textCounter = 1;
    var componentCounter = 1;
    final pages = <PresentationPage>[];

    for (final slide in slides) {
      final title = slide.title.trim();
      final content = slide.content.trim();
      if (title.isEmpty && content.isEmpty) {
        continue;
      }

      final models = slide.models.take(4).toList(growable: false);
      final background = _bestBackground(topic: topic, title: title, content: content);

      final textBlocks = <PresentationTextBlock>[];
      if (title.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: title,
            position: const Offset(0.07, 0.1),
            fontSize: 52,
            type: PresentationTextType.title,
            textStyle: PresentationTextStyle.bilimTemiz,
            textAnimation: PresentationTextAnimation.yavasBelirme,
            widthFactor: models.isEmpty ? 0.84 : 0.58,
          ),
        );
      }
      if (content.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: content,
            position: title.isEmpty ? const Offset(0.07, 0.22) : const Offset(0.07, 0.34),
            fontSize: 26,
            type: PresentationTextType.body,
            textStyle: PresentationTextStyle.bilimTemiz,
            textAnimation: PresentationTextAnimation.bulaniktanNet,
            widthFactor: models.isEmpty ? 0.84 : 0.5,
          ),
        );
      }

      final componentBlocks = <PresentationComponentBlock>[];
      if (models.isNotEmpty) {
        final placements = _modelPlacements(models.length);
        for (var i = 0; i < models.length; i += 1) {
          componentBlocks.add(
            PresentationComponentBlock(
              id: 'component-${componentCounter++}',
              modelAssetId: models[i].id,
              modelAnimationEnabled: false,
              modelOrbitTheta: 15,
              modelOrbitPhi: 70,
              position: placements[i].$1,
              size: placements[i].$2,
            ),
          );
        }
      }

      pages.add(
        PresentationPage(
          id: 'page-${pageCounter++}',
          backgroundKind: background,
          textBlocks: textBlocks,
          componentBlocks: componentBlocks,
        ),
      );
    }

    return pages;
  }

  static List<(Offset, Size)> _modelPlacements(int count) {
    switch (count) {
      case 1:
        return const [
          (Offset(0.6, 0.24), Size(0.36, 0.6)),
        ];
      case 2:
        return const [
          (Offset(0.6, 0.14), Size(0.36, 0.32)),
          (Offset(0.6, 0.52), Size(0.36, 0.32)),
        ];
      case 3:
        return const [
          (Offset(0.6, 0.1), Size(0.36, 0.22)),
          (Offset(0.6, 0.4), Size(0.36, 0.22)),
          (Offset(0.6, 0.7), Size(0.36, 0.22)),
        ];
      default:
        return const [
          (Offset(0.58, 0.1), Size(0.2, 0.26)),
          (Offset(0.8, 0.1), Size(0.18, 0.26)),
          (Offset(0.58, 0.42), Size(0.2, 0.26)),
          (Offset(0.8, 0.42), Size(0.18, 0.26)),
        ];
    }
  }

  static PresentationBackgroundKind _bestBackground({
    required String topic,
    required String title,
    required String content,
  }) {
    final normalized =
        PresentationKeywordCatalog.normalize('$topic $title $content');
    var best = PresentationBackgroundKind.science;
    var bestScore = 0;

    for (final definition in presentationBackgroundLibrary) {
      var score = 0;
      for (final tag in definition.tags) {
        if (PresentationKeywordCatalog.textMatchesKeyword(
          normalized,
          PresentationKeywordCatalog.normalize(tag),
        )) {
          score += 1;
        }
      }
      if (score > bestScore) {
        best = definition.kind;
        bestScore = score;
      }
    }
    return best;
  }

  static PresentationController buildController({
    required String topic,
    required List<DeckSlide> slides,
  }) {
    final controller = PresentationController();
    final pages = const PresentationDeckBuilder().buildPages(
      topic: topic,
      slides: slides,
    );
    controller.replaceDeck(
      pages,
      effectSettings: const PresentationEffectSettings(
        transitionKind: PresentationTransitionKind.slide,
      ),
    );
    return controller;
  }
}

/// Sunum üretim akışının bir slaydı: başlık, içerik ve eşleşen modeller.
class DeckSlide {
  const DeckSlide({
    required this.title,
    required this.content,
    required this.models,
  });

  final String title;
  final String content;
  final List<ModelMatch> models;
}
