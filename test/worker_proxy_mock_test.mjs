import assert from 'node:assert/strict';
import worker from '../sutol-model-proxy/src/index.js';

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

  console.log('All Cloudflare Worker mock tests passed successfully!\n');
}

runWorkerUnitTests().catch((err) => {
  console.error('Worker mock test failed:', err);
  process.exit(1);
});
