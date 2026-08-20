import 'dart:math' as math;

class PresentationContentSample {
  const PresentationContentSample({
    required this.title,
    required this.content,
    this.type = 'concept',
    this.purpose,
    this.keywords = const <String>[],
    this.visual,
  });

  final String title;
  final String content;
  final String type;
  final String? purpose;
  final List<String> keywords;
  final Map<String, dynamic>? visual;
}

/// 7 Boyutlu Pedagojik ve Profesyonel Sunum Kalite Değerlendirmesi
class QualityScoreResult {
  final int overallScore;
  final int factualAccuracy;     // Max: 20
  final int audienceFit;          // Max: 20
  final int pedagogicalValue;     // Max: 20
  final int narrativeCoherence;   // Max: 15
  final int redundancy;           // Max: 10
  final int readability;          // Max: 10
  final int visualPotential;      // Max: 5
  final List<Map<String, dynamic>> slideIssues;
  final List<String> globalIssues;
  final bool needsRevision;
  final bool isPass;

  const QualityScoreResult({
    required this.overallScore,
    required this.factualAccuracy,
    required this.audienceFit,
    required this.pedagogicalValue,
    required this.narrativeCoherence,
    required this.redundancy,
    required this.readability,
    required this.visualPotential,
    this.slideIssues = const <Map<String, dynamic>>[],
    this.globalIssues = const <String>[],
    required this.needsRevision,
    required this.isPass,
  });

  @override
  String toString() {
    return 'Overall: $overallScore/100 (Accuracy: $factualAccuracy, Audience: $audienceFit, Pedagogy: $pedagogicalValue, Narrative: $narrativeCoherence, Redundancy: $redundancy, Readability: $readability, Visual: $visualPotential)';
  }
}

/// AI yanıtındaki pedagojik uyumu, hedef kitle doğruluğunu, anlatı akışını,
/// metin yoğunluğunu ve tekrarı ölçen çok boyutlu kalite motoru.
class PresentationContentQuality {
  const PresentationContentQuality._();

  static const List<String> _superficialFluffPhrases = <String>[
    'onemli bir olaydir',
    'onemli bir konudur',
    'bircok etkisi olmustur',
    'buyuk bir oneme sahiptir',
    'etkileri henuz bilinmemektedir',
    'calismalar devam etmektedir',
    'gelismeler devam etmektedir',
    'gelecegi parlak gorunuyor',
    'daha fazla inovasyon ve gelisim bekleniyor',
    'daha hizli, daha guclu, ve daha kucuk',
    'daha hizli daha guclu ve daha kucuk',
  ];

  static const List<String> _metaNarrationPhrases = <String>[
    'bu sunumda',
    'bu slaytta',
    'konuya genel bakis',
    'sunumun izleyecegi',
    'dusunce hatti',
    'kapsam cizgisi',
    'ortak bir ana soruya',
    'ogretim stratejileri',
    'degerlendirme olcutu',
    'ogretmen notu',
    'ders plani',
    'mufredat hedefleri',
    'kazanimlari',
    'drag_handle',
    'surukleme kolu',
    'sahne karti',
    'secili sayfa',
    'mouse ile tut',
    'dusunce asamasi',
    'burada amacimiz',
    'sayfa sirasi aninda',
  ];

