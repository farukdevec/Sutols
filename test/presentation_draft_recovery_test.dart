import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sutol/services/presentation_draft_recovery.dart';

void main() {
  test(
      'checkpoints are owner scoped; older successful write cannot clear new draft',
      () async {
    SharedPreferences.setMockInitialValues({});
    await PresentationDraftRecovery.put('owner', 'deck', 'old');
    await PresentationDraftRecovery.put('owner', 'deck', 'new');
    await PresentationDraftRecovery.clearIfMatches('owner', 'deck', 'old');
    expect(await PresentationDraftRecovery.read('owner', 'deck'), 'new');
    expect(await PresentationDraftRecovery.read('other', 'deck'), isNull);
    await PresentationDraftRecovery.clearIfMatches('owner', 'deck', 'new');
    expect(await PresentationDraftRecovery.read('owner', 'deck'), isNull);
  });
}
