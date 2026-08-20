import 'package:flutter/widgets.dart';

import '../models/slide_model.dart';
import '../state/presentation_controller.dart';
import 'model_matching_service.dart';
import 'presentation_auto_builder.dart';
import 'presentation_keyword_catalog.dart';

import 'remote_model_sources.dart';
import 'model_asset_service.dart';
import 'presentation_model_source_resolver.dart';

/// Gemini / NVIDIA / Grok + model eşleştirme çıktısından gerçek bir sunum destesi (deck)
/// üretir. Slayt arketipini (hero, comparison, process, cards, timeline, statistic, summary)
/// inceleyerek arketipe özgü zengin görsel düzen ve metin hiyerarşisi oluşturur.
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
      final subtitle = slide.subtitle?.trim() ?? '';
      final content = slide.content.trim();
      final slideType = (slide.type.isEmpty ? 'cards' : slide.type).toLowerCase().trim();

      if (title.isEmpty && content.isEmpty && subtitle.isEmpty) {
        continue;
      }

      var selectedModel =
          slide.models.isEmpty || slide.models.first.modelUrl.trim().isEmpty
              ? null
              : slide.models.first;
      if (selectedModel == null) {
        final searchKeywords = <String>[
          ...slide.keywords,
          ...title.split(' '),
          ...subtitle.split(' '),
          ...content.split(' '),
          ...topic.split(' '),
        ];
        final catalogMatches = ModelMatchingService.rankCatalogModels(
          models: ModelMatchingService.localCatalogEntries,
          keywords: searchKeywords,
        );
        if (catalogMatches.isNotEmpty) {
          selectedModel = catalogMatches.first;
        }
      }
      final fallbackComponent = bestPresentationComponentForSlide(
        title: title,
        body: '${slide.keywords.join(' ')} $subtitle $content',
      );
      final hasVisual = selectedModel != null || fallbackComponent != null;
      final background =
          _bestBackground(topic: topic, title: title, content: content);

      final textBlocks = <PresentationTextBlock>[];

      // ─── Arketipe Özgü Yerleşim Kuralları (Layout Generation) ─────────────
      switch (slideType) {
        case 'hero':
          // Hero Layout: Büyük vurgulu başlık + Alt başlık + Vurucu vizyon/alt metin
          if (title.isNotEmpty) {
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: title,
                position: const Offset(0.08, 0.16),
                fontSize: 54,
                type: PresentationTextType.title,
                textStyle: PresentationTextStyle.bilimDramatik,
                textAnimation: PresentationTextAnimation.yavasBelirme,
                widthFactor: hasVisual ? 0.56 : 0.84,
                heightFactor: 0.22,
              ),
            );
          }
          if (subtitle.isNotEmpty) {
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: subtitle,
                position: const Offset(0.08, 0.40),
                fontSize: 26,
                type: PresentationTextType.subtitle,
                textStyle: PresentationTextStyle.bilimDeneysel,
                textAnimation: PresentationTextAnimation.yavasBelirme,
                widthFactor: hasVisual ? 0.54 : 0.84,
                heightFactor: 0.14,
              ),
            );
          }
          if (content.isNotEmpty) {
            final cleanedContent = content.replaceAll(RegExp(r'^[-\*•]\s*', multiLine: true), '').trim();
            final top = subtitle.isNotEmpty ? 0.56 : 0.42;
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: cleanedContent,
                position: Offset(0.08, top),
                fontSize: 24,
                type: PresentationTextType.body,
                textStyle: PresentationTextStyle.bilimTemiz,
                textAnimation: PresentationTextAnimation.bulaniktanNet,
                widthFactor: hasVisual ? 0.54 : 0.84,
                heightFactor: 0.88 - top,
              ),
            );
          }
          break;

        case 'quote':
          // Quote Layout: İtalik alıntı metni + Başlık/Kaynak
          if (title.isNotEmpty) {
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: title,
                position: const Offset(0.08, 0.10),
                fontSize: 34,
                type: PresentationTextType.title,
                textStyle: PresentationTextStyle.bilimTemiz,
                textAnimation: PresentationTextAnimation.yavasBelirme,
                widthFactor: hasVisual ? 0.56 : 0.84,
                heightFactor: 0.18,
              ),
            );
          }
          if (content.isNotEmpty) {
            final cleanedQuote = content.replaceAll(RegExp(r'^[-\*•]\s*', multiLine: true), '').trim();
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: cleanedQuote.startsWith('"') ? cleanedQuote : '"$cleanedQuote"',
                position: const Offset(0.08, 0.32),
                fontSize: 28,
                textItalic: true,
                type: PresentationTextType.body,
                textStyle: PresentationTextStyle.klasikLora,
                textAnimation: PresentationTextAnimation.bulaniktanNet,
                widthFactor: hasVisual ? 0.54 : 0.84,
                heightFactor: 0.56,
              ),
            );
          }
          break;

        case 'comparison':
        case 'cause_effect':
          // Comparison & Cause-Effect Layout: İki karşılaştırmalı sütun
          final titleLayout = _generatedTitleLayout(title);
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
                widthFactor: 0.86,
                heightFactor: titleLayout.heightFactor,
              ),
            );
          }
          if (content.isNotEmpty) {
            final splitComparison = _splitComparisonContent(content);
            if (splitComparison != null && !hasVisual) {
              // 2 Kolonlu Blok
              textBlocks.add(
                PresentationTextBlock(
                  id: 'text-${textCounter++}',
                  text: splitComparison.left,
                  position: Offset(0.07, titleLayout.bodyTop),
                  fontSize: 22,
                  type: PresentationTextType.body,
                  textStyle: PresentationTextStyle.bilimTemiz,
                  textAnimation: PresentationTextAnimation.bulaniktanNet,
                  widthFactor: 0.40,
                  heightFactor: 0.88 - titleLayout.bodyTop,
                ),
              );
              textBlocks.add(
                PresentationTextBlock(
                  id: 'text-${textCounter++}',
                  text: splitComparison.right,
                  position: Offset(0.51, titleLayout.bodyTop),
                  fontSize: 22,
                  type: PresentationTextType.body,
                  textStyle: PresentationTextStyle.bilimTemiz,
                  textAnimation: PresentationTextAnimation.bulaniktanNet,
                  widthFactor: 0.40,
                  heightFactor: 0.88 - titleLayout.bodyTop,
                ),
              );
            } else {
              textBlocks.add(
                PresentationTextBlock(
                  id: 'text-${textCounter++}',
                  text: content,
                  position: Offset(0.07, titleLayout.bodyTop),
                  fontSize: _generatedBodyFontSize(content),
                  type: PresentationTextType.body,
                  textStyle: PresentationTextStyle.bilimTemiz,
                  textAnimation: PresentationTextAnimation.bulaniktanNet,
                  widthFactor: hasVisual ? 0.54 : 0.84,
                  heightFactor: 0.9 - titleLayout.bodyTop,
                ),
              );
            }
          }
          break;

        case 'statistic':
          // Statistic Layout: Büyük sayı/metrik + Alt açıklama
          if (title.isNotEmpty) {
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: title,
                position: const Offset(0.08, 0.10),
                fontSize: 44,
                type: PresentationTextType.title,
                textStyle: PresentationTextStyle.bilimTemiz,
                textAnimation: PresentationTextAnimation.yavasBelirme,
                widthFactor: hasVisual ? 0.56 : 0.84,
                heightFactor: 0.20,
              ),
            );
          }
          if (content.isNotEmpty) {
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: content,
                position: const Offset(0.08, 0.35),
                fontSize: 28,
                type: PresentationTextType.body,
                textStyle: PresentationTextStyle.bilimDramatik,
                textAnimation: PresentationTextAnimation.bulaniktanNet,
                widthFactor: hasVisual ? 0.54 : 0.84,
                heightFactor: 0.50,
              ),
            );
          }
          break;

        case 'image_focus':
          // Image Focus Layout: Görsel / 3B Model öncelikli düzen
          final titleLayout = _generatedTitleLayout(title);
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
                widthFactor: hasVisual ? 0.50 : 0.84,
                heightFactor: titleLayout.heightFactor,
              ),
            );
          }
          if (content.isNotEmpty) {
            textBlocks.add(
              PresentationTextBlock(
                id: 'text-${textCounter++}',
                text: content,
                position: Offset(0.07, titleLayout.bodyTop),
                fontSize: _generatedBodyFontSize(content),
                type: PresentationTextType.body,
                textStyle: PresentationTextStyle.bilimTemiz,
                textAnimation: PresentationTextAnimation.bulaniktanNet,
                widthFactor: hasVisual ? 0.48 : 0.84,
                heightFactor: 0.9 - titleLayout.bodyTop,
              ),
            );
          }
          break;

        case 'process':
        case 'timeline':
        case 'chart':
        case 'cards':
        case 'summary':
        default:
          // Standart Süreç / Kart / Zaman Çizelgesi / Özet Layout'u
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
                textAnimation: slideType == 'timeline'
                    ? PresentationTextAnimation.soldanKayma
                    : PresentationTextAnimation.bulaniktanNet,
                widthFactor: hasVisual ? 0.52 : 0.84,
                heightFactor: 0.9 - bodyTop,
              ),
            );
          }
          break;
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

  static ({String left, String right})? _splitComparisonContent(String content) {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length < 2) return null;

    final mid = (lines.length / 2).ceil();
    final leftLines = lines.take(mid).join('\n');
    final rightLines = lines.skip(mid).join('\n');
    return (left: leftLines, right: rightLines);
  }

  Future<List<PresentationPage>> buildPagesAsync({
    required String topic,
    required List<DeckSlide> slides,
  }) async {
    final pages = buildPages(topic: topic, slides: slides);
    await hydratePresentationModelSources(pages);
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

  static Future<PresentationController> buildControllerAsync({
    required String topic,
    required List<DeckSlide> slides,
  }) async {
    final pages = await const PresentationDeckBuilder().buildPagesAsync(
      topic: topic,
      slides: slides,
    );
    final controller = PresentationController();
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

/// Sunum üretim akışının bir slaydı: başlık, içerik, tip ve eşleşen modeller.
class DeckSlide {
  const DeckSlide({
    required this.title,
    this.subtitle,
    required this.content,
    required this.models,
    this.keywords = const <String>[],
    this.type = 'cards',
    this.purpose,
    this.keyMessage,
    this.sections,
    this.visual,
    this.sources = const <String>[],
  });

  final String title;
  final String? subtitle;
  final String content;
  final List<ModelMatch> models;
  final List<String> keywords;
  final String type;
  final String? purpose;
  final String? keyMessage;
  final List<Map<String, dynamic>>? sections;
  final Map<String, dynamic>? visual;
  final List<String> sources;
}
