import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/print_export_session.dart';

class _Target implements PrintExportTarget {
  @override
  bool isClosed = false;
  String? destination;
  int closeCount = 0;
  @override
  void navigate(String url) => destination = url;
  @override
  void close() {
    isClosed = true;
    closeCount++;
  }
}

void main() {
  test('reserves the print tab synchronously before delayed preparation',
      () async {
    final target = _Target();
    final document = Completer<String>();
    final events = <String>[];
    final pending = preparePrintExport(openTarget: () {
      events.add('open');
      return target;
    }, prepareDocument: () {
      events.add('prepare');
      return document.future;
    });
    expect(events, ['open', 'prepare']);
    expect(target.destination, isNull);
    document.complete('blob:print');
    await pending;
    expect(target.destination, 'blob:print');
    expect(target.closeCount, 0);
  });

  test('blocked popup does not start downloading or preparing assets',
      () async {
    var prepared = false;
    await expectLater(
        preparePrintExport(
            openTarget: () => null,
            prepareDocument: () async {
              prepared = true;
              return 'blob:print';
            }),
        throwsA(isA<PrintExportWindowException>()
            .having((e) => e.closedByUser, 'closedByUser', false)));
    expect(prepared, false);
  });

  test('failed preparation closes the reserved tab and permits a retry',
      () async {
    final failed = _Target();
    await expectLater(
        preparePrintExport(
            openTarget: () => failed,
            prepareDocument: () async => throw StateError('failed')),
        throwsStateError);
    expect(failed.closeCount, 1);
    final retry = _Target();
    await preparePrintExport(
        openTarget: () => retry, prepareDocument: () async => 'blob:retry');
    expect(retry.destination, 'blob:retry');
  });

  test('does not reopen a tab closed by the user while assets are loading',
      () async {
    final target = _Target();
    final document = Completer<String>();
    final pending = preparePrintExport(
        openTarget: () => target, prepareDocument: () => document.future);
    final check = expectLater(
        pending,
        throwsA(isA<PrintExportWindowException>()
            .having((e) => e.closedByUser, 'closedByUser', true)));
    target.isClosed = true;
    document.complete('blob:unused');
    await check;
    expect(target.destination, isNull);
    expect(target.closeCount, 0);
  });
}
