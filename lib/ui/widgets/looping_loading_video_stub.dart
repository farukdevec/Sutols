import 'package:flutter/material.dart';

/// WebM oynatılamayan platformlarda güvenli yükleme göstergesi.
class LoopingLoadingVideo extends StatelessWidget {
  const LoopingLoadingVideo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
