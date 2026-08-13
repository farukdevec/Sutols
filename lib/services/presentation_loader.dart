import 'dart:ui' show Offset;

import '../models/slide_model.dart';
import '../state/presentation_controller.dart';
import 'firestore_rest_helper.dart';
import 'presentation_project_codec.dart';
import 'presentation_project_store.dart';
import 'presentation_model_source_resolver.dart';

/// Bir sunumu editÃ¶rde dÃ¼zenlenmek Ã¼zere yÃ¼kler.
///
/// Proje dokÃ¼manÄ± (deck JSON) varsa tam durumla; yoksa (eski sunumlar)
/// slides alt koleksiyonundan basit deck Ã¼retilir.
class PresentationLoadResult {
  const PresentationLoadResult({
    required this.controller,
    this.updatedByName,
  });

  final PresentationController controller;
  final String? updatedByName;
}

Future<PresentationLoadResult> loadPresentationForEdit(
  String presentationId, {
  PresentationController? controller,
}) async {
  final ctrl = controller ?? PresentationController();
  String? updatedByName;

  final project = await PresentationProjectStore.loadProject(presentationId);
  final projectJson = project?['json'] as String? ?? '';
  if (projectJson.isNotEmpty) {
    final decoded = PresentationProjectCodec.decodeProject(projectJson);
    await hydratePresentationModelSources(decoded.pages);
    ctrl.replaceDeck(
      decoded.pages,
      effectSettings: decoded.effectSettings,
    );
    updatedByName = project?['updatedByName'] as String?;
  } else {
    // Eski sunumlar: Ã¶nce ana belgedeki gÃ¶mÃ¼lÃ¼ `slides` dizisi, yoksa
    // `slides` alt koleksiyonu. Ä°kisinden de basit sayfalar Ã¼ret.
    final pages = await _buildPagesFromFallback(presentationId);
    if (pages.isEmpty) {
      throw const PresentationLoadException(
        'Bu sunumda dÃ¼zenlenebilir iÃ§erik yok.',
      );
    }
    ctrl.replaceDeck(
      pages,
      effectSettings: const PresentationEffectSettings(
        transitionKind: PresentationTransitionKind.slide,
      ),
    );
  }

  return PresentationLoadResult(
    controller: ctrl,
    updatedByName: updatedByName,
  );
}

/// Sunum iÃ§eriÄŸini yedek kaynaklardan okur: ana belgedeki gÃ¶mÃ¼lÃ¼ `slides`
/// dizisi yoksa `slides` alt koleksiyonu (order ile).
Future<List<PresentationPage>> _buildPagesFromFallback(
  String presentationId,
) async {
  // 1) Ana belgedeki gÃ¶mÃ¼lÃ¼ slides dizisi (AI Ã¼retimi format).
  final doc = await FirestoreRestHelper.getDocument(
    'presentations/$presentationId',
  );
  final embedded = doc?['fields']?['slides']?['arrayValue']?['values'] as List?;
  if (embedded != null && embedded.isNotEmpty) {
    final slides = <({String title, String content})>[];
    for (final value in embedded) {
      final slideFields = (value as Map<String, dynamic>)['mapValue']?['fields']
              as Map<String, dynamic>? ??
          const <String, dynamic>{};
      slides.add((
        title: FirestoreRestHelper.stringField(slideFields, 'title'),
        content: FirestoreRestHelper.stringField(slideFields, 'content'),
      ));
    }
    final pages = _pagesFromTitleContent(slides);
    if (pages.isNotEmpty) return pages;
  }

  // 2) Eski sunumlar: slides alt koleksiyonu (order ile).
  // Admin için kural bazen 403 dönebilir; hata durumunda boş döner ve
  // çağıran tarafa "düzenlenebilir içerik yok" mesajı gösterilir.
  List<({String title, String content})> slides;
  try {
    final slideDocs = await FirestoreRestHelper.runQuery({
      'from': [
        {
          'parent': 'presentations/$presentationId',
          'collectionId': 'slides',
        },
      ],
      'orderBy': [
        {
          'field': {'fieldPath': 'order'},
          'direction': 'ASCENDING'
        },
      ],
    });

    slides = <({String title, String content})>[];
    for (final slideDoc in slideDocs) {
      final slideFields = slideDoc['fields'] as Map<String, dynamic>? ?? {};
      slides.add((
        title: FirestoreRestHelper.stringField(slideFields, 'title'),
        content: FirestoreRestHelper.stringField(slideFields, 'content'),
      ));
    }
  } catch (_) {
    slides = const <({String title, String content})>[];
  }
  return _pagesFromTitleContent(slides);
}

/// Başlık/içerik listesinden basit editör sayfaları üretir.
List<PresentationPage> _pagesFromTitleContent(
  List<({String title, String content})> slides,
) {
  final pages = <PresentationPage>[];
  for (var index = 0; index < slides.length; index++) {
    final title = slides[index].title;
    final content = slides[index].content;

    final textBlocks = <PresentationTextBlock>[];
    if (title.isNotEmpty) {
      textBlocks.add(PresentationTextBlock(
        id: 'slide-$index-title',
        text: title,
        position: const Offset(0.06, 0.07),
        fontSize: 46,
        type: PresentationTextType.title,
        widthFactor: 0.55,
      ));
    }
    if (content.isNotEmpty) {
      textBlocks.add(PresentationTextBlock(
        id: 'slide-$index-content',
        text: content,
        position: const Offset(0.06, 0.2),
        fontSize: 24,
        type: PresentationTextType.body,
        widthFactor: 0.5,
      ));
    }
    if (textBlocks.isNotEmpty) {
      pages.add(PresentationPage(
        id: 'page-$index',
        textBlocks: textBlocks,
      ));
    }
  }
  return pages;
}

class PresentationLoadException implements Exception {
  const PresentationLoadException(this.message);

  final String message;
}
