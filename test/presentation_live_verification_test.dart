import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sutol/services/model_matching_service.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_content_quality.dart';
import 'package:sutol/services/presentation_deck_builder.dart';
import 'package:sutol/services/presentation_export_builder.dart';

// Opt-in: makes a real generation request, but writes no Firestore documents.
// flutter test --dart-define=SUTOLS_LIVE_VERIFY=true test/presentation_live_verification_test.dart
void main() {
  test('live Turkish education deck satisfies content and rendering contracts',
      () async {
    const title = 'Yapay Zekânın Eğitimde Kullanımı';
    final output = Directory('build/verification')..createSync(recursive: true);
    var requestNumber = 0;
    final recordingClient = MockClient((request) async {
      final response = await http.post(request.url,
          headers: request.headers, body: request.body);
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      final content = payload['choices']?[0]?['message']?['content'];
      if (content is String) {
        File('${output.path}/live-response-${++requestNumber}.txt')
            .writeAsStringSync(content);
      }
      return response;
    });
    final presentation = const bool.fromEnvironment('SUTOLS_REPLAY_VERIFY')
        ? NvidiaPresentation.fromJson(jsonDecode(
            File('${output.path}/live-response-1.txt').readAsStringSync()) as Map<String, dynamic>)
        : await NvidiaPresentationService(client: recordingClient)
            .generatePresentation(
      'Öğretmenlere yönelik eğitimde yapay zekâ kullanımı: kişiselleştirilmiş öğrenme, '
      'faydalar ve riskler, etik ilkeler ve öğretmen denetimi. Kapsamı ve temel soruyu '
      'girişte açıkla; doğal Türkçe, kısa maddeler ve somut örnekler kullan.',
      slideCount: 5,
      language: 'turkish',
    );
    expect(presentation.slides, hasLength(5));
    final samples = presentation.slides
        .map((s) => PresentationContentSample(
              title: s.title,
              content: s.content,
              type: s.type,
              keywords: s.keywords,
            ))
        .toList();
    expect(PresentationContentQuality.rejectionReason(samples, language: 'tr'),
        isNull);
    final matches = await ModelMatchingService().matchModelsForSlides(
      presentation.slides
          .map((s) => [
                s.title,
                ...s.keywords,
                s.visual?['subject']?.toString() ?? '',
              ])
          .toList(),
    );
    final deckSlides = <DeckSlide>[];
    final report = <Map<String, dynamic>>[];
    for (var i = 0; i < presentation.slides.length; i++) {
      final s = presentation.slides[i];
      final strong = matches[i]
          .where(ModelMatchingService.isStrong3dMatch)
          .take(1)
          .toList();
      expect(
          strong.any((m) => RegExp('iflas|hacker', caseSensitive: false)
              .hasMatch('${m.id} ${m.name}')),
          isFalse);
      deckSlides.add(DeckSlide(
          title: s.title,
          content: s.content,
          type: s.type,
          models: strong,
          keywords: s.keywords,
          visual: s.visual));
      report.add({
        'title': s.title,
        'type': s.type,
        'content': s.content,
        'visual': s.visual,
        'models': strong.map((m) => m.id).toList()
      });
    }
    final pages = const PresentationDeckBuilder()
        .buildPages(topic: title, slides: deckSlides);
    File('${output.path}/education-live.html').writeAsStringSync(
        buildPresentationExportHtml(
            pages: pages, title: title, compact: false));
    File('${output.path}/education-live.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ')
            .convert({'title': title, 'slides': report}));
    // ignore: avoid_print
    print(
        'VERIFIED: ${pages.length} slides; build/verification/education-live.html');
  },
      skip: !const bool.fromEnvironment('SUTOLS_LIVE_VERIFY') &&
          !const bool.fromEnvironment('SUTOLS_REPLAY_VERIFY'),
      timeout: const Timeout(Duration(minutes: 5)));
}
