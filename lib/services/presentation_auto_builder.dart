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
  astronomi,
  beslenme,
  biyoloji,
  cevre,
  cografya,
  deniz,
  dijital,
  doga,
  edebiyat,
  egitim,
  ekoloji,
  enerji,
  evcilHayvan,
  felsefe,
  fizik,
  fotograf,
  futuristik,
  gastronomi,
  girisimcilik,
  havacilik,
  hukuk,
  isHayati,
  kimya,
  liderlik,
  matematik,
  meteoroloji,
  mitoloji,
  moda,
  muhendislik,
  muzik,
  oyun,
  optik,
  pazarlama,
  psikoloji,
  robotik,
  saglik,
  sanat,
  sehir,
  seyahat,
  sinema,
  spor,
  tarih,
  tip,
  tiyatro,
  toplum,
  ulasim,
  uzay,
  vintage,
  yapayZeka,
  yazilim,
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
    case PresentationTemplate.astronomi:
      return 'Astronomi';
    case PresentationTemplate.beslenme:
      return 'Beslenme';
    case PresentationTemplate.biyoloji:
      return 'Biyoloji';
    case PresentationTemplate.cevre:
      return 'Çevre';
    case PresentationTemplate.cografya:
      return 'Coğrafya';
    case PresentationTemplate.deniz:
      return 'Deniz';
    case PresentationTemplate.dijital:
      return 'Dijital';
    case PresentationTemplate.doga:
      return 'Doğa';
    case PresentationTemplate.edebiyat:
      return 'Edebiyat';
    case PresentationTemplate.egitim:
      return 'Eğitim';
    case PresentationTemplate.ekoloji:
      return 'Ekoloji';
    case PresentationTemplate.enerji:
      return 'Enerji';
    case PresentationTemplate.evcilHayvan:
      return 'Evcil Hayvan';
    case PresentationTemplate.felsefe:
      return 'Felsefe';
    case PresentationTemplate.fizik:
      return 'Fizik';
    case PresentationTemplate.fotograf:
      return 'Fotoğraf';
    case PresentationTemplate.futuristik:
      return 'Fütüristik';
    case PresentationTemplate.gastronomi:
      return 'Gastronomi';
    case PresentationTemplate.girisimcilik:
      return 'Girişimcilik';
    case PresentationTemplate.havacilik:
      return 'Havacılık';
    case PresentationTemplate.hukuk:
      return 'Hukuk';
    case PresentationTemplate.isHayati:
      return 'İş Hayatı';
    case PresentationTemplate.kimya:
      return 'Kimya';
    case PresentationTemplate.liderlik:
      return 'Liderlik';
    case PresentationTemplate.matematik:
      return 'Matematik';
    case PresentationTemplate.meteoroloji:
      return 'Meteoroloji';
    case PresentationTemplate.mitoloji:
      return 'Mitoloji';
    case PresentationTemplate.moda:
      return 'Moda';
    case PresentationTemplate.muhendislik:
      return 'Mühendislik';
    case PresentationTemplate.muzik:
      return 'Müzik';
    case PresentationTemplate.oyun:
      return 'Oyun';
    case PresentationTemplate.optik:
      return 'Optik';
    case PresentationTemplate.pazarlama:
      return 'Pazarlama';
    case PresentationTemplate.psikoloji:
      return 'Psikoloji';
    case PresentationTemplate.robotik:
      return 'Robotik';
    case PresentationTemplate.saglik:
      return 'Sağlık';
    case PresentationTemplate.sanat:
      return 'Sanat';
    case PresentationTemplate.sehir:
      return 'Şehir';
    case PresentationTemplate.seyahat:
      return 'Seyahat';
    case PresentationTemplate.sinema:
      return 'Sinema';
    case PresentationTemplate.spor:
      return 'Spor';
    case PresentationTemplate.tarih:
      return 'Tarih';
    case PresentationTemplate.tip:
      return 'Tıp';
    case PresentationTemplate.tiyatro:
      return 'Tiyatro';
    case PresentationTemplate.toplum:
      return 'Toplum';
    case PresentationTemplate.ulasim:
      return 'Ulaşım';
    case PresentationTemplate.uzay:
      return 'Uzay';
    case PresentationTemplate.vintage:
      return 'Vintage';
    case PresentationTemplate.yapayZeka:
      return 'Yapay Zeka';
    case PresentationTemplate.yazilim:
      return 'Yazılım';
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
    case PresentationTemplate.astronomi:
      return 'Uzay ve gök bilimi odaklı dramatik sunum';
    case PresentationTemplate.beslenme:
      return 'Sağlıklı yaşam ve beslenme odaklı doğal tasarım';
    case PresentationTemplate.biyoloji:
      return 'Canlı bilimi ve genetik odaklı modern görünüm';
    case PresentationTemplate.cevre:
      return 'Çevre bilinci ve sürdürülebilirlik temalı';
    case PresentationTemplate.cografya:
      return 'Coğrafi keşif ve harita odaklı düzen';
    case PresentationTemplate.deniz:
      return 'Deniz ve okyanus temalı akıcı sahne';
    case PresentationTemplate.dijital:
      return 'Modern dijital dönüşüm ve teknoloji odaklı';
    case PresentationTemplate.doga:
      return 'Doğal güzellikler ve organik yaşam temalı';
    case PresentationTemplate.edebiyat:
      return 'Edebi metin ve şiir odaklı zarif düzen';
    case PresentationTemplate.egitim:
      return 'Ders ve akademik içerik için temiz tasarım';
    case PresentationTemplate.ekoloji:
      return 'Ekosistem ve biyolojik çeşitlilik odaklı';
    case PresentationTemplate.enerji:
      return 'Yenilenebilir enerji ve güç sistemleri temalı';
    case PresentationTemplate.evcilHayvan:
      return 'Hayvan dostu sıcak ve samimi sunum';
    case PresentationTemplate.felsefe:
      return 'Derin düşünce ve felsefi sorgulama odaklı';
    case PresentationTemplate.fizik:
      return 'Fizik yasaları ve mekanik odaklı bilimsel düzen';
    case PresentationTemplate.fotograf:
      return 'Görsel sanatlar ve fotoğrafçılık odaklı yaratıcı sahne';
    case PresentationTemplate.futuristik:
      return 'Gelecek teknolojileri ve yenilikçi vizyon temalı';
    case PresentationTemplate.gastronomi:
      return 'Yemek kültürü ve mutfak sanatları odaklı sıcak düzen';
    case PresentationTemplate.girisimcilik:
      return 'Startup ve yenilikçi iş fikirleri için dinamik tasarım';
    case PresentationTemplate.havacilik:
      return 'Havacılık ve uzay mühendisliği odaklı teknik görünüm';
    case PresentationTemplate.hukuk:
      return 'Adalet ve hukuk sistemi odaklı resmi düzen';
    case PresentationTemplate.isHayati:
      return 'Profesyonel iş dünyası ve yönetici sunumları';
    case PresentationTemplate.kimya:
      return 'Kimyasal reaksiyonlar ve laboratuvar odaklı tasarım';
    case PresentationTemplate.liderlik:
      return 'Güçlü liderlik ve vizyoner yönetim temalı';
    case PresentationTemplate.matematik:
      return 'Matematiksel düşünce ve geometri odaklı düzen';
    case PresentationTemplate.meteoroloji:
      return 'Hava durumu ve iklim bilimi odaklı dinamik sahne';
    case PresentationTemplate.mitoloji:
      return 'Antik mitler ve fantastik hikayeler odaklı epik düzen';
    case PresentationTemplate.moda:
      return 'Moda ve stil odaklı yaratıcı görsel düzen';
    case PresentationTemplate.muhendislik:
      return 'Mühendislik ve teknik projeler için modern tasarım';
    case PresentationTemplate.muzik:
      return 'Müzik ve ritim odaklı enerjik sunum';
    case PresentationTemplate.oyun:
      return 'Oyun ve eğlence odaklı renkli dinamik düzen';
    case PresentationTemplate.optik:
      return 'Işık ve optik bilimi odaklı parlak görünüm';
    case PresentationTemplate.pazarlama:
      return 'Pazarlama stratejileri ve marka odaklı düzen';
    case PresentationTemplate.psikoloji:
      return 'İnsan zihni ve davranış bilimi odaklı sakin düzen';
    case PresentationTemplate.robotik:
      return 'Robot teknolojisi ve otomasyon odaklı futuristik sahne';
    case PresentationTemplate.saglik:
      return 'Sağlık hizmetleri ve tıbbi içerik için temiz tasarım';
    case PresentationTemplate.sanat:
      return 'Sanat ve yaratıcı ifade odaklı özgür düzen';
    case PresentationTemplate.sehir:
      return 'Kentsel yaşam ve şehir planlaması odaklı modern düzen';
    case PresentationTemplate.seyahat:
      return 'Seyahat ve turizm odaklı keşif temalı sunum';
    case PresentationTemplate.sinema:
      return 'Film ve sinema sanatı odaklı dramatik düzen';
    case PresentationTemplate.spor:
      return 'Spor ve atletizm odaklı dinamik enerjik sunum';
    case PresentationTemplate.tarih:
      return 'Tarihsel olaylar ve medeniyetler odaklı klasik düzen';
    case PresentationTemplate.tip:
      return 'Tıp ve klinik bilimler odaklı güvenilir tasarım';
    case PresentationTemplate.tiyatro:
      return 'Sahne sanatları ve dramatik anlatım odaklı düzen';
    case PresentationTemplate.toplum:
      return 'Sosyal bilimler ve toplumsal konular odaklı düzen';
    case PresentationTemplate.ulasim:
      return 'Ulaşım ve lojistik odaklı teknik endüstriyel görünüm';
    case PresentationTemplate.uzay:
      return 'Uzay keşfi ve astronot odaklı görkemli sunum';
    case PresentationTemplate.vintage:
      return 'Geçmiş dönem estetiği ve retro odaklı sıcak düzen';
    case PresentationTemplate.yapayZeka:
      return 'Yapay zeka ve makine öğrenmesi odaklı teknoloji sahnesi';
    case PresentationTemplate.yazilim:
      return 'Yazılım geliştirme ve programlama odaklı modern düzen';
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
            fontSize:
                (_titleFontSize(title, titleOnly: titleOnly) * config.fontScale)
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

