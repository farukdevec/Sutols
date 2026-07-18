// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import '../models/slide_model.dart';
import 'presentation_project_codec.dart';

Future<void> savePresentationProjectAsJson({
  required List<PresentationPage> pages,
  required PresentationEffectSettings effectSettings,
  String? fileName,
}) async {
  final source = PresentationProjectCodec.encodeProject(
    pages: pages,
    effectSettings: effectSettings,
  );
  final blob = html.Blob(<Object>[source], 'application/json;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName ?? 'sutol-sunum-projesi.json'
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

Future<PresentationProject?> loadPresentationProjectFromJson() async {
  final completer = Completer<PresentationProject?>();
  final input = html.FileUploadInputElement()
    ..accept = '.json,application/json'
    ..style.display = 'none';

  html.document.body?.children.add(input);
  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      input.remove();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return;
    }

    final reader = html.FileReader();
    reader.onLoad.first.then((_) {
      input.remove();
      try {
        final result = reader.result;
        final source = result is String ? result : '';
        completer.complete(PresentationProjectCodec.decodeProject(source));
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    reader.onError.first.then((_) {
      input.remove();
      completer.completeError(
        StateError('Proje dosyasi okunamadi.'),
      );
    });
    reader.readAsText(file);
  });

  input.click();
  return completer.future;
}
