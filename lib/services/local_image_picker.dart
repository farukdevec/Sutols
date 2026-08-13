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
    this.pixelWidth = 0,
    this.pixelHeight = 0,
  });

  final String name;
  final String dataUrl;
  final int sizeBytes;
  final int pixelWidth;
  final int pixelHeight;

  double get aspectRatio =>
      pixelWidth > 0 && pixelHeight > 0 ? pixelWidth / pixelHeight : 16 / 9;
}

Future<LocalPickedImage?> pickLocalImage() => impl.pickLocalImage();
