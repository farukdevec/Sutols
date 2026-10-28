import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';
import 'package:sutol/ui/widgets/republic_day_banner.dart';

void main() {
  test('Republic Day background supports animated and static exports', () {
    expect(PresentationBackgroundKind.republicDay.index,
        PresentationBackgroundKind.studioNightSky.index + 1);
    for (final animated in [true, false]) {
      final html = buildHtmlBackgroundSceneDocument(
          PresentationBackgroundKind.republicDay,
          animationEnabled: animated);
      expect(html, contains('Türk bayrağı'));
      expect(html, contains('prefers-reduced-motion'));
      expect(html, contains('mask="url(#crescent)"'));
    }
  });

  test('Bundled Republic Day model contains flag texture and animation', () {
    final model = findPresentation3DModelAsset('cumhuriyet-29-ekim')!;
    final bytes = File('web${model.assetPath}').readAsBytesSync();
    expect(bytes.length, model.byteSize);
    final data = ByteData.sublistView(bytes);
    expect(data.getUint32(0, Endian.little), 0x46546c67);
    final jsonLength = data.getUint32(12, Endian.little);
    final gltf =
        jsonDecode(utf8.decode(bytes.sublist(20, 20 + jsonLength))) as Map;
    expect(gltf['animations'], isNotEmpty);
    expect(gltf['images'], isNotEmpty);
    expect(File('web${model.thumbnailPath}').existsSync(), isTrue);
  });

  testWidgets('Broadcast banner fits narrow phones with reduced motion',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
      data: MediaQueryData(disableAnimations: true),
      child: Scaffold(body: RepublicDayBanner()),
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('29'), findsOneWidget);
  });
}
