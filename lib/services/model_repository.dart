import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_rest_helper.dart';

/// Firestore'daki 3B model kataloğunun oturum-içi kaynağı.
///
/// Repository, ilk çağrıda REST ile katalogyu yükler; sonraki çağrılarda aynı
/// bellek içi listeyi döndürür. Devam eden ilk yükleme de paylaşılır; böylece
/// aynı anda açılan tüketiciler ayrı Firestore istekleri başlatmaz.
class ModelCatalogEntry {
  const ModelCatalogEntry({
    required this.id,
    required this.name,
    required this.modelUrl,
    required this.thumbnailUrl,
    required this.tags,
    this.tagsEn = const <String>[],
    required this.category,
    required this.tier,
    this.excludeTags = const <String>[],
  });

  final String id;
  final String name;
  final String modelUrl;
  final String thumbnailUrl;
  final List<String> tags;
  final List<String> tagsEn;
  final String category;
  final String tier;

  /// Bu modelin ASLA eşleşmemesi gereken kelimeler (yanlış-domain koruması).
  /// Örn. bir "Embriyo Gelişimi" modeline `["kahve", "gastronomi", "yemek"]`
  /// eklenirse, gastronomi slaytlarında bu model hiçbir zaman aday olmaz —
  /// skorlama ne derse desin.
  final List<String> excludeTags;
}

class ModelRepository {
  ModelRepository._();

  static final ModelRepository instance = ModelRepository._();

  List<ModelCatalogEntry>? _cachedModels;
  String? _cachedForUserId;
  Future<List<ModelCatalogEntry>>? _loadingModels;
  String? _loadingForUserId;

  /// Model kataloğunu yükler veya aynı uygulama oturumundaki önbelleği döner.
  Future<List<ModelCatalogEntry>> getModels() {
    String? userId;
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {}
    final cachedModels = _cachedModels;
    if (cachedModels != null && _cachedForUserId == userId) {
      return Future.value(cachedModels);
    }

    final loadingModels = _loadingModels;
    if (loadingModels != null && _loadingForUserId == userId) {
      return loadingModels;
    }

    final future = _fetchModels(userId);
    _loadingModels = future;
    _loadingForUserId = userId;
    return future;
  }

  Future<List<ModelCatalogEntry>> _fetchModels(String? userId) async {
    try {
      final docs = await FirestoreRestHelper.listDocuments('models');
      final models = <ModelCatalogEntry>[];

      for (final doc in docs) {
        final id = (doc['name'] as String? ?? '').split('/').last;
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final modelUrl = FirestoreRestHelper.stringField(fields, 'modelUrl');
        if (id.isEmpty || modelUrl.isEmpty) {
          continue;
        }

        final name = FirestoreRestHelper.stringField(fields, 'name');
        models.add(ModelCatalogEntry(
          id: id,
          name: name.isEmpty ? id : name,
          modelUrl: modelUrl,
          thumbnailUrl: FirestoreRestHelper.stringField(fields, 'thumbnailUrl'),
          tags: FirestoreRestHelper.arrayField(fields, 'tags'),
          tagsEn: FirestoreRestHelper.arrayField(fields, 'tags_en'),
          category: FirestoreRestHelper.stringField(fields, 'category'),
          tier: FirestoreRestHelper.stringField(fields, 'tier'),
          excludeTags: FirestoreRestHelper.arrayField(fields, 'excludeTags'),
        ));
      }

      models.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      final immutableModels = List<ModelCatalogEntry>.unmodifiable(models);
      _cachedModels = immutableModels;
      _cachedForUserId = userId;
      return immutableModels;
    } catch (e) {
      // Firestore okuma hatası (403 vb.) olursa boş liste döner;
      // sunum oluşturma akışını bozmaz.
      print('Model kataloğu okunamadı (403 vb.): $e');
      return const [];
    } finally {
      if (_loadingForUserId == userId) {
        _loadingModels = null;
        _loadingForUserId = null;
      }
    }
  }
}
