import 'gemini_presentation_service.dart';

/// Gemini çalışmadığında (AI limiti vb.) konu metninden yapay zeka
/// kullanmadan slayt üreten yedek üretici.
///
/// Konu metnindeki anlamlı kelimeleri anahtar kelime havuzuna çevirir;
/// böylece model eşleştirme (REST, AI gerektirmez) aynı şekilde çalışır ve
/// slaytlara 3B modeller yerleştirilir.
class FallbackSlideGenerator {
  static const Set<String> _stopWords = {
    'ama', 'ancak', 'artik', 'bir', 'bircok', 'bu', 'buna', 'bunlara',
    'bunlari', 'bunun', 'cok', 'daha', 'da', 'de', 'den', 'diye', 'diyor',
    'ederek', 'eden', 'en', 'gibi', 'hakkinda', 'her', 'icin', 'ile',
    'ise', 'kadar', 'ken', 'ki', 'kim', 'nasi', 'nasil', 'ne', 'neden',
    'nerde', 'nere', 'nereye', 'neyle', 'olarak', 'oldugu', 'oldugunu',
    'oldukca', 'once', 'sadece', 'seyler', 'sonra', 'uzere', 'uzerine',
    'uzerinde', 've', 'veya', 'ya', 'yani', 'yapilan', 'yeni', 'zaman',
    'tum', 'butun', 'tumu', 'nedir',
  };

  /// Konu metninden [slideCount] kadar slayt üretir.
  ///
  /// AI kullanmaz; giriş, bölüm ve özet slaytları şablon içerikle doldurur.
  /// [slideCount] 2 ile 8 arasına kısıtlanır.
  static GeminiPresentation generatePresentation(
    String topic, {
    int slideCount = 5,
  }) {
    final words = _meaningfulWords(topic);
    final count = slideCount.clamp(2, 8);
    final slides = <GeminiSlide>[];

    slides.add(GeminiSlide(
      title: 'Giriş',
      content: [
        '- Bu sunumda "$topic" konusunu ele alacağız.',
        '- Konuya genel bir bakış sunacağız.',
        '- İlgili temel kavramları inceleyeceğiz.',
      ].join('\n'),
      keywords: words.take(4).toList(),
    ));

    final middleCount = count - 2;
    for (var i = 0; i < middleCount; i++) {
      final a = words[i % words.length];
      final b = words[(i + 1) % words.length];
      slides.add(GeminiSlide(
        title: 'Bölüm ${i + 1}: ${_capitalize(a)} ve ${_capitalize(b)}',
        content: [
          '- ${_capitalize(a)} hakkında temel bilgiler.',
          '- ${_capitalize(b)} ile ilgili önemli noktalar.',
          '- ${_capitalize(a)} ve ${_capitalize(b)} arasındaki bağlantılar.',
        ].join('\n'),
        keywords: [
          a,
          b,
          words[(i + 2) % words.length],
          words[(i + 3) % words.length],
        ],
      ));
    }

    final topWords = words.take(6).toList();
    slides.add(GeminiSlide(
      title: 'Özet ve Sonuç',
      content: [
        '- Bu sunumda "$topic" konusunu özetledik.',
        '- Öne çıkan kavramlar: ${topWords.join(', ')}.',
        '- Sorularınız için teşekkürler.',
      ].join('\n'),
      keywords: topWords,
    ));

    return GeminiPresentation(slides: slides);
  }

  static List<String> _meaningfulWords(String topic) {
    final tokens = topic
        .toLowerCase()
        .split(RegExp(r'[^a-zçğıöşü0-9]+'))
        .where((w) => w.isNotEmpty && w.length >= 3 && !_stopWords.contains(w))
        .toSet()
        .toList();
    if (tokens.isEmpty && topic.trim().isNotEmpty) {
      return [topic.trim().toLowerCase()];
    }
    return tokens.isEmpty ? ['konu'] : tokens;
  }

  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    final first = word[0] == 'i' ? 'İ' : word[0].toUpperCase();
    return first + word.substring(1);
  }
}
