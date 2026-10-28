"""Generate the manifest's model-viewer comparison page and serve locally.
Use --generate-only for a saved artifact without starting a server.
"""
import argparse
import html
import hashlib
import json
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def generate(destination):
    manifest = json.loads((ROOT / 'web/models/original-v1/manifest.json').read_text())
    cards = []
    for model in manifest:
        attrs = {key: html.escape(str(value), quote=True) for key, value in {
            'key': model['id'], 'label': model['label'], 'lite': model['variants']['lite']['path'],
            'quality': model['variants']['quality']['path'], 'thumbnail': model['thumbnail'] + '?sha256=' + hashlib.sha256((ROOT / 'web' / model['thumbnail'].lstrip('/')).read_bytes()).hexdigest()}.items()}
        cards.append(f'<button class="model-card" data-key="{attrs["key"]}" data-lite="{attrs["lite"]}" data-quality="{attrs["quality"]}"><img loading="lazy" src="{attrs["thumbnail"]}" alt="{attrs["label"]}"><span>{attrs["label"]}</span></button>')
    page = (ROOT / 'tool/models/preview_template.html').read_text()
    for key, value in {'MODEL_CARDS': ''.join(cards), 'MODEL_COUNT': str(len(manifest)),
                       'FIRST_MODEL_URL': html.escape(manifest[0]['variants']['lite']['path'], quote=True),
                       'FIRST_MODEL_LABEL': html.escape(manifest[0]['label'], quote=True)}.items():
        page = page.replace('{{' + key + '}}', value)
    destination.mkdir(parents=True, exist_ok=True)
    (destination / 'index.html').write_text(page)
    lifecycle = (ROOT / 'lib/ui/widgets/html_stage/scene_lifecycle_script.dart').read_text().split("r'''", 1)[1].split("'''", 1)[0]
    (destination / 'scene.html').write_text('''<!doctype html><html><head><script>''' + lifecycle + '''</script><style>body{background:#182c40;color:white;font:20px system-ui}.orb{width:70px;height:70px;border-radius:50%;background:#50baa8;animation:drift 2s ease-in-out infinite}@keyframes drift{to{transform:translateX(240px)}}</style></head><body><div class="orb"></div><output role="status"></output><script>let count=0;function draw(){document.querySelector('output').textContent='Çizilen kare: '+(++count);requestAnimationFrame(draw)}requestAnimationFrame(draw)</script></body></html>''')
    return destination


class Handler(SimpleHTTPRequestHandler):
    def translate_path(self, path):
        # Route only the two public asset folders; normal server path
        # normalization remains handled by SimpleHTTPRequestHandler.
        translated = Path(super().translate_path(path))
        relative = translated.relative_to(self.directory)
        if relative.parts and relative.parts[0] in ('models', 'model_thumbnails'):
            return str(ROOT / 'web' / relative)
        return str(translated)


class PreviewServer(ThreadingHTTPServer):
    request_queue_size = 128


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8794)
    parser.add_argument('--generate-only', action='store_true')
    parser.add_argument('--output', type=Path, default=ROOT / 'build/model-preview')
    args = parser.parse_args()
    destination = generate(args.output.resolve())
    print(f'Preview saved at {destination}', flush=True)
    if not args.generate_only:
        print(f'Local preview: http://127.0.0.1:{args.port}/', flush=True)
        PreviewServer(('127.0.0.1', args.port), partial(Handler, directory=str(destination))).serve_forever()


if __name__ == '__main__':
    main()
