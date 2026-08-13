// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'local_image_picker.dart';

const int _maxImageBytes = 6 * 1024 * 1024;

Future<LocalPickedImage?> pickLocalImage() {
  final completer = Completer<LocalPickedImage?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.multiple = false;
  input.onChange.listen((_) {
    final file = input.files?.isNotEmpty == true ? input.files![0] : null;
    if (file == null) {
      completer.complete(null);
      return;
    }
    if (file.size > _maxImageBytes) {
      completer.completeError(
        StateError(
            'Gorsel 6 MB sinirini asiyor (${file.size.toString()} byte).'),
      );
      return;
    }
    final reader = html.FileReader();
    reader.onLoad.listen((_) {
      final result = reader.result;
      if (result is String && result.startsWith('data:image/')) {
        final image = html.ImageElement(src: result);
        image.onLoad.first.then((_) {
          if (completer.isCompleted) return;
          completer.complete(LocalPickedImage(
            name: file.name,
            dataUrl: result,
            sizeBytes: file.size,
            pixelWidth: image.naturalWidth,
            pixelHeight: image.naturalHeight,
          ));
        });
        image.onError.first.then((_) {
          if (completer.isCompleted) return;
          completer.complete(LocalPickedImage(
            name: file.name,
            dataUrl: result,
            sizeBytes: file.size,
          ));
        });
      } else {
        completer.complete(null);
      }
    });
    reader.onError.listen((_) {
      completer.complete(null);
    });
    reader.readAsDataUrl(file);
  });
  input.click();
  return completer.future;
}
