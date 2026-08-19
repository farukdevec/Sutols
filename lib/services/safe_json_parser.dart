import 'dart:convert';
import 'package:meta/meta.dart';

/// Güvenli, çok aşamalı JSON çıkarma ve doğrulama motoru.
class SafeJsonParser {
  const SafeJsonParser._();

  /// Ham model çıktısını güvenli şekilde ayrıştırır ve standart `{'slides': [...]}`
  /// Map yapısına dönüştürür.
  ///
  /// Sırasıyla:
  /// 1. Düşünce (<think>...</think>) bloklarını temizler.
  /// 2. Markdown kod bloklarını (```json ... ```) temizler.
  /// 3. Doğrudan `jsonDecode` dener.
  /// 4. İlk `{` ile son `}` arasındaki alt dizgiyi dener.
  /// 5. İlk `[` ile son `]` arasındaki alt dizgiyi dener.
  /// 6. Metin içerisindeki slayt nesnelerini regex ile ayıklar.
  ///
  /// Hiçbiri geçerli bir sunum şeması üretmezse [FormatException] fırlatır.
  static Map<String, dynamic> parsePresentationPayload(String rawContent) {
    var cleaned = rawContent.trim();

    // 0. <think>...</think> etiketlerini temizle
    if (cleaned.contains('</think>')) {
      cleaned = cleaned.substring(cleaned.lastIndexOf('</think>') + 8).trim();
    }

    // 1. Markdown kod bloklarını (```json ... ```) temizle
    if (cleaned.contains('```')) {
      final match =
          RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', caseSensitive: false)
              .firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(1)!.trim();
      } else if (cleaned.startsWith('```')) {
        final firstNewline = cleaned.indexOf('\n');
        if (firstNewline != -1) {
          cleaned = cleaned.substring(firstNewline + 1);
        }
        cleaned = cleaned.replaceFirst(RegExp(r'```\s*$'), '').trim();
      }
    }

    // 2. Doğrudan Map decode denemesi
    final directMap = _tryDecodeMap(cleaned);
    if (directMap != null) {
      final normalized = _tryNormalizePresentationPayload(directMap);
      if (normalized != null) return normalized;
    }

    // 3. Doğrudan List decode denemesi
    final directList = _tryDecodeList(cleaned);
    if (directList != null) {
      final normalized = _tryNormalizeSlideList(directList);
      if (normalized != null) return normalized;
    }

