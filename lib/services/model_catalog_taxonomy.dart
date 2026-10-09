import 'model_repository.dart';
import 'presentation_keyword_catalog.dart';

/// Versioned, deterministic enrichment for both cloud and bundled metadata.
/// Never changes asset identity, access tier, URLs or negative matching rules.
class ModelCatalogTaxonomy {
  static const version = 1;
  static const categoryAliases = <String, String>{
    'biyoloji': 'Biyoloji',
    'biology': 'Biyoloji',
    'anatomi ve tip': 'Anatomi ve Tıp',
    'anatomy': 'Anatomi ve Tıp',
    'fizik ve kimya': 'Fizik ve Kimya',
    'doga ve cografya': 'Doğa ve Coğrafya',
    'uzay ve astronomi': 'Uzay ve Astronomi',
    'tarih ve mimari': 'Tarih ve Mimari',
    'teknoloji ve yazilim': 'Teknoloji ve Yazılım',
    'finans ve is': 'Finans ve İş',
    'makine ve mekanizma': 'Makine ve Mekanizma',
    'ofis ve egitim': 'Ofis ve Eğitim',
    'spor ve oyun': 'Spor ve Oyun',
    'analiz modeli': 'Analiz Modelleri',
    'diyagram': 'Diyagram',
    'grafik': 'Grafik',
    'sembol': 'Sembol',
    'ikon 3d': '3D İkonlar',
    'ulasim': 'Ulaşım',
    'enerji': 'Enerji',
    'diger': 'Diğer',
  };

  // Synonyms describe the same concrete concept, not merely a shared subject.
  static const concepts = <List<String>>[
    ['hücre', 'cell'],
    ['organel', 'organelle'],
    ['mitokondri', 'mitochondria', 'mitochondrion'],
    ['kloroplast', 'chloroplast'],
    ['ribozom', 'ribosome'],
    ['golgi', 'Golgi aygıtı', 'Golgi apparatus'],
    ['endoplazmik retikulum', 'endoplasmic reticulum'],
    ['lizozom', 'lysosome'],
    ['sentrozom', 'centrosome'],
    ['vakuol', 'vacuole'],
    ['mitoz', 'mitosis'],
    ['mayoz', 'meiosis'],
    ['embriyo', 'embryo'],
    ['genetik', 'genetics'],
    ['protein', 'protein'],
    ['enzim', 'enzyme'],
    ['nöron', 'neuron'],
    ['sinaps', 'synapse'],
    ['kalp', 'heart'],
    ['akciğer', 'lung'],
    ['karaciğer', 'liver'],
    ['böbrek', 'kidney'],
    ['beyin', 'brain'],
    ['kemik', 'bone'],
    ['kas', 'muscle'],
    ['omurga', 'spine'],
    ['kan', 'blood'],
    ['bitki', 'plant'],
    ['fotosentez', 'photosynthesis'],
    ['tozlaşma', 'pollination'],
    ['bakteri', 'bacteria', 'bacterium'],
    ['ökaryot', 'eukaryote'],
    ['prokaryot', 'prokaryote'],
    ['DNA', 'deoxyribonucleic acid'],
    ['RNA', 'ribonucleic acid'],
    ['uçak', 'airplane', 'aircraft'],
    ['gezegen', 'planet'],
    ['mikroskop', 'microscope'],
    ['teleskop', 'telescope'],
  ];

  static String _key(String text) => PresentationKeywordCatalog.words(
          PresentationKeywordCatalog.normalize(text))
      .join(' ');

  static String canonicalCategory(String category) =>
      categoryAliases[_key(category)] ?? category.trim();

  static Set<String> _words(Iterable<String> values) => values
      .expand((v) => PresentationKeywordCatalog.words(
          PresentationKeywordCatalog.normalize(v)))
      .toSet();

  static bool _hasPhrase(Set<String> words, String phrase) =>
      _words([phrase]).every(words.contains);

  static bool _nonBiologicalCell(ModelCatalogEntry model) {
    final words =
        _words([model.name, model.id, ...model.tags, ...model.tagsEn]);
    return words.intersection({
      'yakit',
      'fuel',
      'galvanik',
      'galvanic',
      'elektrokimyasal',
      'electrochemical',
      'fotovoltaik',
      'photovoltaic',
      'yazilim',
      'software',
      'malware',
      'siber',
      'cyber'
    }).isNotEmpty;
  }

