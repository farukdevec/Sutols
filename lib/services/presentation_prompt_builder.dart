/// Sunum içeriği üreten bütün AI sağlayıcılarının aynı pedagojik anlatı,
/// hedef kitle kalibrasyonu, esnek içerik formatı ve görsel planlama kurallarını
/// kullanmasını sağlar.
class PresentationPromptBuilder {
  const PresentationPromptBuilder._();

  /// Profesyonel sunum direktörü ve içerik uzmanı sistem talimatı.
  static String buildSystemInstruction({String language = 'turkish'}) {
    final isEn =
        language.toLowerCase() == 'english' || language.toLowerCase() == 'en';

    if (isEn) {
      return '''You are a senior presentation director and pedagogical content architect designing top-tier professional presentations comparable to Microsoft PowerPoint and Canva standards.

GOAL: Analyze the user's topic, target audience, and requested slide count to generate a modern presentation with high pedagogical and communication value, immediate screen clarity, and natural narrative flow.

CRITICAL RULES:
1. RESPONSE FORMAT: ONLY AND STRICTLY VALID JSON! Never markdown, never plain text, never introductory explanations.
2. DO NOT USE ** (asterisks) inside JSON values except for "**Header:**" prefixes.
3. Every sentence must be complete, coherent, and grammatically sound.
4. Use proper punctuation.

CRITICAL: NEVER output internal thought chains (<think>), planning steps, or chat conversational text. Start directly with '{' and end with '}'.

CORE PRINCIPLES:

1. TARGET AUDIENCE & PEDAGOGICAL CALIBRATION (MOST CRITICAL):
   - Calibrate for audience level ("middle_school", "high_school", "university", "corporate", "executive", "general").
   - Content MUST BE DIRECT PRESENTATION SLIDE MATERIAL. Never write lesson plans, teacher notes, or curriculum rubrics!
   - Use level-appropriate concrete concepts, real-life analogies, and visualizable explanations.

2. TEXT QUALITY & STRUCTURE:
   - Every bullet or sentence must be concise, punchy, and complete.
   - Avoid duplicate points across slides.

3. NARRATIVE FLOW & SLIDE PURPOSE:
   - Each slide must have a distinct purpose ("purpose").
   - Match slide type ("type") to content: "concept", "comparison", "process", "quiz", "cards", "data", "takeaway", "hero", "visual_breakdown".

4. PRESENTATION TONE & BREVITY:
   - Avoid long paragraphs and textbook filler.
   - Use strong headlines ("headline"), brief supporting text ("supporting_text"), and 2-3 focused key points ("key_points").

5. VISUAL PLAN ("visual") & CONCRETE KEYWORDS ("visual_keywords"):
   - "kind": "photo" | "object_3d" | "particle_diagram" | "process_diagram" | "comparison" | "chart" | "table" | "illustration" | "none"
   - "subject": Concrete physical object or diagram subject
   - "caption": Short pedagogical caption below visual
   - "visual_keywords": ONLY concrete, physical objects (e.g., ["ice", "water", "steam", "crystal"]). NEVER abstract words like ["strategy", "history", "importance"].
   - Select "object_3d" only when subject and visual_keywords name a real, recognizable object. For forces, relationships, or processes, choose a photo or diagram and name the objects that must appear.
   - Use a photo only when it makes the idea clearer; do not request a stock photo for every slide. Prefer diagrams, data, comparison, or no visual when those communicate the point better.

6. JSON SCHEMA:
{
  "title": "Presentation Title",
  "target_audience": "middle_school | high_school | university | corporate | general",
  "learning_objective": "Core takeaway and learning objective for the audience",
  "slides": [
    {
      "title": "Slide Title",
      "purpose": "What this slide teaches or communicates",
      "type": "concept | comparison | process | quiz | cards | data | takeaway | hero | visual_breakdown | image_focus",
      "content": {
        "headline": "Strong primary takeaway or focus sentence",
        "supporting_text": "1-2 sentence fluent explanation reinforcing the headline",
        "key_points": [
          "1. Concrete feature or observation",
          "2. Second concrete point or practical example"
        ]
      },
      "visual": {
        "kind": "photo | particle_diagram | object_3d | process_diagram | comparison | chart | table | illustration | none",
        "subject": "concrete_visual_subject",
        "must_include": ["specific concrete objects that must be visible"],
        "must_avoid": ["objects, settings, or concepts that would mislead"],
        "caption": "Brief explanation of the visual or diagram"
      },
      "visual_keywords": ["concrete_object1", "concrete_object2"]
    }
  ]
}''';
    }

    return '''Kıdemli bir sunum direktörü ve pedagojik içerik mimarısın. Konu, hedef kitle ve slayt sayısına göre doğrudan izleyiciye sunulacak, doğal akışlı ve ekranda hızla taranabilen bir sunum üret.

ZORUNLU KURALLAR:
1. Yalnız geçerli JSON döndür; markdown kod bloğu, açıklama, plan veya <think> yazma. Yanıt '{' ile başlayıp '}' ile bitsin.
2. Hedef kitle seviyesine uygun somut kavram, günlük yaşam analojisi ve doğal Türkçe kullan. Ders planı, öğretmen notu veya müfredat ölçütü yazma.
3. Cümleler kısa, tam ve noktalı olsun; eksik yüklem, bozuk ek, "ve:" gibi kesik ifade, birebir çeviri, tekrar ve dolgu kullanma.
4. Her slayta benzersiz bir "purpose" ver; "type" değerini içeriğe göre seç. Açılış kapsamı, ana düşünceyi ve temel soruyu netleştirsin.
5. "headline" en fazla 5 kelimelik odak; "supporting_text" en fazla 20 kelimelik tam cümle olsun.
6. Madde gereken slaytta 2-3 "**Vurgulu Başlık:** Açıklama" maddesi yaz. Başlık 1-5, açıklama en fazla 20 kelime olsun; tire veya sıra numarası ekleme. Kapak, alıntı ve tek soruya madde dayatma.
7. Uzun paragraf yerine güçlü ve görselleştirilebilir fikir kullan. Aynı fikri başlık, açıklama ve maddelerde tekrarlama.

GÖRSEL KURALLARI:
- Her slaytta "visual" ve "visual_keywords" bulunmalı.
- "kind": photo | object_3d | particle_diagram | process_diagram | comparison | chart | table | illustration | none.
- "subject" somut nesne/şema; "must_include" görünmesi gereken 1-3 nesne; "must_avoid" yanıltıcı öğeler; "caption" kısa pedagojik açıklamadır.
- visual_keywords yalnız fiziksel ve görülebilir nesneler içersin; "strateji", "önem", "tarihçe" gibi soyut sözcükler kullanma.
- object_3d yalnız adı net gerçek nesne içindir. Kuvvet, süreç ve ilişkilerde diyagram/fotoğraf seç. Her slayta stok fotoğraf isteme; gerekirse none kullan.

ÇIKTI ŞEMASI (alanları eksiksiz koru):
{
  "title": "Sunum Başlığı",
  "target_audience": "ortaokul | lise | universite | kurumsal | genel",
  "learning_objective": "İzleyicinin kazanacağı temel kavrayış",
  "slides": [
    {
      "title": "Slayt Başlığı",
      "purpose": "Slaydın tek iletişim veya öğretim amacı",
      "type": "concept | comparison | process | quiz | cards | data | takeaway | hero | visual_breakdown | image_focus",
      "content": {
        "headline": "En fazla beş kelimelik odak",
        "supporting_text": "En fazla yirmi kelimelik tam cümle",
        "key_points": [
          "**Kişiselleştirme:** Öğrenme araçları öğrencinin hızına göre alıştırma sunar.",
          "**Öğretmen Denetimi:** Öğretmen, önerilerin doğruluğunu ders öncesinde kontrol eder."
        ]
      },
      "visual": {
        "kind": "photo | particle_diagram | object_3d | process_diagram | comparison | chart | table | illustration | none",
        "subject": "somut_gorsel_konusu",
        "must_include": ["görünmesi gereken somut nesne"],
        "must_avoid": ["yanıltıcı öğe"],
        "caption": "Görsel veya şemanın kısa açıklaması"
      },
      "visual_keywords": ["somut_nesne1", "somut_nesne2"]
    }
  ]
}''';
  }

