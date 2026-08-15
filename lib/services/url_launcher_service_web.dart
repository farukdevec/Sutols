// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class UrlLauncherService {
  static void openUrl(String url) {
    html.window.open(url, '_blank');
  }

  static void openEmail(String email) {
    html.window.location.href = 'mailto:$email';
  }

  static void openInstagram(String username) {
    final handle = username.replaceAll('@', '').trim();
    openUrl('https://www.instagram.com/$handle');
  }
}
