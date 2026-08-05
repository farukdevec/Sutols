import 'model_matching_service.dart';

enum LayoutType {
  textOnly,
  singleFocus,
  compare,
  grid,
  gridWithMore,
}


class LayoutService {
  LayoutType decideLayout(List<ModelMatch> matches) {
    final strongMatches = matches.where((m) => m.score >= 2).toList();
    final matchedModelCount = strongMatches.length;
    if (matchedModelCount <= 0) return LayoutType.textOnly;
    if (matchedModelCount == 1) return LayoutType.singleFocus;
    if (matchedModelCount == 2) return LayoutType.compare;
    if (matchedModelCount <= 4) return LayoutType.grid;
    return LayoutType.gridWithMore;
  }


  int maxModelsToShow(LayoutType layout) {
    switch (layout) {
      case LayoutType.textOnly:
        return 0;
      case LayoutType.singleFocus:
        return 1;
      case LayoutType.compare:
        return 2;
      case LayoutType.grid:
        return 4;
      case LayoutType.gridWithMore:
        return 4;
    }
  }
}
