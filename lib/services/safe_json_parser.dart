import 'dart:convert';

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

    // 4. Dengeli Parantez (Balanced Brace) JSON Çıkarımı
    final balancedMap = _extractBalancedJsonPayload(cleaned);
    if (balancedMap != null) {
      final normalized = _tryNormalizePresentationPayload(balancedMap);
      if (normalized != null) return normalized;
    }

    // 5. İlk '{' ile son '}' arasındaki alt dizgi denemesi (preamble/postscript temizleme)
    if (cleaned.contains('{') && cleaned.contains('}')) {
      final firstBrace = cleaned.indexOf('{');
      final lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace > firstBrace) {
        final substring = cleaned.substring(firstBrace, lastBrace + 1);
        final map = _tryDecodeMap(substring) ?? _tryDecodeMap(_repairTruncatedJson(substring));
        if (map != null) {
          final normalized = _tryNormalizePresentationPayload(map);
          if (normalized != null) return normalized;
        }
      }
    }

    // 6. İlk '[' ile son ']' arasındaki alt dizgi denemesi
    if (cleaned.contains('[') && cleaned.contains(']')) {
      final firstBracket = cleaned.indexOf('[');
      final lastBracket = cleaned.lastIndexOf(']');
      if (firstBracket != -1 && lastBracket > firstBracket) {
        final substring = cleaned.substring(firstBracket, lastBracket + 1);
        final list = _tryDecodeList(substring) ?? _tryDecodeList(_repairTruncatedJson(substring));
        if (list != null) {
          final normalized = _tryNormalizeSlideList(list);
          if (normalized != null) return normalized;
        }
      }
    }

    // 7. Gömülü veya yarıda kesilmiş JSON slayt nesnelerini ayıklama
    final extractedSlides = _extractAllSlidesFromText(cleaned);
    if (extractedSlides.isNotEmpty) {
      return {'slides': extractedSlides};
    }

    // 8. Markdown metin başlıklarından slayt kurtarma
    final formattedSlides = _extractSlidesFromFormattedText(cleaned);
    if (formattedSlides.isNotEmpty) {
      return {'slides': formattedSlides};
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
  /// `slides` listesi var mı, her slayt `title` ve (`content` / `sections` / `key_message`) alanlarına sahip mi?
  static void validateSchema(Map<String, dynamic> json) {
    final rawSlides = json['slides'];
    if (rawSlides is! List || rawSlides.isEmpty) {
      throw const FormatException(
          'Şema Hatası: "slides" dizisi bulunamadı veya boş.');
    }
    for (var i = 0; i < rawSlides.length; i++) {
      final item = rawSlides[i];
      if (item is! Map) {
        throw FormatException(
            'Şema Hatası: slides[$i] geçerli bir nesne değil.');
      }
      final title = item['title'] ?? item['baslik'];
      final content = item['content'] ??
          item['icerik'] ??
          item['sections'] ??
          item['bolumler'] ??
          item['key_message'] ??
          item['keyMessage'] ??
          item['ana_mesaj'] ??
          item['bullets'];
      if (title == null) {
        throw FormatException('Şema Hatası: slides[$i] "title" alanı eksik.');
      }
      if (content == null) {
        throw FormatException('Şema Hatası: slides[$i] "content" veya "sections" alanı eksik.');
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
      final content = _extractOrSynthesizeContent(item).trim();

      if (title.isEmpty) {
        throw FormatException('İçerik Hatası: slides[$i] başlığı boş.');
      }
      if (content.isEmpty) {
        throw FormatException('İçerik Hatası: slides[$i] içeriği boş.');
      }
    }
  }

  static String _extractOrSynthesizeContent(Map<dynamic, dynamic> map) {
    final rawContent = map['content'] ?? map['icerik'] ?? map['bullets'] ?? map['maddeler'] ?? map['points'];
    if (rawContent != null) {
      final s = _normalizeContentString(rawContent).trim();
      if (s.isNotEmpty) return s;
    }

    final rawSections = map['sections'] ?? map['bolumler'];
    if (rawSections is List && rawSections.isNotEmpty) {
      final lines = <String>[];
      for (final sec in rawSections) {
        if (sec is Map) {
          final heading = sec['heading'] ?? sec['title'] ?? sec['baslik'] ?? '';
          final desc = sec['description'] ?? sec['desc'] ?? sec['text'] ?? sec['aciklama'] ?? sec['content'] ?? '';
          if (heading.toString().trim().isNotEmpty && desc.toString().trim().isNotEmpty) {
            lines.add('- **${heading.toString().trim()}:** ${desc.toString().trim()}');
          } else if (desc.toString().trim().isNotEmpty) {
            lines.add('- ${desc.toString().trim()}');
          } else if (heading.toString().trim().isNotEmpty) {
            lines.add('- **${heading.toString().trim()}**');
          }
        } else if (sec is String && sec.trim().isNotEmpty) {
          final trimmed = sec.trim();
          lines.add(trimmed.startsWith('-') || trimmed.startsWith('*') ? trimmed : '- $trimmed');
        }
      }
      if (lines.isNotEmpty) return lines.join('\n');
    }

    final keyMessage = map['key_message'] ?? map['keyMessage'] ?? map['ana_mesaj'];
    if (keyMessage != null && keyMessage.toString().trim().isNotEmpty) {
      return '- ${keyMessage.toString().trim()}';
    }

    final headline = map['headline'] ?? map['ana_fikir'];
    if (headline != null && headline.toString().trim().isNotEmpty) {
      return '- **${headline.toString().trim()}**';
    }

    return '';
  }

  static String _normalizeContentString(Object? rawContent) {
    if (rawContent is String) return rawContent;
    if (rawContent is Map) {
      final headline = rawContent['headline'] ?? rawContent['ana_fikir'] ?? '';
      final supportingText = rawContent['supporting_text'] ?? rawContent['aciklama'] ?? '';
      final rawKeyPoints = rawContent['key_points'] ?? rawContent['maddeler'];
      final lines = <String>[];
      final cleanHeadline = headline.toString().replaceAll('*', '').trim();
      final cleanSupporting = supportingText.toString().replaceAll('*', '').trim();
      if (cleanHeadline.isNotEmpty && cleanSupporting.isNotEmpty) {
        lines.add('- **$cleanHeadline:** $cleanSupporting');
      } else if (cleanHeadline.isNotEmpty) {
        lines.add('- **$cleanHeadline**');
      } else if (cleanSupporting.isNotEmpty) {
        lines.add('- $cleanSupporting');
      }
      if (rawKeyPoints is List) {
        for (final pt in rawKeyPoints) {
          if (pt != null && pt.toString().trim().isNotEmpty) {
            final cleanPt = pt.toString().trim();
            lines.add(cleanPt.startsWith('-') ? cleanPt : '- $cleanPt');
          }
        }
      }
      if (lines.isNotEmpty) return lines.join('\n');
    }
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
          final result = Map<String, dynamic>.from(decoded);
          result['slides'] = validList;
          return result;
        }
      }
    }

    for (final entry in decoded.entries) {
      if (entry.value is List) {
        final list = entry.value as List;
        final validList = _filterValidSlideMaps(list);
        if (validList.isNotEmpty) {
          final result = Map<String, dynamic>.from(decoded);
          result['slides'] = validList;
          return result;
        }
      }
    }

    if (_looksLikeSlideObject(decoded)) {
      return {
        'slides': [_standardizeSlideMap(decoded)]
      };
    }

    for (final key in const [
      'output',
      '/output',
      'text',
      'content',
      'result',
      'response'
    ]) {
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
    final title = (map['title'] ?? map['baslik'] ?? '').toString();
    final subtitle = (map['subtitle'] ?? map['alt_baslik'] ?? map['sub_title'])?.toString();
    final rawType = map['type'] ?? map['slide_type'] ?? map['layout'] ?? map['tip'] ?? 'cards';
    final purpose = (map['purpose'] ?? map['amac'] ?? map['role'])?.toString();
    final keyMessage = (map['key_message'] ?? map['keyMessage'] ?? map['ana_mesaj'])?.toString();
    final rawSections = map['sections'] ?? map['bolumler'];
    final rawVisual = map['visual'] ?? map['gorsel'];
    final keywords = map['keywords'] ?? map['anahtar_kelimeler'] ?? <dynamic>[];
    final sources = map['sources'] ?? map['kaynaklar'] ?? <dynamic>[];

    final contentStr = _extractOrSynthesizeContent(map);

    return {
      'title': title,
      if (subtitle != null && subtitle.trim().isNotEmpty) 'subtitle': subtitle.trim(),
      'type': rawType.toString().toLowerCase().trim(),
      if (purpose != null && purpose.trim().isNotEmpty) 'purpose': purpose.trim(),
      if (keyMessage != null && keyMessage.trim().isNotEmpty) 'key_message': keyMessage.trim(),
      if (rawSections is List) 'sections': rawSections,
      if (rawVisual is Map) 'visual': rawVisual,
      'content': contentStr,
      'keywords': keywords is List
          ? keywords.map((k) => k.toString()).toList(growable: false)
          : <String>[],
      'sources': sources is List
          ? sources.map((s) => s.toString()).toList(growable: false)
          : <String>[],
    };
  }

  static bool _looksLikeSlideObject(Map<String, dynamic> decoded) {
    final hasTitle =
        decoded.containsKey('title') || decoded.containsKey('baslik');
    final hasContent = decoded.containsKey('content') ||
        decoded.containsKey('icerik') ||
        decoded.containsKey('sections') ||
        decoded.containsKey('bolumler') ||
        decoded.containsKey('key_message') ||
        decoded.containsKey('keyMessage') ||
        decoded.containsKey('ana_mesaj') ||
        decoded.containsKey('bullets') ||
        decoded.containsKey('maddeler') ||
        decoded.containsKey('points');
    return hasTitle && hasContent;
  }

  /// Metin içerisinden dengeli parantezli (balanced brace) JSON payload nesnesini çıkarır.
  static Map<String, dynamic>? _extractBalancedJsonPayload(String text) {
    var searchStart = 0;
    while (searchStart < text.length) {
      final braceIndex = text.indexOf('{', searchStart);
      if (braceIndex == -1) break;

      var depth = 0;
      var inString = false;
      var isEscaped = false;
      int? endIndex;

      for (var i = braceIndex; i < text.length; i++) {
        final char = text[i];
        if (isEscaped) {
          isEscaped = false;
          continue;
        }
        if (char == '\\' && inString) {
          isEscaped = true;
          continue;
        }
        if (char == '"') {
          inString = !inString;
          continue;
        }
        if (!inString) {
          if (char == '{') depth++;
          if (char == '}') {
            depth--;
            if (depth == 0) {
              endIndex = i;
              break;
            }
          }
        }
      }

      if (endIndex != null) {
        final candidate = text.substring(braceIndex, endIndex + 1);
        final map = _tryDecodeMap(candidate);
        if (map != null) {
          if (map.containsKey('slides') || map.containsKey('sunum') || map.containsKey('slaytlar') || map.containsKey('presentation') || map.containsKey('data')) {
            final normalized = _tryNormalizePresentationPayload(map);
            if (normalized != null) return normalized;
          }
        }
        searchStart = braceIndex + 1;
      } else {
        // Yarıda kesilmiş JSON (Truncated JSON) - onar ve dene
        final candidate = text.substring(braceIndex);
        final repaired = _repairTruncatedJson(candidate);
        final map = _tryDecodeMap(repaired);
        if (map != null) {
          if (map.containsKey('slides') || map.containsKey('sunum') || map.containsKey('slaytlar') || map.containsKey('presentation') || map.containsKey('data')) {
            final normalized = _tryNormalizePresentationPayload(map);
            if (normalized != null) return normalized;
          }
        }
        break;
      }
    }
    return null;
  }

  /// Kesilmiş/tamamlanmamış JSON çıktısını açık tırnak ve parantezleri kapatıp kurtarır.
  static String _repairTruncatedJson(String raw) {
    var inString = false;
    var isEscaped = false;
    final openBrackets = <String>[];

    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      if (isEscaped) {
        isEscaped = false;
        continue;
      }
      if (char == '\\' && inString) {
        isEscaped = true;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        continue;
      }
      if (!inString) {
        if (char == '{') openBrackets.add('}');
        if (char == '[') openBrackets.add(']');
        if (char == '}' || char == ']') {
          if (openBrackets.isNotEmpty && openBrackets.last == char) {
            openBrackets.removeLast();
          }
        }
      }
    }

    var result = raw.trim();
    if (inString) {
      result += '"';
    }
    // Açık parantezleri ters sırada kapat
    for (final closeChar in openBrackets.reversed) {
      result += closeChar;
    }
    return result;
  }

  static List<Map<String, dynamic>> _extractAllSlidesFromText(String text) {
    final slides = <Map<String, dynamic>>[];

    // 1. Dengeli parantez tarayıcısı ile tüm geçerli veya onarılabilir slide nesnelerini topla
    var searchStart = 0;
    while (searchStart < text.length) {
      final braceIndex = text.indexOf('{', searchStart);
      if (braceIndex == -1) break;

      var depth = 0;
      var inString = false;
      var isEscaped = false;
      int? endIndex;

      for (var i = braceIndex; i < text.length; i++) {
        final char = text[i];
        if (isEscaped) {
          isEscaped = false;
          continue;
        }
        if (char == '\\' && inString) {
          isEscaped = true;
          continue;
        }
        if (char == '"') {
          inString = !inString;
          continue;
        }
        if (!inString) {
          if (char == '{') depth++;
          if (char == '}') {
            depth--;
            if (depth == 0) {
              endIndex = i;
              break;
            }
          }
        }
      }

      if (endIndex != null) {
        final candidate = text.substring(braceIndex, endIndex + 1);
        final map = _tryDecodeMap(candidate);
        if (map != null) {
          if (map.containsKey('slides') || map.containsKey('sunum') || map.containsKey('slaytlar')) {
            final normalized = _tryNormalizePresentationPayload(map);
            if (normalized != null && normalized['slides'] is List) {
              for (final item in normalized['slides'] as List) {
                if (item is Map<String, dynamic>) slides.add(item);
              }
            }
          } else if (_looksLikeSlideObject(map)) {
            slides.add(_standardizeSlideMap(map));
          }
        }
        searchStart = endIndex + 1;
      } else {
        final candidate = text.substring(braceIndex);
        final repaired = _repairTruncatedJson(candidate);
        final map = _tryDecodeMap(repaired);
        if (map != null) {
          if (map.containsKey('slides') || map.containsKey('sunum') || map.containsKey('slaytlar')) {
            final normalized = _tryNormalizePresentationPayload(map);
            if (normalized != null && normalized['slides'] is List) {
              for (final item in normalized['slides'] as List) {
                if (item is Map<String, dynamic>) slides.add(item);
              }
            }
          } else if (_looksLikeSlideObject(map)) {
            slides.add(_standardizeSlideMap(map));
          }
        }
        break;
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
      final decoded = _tryDecodeMap(part) ?? _tryDecodeMap(_repairTruncatedJson(part));
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

  static List<Map<String, dynamic>> _extractSlidesFromFormattedText(
      String text) {
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
