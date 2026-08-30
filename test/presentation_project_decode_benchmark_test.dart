import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/presentation_component_catalog.dart';
import 'package:sutol/services/presentation_project_codec.dart';

void main() {
  test('decodes every component kind and preserves the legacy fallback', () {
    final kinds = PresentationComponentKind.values;
    final project = PresentationProjectCodec.decodeProject(
      _projectSource(<String>[
        ...kinds.map((kind) => kind.name),
        'unknown-component-kind',
      ]),
    );

    expect(
      project.pages.single.componentBlocks
          .take(kinds.length)
          .map((block) => block.kind)
          .toList(growable: false),
      kinds,
    );
    expect(
      project.pages.single.componentBlocks.last.kind,
      PresentationComponentKind.edebiyat01,
    );
  });

  test('benchmarks component-kind decoding for a large project', () {
    final kinds = PresentationComponentKind.values;
    final expectedKinds = List<String>.generate(
      240,
      (index) => kinds[(index * 97) % kinds.length].name,
      growable: false,
    );
    final source = _projectSource(expectedKinds);
    final expectedKindNames = expectedKinds.toList(growable: false);
    for (var index = 0; index < 4; index++) {
      PresentationProjectCodec.decodeProject(source);
    }

    final stopwatch = Stopwatch()..start();
    PresentationProject? lastProject;
    for (var index = 0; index < 100; index++) {
      lastProject = PresentationProjectCodec.decodeProject(source);
    }
    stopwatch.stop();

    expect(lastProject!.pages.single.componentBlocks, hasLength(240));
    expect(
      lastProject.pages.single.componentBlocks
          .map((block) => block.kind.name)
          .toList(growable: false),
      expectedKindNames,
    );
    // ignore: avoid_print
    print('project-decode-us=${stopwatch.elapsedMicroseconds}');
  });
}

String _projectSource(List<String> kindNames) {
  final components = List<Map<String, Object?>>.generate(kindNames.length, (
    index,
  ) {
    return <String, Object?>{
      'id': 'component-$index',
      'kind': kindNames[index],
      'position': <String, double>{'x': .1, 'y': .1},
      'size': <String, double>{'width': .3, 'height': .3},
    };
  }, growable: false);
  return jsonEncode(<String, Object?>{
    'format': 'sutol.presentation',
    'version': 1,
    'pages': <Object?>[
      <String, Object?>{
        'id': 'benchmark-page',
        'textBlocks': const <Object?>[],
        'componentBlocks': components,
      },
    ],
  });
}