    // 4. İlk '{' ile son '}' arasındaki alt dizgi denemesi (preamble/postscript temizleme)
    if (cleaned.contains('{') && cleaned.contains('}')) {
      final firstBrace = cleaned.indexOf('{');
      final lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace > firstBrace) {
        final substring = cleaned.substring(firstBrace, lastBrace + 1);
        final map = _tryDecodeMap(substring);
        if (map != null) {
          final normalized = _tryNormalizePresentationPayload(map);
          if (normalized != null) return normalized;
        }
      }
    }

    // 5. İlk '[' ile son ']' arasındaki alt dizgi denemesi
    if (cleaned.contains('[') && cleaned.contains(']')) {
      final firstBracket = cleaned.indexOf('[');
      final lastBracket = cleaned.lastIndexOf(']');
      if (firstBracket != -1 && lastBracket > firstBracket) {
        final substring = cleaned.substring(firstBracket, lastBracket + 1);
        final list = _tryDecodeList(substring);
        if (list != null) {
          final normalized = _tryNormalizeSlideList(list);
          if (normalized != null) return normalized;
        }
      }
    }

    // 6. Gömülü JSON slayt nesnelerini regex ile ayıklama
    final extractedSlides = _extractAllSlidesFromText(cleaned);
    if (extractedSlides.isNotEmpty) {
      return {'slides': extractedSlides};
    }

    throw FormatException(
      'Model çıktısı geçerli bir sunum JSON formatına dönüştürülemedi. İçerik: $cleaned',
    );
  }

  /// Güvenli parse denemesi. Başarısızsa `null` döner, istisna fırlatmaz.
  static Map<String, dynamic>? tryParsePresentationPayload(String rawContent) {
    try {
      final parsed = parsePresentationPayload(rawContent);
      validateSchema(parsed);
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// Şema Doğrulaması (Schema Validation)
  /// `slides` listesi var mı, her slayt `title`, `content`, `keywords` alanlarına sahip mi?
  static void validateSchema(Map<String, dynamic> json) {
    final rawSlides = json['slides'];
    if (rawSlides is! List || rawSlides.isEmpty) {
      throw const FormatException('Şema Hatası: "slides" dizisi bulunamadı veya boş.');
    }
    for (var i = 0; i < rawSlides.length; i++) {
      final item = rawSlides[i];
      if (item is! Map) {
        throw FormatException('Şema Hatası: slides[$i] geçerli bir nesne değil.');
      }
      final title = item['title'] ?? item['baslik'];
      final content = item['content'] ?? item['icerik'];
      if (title == null) {
        throw FormatException('Şema Hatası: slides[$i] "title" alanı eksik.');
      }
      if (content == null) {
        throw FormatException('Şema Hatası: slides[$i] "content" alanı eksik.');
      }
    }
  }

  /// İçerik Doğrulaması (Content Validation)
  /// Başlık ve içeriklerin boş olmadığını doğrular.
  static void validateContent(Map<String, dynamic> json) {
    final rawSlides = json['slides'] as List;
    for (var i = 0; i < rawSlides.length; i++) {
      final item = rawSlides[i] as Map;
      final title = (item['title'] ?? item['baslik']).toString().trim();
      final rawContent = item['content'] ?? item['icerik'];
      final content = _normalizeContentString(rawContent).trim();

      if (title.isEmpty) {
        throw FormatException('İçerik Hatası: slides[$i] başlığı boş.');
      }
      if (content.isEmpty) {
        throw FormatException('İçerik Hatası: slides[$i] içeriği boş.');
      }
    }
  }

  static String _normalizeContentString(Object? rawContent) {
    if (rawContent is String) return rawContent;
    if (rawContent is List) {
      return rawContent.whereType<String>().join('\n');
    }
    return '';
  }

  static Map<String, dynamic>? _tryNormalizePresentationPayload(
    Map<String, dynamic> decoded,
  ) {
    for (final key in const [
      'slides',
      'sunum',
      'slaytlar',
      'presentation',
      'items',
      'data'
    ]) {
      if (decoded[key] is List) {
        final list = decoded[key] as List;
        final validList = _filterValidSlideMaps(list);
        if (validList.isNotEmpty) {
          return {'slides': validList};
        }
      }
    }

    for (final entry in decoded.entries) {
      if (entry.value is List) {
        final list = entry.value as List;
        final validList = _filterValidSlideMaps(list);
        if (validList.isNotEmpty) {
          return {'slides': validList};
        }
      }
    }

    if (_looksLikeSlideObject(decoded)) {
      return {
        'slides': [_standardizeSlideMap(decoded)]
      };
    }

    for (final key in const ['output', '/output', 'text', 'content', 'result', 'response']) {
      if (decoded[key] is String) {
        final innerText = (decoded[key] as String).trim();
        final innerMap = _tryDecodeMap(innerText);
        if (innerMap != null) {
          final normalized = _tryNormalizePresentationPayload(innerMap);
          if (normalized != null) return normalized;
        }
        final extracted = _extractSlidesFromFormattedText(innerText);
        if (extracted.isNotEmpty) {
          return {'slides': extracted};
        }
      }
    }

    return null;
  }

  static Map<String, dynamic>? _tryNormalizeSlideList(List<dynamic> list) {
    final validSlides = _filterValidSlideMaps(list);
    if (validSlides.isNotEmpty) {
      return {'slides': validSlides};
    }
    return null;
  }

  static List<Map<String, dynamic>> _filterValidSlideMaps(List<dynamic> list) {
    final valid = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is Map) {
        final map = item.map((key, value) => MapEntry(key.toString(), value));
        if (_looksLikeSlideObject(map)) {
          valid.add(_standardizeSlideMap(map));
        }
      }
    }
    return valid;
  }

  static Map<String, dynamic> _standardizeSlideMap(Map<String, dynamic> map) {
    final title = map['title'] ?? map['baslik'] ?? '';
    final rawContent = map['content'] ?? map['icerik'] ?? map['bullets'] ?? map['maddeler'] ?? map['points'] ?? '';
    final rawType = map['type'] ?? map['slide_type'] ?? map['layout'] ?? map['tip'] ?? 'cards';
    final keywords = map['keywords'] ?? map['anahtar_kelimeler'] ?? <dynamic>[];

    return {
      'title': title.toString(),
      'type': rawType.toString().toLowerCase().trim(),
      'content': rawContent is List
          ? rawContent.whereType<String>().toList(growable: false)
          : rawContent.toString(),
      'keywords': keywords is List
          ? keywords.map((k) => k.toString()).toList(growable: false)
          : <String>[],
    };
  }

  static bool _looksLikeSlideObject(Map<String, dynamic> decoded) {
    final hasTitle = decoded.containsKey('title') || decoded.containsKey('baslik');
    final hasContent = decoded.containsKey('content') ||
        decoded.containsKey('icerik') ||
        decoded.containsKey('bullets') ||
        decoded.containsKey('maddeler') ||
        decoded.containsKey('points');
    return hasTitle && hasContent;
  }

  static List<Map<String, dynamic>> _extractAllSlidesFromText(String text) {
    final slides = <Map<String, dynamic>>[];

    // 1. {"slides": [...]} veya {"sunum": [...]}
    final slideMatches = RegExp(
      r'\{[^{}]*"(?:slides|sunum|slaytlar)"\s*:\s*\[[\s\S]*?\][^{}]*\}',
      caseSensitive: false,
    ).allMatches(text);

    for (final match in slideMatches) {
      final map = _tryDecodeMap(match.group(0)!);
      if (map != null) {
        final normalized = _tryNormalizePresentationPayload(map);
        if (normalized != null && normalized['slides'] is List) {
          for (final item in normalized['slides'] as List) {
            if (item is Map<String, dynamic>) slides.add(item);
          }
        }
      }
    }
    if (slides.isNotEmpty) return slides;

    // 2. Ayrı ayrı slide nesneleri {"title": ..., "content": ...}
    final objMatches = RegExp(
      r'\{[^{}]*"(?:title|baslik)"\s*:[^{}]*"(?:content|icerik)"\s*:[^{}]*\}',
      caseSensitive: false,
    ).allMatches(text);

    for (final match in objMatches) {
      final map = _tryDecodeMap(match.group(0)!);
      if (map != null && _looksLikeSlideObject(map)) {
        slides.add(_standardizeSlideMap(map));
      }
    }
    if (slides.isNotEmpty) return slides;

    return _decodeJsonObjectSequence(text);
  }

  static List<Map<String, dynamic>> _decodeJsonObjectSequence(String raw) {
    final matches = RegExp(r'\{[\s\S]*?\}(?=\s*\{|$)', multiLine: true)
        .allMatches(raw)
        .map((match) => match.group(0)!.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final slides = <Map<String, dynamic>>[];
    for (final part in matches) {
      final decoded = _tryDecodeMap(part);
      if (decoded != null && _looksLikeSlideObject(decoded)) {
        slides.add(_standardizeSlideMap(decoded));
      }
    }
    return slides;
  }

  static Map<String, dynamic>? _tryDecodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return null;
  }

  static List<Map<String, dynamic>> _extractSlidesFromFormattedText(String text) {
    final slides = <Map<String, dynamic>>[];

    // 1. **[Title/Number]:** Content
    final bracketMatches = RegExp(
      r'\*\*\[([^\]]+)\]:\*\*\s*([\s\S]*?)(?=\*\*\[|$)',
      multiLine: true,
    ).allMatches(text);
    for (final m in bracketMatches) {
      final title = m.group(1)!.trim();
      final content = m.group(2)!.trim();
      if (title.isNotEmpty && content.isNotEmpty) {
        slides.add({
          'title': title,
          'type': 'cards',
          'content': content.startsWith('-') ? content : '- $content',
          'keywords': <String>[],
        });
      }
    }
    if (slides.isNotEmpty) return slides;

    // 2. ### Title \n Content or ## Title \n Content
    final headerMatches = RegExp(
      r'#{1,3}\s*([^\n]+)\n([\s\S]*?)(?=#{1,3}\s*|$)',
      multiLine: true,
    ).allMatches(text);
    for (final m in headerMatches) {
      final title = m.group(1)!.trim();
      final content = m.group(2)!.trim();
      if (title.isNotEmpty && content.isNotEmpty) {
        slides.add({
          'title': title,
          'type': 'cards',
          'content': content,
          'keywords': <String>[],
        });
      }
    }
    return slides;
  }

  static List<dynamic>? _tryDecodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }
}
