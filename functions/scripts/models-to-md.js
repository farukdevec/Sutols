/**
 * Firestore "models" koleksiyonundaki tum modelleri kategoriye gore
 * etiketleri ve tier'lariyla birlikte "tool/models-katalogu.md" dosyasina
 * yazar.
 *
 * Kullanim:
 *   node scripts/models-to-md.js
 */

const fs = require("fs");
const path = require("path");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const keyPath = path.join(__dirname, "..", "sutols-firebase-adminsdk-fbsvc-1d50cda9f7.json");
const app = initializeApp({ credential: cert(JSON.parse(fs.readFileSync(keyPath, "utf8"))) });
const db = getFirestore(app);

(async () => {
  const snap = await db.collection("models").get();
  const docs = snap.docs.slice().sort((a, b) => {
    const ac = String(a.data().category || "").localeCompare(String(b.data().category || ""), "tr");
    if (ac !== 0) return ac;
    return String(a.data().name || a.id).localeCompare(String(b.data().name || b.id), "tr");
  });
  const lines = [];
  lines.push("# Sutol 3D Model Katalogu");
  lines.push("");
  lines.push(`**Toplam ${snap.size} model** (Firestore \`models\` koleksiyonu).`);
  lines.push("");
  let cur = "";
  for (const d of docs) {
    const x = d.data();
    const cat = String(x.category || "kategorisiz").trim();
    const name = String(x.name || d.id).trim();
    const tier = String(x.tier || "free").trim();
    const tags = Array.isArray(x.tags) ? x.tags.join(", ") : String(x.tags || "");
    if (cat !== cur) {
      cur = cat;
      lines.push(`## ${cur}`);
      lines.push("");
    }
    lines.push(`- **${name}** — tier: \`${tier}\`${tags ? ` (etiketler: ${tags})` : ""}`);
  }
  const out = path.join(__dirname, "..", "..", "tool", "models-katalogu.md");
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, lines.join("\n") + "\n", "utf8");
  console.log("Yazildi:", out);
  console.log("Model sayisi:", snap.size);
  process.exit(0);
})().catch((e) => {
  console.error("HATA:", e.message);
  process.exit(1);
});