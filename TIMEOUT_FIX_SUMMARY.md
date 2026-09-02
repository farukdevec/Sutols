# Timeout Alignment Fix - Summary

## Problem

The NVIDIA model requests were timing out at 75 seconds, causing slow presentation generation. The logs showed:

```
[SUTOL AI][NVIDIA]
Model: nvidia/nemotron-3-super-120b-a12b
Key: key1
Attempt: 1
Status: TIMEOUT
Latency: 75.02s (75015ms)
Action: FALLBACK_TO_KEY2

[SUTOL AI][NVIDIA]
Model: openai/gpt-oss-120b
Key: key1
Attempt: 2
Status: SUCCESS (200)
Latency: 13.24s (13243ms)
```

## Root Cause

**Timeout Mismatch**: The proxy server timeout (90s) was longer than the Dart client timeout (75s), causing:

1. Client sends request to proxy with 75s timeout
2. Proxy starts NVIDIA API call with 90s timeout
3. Client gives up at 75s and throws `TimeoutException`
4. Proxy is still waiting until 90s (wasting resources)
5. Client tries next model/key, adding unnecessary latency

## Solution

### 1. Proxy Server Changes (`sutol-model-proxy/src/index.js`)

**Before:**
```javascript
function getModelTimeoutMs(modelName) {
  if (!modelName) return 60000;
  const m = modelName.toLowerCase();
  if (m.includes("super") || m.includes("120b")) return 90000;  // 90s
  // ...
}
```

**After:**
```javascript
function getModelTimeoutMs(modelName) {
  if (!modelName) return 60000;
  const m = modelName.toLowerCase();
  // Align with Dart client timeouts: super/120b = 75s, llama-3.3/70b = 60s, etc.
  if (m.includes("super") || m.includes("120b")) return 75000;  // 75s
  if (m.includes("llama-3.3") || m.includes("70b")) return 60000;
  if (m.includes("gpt-oss-20b") || m.includes("nano")) return 40000;
  if (m.includes("llama-3.1") || m.includes("8b")) return 30000;
  return 60000;
}
```

**Grok timeout also updated:**
- Before: 25s
- After: 30s (to align with Dart client)

### 2. Dart Client Changes (`lib/services/ai_model_config.dart`)

**Before:**
```dart
static const Duration timeoutSuper = Duration(seconds: 75);
static const Duration timeoutGptOss120b = Duration(seconds: 75);
static const Duration timeoutLlama33 = Duration(seconds: 60);
// ...
```

**After:**
```dart
// Proxy timeout: super/120b=75s, llama-3.3/70b=60s, gpt-oss-20b/nano=40s, llama-3.1/8b=30s
// Client timeout = Proxy timeout + 5s buffer to prevent race conditions
static const Duration timeoutSuper = Duration(seconds: 80);
static const Duration timeoutGptOss120b = Duration(seconds: 80);
static const Duration timeoutLlama33 = Duration(seconds: 65);
static const Duration timeoutGptOss20b = Duration(seconds: 45);
static const Duration timeoutNano = Duration(seconds: 45);
static const Duration timeoutLlama31 = Duration(seconds: 35);
static const Duration timeoutGemini = Duration(seconds: 35);
static const Duration timeoutGrok = Duration(seconds: 35);
static const Duration timeoutDefaultNvidia = Duration(seconds: 65);
```

## Timeout Alignment Table

| Model | Proxy Timeout | Client Timeout | Buffer |
|-------|---------------|----------------|--------|
| nvidia/nemotron-3-super-120b-a12b | 75s | 80s | +5s |
| openai/gpt-oss-120b | 75s | 80s | +5s |
| meta/llama-3.3-70b-instruct | 60s | 65s | +5s |
| openai/gpt-oss-20b | 40s | 45s | +5s |
| nvidia/nemotron-3-nano-30b-a3b | 40s | 45s | +5s |
| meta/llama-3.1-8b-instruct | 30s | 35s | +5s |
| grok-* | 30s | 35s | +5s |
| gemini-* | 30s | 35s | +5s |

## Benefits

1. **Prevents Race Conditions**: Client timeout is always 5s longer than proxy timeout
2. **Reduces Wasted Resources**: Proxy doesn't keep running after client has given up
3. **Faster Failover**: When proxy times out, client gets the error immediately and can try next model
4. **Consistent Behavior**: All timeouts are now aligned between client and server

## Expected Improvement

- **Before**: nemotron-super times out at 75s, then tries next model
- **After**: Both client and proxy agree on 75s, failover happens at same time
- **Result**: ~5-10s faster total request time for fallback scenarios

## Testing

Run the test scripts to verify:

```bash
# Test proxy timeouts
node test_proxy_timeout.js

# Test Dart timeouts (requires Flutter)
# dart run test_timeout_alignment.dart
```

## Files Changed

1. `sutol-model-proxy/src/index.js` - Proxy timeout function updated
2. `lib/services/ai_model_config.dart` - Dart client timeouts updated with buffer
