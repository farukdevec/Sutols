import 'package:flutter/material.dart';

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
    this.icon = Icons.view_in_ar_rounded,
    this.hasAnimations = false,
    this.hasRig = false,
  });

  final String id;
  final String label;
  final String assetPath;
  final String category;
  final List<String> tags;
  final int byteSize;
  final String sha256;
  final IconData icon;
  final bool hasAnimations;
  final bool hasRig;
}

const List<Presentation3DModelAsset> presentation3DModelCatalog =
    <Presentation3DModelAsset>[
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
];

Presentation3DModelAsset? findPresentation3DModelAsset(String id) {
  for (final model in presentation3DModelCatalog) {
    if (model.id == id) {
      return model;
    }
  }
  return null;
}
