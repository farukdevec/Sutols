class PresentationKeywordCatalog {
  const PresentationKeywordCatalog._();

  static final RegExp _wordBoundary = RegExp(r'[^a-z0-9]+');

  static String normalize(String value) {
    return value
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

  static List<String> words(String normalizedText) {
    return normalizedText
        .split(_wordBoundary)
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
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
    // Zaman / mekan / kapsam dolgu kelimeleri
    'dunya', 'dunyada', 'dunyanin', 'dunyasi', 'dunyayla',
    'tarih', 'tarihi', 'tarihte', 'tarihinde', 'tarihsel',
    'yuzyil', 'yuzyilda', 'yuzyilin', 'gunumuzde', 'gunumuz', 'bugun', 'bugunku',
    // Konu / yapı dolgu kelimeleri
    'konu', 'konusu', 'konusunda', 'alan', 'alani',
    'yapi', 'yapisi', 'sistem', 'sistemi', 'temel', 'temeli',
    'cesit', 'cesidi', 'cesitleri', 'tur', 'turu', 'turleri', 'turlerini', 'turleriyle',
    'ornek', 'ornegi', 'ornekleri', 'ozellik', 'ozelligi', 'ozellikleri',
    // Yaygın fiil/edat/bağlaç kalıpları
    'ortaya', 'cikarmistir', 'cikmistir', 'olusturmustur', 'olusmustur',
    'tuketilmektedir', 'tuketilir', 'tuketim', 'kullanilmaktadir', 'kullanilir',
    'ile', 've', 'bir', 'bu', 'su', 'icin', 'gibi', 'olarak', 'olan',
    'daha', 'cok', 'az', 'her', 'tum', 'butun', 'ise', 'ama', 'fakat',
    'ancak', 'veya', 'ya', 'de', 'da', 'ki',
  };

  /// [normalizedWord] eşleştirme için kullanılamayacak kadar jenerik mi?
  /// (2 karakter ve altı kelimeler de gürültü kabul edilir.)
  static bool isGenericWord(String normalizedWord) {
    return normalizedWord.length <= 2 || genericStopwords.contains(normalizedWord);
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
    if (commonPrefixLength >= 4 &&
        commonPrefixLength / shorterLength >= 0.80 &&
        longerLength - shorterLength <= 4) {
      return true;
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
