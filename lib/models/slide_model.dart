import 'package:flutter/material.dart';

import 'presentation_component_catalog.dart';

export 'presentation_component_catalog.dart';
export 'presentation_3d_model_catalog.dart';

enum PresentationTextType {
  title,
  subtitle,
  body,
}

enum PresentationTextAlign {
  left,
  center,
  right,
}

enum PresentationTextStyle {
  standard,
  bilimDramatik,
  bilimTemiz,
  bilimDeneysel,
  gunesDramatik,
  gunesTemiz,
  gunesDeneysel,
  uzayDramatik,
  uzayTemiz,
  uzayDeneysel,
  optikDramatik,
  optikTemiz,
  optikDeneysel,
  fizikDramatik,
  fizikTemiz,
  fizikDeneysel,
  teknolojiDramatik,
  teknolojiTemiz,
  teknolojiDeneysel,
  openOswald,
  openPlayfairDisplay,
  openBebasNeue,
  openBungee,
  openCaveat,
  openUnbounded,
  klasikTinos,
  klasikArimo,
  klasikCousine,
  klasikCarlito,
  klasikCaladea,
  klasikEBGaramond,
  klasikLibreBaskerville,
  klasikAlegreya,
  klasikPTSerif,
  klasikMerriweather,
  klasikLora,
  klasikGreatVibes,
  klasikDancingScript,
  klasikPacifico,
  klasikLobster,
  googleRoboto,
  googleOpenSans,
  googleInter,
  googleMontserrat,
  googlePoppins,
  googleNotoSansJP,
  googleLato,
  googleArimo,
  googleRobotoCondensed,
  googleRobotoMono,
  googleNotoSans,
  googleOswald,
  googleDMSans,
  googleNunito,
  googleRaleway,
  googleNunitoSans,
  googlePlayfairDisplay,
  googleRobotoSlab,
  googleRubik,
  googleArchivoBlack,
  googleUbuntu,
  googleNotoSansKR,
  googleKanit,
  googleManrope,
  googleOutfit,
  googleMerriweather,
  googleWorkSans,
  googleLora,
  googleNotoSansTC,
  googlePrompt,
}

/// Google Fonts resmi katalog metadata'sındaki popülerlik sırasına göre,
/// açık kaynak olarak işaretlenen ve CSS API üzerinden sunulan 30 aile.
const Map<PresentationTextStyle, String> popularGoogleFontFamilies =
    <PresentationTextStyle, String>{
  PresentationTextStyle.googleRoboto: 'Roboto',
  PresentationTextStyle.googleOpenSans: 'Open Sans',
  PresentationTextStyle.googleInter: 'Inter',
  PresentationTextStyle.googleMontserrat: 'Montserrat',
  PresentationTextStyle.googlePoppins: 'Poppins',
  PresentationTextStyle.googleNotoSansJP: 'Noto Sans JP',
  PresentationTextStyle.googleLato: 'Lato',
  PresentationTextStyle.googleArimo: 'Arimo',
  PresentationTextStyle.googleRobotoCondensed: 'Roboto Condensed',
  PresentationTextStyle.googleRobotoMono: 'Roboto Mono',
  PresentationTextStyle.googleNotoSans: 'Noto Sans',
  PresentationTextStyle.googleOswald: 'Oswald',
  PresentationTextStyle.googleDMSans: 'DM Sans',
  PresentationTextStyle.googleNunito: 'Nunito',
  PresentationTextStyle.googleRaleway: 'Raleway',
  PresentationTextStyle.googleNunitoSans: 'Nunito Sans',
  PresentationTextStyle.googlePlayfairDisplay: 'Playfair Display',
  PresentationTextStyle.googleRobotoSlab: 'Roboto Slab',
  PresentationTextStyle.googleRubik: 'Rubik',
  PresentationTextStyle.googleArchivoBlack: 'Archivo Black',
  PresentationTextStyle.googleUbuntu: 'Ubuntu',
  PresentationTextStyle.googleNotoSansKR: 'Noto Sans KR',
  PresentationTextStyle.googleKanit: 'Kanit',
  PresentationTextStyle.googleManrope: 'Manrope',
  PresentationTextStyle.googleOutfit: 'Outfit',
  PresentationTextStyle.googleMerriweather: 'Merriweather',
  PresentationTextStyle.googleWorkSans: 'Work Sans',
  PresentationTextStyle.googleLora: 'Lora',
  PresentationTextStyle.googleNotoSansTC: 'Noto Sans TC',
  PresentationTextStyle.googlePrompt: 'Prompt',
};

String? presentationGoogleFontFamily(PresentationTextStyle style) =>
    popularGoogleFontFamilies[style];