  static const List<String> _abstractNonVisualKeywords = <String>[
    'strateji',
    'degerlendirme',
    'tarihce',
    'onem',
    'cikarim',
    'uygulama',
    'surec',
    'analiz',
    'hedef',
    'plan',
    'yontem',
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

  /// İçeriği temiz "- Başlık: Açıklama" formatına normalize eder.
  /// AŞAĞIDAKİ SORUNLARI DÜZELTİR:
  /// - Yıldız karakterlerini temizler (markdown kalıntıları)
  /// - "ve:" gibi bozuk formatlamaları düzeltilir
  /// - Çift noktalama işaretlerini temizler
  /// - Fazla boşlukları kaldırır
  static String normalizeContentBullets(String rawContent) {
    final text = rawContent.trim();
    if (text.isEmpty) return '';

    // 1. Tüm yıldız karakterlerini temizle (markdown kalıntıları)
    // **klima** -> klima
    // **Klima:** -> Klima:
    var cleaned = text
        .replaceAllMapped(RegExp(r'\*{2,}([^*]+?)\*{2,}'), (m) => m[1]!) // **metin** -> metin
        .replaceAllMapped(RegExp(r'\*([^*]+?)\*'), (m) => m[1]!); // *metin* -> metin

    // 2. "ve:" "ve " gibi bozuk formatlamaları düzelt
    cleaned = cleaned
        .replaceAllMapped(RegExp(r'(\w+)\s*:\s*'), (m) => '${m[1]}: ') // "ve:" -> "ve: "
        .replaceAllMapped(RegExp(r'(\w+)\s*:\s*(\w+)'), (m) => '${m[1]}: ${m[2]}') // "ve:nemi" -> "ve: nemi"
        .replaceAll(RegExp(r':\s+:'), ':') // "::" -> ":"
        .replaceAll(RegExp(r'\s+:\s+'), ': '); // çoklu boşluk + : + çoklu boşluk -> ": "

    // 3. Çift noktalama işaretlerini temizle
    cleaned = cleaned
        .replaceAllMapped(RegExp(r'[.,;:!\?]\s*[.,;:!\?]'), (Match m) => m[0]!.trim()) // "..." -> "."
        .replaceAll(RegExp(r'\.\s+\.'), '.')
        .replaceAll(RegExp(r':\s*:'), ':');

    // 4. Eğer tek satırda birden fazla **Başlık:** yapıştırılmışsa böl
    var preprocessed = cleaned.replaceAllMapped(
      RegExp(r'(\S)\s*(\*\*[^*]+:\*\*)'),
      (m) => '${m[1]}\n${m[2]}',
    );

    final lines = preprocessed
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList(growable: false);

    final normalizedLines = <String>[];
    for (final line in lines) {
      var lineCleaned = line.replaceFirst(RegExp(r'^\s*[\-\*\•\d\.\)]+\s*'), '').trim();
      
      // Yıldız temizleme - kalıntıları al
      lineCleaned = lineCleaned.replaceAll(RegExp(r'^\*+|\*+$'), '');
      
      if (lineCleaned.isEmpty) continue;

      // "Başlık: Açıklama" formatını tespit et
      if (RegExp(r'^[^:]+:\s*.+').hasMatch(lineCleaned)) {
        final colonIdx = lineCleaned.indexOf(':');
        final header = lineCleaned.substring(0, colonIdx).trim();
        final body = lineCleaned.substring(colonIdx + 1).trim();
        
        // Header'da hala yıldız varsa temizle
        final cleanHeader = header.replaceAll('*', '').trim();
        final cleanBody = body.replaceAll('*', '').trim();
        
        if (cleanHeader.isNotEmpty && cleanBody.isNotEmpty) {
          normalizedLines.add('- $cleanHeader: $cleanBody');
        } else if (cleanHeader.isNotEmpty) {
          normalizedLines.add('- $cleanHeader');
        } else if (cleanBody.isNotEmpty) {
          normalizedLines.add('- $cleanBody');
        }
      } else if (lineCleaned.contains(':') && !lineCleaned.startsWith('http')) {
        final colonIdx = lineCleaned.indexOf(':');
        final header = lineCleaned.substring(0, colonIdx).replaceAll('*', '').trim();
        final body = lineCleaned.substring(colonIdx + 1).replaceAll('*', '').trim();
        if (header.isNotEmpty && body.isNotEmpty) {
          normalizedLines.add('- $header: $body');
        } else {
          normalizedLines.add('- $lineCleaned');
        }
      } else {
        // Uzun cümleleri bölelim
        if (lineCleaned.length > 80) {
          // Nokta veya virgülle böl (lookbehind unsupported in Dart RegExp) — manual split preserving punctuation
          final sentences = <String>[];
          var rest = lineCleaned;
          final regex = RegExp(r'([.!?])\s+');
          while (true) {
            final m = regex.firstMatch(rest);
            if (m == null) {
              if (rest.trim().isNotEmpty) sentences.add(rest.trim());
              break;
            }
            final endIdx = m.start + 1; // include the punctuation
            final sentence = rest.substring(0, endIdx).trim();
            if (sentence.isNotEmpty) sentences.add(sentence);
            rest = rest.substring(m.end);
          }
          for (final sent in sentences) {
            normalizedLines.add('- ${sent.trim()}');
          }
        } else {
          normalizedLines.add('- $lineCleaned');
        }
      }
    }

    return normalizedLines.isEmpty ? cleaned : normalizedLines.join('\n');
  }

  /// 7 Boyutlu Kalite Değerlendirmesi Yapar (0-100)
  static QualityScoreResult evaluateQuality(
    List<PresentationContentSample> slides, {
    String targetAudience = 'general',
  }) {
    if (slides.isEmpty) {
      return const QualityScoreResult(
        overallScore: 0,
        factualAccuracy: 0,
        audienceFit: 0,
        pedagogicalValue: 0,
        narrativeCoherence: 0,
        redundancy: 0,
        readability: 0,
        visualPotential: 0,
        globalIssues: ['Slayt listesi boş.'],
        needsRevision: false,
        isPass: false,
      );
    }

    var accuracy = 20;
    var audience = 20;
    var pedagogy = 20;
    var narrative = 15;
    var redundancy = 10;
    var readability = 10;
    var visual = 5;

    final slideIssues = <Map<String, dynamic>>[];
    final globalIssues = <String>[];

    // 1. Boş veya eksik slayt denetimi
    for (var i = 0; i < slides.length; i++) {
      final s = slides[i];
      if (s.title.trim().isEmpty || s.content.trim().isEmpty) {
        return const QualityScoreResult(
          overallScore: 0,
          factualAccuracy: 0,
          audienceFit: 0,
          pedagogicalValue: 0,
          narrativeCoherence: 0,
          redundancy: 0,
          readability: 0,
          visualPotential: 0,
          globalIssues: ['Boş başlık veya içerik içeren slayt bulundu.'],
          needsRevision: false,
          isPass: false,
        );
      }
    }

    // 2. Audience Fit (Hedef Kitle ve Müfredat Jargonu Kontrolü) (20p)
    final audienceLower = targetAudience.toLowerCase();
    final isMiddleSchool = audienceLower.contains('ortaokul') || audienceLower.contains('cocuk');

    for (var i = 0; i < slides.length; i++) {
      final s = slides[i];
      final normContent = _normalize(s.content);
      final normTitle = _normalize(s.title);

      for (final meta in _metaNarrationPhrases) {
        if (normContent.contains(meta) || normTitle.contains(meta)) {
          audience = math.max(0, audience - 6);
          slideIssues.add({
            'slide': i + 1,
            'category': 'audience_fit',
            'problem': 'Slayt öğretmen planı/müfredat jargonu içeriyor ($meta).',
          });
          break;
        }
      }

      if (isMiddleSchool) {
        if (normContent.contains('101325') ||
            normContent.contains('pascal') ||
            normContent.contains('q=m') ||
            normContent.contains('10^') ||
            normContent.contains('10⁴')) {
          audience = math.max(0, audience - 5);
          slideIssues.add({
            'slide': i + 1,
            'category': 'audience_fit',
            'problem': 'Ortaokul seviyesi için gereksiz üniversite formülü veya fizik sabiti içeriyor.',
          });
        }
      }
    }

    // 3. Pedagogical Value & Jenerik Dolgu Yasağı (20p)
    for (var i = 0; i < slides.length; i++) {
      final s = slides[i];
      final normContent = _normalize(s.content);
      for (final fluff in _superficialFluffPhrases) {
        if (normContent.contains(fluff)) {
          pedagogy = math.max(0, pedagogy - 5);
          slideIssues.add({
            'slide': i + 1,
            'category': 'pedagogical_value',
            'problem': 'Jenerik dolgu cümlesi tespit edildi ($fluff).',
          });
          break;
        }
      }
      if (s.purpose != null && s.purpose!.trim().isNotEmpty) {
        // Purpose tanımlanmışsa pedagojik değer bonusu
      }
    }

    // 4. Narrative Coherence (Anlatı Akışı ve Tür Çeşitliliği) (15p)
    final uniqueTypes = slides.map((s) => s.type.toLowerCase()).toSet();
    if (slides.length >= 5 && uniqueTypes.length < 2) {
      narrative = math.max(0, narrative - 4);
      globalIssues.add('Bütün slaytlar aynı tek tip şablonla üretilmiş; anlatı monoton.');
    }

    // 5. Redundancy (Tekrar Kontrolü) (10p)
    for (var i = 0; i < slides.length; i++) {
      for (var j = i + 1; j < slides.length; j++) {
        final wordsI = _tokens(slides[i].content);
        final wordsJ = _tokens(slides[j].content);
        final sim = jaccardSimilarity(wordsI, wordsJ);
        if (sim > 0.65) {
          redundancy = math.max(0, redundancy - 5);
          slideIssues.add({
            'slide': j + 1,
            'category': 'redundancy',
            'problem': 'Slayt ${j + 1}, Slayt ${i + 1} ile aşırı benzer içerik taşıyor (Benzerlik: ${(sim * 100).toInt()}%).',
          });
        }
      }
    }

    // 6. Readability & Text Density (Okunabilirlik ve Metin Yoğunluğu) (10p)
    for (var i = 0; i < slides.length; i++) {
      final s = slides[i];
      final wordCount = s.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      if (wordCount < 10) {
        readability = math.max(0, readability - 3);
        slideIssues.add({
          'slide': i + 1,
          'category': 'readability',
          'problem': 'Slayt içeriği çok kısa ($wordCount kelime).',
        });
      } else if (wordCount > 90 && isMiddleSchool) {
        readability = math.max(0, readability - 3);
        slideIssues.add({
          'slide': i + 1,
          'category': 'readability',
          'problem': 'Slayt ortaokul düzeyi için fazla yoğun ($wordCount kelime).',
        });
      }
    }

    // 7. Visual Potential (Görsel ve 3B Model Uyumu) (5p)
    for (var i = 0; i < slides.length; i++) {
      final s = slides[i];
      for (final kw in s.keywords) {
        final normKw = _normalize(kw);
        for (final abs in _abstractNonVisualKeywords) {
          if (normKw.contains(abs)) {
            visual = math.max(0, visual - 1);
            break;
          }
        }
      }
    }

    final totalScore = (accuracy + audience + pedagogy + narrative + redundancy + readability + visual).clamp(0, 100);
    final needsRevision = totalScore >= 75 && totalScore < 85;
    final isPass = totalScore >= 85;

    return QualityScoreResult(
      overallScore: totalScore,
      factualAccuracy: accuracy,
      audienceFit: audience,
      pedagogicalValue: pedagogy,
      narrativeCoherence: narrative,
      redundancy: redundancy,
      readability: readability,
      visualPotential: visual,
      slideIssues: slideIssues,
      globalIssues: globalIssues,
      needsRevision: needsRevision,
      isPass: isPass,
    );
  }

  /// Geriye dönük uyumluluk için statik int kalite skoru.
  static int calculateQualityScore(List<PresentationContentSample> slides) {
    return evaluateQuality(slides).overallScore;
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

    if (normalizedContents.any(
      (content) => _superficialFluffPhrases.any(
        (phrase) => content.contains(_normalize(phrase)),
      ),
    )) {
      return 'Jenerik veya yüzeysel dolgu anlatımı var.';
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

    // 3. Slaytlar arası Jaccard ve kapsama benzerliği denetimi (Jaccard > 0.80)
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
        if (jaccard > 0.80 || containment >= 0.92) {
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
