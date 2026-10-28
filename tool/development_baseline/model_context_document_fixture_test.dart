// Explicit local fixture generator, excluded from normal test discovery.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/ui/widgets/html_stage/html_stage_document.dart';

void main() {
  test('generate a public-API HTML recovery fixture', () {
    const page = PresentationPage(
        id: 'context-html-qa',
        textBlocks: [],
        componentBlocks: [
          PresentationComponentBlock(
              id: 'wind',
              modelAssetId: 'sutols-wind-turbine',
              position: Offset(.2, .15),
              size: Size(.6, .7),
              modelAnimationEnabled: false,
              modelAnimationName: 'RotorSpin',
              modelAnimationTime: 1.5,
              modelAutoRotate: false,
              modelCameraRadius: 4,
              modelTurntableRotation: .7,
              modelFieldOfView: 51,
              modelTourEnabled: true,
              modelOrbitTheta: 32,
              modelOrbitPhi: 67,
              modelTargetX: 0,
              modelTargetY: .5,
              modelTargetZ: 0)
        ]);
    final destination = Platform.environment['SUTOLS_CONTEXT_QA_DOCUMENT'];
    expect(destination, isNotNull,
        reason: 'Set an explicit disposable QA output path.');
    final html = buildHtmlStageDocument(page: page, modelSourcesById: {
      'sutols-wind-turbine': '/models/qa-context/rigged-wind-turbine-lite.glb'
    });
    final script =
        File('tool/development_baseline/model_context_document_smoke.js')
            .readAsStringSync();
    File(destination!).writeAsStringSync(html
        .replaceFirst('<head>', r'''<head><script>window.SutolQaPageErrors=[];window.addEventListener('error',function(e){window.SutolQaPageErrors.push({message:e.message,file:e.filename,line:e.lineno,stack:e.error&&e.error.stack});});</script>''').replaceFirst(
            '</body>', '<script>$script</script></body>'));
  });
}
