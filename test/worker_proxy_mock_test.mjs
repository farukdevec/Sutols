import assert from 'node:assert/strict';
import worker, {
  AI_ROUTER_DEADLINE_MS,
  FAST_FALLBACK_MODEL,
  canStartModel,
  compactPresentationGenerationRequest,
  modelAttemptBudgetMs,
} from '../sutol-model-proxy/src/index.js';

async function runWorkerUnitTests() {
  console.log('--- Running Cloudflare Worker Mock Tests ---');

  // Test 1: OPTIONS CORS Preflight
  {
    const req = new Request('https://sutols.online/nvidia', {
      method: 'OPTIONS',
      headers: {
        'Origin': 'https://sutols.com',
        'Access-Control-Request-Headers': 'Content-Type, Authorization',
      },
    });
    const res = await worker.fetch(req, {}, {});
    assert.equal(res.status, 204);
    assert.equal(res.headers.get('Access-Control-Allow-Origin'), 'https://sutols.com');
    console.log('✓ Test 1 Passed: CORS OPTIONS Preflight');
  }

  // Test 2: Health Check Route
  {
    const req = new Request('https://sutols.online/', {
      method: 'GET',
    });
    const res = await worker.fetch(req, {}, {});
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, 'ok');
    console.log('✓ Test 2 Passed: Health Check');
  }

  // Test 3: Fast Model Routing & Missing Keys response
  {
    const req = new Request('https://sutols.online/nvidia', {
      method: 'POST',
      headers: {
        'Origin': 'https://sutols.com',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'meta/llama-3.1-8b-instruct',
        messages: [{ role: 'user', content: 'test' }],
      }),
    });
    const res = await worker.fetch(req, {}, {});
    assert.equal(res.status, 503);
    const body = await res.json();
    assert.equal(body.error.type, 'AI_ROUTER_EXHAUSTED');
    console.log('✓ Test 3 Passed: AI Router gracefully reports exhausted providers when no keys configured');
  }

  // Test 4: The verified production model may start only when its full
  // attempt and egress reserve fit the request deadline.
  {
    const now = Date.now();
    assert.equal(
      canStartModel({
        modelName: 'openai/gpt-oss-120b',
        deadlineAt: now + AI_ROUTER_DEADLINE_MS,
        fastFallbackStillAvailable: true,
      }),
      true,
    );
    assert.equal(
      canStartModel({
        modelName: 'openai/gpt-oss-120b',
        deadlineAt: now + 62000,
        fastFallbackStillAvailable: true,
      }),
      false,
    );
    assert.equal(FAST_FALLBACK_MODEL, 'openai/gpt-oss-120b');
    assert.equal(modelAttemptBudgetMs('openai/gpt-oss-120b'), 105000);
    console.log('✓ Test 4 Passed: deadline preserves the verified-model budget');
  }

  // Test 5: Long presentation prompts are compacted before reaching GPT-OSS,
  // keeping generation fast without changing the requested topic or count.
  {
    const compacted = compactPresentationGenerationRequest({
      messages: [
        { role: 'system', content: 'very long system contract' },
        {
          role: 'user',
          content: 'Konu: soğutucu akışkanlar\nİstenen Slayt Sayısı: 8\n"slides" listesinde tam olarak 8 öğe olmalı.',
        },
      ],
    });
    assert.equal(compacted.messages.length, 2);
    assert.match(compacted.messages[1].content, /exactly 8 concise Turkish presentation slides/);
    assert.match(compacted.messages[1].content, /soğutucu akışkanlar/);
    assert.match(compacted.messages[1].content, /exactly 3 substantive bullet points/);
    assert.match(compacted.messages[1].content, /compressor, valve, cooling tower/);
    assert.match(compacted.messages[1].content, /"must_include"/);
    assert.match(compacted.messages[1].content, /concrete visual brief/);
    console.log('✓ Test 5 Passed: presentation generation prompt is compacted');
  }

  console.log('All Cloudflare Worker mock tests passed successfully!\n');
}

runWorkerUnitTests().catch((err) => {
  console.error('Worker mock test failed:', err);
  process.exit(1);
});
