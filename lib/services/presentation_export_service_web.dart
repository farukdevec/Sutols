// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:http/http.dart' as http;

import '../models/slide_model.dart';
import 'model_asset_service.dart';
import 'embedded_model_cache.dart';
import 'presentation_export_builder.dart';
import 'presentation_export_asset_check.dart';
import 'print_export_session.dart';
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
  requireEmbeddedExportModels(
      pages: pages,
      modelSources: modelSourcesById,
      imageIds: RemoteImageSources.all.keys.toSet());
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
  // Blob download navigation starts asynchronously in some browsers.
  // Release after it has had time to acquire the content, not after click().
  unawaited(Future<void>.delayed(const Duration(seconds: 1), () {
    html.Url.revokeObjectUrl(url);
  }));
}

Future<void> exportPresentationAsPdfViaPrint({
  required List<PresentationPage> pages,
  PresentationEffectSettings effectSettings =
      const PresentationEffectSettings(),
  String? title,
}) async {
  String? documentUrl;
  try {
    await preparePrintExport(
      openTarget: () {
        final window = (html.window as JSObject).callMethod<JSObject?>(
            'open'.toJS, 'about:blank'.toJS, '_blank'.toJS);
        if (window == null) return null;
        window.setProperty('opener'.toJS, null);
        final document = window.getProperty<JSObject>('document'.toJS);
        document.setProperty('title'.toJS, 'Sutols — PDF hazırlanıyor'.toJS);
        document.getProperty<JSObject>('body'.toJS).setProperty(
            'textContent'.toJS, 'PDF hazırlanıyor… / Preparing PDF…'.toJS);
        return _BrowserPrintTarget(window);
      },
      prepareDocument: () async {
        final modelPostersById = await _embeddedModelPosters(pages);
        final htmlDocument = buildPresentationExportHtml(
          pages: pages,
          effectSettings: effectSettings,
          title: title,
          modelPosterSourcesById: modelPostersById,
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
        final blob =
            html.Blob(<Object>[htmlDocument], 'text/html;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        documentUrl = url;
        return url;
      },
    );
  } finally {
    final url = documentUrl;
    if (url != null) {
      unawaited(
        Future<void>.delayed(const Duration(seconds: 45), () {
          html.Url.revokeObjectUrl(url);
        }),
      );
    }
  }
}

class _BrowserPrintTarget implements PrintExportTarget {
  _BrowserPrintTarget(this.window);
  final JSObject window;

  @override
  bool get isClosed => window.getProperty<JSBoolean>('closed'.toJS).toDart;

  @override
  void navigate(String documentUrl) {
    window
        .getProperty<JSObject>('location'.toJS)
        .callMethod<JSAny?>('replace'.toJS, documentUrl.toJS);
  }

  @override
  void close() => window.callMethod<JSAny?>('close'.toJS);
}

Future<Map<String, String>> _embeddedModelSources(
  List<PresentationPage> pages,
) async {
  final modelIds = pages
      .expand((page) => page.componentBlocks)
      .where((block) =>
          block.imageAssetId == null &&
          !RemoteImageSources.all.containsKey(block.modelAssetId))
      .map((block) => block.modelAssetId)
      .whereType<String>()
      .toSet();
  final sources = <String, String>{};

  for (final modelId in modelIds) {
    var source = RemoteModelSources.sourceFor(modelId);
    if (source == null || source.trim().isEmpty) {
      source = RemoteModelSources.sourceForRefresh(modelId) ?? modelId;
    }
    final local = ModelAssetService.isLocalAssetPath(source);
    final version = findPresentation3DModelAsset(modelId)?.sha256 ?? '';
    final cached = local
        ? _embeddedModelSourceCache.lookup(
            source: source, assetVersion: version)
        : null;
    if (cached != null) {
      sources[modelId] = cached;
      continue;
    }
    final fetchUrl = local
        ? Uri.base.resolve(source).toString()
        : await ModelAssetService.generateSignedUrl(source);
    if (fetchUrl == null || fetchUrl.isEmpty) continue;

    try {
      final response = await http
          .get(Uri.parse(fetchUrl))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        continue;
      }
      await Future<void>.delayed(Duration.zero);
      final embedded =
          'data:model/gltf-binary;base64,${base64Encode(response.bodyBytes)}';
      if (local) {
        _embeddedModelSourceCache.store(
            source: source, assetVersion: version, data: embedded);
      }
      sources[modelId] = embedded;
    } catch (_) {
      continue;
    }
  }

  return sources;
}

final _embeddedModelSourceCache = EmbeddedModelCache();

// Print needs a static image, not a second download of the GLB. Embed local
// posters so the blob document does not resolve /model_thumbnails off-origin.
Future<Map<String, String>> _embeddedModelPosters(
  List<PresentationPage> pages,
) async {
  final ids = pages
      .expand((page) => page.componentBlocks)
      .map((block) => block.modelAssetId)
      .whereType<String>()
      .toSet();
  final posters = <String, String>{};
  await Future.wait(ids.map((id) async {
    final asset = findPresentation3DModelAsset(id);
    final path = asset?.thumbnailPath;
    if (asset?.preferBundledAsset != true ||
        path == null ||
        !path.startsWith('/model_thumbnails/')) return;
    try {
      final response = await http
          .get(Uri.base.resolve(path))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return;
      final extension = Uri.parse(path).path.split('.').last.toLowerCase();
      final mime = switch (extension) {
        'webp' => 'image/webp',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        _ => null,
      };
      if (mime == null) return;
      posters[id] = 'data:$mime;base64,${base64Encode(response.bodyBytes)}';
    } catch (_) {
      // Keep the model identity fallback if a poster is unavailable.
    }
  }));
  // An unavailable poster must not leave an origin-relative image in print.
  for (final id in ids) {
    posters.putIfAbsent(id, () => 'unavailable');
  }
  return posters;
}
