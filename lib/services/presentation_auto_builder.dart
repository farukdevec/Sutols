import 'package:flutter/material.dart';

import '../models/slide_model.dart';
import '../state/language_controller.dart';
import 'presentation_keyword_catalog.dart';

class PresentationDraftPage {
  const PresentationDraftPage({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  bool get isBlank => title.trim().isEmpty && body.trim().isEmpty;
}

/// Sunum oluşturulurken kullanılan görsel düzen. `automatic`, konuya göre
/// arka plan seçer; diğer seçenekler ise sunum boyunca tutarlı bir görünüm
/// sağlar.
enum PresentationTemplate {
  automatic,
  academic,
  corporate,
  creative,
  minimal,
  darkCorporate,
  techStartup,
  scientific,
  elegant,
  bold,
  pastel,
  highContrast,
  astronomi,
  beslenme,
  biyoloji,
  cevre,
  cografya,
  deniz,
  dijital,
  doga,
  edebiyat,
  egitim,
  ekoloji,
  enerji,
  evcilHayvan,
  felsefe,
  fizik,
  fotograf,
  futuristik,
  gastronomi,
  girisimcilik,
  havacilik,
  hukuk,
  isHayati,
  kimya,
  liderlik,
  matematik,
  meteoroloji,
  mitoloji,
  moda,
  muhendislik,
  muzik,
  oyun,
  optik,
  pazarlama,
  psikoloji,
  robotik,
  saglik,
  sanat,
  sehir,
  seyahat,
  sinema,
  spor,
  tarih,
  tip,
  tiyatro,
  toplum,
  ulasim,
  uzay,
  vintage,
  yapayZeka,
  yazilim,
  cyberpunk,
  glassmorphism,
  luxuryGold,
  ecoGreen,
  synthwave,
  gradientMesh,
  editorial,
  bauhaus,
  dataTech,
  deepSpace,
  bentoGrid,
  auroraBorealis,
  neomorphism,
  holographic,
  nordicMinimal,
  claymorphism,
}

String presentationTemplateLabel(PresentationTemplate template) {
  switch (template) {
    case PresentationTemplate.automatic:
      return tr('Otomatik', 'Automatic');
    case PresentationTemplate.academic:
      return tr('Akademik', 'Academic');
    case PresentationTemplate.corporate:
      return tr('Kurumsal', 'Corporate');
    case PresentationTemplate.creative:
      return tr('Yaratıcı', 'Creative');
    case PresentationTemplate.minimal:
      return tr('Minimal', 'Minimal');
    case PresentationTemplate.darkCorporate:
      return tr('Koyu Kurumsal', 'Dark Corporate');
    case PresentationTemplate.techStartup:
      return tr('Teknoloji Girişimi', 'Tech Startup');
    case PresentationTemplate.cyberpunk:
      return tr('Siberpunk Neon', 'Cyberpunk Neon');
    case PresentationTemplate.glassmorphism:
      return tr('Buzlu Cam (Glassmorphism)', 'Glassmorphism');
    case PresentationTemplate.luxuryGold:
      return tr('Lüks Altın & Premium', 'Luxury Gold & Premium');
    case PresentationTemplate.ecoGreen:
      return tr('Eko Doğa & Yeşil', 'Eco Green & Nature');
    case PresentationTemplate.synthwave:
      return tr('Retro Synthwave 80s', 'Retro Synthwave 80s');
    case PresentationTemplate.gradientMesh:
      return tr('Gradyan Renk Ağları', 'Gradient Mesh');
    case PresentationTemplate.editorial:
      return tr('Dergi Tipografi (Editorial)', 'Editorial Typography');
    case PresentationTemplate.bauhaus:
      return tr('Bauhaus Geometrik', 'Bauhaus Geometric');
    case PresentationTemplate.dataTech:
      return tr('Finansal & Veri Analitiği', 'Data & Finance Analytics');
    case PresentationTemplate.deepSpace:
      return tr('Koyu Kozmik & Kuantum', 'Dark Cosmic & Quantum');
    case PresentationTemplate.scientific:
      return tr('Bilimsel', 'Scientific');
    case PresentationTemplate.elegant:
      return tr('Şık', 'Elegant');
    case PresentationTemplate.bold:
      return tr('Cesur', 'Bold');
    case PresentationTemplate.pastel:
      return tr('Pastel', 'Pastel');
    case PresentationTemplate.highContrast:
      return tr('Yüksek Kontrast', 'High Contrast');
    case PresentationTemplate.astronomi:
      return tr('Astronomi', 'Astronomy');
    case PresentationTemplate.beslenme:
      return tr('Beslenme', 'Nutrition');
    case PresentationTemplate.biyoloji:
      return tr('Biyoloji', 'Biology');
    case PresentationTemplate.cevre:
      return tr('Çevre', 'Environment');
    case PresentationTemplate.cografya:
      return tr('Coğrafya', 'Geography');
    case PresentationTemplate.deniz:
      return tr('Deniz', 'Ocean & Sea');
    case PresentationTemplate.dijital:
      return tr('Dijital', 'Digital');
    case PresentationTemplate.doga:
      return tr('Doğa', 'Nature');
    case PresentationTemplate.edebiyat:
      return tr('Edebiyat', 'Literature');
    case PresentationTemplate.egitim:
      return tr('Eğitim', 'Education');
    case PresentationTemplate.ekoloji:
      return tr('Ekoloji', 'Ecology');
    case PresentationTemplate.enerji:
      return tr('Enerji', 'Energy');
    case PresentationTemplate.evcilHayvan:
      return tr('Evcil Hayvan', 'Pets & Animals');
    case PresentationTemplate.felsefe:
      return tr('Felsefe', 'Philosophy');
    case PresentationTemplate.fizik:
      return tr('Fizik', 'Physics');
    case PresentationTemplate.fotograf:
      return tr('Fotoğraf', 'Photography');
    case PresentationTemplate.futuristik:
      return tr('Fütüristik', 'Futuristic');
    case PresentationTemplate.gastronomi:
      return tr('Gastronomi', 'Gastronomy');
    case PresentationTemplate.girisimcilik:
      return tr('Girişimcilik', 'Entrepreneurship');
    case PresentationTemplate.havacilik:
      return tr('Havacılık', 'Aviation');
    case PresentationTemplate.hukuk:
      return tr('Hukuk', 'Law & Justice');
    case PresentationTemplate.isHayati:
      return tr('İş Hayatı', 'Business');
    case PresentationTemplate.kimya:
      return tr('Kimya', 'Chemistry');
    case PresentationTemplate.liderlik:
      return tr('Liderlik', 'Leadership');
    case PresentationTemplate.matematik:
      return tr('Matematik', 'Mathematics');
    case PresentationTemplate.meteoroloji:
      return tr('Meteoroloji', 'Meteorology');
    case PresentationTemplate.mitoloji:
      return tr('Mitoloji', 'Mythology');
    case PresentationTemplate.moda:
      return tr('Moda', 'Fashion');
    case PresentationTemplate.muhendislik:
      return tr('Mühendislik', 'Engineering');
    case PresentationTemplate.muzik:
      return tr('Müzik', 'Music');
    case PresentationTemplate.oyun:
      return tr('Oyun', 'Gaming');
    case PresentationTemplate.optik:
      return tr('Optik', 'Optics');
    case PresentationTemplate.pazarlama:
      return tr('Pazarlama', 'Marketing');
    case PresentationTemplate.psikoloji:
      return tr('Psikoloji', 'Psychology');
    case PresentationTemplate.robotik:
      return tr('Robotik', 'Robotics');
    case PresentationTemplate.saglik:
      return tr('Sağlık', 'Healthcare');
    case PresentationTemplate.sanat:
      return tr('Sanat', 'Art');
    case PresentationTemplate.sehir:
      return tr('Şehir', 'Urban & Cities');
    case PresentationTemplate.seyahat:
      return tr('Seyahat', 'Travel');
    case PresentationTemplate.sinema:
      return tr('Sinema', 'Cinema');
    case PresentationTemplate.spor:
      return tr('Spor', 'Sports');
    case PresentationTemplate.tarih:
      return tr('Tarih', 'History');
    case PresentationTemplate.tip:
      return tr('Tıp', 'Medicine');
    case PresentationTemplate.tiyatro:
      return tr('Tiyatro', 'Theater');
    case PresentationTemplate.toplum:
      return tr('Toplum', 'Society');
    case PresentationTemplate.ulasim:
      return tr('Ulaşım', 'Transportation');
    case PresentationTemplate.uzay:
      return tr('Uzay', 'Space');
    case PresentationTemplate.vintage:
      return tr('Vintage', 'Vintage');
    case PresentationTemplate.yapayZeka:
      return tr('Yapay Zeka', 'Artificial Intelligence');
    case PresentationTemplate.yazilim:
      return tr('Yazılım', 'Software');
    case PresentationTemplate.bentoGrid:
      return tr('Bento Grid Kartlar', 'Bento Grid Cards');
    case PresentationTemplate.auroraBorealis:
      return tr('Aurora Yeşil & Mor Işıltı', 'Aurora Borealis Glow');
    case PresentationTemplate.neomorphism:
      return tr('Neumorphic Yumuşak 3D', 'Neumorphic Soft 3D');
    case PresentationTemplate.holographic:
      return tr('Holografik Siber Işıltı', 'Holographic Cyber Glow');
    case PresentationTemplate.nordicMinimal:
      return tr('İskandinav Tipografik Minimal', 'Nordic Typographic Minimal');
    case PresentationTemplate.claymorphism:
      return tr('Kil 3D Pasteller (Claymorphism)', 'Claymorphism 3D Pastels');
  }
}

String presentationTemplateDescription(PresentationTemplate template) {
  switch (template) {
    case PresentationTemplate.automatic:
      return tr('Konuya göre seçilir', 'Automatically chosen based on topic');
    case PresentationTemplate.academic:
      return tr('Dengeli, açıklayıcı düzen', 'Balanced, explanatory layout');
    case PresentationTemplate.corporate:
      return tr('Net ve profesyonel görünüm', 'Clear and professional look');
    case PresentationTemplate.creative:
      return tr('Vurucu, görsel odaklı sahne', 'Striking, visual-focused scenes');
    case PresentationTemplate.minimal:
      return tr('Sade, metin odaklı düzen', 'Simple, text-focused layout');
    case PresentationTemplate.darkCorporate:
      return tr('Koyu tema, executive sunumlar', 'Dark theme for executive decks');
    case PresentationTemplate.techStartup:
      return tr('Modern, teknoloji odaklı', 'Modern, technology-driven');
    case PresentationTemplate.scientific:
      return tr('Veri ve bilim odaklı temiz tasarım', 'Data and science focused clean design');
    case PresentationTemplate.elegant:
      return tr('Zarif, yüksek estetik', 'Graceful, high-aesthetic layout');
    case PresentationTemplate.bold:
      return tr('Güçlü, dikkat çekici', 'Strong, eye-catching style');
    case PresentationTemplate.pastel:
      return tr('Yumuşak, dostane tonlar', 'Soft, friendly tones');
    case PresentationTemplate.highContrast:
      return tr('Maksimum okunabilirlik', 'Maximum readability');
    case PresentationTemplate.astronomi:
      return tr('Uzay ve gök bilimi odaklı dramatik sunum', 'Dramatic presentation for space and astronomy');
    case PresentationTemplate.beslenme:
      return tr('Sağlıklı yaşam ve beslenme odaklı doğal tasarım', 'Natural design for healthy living and nutrition');
    case PresentationTemplate.biyoloji:
      return tr('Canlı bilimi ve genetik odaklı modern görünüm', 'Modern look for life sciences and genetics');
    case PresentationTemplate.cevre:
      return tr('Çevre bilinci ve sürdürülebilirlik temalı', 'Environmental awareness and sustainability');
    case PresentationTemplate.cografya:
      return tr('Coğrafi keşif ve harita odaklı düzen', 'Geographical exploration and map layout');
    case PresentationTemplate.deniz:
      return tr('Deniz ve okyanus temalı akıcı sahne', 'Fluid scene for oceans and marine topics');
    case PresentationTemplate.dijital:
      return tr('Modern dijital dönüşüm ve teknoloji odaklı', 'Digital transformation and modern tech');
    case PresentationTemplate.doga:
      return tr('Doğal güzellikler ve organik yaşam temalı', 'Natural beauty and organic lifestyle');
    case PresentationTemplate.edebiyat:
      return tr('Edebi metin ve şiir odaklı zarif düzen', 'Refined layout for literature and poetry');
    case PresentationTemplate.egitim:
      return tr('Ders ve akademik içerik için temiz tasarım', 'Clean design for courses and education');
    case PresentationTemplate.ekoloji:
      return tr('Ekosistem ve biyolojik çeşitlilik odaklı', 'Ecosystems and biodiversity focus');
    case PresentationTemplate.enerji:
      return tr('Yenilenebilir enerji ve güç sistemleri temalı', 'Renewable energy and power systems');
    case PresentationTemplate.evcilHayvan:
      return tr('Hayvan dostu sıcak ve samimi sunum', 'Warm and friendly presentation for pets');
    case PresentationTemplate.felsefe:
      return tr('Derin düşünce ve felsefi sorgulama odaklı', 'Deep thought and philosophical inquiry');
    case PresentationTemplate.fizik:
      return tr('Fizik yasaları ve mekanik odaklı bilimsel düzen', 'Scientific layout for physics and mechanics');
    case PresentationTemplate.fotograf:
      return tr('Görsel sanatlar ve fotoğrafçılık odaklı yaratıcı sahne', 'Creative scene for visual arts and photography');
    case PresentationTemplate.futuristik:
      return tr('Gelecek teknolojileri ve yenilikçi vizyon temalı', 'Future tech and innovative vision');
    case PresentationTemplate.gastronomi:
      return tr('Yemek kültürü ve mutfak sanatları odaklı sıcak düzen', 'Warm layout for culinary arts and food culture');
    case PresentationTemplate.girisimcilik:
      return tr('Startup ve yenilikçi iş fikirleri için dinamik tasarım', 'Dynamic design for startups and pitch decks');
    case PresentationTemplate.havacilik:
      return tr('Havacılık ve uzay mühendisliği odaklı teknik görünüm', 'Technical look for aerospace and aviation');
    case PresentationTemplate.hukuk:
      return tr('Adalet ve hukuk sistemi odaklı resmi düzen', 'Formal layout for legal and justice systems');
    case PresentationTemplate.isHayati:
      return tr('Profesyonel iş dünyası ve yönetici sunumları', 'Professional business and executive presentations');
    case PresentationTemplate.kimya:
      return tr('Kimyasal reaksiyonlar ve laboratuvar odaklı tasarım', 'Lab and chemical reaction focused design');
    case PresentationTemplate.liderlik:
      return tr('Güçlü liderlik ve vizyoner yönetim temalı', 'Strong leadership and visionary management');
    case PresentationTemplate.matematik:
      return tr('Matematiksel düşünce ve geometri odaklı düzen', 'Mathematical thinking and geometry');
    case PresentationTemplate.meteoroloji:
      return tr('Hava durumu ve iklim bilimi odaklı dinamik sahne', 'Dynamic scene for weather and climate science');
    case PresentationTemplate.mitoloji:
      return tr('Antik mitler ve fantastik hikayeler odaklı epik düzen', 'Epic layout for ancient myths and stories');
    case PresentationTemplate.moda:
      return tr('Moda ve stil odaklı yaratıcı görsel düzen', 'Creative visual layout for fashion and style');
    case PresentationTemplate.muhendislik:
      return tr('Mühendislik ve teknik projeler için modern tasarım', 'Modern design for engineering and technical projects');
    case PresentationTemplate.muzik:
      return tr('Müzik ve ritim odaklı enerjik sunum', 'Energetic presentation for music and rhythm');
    case PresentationTemplate.oyun:
      return tr('Oyun ve eğlence odaklı renkli dinamik düzen', 'Colorful dynamic layout for gaming and entertainment');
    case PresentationTemplate.optik:
      return tr('Işık ve optik bilimi odaklı parlak görünüm', 'Bright look for optics and light science');
    case PresentationTemplate.pazarlama:
      return tr('Pazarlama stratejileri ve marka odaklı düzen', 'Marketing strategies and brand-focused layout');
    case PresentationTemplate.psikoloji:
      return tr('İnsan zihni ve davranış bilimi odaklı sakin düzen', 'Calm layout for psychology and behavioral science');
    case PresentationTemplate.robotik:
      return tr('Robot teknolojisi ve otomasyon odaklı futuristik sahne', 'Futuristic scene for robotics and automation');
    case PresentationTemplate.saglik:
      return tr('Sağlık hizmetleri ve tıbbi içerik için temiz tasarım', 'Clean design for healthcare and medical topics');
    case PresentationTemplate.sanat:
      return tr('Sanat ve yaratıcı ifade odaklı özgür düzen', 'Expressive layout for art and creativity');
    case PresentationTemplate.sehir:
      return tr('Kentsel yaşam ve şehir planlaması odaklı modern düzen', 'Modern layout for urban life and city planning');
    case PresentationTemplate.seyahat:
      return tr('Seyahat ve turizm odaklı keşif temalı sunum', 'Exploration-themed presentation for travel and tourism');
    case PresentationTemplate.sinema:
      return tr('Film ve sinema sanatı odaklı dramatik düzen', 'Dramatic layout for cinema and film arts');
    case PresentationTemplate.spor:
      return tr('Spor ve atletizm odaklı dinamik enerjik sunum', 'Dynamic energetic presentation for sports');
    case PresentationTemplate.tarih:
      return tr('Tarihsel olaylar ve medeniyetler odaklı klasik düzen', 'Classic layout for historical events and civilizations');
    case PresentationTemplate.tip:
      return tr('Tıp ve klinik bilimler odaklı güvenilir tasarım', 'Reliable design for medical and clinical sciences');
    case PresentationTemplate.tiyatro:
      return tr('Sahne sanatları ve dramatik anlatım odaklı düzen', 'Dramatic storytelling and stage arts');
    case PresentationTemplate.toplum:
      return tr('Sosyal bilimler ve toplumsal konular odaklı düzen', 'Layout for social sciences and community issues');
    case PresentationTemplate.ulasim:
      return tr('Ulaşım ve lojistik odaklı teknik endüstriyel görünüm', 'Industrial technical look for transit and logistics');
    case PresentationTemplate.uzay:
      return tr('Uzay keşfi ve astronot odaklı görkemli sunum', 'Grand presentation for space exploration');
    case PresentationTemplate.vintage:
      return tr('Geçmiş dönem estetiği ve retro odaklı sıcak düzen', 'Warm retro layout with vintage aesthetics');
    case PresentationTemplate.yapayZeka:
      return tr('Yapay zeka ve makine öğrenmesi odaklı teknoloji sahnesi', 'Tech scene for AI and machine learning');
    case PresentationTemplate.yazilim:
      return tr('Yazılım geliştirme ve programlama odaklı modern düzen', 'Modern layout for software development and coding');
    case PresentationTemplate.cyberpunk:
      return tr('Karanlık ve parlayan neon efektli siberpunk tasarım', 'Dark cyberpunk design with glowing neon accents');
    case PresentationTemplate.glassmorphism:
      return tr('Buzlu cam katmanlı, ultra modern şeffaf tasarım', 'Frosted glass layers with modern transparency');
    case PresentationTemplate.luxuryGold:
      return tr('Lüks obsidian ve şampanya altını zarafeti', 'Obsidian and champagne gold luxury elegance');
    case PresentationTemplate.ecoGreen:
      return tr('Doğa ve sürdürülebilirlik odaklı yeşil tema', 'Green theme for nature and sustainability');
    case PresentationTemplate.synthwave:
      return tr('80ler retro neon ve dalga estetiği', '80s retro neon and synthwave aesthetics');
    case PresentationTemplate.gradientMesh:
      return tr('Dinamik akan gradyan renk ağı düzeni', 'Dynamic flowing gradient mesh layout');
    case PresentationTemplate.editorial:
      return tr('Dergi ve tipografi odaklı prestijli tasarım', 'Prestigious editorial design with rich typography');
    case PresentationTemplate.bauhaus:
      return tr('Geometrik yapı ve cesur renk kontrasti düzeni', 'Geometric structure and bold color contrast');
    case PresentationTemplate.dataTech:
      return tr('Finansal veri ve teknoloji analitiği odağı', 'Financial data and tech analytics focus');
    case PresentationTemplate.deepSpace:
      return tr('Derin uzay, kozmik ve kuantum temalı sahne', 'Deep space, cosmic and quantum theme');
    case PresentationTemplate.bentoGrid:
      return tr('Bento box düzeninde modern modüler kart tasarımları', 'Modern modular card designs in bento box layout');
    case PresentationTemplate.auroraBorealis:
      return tr('Kuzey ışıkları temalı ışıltılı canlı renk ağları', 'Vibrant glowing aurora borealis color mesh');
    case PresentationTemplate.neomorphism:
      return tr('Yumuşak kabartmalı 3D neomorfik arayüz stili', 'Soft embossed 3D neumorphic interface style');
    case PresentationTemplate.holographic:
      return tr('Siber renk geçişleri ve holografik ışıltılar', 'Cyber color transitions and holographic glows');
    case PresentationTemplate.nordicMinimal:
      return tr('Yüksek kontrastlı, sade ve mimari tipografi', 'High-contrast, clean and architectural typography');
    case PresentationTemplate.claymorphism:
      return tr('3D kil ve pastel tonlarında dost canlısı kabartmalar', 'Friendly embossed 3D clay and pastel tones');
  }
}

class PresentationAutoBuilder {
  const PresentationAutoBuilder();

  List<PresentationPage> buildPages(
    List<PresentationDraftPage> drafts, {
    PresentationTemplate template = PresentationTemplate.automatic,
    bool enforceTopicVisualPolicy = true,
  }) {
    var pageCounter = 1;
    var textCounter = 1;
    var componentCounter = 1;
    final pages = <PresentationPage>[];
    final config = templateConfig(template);

    // Uzun AI yanıtlarını tek bir kutuya koymak yerine okunabilir parçalara
    // ayırıyoruz. Böylece hem düzen korunur hem de export/önizlemede taşma
    // ihtimali ciddi biçimde azalır.
    for (final draft in _splitLongDrafts(drafts, template: template)) {
      final title = draft.title.trim();
      final body = draft.body.trim();
      if (title.isEmpty && body.isEmpty) {
        continue;
      }

      final match = _bestMatch(title: title, body: body, template: template);
      final titleOnly = title.isNotEmpty && body.isEmpty;
      final longBody = body.length >= 170;
      final templateComponentKinds = config.componentKinds;
      final componentKinds = !enforceTopicVisualPolicy &&
              templateComponentKinds.isNotEmpty
          ? templateComponentKinds
          : _bestComponentKinds(
              title: title,
              body: body,
              maxComponents: template == PresentationTemplate.minimal ? 0 : 1,
            );
      final hasComponents = componentKinds.isNotEmpty;
      final textBlocks = <PresentationTextBlock>[];
      final bodyTop = title.isEmpty ? 0.18 : _bodyTop(title);
      final titleTop = titleOnly ? 0.16 : 0.10;

      if (title.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: title,
            position: Offset(0.08, titleTop),
            fontSize:
                (_titleFontSize(title, titleOnly: titleOnly) * config.fontScale)
                    .roundToDouble(),
            type: PresentationTextType.title,
            textStyle: config.titleTextStyle,
            textAnimation: config.titleTextAnimation,
            textColorHex: config.titleTextColor,
            glowIntensity: config.glowIntensity,
            widthFactor: template == PresentationTemplate.minimal
                ? 0.84
                : hasComponents
                    ? titleOnly
                        ? 0.56
                        : 0.58
                    : titleOnly
                        ? 0.78
                        : 0.76,
            heightFactor: titleOnly
                ? 0.5
                : (bodyTop - titleTop - 0.035).clamp(0.16, 0.32).toDouble(),
          ),
        );
      }

      if (body.isNotEmpty) {
        textBlocks.add(
          PresentationTextBlock(
            id: 'text-${textCounter++}',
            text: body,
            position: Offset(0.08, bodyTop),
            fontSize: (_bodyFontSize(body, hasComponents: hasComponents) *
                    config.fontScale)
                .roundToDouble(),
            type: PresentationTextType.body,
            textStyle: config.bodyTextStyle,
            textAnimation: config.bodyTextAnimation,
            textColorHex: config.bodyTextColor,
            glowIntensity: config.glowIntensity,
            widthFactor: hasComponents
                ? 0.58
                : longBody
                    ? 0.78
                    : 0.76,
            heightFactor: 0.91 - bodyTop,
          ),
        );
      }

      final componentBlocks = <PresentationComponentBlock>[];
      for (var i = 0; i < componentKinds.length; i += 1) {
        componentBlocks.add(
          PresentationComponentBlock(
            id: 'component-${componentCounter++}',
            kind: componentKinds[i],
            position: _componentPosition(i, titleOnly: titleOnly),
            size: _componentSize(i, single: componentKinds.length == 1),
          ),
        );
      }

      pages.add(
        PresentationPage(
          id: 'page-${pageCounter++}',
          backgroundKind: config.backgroundKind ?? match.backgroundKind,
          textBlocks: textBlocks,
          componentBlocks: componentBlocks,
        ),
      );
    }

    return pages;
  }

