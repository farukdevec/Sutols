import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  test('bileşen küçük resmi gerçek bileşen HTMLini hafif belgede kullanır', () {
    final document = buildHtmlComponentPreviewDocument(
      PresentationComponentKind.edebiyat01,
    );

    expect(document, contains('sutol-edeb-01'));
    expect(document, contains('sutol-component-preview'));
    expect(document, contains('animation:none!important'));
    expect(document, isNot(contains('sutol-bg-scene-frame')));
    expect(document.length, lessThan(30000));
  });
}
