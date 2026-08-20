import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/model_matching_service.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_content_quality.dart';

void main() {
  group('Presentation Visual Planner & Asset Matching Tests', () {
    test('NvidiaSlide parses visual plan and visual_keywords correctly', () {
      final json = {
        'title': 'Katı Hâl',
        'purpose': 'Tanecik yapısını görselleştirmek',
        'type': 'concept',
        'content': {
          'headline': 'Tanecikler sıkı dizilidir.',
          'supporting_text': 'Titreşim hareketi yaparlar.',
          'key_points': ['Sabit şekil', 'Sabit hacim']
        },
        'visual': {
          'kind': 'particle_diagram',
          'subject': 'solid_lattice',
          'caption': 'Katı kristal yapısı'
        },
        'visual_keywords': ['buz', 'kristal', 'tuz']
      };

      final slide = NvidiaSlide.fromJson(json);
      expect(slide.title, 'Katı Hâl');
      expect(slide.purpose, 'Tanecik yapısını görselleştirmek');
      expect(slide.type, 'concept');
      expect(slide.visual?['kind'], 'particle_diagram');
      expect(slide.visual?['subject'], 'solid_lattice');
      expect(slide.keywords, contains('buz'));
      expect(slide.keywords, contains('tuz'));
      expect(slide.content, contains('Tanecikler sıkı dizilidir.'));
    });

    test('Visual potential score rewards physical keywords and penalizes abstract corporate words', () {
      final goodSamples = [
        const PresentationContentSample(
          title: 'Katı Hâl',
          content: 'Tanecikler birbirine yakındır.',
          keywords: ['buz', 'kristal', 'demir', 'molekul'],
        ),
      ];

      final goodResult = PresentationContentQuality.evaluateQuality(goodSamples);
      expect(goodResult.visualPotential, 5);

      final badSamples = [
        const PresentationContentSample(
          title: 'Katı Hâl',
          content: 'Tanecikler birbirine yakındır.',
          keywords: ['strateji', 'degerlendirme', 'tarihce', 'cikarim'],
        ),
      ];

      final badResult = PresentationContentQuality.evaluateQuality(badSamples);
      expect(badResult.visualPotential, lessThan(5));
    });

    test('ModelMatchingService returns empty match for completely unrelated keywords', () async {
      final matcher = ModelMatchingService();
      final matches = await matcher.matchModelsForSlide(['tamamen_alakasiz_uydurma_kelime_xyz123']);
      expect(matches, isEmpty);
    });
  });
}
