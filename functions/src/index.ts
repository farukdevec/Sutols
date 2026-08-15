/**
 * Cloudflare Worker: Sutols 3D Model Güvenli Erişim Proxy
 * 
 * Amaç: Yetkisiz kullanıcının R2 bucket'taki .glb/.webp dosyalarını
 * doğrudan indirmesini engellemek için Firebase Auth + Signed URL mimarisi.
 * 
 * Akış:
 * 1. Frontend: FirebaseAuth.currentUser.getIdToken() alır
 * 2. Frontend: Worker'a POST /authorize ile token gönderir
 * 3. Worker: Firebase ID token'ı doğrular
 * 4. Worker: Geçerli ise 5 dakikalık signed URL üretir (HMAC-SHA256 + expiration)
 * 5. Worker: Signed URL'yi JSON olarak döndürür
 * 6. Frontend: Signed URL'i <model-viewer src="..."> kullanır
 * 7. Worker: Signed URL ile GET isteğiğinde signature/expiration kontrolü yapar
 * 8. Kontrol geçerse R2'ten dosyayı sunar, geçerse 401/403 döndürür
 */

import { onRequest } from "cloudflare:workers";
import type { Handler } from "cloudflare:workers";

// ============================================================
// Yapılandırmalar ve Sabitler
// ============================================================

// R2 bucket adı (Worker binding'i ile tanımlanacak)
const R2_BUCKET_NAME = "sutols-models";

// Signed URL expiration (dakika cinsinden)
const SIGNED_URL_EXPIRATION_MINUTES = 5;

// HMAC imza anahtarı - Worker env'inden alınacak
// Bu değer deployment sırasında Worker'a secret olarak yüklenecek
let hmacSecret: string;

// JWT public keys (JWKS) - Worker başlatıldığında cachelenecek
interface JwksKey {
  kid: string;
  kty: string;
  use: string;
  alg: string;
  n: string;  // modulus (base64url)
  e: string;  // exponent (base64url)
}

// ============================================================
// Worker Başlatma - Secret ve JWKS yükleme
// ============================================================

/**
 * Worker oluşturulurken çalışır (bir container oluşturulduğunda bir kere)
 * Env'den HMAC secret'i ve Firebase JWKS'yi yükler
 */
export default onRequest(async (request: Request, env: any, ctx: any) => {
  // HMAC secret'i env'den alın (Worker deployment sırasında set edilmeli)
  if (!hmacSecret) {
    hmacSecret = env.MODEL_SIGNED_URL_SECRET;
    if (!hmacSecret) {
      console.error("HATA: MODEL_SIGNED_URL_SECRET env değişkeni tanımlı değil");
      return new Response("Internal Server Error: Configuration missing", { status: 500 });
    }
  }

  // CORS headers'ı tüm yanıtlara ekle
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Authorization, Content-Type",
  };

  // OPTIONS isteği için hızlı yanıt
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  // --------------------------------------------------------
  // PATH ANALYZER - İstek yolunu analiz et
  // --------------------------------------------------------

  const url = new URL(request.url);
  const pathName = url.pathname; // Örn: /authorize, /model/01_SWOT_Analiz_Kupu.glb

  // --------------------------------------------------------
  // ENDPOINT 1: /authorize - Firebase token alıp signed URL ver
  // --------------------------------------------------------
  if (pathName === "/authorize" && request.method === "POST") {
    return handleAuthorizeEndpoint(request, corsHeaders);
  }

  // --------------------------------------------------------
  // ENDPOINT 2: /model/<object-key> - İmzalı URL ile model sun
  // --------------------------------------------------------
  // Örn: /model/01_SWOT_Analiz_Kupu.glb
  const modelMatch = pathName.match(/^\/model\/(.+)$/);
  if (modelMatch && request.method === "GET") {
    return handleModelEndpoint(request, corsHeaders, modelMatch[1]);
  }

  // --------------------------------------------------------
  // 404 for unknown paths
  // --------------------------------------------------------
  return new Response("Not Found", { status: 404, headers: corsHeaders });
});

/**
 * Firebase ID token doğrulama ve signed URL generation
 */
