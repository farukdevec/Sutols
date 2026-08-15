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

  /// `null` kaliteli içerik, aksi halde sağlayıcıyı reddetme nedenidir.
  static String? rejectionReason(List<PresentationContentSample> slides) {
    if (slides.isEmpty) return 'Slayt listesi boş.';
    if (slides.any(
      (slide) => slide.title.trim().isEmpty || slide.content.trim().isEmpty,
    )) {
      return 'Boş başlık veya içerik var.';
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

    final tokenSets = slides.map((slide) => _tokens(slide.content)).toList();
    var nearDuplicateSlides = 0;
    for (var i = 1; i < tokenSets.length; i += 1) {
      final current = tokenSets[i];
      final duplicatesEarlier = <int>[];
      for (var j = 0; j < i; j += 1) {
        if (_containmentSimilarity(current, tokenSets[j]) >= 0.82) {
          duplicatesEarlier.add(j);
        }
      }
      if (duplicatesEarlier.isNotEmpty) nearDuplicateSlides += 1;
    }
    if (nearDuplicateSlides > allowedRepeats) {
      return 'Slayt içerikleri birbirine aşırı benziyor.';
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

  static Set<String> _tokens(String text) => RegExp(r'[a-zçğıöşü0-9]+')
      .allMatches(_normalize(text))
      .map((match) => match.group(0)!)
      .where((word) => word.length >= 3 && !_stopWords.contains(word))
      .toSet();

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
