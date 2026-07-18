// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/services.dart';

import '../models/slide_model.dart';
import 'presentation_export_builder.dart';

Future<void> exportPresentationAsHtml({
  required List<PresentationPage> pages,
  PresentationEffectSettings effectSettings =
      const PresentationEffectSettings(),
  String? fileName,
  String? title,
}) async {
  final modelSourcesById = await _embeddedModelSources(pages);
  final htmlDocument = buildPresentationExportHtml(
    pages: pages,
    effectSettings: effectSettings,
    title: title,
    modelSourcesById: modelSourcesById,
  );
  final blob = html.Blob(<Object>[htmlDocument], 'text/html;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName ?? 'sutol-demo-sunumu.html'
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

Future<void> exportPresentationAsPdfViaPrint({
  required List<PresentationPage> pages,
  PresentationEffectSettings effectSettings =
      const PresentationEffectSettings(),
  String? title,
}) async {
  final modelSourcesById = await _embeddedModelSources(pages);
  final htmlDocument = buildPresentationExportHtml(
    pages: pages,
    effectSettings: effectSettings,
    title: title,
    modelSourcesById: modelSourcesById,
  ).replaceFirst(
    '</body>',
    '''
<script>
window.addEventListener('load', function () {
  setTimeout(function () { window.print(); }, 350);
});
</script>
</body>''',
  );
  final blob = html.Blob(<Object>[htmlDocument], 'text/html;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  unawaited(
    Future<void>.delayed(const Duration(seconds: 45), () {
      html.Url.revokeObjectUrl(url);
    }),
  );
}

Future<Map<String, String>> _embeddedModelSources(
  List<PresentationPage> pages,
) async {
  final modelIds = pages
      .expand((page) => page.componentBlocks)
      .map((block) => block.modelAssetId)
      .whereType<String>()
      .toSet();
  final sources = <String, String>{};

  for (final modelId in modelIds) {
    final model = findPresentation3DModelAsset(modelId);
    if (model == null) {
      continue;
    }
    final cached = _embeddedModelSourceCache[model.id];
    if (cached != null) {
      sources[model.id] = cached;
      continue;
    }
    final data = await rootBundle.load(model.assetPath);
    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await Future<void>.delayed(Duration.zero);
    final source = 'data:model/gltf-binary;base64,${base64Encode(bytes)}';
    _embeddedModelSourceCache[model.id] = source;
    sources[model.id] = source;
  }

  return sources;
}

final Map<String, String> _embeddedModelSourceCache = <String, String>{};
