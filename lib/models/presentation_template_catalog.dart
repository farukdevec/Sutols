import 'package:flutter/foundation.dart';
import 'beautiful_template_catalog.dart';
import 'slide_model.dart';

/// Firestore `templates/{templateId}` doküman yapısına uygun Sutol Şablon Modeli.
@immutable
class SutolTemplateModel {
  const SutolTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.colorPalette,
    required this.fontPair,
    required this.layoutCSS,
    this.description = '',
  });

  final String id;
  final String name;
  final String category; // "kurumsal", "yaratıcı", "minimal", "eğitim", "pazarlama"
  final List<String> colorPalette; // 3-4 renk
  final Map<String, String> fontPair; // {'heading': '...', 'body': '...'}
  final String layoutCSS;
  final String description;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': category,
      'colorPalette': colorPalette,
      'fontPair': fontPair,
      'layoutCSS': layoutCSS,
      'description': description,
    };
  }

  factory SutolTemplateModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SutolTemplateModel(
      id: docId ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'kurumsal',
      colorPalette: List<String>.from(map['colorPalette'] as List? ?? <String>[]),
      fontPair: Map<String, String>.from(map['fontPair'] as Map? ?? <String, String>{}),
      layoutCSS: map['layoutCSS'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }
}

/// Sutol 10 Tamamen Özgün ve Farklılaştırılmış Tasarım Şablon Kataloğu
const List<SutolTemplateModel> sutolTemplateCatalog = <SutolTemplateModel>[
  // ---------------------------------------------------------------------------
  // 1. KURUMSAL: Modern Kurumsal Vizyon
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'kurumsal_modern_vizyon',
    name: 'Modern Kurumsal Vizyon',
    category: 'kurumsal',
    colorPalette: <String>['#0F172A', '#2563EB', '#38BDF8', '#F8FAFC'],
    fontPair: <String, String>{
      'heading': 'Montserrat',
      'body': 'Inter',
    },
    description:
        'Yöneticiler için üst mavi akrilik şeritli, sol dikey çizgi vurgulu, buz mavisi ferah tuval.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Modern Kurumsal Vizyon === */
.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] {
  background-color: #F8FAFC !important;
  background-image: 
    linear-gradient(135deg, rgba(37, 99, 235, 0.05) 0%, rgba(15, 23, 42, 0.02) 100%),
    radial-gradient(circle at 100% 0%, rgba(56, 189, 248, 0.1) 0%, transparent 50%) !important;
  color: #0F172A !important;
  font-family: 'Inter', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"]::before {
  content: '' !important;
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  height: 8px !important;
  background: linear-gradient(90deg, #0F172A 0%, #2563EB 50%, #38BDF8 100%) !important;
  z-index: 20 !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-text-type-title {
  font-family: 'Montserrat', sans-serif !important;
  font-weight: 800 !important;
  color: #0F172A !important;
  letter-spacing: -0.02em !important;
  border-left: 6px solid #2563EB !important;
  padding-left: 0.6em !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-text-type-subtitle {
  font-family: 'Montserrat', sans-serif !important;
  font-weight: 600 !important;
  color: #2563EB !important;
  text-transform: uppercase !important;
  letter-spacing: 0.08em !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-text-type-body {
  color: #334155 !important;
  line-height: 1.65 !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 1px solid #E2E8F0 !important;
  border-top: 4px solid #2563EB !important;
  border-radius: 12px !important;
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 2. KURUMSAL: Koyu Kurumsal Liderlik
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'kurumsal_koyu_liderlik',
    name: 'Koyu Kurumsal Liderlik',
    category: 'kurumsal',
    colorPalette: <String>['#090D16', '#1E293B', '#3B82F6', '#94A3B8'],
    fontPair: <String, String>{
      'heading': 'Roboto',
      'body': 'Open Sans',
    },
    description:
        'Yüksek prestijli gece mavisi tuval, buzlu cam (glassmorphism) kartlar ve neon mavi detaylar.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Koyu Kurumsal Liderlik === */
.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] {
  background-color: #090D16 !important;
  background-image: 
    radial-gradient(circle at 10% 20%, rgba(59, 130, 246, 0.18) 0%, transparent 40%),
    radial-gradient(circle at 90% 80%, rgba(30, 41, 59, 0.6) 0%, transparent 50%) !important;
  color: #F8FAFC !important;
  font-family: 'Open Sans', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-text-type-title {
  font-family: 'Roboto', sans-serif !important;
  font-weight: 800 !important;
  color: #FFFFFF !important;
  letter-spacing: -0.01em !important;
  filter: drop-shadow(0 0 12px rgba(59, 130, 246, 0.35)) !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-text-type-subtitle {
  font-family: 'Roboto', sans-serif !important;
  font-weight: 600 !important;
  color: #3B82F6 !important;
  letter-spacing: 0.06em !important;
  text-transform: uppercase !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-text-type-body {
  color: #94A3B8 !important;
  line-height: 1.6 !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-html-component {
  background: rgba(15, 23, 42, 0.75) !important;
  border: 1px solid rgba(59, 130, 246, 0.35) !important;
  border-radius: 14px !important;
  backdrop-filter: blur(16px) !important;
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.5) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 3. YARATICI: Yaratıcı Neon Stüdyo
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'yaratici_neon_studio',
    name: 'Yaratıcı Cyber Neon',
    category: 'yaratıcı',
    colorPalette: <String>['#07090E', '#EC4899', '#8B5CF6', '#06B6D4'],
    fontPair: <String, String>{
      'heading': 'Outfit',
      'body': 'Roboto',
    },
    description:
        'Derin siyah tuval üzerinde canlı pembe/mor gradyan başlıklar ve siyan neon çerçeveler.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Yaratıcı Cyber Neon === */
.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] {
  background-color: #07090E !important;
  background-image: 
    radial-gradient(circle at 10% 10%, rgba(236, 72, 153, 0.22) 0%, transparent 40%),
    radial-gradient(circle at 90% 90%, rgba(6, 182, 212, 0.18) 0%, transparent 40%),
    radial-gradient(circle at 50% 50%, rgba(139, 92, 246, 0.1) 0%, transparent 50%) !important;
  color: #F3F4F6 !important;
  font-family: 'Roboto', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-text-type-title {
  font-family: 'Outfit', sans-serif !important;
  font-weight: 900 !important;
  background: linear-gradient(135deg, #EC4899 0%, #8B5CF6 50%, #06B6D4 100%) !important;
  -webkit-background-clip: text !important;
  -webkit-text-fill-color: transparent !important;
  letter-spacing: -0.03em !important;
  filter: drop-shadow(0 0 15px rgba(236, 72, 153, 0.4)) !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-text-type-subtitle {
  font-family: 'Outfit', sans-serif !important;
  font-weight: 700 !important;
  color: #06B6D4 !important;
  letter-spacing: 0.1em !important;
  text-transform: uppercase !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-text-type-body {
  color: #E2E8F0 !important;
  line-height: 1.65 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-html-component {
  background: rgba(13, 17, 26, 0.8) !important;
  border: 1.5px solid rgba(236, 72, 153, 0.45) !important;
  border-radius: 16px !important;
  backdrop-filter: blur(14px) !important;
  box-shadow: 0 0 25px rgba(236, 72, 153, 0.18), 0 0 10px rgba(6, 182, 212, 0.15) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 4. YARATICI: Bauhaus Yaratıcı Sanat
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'yaratici_bauhaus_art',
    name: 'Bauhaus Retro-Art',
    category: 'yaratıcı',
    colorPalette: <String>['#F4F1EA', '#E63946', '#457B9D', '#1D3557'],
    fontPair: <String, String>{
      'heading': 'Archivo Black',
      'body': 'Work Sans',
    },
    description:
        'Keten sarısı tuval, 3px siyah sert çerçeveler, 8px kırmızı gölgeler ve neo-brutalist tarz.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Bauhaus Retro-Art === */
.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] {
  background-color: #F4F1EA !important;
  background-image: 
    linear-gradient(90deg, rgba(29, 53, 87, 0.04) 1px, transparent 1px),
    linear-gradient(rgba(29, 53, 87, 0.04) 1px, transparent 1px) !important;
  background-size: 40px 40px !important;
  color: #1D3557 !important;
  font-family: 'Work Sans', sans-serif !important;
  position: relative !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"]::after {
  content: '' !important;
  position: absolute !important;
  bottom: 0 !important;
  right: 0 !important;
  width: 140px !important;
  height: 140px !important;
  background: #E63946 !important;
  clip-path: polygon(100% 0, 0 100%, 100% 100%) !important;
  z-index: 10 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-text-type-title {
  font-family: 'Archivo Black', sans-serif !important;
  font-weight: 900 !important;
  color: #1D3557 !important;
  text-transform: uppercase !important;
  letter-spacing: -0.03em !important;
  line-height: 1.05 !important;
  text-shadow: 3px 3px 0px #E63946 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-text-type-subtitle {
  font-family: 'Work Sans', sans-serif !important;
  font-weight: 800 !important;
  color: #E63946 !important;
  letter-spacing: 0.06em !important;
  text-transform: uppercase !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-text-type-body {
  color: #1D3557 !important;
  line-height: 1.6 !important;
  font-weight: 500 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 3px solid #1D3557 !important;
  border-radius: 0px !important;
  box-shadow: 8px 8px 0px #E63946 !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 5. MİNİMAL: Nordik Minimalist
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'minimal_nordik_sade',
    name: 'Nordik Minimalist',
    category: 'minimal',
    colorPalette: <String>['#F6F6F2', '#2B2D42', '#8D99AE', '#E0E1DD'],
    fontPair: <String, String>{
      'heading': 'DM Sans',
      'body': 'Inter',
    },
    description:
        'Sade taş rengi tuval, geniş ferah boşluklar, kavisli yumuşak kartlar ve saf tipografi.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Nordik Minimalist === */
.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] {
  background-color: #F6F6F2 !important;
  color: #2B2D42 !important;
  font-family: 'Inter', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-text-type-title {
  font-family: 'DM Sans', sans-serif !important;
  font-weight: 600 !important;
  color: #2B2D42 !important;
  letter-spacing: -0.02em !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-text-type-subtitle {
  font-family: 'DM Sans', sans-serif !important;
  font-weight: 500 !important;
  color: #8D99AE !important;
  letter-spacing: 0.05em !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-text-type-body {
  color: #4A5568 !important;
  line-height: 1.75 !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 1px solid #E2E4DC !important;
  border-radius: 20px !important;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.03) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 6. MİNİMAL: Editorial Monokrom
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'minimal_editorial_monokrom',
    name: 'Editorial Monokrom',
    category: 'minimal',
    colorPalette: <String>['#111111', '#FFFFFF', '#767676', '#E5E5E5'],
    fontPair: <String, String>{
      'heading': 'Playfair Display',
      'body': 'Lora',
    },
    description:
        'Dergi mizanpajı hissi veren italik serif başlıklar, çift alt çizgi ve monokrom çerçeveler.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Editorial Monokrom === */
.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] {
  background-color: #FFFFFF !important;
  color: #111111 !important;
  font-family: 'Lora', serif !important;
  border: 12px solid #111111 !important;
  box-sizing: border-box !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-text-type-title {
  font-family: 'Playfair Display', serif !important;
  font-weight: 800 !important;
  font-style: italic !important;
  color: #111111 !important;
  border-bottom: 3px double #111111 !important;
  padding-bottom: 0.3em !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-text-type-subtitle {
  font-family: 'Playfair Display', serif !important;
  font-weight: 500 !important;
  color: #767676 !important;
  text-transform: uppercase !important;
  letter-spacing: 0.12em !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-text-type-body {
  color: #222222 !important;
  line-height: 1.8 !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-html-component {
  background: #FAFAFA !important;
  border: 1px solid #111111 !important;
  border-radius: 0px !important;
  box-shadow: none !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 7. EĞİTİM: Akademik Tez & Kitaplık
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'egitim_akademik_baskani',
    name: 'Akademik Tez & Kitaplık',
    category: 'eğitim',
    colorPalette: <String>['#FDFBF7', '#1B4332', '#D4AF37', '#2D6A4F'],
    fontPair: <String, String>{
      'heading': 'Merriweather',
      'body': 'Open Sans',
    },
    description:
        'Fildişi tuval, üst koyu orman yeşili banner, altın çizgi vurgusu ve sol yeşil şerit kartlar.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Akademik Tez & Kitaplık === */
.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] {
  background-color: #FDFBF7 !important;
  color: #1B4332 !important;
  font-family: 'Open Sans', sans-serif !important;
  position: relative !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"]::before {
  content: '' !important;
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  height: 50px !important;
  background: #1B4332 !important;
  border-bottom: 3px solid #D4AF37 !important;
  z-index: 10 !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] .sutol-text-type-title {
  font-family: 'Merriweather', serif !important;
  font-weight: 900 !important;
  color: #1B4332 !important;
  letter-spacing: -0.01em !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] .sutol-text-type-subtitle {
  font-family: 'Merriweather', serif !important;
  font-weight: 400 !important;
  color: #2D6A4F !important;
  font-style: italic !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] .sutol-text-type-body {
  color: #2C3E50 !important;
  line-height: 1.7 !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 1px solid rgba(27, 67, 50, 0.2) !important;
  border-left: 6px solid #1B4332 !important;
  border-radius: 8px !important;
  box-shadow: 0 6px 18px rgba(27, 67, 50, 0.06) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 8. EĞİTİM: İnteraktif Eğitim Stüdyosu
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'egitim_interaktif_renkli',
    name: 'İnteraktif Eğitim Stüdyosu',
    category: 'eğitim',
    colorPalette: <String>['#FFFBEB', '#D97706', '#2563EB', '#F59E0B'],
    fontPair: <String, String>{
      'heading': 'Poppins',
      'body': 'Nunito',
    },
    description:
        'Sıcak kehribar tuval, neşeli 20px yuvarlatılmış kartlar ve canlı Poppins tipografi.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: İnteraktif Eğitim Stüdyosu === */
.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] {
  background-color: #FFFBEB !important;
  background-image: 
    radial-gradient(circle at 90% 10%, rgba(245, 158, 11, 0.15) 0%, transparent 40%),
    radial-gradient(circle at 10% 90%, rgba(37, 99, 235, 0.1) 0%, transparent 40%) !important;
  color: #1E293B !important;
  font-family: 'Nunito', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-text-type-title {
  font-family: 'Poppins', sans-serif !important;
  font-weight: 800 !important;
  color: #D97706 !important;
  letter-spacing: -0.01em !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-text-type-subtitle {
  font-family: 'Poppins', sans-serif !important;
  font-weight: 700 !important;
  color: #2563EB !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-text-type-body {
  color: #334155 !important;
  line-height: 1.6 !important;
  font-weight: 600 !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 3px solid #F59E0B !important;
  border-radius: 20px !important;
  box-shadow: 0 10px 25px rgba(217, 119, 6, 0.12) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 9. PAZARLAMA: Modern Ürün Lansmanı
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'pazarlama_modern_lansman',
    name: 'Modern Ürün Lansmanı',
    category: 'pazarlama',
    colorPalette: <String>['#0F172A', '#F97316', '#FACC15', '#F8FAFC'],
    fontPair: <String, String>{
      'heading': 'Raleway',
      'body': 'Inter',
    },
    description:
        'Koyu lacivert tuval üzerinde patlayan turuncu gradyan halkalar ve lansman kartları.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Modern Ürün Lansmanı === */
.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] {
  background-color: #0F172A !important;
  background-image: 
    radial-gradient(circle at 80% 20%, rgba(249, 115, 22, 0.28) 0%, transparent 45%),
    radial-gradient(circle at 20% 80%, rgba(250, 204, 21, 0.15) 0%, transparent 45%) !important;
  color: #F8FAFC !important;
  font-family: 'Inter', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-text-type-title {
  font-family: 'Raleway', sans-serif !important;
  font-weight: 900 !important;
  color: #FFFFFF !important;
  letter-spacing: -0.02em !important;
  filter: drop-shadow(0 2px 10px rgba(249, 115, 22, 0.3)) !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-text-type-subtitle {
  font-family: 'Raleway', sans-serif !important;
  font-weight: 800 !important;
  color: #F97316 !important;
  text-transform: uppercase !important;
  letter-spacing: 0.1em !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-text-type-body {
  color: #CBD5E1 !important;
  line-height: 1.65 !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-html-component {
  background: rgba(30, 41, 59, 0.8) !important;
  border: 1.5px solid rgba(249, 115, 22, 0.4) !important;
  border-radius: 16px !important;
  backdrop-filter: blur(12px) !important;
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.45) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 10. PAZARLAMA: Growth & Satış Stratejisi
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'pazarlama_growth_bold',
    name: 'Growth Matrix Green',
    category: 'pazarlama',
    colorPalette: <String>['#080C14', '#10B981', '#059669', '#ECFDF5'],
    fontPair: <String, String>{
      'heading': 'Kanit',
      'body': 'Manrope',
    },
    description:
        'Matris siyahı tuval, ızgara hatları, zümrüt yeşili parlayan metrik kartları ve Kanit tipografi.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Growth Matrix Green === */
.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] {
  background-color: #080C14 !important;
  background-image: 
    linear-gradient(90deg, rgba(16, 185, 129, 0.05) 1px, transparent 1px),
    linear-gradient(rgba(16, 185, 129, 0.05) 1px, transparent 1px),
    radial-gradient(circle at 50% 0%, rgba(16, 185, 129, 0.22) 0%, transparent 60%) !important;
  background-size: 30px 30px, 30px 30px, 100% 100% !important;
  color: #ECFDF5 !important;
  font-family: 'Manrope', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-bg-scene {
  display: none !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-text-type-title {
  font-family: 'Kanit', sans-serif !important;
  font-weight: 800 !important;
  color: #10B981 !important;
  letter-spacing: -0.01em !important;
  filter: drop-shadow(0 0 10px rgba(16, 185, 129, 0.4)) !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-text-type-subtitle {
  font-family: 'Kanit', sans-serif !important;
  font-weight: 600 !important;
  color: #34D399 !important;
  letter-spacing: 0.06em !important;
  text-transform: uppercase !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-text-type-body {
  color: #D1D5DB !important;
  line-height: 1.6 !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-html-component {
  background: rgba(16, 185, 129, 0.08) !important;
  border: 1.5px solid #10B981 !important;
  border-radius: 12px !important;
  backdrop-filter: blur(10px) !important;
  box-shadow: 0 8px 25px rgba(16, 185, 129, 0.15) !important;
}
''',
  ),
];

/// Tüm şablonların (özgün ve 34 Beautiful HTML Şablonları) birleşik listesi
List<SutolTemplateModel> get allSutolTemplateCatalog => <SutolTemplateModel>[
      ...sutolTemplateCatalog,
      ...beautifulTemplateCatalog,
    ];

/// Helper fonksiyonlar
SutolTemplateModel? getSutolTemplateById(String id) {
  for (final template in allSutolTemplateCatalog) {
    if (template.id == id) return template;
  }
  return null;
}

List<SutolTemplateModel> getSutolTemplatesByCategory(String category) {
  return allSutolTemplateCatalog
      .where((t) => t.category.toLowerCase() == category.toLowerCase())
      .toList(growable: false);
}

List<String> get sutolTemplateCategories => const <String>[
      'kurumsal',
      'yaratıcı',
      'minimal',
      'eğitim',
      'pazarlama',
    ];

/// Tüm şablonların ürettiği derlenmiş toplu layoutCSS kuralları
String get sutolCombinedTemplatesCSS =>
    allSutolTemplateCatalog.map((t) => t.layoutCSS).join('\n\n');

/// Font ailesi adını PresentationTextStyle enum değerine çevirir.
PresentationTextStyle presentationFontFamilyStyle(String fontFamily) {
  return switch (fontFamily.toLowerCase().trim()) {
    'montserrat' => PresentationTextStyle.googleMontserrat,
    'inter' => PresentationTextStyle.googleInter,
    'roboto' => PresentationTextStyle.googleRoboto,
    'outfit' => PresentationTextStyle.googleOutfit,
    'open sans' => PresentationTextStyle.googleOpenSans,
    'work sans' => PresentationTextStyle.googleWorkSans,
    'lora' => PresentationTextStyle.googleLora,
    'poppins' => PresentationTextStyle.googlePoppins,
    'nunito' => PresentationTextStyle.googleNunito,
    'raleway' => PresentationTextStyle.googleRaleway,
    'manrope' => PresentationTextStyle.googleManrope,
    'kanit' => PresentationTextStyle.googleKanit,
    'merriweather' => PresentationTextStyle.googleMerriweather,
    'playfair display' => PresentationTextStyle.googlePlayfairDisplay,
    'archivo black' => PresentationTextStyle.googleArchivoBlack,
    'dm sans' => PresentationTextStyle.googleDMSans,
    _ => PresentationTextStyle.googleInter,
  };
}

