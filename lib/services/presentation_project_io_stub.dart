import '../models/slide_model.dart';
import 'presentation_project_codec.dart';

Future<void> savePresentationProjectAsJson({
  required List<PresentationPage> pages,
  required PresentationEffectSettings effectSettings,
  String? fileName,
}) {
  throw UnsupportedError('Proje kaydetme yalnizca webde destekleniyor.');
}

Future<PresentationProject?> loadPresentationProjectFromJson() {
  throw UnsupportedError('Proje yukleme yalnizca webde destekleniyor.');
}
