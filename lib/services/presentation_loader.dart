import 'dart:ui' show Offset;

import '../models/slide_model.dart';
import '../state/presentation_controller.dart';
import 'firestore_rest_helper.dart';
import 'presentation_project_codec.dart';
import 'presentation_project_store.dart';

/// Bir sunumu editörde düzenlenmek üzere yükler.
///
/// Proje dokümanı (deck JSON) varsa tam durumla; yoksa (eski sunumlar)
/// slides alt koleksiyonundan basit deck üretilir.
class PresentationLoadResult {
  const PresentationLoadResult({
    required this.controller,
    this.updatedByName,
  });

  final PresentationController controller;
  final String? updatedByName;
}

Future<PresentationLoadResult> loadPresentationForEdit(
  String presentationId,
) async {
  final controller = PresentationController();
  String? updatedByName;

  final project = await PresentationProjectStore.loadProject(presentationId);
  final projectJson = project?['json'] as String? ?? '';
  if (projectJson.isNotEmpty) {
    final decoded = PresentationProjectCodec.decodeProject(projectJson);
    controller.replaceDeck(
      decoded.pages,
      effectSettings: decoded.effectSettings,
    );
    updatedByName = project?['updatedByName'] as String?;
  } else {
    // Eski sunumlar: slides alt koleksiyonundan basit sayfalar üret.
    final slideDocs = await FirestoreRestHelper.runQuery({
      'from': [
        {
          'parent': 'presentations/$presentationId',
          'collectionId': 'slides',
        },
      ],
      'orderBy': [
        {'field': {'fieldPath': 'order'}, 'direction': 'ASCENDING'},
      ],
    });

    final pages = <PresentationPage>[];
    var index = 0;
    for (final slideDoc in slideDocs) {
      final slideFields = slideDoc['fields'] as Map<String, dynamic>? ?? {};
      final title = FirestoreRestHelper.stringField(slideFields, 'title');
      final content = FirestoreRestHelper.stringField(slideFields, 'content');

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
      index += 1;
    }

    if (pages.isEmpty) {
      throw const PresentationLoadException(
        'Bu sunumda düzenlenebilir içerik yok.',
      );
    }
    controller.replaceDeck(
      pages,
      effectSettings: const PresentationEffectSettings(
        transitionKind: PresentationTransitionKind.slide,
      ),
    );
  }

  return PresentationLoadResult(
    controller: controller,
    updatedByName: updatedByName,
  );
}

class PresentationLoadException implements Exception {
  const PresentationLoadException(this.message);

  final String message;
}
