import 'package:flutter/material.dart';

import '../models/slide_model.dart';
import 'presentation_keyword_catalog.dart';

class PresentationDraftPage {
  const PresentationDraftPage({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  bool get isBlank => title.trim().isEmpty && body.trim().isEmpty;
}

/// Sunum oluşturulurken kullanılan görsel düzen. `automatic`, konuya göre
/// arka plan seçer; diğer seçenekler ise sunum boyunca tutarlı bir görünüm
/// sağlar.
enum PresentationTemplate {
  automatic,
  academic,
  corporate,
  creative,
  minimal,
  darkCorporate,
  techStartup,
  scientific,
  elegant,
  bold,
  pastel,
  highContrast,
}

String presentationTemplateLabel(PresentationTemplate template) {
  switch (template) {
    case PresentationTemplate.automatic:
      return 'Otomatik';
    case PresentationTemplate.academic:
      return 'Akademik';
    case PresentationTemplate.corporate:
      return 'Kurumsal';
    case PresentationTemplate.creative:
      return 'Yaratıcı';
    case PresentationTemplate.minimal:
      return 'Minimal';
    case PresentationTemplate.darkCorporate:
      return 'Koyu Kurumsal';
    case PresentationTemplate.techStartup:
      return 'Teknoloji Girişimi';
    case PresentationTemplate.scientific:
      return 'Bilimsel';
    case PresentationTemplate.elegant:
      return 'Şık';
    case PresentationTemplate.bold:
      return 'Cesur';
    case PresentationTemplate.pastel:
      return 'Pastel';
    case PresentationTemplate.highContrast:
      return 'Yüksek Kontrast';
  }
}

String presentationTemplateDescription(PresentationTemplate template) {
  switch (template) {
    case PresentationTemplate.automatic:
      return 'Konuya göre seçilir';
    case PresentationTemplate.academic:
      return 'Dengeli, açıklayıcı düzen';
    case PresentationTemplate.corporate:
      return 'Net ve profesyonel görünüm';
    case PresentationTemplate.creative:
      return 'Vurucu, görsel odaklı sahne';
    case PresentationTemplate.minimal:
      return 'Sade, metin odaklı düzen';
    case PresentationTemplate.darkCorporate:
      return 'Koyu tema, executive sunumlar';
    case PresentationTemplate.techStartup:
      return 'Modern, teknoloji odaklı';
    case PresentationTemplate.scientific:
      return 'Veri ve bilim odaklı temiz tasarım';
    case PresentationTemplate.elegant:
      return 'Zarfı, yüksek estetik';
    case PresentationTemplate.bold:
      return 'Güçlü, dikkat çekici';
    case PresentationTemplate.pastel:
      return 'Yumuşak, dostane tonlar';
    case PresentationTemplate.highContrast:
      return 'Maksimum okunabilirlik';
  }
}

class PresentationAutoBuilder {
  const PresentationAutoBuilder();

  List<PresentationPage> buildPages(
    List<PresentationDraftPage> drafts, {
    PresentationTemplate template = PresentationTemplate.automatic,
  }) {
    var pageCounter = 1;
    var textCounter = 1;
    var componentCounter = 1;
    final pages = <PresentationPage>[];
    final config = templateConfig(template);

    // Uzun AI yanıtlarını tek bir kutuya koymak yerine okunabilir parçalara
    // ayırıyoruz. Böylece hem düzen korunur hem de export/önizlemede taşma
    // ihtimali ciddi biçimde azalır.
    for (final draft in _splitLongDrafts(drafts, template: template)) {
      final title = draft.title.trim();
      final body = draft.body.trim();
      if (title.isEmpty && body.isEmpty) {
        continue;
      }

      final match = _bestMatch(title: title, body: body, template: template);
      final titleOnly = title.isNotEmpty && body.isEmpty;
      final longBody = body.length >= 170;
      final templateComponentKinds = config.componentKinds;
      final componentKinds = templateComponentKinds.isNotEmpty
          ? templateComponentKinds
          : _bestComponentKinds(
              title: title,
              body: body,
              maxComponents: template == PresentationTemplate.minimal
                  ? 0
                  : titleOnly || longBody
                      ? 1
                      : 2,
            );
      final hasComponents = componentKinds.isNotEmpty;
      final textBlocks = <PresentationTextBlock>[];

      if (title.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: title,
            position:
                titleOnly ? const Offset(0.08, 0.16) : const Offset(0.08, 0.12),
            fontSize: (_titleFontSize(title, titleOnly: titleOnly) *
                    config.fontScale)
                .roundToDouble(),
            type: PresentationTextType.title,
            textStyle: config.titleTextStyle,
            textAnimation: config.titleTextAnimation,
            textColorHex: config.titleTextColor,
            glowIntensity: config.glowIntensity,
            widthFactor: template == PresentationTemplate.minimal
                ? 0.84
                : hasComponents
                    ? titleOnly
                        ? 0.56
                        : 0.58
                    : titleOnly
                        ? 0.78
                        : 0.76,
          ),
        );
      }

      if (body.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: body,
            position: title.isEmpty
                ? const Offset(0.08, 0.18)
                : Offset(0.08, _bodyTop(title)),
            fontSize: (_bodyFontSize(body, hasComponents: hasComponents) *
                    config.fontScale)
                .roundToDouble(),
            type: PresentationTextType.body,
            textStyle: config.bodyTextStyle,
            textAnimation: config.bodyTextAnimation,
            textColorHex: config.bodyTextColor,
            glowIntensity: config.glowIntensity,
            widthFactor: hasComponents
                ? 0.58
                : longBody
                    ? 0.78
                    : 0.76,
          ),
        );
      }

