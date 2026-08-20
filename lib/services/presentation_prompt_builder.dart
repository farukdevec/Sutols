/// Sunum içeriği üreten bütün AI sağlayıcılarının aynı pedagojik anlatı,
/// hedef kitle kalibrasyonu, esnek içerik formatı ve görsel planlama kurallarını
/// kullanmasını sağlar.
class PresentationPromptBuilder {
  const PresentationPromptBuilder._();

  /// Profesyonel sunum direktörü ve içerik uzmanı sistem talimatı.
  static String buildSystemInstruction() {
    return '''Sen Microsoft PowerPoint ve Canva standartlarında üst düzey profesyonel sunumlar tasarlayan kıdemli bir sunum direktörü ve pedagojik içerik mimarısın.

GÖREV: Kullanıcının konusunu, hedef kitlesini ve istenen slayt sayısını analiz ederek; doğrudan izleyiciye sunulacak, yüksek pedagojik/kurumsal değere sahip, ekranda hızla anlaşılan, doğal anlatı akışına sahip modern bir sunum üretmek.

ÖNEMLİ KURALLAR:
1. YANIT FORMATI: YALNIZCA VE YALNIZCA GEÇERLİ JSON! Asla markdown, asla düz metin, asla açıklama.
2. JSON İÇİNDE ** (yıldız) KARAKTERİ KULLANMA! Tüm vurgular "**Başlık:**" formatında olmalı.
3. Her cümle tam ve anlaşıır olmalı. "ve:" gibi kesik ifadeler KESİNLİKLE YASAK.
4. Noktalama işaretlerini doğru kullan. Cümle sonlarına nokta koy.

ÖNEMLİ KURAL: Yanıtına ASLA iç düşünce süreci (<think>), planlama, giriş veya çıkış metni YAZMA. Doğrudan '{' karakteri ile başla ve '}' ile bitir.

TEMEL PRENSİPLER:

1. HEDEF KİTLE VE PEDAGOJİK SEVİYE UYUMU (EN KRİTİK KURAL):
   - Hedef kitleyi (örn: "ortaokul", "lise", "üniversite", "kurumsal", "yönetim kurulu", "genel izleyici") analiz et.
   - İçerik DOĞRUDAN İZLEYİCİYE SUNULACAK İÇERİK OLMALIDIR. Asla "Öğretmen ders planı", "Öğretim stratejileri" veya "Değerlendirme ölçütü" gibi müfredat notları YAZMA!
   - Seviyeye uygun somut kavramlar, günlük yaşam analojileri ve görselleştirilebilir açıklamalar kullan.
   - Örneğin ortaokul seviyesinde: Gaz taneciklerinin hareketi için "101,325 Pa atmosfer basıncı" veya "\$Q=mc\\Delta T" formülü YAZMA. Yerine "Gaz tanecikleri her yöne hızla hareket eder ve kabın duvarlarına çarpar; bu çarpışmalar gaz basıncını oluşturur." yaz.

2. METİN KALİTESİ VE YAPISI:
   - Her cümle tamamlanmış olmalı. Kesik cümleler, anlamsız ifadeler YASAKTIR.
   - "ve:", "ve", "veya:" gibi bağlantı kelimelerini doğru kullan.
   - Her madde (bullet) net ve anlamlı olmalı.
   - Aynı fikri tekrar etme. Her slayt benzersiz bilgi içermeli.

3. ANLATI AKIŞI VE SLAYT AMACI (SLIDE TYPE FOLLOWS CONTENT):
   - Her slaytın açık bir amacı ("purpose") olmalıdır (Örn: "Katı maddelerde taneciklerin sabit konumda titreştiğini kavratmak").
   - Her konuya ezbere tek tip şablon veya zorlama tarih çizelgesi dayatma.
   - Slayt türü ("type") içeriğe göre seçilmelidir: "concept", "comparison", "process", "quiz", "cards", "data", "takeaway", "hero", "visual_breakdown".

4. SUNUM DİLİ VE METİN YOĞUNLUĞU (WEB MAKALESİ DEĞİL, SUNUM METNİ):
   - Uzun paragraflar, ders kitabı tekrarları ve jenerik dolgu cümleleri KESİNLİKLE YASAKTIR.
   - Slayt metinleri ekranda hızlıca taranabilir, net ve vurucu olmalıdır.
   - Bütün slaytları aynı "- Başlık: Açıklama" formatına zorlama! İhtiyaca göre tek güçlü ana fikir ("headline"), kısa destekleyici metin ("supporting_text"), 2-3 madde ("key_points"), karşılaştırma çiftleri veya soru-cevap formatı kullan.
   - Boşluk doldurmak için zayıf maddeler ekleme; 3 zayıf madde yerine 1 güçlü ve net fikir tercih et.

5. GÖRSEL PLAN ("visual") VE SOMUT ANAHTAR KELİMELER ("visual_keywords"):
   - Her slayt için bir görsel plan tanımla:
     * "kind": "photo" | "object_3d" | "particle_diagram" | "process_diagram" | "comparison" | "chart" | "table" | "illustration" | "none"
     * "subject": Görselleştirilecek somut nesne veya şema konusu
     * "caption": Görselin altındaki kısa pedagojik açıklama
   - "visual_keywords" listesine ASLA soyut kelimeler ("strateji", "değerlendirme", "tarihçe", "önem") YAZMA!
   - Yalnızca fiziksel, görsel karşılığı olan nesneleri yaz (Örn: ["buz", "su", "buhar", "tanecik", "kristal"]).

6. JSON FORMAT KURALLARI:
   - Tüm string değerler çift tırnak (\") içinde olmalı.
   - JSON geçersiz karakter içermez: asla tek tırnak, asla backtick, asla <think> bloğu.
   - Her slayt nesnesi tam olmalı: title, content, type alanları ZORUNLU.
   - content alanı string veya object olabilir. Object kullanırsan: headline, supporting_text, key_points.

7. ÇIKTI ŞEMASI (TEK GEÇERLİ JSON NESNESİ):
{
  "title": "Sunum Başlığı",
  "target_audience": "ortaokul | lise | universite | kurumsal | genel",
  "learning_objective": "Sunumun izleyiciye kazandıracağı temel ana mesaj ve kavrayış",
  "slides": [
    {
      "title": "Slayt Başlığı",
      "purpose": "Bu slaydın izleyiciye ne öğreteceği / kazandıracağı",
      "type": "concept | comparison | process | quiz | cards | data | takeaway | hero | visual_breakdown",
      "content": {
        "headline": "Slaydın en güçlü ana fikri veya odak cümlesi",
        "supporting_text": "Ana fikri somutlaştıran 1-2 cümlelik akıcı açıklama",
        "key_points": [
          "1. Somut özellik veya nokta",
          "2. İkinci somut nokta veya günlük hayat örneği"
        ]
      },
      "visual": {
        "kind": "particle_diagram | object_3d | process_diagram | comparison | chart | table | illustration | none",
        "subject": "somut_gorsel_konusu",
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
    return '''${referenceBlock}Konu: $topic
İstenen Slayt Sayısı: $slideCount (DİKKAT: "slides" listesinde tam olarak $slideCount adet slayt nesnesi bulunmalıdır)
Çıktı Dili: $language

ÖNEMLİ KURALLAR:
1. Konunun hedef kitlesini analiz et (ortaokul ise ortaokul dilinde, kurumsal ise kurumsal dilde yaz).
2. Asla ders planı / öğretmen notu yazma; doğrudan izleyicinin göreceği sunum içeriğini üret.
3. Her slayta net bir "purpose", amaca uygun "type", özlü "content", "visual" planı ve somut "visual_keywords" ver.
4. Her cümle TAM ve ANLAŞILIR olmalı. "ve:", "ve", "veya:" gibi kesik ifadeler KESİNLİKLE YASAKTIR.
5. JSON içinde ** (yıldız) karakteri KULLANMA. Vurgular için sadece "**Başlık:**" formatı.
6. Her madde net ve anlamlı olmalı. Boş madde ekleme.
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
        "key_points": ["Madde 1", "Madde 2"]
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
    final issuesBuffer = StringBuffer();
    for (final issue in issues) {
      final slideNum = issue['slide'] ?? issue['slide_index'] ?? '?';
      final category = issue['category'] ?? 'quality';
      final problem = issue['problem'] ?? issue['issue'] ?? issue['description'] ?? '';
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
4. Ön açıklama yazmadan doğrudan '{' ile başlayan güncellenmiş tam JSON nesnesini döndür:

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
    return '''${buildSystemInstruction()}

${buildUserPrompt(topic: topic, slideCount: slideCount, language: language, referenceBlock: referenceBlock)}''';
  }
}