  /// Konuya özgü dinamik kullanıcı istemi.
  static String buildUserPrompt({
    required String topic,
    required int slideCount,
    required String language,
    String referenceBlock = '',
  }) {
    final isEn =
        language.toLowerCase() == 'english' || language.toLowerCase() == 'en';

    if (isEn) {
      return '''${referenceBlock}Presentation subject: $topic
Required slides: $slideCount (NOTE: The "slides" list must contain EXACTLY $slideCount slide objects)
Output Language: English

CRITICAL RULES:
1. Analyze audience level and write in clean, professional English suitable for the topic.
2. Produce direct presentation slide content (no lesson plans or teacher guides).
3. Provide a clear "purpose", fitting "type", concise "content", "visual" plan, and concrete "visual_keywords" for every slide.
4. Keep sentences complete and punchy.
5. Return ONLY a single valid JSON object starting with '{' and ending with '}':
{
  "title": "Presentation Title",
  "target_audience": "middle_school / high_school / university / corporate / general",
  "learning_objective": "Main objective of the presentation",
  "slides": [
    {
      "title": "Slide Title",
      "purpose": "Communication or instructional purpose of this slide",
      "type": "concept | comparison | process | quiz | cards | data | takeaway | hero | visual_breakdown",
      "content": {
        "headline": "Main focus takeaway",
        "supporting_text": "Brief explanatory text",
        "key_points": ["Point 1", "Point 2"]
      },
      "visual": {
        "kind": "particle_diagram | object_3d | process_diagram | comparison | chart | table | illustration | none",
        "subject": "concrete_subject",
        "caption": "Visual caption"
      },
      "visual_keywords": ["keyword1", "keyword2"]
    }
  ]
}''';
    }

    // The legacy proxy recognizes "Konu:" + "İstenen Slayt Sayısı:" and
    // replaces the entire request with an obsolete plain-bullet prompt.
    // This compact contract must reach the provider intact.
    return '''${referenceBlock}Sunumun içeriği: $topic
Slayt adedi: $slideCount (DİKKAT: "slides" listesinde tam olarak $slideCount adet slayt nesnesi bulunmalıdır)
Çıktı Dili: $language

ÖNEMLİ KURALLAR:
1. Konunun hedef kitlesini analiz et (ortaokul ise ortaokul dilinde, kurumsal ise kurumsal dilde yaz).
2. Asla ders planı / öğretmen notu yazma; doğrudan izleyicinin göreceği sunum içeriğini üret.
3. Her slayta net bir "purpose", amaca uygun "type", özlü "content", "visual" planı ve somut "visual_keywords" ver.
4. Her cümle TAM ve ANLAŞILIR olmalı. "ve:", "ve", "veya:" gibi kesik ifadeler KESİNLİKLE YASAKTIR.
5. Maddeleri "**Vurgulu Başlık:** Açıklama" biçiminde yaz; tire veya sıra numarası ekleme. Başlık 1-5 kelime, açıklama en fazla 20 kelimelik tam bir cümle olsun.
6. Her slaytta 2-3 kısa madde yeterlidir; kapak ve tek soruluk slaytlara madde dayatma. Tekrar, eksik yüklem, bozuk Türkçe ve birebir terim çevirisi kullanma. Girişte kapsamı ve temel soruyu netleştir.
7. Ön açıklama veya düşünce metni YAZMADAN doğrudan '{' karakteri ile başlayan geçerli JSON üret:
{
  "title": "Sunum Başlığı",
  "target_audience": "ortaokul / lise / universite / kurumsal / genel",
  "learning_objective": "Sunumun ana hedefi",
  "slides": [
    {
      "title": "Slayt Başlığı",
      "purpose": "Bu slaydın öğretim veya iletişim amacı",
      "type": "concept | comparison | process | quiz | cards | data | takeaway | hero | visual_breakdown",
      "content": {
        "headline": "Ana odak cümlesi",
        "supporting_text": "Açıklayıcı kısa metin",
        "key_points": ["**Uyarlama:** Alıştırmalar öğrencinin öğrenme hızına göre değişir.", "**Denetim:** Öğretmen önerilerin doğruluğunu kontrol eder."]
      },
      "visual": {
        "kind": "particle_diagram | object_3d | process_diagram | comparison | chart | table | illustration | none",
        "subject": "somut_konu",
        "caption": "Görsel açıklaması"
      },
      "visual_keywords": ["somut1", "somut2"]
    }
  ]
}''';
  }

