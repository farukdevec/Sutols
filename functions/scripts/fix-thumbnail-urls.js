/**
 * models koleksiyonundaki TÜM dokümanların thumbnailUrl alanını yeniden
 * oluşturur: modelUrl'deki dosya adı (.glb -> .webp) kullanılarak
 *   https://assets.sutols.com/thumbnails/<dosya adı>.webp
 *
 * Kullanım:
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="<hizmet-hesabi-anahtar.json>"
 *   node scripts/fix-thumbnail-urls.js
 *
 * Batch yazım Firestore'un 500 işlem limitine göre parçalara bölünür.
 */

const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

const THUMB_BASE_URL = "https://assets.sutols.com/thumbnails/";
const BATCH_LIMIT = 500;

/** modelUrl'deki dosya adından (<ad>.glb) küçük resim adını üretir. */
function toThumbnailFileName(modelUrl) {
  const fileName = String(modelUrl || "")
      .split("/")
      .pop();
  return fileName.replace(/\.glb$/i, "");
}

async function fixThumbnailUrls() {
  const snapshot = await db.collection("models").get();
  const docs = snapshot.docs;
  if (docs.length === 0) {
    console.log("models koleksiyonunda doküman bulunamadı.");
    return;
  }

  let updated = 0;
  let skipped = 0;
  const batches = Math.ceil(docs.length / BATCH_LIMIT);

  for (let i = 0; i < batches; i++) {
    const batch = db.batch();
    const chunk = docs.slice(i * BATCH_LIMIT, (i + 1) * BATCH_LIMIT);

    for (const doc of chunk) {
      const data = doc.data() || {};
      const modelUrl = data.modelUrl;
      if (typeof modelUrl !== "string" || modelUrl.trim() === "") {
        console.warn(`  ⚠ modelUrl eksik, atlandı: ${doc.id}`);
        skipped++;
        continue;
      }

      const thumbName = toThumbnailFileName(modelUrl);
      if (thumbName.trim() === "") {
        console.warn(`  ⚠ modelUrl'den dosya adı çıkarılamadı: ${doc.id}`);
        skipped++;
        continue;
      }

      batch.update(doc.ref, {
        thumbnailUrl: THUMB_BASE_URL + thumbName + ".webp",
      });
      updated++;
    }

    await batch.commit();
    console.log(`✓ Batch ${i + 1}/${batches} tamamlandı.`);
  }

  console.log(`\n✓ Toplam ${updated} doküman güncellendi (${skipped} atlandı).`);
}

fixThumbnailUrls()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("Güncelleme başarısız:", err);
      process.exit(1);
    });