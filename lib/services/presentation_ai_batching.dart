class PresentationAiBatching {
  const PresentationAiBatching._();

  static const int maxSlidesPerBatch = 4;
  static const int maxConcurrentBatches = 2;

  static List<({int start, int end})> ranges(int slideCount) {
    if (slideCount <= 0) return const <({int start, int end})>[];
    return <({int start, int end})>[
      for (var start = 0; start < slideCount; start += maxSlidesPerBatch)
        (
          start: start,
          end: (start + maxSlidesPerBatch).clamp(0, slideCount),
        ),
    ];
  }

  /// Bağımsız AI parçalarını sağlayıcıyı aşırı yüklemeden paralel çalıştırır.
  /// Sonuç sırası her zaman giriş sırasıyla aynıdır.
  static Future<List<R>> mapOrdered<T, R>(
    Iterable<T> items,
    Future<R> Function(T item) operation, {
    int concurrency = maxConcurrentBatches,
  }) async {
    if (concurrency < 1) {
      throw ArgumentError.value(concurrency, 'concurrency', 'En az 1 olmalı.');
    }
    final source = items.toList(growable: false);
    final results = <R>[];
    for (var start = 0; start < source.length; start += concurrency) {
      final end = (start + concurrency).clamp(0, source.length);
      results.addAll(
        await Future.wait(source.sublist(start, end).map(operation)),
      );
    }
    return results;
  }
}
