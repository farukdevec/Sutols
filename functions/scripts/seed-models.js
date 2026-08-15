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

// modelUrl ve thumbnailUrl: Cloudflare Worker (sutol-model-proxy) üzerinden
// https://assets.sutols.com/<object-key> ve /thumbnails/<object-key>.webp
// olarak servis edilir. R2 bucket public değildir; doğrudan r2.dev erişimi
// kapalıdır. Worker Origin/Referer bazlı erişim kontrolü uygular.
const models = [
  {
    id: "model-taşıt-001",
    name: "Kırmızı Spor Araba",
    modelUrl: "https://assets.sutols.com/red-sports-car.glb",
    thumbnailUrl:
      "https://assets.sutols.com/thumbnails/red-sports-car.webp",
    tags: ["araba", "taşıt", "spor", "motorlu"],
    category: "taşıt",
    tier: "free",
  },
  {
    id: "model-mimari-001",
    name: "Modern Villa",
    modelUrl: "https://assets.sutols.com/modern-villa.glb",
    thumbnailUrl:
      "https://assets.sutols.com/thumbnails/modern-villa.webp",
    tags: ["bina", "mimari", "villa", "ev"],
    category: "mimari",
    tier: "plus",
  },
  {
    id: "model-doğa-001",
    name: "Çam Ağacı",
    modelUrl: "https://assets.sutols.com/pine-tree.glb",
    thumbnailUrl:
      "https://assets.sutols.com/thumbnails/pine-tree.webp",
    tags: ["ağaç", "doğa", "bitki", "orman"],
    category: "doğa",
    tier: "plus",
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
