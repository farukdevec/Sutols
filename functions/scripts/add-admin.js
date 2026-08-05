/**
 * Belirtilen UID için "admins/{uid}" dokümanı oluşturur.
 *
 * Kullanım:
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="<hizmet-hesabi-anahtar.json>"
 *   npm run add:admin -- <uid>
 *
 * Script admin SDK kullandığı için Firestore kurallarını atlar.
 */

const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

async function main() {
  const uid = process.argv[2];
  if (!uid) {
    console.error("Hata: UID parametresi eksik.");
    console.error('Kullanım: npm run add:admin -- <uid>');
    process.exit(1);
  }

  const ref = db.collection("admins").doc(uid);
  await ref.set({
    addedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`admins/${uid} dokümanı oluşturuldu.`);
  process.exit(0);
}

main().catch((err) => {
  console.error("Admin ekleme hatası:", err);
  process.exit(1);
});
