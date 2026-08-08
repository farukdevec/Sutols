/// Kullanicinin yerelden yukledigi gorsellerin sahne tarafindan cozulebilmesi
/// icin global kaynak kayit defteri.
///
/// Key: gorsel kimligi (uretilen benzersiz id, orn. "local-image-1700000000000")
/// Value: data URL (base64) — dosya her zaman dogrudan dokumana gomulur.
class RemoteImageSources {
  RemoteImageSources._();

  static final Map<String, String> _sources = <String, String>{};

  static Map<String, String> get all =>
      Map<String, String>.unmodifiable(_sources);

  static void register(String id, String dataUrl) {
    _sources[id] = dataUrl;
  }

  static void registerAll(Map<String, String> sources) {
    _sources.addAll(sources);
  }

  static String? sourceFor(String sourceId) => _sources[sourceId];

  static void remove(String sourceId) {
    _sources.remove(sourceId);
  }
}