  _AutoTheme _bestMatch({
    required String title,
    required String body,
    required PresentationTemplate template,
  }) {
    final templateBackground = presentationTemplateBackground(template);
    if (templateBackground != null) {
      return _AutoTheme(
        backgroundKind: templateBackground,
        keywords: const <_AutoKeyword>[],
      );
    }
    final normalizedTitle = _normalize(title);
    final normalizedBody = _normalize(body);
    final normalizedText = '$normalizedTitle $normalizedBody';
    var best = _fallbackTheme;
    var bestScore = 0;

    for (final theme in _autoThemes) {
      var score = 0;
      for (final keyword in theme.keywords) {
        final normalizedKeyword = _normalize(keyword.value);
        if (PresentationKeywordCatalog.textMatchesKeyword(
          normalizedTitle,
          normalizedKeyword,
        )) {
          score += keyword.weight + 2;
        } else if (PresentationKeywordCatalog.textMatchesKeyword(
          normalizedBody,
          normalizedKeyword,
        )) {
          score += keyword.weight;
        } else if (PresentationKeywordCatalog.textMatchesKeyword(
          normalizedText,
          normalizedKeyword,
        )) {
          score += keyword.weight;
        }
      }

      if (score > bestScore) {
        best = theme;
        bestScore = score;
      }
    }

    return best;
  }

