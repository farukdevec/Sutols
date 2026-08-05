/**
 * "models" koleksiyonunu örnek 3D model dokümanlarıyla doldurur.
 *
 * Kullanım:
 *   1) Yerel emülatör:
 *      firebase emulators:start --only firestore
 *      (ayrı bir terminalde) npm run seed:models
 *   2) Canlı proje:
 *      $env:GOOGLE_APPLICATION_CREDENTIALS="<hizmet-hesabi-anahtar.json>"
 *      npm run seed:models
 *
 * Script admin SDK kullandığı için Firestore kurallarını atlar.
 */

const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

// modelUrl ve thumbnailUrl: Cloudflare R2 public bucket linkleri.
// "pub-...r2.dev" kısmını kendi R2 hesap ID'nizle değiştirin.
const models = [
  {
    id: "model-taşıt-001",
    name: "Kırmızı Spor Araba",
    modelUrl:
      "https://pub-00000000000000000000000000000000.r2.dev/sutol/models/red-sports-car.glb",
    thumbnailUrl:
      "https://pub-00000000000000000000000000000000.r2.dev/sutol/thumbnails/red-sports-car.webp",
    tags: ["araba", "taşıt", "spor", "motorlu"],
    category: "taşıt",
    tier: "free",
  },
  {
    id: "model-mimari-001",
    name: "Modern Villa",
    modelUrl:
      "https://pub-00000000000000000000000000000000.r2.dev/sutol/models/modern-villa.glb",
    thumbnailUrl:
      "https://pub-00000000000000000000000000000000.r2.dev/sutol/thumbnails/modern-villa.webp",
    tags: ["bina", "mimari", "villa", "ev"],
    category: "mimari",
    tier: "plus",
  },
  {
    id: "model-doğa-001",
    name: "Çam Ağacı",
    modelUrl:
      "https://pub-00000000000000000000000000000000.r2.dev/sutol/models/pine-tree.glb",
    thumbnailUrl:
      "https://pub-00000000000000000000000000000000.r2.dev/sutol/thumbnails/pine-tree.webp",
    tags: ["ağaç", "doğa", "bitki", "orman"],
    category: "doğa",
    tier: "premium",
  },
];

async function seedModels() {
  const batch = db.batch();

  for (const {id, ...data} of models) {
    const ref = db.collection("models").doc(id);
    batch.set(ref, data, {merge: true});
  }

  await batch.commit();
  console.log(`✓ "models" koleksiyonuna ${models.length} doküman yazıldı:`);
  for (const {id, name} of models) {
    console.log(`  - ${id} (${name})`);
  }
}

seedModels()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("Seed başarısız:", err);
      process.exit(1);
    });
