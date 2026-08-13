/**
 * Etiketlenmiş 3D modelleri Firestore "models" koleksiyonuna yazar.
 *
 * Kullanım:
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="<hizmet-hesabi-anahtar.json>"
 *   npm run upload:tagged                               (models-tagged.json)
 *
 * Doküman id'si olarak dosya adı kullanılır (uzantısız ve nokta/özel
 * karakterler temizlenmiş haliyle). Batch yazım Firestore'un 500 işlem
 * limitine göre parçalara bölünür. thumbnailUrl verilmezse
 * https://assets.sutols.com/thumbnails/<dosya>.webp olarak türetilir.
 */

const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

const DEFAULT_TAGGED_PATH = path.join(__dirname, "models-tagged.json");
const MODEL_BASE_URL = "https://assets.sutols.com/";
const THUMB_BASE_URL = "https://assets.sutols.com/thumbnails/";
const BATCH_LIMIT = 500;

function toDocId(fileName) {
  return fileName
      .replace(/\.glb$/i, "")
      .replace(/[^a-zA-Z0-9\u00C0-\u017F_-]/g, "")
      .replace(/[.]/g, "-");
}

function toThumbnailUrl(fileName) {
  const base = fileName.replace(/\.glb$/i, "").split("/").pop();
  return `${THUMB_BASE_URL}${base}.webp`;
}

function toModelUrl(fileName) {
  return `${MODEL_BASE_URL}${fileName.split("/").pop()}`;
}

async function uploadModels() {
  const argPath = process.argv[2];
  const taggedPath = argPath ? path.resolve(process.cwd(), argPath) : DEFAULT_TAGGED_PATH;

  const items = JSON.parse(fs.readFileSync(taggedPath, "utf8"));

  if (!Array.isArray(items) || items.length === 0) {
    throw new Error(`${path.basename(taggedPath)} boş veya geçersiz.`);
  }

  let written = 0;
  const batches = Math.ceil(items.length / BATCH_LIMIT);

  for (let i = 0; i < batches; i++) {
    const batch = db.batch();
    const chunk = items.slice(i * BATCH_LIMIT, (i + 1) * BATCH_LIMIT);

    for (const item of chunk) {
      if (!item.fileName) {
        console.warn(`  ⚠ "fileName" eksik, atlandı: ${JSON.stringify(item)}`);
        continue;
      }

      const id = toDocId(item.fileName);
      const data = {
        name: item.name,
        modelUrl: toModelUrl(item.fileName),
        thumbnailUrl: toThumbnailUrl(item.fileName),
        tags: item.tags,
        category: item.category,
        tier: item.tier,
      };

      batch.set(db.collection("models").doc(id), data, {merge: true});
      written++;
    }

    await batch.commit();
    console.log(`✓ Batch ${i + 1}/${batches} tamamlandı.`);
  }

  console.log(`\n✓ "models" koleksiyonuna "${path.basename(taggedPath)}" dosyasından toplam ${written} doküman yazıldı.`);
}

uploadModels()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("Yükleme başarısız:", err);
      process.exit(1);
    });
