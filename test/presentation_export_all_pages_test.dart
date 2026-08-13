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
    expect(
      RegExp('class="sutol-export-dot(?: is-active)?"').allMatches(document),
      hasLength(30),
    );
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
}