      final componentBlocks = <PresentationComponentBlock>[];
      for (var i = 0; i < componentKinds.length; i += 1) {
        componentBlocks.add(
          PresentationComponentBlock(
            id: 'component-${componentCounter++}',
            kind: componentKinds[i],
            position: _componentPosition(i, titleOnly: titleOnly),
            size: _componentSize(i, single: componentKinds.length == 1),
          ),
        );
      }

      pages.add(
        PresentationPage(
          id: 'page-${pageCounter++}',
          backgroundKind: config.backgroundKind ?? match.backgroundKind,
          textBlocks: textBlocks,
          componentBlocks: componentBlocks,
        ),
      );
    }

    return pages;
  }

  _AutoTheme _bestMatch({
    required String title,
    required String body,
    required PresentationTemplate template,
  }) {
    final templateBackground = presentationTemplateBackground(template);
    if (templateBackground != null) {
      return _AutoTheme(
        backgroundKind: templateBackground,
        keywords: const <_AutoKeyword>[],
      );
    }
    final normalizedTitle = _normalize(title);
    final normalizedBody = _normalize(body);
    final normalizedText = '$normalizedTitle $normalizedBody';
    var best = _fallbackTheme;
    var bestScore = 0;

    for (final theme in _autoThemes) {
      var score = 0;
      for (final keyword in theme.keywords) {
        final normalizedKeyword = _normalize(keyword.value);
        if (PresentationKeywordCatalog.textMatchesKeyword(
          normalizedTitle,
          normalizedKeyword,
        )) {
          score += keyword.weight + 2;
        } else if (PresentationKeywordCatalog.textMatchesKeyword(
          normalizedBody,
          normalizedKeyword,
        )) {
          score += keyword.weight;
        } else if (PresentationKeywordCatalog.textMatchesKeyword(
          normalizedText,
          normalizedKeyword,
        )) {
          score += keyword.weight;
        }
      }

      if (score > bestScore) {
        best = theme;
        bestScore = score;
      }
    }

    return best;
  }

  List<PresentationDraftPage> _splitLongDrafts(
    List<PresentationDraftPage> drafts, {
    required PresentationTemplate template,
  }) {
    final maxCharacters = template == PresentationTemplate.minimal ? 420 : 280;
    final result = <PresentationDraftPage>[];
    for (final draft in drafts) {
      final body = draft.body.trim();
      if (body.length <= maxCharacters) {
        result.add(draft);
        continue;
      }
      final chunks = _splitText(body, maxCharacters);
      for (var index = 0; index < chunks.length; index += 1) {
        result.add(
          PresentationDraftPage(
            title: index == 0 ? draft.title : '${draft.title} (devam)',
            body: chunks[index],
          ),
        );
      }
    }
    return result;
  }

  List<PresentationComponentKind> _bestComponentKinds({
    required String title,
    required String body,
    required int maxComponents,
  }) {
    if (maxComponents <= 0) {
      return const <PresentationComponentKind>[];
    }

    final normalizedTitle = _normalize(title);
    final normalizedBody = _normalize(body);
    final candidates = <_AutoComponentCandidate>[];

    for (final definition in presentationComponentDefinitions) {
      final score = _componentScore(
        definition,
        normalizedTitle: normalizedTitle,
        normalizedBody: normalizedBody,
      );
      if (score >= _minimumComponentScore) {
        candidates.add(_AutoComponentCandidate(definition, score));
      }
    }

    candidates.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      if (scoreOrder != 0) {
        return scoreOrder;
      }
      return a.definition.label.compareTo(b.definition.label);
    });

    final selected = <PresentationComponentKind>[];
    for (final candidate in candidates) {
      if (selected.length >= maxComponents) {
        break;
      }
      if (selected.contains(candidate.definition.kind)) {
        continue;
      }
      selected.add(candidate.definition.kind);
    }

    return selected;
  }

  int _componentScore(
    PresentationComponentDefinition definition, {
    required String normalizedTitle,
    required String normalizedBody,
  }) {
    var score = 0;

    for (final tag in definition.tags) {
      final normalizedTag = _normalize(tag);
      final isAmbiguous = _ambiguousComponentTags.contains(normalizedTag) ||
          (_componentTagCategoryCounts[normalizedTag] ?? 0) > 1;
      score += _scoreKeyword(
        tag,
        normalizedTitle: normalizedTitle,
        normalizedBody: normalizedBody,
        titleExactScore: isAmbiguous ? 6 : 20,
        bodyExactScore: isAmbiguous ? 4 : 14,
        titlePartialScore: isAmbiguous ? 0 : 5,
        bodyPartialScore: isAmbiguous ? 0 : 3,
        titlePartialCap: isAmbiguous ? 0 : 12,
        bodyPartialCap: isAmbiguous ? 0 : 9,
      );
    }

    score += _scoreKeyword(
      definition.label,
      normalizedTitle: normalizedTitle,
      normalizedBody: normalizedBody,
      titleExactScore: 18,
      bodyExactScore: 12,
      titlePartialScore: 6,
      bodyPartialScore: 4,
      titlePartialCap: 12,
      bodyPartialCap: 8,
    );
    score += _scoreKeyword(
      definition.category,
      normalizedTitle: normalizedTitle,
      normalizedBody: normalizedBody,
      titleExactScore: 4,
      bodyExactScore: 3,
      titlePartialScore: 0,
      bodyPartialScore: 0,
      titlePartialCap: 0,
      bodyPartialCap: 0,
    );
    score += _scoreKeyword(
      definition.description,
      normalizedTitle: normalizedTitle,
      normalizedBody: normalizedBody,
      titleExactScore: 4,
      bodyExactScore: 3,
      titlePartialScore: 1,
      bodyPartialScore: 1,
      titlePartialCap: 3,
      bodyPartialCap: 3,
    );

    return score;
  }

  int _scoreKeyword(
    String value, {
    required String normalizedTitle,
    required String normalizedBody,
    required int titleExactScore,
    required int bodyExactScore,
    required int titlePartialScore,
    required int bodyPartialScore,
    required int titlePartialCap,
    required int bodyPartialCap,
  }) {
    final normalizedKeyword = _normalize(value);
    if (normalizedKeyword.isEmpty) {
      return 0;
    }

    return _scoreTextAgainstKeyword(
          normalizedTitle,
          normalizedKeyword,
          exactScore: titleExactScore,
          partialScore: titlePartialScore,
          partialCap: titlePartialCap,
        ) +
        _scoreTextAgainstKeyword(
          normalizedBody,
          normalizedKeyword,
          exactScore: bodyExactScore,
          partialScore: bodyPartialScore,
          partialCap: bodyPartialCap,
        );
  }

  int _scoreTextAgainstKeyword(
    String normalizedText,
    String normalizedKeyword, {
    required int exactScore,
    required int partialScore,
    required int partialCap,
  }) {
    if (normalizedText.isEmpty || normalizedKeyword.isEmpty) {
      return 0;
    }
    if (PresentationKeywordCatalog.textMatchesKeyword(
      normalizedText,
      normalizedKeyword,
    )) {
      return exactScore;
    }

    return _partialWordScore(
      normalizedText,
      normalizedKeyword,
      perWordScore: partialScore,
      cap: partialCap,
    );
  }
}

