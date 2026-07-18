// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Future<void> requestPresentationFullscreen() async {
  final element = html.document.documentElement;
  if (element == null || html.document.fullscreenElement != null) {
    return;
  }

  try {
    await element.requestFullscreen();
  } catch (_) {
    // Browsers may reject fullscreen unless it is triggered by direct input.
  }
}

Future<void> exitPresentationFullscreen() async {
  if (html.document.fullscreenElement == null) {
    return;
  }

  try {
    html.document.exitFullscreen();
  } catch (_) {
    // Leaving fullscreen is best effort; route navigation still works.
  }
}
