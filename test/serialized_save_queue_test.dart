import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/serialized_save_queue.dart';

void main() {
  test(
      'later writes wait; failed saves remain observable and do not block retry',
      () async {
    final queue = SerializedSaveQueue();
    final gate = Completer<void>();
    final writes = <String>[];
    final first = queue.run(() async {
      await gate.future;
      writes.add('old');
      throw StateError('offline');
    });
    final failure = expectLater(first, throwsStateError);
    final second = queue.run(() async {
      writes.add('new');
    });
    await Future<void>.delayed(Duration.zero);
    expect(writes, isEmpty);
    gate.complete();
    await failure;
    await second;
    expect(writes, ['old', 'new']);
  });
}
