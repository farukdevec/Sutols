/**
 * "models" koleksiyonundaki TUM dokumanlarin modelUrl ve thumbnailUrl
 * alanlarini "https://assets.sutols.com/<fileName>" formatinda yeniden uretir.
 *
 * fileName: Firestore'da field olarak tutulmuyor; mevcut modelUrl'in dosya
 * adi kismi (son "/" sonrasi, orn. "01_SWOT_Analiz_Kupu.glb") kullanilir.
 *
 * Kullanim:
 *   node scripts/fix-model-urls.js
 *
 * Script admin SDK kullandigi icin Firestore kurallarini atlar.
 * Batch yazimlari 500'lu dilimler halinde uygulanir.
 */

const fs = require("fs");
const path = require("path");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

function resolveCredentials() {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return { applicationDefault: true };
  }
  const keyPath = path.join(__dirname, "..", "sutols-firebase-adminsdk-fbsvc-1d50cda9f7.json");
  if (fs.existsSync(keyPath)) {
    return JSON.parse(fs.readFileSync(keyPath, "utf8"));
  }
  console.error("HATA: servis hesabi anahtari bulunamadi. GOOGLE_APPLICATION_CREDENTIALS ayarlayin veya anahtar dosyasini functions/ koyun.");
  process.exit(1);
}

const BASE_URL = "https://assets.sutols.com";
const BATCH_SIZE = 500;

function decodeFileName(value) {
  try {
    return decodeURIComponent(value);
  } catch (_) {
    return value;
  }
}

(async () => {
  const cred = resolveCredentials();
  const app = initializeApp(cred.applicationDefault
    ? { credential: require("firebase-admin/app").applicationDefault() }
    : { credential: cert(cred) });
  const db = getFirestore(app);

  const snap = await db.collection("models").get();
  const total = snap.size;

  let updated = 0;
  let unchanged = 0;
  let skipped = 0;
  const anomalies = [];

  const updates = [];
  for (const doc of snap.docs) {
    const data = doc.data();
    const currentUrl = data.modelUrl || "";
    const encodedFileName = currentUrl.slice(currentUrl.lastIndexOf("/") + 1);
    const fileName = decodeFileName(encodedFileName);

    if (!fileName || !currentUrl.includes("/")) {
      skipped++;
      continue;
    }

    const newUrl = `${BASE_URL}/${fileName}`;
    const thumbnailName = fileName.replace(/\.glb$/i, ".webp");
    const newThumb = `${BASE_URL}/thumbnails/${thumbnailName}`;

    if (currentUrl === newUrl && data.thumbnailUrl === newThumb) {
      unchanged++;
      continue;
    }

    if (!currentUrl.startsWith("https://pub-1380bf0474d81b7754ca92aabc18a4d4.r2.dev/")) {
      anomalies.push(`${doc.id} (eski: ${currentUrl})`);
    }

    updates.push({ ref: doc.ref, newUrl, newThumb });
  }

  for (let i = 0; i < updates.length; i += BATCH_SIZE) {
    const chunk = updates.slice(i, i + BATCH_SIZE);
    const batch = db.batch();
    for (const u of chunk) {
      batch.set(u.ref, { modelUrl: u.newUrl, thumbnailUrl: u.newThumb }, { merge: true });
    }
    await batch.commit();
    updated += chunk.length;
    console.log(`Batch ${Math.floor(i / BATCH_SIZE) + 1}/${Math.ceil(updates.length / BATCH_SIZE)}: ${chunk.length} dokuman islendi`);
  }

  console.log("---");
  console.log(`Toplam dokuman: ${total}`);
  console.log(`Guncellenen: ${updated}`);
  console.log(`Degismeyen: ${unchanged}`);
  console.log(`Atlanan (modelUrl yok): ${skipped}`);
  if (anomalies.length > 0) {
    console.log(`UYARI - beklenmeyen hostlu dokumanlar (${anomalies.length}):`);
    for (const a of anomalies) console.log(`  ${a}`);
  }
  process.exit(0);
})().catch((e) => {
  console.error("HATA:", e.message);
  process.exit(1);
});
