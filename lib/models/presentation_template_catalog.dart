import 'package:flutter/foundation.dart';
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
  final List<String> colorPalette; // 3-4 renk (ör. primary, secondary, accent, surface)
  final Map<String, String> fontPair; // {'heading': '...', 'body': '...'}
  final String layoutCSS;
  final String description;

  /// Firestore document map dönüşümü
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

  /// Firestore document map factory
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

/// Sutol 10 Profesyonel Şablon Kataloğu
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
        'Yöneticiler ve şirket sunumları için temiz, güven veren mavi ve slate tonlarında üst akrilik şeritli kurumsal tasarım.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Modern Kurumsal Vizyon === */
.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"],
.sutol-template-kurumsal_modern_vizyon {
  background-color: #F8FAFC !important;
  background-image: 
    linear-gradient(135deg, rgba(37, 99, 235, 0.04) 0%, rgba(15, 23, 42, 0.02) 100%),
    radial-gradient(circle at 100% 0%, rgba(56, 189, 248, 0.08) 0%, transparent 40%) !important;
  color: #0F172A !important;
  font-family: 'Inter', sans-serif !important;
  position: relative !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"]::before {
  content: '' !important;
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  height: 6px !important;
  background: linear-gradient(90deg, #2563EB 0%, #38BDF8 100%) !important;
  z-index: 10 !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-text-type-title {
  font-family: 'Montserrat', sans-serif !important;
  font-weight: 700 !important;
  color: #0F172A !important;
  letter-spacing: -0.02em !important;
  border-left: 4px solid #2563EB !important;
  padding-left: 0.5em !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-text-type-subtitle {
  font-family: 'Montserrat', sans-serif !important;
  font-weight: 600 !important;
  color: #2563EB !important;
  text-transform: uppercase !important;
  letter-spacing: 0.06em !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-text-type-body {
  color: #334155 !important;
  line-height: 1.65 !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_modern_vizyon"] .sutol-html-component {
  background: rgba(255, 255, 255, 0.88) !important;
  border: 1px solid rgba(226, 232, 240, 0.9) !important;
  border-radius: 12px !important;
  box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.06), 0 8px 10px -6px rgba(15, 23, 42, 0.04) !important;
  backdrop-filter: blur(8px) !important;
  transition: all 0.3s ease !important;
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
        'Yüksek prestijli, premium koyu tema kurumsal sunumlar için lacivert/gece mavisi tonları.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Koyu Kurumsal Liderlik === */
.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"],
.sutol-template-kurumsal_koyu_liderlik {
  background-color: #090D16 !important;
  background-image: 
    radial-gradient(circle at 20% 20%, rgba(59, 130, 246, 0.12) 0%, transparent 50%),
    radial-gradient(circle at 80% 80%, rgba(30, 41, 59, 0.5) 0%, transparent 60%) !important;
  color: #F8FAFC !important;
  font-family: 'Open Sans', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-text-type-title {
  font-family: 'Roboto', sans-serif !important;
  font-weight: 700 !important;
  color: #FFFFFF !important;
  letter-spacing: -0.01em !important;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.5) !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-text-type-subtitle {
  font-family: 'Roboto', sans-serif !important;
  font-weight: 500 !important;
  color: #3B82F6 !important;
  letter-spacing: 0.04em !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-text-type-body {
  color: #94A3B8 !important;
  line-height: 1.6 !important;
}

.sutol-html-stage[data-sutol-template="kurumsal_koyu_liderlik"] .sutol-html-component {
  background: rgba(30, 41, 59, 0.55) !important;
  border: 1px solid rgba(59, 130, 246, 0.25) !important;
  border-radius: 10px !important;
  backdrop-filter: blur(12px) !important;
  box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 3. YARATICI: Yaratıcı Neon Stüdyo
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'yaratici_neon_studio',
    name: 'Yaratıcı Neon Stüdyo',
    category: 'yaratıcı',
    colorPalette: <String>['#0B0F19', '#EC4899', '#8B5CF6', '#06B6D4'],
    fontPair: <String, String>{
      'heading': 'Outfit',
      'body': 'Roboto',
    },
    description:
        'Tasarımcılar, ajanslar ve yaratıcı projeler için canlı neon gradyanlar ve cam efekti.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Yaratıcı Neon Stüdyo === */
.sutol-html-stage[data-sutol-template="yaratici_neon_studio"],
.sutol-template-yaratici_neon_studio {
  background-color: #0B0F19 !important;
  background-image: 
    radial-gradient(circle at 15% 30%, rgba(236, 72, 153, 0.15) 0%, transparent 45%),
    radial-gradient(circle at 85% 70%, rgba(139, 92, 246, 0.15) 0%, transparent 45%),
    radial-gradient(circle at 50% 50%, rgba(6, 182, 212, 0.08) 0%, transparent 60%) !important;
  color: #F3F4F6 !important;
  font-family: 'Roboto', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-text-type-title {
  font-family: 'Outfit', sans-serif !important;
  font-weight: 800 !important;
  background: linear-gradient(135deg, #EC4899 0%, #8B5CF6 50%, #06B6D4 100%) !important;
  -webkit-background-clip: text !important;
  -webkit-text-fill-color: transparent !important;
  letter-spacing: -0.02em !important;
  filter: drop-shadow(0 2px 8px rgba(236, 72, 153, 0.25)) !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-text-type-subtitle {
  font-family: 'Outfit', sans-serif !important;
  font-weight: 600 !important;
  color: #06B6D4 !important;
  letter-spacing: 0.08em !important;
  text-transform: uppercase !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-text-type-body {
  color: #E2E8F0 !important;
  line-height: 1.6 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_neon_studio"] .sutol-html-component {
  background: rgba(15, 23, 42, 0.65) !important;
  border: 1px solid rgba(236, 72, 153, 0.35) !important;
  border-radius: 16px !important;
  backdrop-filter: blur(14px) !important;
  box-shadow: 0 0 25px rgba(236, 72, 153, 0.12), inset 0 0 15px rgba(6, 182, 212, 0.05) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 4. YARATICI: Bauhaus Yaratıcı Sanat
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'yaratici_bauhaus_art',
    name: 'Bauhaus Yaratıcı Sanat',
    category: 'yaratıcı',
    colorPalette: <String>['#F4F1EA', '#E63946', '#457B9D', '#1D3557'],
    fontPair: <String, String>{
      'heading': 'Archivo Black',
      'body': 'Work Sans',
    },
    description:
        'Geometrik şekiller, canlı asimetrik vurucu renkler ve sanatsal tipografi düzeni.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Bauhaus Yaratıcı Sanat === */
.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"],
.sutol-template-yaratici_bauhaus_art {
  background-color: #F4F1EA !important;
  color: #1D3557 !important;
  font-family: 'Work Sans', sans-serif !important;
  position: relative !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"]::after {
  content: '' !important;
  position: absolute !important;
  bottom: 0 !important;
  right: 0 !important;
  width: 120px !important;
  height: 120px !important;
  background: #E63946 !important;
  clip-path: polygon(100% 0, 0 100%, 100% 100%) !important;
  opacity: 0.85 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-text-type-title {
  font-family: 'Archivo Black', sans-serif !important;
  font-weight: 900 !important;
  color: #1D3557 !important;
  text-transform: uppercase !important;
  letter-spacing: -0.03em !important;
  line-height: 1.1 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-text-type-subtitle {
  font-family: 'Work Sans', sans-serif !important;
  font-weight: 700 !important;
  color: #E63946 !important;
  letter-spacing: 0.05em !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-text-type-body {
  color: #457B9D !important;
  line-height: 1.55 !important;
}

.sutol-html-stage[data-sutol-template="yaratici_bauhaus_art"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 3px solid #1D3557 !important;
  border-radius: 0px !important;
  box-shadow: 6px 6px 0px #E63946 !important;
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
    colorPalette: <String>['#F5F5F0', '#2B2D42', '#8D99AE', '#E0E1DD'],
    fontPair: <String, String>{
      'heading': 'DM Sans',
      'body': 'Inter',
    },
    description:
        'Göz yormayan ferah boşluklar, yumuşak gri/bej tonları ve saf tipografik denge.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Nordik Minimalist === */
.sutol-html-stage[data-sutol-template="minimal_nordik_sade"],
.sutol-template-minimal_nordik_sade {
  background-color: #F5F5F0 !important;
  color: #2B2D42 !important;
  font-family: 'Inter', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-text-type-title {
  font-family: 'DM Sans', sans-serif !important;
  font-weight: 500 !important;
  color: #2B2D42 !important;
  letter-spacing: -0.02em !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-text-type-subtitle {
  font-family: 'DM Sans', sans-serif !important;
  font-weight: 400 !important;
  color: #8D99AE !important;
  letter-spacing: 0.04em !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-text-type-body {
  color: #4A5568 !important;
  line-height: 1.7 !important;
  font-weight: 300 !important;
}

.sutol-html-stage[data-sutol-template="minimal_nordik_sade"] .sutol-html-component {
  background: rgba(255, 255, 255, 0.7) !important;
  border: 1px solid #E0E1DD !important;
  border-radius: 8px !important;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02) !important;
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
        'Dergi/gazete mizanpajı hissi veren serif tipografi ve keskin siyah-beyaz monokrom düzen.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Editorial Monokrom === */
.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"],
.sutol-template-minimal_editorial_monokrom {
  background-color: #FFFFFF !important;
  color: #111111 !important;
  font-family: 'Lora', serif !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-text-type-title {
  font-family: 'Playfair Display', serif !important;
  font-weight: 700 !important;
  font-style: italic !important;
  color: #111111 !important;
  border-bottom: 2px solid #111111 !important;
  padding-bottom: 0.2em !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-text-type-subtitle {
  font-family: 'Playfair Display', serif !important;
  font-weight: 400 !important;
  color: #767676 !important;
  text-transform: uppercase !important;
  letter-spacing: 0.1em !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-text-type-body {
  color: #222222 !important;
  line-height: 1.75 !important;
}

.sutol-html-stage[data-sutol-template="minimal_editorial_monokrom"] .sutol-html-component {
  background: #FAFAFA !important;
  border: 1px solid #E5E5E5 !important;
  border-radius: 0px !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 7. EĞİTİM: Akademik Tez & Araştırma
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'egitim_akademik_baskani',
    name: 'Akademik Tez & Araştırma',
    category: 'eğitim',
    colorPalette: <String>['#FDFBF7', '#1B4332', '#2D6A4F', '#D8F3DC'],
    fontPair: <String, String>{
      'heading': 'Merriweather',
      'body': 'Open Sans',
    },
    description:
        'Üniversite, akademik ders ve araştırma sunumları için güvenilir yeşil-krem tonları.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Akademik Tez & Araştırma === */
.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"],
.sutol-template-egitim_akademik_baskani {
  background-color: #FDFBF7 !important;
  color: #1B4332 !important;
  font-family: 'Open Sans', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] .sutol-text-type-title {
  font-family: 'Merriweather', serif !important;
  font-weight: 700 !important;
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
  line-height: 1.65 !important;
}

.sutol-html-stage[data-sutol-template="egitim_akademik_baskani"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 1px solid rgba(45, 106, 79, 0.25) !important;
  border-left: 4px solid #1B4332 !important;
  border-radius: 6px !important;
  box-shadow: 0 4px 15px rgba(27, 67, 50, 0.05) !important;
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
    colorPalette: <String>['#FFFBEB', '#D97706', '#2563EB', '#10B981'],
    fontPair: <String, String>{
      'heading': 'Poppins',
      'body': 'Nunito',
    },
    description:
        'Dersler, workshop\'lar ve öğrenci sunumları için enerjik ve dost canlısı renkli kartlar.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: İnteraktif Eğitim Stüdyosu === */
.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"],
.sutol-template-egitim_interaktif_renkli {
  background-color: #FFFBEB !important;
  color: #1E293B !important;
  font-family: 'Nunito', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-text-type-title {
  font-family: 'Poppins', sans-serif !important;
  font-weight: 700 !important;
  color: #D97706 !important;
  letter-spacing: -0.01em !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-text-type-subtitle {
  font-family: 'Poppins', sans-serif !important;
  font-weight: 600 !important;
  color: #2563EB !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-text-type-body {
  color: #334155 !important;
  line-height: 1.6 !important;
  font-weight: 600 !important;
}

.sutol-html-stage[data-sutol-template="egitim_interaktif_renkli"] .sutol-html-component {
  background: #FFFFFF !important;
  border: 2px solid #FCD34D !important;
  border-radius: 18px !important;
  box-shadow: 0 8px 20px rgba(217, 119, 6, 0.08) !important;
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
        'Pazarlama kampanyaları ve ürün tanıtımları için vurucu turuncu ve altın vurgular.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Modern Ürün Lansmanı === */
.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"],
.sutol-template-pazarlama_modern_lansman {
  background-color: #0F172A !important;
  background-image: 
    radial-gradient(circle at 90% 10%, rgba(249, 115, 22, 0.18) 0%, transparent 40%),
    radial-gradient(circle at 10% 90%, rgba(250, 204, 21, 0.1) 0%, transparent 40%) !important;
  color: #F8FAFC !important;
  font-family: 'Inter', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-text-type-title {
  font-family: 'Raleway', sans-serif !important;
  font-weight: 800 !important;
  color: #FFFFFF !important;
  letter-spacing: -0.02em !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-text-type-subtitle {
  font-family: 'Raleway', sans-serif !important;
  font-weight: 700 !important;
  color: #F97316 !important;
  text-transform: uppercase !important;
  letter-spacing: 0.08em !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-text-type-body {
  color: #CBD5E1 !important;
  line-height: 1.6 !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_modern_lansman"] .sutol-html-component {
  background: rgba(30, 41, 59, 0.7) !important;
  border: 1px solid rgba(249, 115, 22, 0.3) !important;
  border-radius: 14px !important;
  backdrop-filter: blur(10px) !important;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4) !important;
}
''',
  ),

  // ---------------------------------------------------------------------------
  // 10. PAZARLAMA: Growth & Satış Stratejisi
  // ---------------------------------------------------------------------------
  SutolTemplateModel(
    id: 'pazarlama_growth_bold',
    name: 'Growth & Satış Stratejisi',
    category: 'pazarlama',
    colorPalette: <String>['#0D1117', '#10B981', '#059669', '#E6F4EA'],
    fontPair: <String, String>{
      'heading': 'Kanit',
      'body': 'Manrope',
    },
    description:
        'Growth hacking, finansal büyüme ve satış raporları için zümrüt yeşili dinamik tema.',
    layoutCSS: '''
/* === SUTOL TEMPLATE: Growth & Satış Stratejisi === */
.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"],
.sutol-template-pazarlama_growth_bold {
  background-color: #0D1117 !important;
  background-image: 
    radial-gradient(circle at 50% 0%, rgba(16, 185, 129, 0.15) 0%, transparent 50%) !important;
  color: #ECFDF5 !important;
  font-family: 'Manrope', sans-serif !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-text-type-title {
  font-family: 'Kanit', sans-serif !important;
  font-weight: 700 !important;
  color: #10B981 !important;
  letter-spacing: -0.01em !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-text-type-subtitle {
  font-family: 'Kanit', sans-serif !important;
  font-weight: 500 !important;
  color: #34D399 !important;
  letter-spacing: 0.05em !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-text-type-body {
  color: #D1D5DB !important;
  line-height: 1.6 !important;
}

.sutol-html-stage[data-sutol-template="pazarlama_growth_bold"] .sutol-html-component {
  background: rgba(16, 185, 129, 0.06) !important;
  border: 1px solid rgba(16, 185, 129, 0.3) !important;
  border-radius: 12px !important;
  backdrop-filter: blur(8px) !important;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3) !important;
}
''',
  ),
];

/// Helper fonksiyonlar
SutolTemplateModel? getSutolTemplateById(String id) {
  for (final template in sutolTemplateCatalog) {
    if (template.id == id) return template;
  }
  return null;
}

List<SutolTemplateModel> getSutolTemplatesByCategory(String category) {
  return sutolTemplateCatalog
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
    sutolTemplateCatalog.map((t) => t.layoutCSS).join('\n\n');

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