/// Editör kontrollerinde ve Flutter tarafındaki font önizlemelerinde
/// kullanılacak gerçek font ailesi. HTML sahnesindeki CSS aileleriyle aynıdır.
String? presentationFontFamily(PresentationTextStyle style) {
  final googleFamily = presentationGoogleFontFamily(style);
  if (googleFamily != null) return googleFamily;
  return switch (style) {
    PresentationTextStyle.standard => null,
    PresentationTextStyle.openOswald => 'Oswald',
    PresentationTextStyle.openPlayfairDisplay => 'Playfair Display',
    PresentationTextStyle.openBebasNeue => 'Bebas Neue',
    PresentationTextStyle.openBungee => 'Bungee',
    PresentationTextStyle.openCaveat => 'Caveat',
    PresentationTextStyle.openUnbounded => 'Unbounded',
    PresentationTextStyle.klasikTinos => 'Tinos',
    PresentationTextStyle.klasikArimo => 'Arimo',
    PresentationTextStyle.klasikCousine => 'Cousine',
    PresentationTextStyle.klasikCarlito => 'Carlito',
    PresentationTextStyle.klasikCaladea => 'Caladea',
    PresentationTextStyle.klasikEBGaramond => 'EB Garamond',
    PresentationTextStyle.klasikLibreBaskerville => 'Libre Baskerville',
    PresentationTextStyle.klasikAlegreya => 'Alegreya',
    PresentationTextStyle.klasikPTSerif => 'PT Serif',
    PresentationTextStyle.klasikMerriweather => 'Merriweather',
    PresentationTextStyle.klasikLora => 'Lora',
    PresentationTextStyle.klasikGreatVibes => 'Great Vibes',
    PresentationTextStyle.klasikDancingScript => 'Dancing Script',
    PresentationTextStyle.klasikPacifico => 'Pacifico',
    PresentationTextStyle.klasikLobster => 'Lobster',
    _ => null,
  };
}

/// Görsel efekt presetleri font ailesi değildir; yalnızca eski projelerin ve
/// otomatik şablonların geriye dönük uyumluluğu için modelde tutulurlar.
bool isPresentationThemeTextStyle(PresentationTextStyle style) {
  return switch (style) {
    PresentationTextStyle.bilimDramatik ||
    PresentationTextStyle.bilimTemiz ||
    PresentationTextStyle.bilimDeneysel ||
    PresentationTextStyle.gunesDramatik ||
    PresentationTextStyle.gunesTemiz ||
    PresentationTextStyle.gunesDeneysel ||
    PresentationTextStyle.uzayDramatik ||
    PresentationTextStyle.uzayTemiz ||
    PresentationTextStyle.uzayDeneysel ||
    PresentationTextStyle.optikDramatik ||
    PresentationTextStyle.optikTemiz ||
    PresentationTextStyle.optikDeneysel ||
    PresentationTextStyle.fizikDramatik ||
    PresentationTextStyle.fizikTemiz ||
    PresentationTextStyle.fizikDeneysel ||
    PresentationTextStyle.teknolojiDramatik ||
    PresentationTextStyle.teknolojiTemiz ||
    PresentationTextStyle.teknolojiDeneysel =>
      true,
    _ => false,
  };
}

final List<PresentationTextStyle> presentationFontLibraryStyles =
    PresentationTextStyle.values
        .where((style) => !isPresentationThemeTextStyle(style))
        .toList(growable: false);

String? presentationGoogleFontClass(PresentationTextStyle style) {
  final family = popularGoogleFontFamilies[style];
  if (family == null) return null;
  return 'text-style-google-${family.toLowerCase().replaceAll(' ', '-')}';
}

enum PresentationTextAnimation {
  none,
  bilimDramatik,
  bilimTemiz,
  bilimDeneysel,
  gunesDramatik,
  gunesTemiz,
  gunesDeneysel,
  uzayDramatik,
  uzayTemiz,
  uzayDeneysel,
  optikDramatik,
  optikTemiz,
  optikDeneysel,
  fizikDramatik,
  fizikTemiz,
  fizikDeneysel,
  teknolojiDramatik,
  teknolojiTemiz,
  teknolojiDeneysel,
  metalikParlama,
  yavasBelirme,
  daktilo,
  bulaniktanNet,
  ucBoyutluDonus,
  ziplayarakGiris,
  isikTaramasi,
  perdeAcilisi,
  sinematikYaklasma,
  yercekimsizSuzulme,
  neonKontur,
  golgeEkstruzyonu,
  siviDalga,
  kesikSinyal,
  holografikDalga,
}

enum PresentationBackgroundKind {
  science,
  biology,
  natureEcology,
  physics,
  solarEnergyScene,
  lawJustice,
  climateWeather,
  businessFinance,
  chemistry,
  mathematics,
  musicSound,
  optics,
  healthMedicine,
  artDesign,
  travelGeography,
  sportsMovement,
  historyArchaeology,
  technology,
  spaceTechnology,
  lightCorporate,
  lightEducation,
  lightNature,
  lightTechnology,
  lightCreative,
  lightWarm,
}

enum PresentationTransitionKind {
  none,
  smooth,
  fade,
  slide,
  zoom,
  convex,
  concave,
  wipe,
  split,
  reveal,
  cover,
  uncover,
  flip,
  cube3d,
  morph,
  parallax,
  elastic,
  glitch,
  prism,
  radialWipe,
  rotateZoom,
}

@immutable
class PresentationEffectSettings {
  const PresentationEffectSettings({
    this.transitionKind = PresentationTransitionKind.slide,
    this.transitionDurationMs = 420,
    this.zoomEnabled = false,
    this.zoomScale = 1.55,
    this.reducedMotion = false,
    this.autoPlayIntervalSec = 0,
    this.loop = false,
    this.showProgressBar = true,
    this.enableLaserPointer = false,
    this.enableSoundEffects = false,
    this.aspectRatio = '16:9',
    this.customWidth = 1920,
    this.customHeight = 1080,
  });

