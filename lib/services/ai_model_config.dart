/// AI Hata Sınıfları
enum AiErrorType {
  timeout,
  rateLimited429,
  serverError5xx,
  authError401,
  forbidden403,
  badRequest400,
  notFound404,
  invalidJson,
  schemaError,
  qualityRejection,
  networkError,
  unknown,
}

/// Merkezi AI Model ve Router Yapılandırması
class AiModelConfig {
  const AiModelConfig._();

  // Model Adları
  static const String modelNemotronSuper = 'nvidia/nemotron-3-super-120b-a12b';
  static const String modelGptOss120b = 'openai/gpt-oss-120b';
  static const String modelLlama33_70b = 'meta/llama-3.3-70b-instruct';
  static const String modelGptOss20b = 'openai/gpt-oss-20b';
  static const String modelNemotronNano = 'nvidia/nemotron-3-nano-30b-a3b';
  static const String modelLlama31_8b = 'meta/llama-3.1-8b-instruct';
  static const String modelNemotronUltra =
      'nvidia/nemotron-3-ultra-550b-a55b'; // Yalnızca premium/deep reasoning için

  static const String modelGeminiFlash = 'gemini-3.6-flash';

  static const String modelGrokDefault = 'grok-4.3';
  static const String modelGrok45 = 'grok-4.5';
  static const String modelGrok46 = 'grok-4.6';

  // Genel fallback sırası: En hızlı, en kararlı ve en kaliteli modeller en başta.
  static const List<String> defaultNvidiaCandidateModels = [
    modelLlama33_70b,
    modelNemotronNano,
    modelGptOss20b,
    modelLlama31_8b,
    modelNemotronSuper,
    modelGptOss120b,
  ];

  // Normal Üretim Grok Aday Sırası (Mayıs 2026 sonrası güncel modeller)
  static const List<String> defaultGrokCandidateModels = [
    modelGrokDefault,
    modelGrok45,
    modelGrok46,
  ];

  // Model Bazlı Hızlı Zaman Aşımları (Timeouts) - Kullanıcıyı bekletmeyen dinamik süreler
  static const Duration timeoutLlama33 = Duration(seconds: 25);
  static const Duration timeoutNano = Duration(seconds: 18);
  static const Duration timeoutGptOss20b = Duration(seconds: 20);
  static const Duration timeoutLlama31 = Duration(seconds: 15);
  static const Duration timeoutSuper = Duration(seconds: 35);
  static const Duration timeoutGptOss120b = Duration(seconds: 35);
  static const Duration timeoutGemini = Duration(seconds: 20);
  static const Duration timeoutGrok = Duration(seconds: 20);
  static const Duration timeoutDefaultNvidia = Duration(seconds: 25);

  // Router Global Maksimum Süre
  static const Duration maxTotalAiTime = Duration(seconds: 60);

  /// Bir model için geçerli zaman aşımı süresini döndürür.
  static Duration timeoutForModel(String model, {int slideCount = 5}) {
    final scale = slideCount > 6 ? 1.3 : 1.0;
    if (model.contains('super'))
      return Duration(
          milliseconds: (timeoutSuper.inMilliseconds * scale).toInt());
    if (model.contains('gpt-oss-120b'))
      return Duration(
          milliseconds: (timeoutGptOss120b.inMilliseconds * scale).toInt());
    if (model.contains('llama-3.3-70b'))
      return Duration(
          milliseconds: (timeoutLlama33.inMilliseconds * scale).toInt());
    if (model.contains('gpt-oss-20b') || model.contains('gpt-oss'))
      return Duration(
          milliseconds: (timeoutGptOss20b.inMilliseconds * scale).toInt());
    if (model.contains('nano'))
      return Duration(
          milliseconds: (timeoutNano.inMilliseconds * scale).toInt());
    if (model.contains('llama-3.1-8b') || model.contains('llama'))
      return Duration(
          milliseconds: (timeoutLlama31.inMilliseconds * scale).toInt());
    if (model.contains('gemini'))
      return Duration(
          milliseconds: (timeoutGemini.inMilliseconds * scale).toInt());
    if (model.contains('grok'))
      return Duration(
          milliseconds: (timeoutGrok.inMilliseconds * scale).toInt());
    return Duration(
        milliseconds: (timeoutDefaultNvidia.inMilliseconds * scale).toInt());
  }

