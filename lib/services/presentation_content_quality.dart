import 'dart:math' as math;

class PresentationContentSample {
  const PresentationContentSample({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

/// AI yanıtındaki boş, aynı veya çok benzer slaytları ikinci sağlayıcıya
/// geçmeden önce yakalayan hafif, deterministik kalite kontrolü.
class PresentationContentQuality {
  const PresentationContentQuality._();

  static const List<String> _metaNarrationPhrases = <String>[
    'bu sunumda',
    'bu slaytta',
    'konuya genel bakış',
    'sunumun izleyeceği',
    'düşünce hattı',
    'kapsam çizgisi',
    'ortak bir ana soruya',
    'drag_handle',
    'sürükleme kolu',
    'sahne kartı',
    'seçili sayfa',
    'mouse ile tut',
    'düşünce aşaması',
    'burada amacımız',
    'sayfa sırası anında',
  ];

  static const Set<String> _stopWords = <String>{
    'ama',
    'ancak',
    'bir',
    'bu',
    'da',
    'daha',
    'de',
    'en',
    'gibi',
    'icin',
    'ile',
    'olan',
    'olarak',
    've',
    'veya',
    'the',
    'and',
    'for',
    'from',
    'that',
    'this',
    'with',
  };

  /// Slayt başlıklarındaki "Slayt 1:", "Slide 2 -" vb. gereksiz önekleri temizler.
  static String sanitizeTitle(String title) {
    return title
        .replaceFirst(
          RegExp(r'^(?:slayt|slide)\s*\d+[\s:\-–—]*', caseSensitive: false),
          '',
        )
        .trim();
  }

  /// İki kelime kümesi arasındaki Jaccard benzerliğini hesaplar (0.0 ile 1.0 arası).
  static double jaccardSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return intersection / union;
  }

  /// `null` kaliteli içerik, aksi halde sağlayıcıyı reddetme nedenidir.
  static String? rejectionReason(List<PresentationContentSample> slides) {
    if (slides.isEmpty) return 'Slayt listesi boş.';
    if (slides.any(
      (slide) => slide.title.trim().isEmpty || slide.content.trim().isEmpty,
    )) {
      return 'Boş başlık veya içerik var.';
    }

    final slidePrefixRegex =
        RegExp(r'^(?:slayt|slide)\s*\d+[\s:\-–—]', caseSensitive: false);
    if (slides.any((slide) => slidePrefixRegex.hasMatch(slide.title.trim()))) {
      return 'Başlıkta gereksiz "Slayt N:" öneki var.';
    }

    final normalizedContents = slides
        .map((slide) => _normalize(slide.content))
        .toList(growable: false);
    if (normalizedContents.any(
      (content) => _metaNarrationPhrases.any(
        (phrase) => content.contains(_normalize(phrase)),
      ),
    )) {
      return 'Konu bilgisi yerine sunum planını anlatan üst-anlatı var.';
    }

    final genericFluffRegex = RegExp(
      r'(?:gelecegi\s+parlak\s+gorunuyor|daha\s+fazla\s+inovasyon\s+ve\s+gelisim\s+bekleniyor|daha\s+hizli\s*,?\s*daha\s+guclu\s*,?\s*ve\s+daha\s+kucuk)',
      caseSensitive: false,
    );
    if (normalizedContents.any((content) => genericFluffRegex.hasMatch(content))) {
      return 'Jenerik/boş anlatım var.';
    }

    // 1. İçerik doluluk denetimi: Her slaytta anlamlı bir metin/madde olmalı
    for (final slide in slides) {
      final bullets = slide.content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
      if (bullets.isEmpty || slide.content.trim().length < 10) {
        return 'Yetersiz içerik: Slayt içeriği boş veya çok kısa.';
      }
    }

    // 2. Döngüsel / totolojik içerik denetimi
    for (final slide in slides) {
      if (_isTautological(slide.title, slide.content)) {
        return 'Döngüsel/totolojik içerik var.';
      }
    }

    if (slides.length <= 2) return null;

    final allowedRepeats = math.max(1, slides.length ~/ 10);
    final seenTitles = <String>{};
    var repeatedTitles = 0;
    for (final slide in slides) {
      if (!seenTitles.add(_normalize(slide.title))) repeatedTitles += 1;
    }
    if (repeatedTitles > allowedRepeats) {
      return 'Çok sayıda aynı başlık var.';
    }

    // 2b. Robotik kalıp denetimi ("Tanım / Amaç / Fark / Örnek" gibi kalıpların sürekli tekrarı)
    var roboticPatternSlides = 0;
    for (final slide in slides) {
      final content = _normalize(slide.content);
      if (content.contains('tanim:') && content.contains('amac:') && (content.contains('ornek:') || content.contains('fark:'))) {
        roboticPatternSlides += 1;
      }
    }
    if (slides.length >= 4 && roboticPatternSlides >= (slides.length + 1) ~/ 2) {
      return 'Monoton ve robotik "Tanım / Amaç / Örnek" şablonu tekrar ediyor.';
    }

    // 2c. Kuru kronoloji / salt tarih listesi denetimi (Tüm sunumun yalnızca kuru tarihlerden oluşması)
    var dateBulletCount = 0;
    var totalBulletCount = 0;
    final dateBulletRegex = RegExp(
      r'^\s*-\s*\*{0,2}\d{1,2}\s+(?:ocak|subat|mart|nisan|mayis|haziran|temmuz|agustos|eylul|ekim|kasim|aralik|\d{4})[\s:\*–—]',
      caseSensitive: false,
    );
    for (final slide in slides) {
      for (final line in slide.content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) {
          totalBulletCount += 1;
          if (dateBulletRegex.hasMatch(_normalize(trimmed))) {
            dateBulletCount += 1;
          }
        }
      }
    }
    if (slides.length >= 6 && totalBulletCount > 0 && (dateBulletCount / totalBulletCount) >= 0.85) {
      return 'Sunum anlatı yerine baştan sona monoton tarih listesine dönüşmüş.';
    }

    // 3. Slaytlar arası Jaccard ve kapsama benzerliği denetimi (Jaccard > 0.60)
    final tokenSets = slides.map((slide) => _tokens(slide.content)).toList();
    final stemmedSets =
        slides.map((slide) => _stemmedTokens(slide.content)).toList();

    var nearDuplicateSlides = 0;
    for (var i = 1; i < tokenSets.length; i += 1) {
      final currentTokens = tokenSets[i];
      final currentStemmed = stemmedSets[i];
      var isDuplicate = false;
      for (var j = 0; j < i; j += 1) {
        final jaccard = jaccardSimilarity(currentStemmed, stemmedSets[j]);
        final containment =
            _containmentSimilarity(currentTokens, tokenSets[j]);
        if (jaccard > 0.60 || containment >= 0.82) {
          isDuplicate = true;
          break;
        }
      }
      if (isDuplicate) nearDuplicateSlides += 1;
    }
    if (nearDuplicateSlides > allowedRepeats) {
      return 'Slaytlar arası aşırı tekrar var.';
    }

    final seenBullets = <String>{};
    var repeatedBullets = 0;
    for (final slide in slides) {
      for (final line in slide.content.split('\n')) {
        final bullet = _normalize(line.replaceFirst(RegExp(r'^\s*-\s*'), ''));
        if (bullet.length < 18) continue;
        if (!seenBullets.add(bullet)) repeatedBullets += 1;
      }
    }
    if (repeatedBullets > allowedRepeats) {
      return 'Aynı maddeler birden fazla slaytta tekrarlanıyor.';
    }
    return null;
  }

  static bool _isTautological(String title, String content) {
    final normContent = _normalize(content);

    if (RegExp(
              r'gelisimiyle\s+(?:teknolojik\s+)?gelismeler\s+(?:daha\s+da\s+)?hizlandi',
              caseSensitive: false,
            ).hasMatch(normContent) ||
        RegExp(r'gelisimiyle\s+.*?gelisti', caseSensitive: false)
            .hasMatch(normContent) ||
        RegExp(r'etkileri\s+henuz\s+bilinmemektedir', caseSensitive: false)
            .hasMatch(normContent)) {
      return true;
    }

    final titleTokens = _tokens(title);
    if (titleTokens.isNotEmpty) {
      final contentTokens = _tokens(content);
      final newTokensInContent = contentTokens.difference(titleTokens);
      if (newTokensInContent.length < 3) {
        return true;
      }
    }
    return false;
  }

  static Set<String> _tokens(String text) => RegExp(r'[a-zçğıöşü0-9]+')
      .allMatches(_normalize(text))
      .map((match) => match.group(0)!)
      .where((word) => word.length >= 3 && !_stopWords.contains(word))
      .toSet();

  static Set<String> _stemmedTokens(String text) {
    return _tokens(text).map((word) {
      if (word.length > 5) return word.substring(0, 5);
      return word;
    }).toSet();
  }

  static double _containmentSimilarity(Set<String> a, Set<String> b) {
    if (a.length < 5 || b.length < 5) return 0;
    final smaller = math.min(a.length, b.length);
    return a.intersection(b).length / smaller;
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
