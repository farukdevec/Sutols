import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_export_builder.dart';

void main() {
  List<PresentationPage> buildThirtyPages() => List<PresentationPage>.generate(
        30,
        (index) => PresentationPage(
          id: 'export-page-${index + 1}',
          textBlocks: <PresentationTextBlock>[
            PresentationTextBlock(
              id: 'title-${index + 1}',
              text: 'Benzersiz Slayt ${index + 1}',
              position: const Offset(0.08, 0.12),
              fontSize: 48,
              type: PresentationTextType.title,
              widthFactor: 0.84,
            ),
          ],
        ),
        growable: false,
      );

  test('HTML dışa aktarma 30 sayfanın tamamını ve gezinmesini içerir', () {
    final document = buildPresentationExportHtml(
      pages: buildThirtyPages(),
    );

    expect(
      RegExp('class="sutol-export-slide(?: is-active)?"').allMatches(document),
      hasLength(30),
    );
    expect(document, isNot(contains('class="sutol-export-dot')));
    for (var index = 1; index <= 30; index += 1) {
      expect(document, contains('data-page-id="export-page-$index"'));
      expect(document, contains('Benzersiz Slayt $index'));
    }
  });

  test('PDF baskı çıktısı 30 slaydın tamamını ayrı sayfa olarak hazırlar', () {
    final document = buildPresentationExportHtml(
      pages: buildThirtyPages(),
      printMode: true,
    );

    expect(document, contains('.sutol-export-shell.print-mode'));
    expect(document, contains('page-break-after: always'));
    expect(document, contains('page-break-after: auto'));
    expect(document, contains('page-break-inside: avoid'));
    expect(
      RegExp('class="sutol-export-slide(?: is-active)?"').allMatches(document),
      hasLength(30),
    );
    expect(
      RegExp('data-sutol-render-mode="snapshot"').allMatches(document),
      hasLength(30),
    );
    for (var index = 1; index <= 30; index += 1) {
      expect(document, contains('data-page-id="export-page-$index"'));
    }
  });

  test('HTML çıktısı görselin düzenlenmiş çerçeve ölçülerini korur', () {
    const imageId = 'pexels-test-image';
    final document = buildPresentationExportHtml(
      pages: const <PresentationPage>[
        PresentationPage(
          id: 'image-page',
          textBlocks: <PresentationTextBlock>[],
          componentBlocks: <PresentationComponentBlock>[
            PresentationComponentBlock(
              id: 'image-block',
              imageAssetId: imageId,
              imageAspectRatio: 1.5,
              position: Offset(.12, .18),
              size: Size(.37, .42),
            ),
          ],
        ),
      ],
      imageSourcesById: const <String, String>{
        imageId: 'data:image/png;base64,AA==',
      },
    );

    expect(
      document,
      contains(
        'data-sutol-component-id="image-block" data-reveal-step="0" '
        'data-animation-step="0" aria-label="pexels-test-image" '
        'style="left:12.00%;top:18.00%;width:37.00%;height:42.00%;',
      ),
    );
    expect(document, contains('object-fit: cover;'));
    expect(document, isNot(contains('object-fit: contain;')));
  });
}
