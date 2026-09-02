/// Sunumlarda fotoğraf kullanımını dengeli ve amaca uygun tutan kurallar.
///
/// Bir stok fotoğraf ancak anlatıya somut bir katkı yapıyorsa kullanılır.
/// Diyagram, tablo, grafik veya yalnızca metin gerektiren slaytlarda fotoğraf
/// aranmaması; hem daha temiz bir görünüm hem de daha az ağ isteği sağlar.
class PresentationVisualPlan {
  const PresentationVisualPlan._();

  /// [visualKind] üretici modelin görsel planından gelir. Belirsiz planlarda
  /// stok fotoğraf adaylığı, zayıf bir 3B anahtar kelime eşleşmesinden önce
  /// gelir; aksi halde alakasız 3B varlıklar fotoğraf aramasını tamamen
  /// engelliyordu.
  static bool isPhotoCandidate({
    required String? visualKind,
    required bool hasConfident3dModel,
  }) {
    final kind = _normalize(visualKind);
    // Bir diyagram isteği gerçek bir 3B nesneyle karşılanamıyorsa, boş
    // bırakmak yerine konuya doğrulanmış bir fotoğraf yerleştir. Diyagramın
    // metin düzeni korunur; fotoğraf yalnızca anlatısal görsel ankordur.
    // `none` da üreticinin görsel öneremediği eski yanıtlar için aynı güvenli
    // fallback'i kullanır.
    if (!hasConfident3dModel) return true;
    // 3B istendiğinde önce katalogdaki güçlü aday kullanılır. Katalogda
    // yeterli kanıt yoksa yanlış bir 3B nesne yerine fotoğraf aramaya izin ver.
    if (kind == 'object_3d') return false;
    if (kind == 'photo' || kind == 'illustration' || kind == 'image_focus') {
      return true;
    }
    // Bilinmeyen/gelecek şema türlerinde fotoğraf adaylığını koru; katalog
    // modeli kullanılsa bile son karar aşamasında tek görsel seçilir.
    return true;
  }

  /// Fotoğraf isteği bütçesi: slaytların yaklaşık üçte biri. Böylece sunum
  /// görsel olarak nefes alır; her sayfa stok fotoğrafla dolmaz.
  static int photoBudgetFor(int slideCount) {
    if (slideCount <= 2) return 1;
    if (slideCount <= 5) return 2;
    if (slideCount <= 8) return 3;
    return (slideCount * 0.35).round().clamp(3, 8).toInt();
  }

  /// Adayları yayarak seçer. Yan yana iki fotoğraf yalnızca başka seçenek
  /// bulunmadığında kullanılabilir.
  static List<int> choosePhotoSlides({
    required int slideCount,
    required List<int> candidates,
  }) {
    if (slideCount <= 0 || candidates.isEmpty) return const <int>[];
    final budget = photoBudgetFor(slideCount).clamp(1, candidates.length);
    final selected = <int>[];
    for (final index in candidates) {
      if (selected.length >= budget) break;
      if (selected.every((existing) => (existing - index).abs() > 1)) {
        selected.add(index);
      }
    }
    for (final index in candidates) {
      if (selected.length >= budget) break;
      if (!selected.contains(index)) selected.add(index);
    }
    return selected..sort();
  }

  /// Fotoğraf planı, 3B planını yalnızca model açıkça fotoğraf istediğinde
  /// geçersiz kılar. Böylece 3B katalog da anlamlı slaytlarda korunur.
  static bool prefersPhotoOver3d(String? visualKind) {
    final kind = _normalize(visualKind);
    return kind == 'photo' || kind == 'illustration' || kind == 'image_focus';
  }

  static String _normalize(String? value) =>
      (value ?? '').trim().toLowerCase().replaceAll('-', '_');
}
