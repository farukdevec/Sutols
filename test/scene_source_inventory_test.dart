import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  test('every background installs its lifecycle before original scripts', () {
    final inventory = <Map<String, Object>>[];
    for (final definition in presentationBackgroundLibrary) {
      final source = sutolHtmlBackgroundScene(definition.kind);
      final document = buildHtmlBackgroundSceneDocument(definition.kind);
      final lifecycle = document.indexOf('<script data-sutol-scene-lifecycle>');
      expect(lifecycle, greaterThanOrEqualTo(0), reason: definition.kind.name);
      expect(document.indexOf('<script'), lifecycle,
          reason: definition.kind.name);
      int calls(String name) =>
          RegExp('\\b$name\\s*\\(').allMatches(source).length;
      inventory.add({
        'id': definition.kind.name,
        'label': definition.label,
        'requestAnimationFrameCallSites': calls('requestAnimationFrame'),
        'setIntervalCallSites': calls('setInterval'),
        'setTimeoutCallSites': calls('setTimeout'),
        'canvasElements': RegExp(r'<canvas\b', caseSensitive: false)
            .allMatches(source)
            .length,
        'cssKeyframes': RegExp(r'@keyframes\b').allMatches(source).length,
        'sourceBytes': utf8.encode(source).length,
        'externalScriptUrls': RegExp(r'''<script[^>]+src=['"](https?[^'"]+)''',
                caseSensitive: false)
            .allMatches(source)
            .map((m) => m.group(1)!)
            .toList(),
      });
    }
    final output = Platform.environment['SUTOLS_SCENE_INVENTORY_OUTPUT'];
    if (output != null && output.isNotEmpty) {
      File(output)
          .writeAsStringSync('${const JsonEncoder.withIndent('  ').convert({
            'scope': 'static-call-site-inventory; not runtime GPU measurements',
            'backgrounds': inventory,
          })}\n');
    }
    expect(inventory.length, presentationBackgroundLibrary.length);
  });
  test('component animations have no scene-independent timer loops', () {
    final inventory = <Map<String, Object>>[];
    for (final kind in presentationComponentLibraryKinds) {
      final source = presentationComponentHtml(kind);
      expect(RegExp(r'\bsetInterval\s*\(').hasMatch(source), isFalse,
          reason: kind.name);
      expect(RegExp(r'\bsetTimeout\s*\(').hasMatch(source), isFalse,
          reason: kind.name);
      inventory.add({
        'id': kind.name,
        'requestAnimationFrameCallSites':
            RegExp(r'\brequestAnimationFrame\s*\(').allMatches(source).length,
        'canvasElements': RegExp(r'<canvas\b', caseSensitive: false)
            .allMatches(source)
            .length,
        'cssKeyframes': RegExp(r'@keyframes\b').allMatches(source).length,
        'sourceBytes': utf8.encode(source).length
      });
    }
    final output = Platform.environment['SUTOLS_COMPONENT_QA_OUTPUT'];
    if (output != null && output.isNotEmpty) {
      final directory = Directory(output)..createSync(recursive: true);
      File('${directory.path}/component-inventory.json')
          .writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
        'scope': 'static component inventory, not GPU measurements',
        'components': inventory
      }));
      final repeated = PresentationPage(
          id: 'repeated-stars',
          textBlocks: const [],
          componentBlocks: [
            for (var index = 0; index < 2; index++)
              PresentationComponentBlock(
                  id: 'stars-$index',
                  kind: PresentationComponentKind.astronomi04,
                  position: Offset(index * .5, .1),
                  size: const Size(.5, .8))
          ]);
      File('${directory.path}/repeated-stars.html').writeAsStringSync(
          buildHtmlStageDocument(page: repeated));
      for (final kind in [
        PresentationComponentKind.matematik39,
        PresentationComponentKind.astronomi04
      ]) {
        final page = PresentationPage(
            id: kind.name,
            textBlocks: const [],
            componentBlocks: [
              PresentationComponentBlock(
                  id: kind.name,
                  kind: kind,
                  position: const Offset(.1, .1),
                  size: const Size(.8, .8))
            ]);
        for (final reduced in [false, true]) {
          File('${directory.path}/${kind.name}${reduced ? '-reduced' : ''}.html')
              .writeAsStringSync(buildHtmlStageDocument(
                  page: page, reducedMotion: reduced, showBackground: false));
        }
      }
    }
  });
}
