/**
 * Cloudflare R2 bucket'ındaki .glb dosyalarını listeler ve Firestore
 * "models" koleksiyonunda HENÜZ karşılığı bulunmayanları
 * functions/scripts/models-raw-new.json dosyasına yazar
 * (mevcut models-raw.json'a dokunulmaz).
 *
 * Eşleştirme: Firestore doküman ID'si, dosya adının ".glb" uzantısız
 * haliyle karşılaştırılır (örn. "01_SWOT_Analiz_Kupu.glb" <-> "01_SWOT_Analiz_Kupu").
 *
 * Kullanım:
 *   node scripts/list-r2-models.js
 *
 * Çıktı formatı:
 *   [
 *     { "fileName": "koltuk-modern-gri.glb", "modelUrl": "https://..." },
 *     ...
 *   ]
 */

const fs = require("fs");
const path = require("path");
const {S3Client, ListObjectsV2Command} = require("@aws-sdk/client-s3");
const {initializeApp, cert} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

function loadEnv() {
  // process.env'de değer varsa .env okumaya gerek yok.
  if (process.env.R2_ACCOUNT_ID) return;

  const envPath = path.join(__dirname, "..", ".env");
  if (!fs.existsSync(envPath)) return;

  for (const line of fs.readFileSync(envPath, "utf8").split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;

    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;

    const key = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();

    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (!(key in process.env)) process.env[key] = value;
  }
}

loadEnv();

const REQUIRED_ENV = [
  "R2_ACCOUNT_ID",
  "R2_ACCESS_KEY_ID",
  "R2_SECRET_ACCESS_KEY",
  "R2_BUCKET_NAME",
  "R2_ENDPOINT",
];

const missing = REQUIRED_ENV.filter((key) => !process.env[key]);
if (missing.length > 0) {
  console.error(`Eksik R2 ortam değişkenleri: ${missing.join(", ")}`);
  console.error("functions/.env.example dosyasındaki talimatları izleyin.");
  process.exit(1);
}

const bucket = process.env.R2_BUCKET_NAME;
const publicBaseUrl =
  process.env.R2_PUBLIC_BASE_URL ||
  `https://pub-${process.env.R2_ACCOUNT_ID}.r2.dev`;

const s3 = new S3Client({
  region: "auto",
  endpoint: process.env.R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

function resolveCredentials() {
  const keyPath = path.join(__dirname, "..", "sutols-firebase-adminsdk-fbsvc-1d50cda9f7.json");
  if (fs.existsSync(keyPath)) {
    return JSON.parse(fs.readFileSync(keyPath, "utf8"));
  }
  console.error("HATA: servis hesabi anahtari bulunamadi (sutols-firebase-adminsdk-fbsvc-1d50cda9f7.json).");
  process.exit(1);
}

async function listGlbModels() {
  const models = [];
  let continuationToken;

  do {
    const result = await s3.send(
      new ListObjectsV2Command({
        Bucket: bucket,
        ContinuationToken: continuationToken,
      })
    );

    for (const obj of result.Contents || []) {
      if (obj.Key.toLowerCase().endsWith(".glb")) {
        models.push({
          fileName: obj.Key,
          modelUrl: `${publicBaseUrl}/${bucket}/${obj.Key}`,
        });
      }
    }

    continuationToken = result.IsTruncated
      ? result.NextContinuationToken
      : undefined;
  } while (continuationToken);

  return models;
}

async function fetchFirestoreModelIds() {
  const app = initializeApp({credential: cert(resolveCredentials())});
  const db = getFirestore(app);
  const snapshot = await db.collection("models").get();
  await app.delete();
  return new Set(snapshot.docs.map((doc) => doc.id));
}

async function main() {
  const r2Models = await listGlbModels();
  const firestoreIds = await fetchFirestoreModelIds();

  const newModels = r2Models.filter((model) => {
    const baseName = model.fileName.split("/").pop().replace(/\.glb$/i, "");
    return !firestoreIds.has(baseName);
  });

  const outPath = path.join(__dirname, "models-raw-new.json");
  fs.writeFileSync(outPath, JSON.stringify(newModels, null, 2) + "\n", "utf8");
  console.log(
    `✓ R2'de ${r2Models.length} .glb dosya, Firestore'da ${firestoreIds.size} model kaydı var.`
  );
  console.log(`✓ Firestore'da kaydı OLMAYAN ${newModels.length} yeni dosya: ${outPath}`);
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("Listeleme başarısız:", err);
      process.exit(1);
    });