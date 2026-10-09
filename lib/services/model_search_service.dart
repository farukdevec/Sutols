import 'model_repository.dart';
import 'presentation_keyword_catalog.dart';

/// User-driven discovery is intentionally separate from automatic placement:
/// partial names and spelling variants are useful here, but are not evidence
/// for adding a 3D object to a generated presentation.
class ModelSearchIndex {
  ModelSearchIndex(List<ModelCatalogEntry> models)
      : _entries = models.map(_SearchEntry.new).toList(growable: false);

  final List<_SearchEntry> _entries;
  List<String> get categories {
    final values = _entries
        .map((entry) => entry.model.category.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return List.unmodifiable(values);
  }

  String? _lastKey;
  List<ModelCatalogEntry> _lastResults = const [];

  List<ModelCatalogEntry> search(String query, {String category = ''}) {
    final normalized = PresentationKeywordCatalog.normalize(query);
    final key = '$category\u0000$normalized';
    if (_lastKey == key) return _lastResults;
    final terms = PresentationKeywordCatalog.words(normalized).toSet();
    final scored = <(_SearchEntry, int)>[];
    for (final entry in _entries) {
      if (category.isNotEmpty && entry.model.category != category) continue;
      var score = 0;
      var accepts = true;
      for (final term in terms) {
        var best = 0;
        for (final candidate in entry.nameWords) {
          if (candidate == term)
            best = 40;
          else if (_matches(term, candidate) && best < 25) best = 25;
        }
        for (final candidate in entry.tagWords) {
          if (_matches(term, candidate) && best < 20) best = 20;
        }
        for (final candidate in entry.categoryWords) {
          if (_matches(term, candidate) && best < 8) best = 8;
        }
        if (best == 0) {
          accepts = false;
          break;
        }
        score += best;
      }
      if (!accepts) continue;
      if (normalized.isNotEmpty && entry.name == normalized) score += 100;
      scored.add((entry, score));
    }
    if (terms.isNotEmpty) {
      scored.sort((a, b) {
        final order = b.$2.compareTo(a.$2);
        return order == 0 ? a.$1.model.id.compareTo(b.$1.model.id) : order;
      });
    }
    _lastKey = key;
    _lastResults = List.unmodifiable(scored.map((entry) => entry.$1.model));
    return _lastResults;
  }

  static bool _matches(String query, String word) =>
      query == word ||
      (query.length >= 3 && word.startsWith(query)) ||
      (query.length >= 5 &&
          word.length >= 4 &&
          PresentationKeywordCatalog.wordsMatch(query, word)) ||
      _oneEditApart(query, word);

  // Manual search only: a single typo in a sufficiently long word should not
  // force the user to know the catalog spelling. Automatic placement retains
  // its stricter semantic matcher and confidence gates.
  static bool _oneEditApart(String query, String word) {
    if (query.length < 5 ||
        word.length < 5 ||
        query.length > 64 ||
        word.length > 64 ||
        (query.length - word.length).abs() > 1) return false;
    var i = 0, j = 0, edits = 0;
    while (i < query.length && j < word.length) {
      if (query.codeUnitAt(i) == word.codeUnitAt(j)) {
        i++;
        j++;
        continue;
      }
      if (++edits > 1) return false;
      if (query.length == word.length) {
        // Adjacent keyboard transposition counts as one typo.
        if (i + 1 < query.length &&
            j + 1 < word.length &&
            query.codeUnitAt(i) == word.codeUnitAt(j + 1) &&
            query.codeUnitAt(i + 1) == word.codeUnitAt(j)) {
          i += 2;
          j += 2;
        } else {
          i++;
          j++;
        }
      } else if (query.length > word.length) {
        i++;
      } else {
        j++;
      }
    }
    return edits + (query.length - i) + (word.length - j) <= 1;
  }
}

class _SearchEntry {
  _SearchEntry(this.model)
      : name = PresentationKeywordCatalog.normalize(model.name),
        nameWords = _words([model.name]),
        tagWords = _words([...model.tags, ...model.tagsEn]),
        categoryWords = _words([model.category]);
  final ModelCatalogEntry model;
  final String name;
  final Set<String> nameWords, tagWords, categoryWords;
  static Set<String> _words(List<String> values) => values
      .map(PresentationKeywordCatalog.normalize)
      .expand(PresentationKeywordCatalog.words)
      .toSet();
}
