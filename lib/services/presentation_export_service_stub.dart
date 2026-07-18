import '../models/slide_model.dart';

Future<void> exportPresentationAsHtml({
  required List<PresentationPage> pages,
  PresentationEffectSettings effectSettings =
      const PresentationEffectSettings(),
  String? fileName,
  String? title,
}) {
  throw UnsupportedError('HTML disa aktarma yalnizca webde destekleniyor.');
}

Future<void> exportPresentationAsPdfViaPrint({
  required List<PresentationPage> pages,
  PresentationEffectSettings effectSettings =
      const PresentationEffectSettings(),
  String? title,
}) {
  throw UnsupportedError('PDF disa aktarma yalnizca webde destekleniyor.');
}
