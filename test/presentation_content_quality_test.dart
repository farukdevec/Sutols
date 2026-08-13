import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/fallback_slide_generator.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  List<PresentationContentSample> samplesFrom(String topic, int count) {
    final presentation = FallbackSlideGenerator.generatePresentation(
      topic,
      slideCount: count,
    );
    return presentation.slides
        .map(
          (slide) => PresentationContentSample(
            title: slide.title,
            content: slide.content,
          ),
        )
        .toList(growable: false);
  }

  group('sunum içerik kalite kontrolü', () {
    test('30 tekrarlı slaytı reddeder', () {
      final slides = List.generate(
        30,
        (index) => PresentationContentSample(
          title: 'Fen konusu',
          content: '- Fen ile ilgili temel bilgiler.\n'
              '- Fen ile ilgili önemli noktalar.\n'
              '- Fen konusunun günlük yaşamdaki yeri.',
        ),
      );

      expect(PresentationContentQuality.rejectionReason(slides), isNotNull);
    });

    test('aynı maddelerin farklı başlıklar altında tekrarını reddeder', () {
      final slides = List.generate(
        8,
        (index) => PresentationContentSample(
          title: 'Benzersiz başlık $index',
          content: '- Her slaytta yinelenen uzun ve aynı açıklama cümlesi.\n'
              '- Sadece bu slayta ait farklı kısa ayrıntı $index.',
        ),
      );

      expect(PresentationContentQuality.rejectionReason(slides), isNotNull);
    });

    test('30 sayfalık fen yedeği kalite denetiminden geçer', () {
      final slides = samplesFrom('Fen', 30);

      expect(slides.map((slide) => slide.title).toSet(), hasLength(30));
      expect(PresentationContentQuality.rejectionReason(slides), isNull);
    });

    test('genel konu yedeği farklı slayt görevleri üretir', () {
      final slides = samplesFrom('Yapay zeka ve eğitim', 30);

      expect(slides.map((slide) => slide.title).toSet(), hasLength(30));
      expect(slides.map((slide) => slide.content).toSet(), hasLength(30));
    });

    test('sunum planını anlatan üst-anlatıyı reddeder', () {
      final slides = <PresentationContentSample>[
        const PresentationContentSample(
          title: 'Konuya Giriş',
          content: '- Solunum sistemi için başlangıç noktası belirlenir.\n'
              '- Sunumun izleyeceği düşünce hattı açıklanır.',
        ),
        const PresentationContentSample(
          title: 'İşleyiş',
          content: '- Kapsam çizgisi oluşturularak konu değerlendirilir.',
        ),
        const PresentationContentSample(
          title: 'Sonuç',
          content: '- Ayrıntılar ortak bir ana soruya bağlanır.',
        ),
      ];

      expect(
        PresentationContentQuality.rejectionReason(slides),
        contains('üst-anlatı'),
      );
    });

    test('solunum sistemi yedeği gerçek konu içeriği üretir', () {
      final slides = samplesFrom('Solunum sistemi ve çalışma prensibi', 30);
      final allContent = slides.map((slide) => slide.content).join(' ');

      expect(slides, hasLength(30));
      expect(slides.map((slide) => slide.title).toSet(), hasLength(30));
      expect(allContent, contains('alveol'));
      expect(allContent, contains('diyafram'));
      expect(allContent, contains('oksijen'));
      expect(allContent, isNot(contains('düşünce hattı')));
      expect(PresentationContentQuality.rejectionReason(slides), isNull);
    });
  });
}
