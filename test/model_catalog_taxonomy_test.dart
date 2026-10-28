import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_catalog_taxonomy.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/model_search_service.dart';

ModelCatalogEntry model(String name,
        {String category = 'analiz-modeli',
        List<String> tags = const [],
        List<String> tagsEn = const []}) =>
    ModelCatalogEntry(
        id: name,
        name: name,
        modelUrl: 'protected.glb',
        thumbnailUrl: '',
        tags: tags,
        tagsEn: tagsEn,
        category: category,
        tier: 'premium',
        excludeTags: const ['kahve']);

void main() {
  test('legacy subjects are discovered without losing format or permissions',
      () {
    final original = model('Golgi Aygıtı', tags: ['organel']);
    final enriched = ModelCatalogTaxonomy.enrich(original);
    expect(enriched.modelUrl, original.modelUrl);
    expect(enriched.tier, original.tier);
    expect(enriched.excludeTags, original.excludeTags);
    expect(enriched.toCacheJson(),
        ModelCatalogTaxonomy.enrich(enriched).toCacheJson());
    final index = ModelSearchIndex([
      original,
      model('CRISPR Gen Düzenleme'),
      model('Embriyo Gelişimi', category: 'anatomi-ve-tip')
    ]);
    expect(index.search('', category: 'Biyoloji'), hasLength(3));
    expect(index.search('', category: 'biyoloji'), hasLength(3));
    expect(index.search('', category: 'Analiz Modelleri'), hasLength(2));
    expect(index.search('golgi apparatus', category: 'biology').single.id,
        original.id);
  });
  test('non biological cells and software viruses do not enter biology', () {
    final index = ModelSearchIndex([
      model('Galvanik Hücre', tags: ['hücre']),
      model('Yakıt Hücresi'),
      model('Kötü Amaçlı Yazılım Uyarısı',
          category: 'biyoloji', tags: ['virüs']),
      model('Hayvan Hücresi', tags: ['hücre']),
    ]);
    expect(index.search('', category: 'Biyoloji').map((m) => m.name),
        ['Hayvan Hücresi']);
    expect(index.search('cell').map((m) => m.name), ['Hayvan Hücresi']);
  });
  test('legacy snapshot biology discovery repairs misclassified organelles',
      () {
    final rows = (jsonDecode(
                File('functions/scripts/models-tagged.json').readAsStringSync())
            as List)
        .cast<Map<String, dynamic>>();
    final models = rows
        .map((r) => model(r['name'] as String,
            category: r['category'] as String,
            tags: (r['tags'] as List).cast<String>(),
            tagsEn: (r['tags_en'] as List? ?? []).cast<String>()))
        .toList();
    final index = ModelSearchIndex(models);
    final biology = index.search('', category: 'Biyoloji');
    expect(biology.length, greaterThan(34));
    for (final name in [
      'Golgi Aygıtı',
      'Mitokondri Kesiti',
      'Ribozom Yapısı',
      'CRISPR Gen Düzenleme Kompleksi',
      'Endoplazmik Retikulum'
    ]) {
      expect(biology.any((m) => m.name == name), isTrue, reason: name);
    }
    expect(
        biology.any((m) => m.name == 'Kötü Amaçlı Yazılım Uyarısı'), isFalse);
    expect(
        index.search('chloroplast').any((m) => m.name.contains('Kloroplast')),
        isTrue);
    print(
        'Legacy snapshot: ${models.length} records, ${biology.length} biology discoveries (not live count).');
  });
}
