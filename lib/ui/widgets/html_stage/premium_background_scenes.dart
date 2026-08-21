import '../../../models/slide_model.dart';
import 'premium_background_scenes_group_a.dart';
import 'premium_background_scenes_group_b.dart';
import 'premium_background_scenes_group_c.dart';
import 'premium_background_scenes_group_d.dart';

final Map<PresentationBackgroundKind, String> sutolPremiumBackgroundScenes =
    <PresentationBackgroundKind, String>{
  ...sutolPremiumBackgroundScenesGroupA,
  ...sutolPremiumBackgroundScenesGroupB,
  ...sutolPremiumBackgroundScenesGroupC,
  ...sutolPremiumBackgroundScenesGroupD,
};
