/// Compile-time rollback switches. They do not change saved presentation IDs
/// or the URLs of already published model files.
const sutolVisibleScenesEnabled =
    bool.fromEnvironment('SUTOLS_VISIBLE_SCENES', defaultValue: true);
const sutolOriginalModelsEnabled =
    bool.fromEnvironment('SUTOLS_ORIGINAL_MODELS', defaultValue: true);
const sutolInflectedMatchingEnabled =
    bool.fromEnvironment('SUTOLS_INFLECTED_MATCHING', defaultValue: true);
