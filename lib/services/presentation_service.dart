import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../state/presentation_controller.dart';
import 'ai_model_config.dart';
import 'grok_presentation_service.dart';
import 'gemini_presentation_service.dart';
import 'nvidia_presentation_service.dart';
import 'layout_service.dart';
import 'model_matching_service.dart';
import 'model_repository.dart';
import 'presentation_deck_builder.dart';
import 'presentation_project_codec.dart';
import 'usage_service.dart';
import 'firestore_rest_helper.dart';

/// createPresentation sonucu: Firestore doküman ID'si + düzenlenebilir deck.
class PresentationGenerationResult {
  const PresentationGenerationResult({
    required this.presentationId,
    required this.controller,
    this.usedFallback = false,
  });

  final String presentationId;
  final PresentationController controller;

  /// AI (Nvidia/Gemini/Grok) çalışmadığında kelime tabanlı yedek kullanıldıysa true.
  final bool usedFallback;
}

class PresentationService {
  static const int minSlideCount = 1;
  static const int freeMaxSlideCount = 7;
  static const int maxSlideCount = 30;

  static bool hasPlusSlideAccess(String tier) =>
      tier == 'plus' || tier == 'premium' || tier == 'pro';

  static bool canUseSlideCount(String tier, int slideCount) {
    if (slideCount < minSlideCount || slideCount > maxSlideCount) {
      return false;
    }
    return slideCount <= freeMaxSlideCount || hasPlusSlideAccess(tier);
  }

  final _nvidia = NvidiaPresentationService();
  final _gemini = GeminiPresentationService();
  final _grok = GrokPresentationService();
  final _matcher = ModelMatchingService();
  final _layout = LayoutService();

  static const String _apiBase =
      'https://firestore.googleapis.com/v1/projects/sutols/databases/(default)/documents';

