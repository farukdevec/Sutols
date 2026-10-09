import 'package:flutter/widgets.dart';
import '../../models/slide_model.dart';

/// One render preference shared by editor and presentation. Project data stays
/// independent of browser visibility and temporary renderer handles.
class PresentationRenderScope extends InheritedWidget {
  const PresentationRenderScope(
      {super.key, required this.settings, required super.child});
  final PresentationEffectSettings settings;
  static PresentationEffectSettings of(BuildContext context) {
    final settings = context
            .dependOnInheritedWidgetOfExactType<PresentationRenderScope>()
            ?.settings ??
        const PresentationEffectSettings();
    return MediaQuery.maybeOf(context)?.disableAnimations == true
        ? settings.copyWith(reducedMotion: true)
        : settings;
  }

  @override
  bool updateShouldNotify(PresentationRenderScope oldWidget) =>
      oldWidget.settings.renderQuality != settings.renderQuality ||
      oldWidget.settings.reducedMotion != settings.reducedMotion;
}
