// Run only against a local Firestore emulator, never production:
// FIRESTORE_EMULATOR_HOST=127.0.0.1:8185 node --test test/presentation_atomic_rules_test.mjs
import assert from 'node:assert/strict';
import { test } from 'node:test';

const host = process.env.FIRESTORE_EMULATOR_HOST;
if (!host || !/^(127\.0\.0\.1|localhost):\d+$/.test(host)) {
  throw new Error('A loopback FIRESTORE_EMULATOR_HOST is required.');
}
const project = 'demo-sutols-atomic';
const documents = `projects/${project}/databases/(default)/documents`;
const base = `http://${host}/v1/${documents}`;
const runId = Date.now().toString(36);
const uid = `owner-${runId}`;
const token = (user) => {
  const encode = (value) => Buffer.from(JSON.stringify(value)).toString('base64url');
  return `${encode({ alg: 'none', typ: 'JWT' })}.${encode({
    iss: `https://securetoken.google.com/${project}`, aud: project,
    sub: user, user_id: user, email: `${user}@example.test`, email_verified: true,
    iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 3600,
    firebase: { sign_in_provider: 'password', identities: {} },
  })}.`;
};
async function request(path, { user = uid, method = 'GET', body } = {}) {
  return fetch(`${base}${path}`, {
    method,
    headers: { Authorization: `Bearer ${user === 'admin-seed' ? 'owner' : token(user)}`,
      'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined,
  });
}
const string = (value) => ({ stringValue: value });
const integer = (value) => ({ integerValue: `${value}` });
const create = (path, fields) => ({
  update: { name: `${documents}/${path}`, fields }, currentDocument: { exists: false },
});
function writes(id, { invalidSlide = false, owner = uid, count = 1 } = {}) {
  return [
    create(`presentations/${id}`, { userId: string(owner), slideCount: integer(30) }),
    ...Array.from({ length: 30 }, (_, index) => create(`presentations/${id}/slides/slide_${index}`,
      { order: invalidSlide && index === 29 ? string('invalid') : integer(index) })),
    create(`presentations/${id}/project/data`, { json: string('{}'), updatedByUid: string(owner) }),
    create(`users/${uid}/usage/2026-09-22`, { uid: string(uid), date: string('2026-09-22'), count: integer(count) }),
  ];
}

test('atomic presentation rules: 30 slides, rollback, ownership, quota, receipt', async () => {
  let response = await request(`/users/${uid}`, { user: 'admin-seed', method: 'PATCH',
    body: { fields: { tier: string('plus') } } });
  assert.equal(response.status, 200, await response.text());

  const invalid = `invalid-${runId}`;
  response = await request(':commit', { method: 'POST', body: { writes: writes(invalid, { invalidSlide: true }) } });
  assert.equal(response.status, 403, await response.text());
  assert.equal((await request(`/presentations/${invalid}`)).status, 404, 'failed commit must not leave parent');
  assert.equal((await request(`/users/${uid}/usage/2026-09-22`)).status, 404, 'failed commit must not charge quota');

  response = await request(':commit', { user: `outsider-${runId}`, method: 'POST',
    body: { writes: writes(`forged-${runId}`) } });
  assert.equal(response.status, 403, await response.text());

  const id = `success-${runId}`;
  response = await request(':commit', { method: 'POST', body: { writes: writes(id) } });
  assert.equal(response.status, 200, await response.text());
  assert.equal((await request(`/presentations/${id}`)).status, 200);
  assert.equal((await request(`/presentations/${id}/slides/slide_29`)).status, 200);
  assert.equal((await request(`/presentations/${id}/project/data`)).status, 200);
  assert.equal((await request(`/presentations/${id}`, { user: `outsider-${runId}` })).status, 403);
  response = await request(':commit', { user: `outsider-${runId}`, method: 'POST',
    body: { writes: [create(`presentations/${id}/slides/forged`, { order: integer(31) })] } });
  assert.equal(response.status, 403, await response.text());
  let usage = await (await request(`/users/${uid}/usage/2026-09-22`)).json();
  assert.equal(usage.fields.count.integerValue, '1');

  // A repeated create-only batch cannot charge twice or overwrite the deck.
  response = await request(':commit', { method: 'POST', body: { writes: writes(id) } });
  assert.notEqual(response.status, 200);
  usage = await (await request(`/users/${uid}/usage/2026-09-22`)).json();
  assert.equal(usage.fields.count.integerValue, '1');

  // Existing quota documents use updateTime CAS and increment exactly once.
  const secondId = `second-${runId}`;
  const second = writes(secondId, { count: 2 });
  second.at(-1).currentDocument = { updateTime: usage.updateTime };
  response = await request(':commit', { method: 'POST', body: { writes: second } });
  assert.equal(response.status, 200, await response.text());
  const stale = writes(`stale-${runId}`, { count: 2 });
  stale.at(-1).currentDocument = { updateTime: usage.updateTime };
  response = await request(':commit', { method: 'POST', body: { writes: stale } });
  assert.notEqual(response.status, 200);
  assert.equal((await request(`/presentations/stale-${runId}`)).status, 404);

  response = await request(`/users/${uid}/usage/2026-09-22`, { user: 'admin-seed', method: 'PATCH',
    body: { fields: { uid: string(uid), date: string('2026-09-22'), count: integer(15) } } });
  assert.equal(response.status, 200, await response.text());
  usage = await (await request(`/users/${uid}/usage/2026-09-22`)).json();
  const overLimit = writes(`over-limit-${runId}`);
  const quotaWrite = overLimit.at(-1);
  quotaWrite.update.fields.count = integer(16);
  quotaWrite.currentDocument = { updateTime: usage.updateTime };
  response = await request(':commit', { method: 'POST', body: { writes: overLimit } });
  assert.equal(response.status, 403, await response.text());
  assert.equal((await request(`/presentations/over-limit-${runId}`)).status, 404);
});
