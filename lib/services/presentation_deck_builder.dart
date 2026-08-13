import 'package:flutter/widgets.dart';

import '../models/slide_model.dart';
import '../state/presentation_controller.dart';
import 'model_matching_service.dart';
import 'presentation_auto_builder.dart';
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
      for (final model in slide.models.take(1)) {
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

      final selectedModel = slide.models.isEmpty ? null : slide.models.first;
      final fallbackComponent = selectedModel == null
          ? bestPresentationComponentForSlide(
              title: title,
              body: '${slide.keywords.join(' ')} $content',
            )
          : null;
      final hasVisual = selectedModel != null || fallbackComponent != null;
      final background =
          _bestBackground(topic: topic, title: title, content: content);

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
            widthFactor: hasVisual ? 0.58 : 0.84,
          ),
        );
      }
      if (content.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: content,
            position: title.isEmpty
                ? const Offset(0.07, 0.22)
                : const Offset(0.07, 0.34),
            fontSize: 26,
            type: PresentationTextType.body,
            textStyle: PresentationTextStyle.bilimTemiz,
            textAnimation: PresentationTextAnimation.bulaniktanNet,
            widthFactor: hasVisual ? 0.5 : 0.84,
          ),
        );
      }

      final componentBlocks = <PresentationComponentBlock>[];
      if (selectedModel != null) {
        componentBlocks.add(
          PresentationComponentBlock(
            id: 'component-${componentCounter++}',
            modelAssetId: selectedModel.id,
            modelAnimationEnabled: false,
            modelOrbitTheta: 15,
            modelOrbitPhi: 70,
            position: const Offset(0.68, 0.22),
            size: const Size(0.29, 0.62),
          ),
        );
      } else if (fallbackComponent != null) {
        componentBlocks.add(
          PresentationComponentBlock(
            id: 'component-${componentCounter++}',
            kind: fallbackComponent,
            position: const Offset(0.68, 0.24),
            size: const Size(0.27, 0.5),
          ),
        );
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
    this.keywords = const <String>[],
  });

  final String title;
  final String content;
  final List<ModelMatch> models;
  final List<String> keywords;
}
