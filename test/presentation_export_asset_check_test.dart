import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/presentation_export_asset_check.dart';

void main() {
  PresentationComponentBlock model(String id, {String? image}) =>
      PresentationComponentBlock(
          id: id,
          modelAssetId: id,
          imageAssetId: image,
          position: Offset.zero,
          size: const Size(.3, .3));
  test('missing models across all pages are reported once before downloading',
      () {
    final pages = [
      PresentationPage(
          id: 'a',
          textBlocks: [],
          componentBlocks: [model('one'), model('two')]),
      PresentationPage(
          id: 'b',
          textBlocks: [],
          componentBlocks: [model('two'), model('three')])
    ];
    expect(
        () => requireEmbeddedExportModels(
            pages: pages, modelSources: {'one': 'data:glb', 'three': ''}),
        throwsA(isA<PresentationExportAssetException>()
            .having((e) => e.missingModelIds, 'IDs', {'two', 'three'})));
    requireEmbeddedExportModels(pages: pages, modelSources: {
      'one': 'data:glb',
      'two': 'data:glb',
      'three': 'data:glb'
    });
    expect(pages[1].componentBlocks, hasLength(2));
  });
  test('image IDs and ordinary components do not require model downloads', () {
    final pages = [
      PresentationPage(id: 'p', textBlocks: [], componentBlocks: [
        model('image', image: 'uploaded'),
        model('legacy-image'),
        const PresentationComponentBlock(
            id: 'shape', position: Offset.zero, size: Size(.2, .2))
      ])
    ];
    requireEmbeddedExportModels(
        pages: pages, modelSources: {}, imageIds: {'legacy-image'});
    requireEmbeddedExportModels(pages: [], modelSources: {});
  });
}