  List<PresentationDraftPage> _splitLongDrafts(
    List<PresentationDraftPage> drafts, {
    required PresentationTemplate template,
  }) {
    final maxCharacters = template == PresentationTemplate.minimal ? 420 : 280;
    final result = <PresentationDraftPage>[];
    for (final draft in drafts) {
      final body = draft.body.trim();
      if (body.length <= maxCharacters) {
        result.add(draft);
        continue;
      }
      final chunks = _splitText(body, maxCharacters);
      for (var index = 0; index < chunks.length; index += 1) {
        result.add(
          PresentationDraftPage(
            title: index == 0 ? draft.title : '${draft.title} (devam)',
            body: chunks[index],
          ),
        );
      }
    }
    return result;
  }

  List<PresentationComponentKind> _bestComponentKinds({
    required String title,
    required String body,
    required int maxComponents,
    String? allowedCategory,
  }) {
    if (maxComponents <= 0) {
      return const <PresentationComponentKind>[];
    }

    final normalizedTitle = _normalize(title);
    final normalizedBody = _normalize(body);
    final candidates = <_AutoComponentCandidate>[];

    for (final definition in presentationComponentDefinitions) {
      if (allowedCategory != null &&
          PresentationKeywordCatalog.normalize(definition.category) !=
              PresentationKeywordCatalog.normalize(allowedCategory)) {
        continue;
      }
      final score = _componentScore(
        definition,
        normalizedTitle: normalizedTitle,
        normalizedBody: normalizedBody,
      );
      if (score >= _minimumComponentScore) {
        candidates.add(_AutoComponentCandidate(definition, score));
      }
    }

    candidates.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      if (scoreOrder != 0) {
        return scoreOrder;
      }
      return a.definition.label.compareTo(b.definition.label);
    });

    final selected = <PresentationComponentKind>[];
    for (final candidate in candidates) {
      if (selected.length >= maxComponents) {
        break;
      }
      if (selected.contains(candidate.definition.kind)) {
        continue;
      }
      selected.add(candidate.definition.kind);
    }

    return selected;
  }

  int _componentScore(
    PresentationComponentDefinition definition, {
    required String normalizedTitle,
    required String normalizedBody,
  }) {
    var score = 0;

    for (final tag in definition.tags) {
      final normalizedTag = _normalize(tag);
      final isAmbiguous = _ambiguousComponentTags.contains(normalizedTag) ||
          (_componentTagCategoryCounts[normalizedTag] ?? 0) > 1;
      score += _scoreKeyword(
        tag,
        normalizedTitle: normalizedTitle,
        normalizedBody: normalizedBody,
        titleExactScore: isAmbiguous ? 6 : 20,
        bodyExactScore: isAmbiguous ? 4 : 14,
        titlePartialScore: isAmbiguous ? 0 : 5,
        bodyPartialScore: isAmbiguous ? 0 : 3,
        titlePartialCap: isAmbiguous ? 0 : 12,
        bodyPartialCap: isAmbiguous ? 0 : 9,
      );
    }

    score += _scoreKeyword(
      definition.label,
      normalizedTitle: normalizedTitle,
      normalizedBody: normalizedBody,
      titleExactScore: 18,
      bodyExactScore: 12,
      titlePartialScore: 6,
      bodyPartialScore: 4,
      titlePartialCap: 12,
      bodyPartialCap: 8,
    );
    score += _scoreKeyword(
      definition.category,
      normalizedTitle: normalizedTitle,
      normalizedBody: normalizedBody,
      titleExactScore: 4,
      bodyExactScore: 3,
      titlePartialScore: 0,
      bodyPartialScore: 0,
      titlePartialCap: 0,
      bodyPartialCap: 0,
    );
    score += _scoreKeyword(
      definition.description,
      normalizedTitle: normalizedTitle,
      normalizedBody: normalizedBody,
      titleExactScore: 4,
      bodyExactScore: 3,
      titlePartialScore: 1,
      bodyPartialScore: 1,
      titlePartialCap: 3,
      bodyPartialCap: 3,
    );

    return score;
  }

  int _scoreKeyword(
    String value, {
    required String normalizedTitle,
    required String normalizedBody,
    required int titleExactScore,
    required int bodyExactScore,
    required int titlePartialScore,
    required int bodyPartialScore,
    required int titlePartialCap,
    required int bodyPartialCap,
  }) {
    final normalizedKeyword = _normalize(value);
    if (normalizedKeyword.isEmpty) {
      return 0;
    }

    return _scoreTextAgainstKeyword(
          normalizedTitle,
          normalizedKeyword,
          exactScore: titleExactScore,
          partialScore: titlePartialScore,
          partialCap: titlePartialCap,
        ) +
        _scoreTextAgainstKeyword(
          normalizedBody,
          normalizedKeyword,
          exactScore: bodyExactScore,
          partialScore: bodyPartialScore,
          partialCap: bodyPartialCap,
        );
  }

  int _scoreTextAgainstKeyword(
    String normalizedText,
    String normalizedKeyword, {
    required int exactScore,
    required int partialScore,
    required int partialCap,
  }) {
    if (normalizedText.isEmpty || normalizedKeyword.isEmpty) {
      return 0;
    }
    if (PresentationKeywordCatalog.textMatchesKeyword(
      normalizedText,
      normalizedKeyword,
    )) {
      return exactScore;
    }

    return _partialWordScore(
      normalizedText,
      normalizedKeyword,
      perWordScore: partialScore,
      cap: partialCap,
    );
  }
}

