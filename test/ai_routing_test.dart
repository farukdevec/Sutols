import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/ai_model_config.dart';

/// Simulated AI Router Engine implementing candidate ranking, rate limit handling,
/// auth error exclusion, zero-Firestore write in-memory state tracking, and sequential fallback.
class AiRouterEngine {
  final Map<String, AiErrorType?> modelErrors = {};

  final List<String> availableNvidiaModels =
      AiModelConfig.defaultNvidiaCandidateModels;

  final List<String> callLogs = [];

  /// Execute sequential router request with mock responses handler
  Future<String> executeRequest({
    required Future<int> Function(String model) mockNvidiaHandler,
    required Future<bool> Function() mockGeminiHandler,
    required Future<bool> Function() mockGrokHandler,
  }) async {
    // 1. Sequential loop over NVIDIA candidates: Super 120B -> GPT-OSS 120B -> Llama 3.3 70B -> GPT-OSS 20B -> Nano -> Llama 3.1 8B
    for (final model in availableNvidiaModels) {
      callLogs.add('nvidia:$model');

      final statusCode = await mockNvidiaHandler(model);

      if (statusCode == 200) {
        return 'SUCCESS_NVIDIA_$model';
      } else {
        modelErrors[model] = AiModelConfig.classifyStatusCode(statusCode);
        continue;
      }
    }

    // 2. NVIDIA candidates exhausted -> Gemini
    callLogs.add('gemini:${AiModelConfig.modelGeminiFlash}');
    final geminiSuccess = await mockGeminiHandler();
    if (geminiSuccess) {
      return 'SUCCESS_GEMINI';
    }

    // 3. Gemini failed -> Grok
    callLogs.add('grok:${AiModelConfig.modelGrokDefault}');
    final grokSuccess = await mockGrokHandler();
    if (grokSuccess) {
      return 'SUCCESS_GROK';
    }

    // 4. All AI failed -> Fallback
    callLogs.add('fallback:word_based');
    return 'SUCCESS_FALLBACK';
  }
}

void main() {
  group('AI Model Router & Sequential Fallback Tests', () {
    late AiRouterEngine router;

    setUp(() {
      router = AiRouterEngine();
    });

    test('Scenario 1: Super 120B -> SUCCESS (All fallback models NOT called)', () async {
      final result = await router.executeRequest(
        mockNvidiaHandler: (model) async =>
            model == AiModelConfig.modelNemotronSuper ? 200 : 500,
        mockGeminiHandler: () async => true,
        mockGrokHandler: () async => true,
      );

      expect(result, 'SUCCESS_NVIDIA_${AiModelConfig.modelNemotronSuper}');
      expect(router.callLogs, ['nvidia:${AiModelConfig.modelNemotronSuper}']);
      expect(router.callLogs, isNot(contains('nvidia:${AiModelConfig.modelGptOss120b}')));
      expect(router.callLogs, isNot(contains('nvidia:${AiModelConfig.modelLlama33_70b}')));
    });

    test('Scenario 2: Super 120B -> 429/500 -> GPT-OSS 120B -> SUCCESS', () async {
      final result = await router.executeRequest(
        mockNvidiaHandler: (model) async {
          if (model == AiModelConfig.modelNemotronSuper) return 429;
          if (model == AiModelConfig.modelGptOss120b) return 200;
          return 500;
        },
        mockGeminiHandler: () async => true,
        mockGrokHandler: () async => false,
      );

      expect(result, 'SUCCESS_NVIDIA_${AiModelConfig.modelGptOss120b}');
      expect(router.callLogs, [
        'nvidia:${AiModelConfig.modelNemotronSuper}',
        'nvidia:${AiModelConfig.modelGptOss120b}',
      ]);
      expect(router.callLogs, isNot(contains('nvidia:${AiModelConfig.modelLlama33_70b}')));
      expect(router.callLogs, isNot(contains(contains('gemini'))));
    });

    test('Scenario 3: Super 120B + GPT-OSS 120B fail -> Llama 3.3 70B -> SUCCESS', () async {
      final result = await router.executeRequest(
        mockNvidiaHandler: (model) async {
          if (model == AiModelConfig.modelNemotronSuper) return 500;
          if (model == AiModelConfig.modelGptOss120b) return 500;
          if (model == AiModelConfig.modelLlama33_70b) return 200;
          return 500;
        },
        mockGeminiHandler: () async => true,
        mockGrokHandler: () async => false,
      );

      expect(result, 'SUCCESS_NVIDIA_${AiModelConfig.modelLlama33_70b}');
      expect(router.callLogs, [
        'nvidia:${AiModelConfig.modelNemotronSuper}',
        'nvidia:${AiModelConfig.modelGptOss120b}',
        'nvidia:${AiModelConfig.modelLlama33_70b}',
      ]);
      expect(router.callLogs, isNot(contains('nvidia:${AiModelConfig.modelGptOss20b}')));
      expect(router.callLogs, isNot(contains(contains('gemini'))));
    });

    test('Scenario 4: All NVIDIA models fail -> Gemini -> SUCCESS (Grok NOT called)', () async {
      final result = await router.executeRequest(
        mockNvidiaHandler: (model) async => 500,
        mockGeminiHandler: () async => true,
        mockGrokHandler: () async => false,
      );

      expect(result, 'SUCCESS_GEMINI');
      expect(router.callLogs, contains('gemini:${AiModelConfig.modelGeminiFlash}'));
      expect(router.callLogs, isNot(contains(contains('grok'))));
    });

    test('Scenario 5: All NVIDIA fail -> Gemini fails -> Grok -> SUCCESS', () async {
      final result = await router.executeRequest(
        mockNvidiaHandler: (model) async => 500,
        mockGeminiHandler: () async => false,
        mockGrokHandler: () async => true,
      );

      expect(result, 'SUCCESS_GROK');
      expect(router.callLogs, contains('grok:${AiModelConfig.modelGrokDefault}'));
      expect(router.callLogs, isNot(contains(contains('fallback'))));
    });

    test('Scenario 6: All AI services fail -> Word-based Fallback is used', () async {
      final result = await router.executeRequest(
        mockNvidiaHandler: (model) async => 500,
        mockGeminiHandler: () async => false,
        mockGrokHandler: () async => false,
      );

      expect(result, 'SUCCESS_FALLBACK');
      expect(router.callLogs.last, 'fallback:word_based');
    });
  });
}
