// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

void updateBrowserUrl({required String path, String? title}) {
  try {
    if (title != null && title.trim().isNotEmpty) {
      html.document.title = '$title - Sutols';
    }
    final currentPath = html.window.location.pathname;
    if (currentPath != path) {
      html.window.history.pushState(null, title ?? '', path);
    }
  } catch (_) {}
}

void replaceBrowserUrl({required String path, String? title}) {
  try {
    if (title != null && title.trim().isNotEmpty) {
      html.document.title = '$title - Sutols';
    }
    html.window.history.replaceState(null, title ?? '', path);
  } catch (_) {}
}