  Future<PresentationGenerationResult> createPresentation({
    required String userId,
    required String topic,
    int slideCount = 5,
    void Function(String stepTitle, String stepDescription)? onProgress,
  }) async {
    if (slideCount < minSlideCount || slideCount > maxSlideCount) {
      throw Exception('Slayt sayısı 1 ile 30 arasında olmalıdır.');
    }

    final totalStopwatch = Stopwatch()..start();

    // 0. Günlük kota kontrolü (AI çağrısından önce)
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final tier = userDoc.data()?['tier'] as String? ?? 'free';
    if (!canUseSlideCount(tier, slideCount)) {
      throw Exception(
        'Ücretsiz planda en fazla 7 slayt oluşturabilirsiniz. '
        '8-30 slayt için Plus plana geçin.',
      );
    }
    final dailyLimit = UsageService.dailyLimitForTier(tier);
    final allowed =
        await UsageService().tryConsumeDailyQuota(userId, dailyLimit);
    if (!allowed) {
      throw Exception(
          'Günlük sunum oluşturma hakkınız doldu. Yarın tekrar deneyin veya planınızı yükseltin.');
    }

    AiRouterLogger.logRequestStart(topic: topic, slideCount: slideCount);

    onProgress?.call(
      'İçerik Oluşturuluyor...',
      'Yüksek kaliteli yapay zekâ modeli slayt içeriğini hazırlıyor.',
    );

    // 1. Sıralı Router: NVIDIA ana servis; Grok ve Gemini yalnızca yedek.
    GeminiPresentation resultPresentation;
    Object? nvidiaError;
    Object? grokError;
    try {
      final nvidiaResult =
          await _nvidia.generatePresentation(topic, slideCount: slideCount);
      resultPresentation = GeminiPresentation(
        slides: nvidiaResult.slides
            .map(
              (slide) => GeminiSlide(
                title: slide.title,
                subtitle: slide.subtitle,
                content: slide.content,
                keywords: slide.keywords,
                type: slide.type,
                purpose: slide.purpose,
                keyMessage: slide.keyMessage,
                sections: slide.sections,
                visual: slide.visual,
                sources: slide.sources,
              ),
            )
            .toList(growable: false),
      );
    } catch (error) {
      nvidiaError = error;
      try {
        final grokResult =
            await _grok.generatePresentation(topic, slideCount: slideCount);
        resultPresentation = GeminiPresentation(
          slides: grokResult.slides
              .map(
                (slide) => GeminiSlide(
                  title: slide.title,
                  subtitle: slide.subtitle,
                  content: slide.content,
                  keywords: slide.keywords,
                  type: slide.type,
                  purpose: slide.purpose,
                  keyMessage: slide.keyMessage,
                  sections: slide.sections,
                  visual: slide.visual,
                  sources: slide.sources,
                ),
              )
              .toList(growable: false),
        );
      } catch (error) {
        grokError = error;
        try {
          resultPresentation = await _gemini.generatePresentation(
            topic,
            slideCount: slideCount,
          );
        } catch (geminiError) {
          totalStopwatch.stop();
          AiRouterLogger.logTotal(
            latency: totalStopwatch.elapsed,
            success: false,
            details: 'NVIDIA: $nvidiaError Grok: $grokError Gemini: $geminiError',
          );
          throw Exception(
            'Sunum yapay zekâ servisleri yanıt veremedi. '
            'NVIDIA: $nvidiaError Grok: $grokError Gemini: $geminiError',
          );
        }
      }
    }
    final minAllowedSlides = (slideCount - 1).clamp(3, slideCount);
    if (resultPresentation.slides.length < minAllowedSlides) {
      throw FormatException(
        'AI $slideCount yerine ${resultPresentation.slides.length} slayt döndürdü.',
      );
    }

    // 2. Her slayt için model eşleştir ve layout belirle
    onProgress?.call(
      'Görseller ve 3B Modeller Eşleştiriliyor...',
      'Slayt konularına uygun 3B nesneler katalogdan seçiliyor.',
    );

    final matchingStopwatch = Stopwatch()..start();
    final slidesData = <Map<String, dynamic>>[];
    final deckSlides = <DeckSlide>[];
    final usedModelIds = <String>{};

    final searchKeywordsBySlide = resultPresentation.slides.map((slide) {
      return <String>[
        ...slide.keywords,
        ...slide.title.split(' '),
        ...slide.content.split(' '),
        ...topic.split(' '),
      ];
    }).toList(growable: false);

    final matchesBySlide =
        await _matcher.matchModelsForSlides(searchKeywordsBySlide);
    for (var slideIndex = 0;
        slideIndex < resultPresentation.slides.length;
        slideIndex += 1) {
      final slide = resultPresentation.slides[slideIndex];
      final matches = matchesBySlide[slideIndex];

      var selectedModel = ModelMatchingService.bestMatchPreferUnused(
        matches,
        usedModelIds,
      );

      final selectedModels = selectedModel == null
          ? const <ModelMatch>[]
          : <ModelMatch>[selectedModel];
      if (selectedModel != null) usedModelIds.add(selectedModel.id);
      final layout = _layout.decideLayout(selectedModels);
      final maxShow = _layout.maxModelsToShow(layout);
      final shownModelIds =
          selectedModels.take(maxShow).map((m) => m.id).toList();

      slidesData.add({
        'title': slide.title,
        if (slide.subtitle != null) 'subtitle': slide.subtitle,
        'content': slide.content,
        'layout': layout.name,
        'type': slide.type,
        if (slide.purpose != null) 'purpose': slide.purpose,
        if (slide.keyMessage != null) 'key_message': slide.keyMessage,
        'modelIds': shownModelIds,
      });
      deckSlides.add(
        DeckSlide(
          title: slide.title,
          subtitle: slide.subtitle,
          content: slide.content,
          type: slide.type,
          purpose: slide.purpose,
          keyMessage: slide.keyMessage,
          sections: slide.sections,
          visual: slide.visual,
          sources: slide.sources,
          models: selectedModels,
          keywords: slide.keywords,
        ),
      );
    }
    matchingStopwatch.stop();
    AiRouterLogger.logStep(
      stepName: 'MODEL MATCHING',
      latency: matchingStopwatch.elapsed,
    );

    // 2b. Düzenlenebilir deck'i oluştur
    onProgress?.call(
      'Sunum Düzeni Hazırlanıyor...',
      'Slayt şablonları ve görsel yerleşimler oluşturuluyor.',
    );

    final deckStopwatch = Stopwatch()..start();
    final controller = await PresentationDeckBuilder.buildControllerAsync(
      topic: topic,
      slides: deckSlides,
    );
    final projectJson = PresentationProjectCodec.encodeProject(
      pages: controller.pages.toList(growable: false),
      effectSettings: controller.effectSettings,
    );
    deckStopwatch.stop();
    AiRouterLogger.logStep(
      stepName: 'DECK',
      latency: deckStopwatch.elapsed,
    );

    // 3. Firestore'a kaydet (REST API)
    onProgress?.call(
      'Sunum Kaydediliyor...',
      'Sunum projesi veritabanına aktarılıyor.',
    );

    final firestoreStopwatch = Stopwatch()..start();
    final idToken = await _authToken();
    if (idToken == null) {
      throw Exception('Lütfen önce giriş yapın.');
    }

    final body = jsonEncode({
      'fields': {
        'userId': {'stringValue': userId},
        'userEmail': {
          'stringValue': FirebaseAuth.instance.currentUser?.email ?? '',
        },
        'slideCount': {'integerValue': '${slidesData.length}'},
        'topic': {'stringValue': topic},
        'title': {'stringValue': topic},
        'createdAt': {
          'timestampValue':
              FirestoreRestHelper.toFirestoreTimestamp(DateTime.now())
        },
        'updatedAt': {
          'timestampValue':
              FirestoreRestHelper.toFirestoreTimestamp(DateTime.now())
        },
        'wasEdited': {'booleanValue': false},
        'wasExported': {'booleanValue': false},
        'editCount': {'integerValue': '0'},
        'timeSpentSeconds': {'integerValue': '0'},
        'lastOpenedAt': {
          'timestampValue':
              FirestoreRestHelper.toFirestoreTimestamp(DateTime.now())
        },
      },
    });

    final response = await http.post(
      Uri.parse('$_apiBase/presentations'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Sunum kaydedilemedi (HTTP ${response.statusCode}): ${response.body}');
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    final docName = result['name'] as String;
    final presentationId = docName.split('/').last;

    // 3b. Slaytları tek atomik commit ile yaz
    final slideWrites = <Map<String, dynamic>>[];
    for (var i = 0; i < slidesData.length; i += 1) {
      final slide = slidesData[i];
      slideWrites.add({
        'update': {
          'name':
              'projects/sutols/databases/(default)/documents/presentations/$presentationId/slides/slide_$i',
          'fields': {
            'order': {'integerValue': '$i'},
            'title': {'stringValue': slide['title'] as String},
            'content': {'stringValue': slide['content'] as String},
            'layout': {'stringValue': slide['layout'] as String},
            'modelIds': {
              'arrayValue': {
                'values': (slide['modelIds'] as List)
                    .map((id) => {'stringValue': id as String})
                    .toList(),
              },
            },
          },
        },
        'currentDocument': {'exists': false},
      });
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final updatedByName = (currentUser?.displayName ?? '').trim().isNotEmpty
        ? currentUser!.displayName!.trim()
        : (currentUser?.email ?? '');
    slideWrites.add({
      'update': {
        'name':
            'projects/sutols/databases/(default)/documents/presentations/$presentationId/project/data',
        'fields': {
          'json': {'stringValue': projectJson},
          'updatedAt': {
            'timestampValue':
                FirestoreRestHelper.toFirestoreTimestamp(DateTime.now()),
          },
          'updatedByUid': {'stringValue': currentUser?.uid ?? userId},
          'updatedByName': {'stringValue': updatedByName},
          'updatedByEmail': {'stringValue': currentUser?.email ?? ''},
        },
      },
      'currentDocument': {'exists': false},
    });
    if (slideWrites.isNotEmpty) {
      final slideResponse = await http.post(
        Uri.parse('$_apiBase:commit'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'writes': slideWrites}),
      );

      if (slideResponse.statusCode != 200) {
        throw Exception(
            'Slaytlar kaydedilemedi (HTTP ${slideResponse.statusCode}): ${slideResponse.body}');
      }
    }
    firestoreStopwatch.stop();
    AiRouterLogger.logStep(
      stepName: 'FIRESTORE',
      latency: firestoreStopwatch.elapsed,
    );

    totalStopwatch.stop();
    AiRouterLogger.logTotal(
      latency: totalStopwatch.elapsed,
      success: true,
    );

    unawaited(_incrementPresentationCount(userId));

    return PresentationGenerationResult(
      presentationId: presentationId,
      controller: controller,
      usedFallback: false,
    );
  }

  Future<void> _incrementPresentationCount(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'presentationCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (_) {
      // Best-effort: sayım hatası sunum oluşturmayı bozmamalı.
    }
  }

  static Future<String?> _authToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }
}
