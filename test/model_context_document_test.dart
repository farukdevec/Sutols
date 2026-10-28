import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_export_builder.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  const page = PresentationPage(
      id: 'context-document',
      textBlocks: [],
      componentBlocks: [
        PresentationComponentBlock(
            id: 'wind',
            modelAssetId: 'sutols-wind-turbine',
            position: Offset.zero,
            size: Size(1, 1),
            modelAnimationName: 'RotorSpin',
            modelAnimationTime: 1.5,
            modelAnimationEnabled: false)
      ]);
  test('preview and HTML export contain the same native recovery handler', () {
    for (final markup in [
      buildHtmlStageDocument(page: page),
      buildPresentationExportHtml(pages: [page], compact: false)
    ]) {
      expect(markup, contains('window.SutolModelContextRecovery'));
      expect(markup, contains('webglcontextrestored'));
      expect(markup, contains('recovery.handle(this,event)'));
      expect(markup, contains('data-sutol-animation-time="1.5"'));
      expect(markup, contains('recovery.loaded(this)'));
    }
  });
}
