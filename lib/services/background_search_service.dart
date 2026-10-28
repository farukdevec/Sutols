import '../models/slide_model.dart';
import 'presentation_keyword_catalog.dart';

enum BackgroundToneFilter { all, light, dark }

/// Manual discovery only; never changes the current slide or automatic theme
/// selection. Tone describes the original catalog variant, not GPU cost.
class BackgroundSearchIndex {
  BackgroundSearchIndex(List<PresentationBackgroundDefinition> definitions)
      : _entries = definitions.map((definition) {
          final englishName = definition.kind.name.replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}');
          return (
            definition,
            PresentationKeywordCatalog.words(
                    PresentationKeywordCatalog.normalize(
                        '${definition.label} ${definition.category} '
                        '${definition.tags.join(' ')} $englishName'))
                .toSet()
          );
        }).toList(growable: false);

  final List<(PresentationBackgroundDefinition, Set<String>)> _entries;

  List<PresentationBackgroundDefinition> search(String query,
      {BackgroundToneFilter tone = BackgroundToneFilter.all}) {
    final terms = PresentationKeywordCatalog.words(
            PresentationKeywordCatalog.normalize(query))
        .toSet();
    return List.unmodifiable(_entries.where((entry) {
      final dark = presentationBackgroundIsDark(entry.$1.kind);
      if (tone == BackgroundToneFilter.light && dark ||
          tone == BackgroundToneFilter.dark && !dark) return false;
      return terms.every((term) => entry.$2.any((word) =>
          term == word || (term.length >= 3 && word.startsWith(term))));
    }).map((entry) => entry.$1));
  }
}