/// Returns one catalog component only when the slide text has a meaningful
/// topic match. Automatic presentation generation uses this after the 3D model
/// lookup fails; a null result intentionally leaves the slide text-only.
PresentationComponentKind? bestPresentationComponentForSlide({
  required String title,
  required String body,
  String? allowedCategory,
}) {
  final matches = const PresentationAutoBuilder()._bestComponentKinds(
    title: title,
    body: body,
    maxComponents: 1,
    allowedCategory: allowedCategory,
  );
  return matches.isEmpty ? null : matches.single;
}

final Map<PresentationTemplate, PresentationPage> _templatePreviewPageCache =
    <PresentationTemplate, PresentationPage>{};

PresentationPage presentationTemplatePreviewPage(
  PresentationTemplate template,
) {
  assert(template != PresentationTemplate.automatic);
  return _templatePreviewPageCache.putIfAbsent(template, () {
    final pages = const PresentationAutoBuilder().buildPages(
      <PresentationDraftPage>[
        PresentationDraftPage(
          title: 'Yeni Bir Bakış',
          body: 'Fikirleri güçlü ve anlaşılır bir hikâyeye dönüştürün.',
        ),
      ],
      template: template,
      enforceTopicVisualPolicy: false,
    );
    return pages.single.copyWith(id: 'template-preview-${template.name}');
  });
}

int _partialWordScore(
  String normalizedText,
  String normalizedKeyword, {
  required int perWordScore,
  required int cap,
}) {
  final inputWords = PresentationKeywordCatalog.words(normalizedText)
      .where(_isImportantComponentWord)
      .toList(growable: false);
  if (inputWords.isEmpty) {
    return 0;
  }

  final keywordWords = PresentationKeywordCatalog.words(normalizedKeyword)
      .where(_isImportantComponentWord)
      .toSet();
  var matches = 0;
  for (final keywordWord in keywordWords) {
    if (inputWords.any(
      (inputWord) => PresentationKeywordCatalog.wordsMatch(
        inputWord,
        keywordWord,
      ),
    )) {
      matches += 1;
    }
  }

  final score = matches * perWordScore;
  return score > cap ? cap : score;
}

bool _isImportantComponentWord(String word) {
  return word.length >= 3 && !_ignoredComponentWords.contains(word);
}

Offset _componentPosition(int index, {required bool titleOnly}) {
  if (titleOnly) {
    return const Offset(0.68, 0.30);
  }
  return index == 0 ? const Offset(0.70, 0.16) : const Offset(0.70, 0.52);
}

Size _componentSize(int index, {required bool single}) {
  if (single) {
    return const Size(0.24, 0.28);
  }
  return const Size(0.22, 0.24);
}

double _titleFontSize(String title, {required bool titleOnly}) {
  final length = title.replaceAll(RegExp(r'\s+'), ' ').trim().length;
  final base = titleOnly ? 64.0 : 54.0;
  if (length <= 36) return base;
  if (length <= 64) return base - 8;
  if (length <= 92) return base - 16;
  return base - 22;
}

double _bodyFontSize(String body, {required bool hasComponents}) {
  final length = body.length;
  if (length >= 250) return hasComponents ? 27 : 30;
  if (length >= 170) return hasComponents ? 29 : 31;
  return hasComponents ? 32 : 34;
}

double _bodyTop(String title) {
  final length = title.replaceAll(RegExp(r'\s+'), ' ').trim().length;
  if (length <= 40) return 0.32;
  if (length <= 72) return 0.39;
  return 0.46;
}

