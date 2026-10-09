import '../models/development_features.dart';

class PresentationKeywordCatalog {
  const PresentationKeywordCatalog._();

  static String normalize(String value) {
    return value
        .replaceAll('İ', 'I')
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static List<String> words(String normalizedText) {
    final words = <String>[];
    var wordStart = -1;
    for (var index = 0; index <= normalizedText.length; index += 1) {
      final isWordCharacter = index < normalizedText.length &&
          ((normalizedText.codeUnitAt(index) >= 0x61 &&
                  normalizedText.codeUnitAt(index) <= 0x7A) ||
              (normalizedText.codeUnitAt(index) >= 0x30 &&
                  normalizedText.codeUnitAt(index) <= 0x39));
      if (isWordCharacter) {
        if (wordStart < 0) wordStart = index;
      } else if (wordStart >= 0) {
        words.add(normalizedText.substring(wordStart, index));
        wordStart = -1;
      }
    }
    return words.toList(growable: false);
  }

  /// Sunum metinlerinde sık geçen ama HİÇBİR modele özgü olmayan, ayırt
  /// edicilik gücü ~0 olan "jenerik/dolgu" kelimeler.
  ///
  /// Bu liste olmadan "gelişim", "tarih", "farklı" gibi kelimeler slayt
  /// konusuyla tamamen alakasız modelleri tetikleyebiliyordu — örn.
  /// "Türk Kahvesinin Gelişimi" slaytı sadece "gelişim" kelimesi ortak
  /// olduğu için "Embriyo Gelişimi" modeliyle eşleşiyordu. Bu kelimeler
  /// eşleştirme skoruna hiç katkı sağlamamalı.
  static const Set<String> genericStopwords = <String>{
    // Soyut/İlerleme kelimeleri
    'gelisim', 'gelisimi', 'gelisimini', 'gelisimine', 'gelisimiyle',
    'surec', 'sureci', 'surecinde', 'donem', 'donemi', 'donemine',
    // Önem / genellik / fark
    'onemli', 'onemi', 'onemine', 'farkli', 'farklari', 'farklilik',
    'genel', 'genelde', 'geneli', 'genellikle',
    // Zaman / mekan / kapsam dolgu kelimeleri. "Dünya" katalogda gerçek bir
    // gezegen modelini ifade ettiği için jenerik kabul edilmez.
    'tarih', 'tarihi', 'tarihte', 'tarihinde', 'tarihsel',
    'yuzyil', 'yuzyilda', 'yuzyilin', 'gunumuzde', 'gunumuz', 'bugun',
    'bugunku',
    // Konu / yapı dolgu kelimeleri
    'konu', 'konusu', 'konusunda', 'alan', 'alani',
    'yapi', 'yapisi', 'sistem', 'sistemi', 'temel', 'temeli',
    'cesit', 'cesidi', 'cesitleri', 'tur', 'turu', 'turleri', 'turlerini',
    'turleriyle',
    'ornek', 'ornegi', 'ornekleri', 'ozellik', 'ozelligi', 'ozellikleri',
    // Tek başına bir 3B varlığı tanımlamayan fiziksel/arayüzsel kelimeler.
    // Bunlar eşleştirmede katalizör yüzeyi, Gantt şeması veya telefon gibi
    // alakasız katalog öğelerini tetikleyebiliyordu.
    'kuvvet', 'hareket', 'yuzey', 'yuzeyi', 'yuzeyler', 'temas', 'cisim',
    'nesne', 'blok', 'kutu',
    'malzeme', 'uygulama', 'plan', 'sema', 'sekil', 'gorsel',
    // "Etki", "analiz" ve benzeri soyut ifade kelimeleri bir nesneyi
    // tanımlamaz. Bunlar, Etki-Efor Matrisi gibi sunum bileşenlerinin fen
    // konularında yanlışlıkla gerçek 3B nesne seçilmesine yol açıyordu.
    'etki', 'etkisi', 'etkileri', 'efor', 'analiz', 'analizi', 'matris',
    'matrisi', 'oncelik', 'onceligi', 'karsilastirma', 'iliskisi',
    // Bir işlemin bağlamını anlatır; tek başına temsil edilecek 3B nesneyi
    // belirtmez. Örneğin "soğutma döngüsü" bir kelebek yaşam döngüsü değildir.
    'dongu', 'dongusu', 'donguler', 'donguleri', 'asama', 'asamalari',
    'kullanim', 'kullanimlari', 'kullanim_alani', 'verimlilik',
    'enerji', 'cevre', 'gelecek', 'yenilik', 'yenilikler',
    // Yaygın fiil/edat/bağlaç kalıpları
    'ortaya', 'cikarmistir', 'cikmistir', 'olusturmustur', 'olusmustur',
    'tuketilmektedir', 'tuketilir', 'tuketim', 'kullanilmaktadir', 'kullanilir',
    'ile', 've', 'bir', 'bu', 'su', 'icin', 'gibi', 'olarak', 'olan',
    'daha', 'cok', 'az', 'her', 'tum', 'butun', 'ise', 'ama', 'fakat',
    'ancak', 'veya', 'ya', 'de', 'da', 'ki',
    // English generic stopwords & abstract filler
    'the', 'and', 'with', 'from', 'about', 'for', 'this', 'that',
    'into', 'over', 'after', 'before', 'between', 'through', 'during',
    'without', 'again', 'further', 'then', 'once', 'here', 'there',
    'when', 'where', 'why', 'how', 'all', 'any', 'both', 'each',
    'few', 'more', 'most', 'other', 'some', 'such', 'only', 'own',
    'same', 'so', 'than', 'too', 'very', 'can', 'will', 'just',
    'should', 'now', 'development', 'process', 'period', 'history',
    'historical', 'important', 'importance', 'different', 'differences',
    'general', 'generally', 'structure', 'system', 'basic', 'basics',
    'type', 'types', 'example', 'examples', 'feature', 'features',
    'introduction', 'overview', 'summary', 'conclusion',
  };

  /// [normalizedWord] eşleştirme için kullanılamayacak kadar jenerik mi?
  /// (2 karakter ve altı kelimeler de gürültü kabul edilir.)
  static bool isGenericWord(String normalizedWord) {
    return normalizedWord.length <= 2 ||
        genericStopwords.contains(normalizedWord);
  }

  /// [normalizedText] içindeki jenerik olmayan, gerçekten ayırt edici
  /// kelimeleri döner. Model eşleştirme sorgularında yalnızca bu kelimeler
  /// kullanılmalıdır.
  static List<String> significantWords(String normalizedText) {
    return words(normalizedText)
        .where((word) => !isGenericWord(word))
        .toList(growable: false);
  }

  static bool textMatchesKeyword(
    String normalizedText,
    String normalizedKeyword,
  ) {
    if (normalizedText.isEmpty || normalizedKeyword.isEmpty) {
      return false;
    }
    final keywordWords = words(normalizedKeyword);
    if (keywordWords.isEmpty) {
      return false;
    }

    final inputWords = words(normalizedText);
    return keywordWords.every(
      (keywordWord) => inputWords.any(
        (inputWord) => wordsMatch(inputWord, keywordWord),
      ),
    );
  }

  static bool wordsMatch(String inputWord, String keywordWord) {
    if (inputWord == keywordWord) {
      return true;
    }
    if (inputWord.length < 4 || keywordWord.length < 4) {
      return false;
    }

    final shorterLength = inputWord.length < keywordWord.length
        ? inputWord.length
        : keywordWord.length;
    final longerLength = inputWord.length > keywordWord.length
        ? inputWord.length
        : keywordWord.length;
    var commonPrefixLength = 0;
    while (commonPrefixLength < shorterLength &&
        inputWord.codeUnitAt(commonPrefixLength) ==
            keywordWord.codeUnitAt(commonPrefixLength)) {
      commonPrefixLength += 1;
    }
    // A raw common-prefix rule is dangerously broad in Turkish: for example
    // "antik" used to match both "antijen" and "antikor".  Prefixes are
    // useful only when the remainder is a plausible inflection, such as
    // "gezegen" -> "gezegenler" or "ekoloji" -> "ekolojisi".
    if (commonPrefixLength == shorterLength &&
        longerLength - shorterLength <= 6 &&
        _isLikelyInflectionSuffix(
          inputWord.length >= keywordWord.length
              ? inputWord.substring(shorterLength)
              : keywordWord.substring(shorterLength),
        )) {
      return true;
    }

    // Both words can be inflected: panel-i and panel-ler-i share panel.
    // Keep a complete stem of at least four letters; never use raw prefixes.
    if (sutolInflectedMatchingEnabled && commonPrefixLength >= 4) {
      final inputStems = _inflectionStems(inputWord);
      final keywordStems = _inflectionStems(keywordWord);
      if (inputStems.any(keywordStems.contains)) return true;
    }

    if (inputWord.codeUnitAt(0) != keywordWord.codeUnitAt(0) ||
        (inputWord.length - keywordWord.length).abs() > 2) {
      return false;
    }

    final similarity = similarityRatio(inputWord, keywordWord);
    final threshold =
        inputWord.length <= 5 || keywordWord.length <= 5 ? 0.80 : 0.76;
    return similarity >= threshold;
  }

  /// Turkish (and a small set of English) inflection endings that may safely
  /// extend a complete keyword stem. This intentionally excludes arbitrary
  /// continuations: a lexical neighbour like "antikor" is not an inflection
  /// of "antik".
  static bool _isLikelyInflectionSuffix(String suffix) {
    return _inflectionSuffixPattern.hasMatch(suffix);
  }

  static final _inflectionSuffixPattern = RegExp(
    r'^(?:lar(?:da|dan|a|i|in)?|ler(?:de|den|e|i|in)?|tan|ten|ta|te|larin|lerin|lara|lere|dan|den|da|de|dir|dır|dur|dür|in|ın|un|ün|i|ı|u|ü|si|sı|su|sü|im|ım|um|üm|imiz|ımız|umuz|ümüz|miz|mız|muz|müz|nin|nın|nun|nün|na|ne|yi|yı|yu|yü|ya|ye|yle|yla|ce|ca|ci|cı|cu|cü|lik|lık|luk|lük|s|es|ed|ing)$',
  );

  static final Map<String, Set<String>> _stemCache = {};

  static Set<String> _inflectionStems(String word) {
    final cached = _stemCache[word];
    if (cached != null) return cached;
    if (_stemCache.length >= 8192) _stemCache.clear();
    final stems = <String>{word};
    for (var split = 4; split < word.length; split++) {
      if (_isLikelyInflectionSuffix(word.substring(split))) {
        final stem = word.substring(0, split);
        stems.add(stem);
        // Turkish softening before vowel suffixes: çekirdek -> çekirdeği,
        // kitap -> kitabı. Apply only to an explicitly removed suffix.
        if (stem.endsWith('g'))
          stems.add('${stem.substring(0, stem.length - 1)}k');
        if (stem.endsWith('b'))
          stems.add('${stem.substring(0, stem.length - 1)}p');
      }
    }
    _stemCache[word] = stems;
    return stems;
  }

  static double similarityRatio(String a, String b) {
    if (a == b) {
      return 1;
    }
    if (a.isEmpty || b.isEmpty) {
      return 0;
    }

    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    return (maxLength - distance) / maxLength;
  }

  static String splitEnumName(String value) {
    return value.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)!.toLowerCase()}',
    );
  }

  static int _levenshteinDistance(String a, String b) {
    final previous = List<int>.generate(b.length + 1, (index) => index);
    final current = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i += 1) {
      current[0] = i;
      for (var j = 1; j <= b.length; j += 1) {
        final substitutionCost =
            a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        current[j] = _min3(
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + substitutionCost,
        );
      }
      for (var j = 0; j <= b.length; j += 1) {
        previous[j] = current[j];
      }
    }

    return previous[b.length];
  }

  static int _min3(int a, int b, int c) {
    var min = a < b ? a : b;
    if (c < min) {
      min = c;
    }
    return min;
  }
}
