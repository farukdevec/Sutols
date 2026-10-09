"""Losslessly unwrap the existing UI font subsets for native Flutter engines.

Requires fonttools==4.60.2 and brotli==1.2.0. No network downloads, glyph
subsetting, or font design changes. Existing OFL licenses remain alongside
the source assets. Committed TTF outputs also make CI independent of this tool.
"""
import hashlib
import json
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[1]


def prepare():
    output = ROOT / 'assets/fonts/native_ui'
    output.mkdir(parents=True, exist_ok=True)
    records = []
    for family in ('inter', 'roboto'):
        for subset in ('latin', 'latin-ext'):
            stem = f'{family}-400-{subset}'
            source = ROOT / 'assets/fonts/google_fonts' / f'{stem}.woff2'
            destination = output / f'{stem}.ttf'
            font = TTFont(source)
            original_cmap = font.getBestCmap()
            original_glyphs = font.getGlyphOrder()
            font.flavor = None
            font.save(destination)
            converted = TTFont(destination)
            assert converted.getBestCmap() == original_cmap
            assert converted.getGlyphOrder() == original_glyphs
            records.append({
                'source': str(source.relative_to(ROOT)),
                'output': str(destination.relative_to(ROOT)),
                'sourceSha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                'outputSha256': hashlib.sha256(destination.read_bytes()).hexdigest(),
                'bytes': destination.stat().st_size,
                'codepoints': len(original_cmap),
                'license': f'assets/fonts/google_fonts/licenses/{family}.txt',
            })
    (output / 'provenance.json').write_text(json.dumps(records, indent=2) + '\n')
    print(json.dumps(records, indent=2))


if __name__ == '__main__':
    prepare()
