import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'modelUrl': modelUrl,
        'thumbnailUrl': thumbnailUrl,
        'tags': tags,
        'tagsEn': tagsEn,
        'category': category,
        'tier': tier,
        'excludeTags': excludeTags,
      };

  static ModelCatalogEntry? fromCacheJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final id = value['id'];
    final modelUrl = value['modelUrl'];
    if (id is! String ||
        id.isEmpty ||
        modelUrl is! String ||
        modelUrl.isEmpty) {
      return null;
    }
    List<String> strings(Object? raw) => raw is List
        ? raw.whereType<String>().where((item) => item.isNotEmpty).toList()
        : const <String>[];

    return ModelCatalogEntry(
      id: id,
      name: value['name'] is String && (value['name'] as String).isNotEmpty
          ? value['name'] as String
          : id,
      modelUrl: modelUrl,
      thumbnailUrl: value['thumbnailUrl'] as String? ?? '',
      tags: strings(value['tags']),
      tagsEn: strings(value['tagsEn']),
      category: value['category'] as String? ?? '',
      tier: value['tier'] as String? ?? '',
      excludeTags: strings(value['excludeTags']),
    );
  }
}

class ModelRepository {
  ModelRepository._();

  static final ModelRepository instance = ModelRepository._();

  static const int _cacheSchemaVersion = 1;
  static const Duration _persistentCacheTtl = Duration(hours: 12);
  static const String _persistentCachePrefix = 'model_catalog_cache_v1';

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

    final future = _loadModels(userId);
    _loadingModels = future;
    _loadingForUserId = userId;
    return future;
  }

  Future<List<ModelCatalogEntry>> _loadModels(String? userId) async {
    final persistent = await _readPersistentCache(userId);
    if (persistent != null && persistent.models.isNotEmpty) {
      _cachedModels = persistent.models;
      _cachedForUserId = userId;
      if (DateTime.now().difference(persistent.savedAt) > _persistentCacheTtl) {
        unawaited(_refreshInBackground(userId));
      }
      if (_loadingForUserId == userId) {
        _loadingModels = null;
        _loadingForUserId = null;
      }
      return persistent.models;
    }
    return _fetchModels(userId);
  }

  Future<void> _refreshInBackground(String? userId) async {
    try {
      await _fetchModels(userId);
    } catch (_) {
      // Eski ama geçerli katalog ağ hatasında kullanılmaya devam eder.
    }
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
      if (immutableModels.isNotEmpty) {
        await _writePersistentCache(userId, immutableModels);
      }
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

  String _persistentCacheKey(String? userId) =>
      '$_persistentCachePrefix:${userId ?? 'anonymous'}';

  Future<_PersistentModelCatalog?> _readPersistentCache(String? userId) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_persistentCacheKey(userId));
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> ||
          decoded['schemaVersion'] != _cacheSchemaVersion) {
        return null;
      }
      final savedAt = DateTime.tryParse(decoded['savedAt'] as String? ?? '');
      final rawModels = decoded['models'];
      if (savedAt == null || rawModels is! List) return null;
      final models = rawModels
          .map(ModelCatalogEntry.fromCacheJson)
          .whereType<ModelCatalogEntry>()
          .toList(growable: false);
      if (models.isEmpty) return null;
      return _PersistentModelCatalog(
        savedAt: savedAt,
        models: List<ModelCatalogEntry>.unmodifiable(models),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writePersistentCache(
    String? userId,
    List<ModelCatalogEntry> models,
  ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _persistentCacheKey(userId),
        jsonEncode(<String, dynamic>{
          'schemaVersion': _cacheSchemaVersion,
          'savedAt': DateTime.now().toUtc().toIso8601String(),
          'models': models.map((model) => model.toCacheJson()).toList(),
        }),
      );
    } catch (_) {
      // Kalıcı önbellek yazılamazsa oturum içi RAM önbelleği kullanılmaya devam eder.
    }
  }
}

class _PersistentModelCatalog {
  const _PersistentModelCatalog({
    required this.savedAt,
    required this.models,
  });

  final DateTime savedAt;
  final List<ModelCatalogEntry> models;
}