  static ModelCatalogEntry enrich(ModelCatalogEntry model) {
    final words = _words([
      model.name,
      model.id.replaceAll('_', ' '),
      ...model.tags,
      ...model.tagsEn
    ]);
    final tags = <String>[...model.tags];
    final english = <String>[...model.tagsEn];
    for (final group in concepts) {
      if (group.first == 'hücre' && _nonBiologicalCell(model)) continue;
      if (!group.any((term) => _hasPhrase(words, term))) continue;
      tags.add(group.first);
      english.addAll(group.skip(1));
    }
    List<String> unique(List<String> values) {
      final seen = <String>{};
      return List.unmodifiable(values
          .where((v) => v.trim().isNotEmpty && seen.add(_key(v)))
          .map((v) => v.trim()));
    }

    return ModelCatalogEntry(
        id: model.id,
        name: model.name,
        modelUrl: model.modelUrl,
        thumbnailUrl: model.thumbnailUrl,
        tags: unique(tags),
        tagsEn: unique(english),
        category: canonicalCategory(model.category),
        tier: model.tier,
        excludeTags: model.excludeTags);
  }

  /// Discovery permits multiple subjects without weakening automatic placement.
  static Set<String> discoveryCategories(ModelCatalogEntry model) {
    final primary = canonicalCategory(model.category);
    final result = <String>{if (primary.isNotEmpty) primary};
    final words =
        _words([model.name, model.id, ...model.tags, ...model.tagsEn]);
    if (_nonBiologicalCell(model)) {
      result.remove('Biyoloji');
      if (words.intersection(
          {'yazilim', 'software', 'malware', 'siber', 'cyber'}).isNotEmpty) {
        result.add('Teknoloji ve Yazılım');
      } else {
        result.add('Fizik ve Kimya');
      }
      return result;
    }
    const subjectTerms = <String, Set<String>>{
      'Fizik ve Kimya': {
        'atom',
        'molekul',
        'molecule',
        'kimya',
        'chemistry',
        'fizik',
        'physics',
        'elektron',
        'electron',
        'periyodik',
        'elektrokimya'
      },
      'Uzay ve Astronomi': {
        'astronomi',
        'astronomy',
        'gezegen',
        'planet',
        'galaksi',
        'galaxy',
        'saturn',
        'jupiter',
        'teleskop',
        'telescope'
      },
      'Teknoloji ve Yazılım': {
        'yazilim',
        'software',
        'algoritma',
        'algorithm',
        'bilgisayar',
        'computer',
        'robot',
        'islemci',
        'processor'
      },
      'Doğa ve Coğrafya': {
        'cografya',
        'geography',
        'volkan',
        'volcano',
        'deprem',
        'earthquake',
        'nehir',
        'river',
        'dag',
        'mountain'
      },
      'Finans ve İş': {
        'finans',
        'finance',
        'yatirim',
        'investment',
        'borsa',
        'stock',
        'pazarlama',
        'marketing',
        'butce',
        'budget'
      },
      'Ulaşım': {
        'ucak',
        'airplane',
        'aircraft',
        'otomobil',
        'car',
        'tren',
        'train',
        'gemi',
        'ship'
      },
      'Anatomi ve Tıp': {
        'anatomi',
        'anatomy',
        'kalp',
        'heart',
        'akciger',
        'lung',
        'bobrek',
        'kidney',
        'karaciger',
        'liver',
        'omurga',
        'spine',
        'beyin',
        'brain'
      },
    };
    for (final subject in subjectTerms.entries) {
      if (words.intersection(subject.value).isNotEmpty) result.add(subject.key);
    }
    const biological = {
      'biyoloji',
      'biology',
      'organel',
      'organelle',
      'hucre',
      'cell',
      'mitokondri',
      'mitochondria',
      'kloroplast',
      'chloroplast',
      'ribozom',
      'ribosome',
      'golgi',
      'lizozom',
      'lysosome',
      'sentrozom',
      'centrosome',
      'vakuol',
      'vacuole',
      'mitoz',
      'mitosis',
      'mayoz',
      'meiosis',
      'embriyo',
      'embryo',
      'genetik',
      'genetics',
      'dna',
      'rna',
      'crispr',
      'enzim',
      'enzyme',
      'protein',
      'fotosentez',
      'photosynthesis',
      'tozlasma',
      'pollination',
      'bakteri',
      'bacteria',
      'bitki',
      'plant',
      'anatomi',
      'anatomy',
      'noron',
      'neuron',
      'sinaps',
      'synapse'
    };
    if (result.contains('Anatomi ve Tıp') ||
        words.intersection(biological).isNotEmpty) {
      result.add('Biyoloji');
    }
    return Set.unmodifiable(result);
  }
}
