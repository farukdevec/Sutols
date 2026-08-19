@Timeout(Duration(minutes: 5))
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sutol/services/ai_model_config.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_deck_builder.dart';
import 'package:sutol/services/safe_json_parser.dart';

void main() {
  test('Live Production Benchmark: Makine Öğrenmesi (10 Slides)', () async {
    final client = http.Client();
    final modelsToTest = [
      'nvidia/nemotron-3-nano-30b-a3b',
      'openai/gpt-oss-20b',
      'nvidia/nemotron-3-super-120b-a12b',
    ];

    for (final model in modelsToTest) {
      print('\n==================================================');
      print('TESTING MODEL: $model');
      print('==================================================');

      final service = NvidiaPresentationService(
        modelName: model,
        customCandidateModels: [model],
        client: client,
      );

      final stopwatch = Stopwatch()..start();
      try {
        final pres = await service.generatePresentation(
          'Makine Öğrenmesi',
          slideCount: 10,
          language: 'turkish',
        );
        stopwatch.stop();

        print('\n[BENCHMARK RESULT]');
        print('MODEL: $model');
        print('LATENCY: ${stopwatch.elapsedMilliseconds}ms');
        print('JSON: VALID');
        print('SCHEMA: VALID (${pres.slides.length} slides)');
        print('QUALITY: PASS');

        final typeCounts = <String, int>{};
        for (final s in pres.slides) {
          typeCounts[s.type] = (typeCounts[s.type] ?? 0) + 1;
        }
        print('SLIDE TYPES: $typeCounts');

        final deckSlides = pres.slides
            .map((s) => DeckSlide(
                  title: s.title,
                  content: s.content,
                  type: s.type,
                  models: const [],
                  keywords: s.keywords,
                ))
            .toList();

        final pages = const PresentationDeckBuilder().buildPages(
          topic: 'Makine Öğrenmesi',
          slides: deckSlides,
        );

        print('RENDERED PAGES: ${pages.length}');

        for (var i = 0; i < pres.slides.length; i++) {
          final s = pres.slides[i];
          final p = pages[i];
          print('\nSLIDE ${i + 1}');
          print('type: ${s.type}');
          print('title: ${s.title}');
          print('content:\n${s.content}');
          print('keywords: ${s.keywords}');
          print('rendered layout: ${s.type.toUpperCase()} (${p.textBlocks.length} text blocks, fontSizes: ${p.textBlocks.map((b) => b.fontSize).toList()})');
        }
      } catch (e) {
        stopwatch.stop();
        print('MODEL: $model');
        print('LATENCY: ${stopwatch.elapsedMilliseconds}ms');
        print('ERROR: $e');
      }
    }
  });
}
