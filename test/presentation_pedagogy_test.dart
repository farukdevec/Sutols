import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_content_quality.dart';
import 'package:sutol/services/presentation_prompt_builder.dart';

void main() {
  group('Presentation Pedagogy and Audience Calibration Tests', () {
    test('Scenario 1: Middle School States of Matter prompts emphasize student experience over syllabus', () {
      final prompt = PresentationPromptBuilder.buildUserPrompt(
        topic: 'ortaokul düzeyinde maddenin halleri',
        slideCount: 7,
        language: 'turkish',
      );

      expect(prompt, contains('ortaokul'));
      expect(prompt, contains('ders planı'));
      expect(prompt, contains('purpose'));
      expect(prompt, contains('visual_keywords'));
    });

    test('Scenario 2: University Quantum Mechanics accepts rigorous scientific depth', () {
      final samples = [
        const PresentationContentSample(
          title: 'Dalga Fonksiyonu ve Schrödinger Denklemi',
          purpose: 'Durum vektörünün Hilbert uzayındaki gelişimini açıklamak',
          type: 'concept',
          content: '- **Olasılık Yoğunluğu:** Dalga fonksiyonunun karesi parçacığın uzaydaki bulunma olasılığını verir.\n- **Süperpozisyon:** Kuantum durumları ölçüm yapılana kadar doğrusal birleşim halinde kalır.',
          keywords: ['dalga', 'elektron', 'foton', 'atom'],
        ),
      ];

      final result = PresentationContentQuality.evaluateQuality(
        samples,
        targetAudience: 'üniversite',
      );

      expect(result.audienceFit, 20);
      expect(result.overallScore, greaterThanOrEqualTo(85));
    });

    test('Scenario 3: Corporate Business Strategy uses clean business language', () {
      final samples = [
        const PresentationContentSample(
          title: '2026 Q3 Büyüme Stratejisi ve Hedefler',
          purpose: 'Yıllık gelir artışı ve pazar penetrasyonu yol haritasını sunmak',
          type: 'takeaway',
          content: '- **Pazar Genişlemesi:** SaaS abonelik modelinde yıllık %35 ARR büyümesi hedeflenmektedir.\n- **Müşteri Edinme:** CAC optimizasyonu ile dönüşüm oranları artırılacaktır.',
          keywords: ['grafik', 'hedef', 'dijital_pano'],
        ),
      ];

      final result = PresentationContentQuality.evaluateQuality(
        samples,
        targetAudience: 'kurumsal',
      );

      expect(result.audienceFit, 20);
    });

    test('Scenario 4: History Chernobyl disaster uses logical cause-effect chronology', () {
      final samples = [
        const PresentationContentSample(
          title: '26 Nisan 1986: Kazanın Gelişimi',
          purpose: 'Test sırasındaki kritik olaylar dizisini açıklamak',
          type: 'process',
          content: '- **01:23 AZ-5 Düğmesi:** Acil durdurma çubuklarının grafit uçları reaktivite sıçraması yarattı.\n- **Buhar Patlaması:** Aşırı basınç reaktör kapağını havaya uçurdu.',
          keywords: ['reaktor', 'radyasyon', 'grafit'],
        ),
      ];

      final result = PresentationContentQuality.evaluateQuality(
        samples,
        targetAudience: 'genel',
      );

      expect(result.factualAccuracy, 20);
    });
  });
}