PresentationBackgroundKind? presentationTemplateBackground(
  PresentationTemplate template,
) {
  switch (template) {
    case PresentationTemplate.automatic:
      return null;
    case PresentationTemplate.academic:
      return PresentationBackgroundKind.lightEducation;
    case PresentationTemplate.corporate:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.creative:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.minimal:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.darkCorporate:
      return PresentationBackgroundKind.businessFinance;
    case PresentationTemplate.techStartup:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.scientific:
      return PresentationBackgroundKind.science;
    case PresentationTemplate.elegant:
      return PresentationBackgroundKind.lightNature;
    case PresentationTemplate.bold:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.pastel:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.highContrast:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.astronomi:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.beslenme:
      return PresentationBackgroundKind.lightNature;
    case PresentationTemplate.biyoloji:
      return PresentationBackgroundKind.biology;
    case PresentationTemplate.cevre:
      return PresentationBackgroundKind.natureEcology;
    case PresentationTemplate.cografya:
      return PresentationBackgroundKind.travelGeography;
    case PresentationTemplate.deniz:
      return PresentationBackgroundKind.travelGeography;
    case PresentationTemplate.dijital:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.doga:
      return PresentationBackgroundKind.natureEcology;
    case PresentationTemplate.edebiyat:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.egitim:
      return PresentationBackgroundKind.lightEducation;
    case PresentationTemplate.ekoloji:
      return PresentationBackgroundKind.natureEcology;
    case PresentationTemplate.enerji:
      return PresentationBackgroundKind.solarEnergyScene;
    case PresentationTemplate.evcilHayvan:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.felsefe:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.fizik:
      return PresentationBackgroundKind.physics;
    case PresentationTemplate.fotograf:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.futuristik:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.gastronomi:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.girisimcilik:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.havacilik:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.hukuk:
      return PresentationBackgroundKind.lawJustice;
    case PresentationTemplate.isHayati:
      return PresentationBackgroundKind.businessFinance;
    case PresentationTemplate.kimya:
      return PresentationBackgroundKind.chemistry;
    case PresentationTemplate.liderlik:
      return PresentationBackgroundKind.businessFinance;
    case PresentationTemplate.matematik:
      return PresentationBackgroundKind.mathematics;
    case PresentationTemplate.meteoroloji:
      return PresentationBackgroundKind.climateWeather;
    case PresentationTemplate.mitoloji:
      return PresentationBackgroundKind.historyArchaeology;
    case PresentationTemplate.moda:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.muhendislik:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.muzik:
      return PresentationBackgroundKind.musicSound;
    case PresentationTemplate.oyun:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.optik:
      return PresentationBackgroundKind.optics;
    case PresentationTemplate.pazarlama:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.psikoloji:
      return PresentationBackgroundKind.healthMedicine;
    case PresentationTemplate.robotik:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.saglik:
      return PresentationBackgroundKind.healthMedicine;
    case PresentationTemplate.sanat:
      return PresentationBackgroundKind.artDesign;
    case PresentationTemplate.sehir:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.seyahat:
      return PresentationBackgroundKind.travelGeography;
    case PresentationTemplate.sinema:
      return PresentationBackgroundKind.artDesign;
    case PresentationTemplate.spor:
      return PresentationBackgroundKind.sportsMovement;
    case PresentationTemplate.tarih:
      return PresentationBackgroundKind.historyArchaeology;
    case PresentationTemplate.tip:
      return PresentationBackgroundKind.healthMedicine;
    case PresentationTemplate.tiyatro:
      return PresentationBackgroundKind.artDesign;
    case PresentationTemplate.toplum:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.ulasim:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.uzay:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.vintage:
      return PresentationBackgroundKind.historyArchaeology;
    case PresentationTemplate.yapayZeka:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.yazilim:
      return PresentationBackgroundKind.lightTechnology;
    case PresentationTemplate.cyberpunk:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.glassmorphism:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.luxuryGold:
      return PresentationBackgroundKind.historyArchaeology;
    case PresentationTemplate.ecoGreen:
      return PresentationBackgroundKind.natureEcology;
    case PresentationTemplate.synthwave:
      return PresentationBackgroundKind.lightCreative;
    case PresentationTemplate.gradientMesh:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.editorial:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.bauhaus:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.dataTech:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.deepSpace:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.bentoGrid:
      return PresentationBackgroundKind.lightCorporate;
    case PresentationTemplate.auroraBorealis:
      return PresentationBackgroundKind.technology;
    case PresentationTemplate.neomorphism:
      return PresentationBackgroundKind.lightWarm;
    case PresentationTemplate.holographic:
      return PresentationBackgroundKind.spaceTechnology;
    case PresentationTemplate.nordicMinimal:
      return PresentationBackgroundKind.lightEducation;
    case PresentationTemplate.claymorphism:
      return PresentationBackgroundKind.lightCreative;
  }
}

/// Comprehensive template configuration that defines all visual aspects
/// of a template including background, text styles, animations, transitions, etc.
@immutable
class PresentationTemplateConfig {
  const PresentationTemplateConfig({
    required this.backgroundKind,
    required this.titleTextStyle,
    required this.bodyTextStyle,
    required this.titleTextAnimation,
    required this.bodyTextAnimation,
    required this.titleTextColor,
    required this.bodyTextColor,
    required this.transitionKind,
    required this.transitionDurationMs,
    required this.componentKinds,
    required this.glowIntensity,
    required this.fontScale,
  });

  final PresentationBackgroundKind? backgroundKind;
  final PresentationTextStyle titleTextStyle;
  final PresentationTextStyle bodyTextStyle;
  final PresentationTextAnimation titleTextAnimation;
  final PresentationTextAnimation bodyTextAnimation;
  final String? titleTextColor;
  final String? bodyTextColor;
  final PresentationTransitionKind transitionKind;
  final int transitionDurationMs;
  final List<PresentationComponentKind> componentKinds;
  final double glowIntensity;
  final double fontScale;
}

