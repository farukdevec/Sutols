import 'dart:convert';

/// An untrusted local receipt is a review aid, never publishing authority.
class ModelIntakeReceipt {
  ModelIntakeReceipt._(this.data);
  final Map<String, dynamic> data;
  Map<String, dynamic> get metadata => data['metadata'] as Map<String, dynamic>;
  String get id => metadata['id'] as String;
  String get name => metadata['name'] as String;
  bool get canReview =>
      data['state'] == 'awaiting-review' &&
      (data['blockers'] as List).isEmpty &&
      data['triangles'] is int &&
      (data['triangles'] as int) <= 50000;
  int get warnings => data['warnings'] as int;

  factory ModelIntakeReceipt.parse(String source) {
    if (source.length > 256 * 1024)
      throw const FormatException('Rapor çok büyük.');
    final raw = jsonDecode(source);
    if (raw is! Map<String, dynamic> ||
        raw['schema'] != 1 ||
        !['awaiting-review', 'rejected'].contains(raw['state'])) {
      throw const FormatException('Karantina raporu bekleniyor.');
    }
    final meta = raw['metadata'];
    if (meta is! Map<String, dynamic>)
      throw const FormatException('Model bilgisi eksik.');
    for (final field in [
      'id',
      'name',
      'category',
      'license',
      'source',
      'author'
    ]) {
      final value = meta[field];
      if (value is! String || value.trim().isEmpty || value.length > 2000) {
        throw FormatException('Model bilgisi geçersiz: $field');
      }
    }
    if (!RegExp(r'^[a-z][a-z0-9-]{2,79}$').hasMatch(meta['id'] as String)) {
      throw const FormatException('Model kimliği geçersiz.');
    }
    for (final field in ['modelSha256', 'thumbnailSha256', 'metadataSha256']) {
      if (raw[field] is! String ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(raw[field] as String)) {
        throw const FormatException('Dosya kimliği eksik veya geçersiz.');
      }
    }
    if (raw['bytes'] is! int ||
        (raw['bytes'] as int) <= 0 ||
        (raw['bytes'] as int) > 8 * 1024 * 1024 ||
        raw['warnings'] is! int ||
        (raw['warnings'] as int) < 0 ||
        raw['blockers'] is! List ||
        (raw['blockers'] as List).any((e) => e is! String) ||
        (raw['triangles'] != null &&
            (raw['triangles'] is! int || (raw['triangles'] as int) < 0))) {
      throw const FormatException('Doğrulama bilgisi geçersiz.');
    }
    // JSON clone avoids sharing mutable caller-owned metadata with decisions.
    return ModelIntakeReceipt._(
        jsonDecode(jsonEncode(raw)) as Map<String, dynamic>);
  }

  Map<String, dynamic> decision(
      {required String reviewer,
      required bool accepted,
      required bool visualReviewed,
      required bool licenseReviewed,
      required bool warningsReviewed,
      required String notes}) {
    if (reviewer.trim().isEmpty ||
        reviewer.length > 200 ||
        notes.length > 4000) {
      throw const FormatException('İnceleyen adı veya not geçersiz.');
    }
    if (accepted &&
        (!canReview ||
            !visualReviewed ||
            !licenseReviewed ||
            (warnings > 0 && !warningsReviewed))) {
      throw const FormatException(
          'Onay için görsel, lisans ve uyarı incelemesini tamamlayın.');
    }
    return {
      'schema': 1,
      'id': id,
      for (final key in ['modelSha256', 'thumbnailSha256', 'metadataSha256'])
        key: data[key],
      'decision': accepted ? 'accept' : 'reject',
      'reviewer': reviewer.trim(),
      'visualReviewed': visualReviewed,
      'licenseReviewed': licenseReviewed,
      'warningsReviewed': warningsReviewed,
      'notes': notes.trim(),
      'reviewedAt': DateTime.now().toUtc().toIso8601String(),
      'publicationStatus': 'local-review-only'
    };
  }
}
