// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

Future<String?> pickLocalJsonFile() async {
  final result = Completer<String?>();
  final input = html.FileUploadInputElement()
    ..accept = '.json,application/json';
  StreamSubscription<html.Event>? changed, canceled;
  void finish(String? source, [Object? error]) {
    if (result.isCompleted) return;
    if (error != null)
      result.completeError(error);
    else
      result.complete(source);
    changed?.cancel();
    canceled?.cancel();
    input.remove();
  }

  canceled = input.on['cancel'].listen((_) => finish(null));
  changed = input.onChange.listen((_) async {
    final file = input.files?.firstOrNull;
    if (file == null) {
      finish(null);
      return;
    }
    if (file.size > 256 * 1024) {
      finish(
          null, const FormatException('JSON dosyası 256 KB sınırını aşıyor.'));
      return;
    }
    final reader = html.FileReader();
    try {
      final loaded = reader.onLoad.first;
      reader.readAsText(file);
      await Future.any([
        loaded,
        reader.onError.first
            .then((_) => throw const FormatException('Dosya okunamadı.'))
      ]);
      finish(reader.result is String ? reader.result as String : null);
    } catch (error) {
      finish(null, error);
    }
  });
  input.click();
  return result.future;
}

Future<void> downloadLocalJsonFile(String source, String name) async {
  final blob = html.Blob([source], 'application/json;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final link = html.AnchorElement(href: url)
    ..download = name
    ..style.display = 'none';
  html.document.body?.children.add(link);
  try {
    link.click();
  } finally {
    link.remove();
    // Give the browser time to start its download before revoking the Blob.
    Timer(const Duration(seconds: 1), () => html.Url.revokeObjectUrl(url));
  }
}
