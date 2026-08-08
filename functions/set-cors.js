const fs = require("fs");
const path = require("path");
const {S3Client, PutBucketCorsCommand, GetBucketCorsCommand, GetBucketPolicyCommand} = require("@aws-sdk/client-s3");

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
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) v = v.slice(1, -1);
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
  const rules = [
    {
      AllowedOrigins: ["*"],
      AllowedMethods: ["GET", "HEAD"],
      AllowedHeaders: ["*"],
      ExposeHeaders: ["ETag"],
      MaxAgeSeconds: 3600,
    },
  ];
  try {
    await s3.send(new PutBucketCorsCommand({Bucket: process.env.R2_BUCKET_NAME, CORSConfiguration: {CORSRules: rules}}));
    console.log("PutBucketCors: OK");
  } catch (e) {
    console.log("PutBucketCors HATA:", e.message);
    return;
  }
  try {
    const cors = await s3.send(new GetBucketCorsCommand({Bucket: process.env.R2_BUCKET_NAME}));
    console.log("GetBucketCors:", JSON.stringify(cors.CORSRules));
  } catch (e) {
    console.log("GetBucketCors HATA:", e.message);
  }
})();
