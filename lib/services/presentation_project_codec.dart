import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/slide_model.dart';

@immutable
class PresentationProject {
  const PresentationProject({
    required this.pages,
    required this.effectSettings,
  });

  final List<PresentationPage> pages;
  final PresentationEffectSettings effectSettings;
}

class PresentationProjectCodec {
  const PresentationProjectCodec._();

  static const int version = 1;

  static String encodeProject({
    required List<PresentationPage> pages,
    required PresentationEffectSettings effectSettings,
  }) {
    final data = <String, Object?>{
      'format': 'sutol.presentation',
      'version': version,
      'effectSettings': _effectSettingsToJson(effectSettings),
      'pages': pages.map(_pageToJson).toList(growable: false),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static PresentationProject decodeProject(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Gecersiz Sutols proje dosyasi.');
    }

    final pagesJson = decoded['pages'];
    if (pagesJson is! List) {
      throw const FormatException('Proje dosyasinda sayfa listesi yok.');
    }

    final pages = pagesJson
        .whereType<Map<String, Object?>>()
        .map(_pageFromJson)
        .toList(growable: false);
    if (pages.isEmpty) {
      throw const FormatException('Proje dosyasi bos.');
    }

    return PresentationProject(
      pages: pages,
      effectSettings: decoded['effectSettings'] is Map<String, Object?>
          ? _effectSettingsFromJson(
              decoded['effectSettings']! as Map<String, Object?>,
            )
          : const PresentationEffectSettings(),
    );
  }

  static Map<String, Object?> _pageToJson(PresentationPage page) {
    return <String, Object?>{
      'id': page.id,
      'backgroundKind': page.backgroundKind.name,
      'speakerNotes': page.speakerNotes,
      'textBlocks': page.textBlocks.map(_textBlockToJson).toList(),
      'componentBlocks':
          page.componentBlocks.map(_componentBlockToJson).toList(),
    };
  }

  static PresentationPage _pageFromJson(Map<String, Object?> json) {
    final textBlocks = (json['textBlocks'] as List? ?? const <Object?>[])
        .whereType<Map<String, Object?>>()
        .map(_textBlockFromJson)
        .toList(growable: false);

    final componentBlocks =
        (json['componentBlocks'] as List? ?? const <Object?>[])
            .whereType<Map<String, Object?>>()
            .map(_componentBlockFromJson)
            .toList(growable: false);

    return PresentationPage(
      id: _string(json['id'], 'page-1'),
      backgroundKind: _backgroundKindValue(json['backgroundKind']),
      speakerNotes: _string(json['speakerNotes'], ''),
      textBlocks: textBlocks,
      componentBlocks: componentBlocks,
    );
  }

  static PresentationBackgroundKind _backgroundKindValue(Object? value) {
    final name = value?.toString();
    for (final definition in presentationBackgroundLibrary) {
      if (definition.kind.name == name) return definition.kind;
    }

    const migrations = <String, PresentationBackgroundKind>{
      'blankStudio': PresentationBackgroundKind.science,
      'scientificReasoning': PresentationBackgroundKind.science,
      'cosmicReasoning': PresentationBackgroundKind.spaceTechnology,
      'solarEnergy': PresentationBackgroundKind.solarEnergyScene,
      'mirrorOptics': PresentationBackgroundKind.optics,
      'physicsLab': PresentationBackgroundKind.physics,
      'microUniverse': PresentationBackgroundKind.biology,
      'spaceTech': PresentationBackgroundKind.spaceTechnology,
      'techNetwork': PresentationBackgroundKind.technology,
      'techDataCore': PresentationBackgroundKind.technology,
      'techCleanCircuit': PresentationBackgroundKind.technology,
      'techNeonMotion': PresentationBackgroundKind.technology,
      'techPremiumHologram': PresentationBackgroundKind.technology,
      'mathOrbitGrid': PresentationBackgroundKind.mathematics,
      'mathWireframeSpace': PresentationBackgroundKind.mathematics,
      'mathCleanGeometry': PresentationBackgroundKind.mathematics,
      'mathDynamicFractal': PresentationBackgroundKind.mathematics,
      'mathPremiumTopology': PresentationBackgroundKind.mathematics,
      'chemMolecularField': PresentationBackgroundKind.chemistry,
      'chemLaboratoryDepth': PresentationBackgroundKind.chemistry,
      'chemCleanMatter': PresentationBackgroundKind.chemistry,
      'chemReactionEnergy': PresentationBackgroundKind.chemistry,
      'chemPremiumGlassware': PresentationBackgroundKind.chemistry,
      'geographyAtmosphere': PresentationBackgroundKind.travelGeography,
      'geographyGeologyCore': PresentationBackgroundKind.travelGeography,
      'geographyPaperMap': PresentationBackgroundKind.travelGeography,
      'geographyStormSystem': PresentationBackgroundKind.climateWeather,
      'geographyTwilightAtlas': PresentationBackgroundKind.travelGeography,
      'demoSpaceCommand': PresentationBackgroundKind.spaceTechnology,
      'demoSolarHorizon': PresentationBackgroundKind.solarEnergyScene,
      'demoAcademicPulse': PresentationBackgroundKind.science,
      'demoOrbitAmber': PresentationBackgroundKind.spaceTechnology,
      'historyChronicle': PresentationBackgroundKind.historyArchaeology,
      'historyArchiveDepth': PresentationBackgroundKind.historyArchaeology,
      'historyParchmentMap': PresentationBackgroundKind.historyArchaeology,
      'historyEmberTimeline': PresentationBackgroundKind.historyArchaeology,
      'historyPremiumRelic': PresentationBackgroundKind.historyArchaeology,
      'musicPulseStage': PresentationBackgroundKind.musicSound,
      'musicResonanceDepth': PresentationBackgroundKind.musicSound,
      'musicCleanStaff': PresentationBackgroundKind.musicSound,
      'musicDynamicWave': PresentationBackgroundKind.musicSound,
      'musicPremiumConcert': PresentationBackgroundKind.musicSound,
      'engineeringBlueprintSky': PresentationBackgroundKind.technology,
      'engineeringWorkshopMetal': PresentationBackgroundKind.technology,
      'engineeringCleanBlueprint': PresentationBackgroundKind.technology,
      'engineeringDynamicSystem': PresentationBackgroundKind.technology,
      'engineeringPremiumMechanism': PresentationBackgroundKind.technology,
      'artCanvasWash': PresentationBackgroundKind.artDesign,
      'artStudioDepth': PresentationBackgroundKind.artDesign,
      'artCleanGallery': PresentationBackgroundKind.artDesign,
      'artColorEnergy': PresentationBackgroundKind.artDesign,
      'artPremiumAtelier': PresentationBackgroundKind.artDesign,
    };
    return migrations[name] ?? PresentationBackgroundKind.science;
  }

  static Map<String, Object?> _textBlockToJson(PresentationTextBlock block) {
    return <String, Object?>{
      'id': block.id,
      'text': block.text,
      'position': _offsetToJson(block.position),
      'fontSize': block.fontSize,
      'type': block.type.name,
      'widthFactor': block.widthFactor,
      'textStyle': block.textStyle.name,
      'textAnimation': block.textAnimation.name,
      'textColorHex': block.textColorHex,
      'glowIntensity': block.glowIntensity,
      'revealStep': block.revealStep,
      'hotspotTargetPageId': block.hotspotTargetPageId,
      'textBold': block.textBold,
      'textItalic': block.textItalic,
      'textUnderline': block.textUnderline,
      'textAlign': block.textAlign.name,
    };
  }

  static PresentationTextBlock _textBlockFromJson(Map<String, Object?> json) {
    return PresentationTextBlock(
      id: _string(json['id'], 'text-1'),
      text: _string(json['text'], ''),
      position: _offsetFromJson(json['position']),
      fontSize: _double(json['fontSize'], 42),
      type: _enumValue(
        PresentationTextType.values,
        json['type'],
        PresentationTextType.body,
      ),
      widthFactor: _double(json['widthFactor'], 0.34),
      textStyle: _enumValue(
        PresentationTextStyle.values,
        json['textStyle'],
        PresentationTextStyle.standard,
      ),
      textAnimation: _enumValue(
        PresentationTextAnimation.values,
        json['textAnimation'],
        PresentationTextAnimation.none,
      ),
      textColorHex: json['textColorHex'] is String
          ? json['textColorHex']! as String
          : null,
      glowIntensity: _double(json['glowIntensity'], 1),
      revealStep: _int(json['revealStep'], 0),
      hotspotTargetPageId: json['hotspotTargetPageId'] is String
          ? json['hotspotTargetPageId']! as String
          : null,
      textBold:
          json['textBold'] is bool ? json['textBold']! as bool : false,
      textItalic:
          json['textItalic'] is bool ? json['textItalic']! as bool : false,
      textUnderline: json['textUnderline'] is bool
          ? json['textUnderline']! as bool
          : false,
      textAlign: _enumValue(
        PresentationTextAlign.values,
        json['textAlign'],
        PresentationTextAlign.left,
      ),
    );
  }

  static Map<String, Object?> _componentBlockToJson(
    PresentationComponentBlock block,
  ) {
    return <String, Object?>{
      'id': block.id,
      'kind': block.kind.name,
      'modelAssetId': block.modelAssetId,
      'modelAnimationEnabled': block.modelAnimationEnabled,
      'modelAutoRotate': block.modelAutoRotate,
      'modelRotationSpeed': block.modelRotationSpeed,
      'modelOrbitEnabled': block.modelOrbitEnabled,
      'modelOrbitTheta': block.modelOrbitTheta,
      'modelOrbitPhi': block.modelOrbitPhi,
      'position': _offsetToJson(block.position),
      'size': _sizeToJson(block.size),
      'revealStep': block.revealStep,
      'hotspotTargetPageId': block.hotspotTargetPageId,
    };
  }

  static PresentationComponentBlock _componentBlockFromJson(
    Map<String, Object?> json,
  ) {
    final modelAssetId =
        json['modelAssetId'] is String ? json['modelAssetId']! as String : null;
    return PresentationComponentBlock(
      id: _string(json['id'], 'component-1'),
      kind: _enumValue(
        PresentationComponentKind.values,
        json['kind'],
        PresentationComponentKind.edebiyat01,
      ),
      modelAssetId: modelAssetId,
      modelAnimationEnabled: json['modelAnimationEnabled'] is bool
          ? json['modelAnimationEnabled']! as bool
          : true,
      modelAutoRotate: json['modelAutoRotate'] is bool
          ? json['modelAutoRotate']! as bool
          : false,
      modelRotationSpeed: _double(json['modelRotationSpeed'], 30),
      modelOrbitEnabled: json['modelOrbitEnabled'] is bool
          ? json['modelOrbitEnabled']! as bool
          : false,
      modelOrbitTheta: _double(json['modelOrbitTheta'], 0),
      modelOrbitPhi: _double(json['modelOrbitPhi'], 75),
      position: _offsetFromJson(json['position']),
      size: _sizeFromJson(json['size']),
      revealStep: _int(json['revealStep'], 0),
      hotspotTargetPageId: json['hotspotTargetPageId'] is String
          ? json['hotspotTargetPageId']! as String
          : null,
    );
  }

  static Map<String, Object?> _effectSettingsToJson(
    PresentationEffectSettings settings,
  ) {
    return <String, Object?>{
      'transitionKind': settings.transitionKind.name,
      'transitionDurationMs': settings.transitionDurationMs,
      'zoomEnabled': settings.zoomEnabled,
      'zoomScale': settings.zoomScale,
      'reducedMotion': settings.reducedMotion,
    };
  }

  static PresentationEffectSettings _effectSettingsFromJson(
    Map<String, Object?> json,
  ) {
    return PresentationEffectSettings(
      transitionKind: _enumValue(
        PresentationTransitionKind.values,
        json['transitionKind'],
        PresentationTransitionKind.slide,
      ),
      transitionDurationMs: _int(json['transitionDurationMs'], 420),
      zoomEnabled: _bool(json['zoomEnabled'], false),
      zoomScale: _double(json['zoomScale'], 1.55),
      reducedMotion: _bool(json['reducedMotion'], false),
    );
  }

  static Map<String, Object?> _offsetToJson(Offset offset) {
    return <String, Object?>{
      'x': offset.dx,
      'y': offset.dy,
    };
  }

  static Map<String, Object?> _sizeToJson(Size size) {
    return <String, Object?>{
      'width': size.width,
      'height': size.height,
    };
  }

  static Size _sizeFromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      return const Size(0.28, 0.28);
    }
    return Size(
      _double(value['width'], 0.28),
      _double(value['height'], 0.28),
    );
  }

  static Offset _offsetFromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      return Offset.zero;
    }
    return Offset(
      _double(value['x'], 0),
      _double(value['y'], 0),
    );
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? value,
    T fallback,
  ) {
    if (value is! String) {
      return fallback;
    }
    return values.firstWhere(
      (item) => item.name == value,
      orElse: () => fallback,
    );
  }

  static String _string(Object? value, String fallback) {
    return value is String ? value : fallback;
  }

  static int _int(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return fallback;
  }

  static double _double(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  static bool _bool(Object? value, bool fallback) {
    return value is bool ? value : fallback;
  }
}