  final PresentationTransitionKind transitionKind;
  final int transitionDurationMs;
  final bool zoomEnabled;
  final double zoomScale;
  final bool reducedMotion;
  final int autoPlayIntervalSec;
  final bool loop;
  final bool showProgressBar;
  final bool enableLaserPointer;
  final bool enableSoundEffects;
  final String aspectRatio;
  final double customWidth;
  final double customHeight;

  double get calculatedAspectRatio {
    if (aspectRatio == 'custom' && customHeight > 0 && customWidth > 0) {
      return (customWidth / customHeight).clamp(0.2, 5.0);
    }
    switch (aspectRatio) {
      case '9:16':
        return 9 / 16;
      case '4:3':
        return 4 / 3;
      case '1:1':
        return 1 / 1;
      case '16:9':
      default:
        return 16 / 9;
    }
  }

  bool get isPortrait => calculatedAspectRatio < 1.0;

  String get stageDimensionLabel {
    switch (aspectRatio) {
      case '9:16':
        return 'Mobil Dikey (9:16)';
      case '4:3':
        return 'Klasik (4:3)';
      case '1:1':
        return 'Kare (1:1)';
      case 'custom':
        return 'Özel (${customWidth.toInt()}x${customHeight.toInt()})';
      case '16:9':
      default:
        return 'Standart (16:9)';
    }
  }

  PresentationEffectSettings copyWith({
    PresentationTransitionKind? transitionKind,
    int? transitionDurationMs,
    bool? zoomEnabled,
    double? zoomScale,
    bool? reducedMotion,
    int? autoPlayIntervalSec,
    bool? loop,
    bool? showProgressBar,
    bool? enableLaserPointer,
    bool? enableSoundEffects,
    String? aspectRatio,
    double? customWidth,
    double? customHeight,
  }) {
    return PresentationEffectSettings(
      transitionKind: transitionKind ?? this.transitionKind,
      transitionDurationMs: transitionDurationMs ?? this.transitionDurationMs,
      zoomEnabled: zoomEnabled ?? this.zoomEnabled,
      zoomScale: zoomScale ?? this.zoomScale,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      autoPlayIntervalSec: autoPlayIntervalSec ?? this.autoPlayIntervalSec,
      loop: loop ?? this.loop,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      enableLaserPointer: enableLaserPointer ?? this.enableLaserPointer,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
    );
  }
}

@immutable
class PresentationTextBlock {
  const PresentationTextBlock({
    required this.id,
    required this.text,
    required this.position,
    required this.fontSize,
    required this.type,
    required this.widthFactor,
    this.heightFactor,
    this.textStyle = PresentationTextStyle.standard,
    this.textAnimation = PresentationTextAnimation.none,
    this.textColorHex,
    this.glowIntensity = 1,
    this.revealStep = 0,
    this.hotspotTargetPageId,
    this.textBold = false,
    this.textItalic = false,
    this.textUnderline = false,
    this.textAlign = PresentationTextAlign.left,
  });

  final String id;
  final String text;
  final Offset position;
  final double fontSize;
  final PresentationTextType type;
  final double widthFactor;
  final double? heightFactor;
  final PresentationTextStyle textStyle;
  final PresentationTextAnimation textAnimation;
  final String? textColorHex;
  final double glowIntensity;
  final int revealStep;
  final String? hotspotTargetPageId;
  final bool textBold;
  final bool textItalic;
  final bool textUnderline;
  final PresentationTextAlign textAlign;

