import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_content_quality.dart';
import 'package:sutol/services/presentation_deck_builder.dart';
import 'package:sutol/services/safe_json_parser.dart';

void main() {
  group('Presentation Narrative Architecture & Enhanced Schema Tests', () {
    test('SafeJsonParser parses enriched slide structure with all metadata', () {
      const jsonPayload = '''
      {
        "slides": [
          {
            "title": "Radyoaktivite insanlara nasıl ulaştı?",
            "subtitle": "Atmosferik yayılım ve besin zinciri maruziyeti",
            "type": "cause_effect",
            "purpose": "Radyasyon maruziyet mekanizmalarını açıklamak",
            "key_message": "İyot-131 ve Sezyum-137 farklı yollarla insan vücuduna girdi",
            "sections": [
              {
                "heading": "Doğrudan Soluma",
                "description": "Radyoaktif bulutun geçişi sırasında solunum yoluyla ilk maruziyet gerçekleşti."
              },
              {
                "heading": "Besin Zinciri",
                "description": "Kontamine otları tüketen hayvanların sütüyle İyot-131 çocuklara geçti."
              }
            ],
            "visual": {
              "type": "cause_effect",
              "data": ["Atmosfere Salınım", "Toprak Kontaminasyonu", "İnsan Tüketimi"]
            },
            "keywords": ["radyasyon", "iyot", "sezyum"],
            "sources": ["UNSCEAR 2008 Raporu", "DSÖ Çernobil Sağlık Verileri"]
          }
        ]
      }
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(jsonPayload);
      SafeJsonParser.validateSchema(parsed);
      SafeJsonParser.validateContent(parsed);

      final pres = NvidiaPresentation.fromJson(parsed);
      expect(pres.slides.length, 1);
      final slide = pres.slides.first;

      expect(slide.title, 'Radyoaktivite insanlara nasıl ulaştı?');
      expect(slide.subtitle, 'Atmosferik yayılım ve besin zinciri maruziyeti');
      expect(slide.type, 'cause_effect');
      expect(slide.purpose, 'Radyasyon maruziyet mekanizmalarını açıklamak');
      expect(slide.keyMessage, 'İyot-131 ve Sezyum-137 farklı yollarla insan vücuduna girdi');
      expect(slide.sections?.length, 2);
      expect(slide.visual?['type'], 'cause_effect');
      expect(slide.sources, contains('UNSCEAR 2008 Raporu'));
      expect(slide.content, contains('Doğrudan Soluma'));
      expect(slide.content, contains('Besin Zinciri'));
    });

    test('SafeJsonParser synthesizes content when model only provides sections', () {
      const jsonWithoutContent = '''
      {
        "slides": [
          {
            "title": "Felakete Yol Açan Faktörler",
            "type": "cards",
            "sections": [
              {"heading": "Tasarım Kusurları", "description": "RBMK-1000 reaktörünün pozitif boşluk katsayısı dengesizlik yarattı."},
              {"heading": "Güvenlik İhlalleri", "description": "Test sırasında acil durum koruma sistemleri devre dışı bırakıldı."}
            ]
          }
        ]
      }
      ''';

      final parsed = SafeJsonParser.parsePresentationPayload(jsonWithoutContent);
      SafeJsonParser.validateSchema(parsed);
      SafeJsonParser.validateContent(parsed);

      final slide = NvidiaSlide.fromJson((parsed['slides'] as List)[0] as Map<String, dynamic>);
      expect(slide.content, contains('- **Tasarım Kusurları:** RBMK-1000 reaktörünün pozitif boşluk katsayısı dengesizlik yarattı.'));
      expect(slide.content, contains('- **Güvenlik İhlalleri:** Test sırasında acil durum koruma sistemleri devre dışı bırakıldı.'));
    });

    test('PresentationDeckBuilder builds distinct layout with subtitle and quote', () {
      final slides = [
        const DeckSlide(
          title: 'Çernobil Nükleer Faciası ve Sağlık Etkileri',
          subtitle: 'Tarihin en büyük nükleer kazasının bilimsel anatomisi',
          content: '26 Nisan 1986 gecesi meydana gelen patlama, nükleer güvenlik ve halk sağlığı standartlarını kökten değiştirdi.',
          type: 'hero',
          models: [],
        ),
        const DeckSlide(
          title: 'Tarihsel Bir Uyarı',
          content: 'Nükleer enerji teknolojisinde insan hatası ve tasarım kusurları affedilmez sonuçlar doğurur.',
          type: 'quote',
          models: [],
        ),
      ];

      final pages = const PresentationDeckBuilder().buildPages(
        topic: 'Çernobil',
        slides: slides,
      );

      expect(pages.length, 2);

      // Slide 1 (Hero) should contain title, subtitle, and body
      final heroPage = pages[0];
      final titleBlock = heroPage.textBlocks.firstWhere((b) => b.type == PresentationTextType.title);
      final subtitleBlock = heroPage.textBlocks.firstWhere((b) => b.type == PresentationTextType.subtitle);
      final bodyBlock = heroPage.textBlocks.firstWhere((b) => b.type == PresentationTextType.body);

      expect(titleBlock.text, contains('Çernobil'));
      expect(subtitleBlock.text, contains('bilimsel anatomisi'));
      expect(bodyBlock.text, contains('patlama'));
      expect(titleBlock.position.dy, lessThan(subtitleBlock.position.dy));
      expect(subtitleBlock.position.dy, lessThan(bodyBlock.position.dy));

      // Slide 2 (Quote) should have italic quote block
      final quotePage = pages[1];
      final quoteBody = quotePage.textBlocks.firstWhere((b) => b.type == PresentationTextType.body);
      expect(quoteBody.textItalic, isTrue);
      expect(quoteBody.textStyle, PresentationTextStyle.klasikLora);
    });

    test('PresentationContentQuality rejects decks consisting exclusively of dry date bullets', () {
      final dryDateSlides = List.generate(
        8,
        (i) => PresentationContentSample(
          title: 'Kronoloji Başlık $i',
          content: '- 26 Nisan 1986: Patlama meydana geldi.\n'
              '- 27 Nisan 1986: Pripyat tahliye edildi.\n'
              '- 28 Nisan 1986: İsveç radyasyon artışını tespit etti.',
        ),
      );

      final reason = PresentationContentQuality.rejectionReason(dryDateSlides);
      expect(reason, isNotNull);
      expect(reason, contains('monoton tarih listesi'));
    });
  });
}
