import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../state/presentation_controller.dart';
import 'deepseek_presentation_service.dart';
import 'fallback_slide_generator.dart';
import 'grok_presentation_service.dart';
import 'gemini_presentation_service.dart';
import 'nvidia_presentation_service.dart';
import 'layout_service.dart';
import 'model_matching_service.dart';
import 'model_repository.dart';
import 'presentation_deck_builder.dart';
import 'presentation_content_quality.dart';
import 'presentation_project_codec.dart';
import 'presentation_keyword_catalog.dart';
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

  /// AI (DeepSeek/Nvidia/Gemini/Grok) çalışmadığında kelime tabanlı yedek kullanıldıysa true.
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
  }) async {
    if (slideCount < minSlideCount || slideCount > maxSlideCount) {
      throw Exception('Slayt sayısı 1 ile 30 arasında olmalıdır.');
    }

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

    final modelCatalogWarmup = ModelRepository.instance.getModels();
    // 1. NVIDIA -> Gemini -> Grok -> Kelime tabanlı yedek sıralaması ile slayt içeriklerini al
    // ignore: avoid_print
    print('ADIM 1: NVIDIA çağrısı başlıyor');
    GeminiPresentation resultPresentation;
    var usedFallback = false;
    try {
      final nvidiaResult =
          await _nvidia.generatePresentation(topic, slideCount: slideCount);
      resultPresentation = GeminiPresentation(
        slides: nvidiaResult.slides
            .map(
              (slide) => GeminiSlide(
                title: slide.title,
                content: slide.content,
                keywords: slide.keywords,
              ),
            )
            .toList(growable: false),
      );
      _ensureContentQuality(resultPresentation, provider: 'NVIDIA');
    } catch (e) {
      // ignore: avoid_print
      print('NVIDIA HATASI: $e — Gemini deneniyor');
      try {
        resultPresentation =
            await _gemini.generatePresentation(topic, slideCount: slideCount);
        _ensureContentQuality(resultPresentation, provider: 'Gemini');
      } catch (e2) {
        // ignore: avoid_print
        print('Gemini HATASI: $e2 — Grok deneniyor');
        try {
          final grokResult =
              await _grok.generatePresentation(topic, slideCount: slideCount);
          resultPresentation = GeminiPresentation(
            slides: grokResult.slides
                .map(
                  (slide) => GeminiSlide(
                    title: slide.title,
                    content: slide.content,
                    keywords: slide.keywords,
                  ),
                )
                .toList(growable: false),
          );
          _ensureContentQuality(resultPresentation, provider: 'Grok');
        } catch (e3) {
          // ignore: avoid_print
          print(
              'AI HATASI (Nvidia, Gemini, Grok): $e3 — kelime tabanlı yedek kullanılıyor');
          usedFallback = true;
          resultPresentation = FallbackSlideGenerator.generatePresentation(
            topic,
            slideCount: slideCount,
          );
        }
      }
    }
    if (resultPresentation.slides.length != slideCount) {
      // AI sağlayıcısı istenen adedi döndürmezse kullanıcının seçimini koru.
      usedFallback = true;
      resultPresentation = FallbackSlideGenerator.generatePresentation(
        topic,
        slideCount: slideCount,
      );
    }
    // ignore: avoid_print
    print('ADIM 1 TAMAM (yedek: $usedFallback)');

    // 2. Her slayt için model eşleştir ve layout belirle. Bütün slaytlar aynı
    // normalize edilmiş katalog indeksi üzerinden tek toplu geçişte işlenir.
    final slidesData = <Map<String, dynamic>>[];
    final deckSlides = <DeckSlide>[];
    final usedModelIds = <String>{};
    final catalogEntries = await modelCatalogWarmup;
    final allAvailableCatalog = catalogEntries.isNotEmpty
        ? catalogEntries
        : ModelMatchingService.localCatalogEntries;

    final searchKeywordsBySlide = resultPresentation.slides.map((slide) {
      return <String>[
        ...slide.keywords,
        ...slide.title.split(' '),
        ...slide.content.split(' '),
        ...topic.split(' '),
      ];
    }).toList(growable: false);

    final matchesBySlide = await _matcher.matchModelsForSlides(searchKeywordsBySlide);
    for (var slideIndex = 0;
        slideIndex < resultPresentation.slides.length;
        slideIndex += 1) {
      final slide = resultPresentation.slides[slideIndex];
      // ignore: avoid_print
      print('ADIM 2: Model eşleştirme başlıyor - ${slide.title}');
      final matches = matchesBySlide[slideIndex];
      // ignore: avoid_print
      print('ADIM 2 TAMAM - ${matches.length} eşleşme');
      // Otomatik üretimde 3B modeller her zaman 2D bileşenlere önceliklidir.
      // Slayta özel anahtar kelime eşleşmesi sağlayan en güçlü unused modeli seç.
      // Eşleşme yoksa konu kelimelerine veya katalogdaki diğer 3B modellere başvur.
      var selectedModel = ModelMatchingService.bestMatchPreferUnused(
        matches,
        usedModelIds,
      );

      if (selectedModel == null && allAvailableCatalog.isNotEmpty) {
        // Aşama 2: Slayt bazlı eşleşme yoksa, sunumun genel konu başlığı
        // kelimelerine göre katalogda ara.
        final topicMatches = ModelMatchingService.rankCatalogModels(
          models: allAvailableCatalog,
          keywords: PresentationKeywordCatalog.words(topic),
        );
        selectedModel = ModelMatchingService.bestMatchPreferUnused(
          topicMatches,
          usedModelIds,
        );

        // ÖNEMLİ: Burada BİLİNÇLİ OLARAK "hiçbir şey eşleşmezse kataloktan
        // rastgele/ilk kullanılmamış modeli zorla seç" adımı YOK.
        //
        // Önceki sürümde tam bu noktada, gerçek bir eşleşme bulunamadığında
        // bile kataloktaki ilk kullanılmamış model koşulsuz seçiliyordu. Bu
        // yüzden "Türk Kahvesinin Gelişimi" gibi bir slayta, sadece kataloğun
        // ilk sırasında olduğu için "Embriyo Gelişimi" gibi tamamen alakasız
        // bir model atanabiliyordu.
        //
        // Artık gerçekten alakalı bir model bulunamazsa `selectedModel`
        // null kalır ve aşağıdaki `_layout.decideLayout(selectedModels)`
        // boş model listesiyle çağrılarak mimarideki Aşama 4'e (2D bileşen
        // düzenine düşme) geçilir. Bu, "alakasız 3B model" göstermekten
        // her zaman daha iyidir.
      }

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
        'content': slide.content,
        'layout': layout.name,
        'modelIds': shownModelIds,
      });
      deckSlides.add(
        DeckSlide(
          title: slide.title,
          content: slide.content,
          models: selectedModels,
          keywords: slide.keywords,
        ),
      );
    }

    // 2b. Düzenlenebilir deck'i oluştur (metin sol, 3B modeller sağ)
    final controller = await PresentationDeckBuilder.buildControllerAsync(
      topic: topic,
      slides: deckSlides,
    );
    final projectJson = PresentationProjectCodec.encodeProject(
      pages: controller.pages.toList(growable: false),
      effectSettings: controller.effectSettings,
    );

    // 3. Firestore'a kaydet (REST API - Firestore SDK'sını bypass eder)
    // ignore: avoid_print
    print('ADIM 3: Firestore yazma başlıyor');
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

    // 3b. Slaytları tek atomik commit ile yaz. Önceki uygulama her slayt için
    // sırayla ayrı HTTP isteği yaptığı için sayfa sayısı arttıkça bekleme de
    // doğrusal biçimde artıyordu (30 slayt = 30 ardışık ağ turu).
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

    // İlk oluşturulan düzeni de aynı atomik commit içinde sakla. Aksi halde
    // editörde ilk anda görünen 3B model/bileşenler sunum yeniden açıldığında
    // yalnızca title/content kaydından kuruluyor ve kayboluyordu.
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
    // ignore: avoid_print
    print('ADIM 3 TAMAM');

    // İstatistik sayacı sunumun açılmasını bekletmemeli. Metot zaten
    // best-effort çalışır ve hata durumunda üretim sonucunu etkilemez.
    unawaited(_incrementPresentationCount(userId));

    return PresentationGenerationResult(
      presentationId: presentationId,
      controller: controller,
      usedFallback: usedFallback,
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

  static void _ensureContentQuality(
    GeminiPresentation presentation, {
    required String provider,
  }) {
    final reason = PresentationContentQuality.rejectionReason(
      presentation.slides
          .map(
            (slide) => PresentationContentSample(
              title: slide.title,
              content: slide.content,
            ),
          )
          .toList(growable: false),
    );
    if (reason != null) {
      throw FormatException('$provider sunum kalite kontrolü: $reason');
    }
  }

  static Future<String?> _authToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }
}
