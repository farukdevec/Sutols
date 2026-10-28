/// A print tab reserved while the browser still has user activation.
abstract class PrintExportTarget {
  bool get isClosed;
  void navigate(String documentUrl);
  void close();
}

class PrintExportWindowException implements Exception {
  const PrintExportWindowException({this.closedByUser = false});
  final bool closedByUser;
}

Future<void> preparePrintExport({
  required PrintExportTarget? Function() openTarget,
  required Future<String> Function() prepareDocument,
}) async {
  // This must precede the first await: delayed window.open loses activation.
  final target = openTarget();
  if (target == null) throw const PrintExportWindowException();
  try {
    final url = await prepareDocument();
    if (target.isClosed) {
      throw const PrintExportWindowException(closedByUser: true);
    }
    target.navigate(url);
  } catch (_) {
    if (!target.isClosed) target.close();
    rethrow;
  }
}