  /// HTTP durum kodunu `AiErrorType` olarak sınıflandırır.
  static AiErrorType classifyStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return AiErrorType.badRequest400;
      case 401:
        return AiErrorType.authError401;
      case 403:
        return AiErrorType.forbidden403;
      case 404:
        return AiErrorType.notFound404;
      case 408:
        return AiErrorType.timeout;
      case 429:
        return AiErrorType.rateLimited429;
      default:
        if (statusCode >= 500) {
          return AiErrorType.serverError5xx;
        }
        return AiErrorType.unknown;
    }
  }

  /// Bu hatanın sonraki modele fallback yapmaya uygun olup olmadığını belirler.
  static bool isFallbackable(AiErrorType errorType) {
    switch (errorType) {
      case AiErrorType.timeout:
      case AiErrorType.rateLimited429:
      case AiErrorType.serverError5xx:
      case AiErrorType.invalidJson:
      case AiErrorType.schemaError:
      case AiErrorType.qualityRejection:
      case AiErrorType.networkError:
      case AiErrorType.badRequest400:
      case AiErrorType.notFound404:
      case AiErrorType.unknown:
        return true;
      case AiErrorType.authError401:
      case AiErrorType.forbidden403:
        return true;
    }
  }

  /// Hata tipinin metin etiketini döndürür.
  static String errorTypeLabel(AiErrorType errorType) {
    switch (errorType) {
      case AiErrorType.timeout:
        return 'TIMEOUT';
      case AiErrorType.rateLimited429:
        return '429_RATE_LIMIT';
      case AiErrorType.serverError5xx:
        return '5XX_SERVER_ERROR';
      case AiErrorType.authError401:
        return '401_AUTH_ERROR';
      case AiErrorType.forbidden403:
        return '403_FORBIDDEN';
      case AiErrorType.badRequest400:
        return '400_BAD_REQUEST';
      case AiErrorType.notFound404:
        return '404_NOT_FOUND';
      case AiErrorType.invalidJson:
        return 'INVALID_JSON';
      case AiErrorType.schemaError:
        return 'SCHEMA_ERROR';
      case AiErrorType.qualityRejection:
        return 'QUALITY_REJECTED';
      case AiErrorType.networkError:
        return 'NETWORK_ERROR';
      case AiErrorType.unknown:
        return 'UNKNOWN_ERROR';
    }
  }
}

/// Standart Yapılandırılmış AI Router Loglayıcı
class AiRouterLogger {
  const AiRouterLogger._();

  static void logRequestStart(
      {required String topic, required int slideCount}) {
    // ignore: avoid_print
    print('''
[AI ROUTER]
Request started: topic="$topic", slideCount=$slideCount''');
  }

  static void logSuccess({
    required String provider,
    String? key,
    required String model,
    required int attempt,
    int? status,
    required Duration latency,
    bool? jsonValid,
    bool? schemaValid,
    bool? qualityPass,
  }) {
    final keyLine = key != null && key.isNotEmpty ? 'Key: $key\n' : '';
    final statusCode = status ?? 200;
    // ignore: avoid_print
    print('''
[AI ROUTER]
Provider: $provider
${keyLine}Model: $model
Attempt: $attempt
Status: $statusCode
Latency: ${latency.inMilliseconds}ms''');
  }

  static void logFailure({
    required String provider,
    String? key,
    required String model,
    required int attempt,
    String? status,
    AiErrorType? errorType,
    required Duration latency,
    String? action,
    String? error,
    String? details,
  }) {
    final keyLine = key != null && key.isNotEmpty ? 'Key: $key\n' : '';
    final statusStr = status ??
        (errorType != null
            ? AiModelConfig.errorTypeLabel(errorType)
            : 'FAILED');
    final actionLine =
        action != null && action.isNotEmpty ? '\nAction: $action' : '';
    final errorLine = error != null && error.isNotEmpty
        ? '\nError: $error'
        : (details != null && details.isNotEmpty ? '\nError: $details' : '');
    // ignore: avoid_print
    print('''
[AI ROUTER]
Provider: $provider
${keyLine}Model: $model
Attempt: $attempt
Status: $statusStr
Latency: ${latency.inMilliseconds}ms$actionLine$errorLine''');
  }

  static void logKeyFallback({
    required String provider,
    required String fromKey,
    required String toKey,
    String? status,
  }) {
    // ignore: avoid_print
    print('''
[AI ROUTER]
Provider: $provider
Key: $fromKey
Status: ${status ?? 'FAILED'}
Action: FALLBACK_TO_${toKey.toUpperCase()}''');
  }
}
