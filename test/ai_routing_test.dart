import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/ai_model_config.dart';

// Test production policy directly. The old test-only router had a different
// provider order and an obsolete Super-first chain, so it could not verify
// the real routing implementation. HTTP failover lives in
// nvidia_presentation_service_test.dart with a MockClient.
void main() {
  group('AI production route policy', () {
    test('standard generation uses the canonical proxy route', () {
      expect(AiModelConfig.presentationCandidatesFor('Atom'),
          [AiModelConfig.modelGptOss120b]);
    });
    test('deep mode preserves the proxy route and its shared deadline', () {
      expect(
          AiModelConfig.presentationCandidatesFor('Atom',
              mode: PresentationGenerationMode.deep),
          [AiModelConfig.modelGptOss120b]);
    });
    test('diagnostic candidates preserve order without enabling Ultra', () {
      expect(AiModelConfig.defaultNvidiaCandidateModels.first,
          AiModelConfig.modelGptOss120b);
      expect(AiModelConfig.deepNvidiaCandidateModels, [
        AiModelConfig.modelNemotronSuper,
        ...AiModelConfig.defaultNvidiaCandidateModels
      ]);
      expect(AiModelConfig.defaultNvidiaCandidateModels.toSet().length,
          AiModelConfig.defaultNvidiaCandidateModels.length);
      expect(AiModelConfig.deepNvidiaCandidateModels,
          isNot(contains(AiModelConfig.modelNemotronUltra)));
    });
    test('HTTP failures keep distinct authentication and retry classifications',
        () {
      for (final (status, error) in <(int, AiErrorType)>[
        (400, AiErrorType.badRequest400),
        (401, AiErrorType.authError401),
        (403, AiErrorType.forbidden403),
        (404, AiErrorType.notFound404),
        (408, AiErrorType.timeout),
        (429, AiErrorType.rateLimited429),
        (500, AiErrorType.serverError5xx),
        (503, AiErrorType.serverError5xx),
        (418, AiErrorType.unknown),
      ]) {
        expect(AiModelConfig.classifyStatusCode(status), error);
      }
      for (final error in [
        AiErrorType.timeout,
        AiErrorType.rateLimited429,
        AiErrorType.serverError5xx,
        AiErrorType.networkError
      ]) {
        expect(AiModelConfig.isFallbackable(error), isTrue);
      }
    });
    test(
        'large decks scale the canonical model deadline within the total budget',
        () {
      final normal =
          AiModelConfig.timeoutForModel(AiModelConfig.modelGptOss120b);
      final large = AiModelConfig.timeoutForModel(AiModelConfig.modelGptOss120b,
          slideCount: 10);
      expect(normal, AiModelConfig.timeoutGptOss120b);
      expect(large, greaterThan(normal));
      expect(large, lessThanOrEqualTo(AiModelConfig.maxTotalAiTime));
    });
    test('disabled challenger cannot route a topic to an unverified model', () {
      expect(AiModelConfig.lightningChallengerPercent, 0);
      for (final topic in ['Atom', 'İklim', 'History', '', 'Uzay']) {
        expect(AiModelConfig.useLightningChallenger(topic), isFalse);
      }
    });
  });
}
