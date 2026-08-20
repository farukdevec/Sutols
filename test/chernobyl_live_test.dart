import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/nvidia_presentation_service.dart';
import 'package:sutol/services/presentation_deck_builder.dart';

void main() {
  test('Live Real Generation Test: Çernobil Nükleer Faciası ve Sağlık Etkileri (10 Slides)', () async {
    final service = NvidiaPresentationService();

    print('\n==================================================');
    print('CANLI ÇERNOBİL 10 SLAYT TESTİ BAŞLATILIYOR...');
    print('==================================================');

    final stopwatch = Stopwatch()..start();
    final presentation = await service.generatePresentation(
      'Çernobil Nükleer Faciası ve Sağlık Etkileri',
      slideCount: 10,
      language: 'turkish',
    );
    stopwatch.stop();

    print('\n[ÜRETİM BAŞARILI]');
    print('Geçen Süre: ${stopwatch.elapsedMilliseconds}ms');
    print('Toplam Slayt Sayısı: ${presentation.slides.length}');

    final typeCounts = <String, int>{};
    for (final s in presentation.slides) {
      typeCounts[s.type] = (typeCounts[s.type] ?? 0) + 1;
    }
    print('Kullanılan Slayt Tipleri: $typeCounts');

    print('\n==================== SLAYTLAR ====================');
    for (var i = 0; i < presentation.slides.length; i++) {
      final s = presentation.slides[i];
      print('\n--- SLAYT ${i + 1} [${s.type.toUpperCase()}] ---');
      print('Başlık: ${s.title}');
      if (s.subtitle != null) print('Alt Başlık: ${s.subtitle}');
      if (s.purpose != null) print('Amaç: ${s.purpose}');
      if (s.keyMessage != null) print('Ana Mesaj: ${s.keyMessage}');
      print('İçerik:\n${s.content}');
      if (s.visual != null) print('Görsel Veri: ${jsonEncode(s.visual)}');
      if (s.sources.isNotEmpty) print('Kaynaklar: ${s.sources.join(", ")}');
      print('Anahtar Kelimeler: ${s.keywords.join(", ")}');
    }

    // Verify deck building
    final deckSlides = presentation.slides
        .map((s) => DeckSlide(
              title: s.title,
              subtitle: s.subtitle,
              content: s.content,
              type: s.type,
              purpose: s.purpose,
              keyMessage: s.keyMessage,
              sections: s.sections,
              visual: s.visual,
              sources: s.sources,
              models: const [],
              keywords: s.keywords,
            ))
        .toList();

    final pages = const PresentationDeckBuilder().buildPages(
      topic: 'Çernobil Nükleer Faciası ve Sağlık Etkileri',
      slides: deckSlides,
    );

    print('\n[SAHNE DÖNÜŞÜMÜ]');
    print('Oluşturulan Sayfa Sayısı: ${pages.length}');
    for (var i = 0; i < pages.length; i++) {
      final p = pages[i];
      print('Sayfa ${i + 1}: ${p.textBlocks.length} metin bloğu, arkaplan: ${p.backgroundKind.name}');
    }

    expect(presentation.slides.length, 10);
    expect(typeCounts.keys.length, greaterThanOrEqualTo(4));
    expect(pages.length, 10);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