final Map<PresentationTemplate, PresentationPage> _templatePreviewPageCache =
    <PresentationTemplate, PresentationPage>{};

PresentationPage presentationTemplatePreviewPage(
  PresentationTemplate template,
) {
  assert(template != PresentationTemplate.automatic);
  return _templatePreviewPageCache.putIfAbsent(template, () {
    final pages = const PresentationAutoBuilder().buildPages(
      <PresentationDraftPage>[
        PresentationDraftPage(
          title: 'Yeni Bir Bakış',
          body: 'Fikirleri güçlü ve anlaşılır bir hikâyeye dönüştürün.',
        ),
      ],
      template: template,
    );
    return pages.single.copyWith(id: 'template-preview-${template.name}');
  });
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
    case PresentationTemplate.astronomi:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.beslenme:
      return PresentationBackgroundKind.lightNature;
    case PresentationTemplate.biyoloji:
      return PresentationBackgroundKind.biology;
    case PresentationTemplate.cevre:
      return PresentationBackgroundKind.natureEcology;
    case PresentationTemplate.cografya:
      return PresentationBackgroundKind.travelGeography;
    case PresentationTemplate.deniz:
      return PresentationBackgroundKind.travelGeography;
    case PresentationTemplate.dijital:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.doga:
      return PresentationBackgroundKind.natureEcology;
    case PresentationTemplate.edebiyat:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.egitim:
      return PresentationBackgroundKind.lightEducation;
    case PresentationTemplate.ekoloji:
      return PresentationBackgroundKind.natureEcology;
    case PresentationTemplate.enerji:
      return PresentationBackgroundKind.solarEnergyScene;
    case PresentationTemplate.evcilHayvan:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.felsefe:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.fizik:
      return PresentationBackgroundKind.physics;
    case PresentationTemplate.fotograf:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.futuristik:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.gastronomi:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.girisimcilik:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.havacilik:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.hukuk:
      return PresentationBackgroundKind.lawJustice;
    case PresentationTemplate.isHayati:
      return PresentationBackgroundKind.businessFinance;
    case PresentationTemplate.kimya:
      return PresentationBackgroundKind.chemistry;
    case PresentationTemplate.liderlik:
      return PresentationBackgroundKind.businessFinance;
    case PresentationTemplate.matematik:
      return PresentationBackgroundKind.mathematics;
    case PresentationTemplate.meteoroloji:
      return PresentationBackgroundKind.climateWeather;
    case PresentationTemplate.mitoloji:
      return PresentationBackgroundKind.historyArchaeology;
    case PresentationTemplate.moda:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.muhendislik:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.muzik:
      return PresentationBackgroundKind.musicSound;
    case PresentationTemplate.oyun:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.optik:
      return PresentationBackgroundKind.optics;
    case PresentationTemplate.pazarlama:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.psikoloji:
      return PresentationBackgroundKind.healthMedicine;
    case PresentationTemplate.robotik:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.saglik:
      return PresentationBackgroundKind.healthMedicine;
    case PresentationTemplate.sanat:
      return PresentationBackgroundKind.artDesign;
    case PresentationTemplate.sehir:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.seyahat:
      return PresentationBackgroundKind.travelGeography;
    case PresentationTemplate.sinema:
      return PresentationBackgroundKind.artDesign;
    case PresentationTemplate.spor:
      return PresentationBackgroundKind.sportsMovement;
    case PresentationTemplate.tarih:
      return PresentationBackgroundKind.historyArchaeology;
    case PresentationTemplate.tip:
      return PresentationBackgroundKind.healthMedicine;
    case PresentationTemplate.tiyatro:
      return PresentationBackgroundKind.artDesign;
    case PresentationTemplate.toplum:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.ulasim:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.uzay:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.vintage:
      return PresentationBackgroundKind.historyArchaeology;
    case PresentationTemplate.yapayZeka:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.yazilim:
      return PresentationBackgroundKind.lightTechnology;
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
    case PresentationTemplate.astronomi:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.uzayDramatik,
        bodyTextStyle: PresentationTextStyle.uzayTemiz,
        titleTextAnimation: PresentationTextAnimation.uzayDramatik,
        bodyTextAnimation: PresentationTextAnimation.uzayDeneysel,
        titleTextColor: '#6C63FF',
        bodyTextColor: '#9D8FFF',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.astronomi01,
          PresentationComponentKind.astronomi02,
        ],
        glowIntensity: 0.7,
        fontScale: 1.0,
      );
    case PresentationTemplate.beslenme:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightNature,
        titleTextStyle: PresentationTextStyle.gunesTemiz,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2E7D32',
        bodyTextColor: '#4CAF50',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.tarimGida01,
          PresentationComponentKind.tarimGida02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.biyoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.biology,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#06D6A0',
        bodyTextColor: '#00B894',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.biyoloji01,
          PresentationComponentKind.biyoloji02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.cevre:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.natureEcology,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimTemiz,
        bodyTextAnimation: PresentationTextAnimation.gunesTemiz,
        titleTextColor: '#74C69D',
        bodyTextColor: '#52B788',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.cevreDoga01,
          PresentationComponentKind.cevreDoga02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.cografya:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.travelGeography,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#4CC9F0',
        bodyTextColor: '#00B4D8',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.cografya01,
          PresentationComponentKind.cografya02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.deniz:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.travelGeography,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.siviDalga,
        bodyTextAnimation: PresentationTextAnimation.yercekimsizSuzulme,
        titleTextColor: '#0077B6',
        bodyTextColor: '#0096C7',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.turizmSeyahat01,
          PresentationComponentKind.turizmSeyahat02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.dijital:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDeneysel,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#22A6B3',
        bodyTextColor: '#38B2AC',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji01,
          PresentationComponentKind.teknoloji02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.05,
      );
    case PresentationTemplate.doga:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.natureEcology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2D6A4F',
        bodyTextColor: '#40916C',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.cevreDoga03,
          PresentationComponentKind.cevreDoga04,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.edebiyat:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#6B4226',
        bodyTextColor: '#8D6E63',
        transitionKind: PresentationTransitionKind.none,
        transitionDurationMs: 400,
        componentKinds: [
          PresentationComponentKind.edebiyat01,
          PresentationComponentKind.edebiyat02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.05,
      );
    case PresentationTemplate.egitim:
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
    case PresentationTemplate.ekoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.natureEcology,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.bilimTemiz,
        titleTextColor: '#1B4332',
        bodyTextColor: '#2D6A4F',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.cevreDoga05,
          PresentationComponentKind.cevreDoga06,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.enerji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.solarEnergyScene,
        titleTextStyle: PresentationTextStyle.gunesDramatik,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesDramatik,
        bodyTextAnimation: PresentationTextAnimation.gunesDeneysel,
        titleTextColor: '#FFD166',
        bodyTextColor: '#FFB703',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.enerjiAltyapisi01,
          PresentationComponentKind.enerjiAltyapisi02,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.evcilHayvan:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openCaveat,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#E07A5F',
        bodyTextColor: '#F4A261',
        transitionKind: PresentationTransitionKind.none,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.evcilHayvanlar01,
          PresentationComponentKind.evcilHayvanlar02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.0,
      );
    case PresentationTemplate.felsefe:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#3D405B',
        bodyTextColor: '#5C5E7D',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.felsefeDin01,
          PresentationComponentKind.felsefeDin02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.fizik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.physics,
        titleTextStyle: PresentationTextStyle.fizikDramatik,
        bodyTextStyle: PresentationTextStyle.fizikTemiz,
        titleTextAnimation: PresentationTextAnimation.fizikDramatik,
        bodyTextAnimation: PresentationTextAnimation.fizikDeneysel,
        titleTextColor: '#7C90B0',
        bodyTextColor: '#A0B4D0',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.fizik01,
          PresentationComponentKind.fizik02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.fotograf:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#B15CDE',
        bodyTextColor: '#C77DFF',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.fotografcilik01,
          PresentationComponentKind.fotografcilik02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.05,
      );
    case PresentationTemplate.futuristik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiDeneysel,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#00B4D8',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.teknoloji03,
          PresentationComponentKind.teknoloji04,
        ],
        glowIntensity: 1.2,
        fontScale: 1.1,
      );
    case PresentationTemplate.gastronomi:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.siviDalga,
        titleTextColor: '#D62828',
        bodyTextColor: '#E76F51',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.gastronomi01,
          PresentationComponentKind.gastronomi02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.05,
      );
    case PresentationTemplate.girisimcilik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#0D47A1',
        bodyTextColor: '#1565C0',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.genelSunumIs01,
          PresentationComponentKind.genelSunumIs02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.1,
      );
    case PresentationTemplate.havacilik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#6C63FF',
        bodyTextColor: '#8B83FF',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.havacilik01,
          PresentationComponentKind.havacilik02,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.hukuk:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lawJustice,
        titleTextStyle: PresentationTextStyle.standard,
        bodyTextStyle: PresentationTextStyle.standard,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#D4AF37',
        bodyTextColor: '#C5A035',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.hukuk01,
          PresentationComponentKind.hukuk02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.isHayati:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.businessFinance,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
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
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.kimya:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.chemistry,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDeneysel,
        bodyTextAnimation: PresentationTextAnimation.bilimTemiz,
        titleTextColor: '#62D2A2',
        bodyTextColor: '#4ECB71',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.kimya01,
          PresentationComponentKind.kimya02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.liderlik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.businessFinance,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.metalikParlama,
        bodyTextAnimation: PresentationTextAnimation.perdeAcilisi,
        titleTextColor: '#FFD600',
        bodyTextColor: '#FFC107',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.genelSunumIs03,
          PresentationComponentKind.genelSunumIs04,
        ],
        glowIntensity: 0.7,
        fontScale: 1.1,
      );
    case PresentationTemplate.matematik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.mathematics,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.bilimTemiz,
        titleTextColor: '#9B5DE5',
        bodyTextColor: '#B47CFF',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.matematik01,
          PresentationComponentKind.matematik02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.meteoroloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.climateWeather,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesDramatik,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#6DD5FA',
        bodyTextColor: '#4CC9F0',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.meteoroloji01,
          PresentationComponentKind.meteoroloji02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.mitoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.historyArchaeology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#D4A373',
        bodyTextColor: '#C18F5B',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.mitolojiFantastik01,
          PresentationComponentKind.mitolojiFantastik02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.moda:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openUnbounded,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.neonKontur,
        titleTextColor: '#FF70A6',
        bodyTextColor: '#FF85B3',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.moda01,
          PresentationComponentKind.moda02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.1,
      );
    case PresentationTemplate.muhendislik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#4DD0E1',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.muhendislik01,
          PresentationComponentKind.muhendislik02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.muzik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.musicSound,
        titleTextStyle: PresentationTextStyle.openUnbounded,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.siviDalga,
        bodyTextAnimation: PresentationTextAnimation.kesikSinyal,
        titleTextColor: '#F15BB5',
        bodyTextColor: '#F72585',
        transitionKind: PresentationTransitionKind.concave,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.muzik01,
          PresentationComponentKind.muzik02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.oyun:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openUnbounded,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.ucBoyutluDonus,
        titleTextColor: '#FF595E',
        bodyTextColor: '#FF6B6B',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.oyun01,
          PresentationComponentKind.oyun02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.1,
      );
    case PresentationTemplate.optik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.optics,
        titleTextStyle: PresentationTextStyle.optikDramatik,
        bodyTextStyle: PresentationTextStyle.optikTemiz,
        titleTextAnimation: PresentationTextAnimation.optikDramatik,
        bodyTextAnimation: PresentationTextAnimation.optikDeneysel,
        titleTextColor: '#7EFFF5',
        bodyTextColor: '#5EEAD4',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.fizik03,
          PresentationComponentKind.fizik04,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.pazarlama:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#E91E63',
        bodyTextColor: '#F06292',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.ekonomiIsFinans03,
          PresentationComponentKind.ekonomiIsFinans04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.05,
      );
    case PresentationTemplate.psikoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.healthMedicine,
        titleTextStyle: PresentationTextStyle.gunesTemiz,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesDeneysel,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2EC4B6',
        bodyTextColor: '#3DD6C8',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.psikoloji01,
          PresentationComponentKind.psikoloji02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.robotik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiDeneysel,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.kesikSinyal,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#00BCD4',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.muhendislik03,
          PresentationComponentKind.muhendislik04,
        ],
        glowIntensity: 0.8,
        fontScale: 1.05,
      );
    case PresentationTemplate.saglik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.healthMedicine,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#2EC4B6',
        bodyTextColor: '#4DD0C8',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.saglik01,
          PresentationComponentKind.saglik02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.sanat:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.artDesign,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.gunesDramatik,
        bodyTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        titleTextColor: '#FF70A6',
        bodyTextColor: '#FF8EB8',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.sanat01,
          PresentationComponentKind.sanat02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.05,
      );
    case PresentationTemplate.sehir:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#22A6B3',
        bodyTextColor: '#38B2AC',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.sehirKentsel01,
          PresentationComponentKind.sehirKentsel02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.seyahat:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.travelGeography,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        titleTextColor: '#4CC9F0',
        bodyTextColor: '#00B4D8',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.turizmSeyahat03,
          PresentationComponentKind.turizmSeyahat04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.sinema:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.artDesign,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.perdeAcilisi,
        titleTextColor: '#FFD600',
        bodyTextColor: '#FFC107',
        transitionKind: PresentationTransitionKind.cover,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.sinemaFilm01,
          PresentationComponentKind.sinemaFilm02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.spor:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.sportsMovement,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.ucBoyutluDonus,
        bodyTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        titleTextColor: '#FF595E',
        bodyTextColor: '#FF6B6B',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.spor01,
          PresentationComponentKind.spor02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.05,
      );
    case PresentationTemplate.tarih:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.historyArchaeology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#D4A373',
        bodyTextColor: '#C18F5B',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.tarih01,
          PresentationComponentKind.tarih02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.tip:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.healthMedicine,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2EC4B6',
        bodyTextColor: '#48C9B0',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.saglik03,
          PresentationComponentKind.saglik04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.tiyatro:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.artDesign,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        titleTextColor: '#E91E63',
        bodyTextColor: '#F06292',
        transitionKind: PresentationTransitionKind.cover,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.sinemaFilm03,
          PresentationComponentKind.sinemaFilm04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.toplum:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#5D4037',
        bodyTextColor: '#795548',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.toplum01,
          PresentationComponentKind.toplum02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.0,
      );
    case PresentationTemplate.ulasim:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#1565C0',
        bodyTextColor: '#1976D2',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.ulasimLojistik01,
          PresentationComponentKind.ulasimLojistik02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.uzay:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.uzayDramatik,
        bodyTextStyle: PresentationTextStyle.uzayTemiz,
        titleTextAnimation: PresentationTextAnimation.uzayDramatik,
        bodyTextAnimation: PresentationTextAnimation.uzayDeneysel,
        titleTextColor: '#6C63FF',
        bodyTextColor: '#8580FF',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.astronomi03,
          PresentationComponentKind.astronomi04,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.vintage:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.historyArchaeology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.daktilo,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#8B7355',
        bodyTextColor: '#A08860',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.tarih03,
          PresentationComponentKind.tarih04,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.yapayZeka:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiDeneysel,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#4DD0E1',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.teknoloji05,
          PresentationComponentKind.teknoloji06,
        ],
        glowIntensity: 1.0,
        fontScale: 1.05,
      );
    case PresentationTemplate.yazilim:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDeneysel,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.kesikSinyal,
        titleTextColor: '#22A6B3',
        bodyTextColor: '#38B2AC',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji07,
          PresentationComponentKind.teknoloji08,
        ],
        glowIntensity: 0.5,
        fontScale: 1.05,
      );
  }
}

List<String> _splitText(String text, int maxCharacters) {
  final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  final chunks = <String>[];
  var current = StringBuffer();
  for (final word in words) {
    final nextLength =
        current.length == 0 ? word.length : current.length + word.length + 1;
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
