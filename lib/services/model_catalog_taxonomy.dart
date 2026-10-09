import 'model_repository.dart';
import 'presentation_keyword_catalog.dart';

/// Versioned, deterministic enrichment for both cloud and bundled metadata.
/// Never changes asset identity, access tier, URLs or negative matching rules.
class ModelCatalogTaxonomy {
  static const version = 2;
  static const categoryAliases = <String, String>{
    'uzay': 'Uzay ve Astronomi',
    'space': 'Uzay ve Astronomi',
    'astronomi': 'Uzay ve Astronomi',
    'astronomy': 'Uzay ve Astronomi',
    'space and astronomy': 'Uzay ve Astronomi',
    'cografya': 'Doğa ve Coğrafya',
    'geography': 'Doğa ve Coğrafya',
    'doga': 'Doğa ve Coğrafya',
    'nature': 'Doğa ve Coğrafya',
    'cografya ve uzay': 'Doğa ve Coğrafya',
    'nature and geography': 'Doğa ve Coğrafya',
    'fizik': 'Fizik ve Kimya',
    'physics': 'Fizik ve Kimya',
    'kimya': 'Fizik ve Kimya',
    'chemistry': 'Fizik ve Kimya',
    'teknoloji': 'Teknoloji ve Yazılım',
    'technology': 'Teknoloji ve Yazılım',
    'elektronik': 'Elektronik',
    'electronics': 'Elektronik',
    'muhendislik': 'Mühendislik',
    'engineering': 'Mühendislik',
    'matematik': 'Matematik',
    'mathematics': 'Matematik',
    'math': 'Matematik',
    'enerji ve iklimlendirme': 'Enerji',
    'energy': 'Enerji',
    'tarih ve kultur': 'Tarih ve Mimari',
    'mimari': 'Tarih ve Mimari',
    'architecture': 'Tarih ve Mimari',
    'ulasim ve havacilik': 'Ulaşım',
    'tasit': 'Ulaşım',
    'transport': 'Ulaşım',
    'egitim': 'Ofis ve Eğitim',
    'education': 'Ofis ve Eğitim',
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
    ['dünya', 'earth'],
    ['güneş', 'sun'],
    ['ay', 'moon'],
    ['merkür', 'mercury'],
    ['venüs', 'venus'],
    ['jüpiter', 'jupiter'],
    ['satürn', 'saturn'],
    ['uranüs', 'uranus'],
    ['neptün', 'neptune'],
    ['galaksi', 'galaxy'],
    ['yıldız', 'star'],
    ['uydu', 'satellite'],
    ['roket', 'rocket'],
    ['astronot', 'astronaut'],
    ['kara delik', 'black hole'],
    ['güneş sistemi', 'solar system'],
    ['kuyruklu yıldız', 'comet'],
    ['yörünge', 'orbit'],
    ['tutulma', 'eclipse'],
    ['göktaşı', 'meteor', 'meteorite'],
    ['dağ', 'mountain'],
    ['volkan', 'volcano'],
    ['deprem', 'earthquake'],
    ['nehir', 'river'],
    ['okyanus', 'ocean'],
    ['buzul', 'glacier'],
    ['erozyon', 'erosion'],
    ['iklim', 'climate'],
    ['atmosfer', 'atmosphere'],
    ['toprak', 'soil'],
    ['orman', 'forest'],
    ['harita', 'map'],
    ['kıta', 'continent'],
    ['vadi', 'valley'],
    ['fay', 'fault'],
    ['ekosistem', 'ecosystem'],
    ['bulut', 'cloud'],
    ['atom', 'atom'],
    ['molekül', 'molecule'],
    ['elektron', 'electron'],
    ['proton', 'proton'],
    ['nötron', 'neutron'],
    ['mıknatıs', 'magnet'],
    ['sarkaç', 'pendulum'],
    ['dalga', 'wave'],
    ['devre', 'circuit'],
    ['direnç', 'resistor'],
    ['kondansatör', 'capacitor'],
    ['diyot', 'diode'],
    ['transistör', 'transistor'],
    ['dişli', 'gear'],
    ['motor', 'engine'],
    ['pompa', 'pump'],
    ['türbin', 'turbine'],
    ['güneş paneli', 'solar panel'],
    ['batarya', 'pil', 'battery'],
    ['bilgisayar', 'computer'],
    ['işlemci', 'processor'],
    ['algoritma', 'algorithm'],
    ['yazılım', 'software'],
    ['üçgen', 'triangle'],
    ['kare', 'square'],
    ['küre', 'sphere'],
    ['silindir', 'cylinder'],
    ['koni', 'cone'],
    ['piramit', 'pyramid'],
    ['tren', 'train'],
    ['gemi', 'ship'],
    ['otomobil', 'car'],
    ['bisiklet', 'bicycle'],
    ['otobüs', 'bus'],
    ['köprü', 'bridge'],
    ['kitap', 'book'],
    ['okul', 'school'],
    ['öğretmen', 'teacher'],
    ['bütçe', 'budget'],
    ['yatırım', 'investment'],
    ['finans', 'finance'],
    ['pazarlama', 'marketing'],
    ['futbol', 'football', 'soccer'],
    ['basketbol', 'basketball'],
    ['satranç', 'chess'],
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
      'cyber',
      'fabrika',
      'factory',
      'imalat',
      'manufacturing'
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
    // Compute the small synonym closure once, so reloading a cache cannot
    // add a different set of tags than the first cloud load.
    final applied = <int>{};
    var changed = true;
    while (changed) {
      changed = false;
      for (var i = 0; i < concepts.length; i++) {
        if (applied.contains(i)) continue;
        final group = concepts[i];
        if (group.first == 'hücre' && _nonBiologicalCell(model)) continue;
        if (!group.any((term) => _hasPhrase(words, term))) continue;
        applied.add(i);
        tags.add(group.first);
        english.addAll(group.skip(1));
        words.addAll(_words(group));
        changed = true;
      }
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
    final result = <String>{primary.isEmpty ? 'Diğer' : primary};
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
    }
    final metaphor = words.intersection({
      'vizyon',
      'vision',
      'hedef',
      'goal',
      'finansal',
      'marketing',
      'pazarlama'
    }).isNotEmpty;
    if (_hasPhrase(words, 'kara delik') ||
        _hasPhrase(words, 'black hole') ||
        _hasPhrase(words, 'gunes sistemi') ||
        _hasPhrase(words, 'solar system')) {
      result.add('Uzay ve Astronomi');
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
        'uzay',
        'space',
        'gok',
        'cosmos',
        'moon',
        'ay',
        'mars',
        'merkur',
        'mercury',
        'venus',
        'uranus',
        'neptun',
        'neptune',
        'yildiz',
        'star',
        'astronot',
        'astronaut',
        'roket',
        'rocket',
        'yorunge',
        'orbit',
        'satellite',
        'uydu',
        'tutulma',
        'eclipse',
        'goktasi',
        'meteor',
        'comet',
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
        'doga',
        'nature',
        'jeoloji',
        'geology',
        'iklim',
        'climate',
        'atmosfer',
        'atmosphere',
        'toprak',
        'soil',
        'erozyon',
        'erosion',
        'buzul',
        'glacier',
        'vadi',
        'valley',
        'kiyi',
        'coast',
        'okyanus',
        'ocean',
        'orman',
        'forest',
        'ekosistem',
        'ecosystem',
        'kita',
        'continent',
        'harita',
        'map',
        'meridyen',
        'paralel',
        'karstik',
        'tektonik',
        'tectonic',
        'fay',
        'fault',
        'kuraklik',
        'drought',
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
      'Matematik': {
        'matematik',
        'mathematics',
        'geometri',
        'geometry',
        'ucgen',
        'triangle',
        'kure',
        'sphere',
        'silindir',
        'cylinder',
        'koni',
        'cone',
        'piramit',
        'pyramid',
        'prizma',
        'prism',
        'kesir',
        'fraction',
        'abacus',
        'abakus'
      },
      'Elektronik': {
        'elektronik',
        'electronics',
        'devre',
        'circuit',
        'direnc',
        'resistor',
        'kondansator',
        'capacitor',
        'diyot',
        'diode',
        'transistor'
      },
      'Mühendislik': {
        'muhendislik',
        'engineering',
        'mekanik',
        'mechanical',
        'pnomatik',
        'pneumatic',
        'hidrolik',
        'hydraulic',
        'kompresor',
        'compressor',
        'disli',
        'gear'
      },
      'Makine ve Mekanizma': {
        'makine',
        'machine',
        'mekanizma',
        'mechanism',
        'motor',
        'engine',
        'pompa',
        'pump',
        'disli',
        'gear',
        'kompresor',
        'compressor',
        'imalat',
        'manufacturing'
      },
      'Enerji': {
        'enerji',
        'energy',
        'turbin',
        'turbine',
        'yenilenebilir',
        'renewable',
        'batarya',
        'battery',
        'fotovoltaik',
        'photovoltaic',
        'jenerator',
        'generator'
      },
      'Tarih ve Mimari': {
        'tarih',
        'history',
        'mimari',
        'architecture',
        'arkeoloji',
        'archaeology',
        'anit',
        'monument',
        'saray',
        'palace',
        'kale',
        'castle',
        'tapinak',
        'temple'
      },
      'Ofis ve Eğitim': {
        'egitim',
        'education',
        'okul',
        'school',
        'ofis',
        'office',
        'ogretmen',
        'teacher',
        'sinif',
        'classroom',
        'kitap',
        'book',
        'ogrenci',
        'student'
      },
      'Spor ve Oyun': {
        'spor',
        'sport',
        'oyun',
        'game',
        'futbol',
        'football',
        'basketbol',
        'basketball',
        'satranc',
        'chess',
        'fitness'
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
      if (metaphor &&
          {'Doğa ve Coğrafya', 'Uzay ve Astronomi'}.contains(subject.key))
        continue;
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
    if (!_nonBiologicalCell(model) &&
        (result.contains('Anatomi ve Tıp') ||
            words.intersection(biological).isNotEmpty)) {
      result.add('Biyoloji');
    }
    return Set.unmodifiable(result);
  }
}
