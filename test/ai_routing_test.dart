import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

/// Simulated Key Health States
enum KeyHealthState {
  healthy,
  rateLimited,
  authenticationError,
  temporarilyUnavailable,
}

/// Simulated Candidate: (Credential Key, Model)
class AiCandidate {
  final String keyId;
  final String model;
  KeyHealthState state;

  AiCandidate({
    required this.keyId,
    required this.model,
    this.state = KeyHealthState.healthy,
  });
}

/// Simulated AI Router Engine implementing candidate ranking, rate limit handling,
/// auth error exclusion, zero-Firestore write in-memory state tracking, and sequential fallback.
class AiRouterEngine {
  final Map<String, KeyHealthState> keyHealth = {
    'key1': KeyHealthState.healthy,
    'key2': KeyHealthState.healthy,
  };

  final List<String> availableModels = [
    'model_a',
    'model_b',
    'model_c',
  ];

  final Map<String, List<String>> _callLogs = {
    'key1': [],
    'key2': [],
    'gemini': [],
    'grok': [],
  };

  List<String> get callLogs => [
        ..._callLogs['key1']!,
        ..._callLogs['key2']!,
        ..._callLogs['gemini']!,
        ..._callLogs['grok']!,
      ];

  List<String> getProviderLogs() {
    final list = <String>[];
    for (final entry in _callLogs.entries) {
      for (final item in entry.value) {
        list.add('${entry.key}:$item');
      }
    }
    return list;
  }

  /// Generate ordered candidate list: healthy key 1 models -> healthy key 2 models.
  /// Excludes keys marked with authenticationError.
  List<AiCandidate> buildCandidates(String requestedModel) {
    final candidates = <AiCandidate>[];

    final models = [
      requestedModel,
      ...availableModels.where((m) => m != requestedModel)
    ];

    final keys = ['key1', 'key2'];
    for (final k in keys) {
      if (keyHealth[k] == KeyHealthState.authenticationError) {
        continue; // Exclude auth error key immediately
      }
      for (final m in models) {
        candidates.add(AiCandidate(keyId: k, model: m, state: keyHealth[k]!));
      }
    }

    // Sort: healthy keys first, then rate limited keys
    candidates.sort((a, b) {
      if (a.state != b.state) {
        return a.state == KeyHealthState.healthy ? -1 : 1;
      }
      return 0; // maintain key1 -> key2 order
    });

    return candidates;
  }

  /// Execute sequential router request with mock responses handler per (keyId, model)
  Future<String> executeRequest({
    required String requestedModel,
    required Future<int> Function(String keyId, String model) mockNvidiaHandler,
    required Future<bool> Function() mockGeminiHandler,
    required Future<bool> Function() mockGrokHandler,
  }) async {
    final candidates = buildCandidates(requestedModel);

    // Sequential loop over NVIDIA candidates
    for (final candidate in candidates) {
      _callLogs[candidate.keyId]!.add(candidate.model);

      final statusCode = await mockNvidiaHandler(candidate.keyId, candidate.model);

      if (statusCode == 200) {
        keyHealth[candidate.keyId] = KeyHealthState.healthy;
        return 'SUCCESS_NVIDIA_${candidate.keyId}_${candidate.model}';
      } else if (statusCode == 429) {
        keyHealth[candidate.keyId] = KeyHealthState.rateLimited;
        continue;
      } else if (statusCode == 401 || statusCode == 403) {
        keyHealth[candidate.keyId] = KeyHealthState.authenticationError;
        continue;
      } else {
        keyHealth[candidate.keyId] = KeyHealthState.temporarilyUnavailable;
        continue;
      }
    }

    // NVIDIA Key 1 + Key 2 exhausted -> Gemini
    _callLogs['gemini']!.add('gemini-3.6-flash');
    final geminiSuccess = await mockGeminiHandler();
    if (geminiSuccess) {
      return 'SUCCESS_GEMINI';
    }

    // Gemini failed -> Grok
    _callLogs['grok']!.add('grok-4.3');
    final grokSuccess = await mockGrokHandler();
    if (grokSuccess) {
      return 'SUCCESS_GROK';
    }

    throw Exception('FINAL_ERROR: All providers failed');
  }
}

