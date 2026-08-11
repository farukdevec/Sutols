import 'package:cloud_firestore/cloud_firestore.dart';

import 'layout_stats_service.dart';

/// Bir sunum, oluşturulduktan 24 saat sonra hâlâ `wasEdited == false` VEYA
/// `wasExported == true` ise "başarılı" sayılır: kullanıcı beğenip
/// dokunmadı ya da dışa aktardı. 24 saatten genç sunumlar henüz
/// sınıflandırılamaz, taramada atlanır.
class StatsAggregationService {
  final _db = FirebaseFirestore.instance;
  final _layoutStats = LayoutStatsService();

  /// Son [days] günün presentations kayıtlarını tarar; 24 saatten eski her
  /// sunumun başarı durumunu hesaplar ve her slaydın kendi `category` +
  /// `layout` alanlarıyla LayoutStatsService().recordUsage() çağırır.
  Future<StatsAggregationSummary> aggregateRecent({int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final minAge = DateTime.now().subtract(const Duration(hours: 24));

    final snapshot = await _db
        .collection('presentations')
        .where('createdAt', isGreaterThanOrEqualTo: since)
        .get();

    var presentationsScanned = 0;
    var presentationsMature = 0;
    var skippedNotMature = 0;
    var slidesRecorded = 0;
    var slidesSkipped = 0;

    for (final doc in snapshot.docs) {
      presentationsScanned++;
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null || createdAt.isAfter(minAge)) {
        skippedNotMature++;
        continue;
      }
      presentationsMature++;

      final wasEdited = data['wasEdited'] == true;
      final wasExported = data['wasExported'] == true;
      final wasSuccessful = !wasEdited || wasExported;

      final slides = await _slidesOf(doc);
      for (final slide in slides) {
        final category = slide['category'];
        final layout = slide['layout'];
        if (category is! String || category.isEmpty ||
            layout is! String || layout.isEmpty) {
          slidesSkipped++;
          continue;
        }
        try {
          await _layoutStats.recordUsage(category, layout, wasSuccessful);
          slidesRecorded++;
        } catch (_) {
          // Tek sunum/slaydın hatası toplam taramayı bozmasın.
          slidesSkipped++;
        }
      }
    }

    return StatsAggregationSummary(
      presentationsScanned: presentationsScanned,
      presentationsMature: presentationsMature,
      skippedNotMature: skippedNotMature,
      slidesRecorded: slidesRecorded,
      slidesSkipped: slidesSkipped,
    );
  }

  /// Slaytları okur: önce ana belgedeki `slides` dizisi, yoksa `slides`
  /// alt koleksiyonu (order ile). Dönen her slayt map'i `category` ve
  /// `layout` alanlarını taşır; alanlar yoksa boş bırakılır.
  Future<List<Map<String, dynamic>>> _slidesOf(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final embedded = doc.data()?['slides'];
    if (embedded is List) {
      return embedded
          .whereType<Map<dynamic, dynamic>>()
          .map((slide) => {
                'category': slide['category'] as String? ?? '',
                'layout': slide['layout'] as String? ?? '',
              })
          .toList();
    }

    try {
      final slideDocs = await _db
          .collection('presentations')
          .doc(doc.id)
          .collection('slides')
          .orderBy('order')
          .get();
      return slideDocs.docs.map((slideDoc) {
        final slideData = slideDoc.data();
        return {
          'category': slideData['category'] as String? ?? '',
          'layout': slideData['layout'] as String? ?? '',
        };
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}

class StatsAggregationSummary {
  const StatsAggregationSummary({
    required this.presentationsScanned,
    required this.presentationsMature,
    required this.skippedNotMature,
    required this.slidesRecorded,
    required this.slidesSkipped,
  });

  /// Taramaya giren toplam sunum sayısı.
  final int presentationsScanned;

  /// 24 saatten eski olduğu için sınıflandırılabilen sunum sayısı.
  final int presentationsMature;

  /// 24 saatten genç olduğu için atlanan sunum sayısı.
  final int skippedNotMature;

  /// LayoutStats'e işlenen slayt sayısı.
  final int slidesRecorded;

  /// category/layout alanı eksik olduğu için veya hata nedeniyle atlanan slayt sayısı.
  final int slidesSkipped;
}