int _partialWordScore(
  String normalizedText,
  String normalizedKeyword, {
  required int perWordScore,
  required int cap,
}) {
  final inputWords = PresentationKeywordCatalog.words(normalizedText)
      .where(_isImportantComponentWord)
      .toList(growable: false);
  if (inputWords.isEmpty) {
    return 0;
  }

  final keywordWords = PresentationKeywordCatalog.words(normalizedKeyword)
      .where(_isImportantComponentWord)
      .toSet();
  var matches = 0;
  for (final keywordWord in keywordWords) {
    if (inputWords.any(
      (inputWord) => PresentationKeywordCatalog.wordsMatch(
        inputWord,
        keywordWord,
      ),
    )) {
      matches += 1;
    }
  }

  final score = matches * perWordScore;
  return score > cap ? cap : score;
}

bool _isImportantComponentWord(String word) {
  return word.length >= 3 && !_ignoredComponentWords.contains(word);
}

Offset _componentPosition(int index, {required bool titleOnly}) {
  if (titleOnly) {
    return const Offset(0.68, 0.30);
  }
  return index == 0 ? const Offset(0.70, 0.16) : const Offset(0.70, 0.52);
}

Size _componentSize(int index, {required bool single}) {
  if (single) {
    return const Size(0.24, 0.28);
  }
  return const Size(0.22, 0.24);
}

