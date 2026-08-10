/**
 * 3B model kütüphanesini sıfırlar: Firestore'da YALNIZCA "models"
 * koleksiyonundaki dokümanları siler.
 *
 * GÜVENLİK:
 *   - Diğer koleksiyonlara (users vb.) kesinlikle dokunulmaz.
 *
 * Kullanım:
 *   export GOOGLE_APPLICATION_CREDENTIALS="<hizmet-hesabi-anahtar.json>"
 *   Önizleme (hiçbir şey silmez):
 *     node scripts/delete-firestore-models.js --dry-run
 *   Gerçek silme:
 *     node scripts/delete-firestore-models.js
 */

const admin = require("firebase-admin");

const DRY_RUN = process.argv.includes("--dry-run");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();
const COLLECTION = "models";
const BATCH_LIMIT = 500;

async function deleteModelsCollection() {
  const snapshot = await db.collection(COLLECTION).get();
  console.log(`"${COLLECTION}" koleksiyonundaki doküman sayısı: ${snapshot.size}`);

  if (snapshot.empty) {
    console.log("Koleksiyon zaten boş, yapılacak bir şey yok.");
    return;
  }

  if (DRY_RUN) {
    console.log("\n--dry-run: hiçbir şey silinmedi.");
    console.log("Silinecek dokümanlardan örnekler:");
    for (const doc of snapshot.docs.slice(0, 10)) {
      console.log(`  - ${doc.id} (${doc.data().name || "isimsiz"})`);
    }
    return;
  }

  let deleted = 0;
  let batch = db.batch();
  let batchCount = 0;

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    batchCount += 1;

    if (batchCount === BATCH_LIMIT) {
      await batch.commit();
      deleted += batchCount;
      batch = db.batch();
      batchCount = 0;
    }
  }

  if (batchCount > 0) {
    await batch.commit();
    deleted += batchCount;
  }

  console.log(`✓ ${deleted} doküman silindi.`);

  // Doğrulama
  const check = await db.collection(COLLECTION).limit(1).get();
  if (check.empty) {
    console.log(`✓ Doğrulama başarılı: "${COLLECTION}" koleksiyonu boş.`);
  } else {
    console.error(`✗ Doğrulama: "${COLLECTION}" koleksiyonunda hâlâ doküman var.`);
    process.exit(1);
  }
}

deleteModelsCollection()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Firestore silme başarısız:", err);
    process.exit(1);
  });
