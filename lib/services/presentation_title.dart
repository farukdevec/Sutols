const int presentationFallbackTitleMaxLength = 80;

/// Returns the explicit presentation name, or a compact deterministic name
/// derived from [topic] when the user leaves the title field blank.
String resolvePresentationTitle({
  required String title,
  required String topic,
}) {
  final explicitTitle = title.trim();
  if (explicitTitle.isNotEmpty) return explicitTitle;

  final normalizedTopic = topic.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalizedTopic.length <= presentationFallbackTitleMaxLength) {
    return normalizedTopic;
  }
  return '${normalizedTopic.substring(0, presentationFallbackTitleMaxLength - 1).trimRight()}…';
}