double _titleFontSize(String title, {required bool titleOnly}) {
  final length = title.replaceAll(RegExp(r'\s+'), ' ').trim().length;
  final base = titleOnly ? 64.0 : 54.0;
  if (length <= 36) return base;
  if (length <= 64) return base - 8;
  if (length <= 92) return base - 16;
  return base - 22;
}

double _bodyFontSize(String body, {required bool hasComponents}) {
  final length = body.length;
  if (length >= 250) return hasComponents ? 27 : 30;
  if (length >= 170) return hasComponents ? 29 : 31;
  return hasComponents ? 32 : 34;
}

double _bodyTop(String title) {
  final length = title.replaceAll(RegExp(r'\s+'), ' ').trim().length;
  if (length <= 40) return 0.30;
  if (length <= 72) return 0.35;
  return 0.42;
}

PresentationBackgroundKind? presentationTemplateBackground(
  PresentationTemplate template,
) {
  switch (template) {
    case PresentationTemplate.automatic:
      return null;
    case PresentationTemplate.academic:
      return PresentationBackgroundKind.lightEducation;
    case PresentationTemplate.corporate:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.creative:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.minimal:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.darkCorporate:
      return PresentationBackgroundKind.businessFinance;
    case PresentationTemplate.techStartup:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.scientific:
      return PresentationBackgroundKind.science;
    case PresentationTemplate.elegant:
      return PresentationBackgroundKind.lightNature;
    case PresentationTemplate.bold:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.pastel:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.highContrast:
      return PresentationBackgroundKind.lightCorporate;
  }
}