PresentationTemplateConfig templateConfig(PresentationTemplate template) {
  switch (template) {
    case PresentationTemplate.automatic:
      return const PresentationTemplateConfig(
        backgroundKind: null,
        titleTextStyle: PresentationTextStyle.standard,
        bodyTextStyle: PresentationTextStyle.standard,
        titleTextAnimation: PresentationTextAnimation.none,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: null,
        bodyTextColor: null,
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 600,
        componentKinds: [],
        glowIntensity: 1.0,
        fontScale: 1.0,
      );
    case PresentationTemplate.academic:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightEducation,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#1A237E',
        bodyTextColor: '#283593',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.egitim01,
          PresentationComponentKind.egitim02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.corporate:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#0D47A1',
        bodyTextColor: '#1565C0',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.genelSunumIs01,
          PresentationComponentKind.genelSunumIs02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.05,
      );
    case PresentationTemplate.creative:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        titleTextColor: '#7B1FA2',
        bodyTextColor: '#8E24AA',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.sanat01,
          PresentationComponentKind.sanat02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.1,
      );
    case PresentationTemplate.minimal:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.none,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#3E2723',
        bodyTextColor: '#5D4037',
        transitionKind: PresentationTransitionKind.none,
        transitionDurationMs: 300,
        componentKinds: [],
        glowIntensity: 0.0,
        fontScale: 1.0,
      );
    case PresentationTemplate.darkCorporate:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.businessFinance,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.metalikParlama,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#FFFFFF',
        bodyTextColor: '#B0BEC5',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.ekonomiIsFinans01,
          PresentationComponentKind.ekonomiIsFinans02,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.techStartup:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDeneysel,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.holografikDalga,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#4DD0E1',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji01,
          PresentationComponentKind.teknoloji02,
        ],
        glowIntensity: 1.0,
        fontScale: 1.05,
      );
    case PresentationTemplate.scientific:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.science,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.fizikDramatik,
        titleTextColor: '#54D6FF',
        bodyTextColor: '#81D4FA',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.fizik01,
          PresentationComponentKind.kimya01,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.elegant:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightNature,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.siviDalga,
        bodyTextAnimation: PresentationTextAnimation.yercekimsizSuzulme,
        titleTextColor: '#2E7D32',
        bodyTextColor: '#43A047',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 1000,
        componentKinds: [
          PresentationComponentKind.cevreDoga01,
          PresentationComponentKind.cevreDoga02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.05,
      );
    case PresentationTemplate.bold:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openUnbounded,
        titleTextAnimation: PresentationTextAnimation.isikTaramasi,
        bodyTextAnimation: PresentationTextAnimation.neonKontur,
        titleTextColor: '#FFD600',
        bodyTextColor: '#FFEB3B',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 400,
        componentKinds: [
          PresentationComponentKind.teknoloji03,
          PresentationComponentKind.teknoloji04,
        ],
        glowIntensity: 1.5,
        fontScale: 1.15,
      );
    case PresentationTemplate.pastel:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.gunesTemiz,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#E91E63',
        bodyTextColor: '#F06292',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.moda01,
          PresentationComponentKind.moda02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.highContrast:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.daktilo,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#000000',
        bodyTextColor: '#212121',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 300,
        componentKinds: [
          PresentationComponentKind.genelSunumIs03,
          PresentationComponentKind.genelSunumIs04,
        ],
        glowIntensity: 0.0,
        fontScale: 1.1,
      );
    case PresentationTemplate.astronomi:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.uzayDramatik,
        bodyTextStyle: PresentationTextStyle.uzayTemiz,
        titleTextAnimation: PresentationTextAnimation.uzayDramatik,
        bodyTextAnimation: PresentationTextAnimation.uzayDeneysel,
        titleTextColor: '#6C63FF',
        bodyTextColor: '#9D8FFF',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.astronomi01,
          PresentationComponentKind.astronomi02,
        ],
        glowIntensity: 0.7,
        fontScale: 1.0,
      );
    case PresentationTemplate.beslenme:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightNature,
        titleTextStyle: PresentationTextStyle.gunesTemiz,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2E7D32',
        bodyTextColor: '#4CAF50',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.tarimGida01,
          PresentationComponentKind.tarimGida02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.biyoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.biology,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#06D6A0',
        bodyTextColor: '#00B894',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.biyoloji01,
          PresentationComponentKind.biyoloji02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.cevre:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.natureEcology,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimTemiz,
        bodyTextAnimation: PresentationTextAnimation.gunesTemiz,
        titleTextColor: '#74C69D',
        bodyTextColor: '#52B788',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.cevreDoga01,
          PresentationComponentKind.cevreDoga02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.cografya:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.travelGeography,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#4CC9F0',
        bodyTextColor: '#00B4D8',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.cografya01,
          PresentationComponentKind.cografya02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.deniz:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.travelGeography,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.siviDalga,
        bodyTextAnimation: PresentationTextAnimation.yercekimsizSuzulme,
        titleTextColor: '#0077B6',
        bodyTextColor: '#0096C7',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.turizmSeyahat01,
          PresentationComponentKind.turizmSeyahat02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.dijital:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDeneysel,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#22A6B3',
        bodyTextColor: '#38B2AC',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji01,
          PresentationComponentKind.teknoloji02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.05,
      );
    case PresentationTemplate.doga:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.natureEcology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2D6A4F',
        bodyTextColor: '#40916C',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.cevreDoga03,
          PresentationComponentKind.cevreDoga04,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.edebiyat:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#6B4226',
        bodyTextColor: '#8D6E63',
        transitionKind: PresentationTransitionKind.none,
        transitionDurationMs: 400,
        componentKinds: [
          PresentationComponentKind.edebiyat01,
          PresentationComponentKind.edebiyat02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.05,
      );
    case PresentationTemplate.egitim:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightEducation,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#1A237E',
        bodyTextColor: '#283593',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.egitim01,
          PresentationComponentKind.egitim02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.ekoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.natureEcology,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.bilimTemiz,
        titleTextColor: '#1B4332',
        bodyTextColor: '#2D6A4F',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.cevreDoga05,
          PresentationComponentKind.cevreDoga06,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.enerji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.solarEnergyScene,
        titleTextStyle: PresentationTextStyle.gunesDramatik,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesDramatik,
        bodyTextAnimation: PresentationTextAnimation.gunesDeneysel,
        titleTextColor: '#FFD166',
        bodyTextColor: '#FFB703',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.enerjiAltyapisi01,
          PresentationComponentKind.enerjiAltyapisi02,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.evcilHayvan:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openCaveat,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#E07A5F',
        bodyTextColor: '#F4A261',
        transitionKind: PresentationTransitionKind.none,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.evcilHayvanlar01,
          PresentationComponentKind.evcilHayvanlar02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.0,
      );
    case PresentationTemplate.felsefe:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#3D405B',
        bodyTextColor: '#5C5E7D',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.felsefeDin01,
          PresentationComponentKind.felsefeDin02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.fizik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.physics,
        titleTextStyle: PresentationTextStyle.fizikDramatik,
        bodyTextStyle: PresentationTextStyle.fizikTemiz,
        titleTextAnimation: PresentationTextAnimation.fizikDramatik,
        bodyTextAnimation: PresentationTextAnimation.fizikDeneysel,
        titleTextColor: '#7C90B0',
        bodyTextColor: '#A0B4D0',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.fizik01,
          PresentationComponentKind.fizik02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.fotograf:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#B15CDE',
        bodyTextColor: '#C77DFF',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.fotografcilik01,
          PresentationComponentKind.fotografcilik02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.05,
      );
    case PresentationTemplate.futuristik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiDeneysel,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#00B4D8',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.teknoloji03,
          PresentationComponentKind.teknoloji04,
        ],
        glowIntensity: 1.2,
        fontScale: 1.1,
      );
    case PresentationTemplate.gastronomi:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.siviDalga,
        titleTextColor: '#D62828',
        bodyTextColor: '#E76F51',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.gastronomi01,
          PresentationComponentKind.gastronomi02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.05,
      );
    case PresentationTemplate.girisimcilik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#0D47A1',
        bodyTextColor: '#1565C0',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.genelSunumIs01,
          PresentationComponentKind.genelSunumIs02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.1,
      );
    case PresentationTemplate.havacilik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#6C63FF',
        bodyTextColor: '#8B83FF',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.havacilik01,
          PresentationComponentKind.havacilik02,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.hukuk:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lawJustice,
        titleTextStyle: PresentationTextStyle.standard,
        bodyTextStyle: PresentationTextStyle.standard,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#D4AF37',
        bodyTextColor: '#C5A035',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.hukuk01,
          PresentationComponentKind.hukuk02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.isHayati:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.businessFinance,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.metalikParlama,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#FFFFFF',
        bodyTextColor: '#B0BEC5',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.ekonomiIsFinans01,
          PresentationComponentKind.ekonomiIsFinans02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.kimya:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.chemistry,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDeneysel,
        bodyTextAnimation: PresentationTextAnimation.bilimTemiz,
        titleTextColor: '#62D2A2',
        bodyTextColor: '#4ECB71',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.kimya01,
          PresentationComponentKind.kimya02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.liderlik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.businessFinance,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.metalikParlama,
        bodyTextAnimation: PresentationTextAnimation.perdeAcilisi,
        titleTextColor: '#FFD600',
        bodyTextColor: '#FFC107',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.genelSunumIs03,
          PresentationComponentKind.genelSunumIs04,
        ],
        glowIntensity: 0.7,
        fontScale: 1.1,
      );
    case PresentationTemplate.matematik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.mathematics,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.bilimTemiz,
        titleTextColor: '#9B5DE5',
        bodyTextColor: '#B47CFF',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.matematik01,
          PresentationComponentKind.matematik02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.meteoroloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.climateWeather,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesDramatik,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#6DD5FA',
        bodyTextColor: '#4CC9F0',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.meteoroloji01,
          PresentationComponentKind.meteoroloji02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.mitoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.historyArchaeology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#D4A373',
        bodyTextColor: '#C18F5B',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.mitolojiFantastik01,
          PresentationComponentKind.mitolojiFantastik02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.moda:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openUnbounded,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.neonKontur,
        titleTextColor: '#FF70A6',
        bodyTextColor: '#FF85B3',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.moda01,
          PresentationComponentKind.moda02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.1,
      );
    case PresentationTemplate.muhendislik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#4DD0E1',
        transitionKind: PresentationTransitionKind.wipe,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.muhendislik01,
          PresentationComponentKind.muhendislik02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.muzik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.musicSound,
        titleTextStyle: PresentationTextStyle.openUnbounded,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.siviDalga,
        bodyTextAnimation: PresentationTextAnimation.kesikSinyal,
        titleTextColor: '#F15BB5',
        bodyTextColor: '#F72585',
        transitionKind: PresentationTransitionKind.concave,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.muzik01,
          PresentationComponentKind.muzik02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.oyun:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openUnbounded,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.ucBoyutluDonus,
        titleTextColor: '#FF595E',
        bodyTextColor: '#FF6B6B',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.oyun01,
          PresentationComponentKind.oyun02,
        ],
        glowIntensity: 0.6,
        fontScale: 1.1,
      );
    case PresentationTemplate.optik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.optics,
        titleTextStyle: PresentationTextStyle.optikDramatik,
        bodyTextStyle: PresentationTextStyle.optikTemiz,
        titleTextAnimation: PresentationTextAnimation.optikDramatik,
        bodyTextAnimation: PresentationTextAnimation.optikDeneysel,
        titleTextColor: '#7EFFF5',
        bodyTextColor: '#5EEAD4',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.fizik03,
          PresentationComponentKind.fizik04,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.pazarlama:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#E91E63',
        bodyTextColor: '#F06292',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.ekonomiIsFinans03,
          PresentationComponentKind.ekonomiIsFinans04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.05,
      );
    case PresentationTemplate.psikoloji:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.healthMedicine,
        titleTextStyle: PresentationTextStyle.gunesTemiz,
        bodyTextStyle: PresentationTextStyle.gunesTemiz,
        titleTextAnimation: PresentationTextAnimation.gunesDeneysel,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2EC4B6',
        bodyTextColor: '#3DD6C8',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.psikoloji01,
          PresentationComponentKind.psikoloji02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.robotik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiDeneysel,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.kesikSinyal,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#00BCD4',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.muhendislik03,
          PresentationComponentKind.muhendislik04,
        ],
        glowIntensity: 0.8,
        fontScale: 1.05,
      );
    case PresentationTemplate.saglik:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.healthMedicine,
        titleTextStyle: PresentationTextStyle.bilimTemiz,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#2EC4B6',
        bodyTextColor: '#4DD0C8',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.saglik01,
          PresentationComponentKind.saglik02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.sanat:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.artDesign,
        titleTextStyle: PresentationTextStyle.openBungee,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.gunesDramatik,
        bodyTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        titleTextColor: '#FF70A6',
        bodyTextColor: '#FF8EB8',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.sanat01,
          PresentationComponentKind.sanat02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.05,
      );
    case PresentationTemplate.sehir:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#22A6B3',
        bodyTextColor: '#38B2AC',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.sehirKentsel01,
          PresentationComponentKind.sehirKentsel02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.seyahat:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.travelGeography,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.gunesTemiz,
        bodyTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        titleTextColor: '#4CC9F0',
        bodyTextColor: '#00B4D8',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.turizmSeyahat03,
          PresentationComponentKind.turizmSeyahat04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.sinema:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.artDesign,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.perdeAcilisi,
        titleTextColor: '#FFD600',
        bodyTextColor: '#FFC107',
        transitionKind: PresentationTransitionKind.cover,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.sinemaFilm01,
          PresentationComponentKind.sinemaFilm02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.spor:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.sportsMovement,
        titleTextStyle: PresentationTextStyle.openBebasNeue,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.ucBoyutluDonus,
        bodyTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        titleTextColor: '#FF595E',
        bodyTextColor: '#FF6B6B',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.spor01,
          PresentationComponentKind.spor02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.05,
      );
    case PresentationTemplate.tarih:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.historyArchaeology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openPlayfairDisplay,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#D4A373',
        bodyTextColor: '#C18F5B',
        transitionKind: PresentationTransitionKind.reveal,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.tarih01,
          PresentationComponentKind.tarih02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.tip:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.healthMedicine,
        titleTextStyle: PresentationTextStyle.bilimDramatik,
        bodyTextStyle: PresentationTextStyle.bilimTemiz,
        titleTextAnimation: PresentationTextAnimation.bilimDramatik,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#2EC4B6',
        bodyTextColor: '#48C9B0',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.saglik03,
          PresentationComponentKind.saglik04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.tiyatro:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.artDesign,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        titleTextColor: '#E91E63',
        bodyTextColor: '#F06292',
        transitionKind: PresentationTransitionKind.cover,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.sinemaFilm03,
          PresentationComponentKind.sinemaFilm04,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.toplum:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.openOswald,
        bodyTextStyle: PresentationTextStyle.openOswald,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.daktilo,
        titleTextColor: '#5D4037',
        bodyTextColor: '#795548',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.toplum01,
          PresentationComponentKind.toplum02,
        ],
        glowIntensity: 0.2,
        fontScale: 1.0,
      );
    case PresentationTemplate.ulasim:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiTemiz,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#1565C0',
        bodyTextColor: '#1976D2',
        transitionKind: PresentationTransitionKind.slide,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.ulasimLojistik01,
          PresentationComponentKind.ulasimLojistik02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.uzay:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.uzayDramatik,
        bodyTextStyle: PresentationTextStyle.uzayTemiz,
        titleTextAnimation: PresentationTextAnimation.uzayDramatik,
        bodyTextAnimation: PresentationTextAnimation.uzayDeneysel,
        titleTextColor: '#6C63FF',
        bodyTextColor: '#8580FF',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.astronomi03,
          PresentationComponentKind.astronomi04,
        ],
        glowIntensity: 0.8,
        fontScale: 1.0,
      );
    case PresentationTemplate.vintage:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.historyArchaeology,
        titleTextStyle: PresentationTextStyle.openPlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.openCaveat,
        titleTextAnimation: PresentationTextAnimation.daktilo,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#8B7355',
        bodyTextColor: '#A08860',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 900,
        componentKinds: [
          PresentationComponentKind.tarih03,
          PresentationComponentKind.tarih04,
        ],
        glowIntensity: 0.3,
        fontScale: 1.0,
      );
    case PresentationTemplate.yapayZeka:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.teknolojiDramatik,
        bodyTextStyle: PresentationTextStyle.teknolojiDeneysel,
        titleTextAnimation: PresentationTextAnimation.teknolojiDramatik,
        bodyTextAnimation: PresentationTextAnimation.holografikDalga,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#4DD0E1',
        transitionKind: PresentationTransitionKind.zoom,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.teknoloji05,
          PresentationComponentKind.teknoloji06,
        ],
        glowIntensity: 1.0,
        fontScale: 1.05,
      );
    case PresentationTemplate.yazilim:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightTechnology,
        titleTextStyle: PresentationTextStyle.teknolojiDeneysel,
        bodyTextStyle: PresentationTextStyle.teknolojiTemiz,
        titleTextAnimation: PresentationTextAnimation.teknolojiDeneysel,
        bodyTextAnimation: PresentationTextAnimation.kesikSinyal,
        titleTextColor: '#22A6B3',
        bodyTextColor: '#38B2AC',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji07,
          PresentationComponentKind.teknoloji08,
        ],
        glowIntensity: 0.5,
        fontScale: 1.05,
      );
    case PresentationTemplate.cyberpunk:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.googleArchivoBlack,
        bodyTextStyle: PresentationTextStyle.googleRobotoMono,
        titleTextAnimation: PresentationTextAnimation.kesikSinyal,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#00E5FF',
        bodyTextColor: '#FF0055',
        transitionKind: PresentationTransitionKind.glitch,
        transitionDurationMs: 400,
        componentKinds: [
          PresentationComponentKind.teknoloji09,
          PresentationComponentKind.teknoloji10,
        ],
        glowIntensity: 1.2,
        fontScale: 1.1,
      );
    case PresentationTemplate.glassmorphism:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.googleOutfit,
        bodyTextStyle: PresentationTextStyle.googleInter,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#E2E8F0',
        bodyTextColor: '#94A3B8',
        transitionKind: PresentationTransitionKind.morph,
        transitionDurationMs: 650,
        componentKinds: [
          PresentationComponentKind.genelSunumIs05,
          PresentationComponentKind.genelSunumIs06,
        ],
        glowIntensity: 0.8,
        fontScale: 1.05,
      );
    case PresentationTemplate.luxuryGold:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.historyArchaeology,
        titleTextStyle: PresentationTextStyle.googlePlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.googleLora,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.bulaniktanNet,
        titleTextColor: '#F59E0B',
        bodyTextColor: '#D97706',
        transitionKind: PresentationTransitionKind.prism,
        transitionDurationMs: 750,
        componentKinds: [
          PresentationComponentKind.tarih01,
          PresentationComponentKind.edebiyat01,
        ],
        glowIntensity: 0.9,
        fontScale: 1.0,
      );
    case PresentationTemplate.ecoGreen:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.natureEcology,
        titleTextStyle: PresentationTextStyle.googleNunito,
        bodyTextStyle: PresentationTextStyle.googleManrope,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#10B981',
        bodyTextColor: '#059669',
        transitionKind: PresentationTransitionKind.parallax,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.cevreDoga01,
          PresentationComponentKind.cevreDoga02,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.synthwave:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.googleOswald,
        bodyTextStyle: PresentationTextStyle.googlePoppins,
        titleTextAnimation: PresentationTextAnimation.holografikDalga,
        bodyTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        titleTextColor: '#EC4899',
        bodyTextColor: '#8B5CF6',
        transitionKind: PresentationTransitionKind.rotateZoom,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.sanat03,
          PresentationComponentKind.sanat04,
        ],
        glowIntensity: 1.1,
        fontScale: 1.1,
      );
    case PresentationTemplate.gradientMesh:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.googleDMSans,
        bodyTextStyle: PresentationTextStyle.googleInter,
        titleTextAnimation: PresentationTextAnimation.sinematikYaklasma,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#6366F1',
        bodyTextColor: '#4F46E5',
        transitionKind: PresentationTransitionKind.elastic,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.genelSunumIs03,
          PresentationComponentKind.genelSunumIs04,
        ],
        glowIntensity: 0.6,
        fontScale: 1.0,
      );
    case PresentationTemplate.editorial:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.googlePlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.googleRobotoSlab,
        titleTextAnimation: PresentationTextAnimation.daktilo,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#1E293B',
        bodyTextColor: '#334155',
        transitionKind: PresentationTransitionKind.radialWipe,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.edebiyat03,
          PresentationComponentKind.edebiyat04,
        ],
        glowIntensity: 0.2,
        fontScale: 1.0,
      );
    case PresentationTemplate.bauhaus:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.googleArchivoBlack,
        bodyTextStyle: PresentationTextStyle.googleArimo,
        titleTextAnimation: PresentationTextAnimation.perdeAcilisi,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#EF4444',
        bodyTextColor: '#1E40AF',
        transitionKind: PresentationTransitionKind.cube3d,
        transitionDurationMs: 700,
        componentKinds: [
          PresentationComponentKind.sanat01,
          PresentationComponentKind.sanat02,
        ],
        glowIntensity: 0.3,
        fontScale: 1.05,
      );
    case PresentationTemplate.dataTech:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.googleRobotoMono,
        bodyTextStyle: PresentationTextStyle.googleDMSans,
        titleTextAnimation: PresentationTextAnimation.isikTaramasi,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#06B6D4',
        bodyTextColor: '#0EA5E9',
        transitionKind: PresentationTransitionKind.split,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji01,
          PresentationComponentKind.teknoloji02,
        ],
        glowIntensity: 0.7,
        fontScale: 1.0,
      );
    case PresentationTemplate.deepSpace:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.googlePlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.googleInter,
        titleTextAnimation: PresentationTextAnimation.uzayDramatik,
        bodyTextAnimation: PresentationTextAnimation.uzayDeneysel,
        titleTextColor: '#A855F7',
        bodyTextColor: '#C084FC',
        transitionKind: PresentationTransitionKind.cube3d,
        transitionDurationMs: 800,
        componentKinds: [
          PresentationComponentKind.astronomi01,
          PresentationComponentKind.astronomi02,
        ],
        glowIntensity: 1.0,
        fontScale: 1.05,
      );
    case PresentationTemplate.bentoGrid:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCorporate,
        titleTextStyle: PresentationTextStyle.googleOutfit,
        bodyTextStyle: PresentationTextStyle.googleInter,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#0F172A',
        bodyTextColor: '#334155',
        transitionKind: PresentationTransitionKind.smooth,
        transitionDurationMs: 550,
        componentKinds: [
          PresentationComponentKind.genelSunumIs01,
          PresentationComponentKind.genelSunumIs02,
        ],
        glowIntensity: 0.5,
        fontScale: 1.0,
      );
    case PresentationTemplate.auroraBorealis:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.technology,
        titleTextStyle: PresentationTextStyle.googleOutfit,
        bodyTextStyle: PresentationTextStyle.googleInter,
        titleTextAnimation: PresentationTextAnimation.holografikDalga,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#10B981',
        bodyTextColor: '#8B5CF6',
        transitionKind: PresentationTransitionKind.morph,
        transitionDurationMs: 650,
        componentKinds: [
          PresentationComponentKind.teknoloji05,
          PresentationComponentKind.teknoloji06,
        ],
        glowIntensity: 1.1,
        fontScale: 1.05,
      );
    case PresentationTemplate.neomorphism:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightWarm,
        titleTextStyle: PresentationTextStyle.googleDMSans,
        bodyTextStyle: PresentationTextStyle.googleManrope,
        titleTextAnimation: PresentationTextAnimation.yavasBelirme,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#1E293B',
        bodyTextColor: '#475569',
        transitionKind: PresentationTransitionKind.convex,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.genelSunumIs05,
          PresentationComponentKind.genelSunumIs06,
        ],
        glowIntensity: 0.4,
        fontScale: 1.0,
      );
    case PresentationTemplate.holographic:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.spaceTechnology,
        titleTextStyle: PresentationTextStyle.googleArchivoBlack,
        bodyTextStyle: PresentationTextStyle.googleRobotoMono,
        titleTextAnimation: PresentationTextAnimation.neonKontur,
        bodyTextAnimation: PresentationTextAnimation.isikTaramasi,
        titleTextColor: '#38BDF8',
        bodyTextColor: '#F472B6',
        transitionKind: PresentationTransitionKind.glitch,
        transitionDurationMs: 500,
        componentKinds: [
          PresentationComponentKind.teknoloji09,
          PresentationComponentKind.teknoloji10,
        ],
        glowIntensity: 1.3,
        fontScale: 1.1,
      );
    case PresentationTemplate.nordicMinimal:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightEducation,
        titleTextStyle: PresentationTextStyle.googlePlayfairDisplay,
        bodyTextStyle: PresentationTextStyle.googleInter,
        titleTextAnimation: PresentationTextAnimation.daktilo,
        bodyTextAnimation: PresentationTextAnimation.none,
        titleTextColor: '#09090B',
        bodyTextColor: '#27272A',
        transitionKind: PresentationTransitionKind.fade,
        transitionDurationMs: 400,
        componentKinds: [
          PresentationComponentKind.edebiyat01,
          PresentationComponentKind.edebiyat02,
        ],
        glowIntensity: 0.0,
        fontScale: 1.0,
      );
    case PresentationTemplate.claymorphism:
      return const PresentationTemplateConfig(
        backgroundKind: PresentationBackgroundKind.lightCreative,
        titleTextStyle: PresentationTextStyle.googleNunito,
        bodyTextStyle: PresentationTextStyle.googlePoppins,
        titleTextAnimation: PresentationTextAnimation.ziplayarakGiris,
        bodyTextAnimation: PresentationTextAnimation.yavasBelirme,
        titleTextColor: '#EC4899',
        bodyTextColor: '#6366F1',
        transitionKind: PresentationTransitionKind.elastic,
        transitionDurationMs: 600,
        componentKinds: [
          PresentationComponentKind.sanat03,
          PresentationComponentKind.sanat04,
        ],
        glowIntensity: 0.7,
        fontScale: 1.05,
      );
  }
}

