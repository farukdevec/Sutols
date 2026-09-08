# Yerel Anıtkabir r1 araçları

Bu araçlar tek pilotun doğrulanmış SHA-256 temelinden aday üretir; yayın yapmaz.
Proje kökünden çalıştırılır. Uygulama bağımlılıkları değiştirilmez.

Gerekenler: Python 3 + NumPy + Pillow, Node.js, macOS Google Chrome.
QA bağımlılıkları: `npm install --prefix /tmp/sutols-model-qa playwright gltf-validator @google/model-viewer@4.3.1`.
Video için `/tmp/sutols-model-qa/node_modules/.bin/playwright install ffmpeg`.
Renderer dosyası: `https://ajax.googleapis.com/ajax/libs/model-viewer/4.3.1/model-viewer.min.js`
→ `/tmp/sutols-model-qa/model-viewer.min.js`.

- `build-anitkabir-candidate.py`: yalnız kayıtlı temel hash ile çalışır; geometri/texture/rig aktarımı yapmaz. JSON kliplerini birleştirir ve 97 zaman anahtarını 0–4 saniyeye taşır. Hash taşıyan ayrı GLB yazar.
- `inspect-glb.py INPUT OUTPUT_JSON`: bu sıkıştırılmamış pilot için teknik ölçümler. Desteklenmeyen sparse accessor, primitive veya hareket türünde durur; genel katalog işlemcisi değildir. GPU bellek değeri ölçülmüş tahsis değil, açıkça belirtilmiş RGBA+mipmap tahminidir.
- `validate-anitkabir.cjs`: Khronos validator ile önce/sonra raporları.
- `check-anitkabir-invariants.py`: geometri, kökler, dosya özeti, döngü uçları ve hareket zarfı kontrolleri.
- `browser-review.cjs [INPUT_GLB] [OUTPUT_DIRECTORY]`: model-viewer 4.3.1 ile sabit üç açı, bayrak yakın planı, video, duraklat/devam ve oynatma zamanında üç gerçek döngü dönüşü. Uygulama içi doğrulamanın yerine geçmez.

İş sırası: başlangıç ölçüm/görüntüleri → build → aday ölçümleri → validator → invariants → tarayıcı incelemesi. `candidate-build.json` aday yolunu içerir.
Adayı canlı katalog veya paket dosyası yerine kopyalamayın; `prompt.md` yayın kapıları henüz tamamlanmadı.
