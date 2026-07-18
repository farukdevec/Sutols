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
