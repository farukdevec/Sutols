/// Yerel gorsel secici — web'de dosya secici acar, gorseli data URL olarak
/// dondurur.
library;

import 'local_image_picker_io.dart'
    if (dart.library.html) 'local_image_picker_web.dart' as impl;

class LocalPickedImage {
  const LocalPickedImage({
    required this.name,
    required this.dataUrl,
    required this.sizeBytes,
  });

  final String name;
  final String dataUrl;
  final int sizeBytes;
}

Future<LocalPickedImage?> pickLocalImage() => impl.pickLocalImage();