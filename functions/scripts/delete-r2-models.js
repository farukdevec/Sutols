/**
 * 3B model kütüphanesini sıfırlar: models-tagged.json'da listelenen
 * .glb dosyalarını Cloudflare R2 bucket'ından TEK TEK siler.
 *
 * GÜVENLİK:
 *   - Sadece models-tagged.json'daki 1037 dosya silinir.
 *   - Bucket'taki başka hiçbir nesneye dokunulmaz.
 *   - Bucket'ın kendisi silinmez.
 *
 * Kullanım:
 *   1) functions/.env dosyasını .env.example'a göre doldurun.
 *   2) Önizleme (hiçbir şey silmez):
 *        node scripts/delete-r2-models.js --dry-run
 *   3) Gerçek silme:
 *        node scripts/delete-r2-models.js
 */

const fs = require("fs");
const path = require("path");
const {
  S3Client,
  DeleteObjectsCommand,
  ListObjectsV2Command,
} = require("@aws-sdk/client-s3");

const DRY_RUN = process.argv.includes("--dry-run");

function loadEnv() {
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

const s3 = new S3Client({
  region: "auto",
  endpoint: process.env.R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

// Silinecek dosya listesi: YALNIZCA models-tagged.json'daki kayıtlar.
const taggedPath = path.join(__dirname, "models-tagged.json");
const tagged = JSON.parse(fs.readFileSync(taggedPath, "utf8"));
const keysToDelete = tagged.map((m) => m.fileName);

async function listAllBucketKeys() {
  const keys = [];
  let continuationToken;

  do {
    const result = await s3.send(
      new ListObjectsV2Command({
        Bucket: bucket,
        ContinuationToken: continuationToken,
      })
    );

    for (const obj of result.Contents || []) {
      keys.push(obj.Key);
    }

    continuationToken = result.IsTruncated
      ? result.NextContinuationToken
      : undefined;
  } while (continuationToken);

  return keys;
}

async function deleteModels() {
  console.log(`Silinecek dosya sayısı (models-tagged.json): ${keysToDelete.length}`);

  const existingKeys = new Set(await listAllBucketKeys());
  console.log(`Bucket'taki toplam nesne sayısı: ${existingKeys.size}`);

  const present = keysToDelete.filter((k) => existingKeys.has(k));
  const notFound = keysToDelete.filter((k) => !existingKeys.has(k));
  console.log(`Bucket'ta mevcut olan: ${present.length}`);
  console.log(`Bucket'ta bulunamayan (zaten yok): ${notFound.length}`);

  const untouched = [...existingKeys].filter(
    (k) => !keysToDelete.includes(k)
  );
  console.log(
    `DOKUNULMAYACAK diğer nesneler: ${untouched.length}` +
      (untouched.length > 0
        ? `\n  örnek: ${untouched.slice(0, 5).join(", ")}`
        : "")
  );

  if (DRY_RUN) {
    console.log("\n--dry-run: hiçbir şey silinmedi.");
    console.log(`Gerçek silmede ${present.length} dosya silinecek.`);
    return;
  }

  // S3 DeleteObjects: istek başına en fazla 1000 anahtar.
  let deleted = 0;
  for (let i = 0; i < present.length; i += 1000) {
    const chunk = present.slice(i, i + 1000);
    const result = await s3.send(
      new DeleteObjectsCommand({
        Bucket: bucket,
        Delete: {
          Objects: chunk.map((Key) => ({Key})),
          Quiet: false,
        },
      })
    );

    deleted += (result.Deleted || []).length;

    if (result.Errors && result.Errors.length > 0) {
      console.error("Silme hataları:");
      for (const err of result.Errors) {
        console.error(`  - ${err.Key}: ${err.Code} ${err.Message}`);
      }
    }
  }

  console.log(`\n✓ ${deleted} dosya silindi.`);

  // Doğrulama: silinenlerden bucket'ta kalan var mı?
  const remaining = new Set(await listAllBucketKeys());
  const stillThere = keysToDelete.filter((k) => remaining.has(k));
  if (stillThere.length === 0) {
    console.log("✓ Doğrulama başarılı: listedeki hiçbir model bucket'ta kalmadı.");
  } else {
    console.error(`✗ Doğrulama: ${stillThere.length} dosya hâlâ bucket'ta:`);
    for (const k of stillThere.slice(0, 10)) console.error(`  - ${k}`);
    process.exit(1);
  }

  console.log(
    `✓ Bucket'ta kalan diğer nesneler: ${remaining.size} (dokunulmadı)`
  );
}

deleteModels()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("R2 silme başarısız:", err);
    process.exit(1);
  });
