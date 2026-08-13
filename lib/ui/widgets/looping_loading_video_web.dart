// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Sutols logosunun şeffaf WebM animasyonunu sessiz ve sürekli döngüde oynatır.
class LoopingLoadingVideo extends StatefulWidget {
  const LoopingLoadingVideo({super.key, this.size = 120});

  final double size;

  @override
  State<LoopingLoadingVideo> createState() => _LoopingLoadingVideoState();
}

class _LoopingLoadingVideoState extends State<LoopingLoadingVideo> {
  late final String _viewType;
  late final html.VideoElement _video;

  @override
  void initState() {
    super.initState();
    _viewType = 'sutols-loading-video-${identityHashCode(this)}';
    _video = html.VideoElement()
      // Sürüm parametresi, tarayıcının önceki düşük çözünürlüklü dosyayı
      // önbellekten göstermesini engeller.
      ..src = 'assets/assets/videos/sutols_loading_logo.webm?v=original-hd'
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..controls = false
      ..preload = 'auto'
      ..setAttribute('playsinline', 'true')
      ..setAttribute('aria-label', 'Sutols yükleniyor');
    _video.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'contain'
      ..transform = 'scale(2.35)'
      ..transformOrigin = 'center center'
      ..backgroundColor = 'transparent'
      ..pointerEvents = 'none';

    final host = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.overflow = 'hidden'
      ..style.backgroundColor = 'transparent'
      ..append(_video);

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (_) => host,
    );
    _video.play();
  }

  @override
  void dispose() {
    _video
      ..pause()
      ..src = ''
      ..load();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: ClipRect(child: HtmlElementView(viewType: _viewType)),
    );
  }
}
