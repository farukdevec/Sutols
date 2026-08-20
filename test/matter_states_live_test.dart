import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  test('Live Real Test: Ortaokul Düzeyinde Maddenin Halleri (7 Slayt)', () async {
    print('===============================================================');
    print('[CANLI TEST] Ortaokul Düzeyinde Maddenin Halleri Konusu (7 Slayt)');
    print('===============================================================');

    final service = NvidiaPresentationService();
    final stopwatch = Stopwatch()..start();

    final presentation = await service.generatePresentation(
      'ortaokul düzeyinde maddenin halleri konusu',
      slideCount: 7,
      language: 'turkish',
      checkQuality: true,
    );

    stopwatch.stop();
    final elapsedSec = (stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2);

    print('\n[TEST SONUCU: BAŞARILI]');
    print('Toplam Süre: ${elapsedSec}s');
    print('Üretilen Slayt Sayısı: ${presentation.slides.length}');

    final samples = presentation.slides
        .map((s) => PresentationContentSample(
              title: s.title,
              content: s.content,
              type: s.type,
              purpose: s.purpose,
              keywords: s.keywords,
              visual: s.visual,
            ))
        .toList();

    final quality = PresentationContentQuality.evaluateQuality(
      samples,
      targetAudience: 'ortaokul',
    );

    print('\n[KALİTE DEĞERLENDİRME RAPORU]');
    print('Genel Skor: ${quality.overallScore}/100');
    print('Factual Accuracy: ${quality.factualAccuracy}/20');
    print('Audience Fit: ${quality.audienceFit}/20');
    print('Pedagogical Value: ${quality.pedagogicalValue}/20');
    print('Narrative Coherence: ${quality.narrativeCoherence}/15');
    print('Redundancy: ${quality.redundancy}/10');
    print('Readability: ${quality.readability}/10');
    print('Visual Potential: ${quality.visualPotential}/5');

    print('\n================ SLAYTLAR VE İÇERİK KALİTESİ ================');
    for (var i = 0; i < presentation.slides.length; i++) {
      final s = presentation.slides[i];
      print('\n--- SLAYT ${i + 1}: ${s.title} [${s.type.toUpperCase()}] ---');
      if (s.purpose != null) print('Purpose: ${s.purpose}');
      if (s.visual != null) print('Visual: ${s.visual}');
      print('Keywords: ${s.keywords.join(", ")}');
      print('İçerik:\n${s.content}');
    }
    print('\n===============================================================');

    expect(presentation.slides.length, greaterThanOrEqualTo(6));
    expect(quality.overallScore, greaterThanOrEqualTo(85));
    expect(quality.audienceFit, greaterThanOrEqualTo(16));
    expect(quality.pedagogicalValue, greaterThanOrEqualTo(16));
  }, timeout: const Timeout(Duration(minutes: 4)));
}
