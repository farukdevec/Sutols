import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/models/slide_model.dart';
import 'package:sutol/services/background_search_service.dart';

void main() {
  final index = BackgroundSearchIndex(presentationBackgroundLibrary);
  test('Turkish case/diacritics and English catalog concepts are searchable',
      () {
    expect(index.search('YAPAY ZEKA').map((d) => d.kind),
        contains(PresentationBackgroundKind.studioTechnologyAi));
    expect(index.search('GOKYUZU').map((d) => d.kind),
        contains(PresentationBackgroundKind.studioSky));
    expect(index.search('health medicine').map((d) => d.kind),
        contains(PresentationBackgroundKind.studioHealthMedicine));
    expect(index.search('education').map((d) => d.kind),
        contains(PresentationBackgroundKind.studioEducationAcademia));
    expect(index.search('technology unrelated'), isEmpty);
  });
  test('tone intersects search and leaves every definition immutable', () {
    expect(index.search('', tone: BackgroundToneFilter.light), isNotEmpty);
    expect(index.search('', tone: BackgroundToneFilter.dark), isNotEmpty);
    expect(
        index.search('').length,
        index.search('', tone: BackgroundToneFilter.light).length +
            index.search('', tone: BackgroundToneFilter.dark).length);
    expect(
        index
            .search('sky', tone: BackgroundToneFilter.light)
            .map((d) => d.kind),
        contains(PresentationBackgroundKind.studioSky));
    expect(
        index.search('sky', tone: BackgroundToneFilter.dark).map((d) => d.kind),
        isNot(contains(PresentationBackgroundKind.studioSky)));
    expect(index.search('sky').map((d) => d.kind),
        contains(PresentationBackgroundKind.studioSky));
    expect(presentationBackgroundIsDark(PresentationBackgroundKind.studioSky),
        isFalse);
  });
}
