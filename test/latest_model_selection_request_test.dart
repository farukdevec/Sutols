import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/latest_model_selection_request.dart';

void main() {
  test('newer selection wins when authorization resolves in reverse order',
      () async {
    final gate = LatestModelSelectionRequest();
    final page = Object();
    final scope = (page: page, owner: 'one', selection: 'a');
    final first = Completer<String>();
    final second = Completer<String>();
    final applied = <String>[];
    Future<void> choose(Future<String> response) async {
      final revision = gate.begin(scope);
      final result = await response;
      if (gate.accepts(revision, scope)) applied.add(result);
    }

    final a = choose(first.future);
    final b = choose(second.future);
    second.complete('new');
    await b;
    first.complete('old');
    await a;
    expect(applied, ['new']);
  });

  test('leaving and returning to the same page still discards pending work',
      () {
    final gate = LatestModelSelectionRequest();
    final page = Object();
    final initial = (page: page, owner: 'one', selection: 'a');
    final revision = gate.begin(initial);
    gate.observe((page: Object(), owner: 'one', selection: 'a'));
    gate.observe(initial);
    expect(gate.accepts(revision, initial), isFalse);
  });

  test('account, item selection, document replacement and disposal invalidate',
      () {
    for (final change in ['owner', 'selection', 'document', 'dispose']) {
      final gate = LatestModelSelectionRequest();
      final page = Object();
      final initial = (page: page, owner: 'one', selection: 'a');
      final revision = gate.begin(initial);
      gate.observe(initial);
      expect(gate.accepts(revision, initial), isTrue);
      if (change == 'dispose') {
        gate.invalidate();
      } else {
        gate.observe((
          page: change == 'document' ? Object() : page,
          owner: change == 'owner' ? 'two' : 'one',
          selection: change == 'selection' ? 'b' : 'a'
        ));
      }
      expect(gate.accepts(revision, initial), isFalse);
    }
  });
}
