import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/services/presentation_deck_builder.dart';
import 'package:sutol/services/model_matching_service.dart';

void main() {
  test('export a deliberately narrow Turkish title for browser verification',
      () {
    final html = buildPresentationExportHtml(
        title: 'Metin taşma regresyonu',
        compact: false,
        pages: const [
          PresentationPage(id: 'regression', textBlocks: [
            PresentationTextBlock(
                id: 'narrow-title',
                text:
                    'Kişiselleştirilmiş Öğrenme ve Öğretmen Gözetiminde Yapay Zekâ',
                type: PresentationTextType.title,
                fontSize: 48,
                position: Offset(.08, .08),
                widthFactor: .28,
                heightFactor: .04,
                overflow: PresentationTextOverflow.shrink,
                textAnimation: PresentationTextAnimation.none),
          PresentationTextBlock(
              id: 'body',
              type: PresentationTextType.body,
                text:
                    '• **Öğretmen Denetimi:** Öğretmen önerileri kontrol eder.\n• **Uyarlama:** Alıştırmalar öğrencinin hızına göre değişir.',
                fontSize: 28,
                position: Offset(.08, .55),
                widthFactor: .80,
                heightFactor: .26,
                overflow: PresentationTextOverflow.shrink,
                textAnimation: PresentationTextAnimation.none),
          ], componentBlocks: []),
        ]);
    expect(html, contains('<strong>Öğretmen Denetimi:</strong>'));
    expect(html, contains('window.SutolFitText = fitAllText'));
    expect(html, contains('window.SutolFitText?.();'));
    final output = Directory('build/verification')..createSync(recursive: true);
    File('${output.path}/text-layout-regression.html').writeAsStringSync(html);
    final matches = ModelMatchingService.rankCatalogModels(
      models: ModelMatchingService.localCatalogEntries,
      keywords: ['Anıtkabir', 'Mustafa Kemal Atatürk', 'Ankara anıt mezar'],
    );
    final model = ModelMatchingService.bestStrongMatchPreferUnused(matches, {});
    expect(model?.id, 'anitkabir');
    final pages = const PresentationDeckBuilder().buildPages(topic: 'Anıtkabir', slides: [
      DeckSlide(title: 'Anıtkabir', content: '• **Anıt Mezar:** Atatürk’ün anıt mezarı Ankara’da bulunur.',
        type: 'concept', models: [model!]),
    ]);
    File('${output.path}/model-framing-regression.html').writeAsStringSync(
      buildPresentationExportHtml(pages: pages, title: 'Otomatik 3B kadraj doğrulaması', compact: false,
        modelSourcesById: {'anitkabir': '/web/models/anitkabir.glb'}));
  }, skip: !const bool.fromEnvironment('SUTOLS_RENDER_VERIFY'));
}