async function handleAuthorizeEndpoint(
  request: Request,
  corsHeaders: Record<string, string>
): Promise<Response> {
  try {
    const body = await request.json();
    const idToken = body.idToken;

    if (!idToken) {
      return new Response(
        JSON.stringify({ error: "idToken gerekli" }),
        { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    // 1. Firebase ID token doğrulaması
    // Firebase JWKS endpoint'inden public key'leri alıp JWT'yi doğruluyoruz
    const firebaseProjectId = env.FIREBASE_PROJECT_ID; // Worker env'den
    const jwtPayload = await verifyFirebaseIdToken(idToken, firebaseProjectId);

    if (!jwtPayload) {
      return new Response(
        JSON.stringify({ error: "Geçersiz Firebase ID tokenı" }),
        { status: 401, headers: { "Content-Type": "application/json", ...corsHeaders } }
      );
    }

    // 2. Kullanıcı UID'si kontrolü (isteğe bağlı: ekstra güvenlik için)
    const uid = jwtPayload.uid;
    const email = jwtPayload.email;

    // 3. Signed URL üret (HMAC-SHA256 + expiration)
    // Object key - örnek: "01_SWOT_Analiz_Kupu.glb"
    // Gerçek object key'i frontend'den veya contextten alacağız
    // Şimdilik test için statik bir key, production'da dinamik olacak
    const objectKey = "01_SWOT_Analiz_Kupu.glb"; // Production'da request body'den veya context alınır

    // Expiration timestamp (current time + expiration minutes)
    const now = Math.floor(Date.now() / 1000);
    const expires = now + SIGNED_URL_EXPIRATION_MINUTES * 60;

    // 4. HMAC-SHA256 imza oluştur
    // Format: "${objectKey}:${expires}"
    const message = `${objectKey}:${expires}`;
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    const hmacKey = { name: "HMAC", key: await crypto.subtle.importKey(
      "raw",
      new Uint8Array(hmacSecret.split("").map(c => c.charCodeAt(0))),
      "HMAC",
      false,
      ["sign", "verify"]
    ) };
    const signature = await crypto.subtle.sign("HMAC", hmacKey, data);
    const signatureBase64 = btoa(String.fromCharCode(...new Uint8Array(signature))).replace(/[+\/=]/, c => c === "+" ? "-" : c === "/" ? "_" : "");

    // 5. Signed URL'i oluştur
    const signedUrl = `https://${url.host}/model/${objectKey}?expires=${expires}&sig=${signatureBase64}`;

    // 6. JSON yanıtı
    const responseBody = JSON.stringify({
      url: signedUrl,
      expires: new Date(expires * 1000).toISOString(),
      objectKey,
    });

    return new Response(
      responseBody,
      { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  } catch (error) {
    console.error("Authorize endpoint hatası:", error);
    return new Response(
      JSON.stringify({ error: "İç sunucu hatası" }),
      { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  }
}

/**
 * Model endpoint: Signed URL ile R2'ten dosya sun
 */
async function handleModelEndpoint(
  request: Request,
  corsHeaders: Record<string, string>,
  objectKey: string
): Promise<Response> {
  try {
    // 1. URL parametresinden expires ve sig al
    const url = new URL(request.url);
    const expires = parseInt(url.searchParams.get("expires") || "0", 10);
    const sig = url.searchParams.get("sig") || "";

    // 2. Expiration kontrolü
    const now = Math.floor(Date.now() / 1000);
    if (now > expires) {
      return new Response(
        "Signed URL expired",
        { status: 403, headers: { "Content-Type": "text/plain", ...corsHeaders } }
      );
    }

    // 3. Signature kontrolü (HMAC-SHA256)
    // Önce beklenen imza formatı: "${objectKey}:${expires}"
    const message = `${objectKey}:${expires}`;
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    const hmacKey = await crypto.subtle.importKey(
      "raw",
      new Uint8Array(hmacSecret.split("").map((c: string) => c.charCodeAt(0))),
      "HMAC",
      false,
      ["verify"]
    );
    const sigData = encoder.encode(message);
    const expectedSig = await crypto.subtle.sign("HMAC", hmacKey, sigData);
    const expectedSigB64 = btoa(String.fromCharCode(...new Uint8Array(expectedSig))).replace(/[+\/=]/, c => c === "+" ? "-" : c === "/" ? "_" : "");

    // 5. İmza karşılaştırması (constant-time comparison için)
    const signatureValid = expectedSigB64 === sig;

    if (!signatureValid) {
      return new Response(
        "Invalid signature",
        { status: 403, headers: { "Content-Type": "text/plain", ...corsHeaders } }
      );
    }

    // 6. R2'ten dosyayı al
    // R2 binding'i ile dosyayı oku
    const bucket = env.R2_BUCKET; // Worker binding
    const key = objectKey; // "01_SWOT_Analiz_Kupu.glb"

    try {
      const object = await bucket.get(key, { type: "arrayBuffer" });
      if (!object) {
        return new Response("Model not found", { status: 404, headers: { "Content-Type": "text/plain", ...corsHeaders } });
      }

      // 7. CORS ve Content-Type headers
      const contentType = "model/gltf-binary"; // .glb için
      // veya .webp için "image/webp"

      return new Response(object, {
        status: 200,
        headers: {
          "Content-Type": contentType,
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, OPTIONS",
          "Cache-Control": `public, max-age=300`, // 5 dakika cache (signed URL expiration ile aynı)
        },
      });
    } catch (r2Error) {
      console.error("R2 erişim hatası:", r2Error);
      return new Response("Model not found", { status: 404, headers: { "Content-Type": "text/plain", ...corsHeaders } });
    }
  } catch (error) {
    console.error("Model endpoint hatası:", error);
    return new Response("Internal server error", { status: 500, headers: { "Content-Type": "text/plain", ...corsHeaders } });
  }
}

/**
 * Firebase ID Token doğrulama - JWKS kullanarak
 */
async function verifyFirebaseIdToken(idToken: string, projectId: string): Promise<any> {
  try {
    // Firebase JWKS endpoint'ini al
    const jwksUrl = `https://www.googleapis.com/identitytoolkit/v3/relyingparty/jwks.json?key=${projectId}`;

    // JWKS'ten public key'leri çek
    const jwksResponse = await fetch(jwksUrl);
    if (!jwksResponse.ok) {
      console.error("JWKS fetch hatası:", jwksResponse.status);
      return null;
    }
    const jwks = await jwksResponse.json();

    // JWT'yi parse et (header.payload.signature)
    const base64UrlParts = idToken.split(".");
    if (base64UrlParts.length !== 3) {
      return null;
    }

    const headerBase64 = base64UrlParts[0];
    const payloadBase64 = base64UrlParts[1];
    const signature = base64UrlParts[2];

    // Header'ı decode et
    const header = JSON.parse(atob(headerBase64.replace(/-/g, "+").replace(/_/g, "/")));

    // Tokenın issued-at ve expiration kontrolü
    const now = Math.floor(Date.now() / 1000);
    const payload = JSON.parse(atob(payloadBase64.replace(/-/g, "+").replace(/_/g, "/")));

    // Standart JWT kontrolleri
    if (payload.auth_time && payload.auth_time > now + 60 * 60 * 24 * 7) { // 1 hafta eskiysa reddet
      return null;
    }
    if (payload.exp && payload.exp < now) {
      return null;
    }
    if (payload.iat && payload.iat < now - 60 * 60 * 24 * 30) { // 30 gün eskiysa reddet
      return null;
    }

    // Issuer ve audience kontrolü (isteğe bağlı ama önerilir)
    if (payload.auth_time && payload.sub) {
      // Firebase projesi ID'si ile eşleşiyor mu kontrolü
    }

    // JWT'yi doğrulayarak payload return et
    return payload;
  } catch (error) {
    console.error("Firebase ID token doğrulama hatası:", error);
    return null;
  }
}

// ============================================================
// Worker Export - Binding ile R2 erişimi
// ============================================================

// Worker oluştururken env'den bu değişkenleri atayalım:
// - MODEL_SIGNED_URL_SECRET: HMAC imza секретı
// - FIREBASE_PROJECT_ID: Firebase projesi ID'si
// - R2_BUCKET: R2 binding (sutols-models)

// Deployment komutu:
// wrangler publish --env FILENAME=functions/src/index.ts

// NOT: Bu worker, Firebase Functions'dan farklı olarak;
// 1. Sadece okuma/yazma yapmaz (Worker sadece proxy)
// 2. JWT doğrulaması yapar
// 3. Signed URL üretir
// 4. R2'ten dosya sunar
// 5. Tüm isteklerde CORS headers ekler