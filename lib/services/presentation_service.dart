import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../state/presentation_controller.dart';
import 'fallback_slide_generator.dart';
import 'gemini_presentation_service.dart';
import 'nvidia_presentation_service.dart';
import 'layout_service.dart';
import 'model_matching_service.dart';
import 'presentation_deck_builder.dart';
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

  /// AI (Gemini) çalışmadığında kelime tabanlı yedek kullanıldıysa true.
  final bool usedFallback;
}

class PresentationService {
  final _nvidia = NvidiaPresentationService();
  final _gemini = GeminiPresentationService();
  final _matcher = ModelMatchingService();
  final _layout = LayoutService();

  static const String _apiBase =
      'https://firestore.googleapis.com/v1/projects/sutols/databases/(default)/documents';

  Future<PresentationGenerationResult> createPresentation({
    required String userId,
    required String topic,
    int slideCount = 5,
  }) async {
    // 0. Günlük kota kontrolü (Gemini çağrısından önce)
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final tier = userDoc.data()?['tier'] as String? ?? 'free';
    final dailyLimit = tier == 'premium' ? 999 : (tier == 'plus' ? 15 : 3);
    final allowed =
        await UsageService().tryConsumeDailyQuota(userId, dailyLimit);
    if (!allowed) {
      throw Exception(
          'Günlük sunum oluşturma hakkınız doldu. Yarın tekrar deneyin veya planınızı yükseltin.');
    }

    // 1. NVIDIA / Cloudflare'dan slayt içeriklerini al
    // Çalışmazsa Gemini'ye, o da çalışmazsa kelime tabanlı yedeğe düş
    // ignore: avoid_print
    print('ADIM 1: NVIDIA çağrısı başlıyor');
    var resultPresentation;
    var usedFallback = false;
    try {
      resultPresentation = await _nvidia.generatePresentation(topic, slideCount: slideCount);
    } catch (e) {
      // ignore: avoid_print
      print('NVIDIA/Cloudflare HATASI: $e — Gemini deneniyor');
      try {
        resultPresentation = await _gemini.generatePresentation(topic, slideCount: slideCount);
      } catch (e2) {
        // ignore: avoid_print
        print('AI HATASI (Gemini vb.): $e2 — kelime tabanlı yedek kullanılıyor');
        usedFallback = true;
        resultPresentation = FallbackSlideGenerator.generatePresentation(topic, slideCount: slideCount);
      }
    }
    // ignore: avoid_print
    print('ADIM 1 TAMAM (yedek: $usedFallback)');

    // 2. Her slayt için model eşleştir ve layout belirle
    final slidesData = <Map<String, dynamic>>[];
    final deckSlides = <DeckSlide>[];
    for (final slide in resultPresentation.slides) {
      // ignore: avoid_print
      print('ADIM 2: Model eşleştirme başlıyor - ${slide.title}');
      final matches = await _matcher.matchModelsForSlide(slide.keywords);
      // ignore: avoid_print
      print('ADIM 2 TAMAM - ${matches.length} eşleşme');
      final strongMatches = matches.where((m) => m.score >= 2).toList();
      final layout = _layout.decideLayout(matches);
      final maxShow = _layout.maxModelsToShow(layout);
      final shownModelIds = strongMatches.take(maxShow).map((m) => m.id).toList();

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
          models: matches,
        ),
      );
    }

    // 2b. Düzenlenebilir deck'i oluştur (metin sol, 3B modeller sağ)
    final controller = PresentationDeckBuilder.buildController(
      topic: topic,
      slides: deckSlides,
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
        'createdAt': {'timestampValue': FirestoreRestHelper.toFirestoreTimestamp(DateTime.now())},
        'updatedAt': {'timestampValue': FirestoreRestHelper.toFirestoreTimestamp(DateTime.now())},
        'wasEdited': {'booleanValue': false},
        'wasExported': {'booleanValue': false},
        'editCount': {'integerValue': '0'},
        'timeSpentSeconds': {'integerValue': '0'},
        'lastOpenedAt': {'timestampValue': FirestoreRestHelper.toFirestoreTimestamp(DateTime.now())},
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
      throw Exception('Sunum kaydedilemedi (HTTP ${response.statusCode}): ${response.body}');
    }

    final result = jsonDecode(response.body) as Map<String, dynamic>;
    final docName = result['name'] as String;
    final presentationId = docName.split('/').last;

    // 3b. Slaytları alt koleksiyona yaz (her slayt ayrı doküman, order alanıyla)
    for (var i = 0; i < slidesData.length; i++) {
      final slide = slidesData[i];
      final slideBody = jsonEncode({
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
      });

      final slideResponse = await http.post(
        Uri.parse('$_apiBase/presentations/$presentationId/slides?documentId=slide_$i'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: slideBody,
      );

      if (slideResponse.statusCode != 200) {
        throw Exception('Slayt kaydedilemedi (HTTP ${slideResponse.statusCode}): ${slideResponse.body}');
      }
    }
    // ignore: avoid_print
    print('ADIM 3 TAMAM');

    await _incrementPresentationCount(userId);

    return PresentationGenerationResult(
      presentationId: presentationId,
      controller: controller,
      usedFallback: usedFallback,
    );
  }

  Future<void> _incrementPresentationCount(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
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
