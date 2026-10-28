import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_matching_service.dart';
import 'package:sutol/services/model_repository.dart';
import 'package:sutol/services/model_search_service.dart';

void main() {
  const input = String.fromEnvironment('SUTOLS_BENCHMARK_INPUT');
  const output = String.fromEnvironment('SUTOLS_BENCHMARK_OUTPUT');
  test('evaluate only a reviewed locked local query set', () {
    if (input.isEmpty || output.isEmpty) {
      throw StateError(
          'Provide SUTOLS_BENCHMARK_INPUT and SUTOLS_BENCHMARK_OUTPUT');
    }
    final package = jsonDecode(File(input).readAsStringSync()) as Map;
    if (package['schemaVersion'] != 1 ||
        package['status'] != 'human-reviewed-locked') {
      throw StateError('Draft queries cannot produce acceptance metrics');
    }
    final rows = (package['queries'] as List).cast<Map>();
    if (rows.length < 200)
      throw StateError('At least 200 reviewed queries required');
    final catalog = ModelRepository.mergeWithBundledModels(const []);
    final ids = catalog.map((m) => m.id).toSet();
    final search = ModelSearchIndex(catalog);
    final samples = <Map<String, Object?>>[];
    for (final row in rows) {
      if (row['review_status'] != 'reviewed' ||
          (row['reviewer'] as String).trim().isEmpty) {
        throw StateError('Every query requires named human review');
      }
      final relevant = (row['relevant_ids'] as List).cast<String>().toSet();
      if (!ids.containsAll(relevant))
        throw StateError('Unknown relevant model ID');
      final none = row['expected_none'] == true;
      if (none == relevant.isNotEmpty)
        throw StateError('Conflicting relevance labels');
      final query = row['query'] as String;
      final clock = Stopwatch()..start();
      final automatic = row['mode'] == 'automatic';
      final results = automatic
          ? ModelMatchingService.rankCatalogModels(
                  models: catalog, keywords: [query])
              .where(ModelMatchingService.isStrong3dMatch)
              .take(3)
              .map((m) => m.id)
              .toList()
          : search.search(query).take(3).map((m) => m.id).toList();
      clock.stop();
      final hits = results.where(relevant.contains).length;
      final rank = results.indexWhere(relevant.contains);
      samples.add({
        'id': row['id'], 'split': row['split'], 'language': row['language'],
        'mode': row['mode'], 'kind': row['kind'], 'returnedIds': results,
        'elapsedUs': clock.elapsedMicroseconds, 'expectedNone': none,
        'precisionAt3FixedDenominator': none ? null : hits / 3,
        'recallAt3': none ? null : hits / relevant.length,
        'reciprocalRankAt3': none
            ? null
            : rank < 0
                ? 0.0
                : 1 / (rank + 1),
        'abstained': results.isEmpty,
        // Generation places one model. Rank diagnostics above are advisory;
        // this records whether the first strong choice was actually relevant.
        'top1Relevant': none
            ? null
            : results.isNotEmpty && relevant.contains(results.first),
      });
    }
    final groups = <String, Object?>{};
    for (final split in ['development', 'evaluation']) {
      for (final language in ['tr', 'en']) {
        for (final mode in ['manual', 'automatic']) {
          final group = samples
              .where((s) =>
                  s['split'] == split &&
                  s['language'] == language &&
                  s['mode'] == mode)
              .toList();
          final positive =
              group.where((s) => s['expectedNone'] == false).toList();
          final negative =
              group.where((s) => s['expectedNone'] == true).toList();
          double? mean(String key) => positive.isEmpty
              ? null
              : positive.map((s) => s[key] as num).reduce((a, b) => a + b) /
                  positive.length;
          final times = group.map((s) => s['elapsedUs'] as int).toList()
            ..sort();
          groups['$split/$language/$mode'] = {
            'queries': group.length,
            'positiveQueries': positive.length,
            'abstentionQueries': negative.length,
            'precisionAt3FixedDenominator':
                mean('precisionAt3FixedDenominator'),
            'recallAt3': mean('recallAt3'),
            'mrrAt3': mean('reciprocalRankAt3'),
            'falsePositiveRate': negative.isEmpty
                ? null
                : negative.where((s) => s['abstained'] == false).length /
                    negative.length,
            'warmAndColdMixedP95Us':
                times.isEmpty ? null : times[((times.length - 1) * .95).ceil()],
          };
        }
      }
    }
    final result = {
      'schemaVersion': 1,
      'sourceLabelSha256': package['sourceSha256'],
      'catalogIds': ids.toList()..sort(),
      'scope':
          'Local pure matching; no network or GPU; no acceptance threshold inferred.',
      'groups': groups,
      'samples': samples
    };
    File(output).parent.createSync(recursive: true);
    File(output)
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
  });
}
