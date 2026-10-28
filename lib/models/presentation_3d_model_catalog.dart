import 'package:flutter/material.dart';
import 'development_features.dart';

part 'original_model_catalog.dart';

@immutable
class Presentation3DModelAsset {
  const Presentation3DModelAsset({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.category,
    required this.tags,
    required this.byteSize,
    required this.sha256,
    this.thumbnailPath,
    this.labelEn,
    this.qualityAssetPath,
    this.exposure = 1,
    this.environmentImage,
    this.icon = Icons.view_in_ar_rounded,
    this.hasAnimations = false,
    this.hasRig = false,
    this.supportsVirtualTour = false,
    this.preferBundledAsset = false,
  });

  final String id;
  final String label;
  final String? labelEn;
  final String assetPath;
  final String category;
  final List<String> tags;
  final int byteSize;
  final String sha256;
  final String? thumbnailPath;
  final String? qualityAssetPath;
  final double exposure;
  final String? environmentImage;
  final IconData icon;
  final bool hasAnimations;
  final bool hasRig;
  final bool supportsVirtualTour;
  final bool preferBundledAsset;
}

const List<Presentation3DModelAsset> presentation3DModelCatalog =
    <Presentation3DModelAsset>[
  Presentation3DModelAsset(
    id: 'anitkabir',
    label: 'Anıtkabir',
    assetPath: '/models/anitkabir.glb',
    thumbnailPath: '/model_thumbnails/anitkabir.webp?v=2',
    category: 'Tarih ve Kültür',
    tags: <String>[
      'Anıtkabir',
      'Mustafa Kemal Atatürk',
      'Atatürk',
      'Ankara',
      'Türkiye',
      'tarih',
      'mimari',
      'anıt mezar',
      '3B',
    ],
    byteSize: 3507628,
    sha256: '15f5d50eb5dd9c433a458d77d09a55c40cc390134a67c018c070ff5ebf5348eb',
    icon: Icons.account_balance_rounded,
    hasAnimations: true,
    supportsVirtualTour: true,
    preferBundledAsset: true,
    // Kaynak GLB, 2185.6 şiddetinde gömülü bir yönlü güneş içeriyor.
    // model-viewer'ın ortam ışığıyla birleştiğinde renklerin beyaza kırpılmasını
    // önlemek ve GLB'deki özgün yeşil materyalleri korumak için kalibre edildi.
    exposure: 0.003,
    environmentImage: 'neutral',
  ),
  Presentation3DModelAsset(
    id: 'yolcu-ucagi',
    label: 'Yolcu Uçağı',
    assetPath: 'assets/models/yolcu_ucagi.glb',
    category: 'Ulaşım ve Havacılık',
    tags: <String>[
      'uçak',
      'yolcu uçağı',
      'havacılık',
      'ulaşım',
      'seyahat',
      '3B',
    ],
    byteSize: 1506520,
    sha256: '874c4636c9e13525f09345fa6a16cfacea69a1ac8073946d4dbd9799033edd4b',
    icon: Icons.flight_rounded,
  ),
  Presentation3DModelAsset(
    id: 'gercekci-dunya',
    label: 'Gerçekçi Dünya',
    assetPath: 'assets/models/gercekci_dunya.glb',
    category: 'Coğrafya ve Uzay',
    tags: <String>[
      'dünya',
      'gezegen',
      'coğrafya',
      'uzay',
      'küre',
      '3B',
    ],
    byteSize: 4192768,
    sha256: '84b698e2ca3f1b50d14eb6561891cc53385f4460ee9047a72789027c4c976e87',
    icon: Icons.public_rounded,
    hasAnimations: true,
  ),
  Presentation3DModelAsset(
    id: 'kompresor-kesiti',
    label: 'Kompresör Kesiti',
    assetPath: 'https://assets.sutols.com/237_kompresor_kesiti.glb',
    thumbnailPath:
        'https://assets.sutols.com/thumbnails/237_kompresor_kesiti.webp',
    category: 'Enerji ve İklimlendirme',
    tags: <String>[
      'kompresör',
      'soğutma kompresörü',
      'refrigeration compressor',
      'compressor',
      'soğutucu akışkan',
      'HVAC',
      'makine',
    ],
    byteSize: 0,
    sha256: '',
  ),
  Presentation3DModelAsset(
    id: 'sogutma-kulesi',
    label: 'Soğutma Kulesi',
    assetPath: 'https://assets.sutols.com/243_sogutma_kulesi.glb',
    thumbnailPath:
        'https://assets.sutols.com/thumbnails/243_sogutma_kulesi.webp',
    category: 'Enerji ve İklimlendirme',
    tags: <String>[
      'soğutma kulesi',
      'cooling tower',
      'endüstriyel soğutma',
      'HVAC',
      'iklimlendirme',
      'kule',
    ],
    byteSize: 0,
    sha256: '',
  ),
  Presentation3DModelAsset(
    id: 'hvac-klima-santrali',
    label: 'HVAC Klima Santrali',
    assetPath: 'https://assets.sutols.com/244_hvac_klima_santrali.glb',
    thumbnailPath:
        'https://assets.sutols.com/thumbnails/244_hvac_klima_santrali.webp',
    category: 'Enerji ve İklimlendirme',
    tags: <String>[
      'HVAC',
      'klima santrali',
      'air conditioner',
      'air conditioning',
      'iklimlendirme',
      'havalandırma',
      'soğutma',
    ],
    byteSize: 0,
    sha256: '',
  ),
  if (sutolOriginalModelsEnabled) ...originalPresentation3DModels,
];

Presentation3DModelAsset? findPresentation3DModelAsset(String id) {
  for (final model in presentation3DModelCatalog) {
    if (model.id == id) {
      return model;
    }
  }
  return null;
}

String? preferredBundledModelAssetPath(String id) {
  final model = findPresentation3DModelAsset(id);
  if (model == null || !model.preferBundledAsset) return null;
  return model.assetPath.trim().isEmpty ? null : model.assetPath.trim();
}

/// Only switches variants of a known bundled asset; imported/embedded sources
/// are preserved verbatim so a saved presentation never changes ownership.
String? modelSourceForRender(String id, String? source,
    {bool highQuality = false}) {
  final asset = findPresentation3DModelAsset(id);
  final resolved = source ?? preferredBundledModelAssetPath(id);
  if (highQuality &&
      asset?.qualityAssetPath != null &&
      resolved == asset!.assetPath) {
    return asset.qualityAssetPath;
  }
  return resolved;
}
