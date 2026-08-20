import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  group('PresentationContentQuality 7-Dimensional Scoring Tests', () {
    test('High quality, audience-calibrated middle school presentation scores 85+ and passes', () {
      final samples = [
        const PresentationContentSample(
          title: 'Maddenin Halleri',
          purpose: 'Maddenin üç temel hâlini tanıtmak',
          type: 'concept',
          content: '- **Madde ve Tanecik:** Madde atom ve moleküllerden oluşur.\n- **Üç Temel Hâl:** Katı, sıvı ve gaz temel hâllerdir.',
          keywords: ['su', 'buz', 'buhar', 'tanecik'],
        ),
        const PresentationContentSample(
          title: 'Katı Hâl',
          purpose: 'Katıların tanecik düzenini öğretmek',
          type: 'concept',
          content: '- **Sabit Şekil ve Hacim:** Tanecikler sıkı dizilidir ve yerlerini korur.\n- **Titreşim Hareketi:** Tanecikler sadece bulundukları yerde titreşir.',
          keywords: ['buz', 'kristal', 'demir'],
        ),
        const PresentationContentSample(
          title: 'Sıvı Hâl',
          purpose: 'Sıvıların akışkanlık özelliğini açıklamak',
          type: 'concept',
          content: '- **Kabın Şeklini Alma:** Tanecikler birbirinin üzerinden kayar.\n- **Sabit Hacim:** Sıvıların belirli bir hacmi vardır.',
          keywords: ['su', 'zeytinyagi', 'bardak'],
        ),
        const PresentationContentSample(
          title: 'Gaz Hâl',
          purpose: 'Gazların serbest yayılmasını kavratmak',
          type: 'concept',
          content: '- **Serbest Hareket:** Tanecikler birbirinden uzaktır ve her yöne uçar.\n- **Sıkıştırılabilirlik:** Gazlar kolayca sıkıştırılabilir.',
          keywords: ['balon', 'hava', 'buhar'],
        ),
        const PresentationContentSample(
          title: 'Hâl Değişimleri',
          purpose: 'Isı alışverişi ile hâl değişimlerini göstermek',
          type: 'process',
          content: '- **Erime ve Buharlaşma:** Isı alan madde katıdan sıvıya ve gaza geçer.\n- **Donma ve Yoğuşma:** Isı veren madde gazdan sıvıya ve katıya döner.',
          keywords: ['isitici', 'termometre', 'buz'],
        ),
        const PresentationContentSample(
          title: 'Karşılaştırma Tablosu',
          purpose: 'Üç hâlin tanecik özelliklerini özetlemek',
          type: 'comparison',
          content: '- **Tanecik Mesafesi:** Katıda çok az, sıvıda orta, gazda çok fazla.\n- **Hareket Türü:** Katıda titreşim, sıvıda kayma, gazda serbest hareket.',
          keywords: ['karsilastirma', 'tanecik'],
        ),
        const PresentationContentSample(
          title: 'Sıra Sende: Mini Soru',
          purpose: 'Öğrenilenleri günlük hayat örneğiyle pekiştirmek',
          type: 'quiz',
          content: '- **Soru:** Güneşte bırakılan buz neden erir?\n- **Açıklama:** Isı enerjisi alan tanecikler daha hızlı hareket ederek sıvıya dönüşür.',
          keywords: ['gunes', 'buz', 'su'],
        ),
      ];

      final result = PresentationContentQuality.evaluateQuality(
        samples,
        targetAudience: 'ortaokul',
      );

      expect(result.overallScore, greaterThanOrEqualTo(85));
      expect(result.isPass, isTrue);
      expect(result.audienceFit, greaterThanOrEqualTo(18));
      expect(result.factualAccuracy, greaterThanOrEqualTo(18));
      expect(result.pedagogicalValue, greaterThanOrEqualTo(18));
    });

    test('Presentation with curriculum notes (Öğretim stratejileri) drops audience score and fails', () {
      final samples = [
        const PresentationContentSample(
          title: 'Maddenin Halleri',
          content: '- **Öğretim Stratejileri:** Öğrencilere erime ve kaynama deneyleri yaptırılmalı.\n- **Değerlendirme Ölçütü:** Q = m*c*deltaT formülü uygulanmalıdır.',
        ),
        const PresentationContentSample(
          title: 'Müfredat Hedefleri',
          content: '- **Kazanımlar:** Öğrencilerin termodinamik denklemlerini çözmesi hedeflenir.',
        ),
      ];

      final result = PresentationContentQuality.evaluateQuality(
        samples,
        targetAudience: 'ortaokul',
      );

      expect(result.audienceFit, lessThan(15));
      expect(result.slideIssues.any((i) => i['category'] == 'audience_fit'), isTrue);
    });

    test('Redundant repeated slides drop redundancy score', () {
      final samples = [
        const PresentationContentSample(
          title: 'Katılar',
          content: '- **Katı Şekli:** Katı maddeler kendi şeklini ve hacmini korur.',
        ),
        const PresentationContentSample(
          title: 'Katıların Özellikleri',
          content: '- **Katı Şekli:** Katı maddeler kendi şeklini ve hacmini korur.',
        ),
      ];

      final result = PresentationContentQuality.evaluateQuality(samples);
      expect(result.redundancy, lessThan(10));
      expect(result.slideIssues.any((i) => i['category'] == 'redundancy'), isTrue);
    });
  });
}
