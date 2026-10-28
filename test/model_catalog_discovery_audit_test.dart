import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_catalog_taxonomy.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/model_search_service.dart';

ModelCatalogEntry fixture(String name, String category,
        {List<String> tags = const []}) =>
    ModelCatalogEntry(
        id: name,
        name: name,
        modelUrl: '$name.glb',
        thumbnailUrl: '',
        tags: tags,
        category: category,
        tier: 'free');

void main() {
  test('all historic snapshots are discoverable by name and unique identity',
      () {
    final byId = <String, ModelCatalogEntry>{};
    for (final file in [
      'models-raw.json',
      'models-raw-new.json',
      'models-tagged.json'
    ]) {
      final rows =
          jsonDecode(File('functions/scripts/$file').readAsStringSync())
              as List;
      for (final raw in rows.cast<Map<String, dynamic>>()) {
        final id = (raw['fileName'] ?? raw['name']) as String;
        List<String> strings(String key) =>
            (raw[key] as List? ?? []).whereType<String>().toList();
        byId[id] = ModelCatalogEntry(
            id: id,
            name: raw['name'] as String? ?? id,
            modelUrl: raw['modelUrl'] as String? ?? id,
            thumbnailUrl: '',
            tags: strings('tags'),
            tagsEn: strings('tags_en'),
            category: raw['category'] as String? ?? '',
            tier: 'free');
      }
    }
    final combined = ModelRepository.mergeWithBundledModels(byId.values);
    final index = ModelSearchIndex(combined);
    final missing = <String>[];
    for (final m in combined) {
      if (!index.search(m.name).any((r) => r.id == m.id)) missing.add(m.id);
      expect(
          ModelCatalogTaxonomy.enrich(ModelCatalogTaxonomy.enrich(m))
              .toCacheJson(),
          ModelCatalogTaxonomy.enrich(m).toCacheJson(),
          reason: m.id);
      expect(index.search(m.id).any((r) => r.id == m.id), isTrue, reason: m.id);
    }
    expect(missing, isEmpty);
    expect(index.search('').length, combined.length);
    for (final category in index.categories) {
      expect(index.categoryCounts[category],
          index.search('', category: category).length);
    }
    for (final category in ['Uzay ve Astronomi', 'Doğa ve Coğrafya']) {
      expect(index.categoryCounts[category], greaterThan(20));
    }
    final report = {
      'scope': 'local_historical_snapshots_not_authenticated_live_catalog',
      'taxonomyVersion': ModelCatalogTaxonomy.version,
      'historicalModels': byId.length,
      'combinedUniqueModels': combined.length,
      'missingNameQueries': missing,
      'identityQueriesPassed': combined.length,
      'categoryCounts': index.categoryCounts,
    };
    final file = File('build/test_reports/model_discovery_audit.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
    print(jsonEncode(report));
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('old and new category spellings share the complete same results', () {
    final index = ModelSearchIndex([
      fixture('Ay', 'uzay-ve-astronomi'),
      fixture('Mars', 'Uzay'),
      fixture('Kara Delik', 'diyagram'),
      fixture('Dağ Oluşumu', 'doga-ve-cografya'),
      fixture('Buzul Vadisi', 'Doğa'),
      fixture('Gerçekçi Dünya', 'Coğrafya ve Uzay',
          tags: ['gezegen', 'coğrafya']),
    ]);
    for (final alias in ['Uzay', 'uzay-ve-astronomi', 'space', 'Astronomi']) {
      expect(index.search('', category: alias).map((m) => m.name),
          containsAll(['Ay', 'Mars', 'Kara Delik', 'Gerçekçi Dünya']));
    }
    for (final alias in ['Coğrafya', 'Doğa', 'doga-ve-cografya', 'geography']) {
      expect(index.search('', category: alias).map((m) => m.name),
          containsAll(['Dağ Oluşumu', 'Buzul Vadisi', 'Gerçekçi Dünya']));
    }
    expect(index.search('black hole model').single.name, 'Kara Delik');
    expect(index.search('moon').single.name, 'Ay');
    expect(index.search('geography 3d'), hasLength(3));
  });

  test('metaphors and industrial cells do not pollute subject discovery', () {
    final index = ModelSearchIndex([
      fixture('Finansal Hedef Dağı', 'diger', tags: ['finans', 'hedef']),
      fixture('Gelecek Vizyonu Teleskobu', 'diger', tags: ['vizyon', 'hedef']),
      fixture('Fabrika Üretim Hücresi', 'diger', tags: ['endüstri', 'imalat']),
      fixture('Bulut Sunucu Kümesi', 'diger', tags: ['sunucu', 'bilişim']),
    ]);
    expect(index.search('', category: 'Uzay'), isEmpty);
    expect(index.search('', category: 'Coğrafya'), isEmpty);
    expect(index.search('', category: 'Biyoloji'), isEmpty);
  });
}
