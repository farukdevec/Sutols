// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:http/http.dart' as http;

import '../models/slide_model.dart';
import 'model_asset_service.dart';
import 'presentation_export_builder.dart';
import 'remote_image_sources.dart';
import 'remote_model_sources.dart';

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
    imageSourcesById: RemoteImageSources.all,
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
    imageSourcesById: RemoteImageSources.all,
    printMode: true,
  ).replaceFirst(
    '</body>',
    '''
<script>
window.addEventListener('load', async function () {
  try {
    if (document.fonts && document.fonts.ready) await document.fonts.ready;
  } catch (_) {}

  const frames = Array.from(document.querySelectorAll('iframe'));
  await Promise.all(frames.map(function (frame) {
    try {
      if (frame.contentDocument && frame.contentDocument.readyState === 'complete') {
        return Promise.resolve();
      }
    } catch (_) {}
    return new Promise(function (resolve) {
      const timeout = setTimeout(resolve, 1800);
      frame.addEventListener('load', function () {
        clearTimeout(timeout);
        resolve();
      }, { once: true });
    });
  }));

  setTimeout(function () { window.print(); }, 250);
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
    final cached = _embeddedModelSourceCache[modelId];
    if (cached != null) {
      sources[modelId] = cached;
      continue;
    }
    var source = RemoteModelSources.sourceFor(modelId);
    if (source == null || source.trim().isEmpty) {
      source = modelId;
    }
    final signedUrl = await ModelAssetService.generateSignedUrl(source);
    if (signedUrl == null || !signedUrl.contains('token=')) {
      continue;
    }
    final fetchUrl = signedUrl;


    try {
      final response = await http.get(Uri.parse(fetchUrl));
      if (response.statusCode != 200) {
        continue;
      }
      await Future<void>.delayed(Duration.zero);
      final embedded =
          'data:model/gltf-binary;base64,${base64Encode(response.bodyBytes)}';
      _embeddedModelSourceCache[modelId] = embedded;
      sources[modelId] = embedded;
    } catch (_) {
      continue;
    }
  }

  return sources;
}

final Map<String, String> _embeddedModelSourceCache = <String, String>{};

