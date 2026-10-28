import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('preview_intake', Path(__file__).with_name('preview_intake.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class PreviewTest(unittest.TestCase):
    def test_verified_assets_and_escaped_metadata(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            files = {
                'model.glb': (ROOT / 'web/models/original-v1/bohr-atom-lite.glb').read_bytes(),
                'thumbnail.png': (ROOT / 'web/model_thumbnails/original-v1/bohr-atom.png').read_bytes(),
                'metadata.json': json.dumps({'name': '<script>bad()</script>', 'category': 'Fizik',
                                            'author': 'Test', 'license': 'Test fixture'}).encode(),
            }
            keys = {'model.glb': 'modelSha256', 'thumbnail.png': 'thumbnailSha256',
                    'metadata.json': 'metadataSha256'}
            receipt = {}
            for name, data in files.items():
                (folder / name).write_bytes(data)
                receipt[keys[name]] = hashlib.sha256(data).hexdigest()
            (folder / 'receipt.json').write_text(json.dumps(receipt))
            assets = module.assets_for(folder)
            self.assertEqual(assets['/model.glb'], files['model.glb'])
            self.assertNotIn(b'<script>bad()', assets['/'])
            self.assertIn(b'&lt;script&gt;', assets['/'])
            (folder / 'thumbnail.png').write_bytes(b'changed')
            with self.assertRaisesRegex(ValueError, 'Submission changed'):
                module.assets_for(folder)


if __name__ == '__main__':
    unittest.main()
