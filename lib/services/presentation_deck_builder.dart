import 'package:flutter/widgets.dart';

import '../models/slide_model.dart';
import '../state/presentation_controller.dart';
import 'model_matching_service.dart';
import 'presentation_auto_builder.dart';
import 'presentation_keyword_catalog.dart';

import 'remote_model_sources.dart';
import 'model_asset_service.dart';
import 'presentation_model_source_resolver.dart';

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
        if (model.id.isNotEmpty && model.modelUrl.trim().isNotEmpty) {
          sources[model.id] = ModelAssetService.modelUrlFromField(model.modelUrl);
        }
      }
    }
    if (sources.isNotEmpty) {
      RemoteModelSources.registerAll(sources);
    }

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

      // `kind` is also the HTML fallback rendered while a remote 3D source
      // cannot be resolved. Calculate it for model-backed blocks as well;
      // otherwise PresentationComponentBlock's historical default
      // (edebiyat01 / open book) appears for every missing model.
      var selectedModel =
          slide.models.isEmpty || slide.models.first.modelUrl.trim().isEmpty
              ? null
              : slide.models.first;
      if (selectedModel == null) {
        final searchKeywords = <String>[
          ...slide.keywords,
          ...title.split(' '),
          ...content.split(' '),
        ];
        final catalogMatches = ModelMatchingService.rankCatalogModels(
          models: ModelMatchingService.localCatalogEntries,
          keywords: searchKeywords,
        );
        if (catalogMatches.isNotEmpty) {
          selectedModel = catalogMatches.first;
        }
      }
      final fallbackComponent = selectedModel != null
          ? null
          : bestPresentationComponentForSlide(
              title: title,
              body: '${slide.keywords.join(' ')} $content',
            );
      final hasVisual = selectedModel != null || fallbackComponent != null;
      final background =
          _bestBackground(topic: topic, title: title, content: content);

      final textBlocks = <PresentationTextBlock>[];
      final titleLayout = _generatedTitleLayout(title);
      final bodyTop = title.isEmpty ? 0.16 : titleLayout.bodyTop;
      if (title.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: title,
            position: const Offset(0.07, 0.08),
            fontSize: titleLayout.fontSize,
            type: PresentationTextType.title,
            textStyle: PresentationTextStyle.bilimTemiz,
            textAnimation: PresentationTextAnimation.yavasBelirme,
            widthFactor: hasVisual ? 0.58 : 0.84,
            heightFactor: titleLayout.heightFactor,
          ),
        );
      }
      if (content.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: content,
            position: Offset(0.07, bodyTop),
            fontSize: _generatedBodyFontSize(content),
            type: PresentationTextType.body,
            textStyle: PresentationTextStyle.bilimTemiz,
            textAnimation: PresentationTextAnimation.bulaniktanNet,
            widthFactor: hasVisual ? 0.5 : 0.84,
            heightFactor: 0.9 - bodyTop,
          ),
        );
      }

      final componentBlocks = <PresentationComponentBlock>[];
      if (selectedModel != null) {
        componentBlocks.add(
          PresentationComponentBlock(
            id: 'component-${componentCounter++}',
            kind: fallbackComponent ?? PresentationComponentKind.edebiyat01,
            modelAssetId: selectedModel.id,
            modelAnimationEnabled: true,
            modelAutoRotate: true,
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
    hydratePresentationModelSources(pages);
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

({double fontSize, double heightFactor, double bodyTop}) _generatedTitleLayout(
    String title) {
  final length = title.replaceAll(RegExp(r'\s+'), ' ').trim().length;
  if (length <= 34) {
    return (fontSize: 52, heightFactor: 0.18, bodyTop: 0.30);
  }
  if (length <= 68) {
    return (fontSize: 46, heightFactor: 0.24, bodyTop: 0.36);
  }
  return (fontSize: 40, heightFactor: 0.30, bodyTop: 0.42);
}

double _generatedBodyFontSize(String content) {
  final length = content.replaceAll(RegExp(r'\s+'), ' ').trim().length;
  if (length >= 360) return 20;
  if (length >= 260) return 22;
  if (length >= 180) return 24;
  return 26;
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
