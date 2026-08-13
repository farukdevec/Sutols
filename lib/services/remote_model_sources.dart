/// Eşleştirilen Firestore modellerinin sahne (model-viewer) tarafından
/// çözülebilmesi için global kaynak kayıt defteri.
///
/// Key: model doküman ID'si (örn. "01_SWOT_Analiz_Kupu")
/// Value: yükleme kaynağı — Cloudflare R2 modelUrl.
class RemoteModelSources {
  RemoteModelSources._();

  static final Map<String, String> _sources = <String, String>{};

  static Map<String, String> get all =>
      Map<String, String>.unmodifiable(_sources);

  static void registerAll(Map<String, String> sources) {
    for (final entry in sources.entries) {
      if (entry.key.trim().isEmpty || entry.value.trim().isEmpty) continue;
      _sources[entry.key] = entry.value.trim();
    }
  }

  static String? sourceFor(String modelId) => _sources[modelId];
}
