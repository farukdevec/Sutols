/**
 * Cloudflare R2 bucket'ındaki tüm .glb dosyalarını listeler ve
 * functions/scripts/models-raw.json dosyasına yazar.
 *
 * Kullanım:
 *   1) functions/.env dosyasını .env.example'a göre oluşturun.
 *   2) npm run list:models
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

  const outPath = path.join(__dirname, "models-raw.json");
  fs.writeFileSync(outPath, JSON.stringify(models, null, 2) + "\n", "utf8");
  console.log(`✓ ${models.length} .glb model bulundu: ${outPath}`);
}

listGlbModels()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("R2 listeleme başarısız:", err);
      process.exit(1);
    });