List<String> _splitText(String text, int maxCharacters) {
  final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  final chunks = <String>[];
  var current = StringBuffer();
  for (final word in words) {
    final nextLength =
        current.length == 0 ? word.length : current.length + word.length + 1;
    if (current.length > 0 && nextLength > maxCharacters) {
      chunks.add(current.toString());
      current = StringBuffer(word);
    } else {
      if (current.length > 0) current.write(' ');
      current.write(word);
    }
  }
  if (current.length > 0) chunks.add(current.toString());
  return chunks;
}

const int _minimumComponentScore = 12;

const Set<String> _ignoredComponentWords = <String>{
  'bir',
  'bu',
  'icin',
  'ile',
  'olan',
  'olarak',
  'gibi',
  'daha',
  'cok',
  'az',
  'her',
  'the',
  'and',
  'for',
  'with',
  'from',
  'that',
  'this',
  'into',
};

const Set<String> _ambiguousComponentTags = <String>{
  'analiz',
  'basari',
  'degerlendirme',
  'dil',
  'dogal kaynak',
  'doga',
  'form',
  'fikir',
  'gelisim',
  'hedef',
  'hareket',
  'iletisim',
  'ilerleme',
  'isbirligi',
  'kayit',
  'performans',
  'proje',
  'renk',
  'ses',
  'sembol',
  'sistem',
  'strateji',
  'surec',
  'tasarim',
  'teknoloji',
  'uretim',
  'veri',
  'verimlilik',
  'yaraticilik',
};