void main() {
  group('AI Model Router & Sequential Fallback Tests', () {
    late AiRouterEngine router;

    setUp(() {
      router = AiRouterEngine();
    });

    test('Test 1: Key 1 + Model A -> SUCCESS (Key 2, Gemini, Grok NOT called)', () async {
      final result = await router.executeRequest(
        requestedModel: 'model_a',
        mockNvidiaHandler: (keyId, model) async {
          if (keyId == 'key1' && model == 'model_a') return 200;
          return 500;
        },
        mockGeminiHandler: () async => true,
        mockGrokHandler: () async => true,
      );

      expect(result, 'SUCCESS_NVIDIA_key1_model_a');
      expect(router.getProviderLogs(), ['key1:model_a']);
      expect(router.keyHealth['key1'], KeyHealthState.healthy);
    });

    test('Test 2: Key 1 + Model A -> 429 -> Key 1 + Model B -> SUCCESS', () async {
      final result = await router.executeRequest(
        requestedModel: 'model_a',
        mockNvidiaHandler: (keyId, model) async {
          if (keyId == 'key1' && model == 'model_a') return 429;
          if (keyId == 'key1' && model == 'model_b') return 200;
          return 500;
        },
        mockGeminiHandler: () async => false,
        mockGrokHandler: () async => false,
      );

      expect(result, 'SUCCESS_NVIDIA_key1_model_b');
      expect(router.getProviderLogs(), containsAllInOrder(['key1:model_a', 'key1:model_b']));
      expect(router.getProviderLogs(), isNot(contains('gemini:gemini-3.6-flash')));
    });

    test('Test 3: Key 1 -> rate limited -> Key 2 + Model A -> SUCCESS', () async {
      router.keyHealth['key1'] = KeyHealthState.rateLimited;

      final result = await router.executeRequest(
        requestedModel: 'model_a',
        mockNvidiaHandler: (keyId, model) async {
          if (keyId == 'key2' && model == 'model_a') return 200;
          return 500;
        },
        mockGeminiHandler: () async => false,
        mockGrokHandler: () async => false,
      );

      expect(result, 'SUCCESS_NVIDIA_key2_model_a');
      expect(router.getProviderLogs().first, startsWith('key2:'));
      expect(router.getProviderLogs(), isNot(contains('gemini:gemini-3.6-flash')));
    });

    test('Test 4: Key 1 & Key 2 NVIDIA models fail -> Gemini -> SUCCESS', () async {
      final result = await router.executeRequest(
        requestedModel: 'model_a',
        mockNvidiaHandler: (keyId, model) async => 500, // All NVIDIA fail
        mockGeminiHandler: () async => true,
        mockGrokHandler: () async => false,
      );

      expect(result, 'SUCCESS_GEMINI');
      expect(router.getProviderLogs(), contains('gemini:gemini-3.6-flash'));
      expect(router.getProviderLogs(), isNot(contains('grok:grok-4.3')));
    });

    test('Test 5: NVIDIA Key 1 & 2 fail -> Gemini fails -> Grok -> SUCCESS', () async {
      final result = await router.executeRequest(
        requestedModel: 'model_a',
        mockNvidiaHandler: (keyId, model) async => 500,
        mockGeminiHandler: () async => false, // Gemini fails
        mockGrokHandler: () async => true, // Grok succeeds
      );

      expect(result, 'SUCCESS_GROK');
      expect(router.getProviderLogs(), contains('grok:grok-4.3'));
    });

    test('Test 6: Key 1 -> 401 (authentication_error) -> Key 2 used (No infinite retry)', () async {
      await expectLater(
        router.executeRequest(
          requestedModel: 'model_a',
          mockNvidiaHandler: (keyId, model) async {
            if (keyId == 'key1') return 401; // Key 1 gets auth error
            if (keyId == 'key2' && model == 'model_a') return 200; // Key 2 succeeds
            return 500;
          },
          mockGeminiHandler: () async => false,
          mockGrokHandler: () async => false,
        ),
        completion(equals('SUCCESS_NVIDIA_key2_model_a')),
      );

      expect(router.keyHealth['key1'], KeyHealthState.authenticationError);

      final nextLogs = <String>[];
      final candidates = router.buildCandidates('model_a');

      for (final c in candidates) {
        nextLogs.add('${c.keyId}:${c.model}');
      }

      expect(nextLogs, isNot(contains(startsWith('key1:'))));
      expect(candidates.every((c) => c.keyId != 'key1'), isTrue);
    });
  });
}