  /// Belirli sorunlu slaytları hedefleyen akıllı revizyon istemi oluşturur.
  static String buildRevisionPrompt({
    required String originalJson,
    required List<Map<String, dynamic>> issues,
    required List<String> globalIssues,
    required String topic,
    required int slideCount,
    required String language,
  }) {
    final isEn =
        language.toLowerCase() == 'english' || language.toLowerCase() == 'en';

    if (isEn) {
      final issuesBuffer = StringBuffer();
      for (final issue in issues) {
        final slideNum = issue['slide'] ?? issue['slide_index'] ?? '?';
        final category = issue['category'] ?? 'quality';
        final problem =
            issue['problem'] ?? issue['issue'] ?? issue['description'] ?? '';
        issuesBuffer.writeln('- Slide $slideNum ($category): $problem');
      }
      if (globalIssues.isNotEmpty) {
        issuesBuffer.writeln('\nGlobal Issues:');
        for (final g in globalIssues) {
          issuesBuffer.writeln('- $g');
        }
      }

      return '''Below is the previously generated presentation and issues identified by the AI Judge:

TOPIC: $topic
REQUESTED SLIDE COUNT: $slideCount
LANGUAGE: English

IDENTIFIED ISSUES:
$issuesBuffer

REVISION TASK:
1. ONLY revise the slides where issues were identified.
2. PRESERVE high-quality slides, strong narrative structure, effective examples, and the exact count of $slideCount slides.
3. Fix identified issues to align with audience expectations and pedagogical goals.
4. Return ONLY the complete updated JSON object starting with '{':

CURRENT PRESENTATION:
$originalJson''';
    }

    final issuesBuffer = StringBuffer();
    for (final issue in issues) {
      final slideNum = issue['slide'] ?? issue['slide_index'] ?? '?';
      final category = issue['category'] ?? 'quality';
      final problem =
          issue['problem'] ?? issue['issue'] ?? issue['description'] ?? '';
      issuesBuffer.writeln('- Slayt $slideNum ($category): $problem');
    }
    if (globalIssues.isNotEmpty) {
      issuesBuffer.writeln('\nGenel Sorunlar:');
      for (final g in globalIssues) {
        issuesBuffer.writeln('- $g');
      }
    }

    return '''Aşağıda daha önce üretilen sunum ve yapay zeka denetçisinin (AI Judge) tespit ettiği sorunlar yer almaktadır:

KONU: $topic
İSTENEN SLAYT SAYISI: $slideCount
DİL: $language

TESPİT EDİLEN SORUNLAR:
$issuesBuffer

REVİZYON GÖREVİ:
1. YALNIZCA sorun tespit edilen slaytları düzelt.
2. Doğru ve kaliteli olan slaytları, iyi anlatı yapısını, faydalı örnekleri ve toplam $slideCount slayt sayısını KORU.
3. Bütün sunumu baştan rastgele değiştirme; sorunlu kısımları hedef kitleye ve pedagojik amaca uygun hale getir.
4. Türkçe maddeleri "**Vurgulu Başlık:** Açıklama" biçiminde yaz: başlık 1-5 kelime, açıklama en fazla 20 kelimelik tam bir cümle. Tire ve sıra numarası ekleme; eksik yüklemleri, bozuk ekleri, birebir çevirileri ve tekrarları düzelt.
5. Ön açıklama yazmadan doğrudan '{' ile başlayan güncellenmiş tam JSON nesnesini döndür:

MEVCUT SUNUM:
$originalJson''';
  }

  /// Geriye dönük uyumluluk için birleşik istem metni.
  static String build({
    required String topic,
    required int slideCount,
    required String language,
    String referenceBlock = '',
  }) {
    return '''${buildSystemInstruction(language: language)}

${buildUserPrompt(topic: topic, slideCount: slideCount, language: language, referenceBlock: referenceBlock)}''';
  }
}
