import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  test('Live Production Benchmark: 10 slides Chernobyl disaster generation', () async {
    print('===============================================================');
    print('[CANLI BENCHMARK] 10 Slaytlık Çernobil Nükleer Faciası Testi');
    print('===============================================================');

    final service = NvidiaPresentationService();
    final stopwatch = Stopwatch()..start();

    final presentation = await service.generatePresentation(
      'Çernobil Nükleer Faciası',
      slideCount: 10,
      language: 'turkish',
      checkQuality: true,
    );

    stopwatch.stop();
    final elapsedSec = (stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2);

    expect(presentation.slides.length, 10);

    final samples = presentation.slides
        .map((s) => PresentationContentSample(title: s.title, content: s.content))
        .toList();

    final score = PresentationContentQuality.calculateQualityScore(samples);
    expect(score, greaterThanOrEqualTo(80));

    print('\n[TEST SONUCU: BAŞARILI]');
    print('Toplam Süre: ${elapsedSec}s');
    print('Üretilen Slayt Sayısı: ${presentation.slides.length}');
    print('Kalite Skoru: $score/100');
  }, timeout: const Timeout(Duration(minutes: 4)));
}