/// Comprehensive template configuration that defines all visual aspects
/// of a template including background, text styles, animations, transitions, etc.
@immutable
class PresentationTemplateConfig {
  const PresentationTemplateConfig({
    required this.backgroundKind,
    required this.titleTextStyle,
    required this.bodyTextStyle,
    required this.titleTextAnimation,
    required this.bodyTextAnimation,
    required this.titleTextColor,
    required this.bodyTextColor,
    required this.transitionKind,
    required this.transitionDurationMs,
    required this.componentKinds,
    required this.glowIntensity,
    required this.fontScale,
  });

  final PresentationBackgroundKind? backgroundKind;
  final PresentationTextStyle titleTextStyle;
  final PresentationTextStyle bodyTextStyle;
  final PresentationTextAnimation titleTextAnimation;
  final PresentationTextAnimation bodyTextAnimation;
  final String? titleTextColor;
  final String? bodyTextColor;
  final PresentationTransitionKind transitionKind;
  final int transitionDurationMs;
  final List<PresentationComponentKind> componentKinds;
  final double glowIntensity;
  final double fontScale;
}

PresentationTemplateConfig templateConfig(PresentationTemplate template) {
  switch (template) {
    case PresentationTemplate.automatic:
      return const PresentationTemplateConfig(
        backgroundKind: null,
        titleTextStyle: PresentationTextStyle.standard,
        bodyTextStyle: PresentationTextStyle.standard,
        titleTextAnimation: PresentationTextAnimation.none,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: null,
        bodyTextColor: null,
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 600,
        componentKinds: [],
        glowIntensity: 1.0,
        fontScale: 1.0,
      );
    case PresentationTemplate.academic:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightEducation,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#1A237E',
        bodyTextColor: '#283593',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.egitim01,
          PresentationComponentKind.egitim02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.corporate:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#0D47A1',
        bodyTextColor: '#1565C0',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.genelSunumIs01,
          PresentationComponentKind.genelSunumIs02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.05,
      );
    case PresentationTemplate.creative:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        titleTextColor: '#7B1FA2',
        bodyTextColor: '#8E24AA',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.sanat01,
          PresentationComponentKind.sanat02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.1,
      );
    case PresentationTemplate.minimal:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.none,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#3E2723',
        bodyTextColor: '#5D4037',
        transitionKind: PresentationTransitionKind.none,
        transitionDurationMs: 300,
        componentKinds: [],
        glowIntensity: 0.0,
        fontScale: 1.0,
      );
    case PresentationTemplate.darkCorporate:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.businessFinance,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.metalikParlama,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#FFFFFF',
        bodyTextColor: '#B0BEC5',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.ekonomiIsFinans01,
          PresentationComponentKind.ekonomiIsFinans02,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.techStartup:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDeneysel,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.holografikDalga,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#4DD0E1',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji01,
          PresentationComponentKind.teknoloji02,
        ],
        glowIntensity: 1.0,
        fontScale: 1.05,
      );
    case PresentationTemplate.scientific:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.science,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.fizikDramatik,
        titleTextColor: '#54D6FF',
        bodyTextColor: '#81D4FA',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.fizik01,
          PresentationComponentKind.kimya01,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.elegant:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightNature,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.siviDalga,
        bodyTextAnimation: PresentationTextAnimation.yercekimsizSuzulme,
        titleTextColor: '#2E7D32',
        bodyTextColor: '#43A047',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 1000,
        componentKinds: [
          PresentationComponentKind.cevreDoga01,
          PresentationComponentKind.cevreDoga02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.05,
      );
    case PresentationTemplate.bold:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openUnbounded,
        titleTextAnimation: PresentationTextAnimation.isikTaramasi,
        bodyTextAnimation: PresentationTextAnimation.neonKontur,
        titleTextColor: '#FFD600',
        bodyTextColor: '#FFEB3B',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 400,
        componentKinds: [
          PresentationComponentKind.teknoloji03,
          PresentationComponentKind.teknoloji04,
        ],
        glowIntensity: 1.5,
        fontScale: 1.15,
      );
    case PresentationTemplate.pastel:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.gunesTemiz,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#E91E63',
        bodyTextColor: '#F06292',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.moda01,
          PresentationComponentKind.moda02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.highContrast:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.daktilo,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#000000',
        bodyTextColor: '#212121',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 300,
        componentKinds: [
          PresentationComponentKind.genelSunumIs03,
          PresentationComponentKind.genelSunumIs04,
        ],
        glowIntensity: 0.0,
        fontScale: 1.1,
      );
  }
}

