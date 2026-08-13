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
    return matches.isEmpty ? LayoutType.textOnly : LayoutType.singleFocus;
  }

  int maxModelsToShow(LayoutType layout) {
    switch (layout) {
      case LayoutType.textOnly:
        return 0;
      case LayoutType.singleFocus:
        return 1;
      case LayoutType.compare:
        return 1;
      case LayoutType.grid:
        return 1;
      case LayoutType.gridWithMore:
        return 1;
    }
  }
}