  PresentationTextBlock copyWith({
    String? id,
    String? text,
    Offset? position,
    double? fontSize,
    PresentationTextType? type,
    double? widthFactor,
    Object? heightFactor = _copySentinel,
    PresentationTextStyle? textStyle,
    PresentationTextAnimation? textAnimation,
    Object? textColorHex = _copySentinel,
    double? glowIntensity,
    int? revealStep,
    Object? hotspotTargetPageId = _copySentinel,
    bool? textBold,
    bool? textItalic,
    bool? textUnderline,
    PresentationTextAlign? textAlign,
  }) {
    return PresentationTextBlock(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      type: type ?? this.type,
      widthFactor: widthFactor ?? this.widthFactor,
      heightFactor: identical(heightFactor, _copySentinel)
          ? this.heightFactor
          : heightFactor as double?,
      textStyle: textStyle ?? this.textStyle,
      textAnimation: textAnimation ?? this.textAnimation,
      textColorHex: identical(textColorHex, _copySentinel)
          ? this.textColorHex
          : textColorHex as String?,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      revealStep: revealStep ?? this.revealStep,
      hotspotTargetPageId: identical(hotspotTargetPageId, _copySentinel)
          ? this.hotspotTargetPageId
          : hotspotTargetPageId as String?,
      textBold: textBold ?? this.textBold,
      textItalic: textItalic ?? this.textItalic,
      textUnderline: textUnderline ?? this.textUnderline,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}

@immutable
class PresentationComponentBlock {
  const PresentationComponentBlock({
    required this.id,
    this.kind = PresentationComponentKind.edebiyat01,
    this.modelAssetId,
    this.imageAssetId,
    this.imageAspectRatio,
    this.modelAnimationEnabled = true,
    this.modelAutoRotate = false,
    this.modelRotationSpeed = 30,
    this.modelOrbitEnabled = false,
    this.modelOrbitTheta = 0,
    this.modelOrbitPhi = 75,
    required this.position,
    required this.size,
    this.revealStep = 0,
    this.hotspotTargetPageId,
  });

  final String id;
  final PresentationComponentKind kind;
  final String? modelAssetId;
  final String? imageAssetId;
  final double? imageAspectRatio;
  final bool modelAnimationEnabled;
  final bool modelAutoRotate;
  final double modelRotationSpeed;
  final bool modelOrbitEnabled;
  final double modelOrbitTheta;
  final double modelOrbitPhi;
  final Offset position;
  final Size size;
  final int revealStep;
  final String? hotspotTargetPageId;

  PresentationComponentBlock copyWith({
    String? id,
    PresentationComponentKind? kind,
    Object? modelAssetId = _copySentinel,
    Object? imageAssetId = _copySentinel,
    Object? imageAspectRatio = _copySentinel,
    bool? modelAnimationEnabled,
    bool? modelAutoRotate,
    double? modelRotationSpeed,
    bool? modelOrbitEnabled,
    double? modelOrbitTheta,
    double? modelOrbitPhi,
    Offset? position,
    Size? size,
    int? revealStep,
    Object? hotspotTargetPageId = _copySentinel,
  }) {
    return PresentationComponentBlock(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      modelAssetId: identical(modelAssetId, _copySentinel)
          ? this.modelAssetId
          : modelAssetId as String?,
      imageAssetId: identical(imageAssetId, _copySentinel)
          ? this.imageAssetId
          : imageAssetId as String?,
      imageAspectRatio: identical(imageAspectRatio, _copySentinel)
          ? this.imageAspectRatio
          : imageAspectRatio as double?,
      modelAnimationEnabled:
          modelAnimationEnabled ?? this.modelAnimationEnabled,
      modelAutoRotate: modelAutoRotate ?? this.modelAutoRotate,
      modelRotationSpeed: modelRotationSpeed ?? this.modelRotationSpeed,
      modelOrbitEnabled: modelOrbitEnabled ?? this.modelOrbitEnabled,
      modelOrbitTheta: modelOrbitTheta ?? this.modelOrbitTheta,
      modelOrbitPhi: modelOrbitPhi ?? this.modelOrbitPhi,
      position: position ?? this.position,
      size: size ?? this.size,
      revealStep: revealStep ?? this.revealStep,
      hotspotTargetPageId: identical(hotspotTargetPageId, _copySentinel)
          ? this.hotspotTargetPageId
          : hotspotTargetPageId as String?,
    );
  }
}

@immutable
class PresentationPage {
  const PresentationPage({
    required this.id,
    required this.textBlocks,
    this.componentBlocks = const <PresentationComponentBlock>[],
    this.backgroundKind = PresentationBackgroundKind.science,
    this.speakerNotes = '',
  });

  final String id;
  final List<PresentationTextBlock> textBlocks;
  final List<PresentationComponentBlock> componentBlocks;
  final PresentationBackgroundKind backgroundKind;
  final String speakerNotes;

  PresentationPage copyWith({
    String? id,
    List<PresentationTextBlock>? textBlocks,
    List<PresentationComponentBlock>? componentBlocks,
    PresentationBackgroundKind? backgroundKind,
    String? speakerNotes,
  }) {
    return PresentationPage(
      id: id ?? this.id,
      textBlocks: textBlocks ?? this.textBlocks,
      componentBlocks: componentBlocks ?? this.componentBlocks,
      backgroundKind: backgroundKind ?? this.backgroundKind,
      speakerNotes: speakerNotes ?? this.speakerNotes,
    );
  }

  PresentationTextBlock? findTextBlock(String? textBlockId) {
    if (textBlockId == null) {
      return null;
    }

    for (final block in textBlocks) {
      if (block.id == textBlockId) {
        return block;
      }
    }

    return null;
  }

  PresentationComponentBlock? findComponentBlock(String? componentBlockId) {
    if (componentBlockId == null) {
      return null;
    }

    for (final block in componentBlocks) {
      if (block.id == componentBlockId) {
        return block;
      }
    }

    return null;
  }
}

const Object _copySentinel = Object();

String presentationTransitionLabel(PresentationTransitionKind kind) {
  switch (kind) {
    case PresentationTransitionKind.none:
      return 'Yok';
    case PresentationTransitionKind.smooth:
      return 'Yumuşak Geçiş';
    case PresentationTransitionKind.fade:
      return 'Fade';
    case PresentationTransitionKind.slide:
      return 'İtme';
    case PresentationTransitionKind.zoom:
      return 'Zoom';
    case PresentationTransitionKind.convex:
      return 'Convex';
    case PresentationTransitionKind.concave:
      return 'Concave';
    case PresentationTransitionKind.wipe:
      return 'Silme';
    case PresentationTransitionKind.split:
      return 'Bölme';
    case PresentationTransitionKind.reveal:
      return 'Açığa Çıkarma';
    case PresentationTransitionKind.cover:
      return 'Kaplama';
    case PresentationTransitionKind.uncover:
      return 'Örtüyü Kaldırma';
    case PresentationTransitionKind.flip:
      return 'Çevirme';
    case PresentationTransitionKind.cube3d:
      return '3D Küp';
    case PresentationTransitionKind.morph:
      return 'Cam Blur Morph';
    case PresentationTransitionKind.parallax:
      return 'Parallaks Derinlik';
    case PresentationTransitionKind.elastic:
      return 'Esnek Sıçrama';
    case PresentationTransitionKind.glitch:
      return 'Siber Titreşim';
    case PresentationTransitionKind.prism:
      return 'Prizma Işığı';
    case PresentationTransitionKind.radialWipe:
      return 'Dairesel Süpürme';
    case PresentationTransitionKind.rotateZoom:
      return '3D Dönel Yakınlaşma';
  }
}

String presentationTransitionSubtitle(PresentationTransitionKind kind) {
  switch (kind) {
    case PresentationTransitionKind.none:
      return 'Kesintisiz sayfa degisimi';
    case PresentationTransitionKind.smooth:
      return 'Aynı 3D modeli ve sahneyi akıcı biçimde dönüştürür';
    case PresentationTransitionKind.fade:
      return 'Yumusak opaklik gecisi';
    case PresentationTransitionKind.slide:
      return 'Yeni slayt eskisini yatay olarak iter';
    case PresentationTransitionKind.zoom:
      return 'Sahneye yakinlasarak giris';
    case PresentationTransitionKind.convex:
      return 'Disa dogru 3B kart hissi';
    case PresentationTransitionKind.concave:
      return 'Ice dogru 3B kart hissi';
    case PresentationTransitionKind.wipe:
      return 'Slaytı soldan sağa doğru açar';
    case PresentationTransitionKind.split:
      return 'Slaytı merkezden iki yana doğru açar';
    case PresentationTransitionKind.reveal:
      return 'Yeni slaytı alttan akıcı biçimde gösterir';
    case PresentationTransitionKind.cover:
      return 'Yeni slayt eskisinin üzerini kaplar';
    case PresentationTransitionKind.uncover:
      return 'Eski slayt çekilerek yenisini ortaya çıkarır';
    case PresentationTransitionKind.flip:
      return 'Slaytı 3B kart gibi çevirir';
    case PresentationTransitionKind.cube3d:
      return 'Slaytları 3B küp yüzeyi gibi döndürür';
    case PresentationTransitionKind.morph:
      return 'Bulanıklaşan cam efektiyle odak değiştirir';
    case PresentationTransitionKind.parallax:
      return 'Derinlikli katman kayması yaratır';
    case PresentationTransitionKind.elastic:
      return 'Yay esnekliğinde sıçrayışlı geçiş yapar';
    case PresentationTransitionKind.glitch:
      return 'Dijital siber parazit ve renk kırılması';
    case PresentationTransitionKind.prism:
      return 'Prizmatik parlak ışık hüzmesi geçişi';
    case PresentationTransitionKind.radialWipe:
      return 'Merkezden dışa dairesel açılış efekti';
    case PresentationTransitionKind.rotateZoom:
      return '3B eksende dönerek ekrana yaklaşır';
  }
}

IconData presentationTransitionIcon(PresentationTransitionKind kind) {
  switch (kind) {
    case PresentationTransitionKind.none:
      return Icons.block_rounded;
    case PresentationTransitionKind.smooth:
      return Icons.motion_photos_on_rounded;
    case PresentationTransitionKind.fade:
      return Icons.blur_on_rounded;
    case PresentationTransitionKind.slide:
      return Icons.view_carousel_rounded;
    case PresentationTransitionKind.zoom:
      return Icons.center_focus_strong_rounded;
    case PresentationTransitionKind.convex:
      return Icons.view_array_rounded;
    case PresentationTransitionKind.concave:
      return Icons.crop_free_rounded;
    case PresentationTransitionKind.wipe:
      return Icons.gradient_rounded;
    case PresentationTransitionKind.split:
      return Icons.splitscreen_rounded;
    case PresentationTransitionKind.reveal:
      return Icons.unfold_more_rounded;
    case PresentationTransitionKind.cover:
      return Icons.layers_rounded;
    case PresentationTransitionKind.uncover:
      return Icons.layers_clear_rounded;
    case PresentationTransitionKind.flip:
      return Icons.flip_camera_android_rounded;
    case PresentationTransitionKind.cube3d:
      return Icons.view_in_ar_rounded;
    case PresentationTransitionKind.morph:
      return Icons.transform_rounded;
    case PresentationTransitionKind.parallax:
      return Icons.filter_hdr_rounded;
    case PresentationTransitionKind.elastic:
      return Icons.polyline_rounded;
    case PresentationTransitionKind.glitch:
      return Icons.sensors_rounded;
    case PresentationTransitionKind.prism:
      return Icons.style_rounded;
    case PresentationTransitionKind.radialWipe:
      return Icons.radio_button_checked_rounded;
    case PresentationTransitionKind.rotateZoom:
      return Icons.autorenew_rounded;
  }
}

@immutable
class PresentationBackgroundDefinition {
  const PresentationBackgroundDefinition({
    required this.kind,
    required this.label,
    required this.category,
    required this.tags,
    required this.previewColors,
    required this.icon,
  });

  final PresentationBackgroundKind kind;
  final String label;
  final String category;
  final List<String> tags;
  final List<Color> previewColors;
  final IconData icon;
}

const List<PresentationBackgroundDefinition> presentationBackgroundLibrary =
    <PresentationBackgroundDefinition>[
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.science,
      label: 'Bilim',
      category: 'Bilim',
      tags: <String>[
        'bilim',
        'bilimsel yöntem',
        'bilimsel araştırma',
        'deney',
        'laboratuvar',
        'mikroskop',
        'hipotez',
        'keşif',
        'bilim insanı',
        'atom',
        'science',
        'research',
        'experiment'
      ],
      previewColors: <Color>[
        Color(0xFF0B1026),
        Color(0xFF162A46),
        Color(0xFF54D6FF)
      ],
      icon: Icons.science_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.biology,
      label: 'Biyoloji',
      category: 'Biyoloji',
      tags: <String>[
        'biyoloji',
        'hücre',
        'dna',
        'genetik',
        'canlı organizma',
        'mikroorganizma',
        'protein',
        'enzim',
        'evrim',
        'biology',
        'cell',
        'genetics'
      ],
      previewColors: <Color>[
        Color(0xFF0D1B1E),
        Color(0xFF123C34),
        Color(0xFF06D6A0)
      ],
      icon: Icons.biotech_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.natureEcology,
      label: 'Doğa ve Ekoloji',
      category: 'Doğa',
      tags: <String>[
        'doğa',
        'ekoloji',
        'çevre',
        'orman',
        'ekosistem',
        'bitki örtüsü',
        'sürdürülebilirlik',
        'biyoçeşitlilik',
        'doğal yaşam',
        'nature',
        'ecology',
        'environment'
      ],
      previewColors: <Color>[
        Color(0xFF0E1F17),
        Color(0xFF234D36),
        Color(0xFF74C69D)
      ],
      icon: Icons.eco_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.physics,
      label: 'Fizik',
      category: 'Fizik',
      tags: <String>[
        'fizik',
        'mekanik',
        'kuvvet',
        'hareket yasaları',
        'kinetik enerji',
        'potansiyel enerji',
        'elektrik',
        'manyetizma',
        'termodinamik',
        'physics',
        'mechanics'
      ],
      previewColors: <Color>[
        Color(0xFF0A0B11),
        Color(0xFF14161F),
        Color(0xFF7C90B0)
      ],
      icon: Icons.science_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.solarEnergyScene,
      label: 'Güneş Enerjisi',
      category: 'Enerji',
      tags: <String>[
        'güneş',
        'güneş enerjisi',
        'solar',
        'güneş paneli',
        'fotovoltaik',
        'yenilenebilir enerji',
        'güneş ışığı',
        'güneş santrali',
        'temiz enerji',
        'sun',
        'solar energy'
      ],
      previewColors: <Color>[
        Color(0xFF1A1A2E),
        Color(0xFF3B3159),
        Color(0xFFFFD166)
      ],
      icon: Icons.solar_power_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.lawJustice,
      label: 'Hukuk ve Adalet',
      category: 'Hukuk',
      tags: <String>[
        'hukuk',
        'adalet',
        'mahkeme',
        'yasa',
        'anayasa',
        'insan hakları',
        'avukat',
        'hakim',
        'savcı',
        'dava',
        'law',
        'justice'
      ],
      previewColors: <Color>[
        Color(0xFF101820),
        Color(0xFF263746),
        Color(0xFFD4AF37)
      ],
      icon: Icons.balance_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.climateWeather,
      label: 'İklim ve Hava',
      category: 'İklim',
      tags: <String>[
        'iklim',
        'hava durumu',
        'meteoroloji',
        'atmosfer',
        'sıcaklık',
        'yağış',
        'fırtına',
        'bulut',
        'iklim değişikliği',
        'climate',
        'weather'
      ],
      previewColors: <Color>[
        Color(0xFF1B2430),
        Color(0xFF355C7D),
        Color(0xFF6DD5FA)
      ],
      icon: Icons.cloud_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.businessFinance,
      label: 'İş ve Finans',
      category: 'Finans',
      tags: <String>[
        'iş dünyası',
        'finans',
        'ekonomi',
        'şirket',
        'pazar',
        'yatırım',
        'bütçe',
        'girişimcilik',
        'ticaret',
        'borsa',
        'business',
        'finance'
      ],
      previewColors: <Color>[
        Color(0xFF05070C),
        Color(0xFF15253A),
        Color(0xFF2EC4B6)
      ],
      icon: Icons.trending_up_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.chemistry,
      label: 'Kimya',
      category: 'Kimya',
      tags: <String>[
        'kimya',
        'kimyasal reaksiyon',
        'molekül',
        'atom',
        'element',
        'bileşik',
        'periyodik tablo',
        'asit',
        'baz',
        'laboratuvar kimyası',
        'chemistry',
        'reaction'
      ],
      previewColors: <Color>[
        Color(0xFF05070A),
        Color(0xFF13302B),
        Color(0xFF62D2A2)
      ],
      icon: Icons.science_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.mathematics,
      label: 'Matematik',
      category: 'Matematik',
      tags: <String>[
        'matematik',
        'geometri',
        'denklem',
        'sayı',
        'istatistik',
        'cebir',
        'matematiksel grafik',
        'olasılık',
        'fonksiyon',
        'hesaplama',
        'math',
        'mathematics'
      ],
      previewColors: <Color>[
        Color(0xFF05060A),
        Color(0xFF19142C),
        Color(0xFF9B5DE5)
      ],
      icon: Icons.functions_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.musicSound,
      label: 'Müzik ve Ses',
      category: 'Müzik',
      tags: <String>[
        'müzik',
        'nota',
        'ritim',
        'melodi',
        'akustik',
        'enstrüman',
        'müzik aleti',
        'şarkı',
        'beste',
        'music',
        'sound'
      ],
      previewColors: <Color>[
        Color(0xFF150E27),
        Color(0xFF39205A),
        Color(0xFFF15BB5)
      ],
      icon: Icons.graphic_eq_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.optics,
      label: 'Optik',
      category: 'Optik',
      tags: <String>[
        'optik',
        'ışık fiziği',
        'ayna',
        'mercek',
        'yansıma',
        'kırılma',
        'foton',
        'lazer',
        'prizma',
        'optics',
        'lens'
      ],
      previewColors: <Color>[
        Color(0xFF10121A),
        Color(0xFF20283D),
        Color(0xFF7EFFF5)
      ],
      icon: Icons.blur_on_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.healthMedicine,
      label: 'Sağlık ve Tıp',
      category: 'Sağlık',
      tags: <String>[
        'sağlık',
        'tıp',
        'doktor',
        'hastane',
        'tedavi',
        'anatomi',
        'hastalık',
        'ilaç',
        'cerrahi',
        'sağlık hizmeti',
        'health',
        'medicine'
      ],
      previewColors: <Color>[
        Color(0xFF0A1F26),
        Color(0xFF164B57),
        Color(0xFF2EC4B6)
      ],
      icon: Icons.medical_services_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.artDesign,
      label: 'Sanat ve Tasarım',
      category: 'Sanat',
      tags: <String>[
        'sanat',
        'tasarım',
        'resim',
        'yaratıcılık',
        'renk teorisi',
        'görsel sanatlar',
        'illüstrasyon',
        'grafik tasarım',
        'art',
        'design'
      ],
      previewColors: <Color>[
        Color(0xFF1A0F1F),
        Color(0xFF4B2142),
        Color(0xFFFF70A6)
      ],
      icon: Icons.palette_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.travelGeography,
      label: 'Seyahat ve Coğrafya',
      category: 'Coğrafya',
      tags: <String>[
        'seyahat',
        'coğrafya',
        'harita',
        'ülke',
        'destinasyon',
        'turizm',
        'rota',
        'gezi',
        'coğrafi bölge',
        'travel',
        'geography'
      ],
      previewColors: <Color>[
        Color(0xFF071A24),
        Color(0xFF174B5F),
        Color(0xFF4CC9F0)
      ],
      icon: Icons.public_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.sportsMovement,
      label: 'Spor ve Hareket',
      category: 'Spor',
      tags: <String>[
        'spor',
        'egzersiz',
        'antrenman',
        'fitness',
        'yarış',
        'spor takımı',
        'müsabaka',
        'atlet',
        'sports',
        'athlete'
      ],
      previewColors: <Color>[
        Color(0xFF0C1320),
        Color(0xFF243B55),
        Color(0xFFFF595E)
      ],
      icon: Icons.sports_basketball_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.historyArchaeology,
      label: 'Tarih ve Arkeoloji',
      category: 'Tarih',
      tags: <String>[
        'tarih',
        'arkeoloji',
        'antik',
        'medeniyet',
        'kazı',
        'tarihsel dönem',
        'müze',
        'antik uygarlık',
        'tarihi eser',
        'history',
        'archaeology'
      ],
      previewColors: <Color>[
        Color(0xFF1A120B),
        Color(0xFF4A3320),
        Color(0xFFD4A373)
      ],
      icon: Icons.history_edu_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.technology,
      label: 'Teknoloji',
      category: 'Teknoloji',
      tags: <String>[
        'teknoloji',
        'yapay zeka',
        'yazılım',
        'bilgisayar',
        'işlemci',
        'veritabanı',
        'robot',
        'veri bilimi',
        'dijital',
        'siber güvenlik',
        'programlama',
        'internet',
        'technology',
        'software'
      ],
      previewColors: <Color>[
        Color(0xFF0A0A0F),
        Color(0xFF14213D),
        Color(0xFF00E5FF)
      ],
      icon: Icons.memory_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.spaceTechnology,
      label: 'Uzay Teknolojileri',
      category: 'Uzay',
      tags: <String>[
        'uzay',
        'roket',
        'uydu',
        'astronomi',
        'gezegen',
        'yörünge',
        'galaksi',
        'yıldız',
        'teleskop',
        'astronot',
        'uzay istasyonu',
        'space',
        'satellite'
      ],
      previewColors: <Color>[
        Color(0xFF020111),
        Color(0xFF101A40),
        Color(0xFF6C63FF)
      ],
      icon: Icons.rocket_launch_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.lightCorporate,
      label: 'Açık Kurumsal',
      category: 'Açık · Kurumsal',
      tags: <String>[
        'açık kurumsal',
        'kurumsal sunum',
        'iş toplantısı',
        'şirket tanıtımı',
        'proje özeti',
        'rapor',
        'strateji',
        'minimal mavi',
        'light corporate',
        'business presentation'
      ],
      previewColors: <Color>[
        Color(0xFFF8FBFF),
        Color(0xFFE7F0FF),
        Color(0xFF4F7DF3)
      ],
      icon: Icons.business_center_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.lightEducation,
      label: 'Açık Eğitim',
      category: 'Açık · Eğitim',
      tags: <String>[
        'açık eğitim',
        'ders sunumu',
        'okul',
        'öğretmen',
        'öğrenci',
        'eğitim içeriği',
        'akademik ders',
        'not kağıdı',
        'light education',
        'classroom'
      ],
      previewColors: <Color>[
        Color(0xFFFFFEF8),
        Color(0xFFFFF2C7),
        Color(0xFFF2B84B)
      ],
      icon: Icons.school_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.lightNature,
      label: 'Açık Doğa',
      category: 'Açık · Doğa',
      tags: <String>[
        'açık doğa',
        'organik tasarım',
        'yeşil yaşam',
        'çevre projesi',
        'sürdürülebilir proje',
        'bitkisel',
        'pastel yeşil',
        'doğal ürün',
        'light nature',
        'organic'
      ],
      previewColors: <Color>[
        Color(0xFFF7FFF9),
        Color(0xFFDDF5E6),
        Color(0xFF45A675)
      ],
      icon: Icons.spa_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.lightTechnology,
      label: 'Açık Teknoloji',
      category: 'Açık · Teknoloji',
      tags: <String>[
        'açık teknoloji',
        'temiz teknoloji',
        'yazılım sunumu',
        'ürün tanıtımı',
        'dijital proje',
        'startup sunumu',
        'veri ağı',
        'arayüz',
        'light technology',
        'tech pitch'
      ],
      previewColors: <Color>[
        Color(0xFFF7FCFF),
        Color(0xFFDDF5FA),
        Color(0xFF22A6B3)
      ],
      icon: Icons.hub_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.lightCreative,
      label: 'Açık Yaratıcı',
      category: 'Açık · Yaratıcı',
      tags: <String>[
        'açık yaratıcı',
        'yaratıcı sunum',
        'portfolyo',
        'tasarım projesi',
        'renkli pastel',
        'ajans sunumu',
        'fikir geliştirme',
        'modern sanat',
        'light creative',
        'creative portfolio'
      ],
      previewColors: <Color>[
        Color(0xFFFFFAFD),
        Color(0xFFF6E6FF),
        Color(0xFFB15CDE)
      ],
      icon: Icons.auto_awesome_rounded),
  PresentationBackgroundDefinition(
      kind: PresentationBackgroundKind.lightWarm,
      label: 'Açık Sıcak',
      category: 'Açık · Hikâye',
      tags: <String>[
        'açık sıcak',
        'hikaye anlatımı',
        'kişisel sunum',
        'sosyal proje',
        'kültür sunumu',
        'etkinlik tanıtımı',
        'pastel turuncu',
        'samimi tasarım',
        'light warm',
        'storytelling'
      ],
      previewColors: <Color>[
        Color(0xFFFFFBF5),
        Color(0xFFFFE6D5),
        Color(0xFFE9855B)
      ],
      icon: Icons.wb_sunny_rounded),
];

PresentationBackgroundDefinition? presentationBackgroundDefinition(
  PresentationBackgroundKind kind,
) {
  for (final definition in presentationBackgroundLibrary) {
    if (definition.kind == kind) return definition;
  }
  return null;
}

List<String> presentationBackgroundTags(PresentationBackgroundKind kind) =>
    presentationBackgroundDefinition(kind)?.tags ?? const <String>[];

bool presentationBackgroundIsDark(PresentationBackgroundKind kind) {
  switch (kind) {
    case PresentationBackgroundKind.lightCorporate:
    case PresentationBackgroundKind.lightEducation:
    case PresentationBackgroundKind.lightNature:
    case PresentationBackgroundKind.lightTechnology:
    case PresentationBackgroundKind.lightCreative:
    case PresentationBackgroundKind.lightWarm:
      return false;
    default:
      return true;
  }
}

String presentationBackgroundLabel(PresentationBackgroundKind kind) =>
    presentationBackgroundDefinition(kind)!.label;

String presentationBackgroundSubtitle(PresentationBackgroundKind kind) {
  final definition = presentationBackgroundDefinition(kind)!;
  return '${definition.category} etiketleriyle eşleşen çevrimdışı HTML sahnesi';
}

String presentationBackgroundCategory(PresentationBackgroundKind kind) =>
    presentationBackgroundDefinition(kind)!.category;

IconData presentationBackgroundIcon(PresentationBackgroundKind kind) =>
    presentationBackgroundDefinition(kind)!.icon;

List<Color> presentationBackgroundPreviewColors(
  PresentationBackgroundKind kind,
) =>
    presentationBackgroundDefinition(kind)!.previewColors;
