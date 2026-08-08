const fs = require("fs");
const path = require("path");
const {S3Client, ListObjectsV2Command, GetBucketCorsCommand, HeadObjectCommand} = require("@aws-sdk/client-s3");

function loadEnv() {
  if (process.env.R2_ACCOUNT_ID) return;
  const p = path.join(process.cwd(), ".env");
  if (!fs.existsSync(p)) return;
  for (const line of fs.readFileSync(p, "utf8").split(/\r?\n/)) {
    const t = line.trim();
    if (!t || t.startsWith("#")) continue;
    const eq = t.indexOf("=");
    if (eq === -1) continue;
    const k = t.slice(0, eq).trim();
    let v = t.slice(eq + 1).trim();
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
      v = v.slice(1, -1);
    }
    if (!(k in process.env)) process.env[k] = v;
  }
}

loadEnv();

const s3 = new S3Client({
  region: "auto",
  endpoint: process.env.R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

(async () => {
  try {
    const list = await s3.send(new ListObjectsV2Command({Bucket: process.env.R2_BUCKET_NAME, MaxKeys: 5}));
    console.log("objeler:", (list.Contents || []).map((o) => o.Key).join(", "));
  } catch (e) {
    console.log("LIST HATA:", e.message);
  }
  try {
    const cors = await s3.send(new GetBucketCorsCommand({Bucket: process.env.R2_BUCKET_NAME}));
    console.log("CORS:", JSON.stringify(cors.CORSRules));
  } catch (e) {
    console.log("CORS HATA:", e.message);
  }
  try {
    const head = await s3.send(new HeadObjectCommand({Bucket: process.env.R2_BUCKET_NAME, Key: "yolcu_ucagi.glb"}));
    console.log("yolcu_ucagi.glb: OK", head.ContentLength, "byte");
  } catch (e) {
    console.log("HEAD HATA:", e.message);
  }
})();
