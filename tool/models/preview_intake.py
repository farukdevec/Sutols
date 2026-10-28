#!/usr/bin/env python3
"""Preview exactly one quarantined model on localhost before review."""
import argparse
import hashlib
import html
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import struct


def assets_for(submission):
    receipt = json.loads((submission / 'receipt.json').read_text())
    assets = {}
    for name, key in [('model.glb', 'modelSha256'), ('thumbnail.png', 'thumbnailSha256'),
                      ('metadata.json', 'metadataSha256')]:
        file = submission / name
        maximum = 8 * 1024 * 1024 if name == 'model.glb' else 2 * 1024 * 1024
        if file.stat().st_size > maximum:
            raise ValueError('File exceeds preview limit: ' + name)
        data = file.read_bytes()
        if hashlib.sha256(data).hexdigest() != receipt[key]:
            raise ValueError('Submission changed: ' + name)
        assets['/' + name] = data
    glb = assets['/model.glb']
    if len(glb) < 20 or struct.unpack_from('<III', glb) != (0x46546C67, 2, len(glb)):
        raise ValueError('GLB 2.0 required')
    length, chunk_type = struct.unpack_from('<II', glb, 12)
    if chunk_type != 0x4E4F534A or length > len(glb) - 20:
        raise ValueError('Invalid GLB JSON chunk')
    scene = json.loads(glb[20:20 + length])
    if any('uri' in item for item in scene.get('buffers', []) + scene.get('images', [])):
        raise ValueError('External/data-URI resources are not allowed')
    meta = json.loads(assets['/metadata.json'])
    details = html.escape(f"{meta['category']} · {meta['author']} · {meta['license']}")
    title = html.escape(meta['name'])
    # Only escaped local metadata is interpolated; never model-provided markup.
    assets['/'] = f'''<!doctype html><html lang="tr"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>{title}</title>
<script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/4.3.1/model-viewer.min.js"></script>
<style>body{{margin:0;padding:24px;font:16px system-ui;background:#eff6f6;color:#152d38}}
main{{max-width:1000px;margin:auto}}model-viewer{{width:100%;height:65vh;background:white;border-radius:20px}}
img{{max-width:220px;max-height:220px}}.row{{display:flex;gap:24px;flex-wrap:wrap}}
</style><main><h1>{title}</h1><p>{details}</p>
<p>Modeli farklı açılardan inceleyin; küçük resmi ve kaynak hakkını kontrol edin.</p>
<model-viewer src="/model.glb" camera-controls shadow-intensity="0.3" loading="eager" alt="{title}"></model-viewer>
<div class="row"><img src="/thumbnail.png" alt="Model küçük resmi"><div>
<p>Yükleme: <strong id="status">Bekleniyor</strong></p>
<button id="motion">Dönüşü başlat</button><p>Karantina modelinin yerel önizlemesi</p></div></div></main>
<script>const model=document.querySelector('model-viewer'), status=document.querySelector('#status');
model.addEventListener('load',()=>status.textContent='Yüklendi');
model.addEventListener('error',()=>status.textContent='Yükleme başarısız');
document.querySelector('#motion').onclick=function(){{model.autoRotate=!model.autoRotate;
this.textContent=model.autoRotate?'Dönüşü durdur':'Dönüşü başlat';}};</script></html>'''.encode()
    return assets


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('submission', type=Path)
    parser.add_argument('--port', type=int, default=8798)
    args = parser.parse_args()
    assets = assets_for(args.submission.resolve())

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            data = assets.get(self.path)
            if data is None:
                self.send_error(404)
                return
            mime = {'/': 'text/html;charset=utf-8', '/model.glb': 'model/gltf-binary',
                    '/thumbnail.png': 'image/png', '/metadata.json': 'application/json'}[self.path]
            self.send_response(200)
            self.send_header('Content-Type', mime)
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Cache-Control', 'no-store')
            self.send_header('X-Content-Type-Options', 'nosniff')
            self.end_headers()
            self.wfile.write(data)

    print(f'Preview: http://127.0.0.1:{args.port}/', flush=True)
    ThreadingHTTPServer(('127.0.0.1', args.port), Handler).serve_forever()


if __name__ == '__main__':
    main()
