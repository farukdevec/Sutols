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

    test('tek cümlelik ve döngüsel/totolojik içeriği reddeder', () {
      final slides = <PresentationContentSample>[
        const PresentationContentSample(
          title: 'Bilgisayarların Gelişimi',
          content:
              '- Bilgisayarların gelişimiyle teknolojik gelişmeler hızlandı.',
        ),
        const PresentationContentSample(
          title: 'Mobil Teknolojilerin Gelişimi',
          content:
              '- Mobil teknolojilerin gelişimiyle teknolojik gelişmeler daha da hızlandı.',
        ),
        const PresentationContentSample(
          title: 'Gelecek',
          content:
              '- Teknolojik gelişmelerin gelecekteki etkileri henüz bilinmemektedir.',
        ),
      ];

      final reason = PresentationContentQuality.rejectionReason(slides);
      expect(reason, isNotNull);
      expect(
        reason == 'Döngüsel/totolojik içerik var.' ||
            reason ==
                'Yetersiz içerik derinliği: Her slayt en az 3 madde içermelidir.',
        isTrue,
      );
    });

    test('birbirinin kopyası gibi duran yüksek benzerlikli slaytları reddeder',
        () {
      final slides = <PresentationContentSample>[
        const PresentationContentSample(
          title: 'Yapay Zeka Ve Yazılım',
          content:
              '- Otomatik kodlama araçları yazılımcıların verimliliğini artırıyor.\n'
              '- Algoritmalar hata tespitini ve test süreçlerini hızlandırıyor.\n'
              '- Yapay zeka destekli kod tamamlama sistemleri yaygınlaşıyor.',
        ),
        const PresentationContentSample(
          title: 'Yapay Zeka Ve Programlama',
          content:
              '- Otomatik kodlama araçları yazılımcıların verimliliğini artırıyor.\n'
              '- Algoritmalar hata tespitini ve test süreçlerini hızlandırıyor.\n'
              '- Yapay zeka destekli kod tamamlama araçları yaygınlaşıyor.',
        ),
        const PresentationContentSample(
          title: 'Geleceğin Yazılım Dünyası',
          content:
              '- Derleme teknolojileri performans optimizasyonu sağlıyor.\n'
              '- Bulut tabanlı geliştirme ortamları erişilebilirliği artırıyor.\n'
              '- Siber güvenlik odaklı mimariler önem kazanıyor.',
        ),
      ];

      final reason = PresentationContentQuality.rejectionReason(slides);
      expect(reason, isNotNull);
      expect(
        reason!.contains('aşırı tekrar') || reason.contains('tekrarlanıyor'),
        isTrue,
      );
    });

    test('Slayt N önekli başlığı reddeder ve sanitizeTitle temizler', () {
      final slides = <PresentationContentSample>[
        const PresentationContentSample(
          title: 'Slayt 1: Teknolojik Gelişmelerin Hızı',
          content:
              '- 1970’lerde mikroişlemcilerin icadıyla bilgi işleme kapasitesi arttı.\n'
              '- 1990’larda internetin yaygınlaşması küresel iletişimi değiştirdi.\n'
              '- 2020’lerde yapay zeka entegrasyonu sanayi süreçlerini dönüştürdü.',
        ),
        const PresentationContentSample(
          title: 'Slide 2 - Bilgisayarların Gelişimi',
          content: '- ENIAC gibi ilk bilgisayarlar oda büyüklüğündeydi.\n'
              '- Transistörlerin icadı cihaz boyutlarını küçülttü.\n'
              '- Kuantum bilgisayarlar karmaşık simülasyonları mümkün kılıyor.',
        ),
        const PresentationContentSample(
          title: 'Gelecek Vizyonu',
          content: '- Otonom sistemler lojistik süreçlerini yönetiyor.\n'
              '- Yenilenebilir enerji odaklı veri merkezleri kuruluyor.\n'
              '- Biyoteknoloji ve yapay zeka kesişim alanları genişliyor.',
        ),
      ];

      expect(
        PresentationContentQuality.rejectionReason(slides),
        contains('gereksiz "Slayt N:" öneki'),
      );
      expect(
        PresentationContentQuality.sanitizeTitle(
            'Slayt 1: Teknolojik Gelişmelerin Hızı'),
        equals('Teknolojik Gelişmelerin Hızı'),
      );
      expect(
        PresentationContentQuality.sanitizeTitle(
            'Slide 2 - Bilgisayarların Gelişimi'),
        equals('Bilgisayarların Gelişimi'),
      );
    });

    test('veri içermeyen jenerik/boş anlatımı reddeder', () {
      final slides = <PresentationContentSample>[
        const PresentationContentSample(
          title: 'Giriş',
          content: '- Bilgisayarlar son 10 yılda büyük bir dönüşüm geçirdi.\n'
              '- Artık daha hızlı, daha güçlü ve daha küçük.\n'
              '- Mobil cihazlar yaygınlaştı.',
        ),
        const PresentationContentSample(
          title: 'Sonuç',
          content: '- Bilgisayarların geleceği parlak görünüyor.\n'
              '- Teknolojideki değişimler devam edecek.\n'
              '- Daha fazla inovasyon ve gelişim bekleniyor.',
        ),
      ];

      final reason = PresentationContentQuality.rejectionReason(slides);
      expect(reason, equals('Jenerik/boş anlatım var.'));
    });
  });
}
