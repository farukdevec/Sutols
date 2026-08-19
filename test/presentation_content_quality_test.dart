import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  test('sunum planını anlatan üst-anlatıyı reddeder', () {
    const slides = <PresentationContentSample>[
      PresentationContentSample(
        title: 'Konuya Giriş',
        content: '- Sunumun izleyeceği düşünce hattı açıklanır.',
      ),
    ];

    expect(
      PresentationContentQuality.rejectionReason(slides),
      contains('üst-anlatı'),
    );
  });

  test('somut konu anlatımını kabul eder', () {
    const slides = <PresentationContentSample>[
      PresentationContentSample(
        title: 'Fotosentez',
        content:
            '- Bitkiler ışık enerjisini kullanarak su ve karbondioksitten glikoz üretir.',
      ),
    ];

    expect(PresentationContentQuality.rejectionReason(slides), isNull);
  });
}