final Map<String, int> _componentTagCategoryCounts = () {
  final categoriesByTag = <String, Set<String>>{};
  for (final definition in presentationComponentDefinitions) {
    for (final tag in definition.tags) {
      final normalizedTag = _normalize(tag);
      if (normalizedTag.isEmpty) {
        continue;
      }
      categoriesByTag
          .putIfAbsent(normalizedTag, () => <String>{})
          .add(definition.category);
    }
  }
  return <String, int>{
    for (final entry in categoriesByTag.entries) entry.key: entry.value.length,
  };
}();

class _AutoTheme {
  const _AutoTheme({
    required this.backgroundKind,
    required this.keywords,
  });

  final PresentationBackgroundKind backgroundKind;
  final List<_AutoKeyword> keywords;
}

class _AutoKeyword {
  const _AutoKeyword(this.value, [this.weight = 3]);

  final String value;
  final int weight;
}

class _AutoComponentCandidate {
  const _AutoComponentCandidate(this.definition, this.score);

  final PresentationComponentDefinition definition;
  final int score;
}

const _fallbackTheme = _AutoTheme(
  backgroundKind: PresentationBackgroundKind.science,
  keywords: <_AutoKeyword>[],
);

final List<_AutoTheme> _autoThemes = presentationBackgroundLibrary
    .map(
      (definition) => _AutoTheme(
        backgroundKind: definition.kind,
        keywords: definition.tags
            .map((tag) => _AutoKeyword(tag, tag.contains(' ') ? 8 : 6))
            .toList(growable: false),
      ),
    )
    .toList(growable: false);

final Map<String, String> _normalizedCatalogTextCache = <String, String>{};

String _normalize(String value) {
  // Katalog etiketleri ve açıklamaları yüzlerce slaytta tekrar kullanılır.
  // Normalizasyon saf bir işlem olduğundan sonucu paylaşmak aynı eşleşme
  // davranışını korurken büyük katalog taramalarındaki tekrarları kaldırır.
  return _normalizedCatalogTextCache.putIfAbsent(
    value,
    () => PresentationKeywordCatalog.normalize(value),
  );
}