List<String> _splitText(String text, int maxCharacters) {
  final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  final chunks = <String>[];
  var current = StringBuffer();
  for (final word in words) {
    final nextLength = current.length == 0 ? word.length : current.length + word.length + 1;
    if (current.length > 0 && nextLength > maxCharacters) {
      chunks.add(current.toString());
      current = StringBuffer(word);
    } else {
      if (current.length > 0) current.write(' ');
      current.write(word);
    }
  }
  if (current.length > 0) chunks.add(current.toString());
  return chunks;
}

const int _minimumComponentScore = 12;

const Set<String> _ignoredComponentWords = <String>{
  'bir',
  'bu',
  'icin',
  'ile',
  'olan',
  'olarak',
  'gibi',
  'daha',
  'cok',
  'az',
  'her',
  'the',
  'and',
  'for',
  'with',
  'from',
  'that',
  'this',
  'into',
};

const Set<String> _ambiguousComponentTags = <String>{
  'analiz',
  'basari',
  'degerlendirme',
  'dil',
  'dogal kaynak',
  'doga',
  'form',
  'fikir',
  'gelisim',
  'hedef',
  'hareket',
  'iletisim',
  'ilerleme',
  'isbirligi',
  'kayit',
  'performans',
  'proje',
  'renk',
  'ses',
  'sembol',
  'sistem',
  'strateji',
  'surec',
  'tasarim',
  'teknoloji',
  'uretim',
  'veri',
  'verimlilik',
  'yaraticilik',
};

final Map<String, int> _componentTagCategoryCounts = () {
  final categoriesByTag = <String, Set<String>>{};
  for (final definition in presentationComponentDefinitions) {
    for (final tag in definition.tags) {
      final normalizedTag = _normalize(tag);
      if (normalizedTag.isEmpty) {
        continue;
      }
      categoriesByTag
          .putIfAbsent(normalizedTag, () => <String>{})
          .add(definition.category);
    }
  }
  return <String, int>{
    for (final entry in categoriesByTag.entries) entry.key: entry.value.length,
  };
}();

class _AutoTheme {
  const _AutoTheme({
    required this.backgroundKind,
    required this.keywords,
  });

  final PresentationBackgroundKind backgroundKind;
  final List<_AutoKeyword> keywords;
}

class _AutoKeyword {
  const _AutoKeyword(this.value, [this.weight = 3]);

  final String value;
  final int weight;
}

class _AutoComponentCandidate {
  const _AutoComponentCandidate(this.definition, this.score);

  final PresentationComponentDefinition definition;
  final int score;
}

const _fallbackTheme = _AutoTheme(
  backgroundKind: PresentationBackgroundKind.science,
  keywords: <_AutoKeyword>[],
);

final List<_AutoTheme> _autoThemes = presentationBackgroundLibrary
    .map(
      (definition) => _AutoTheme(
        backgroundKind: definition.kind,
        keywords: definition.tags
            .map((tag) => _AutoKeyword(tag, tag.contains(' ') ? 8 : 6))
            .toList(growable: false),
      ),
    )
    .toList(growable: false);

String _normalize(String value) {
  return PresentationKeywordCatalog.normalize(value);
}
