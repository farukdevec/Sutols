#!/usr/bin/env python3
"""Download Sutol's curated Google Fonts as local latin/latin-ext WOFF2 assets."""

from __future__ import annotations

import argparse
import hashlib
import re
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FONT_DIR = ROOT / "assets" / "fonts" / "google_fonts"
CSS_DART = ROOT / "lib" / "services" / "local_google_fonts_css.dart"
USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140 Safari/537.36"
)

FAMILIES = (
    "Roboto",
    "Open Sans",
    "Inter",
    "Montserrat",
    "Poppins",
    "Noto Sans JP",
    "Lato",
    "Arimo",
    "Roboto Condensed",
    "Roboto Mono",
    "Noto Sans",
    "Oswald",
    "DM Sans",
    "Nunito",
    "Raleway",
    "Nunito Sans",
    "Playfair Display",
    "Roboto Slab",
    "Rubik",
    "Archivo Black",
    "Ubuntu",
    "Noto Sans KR",
    "Kanit",
    "Manrope",
    "Outfit",
    "Merriweather",
    "Work Sans",
    "Lora",
    "Noto Sans TC",
    "Prompt",
    "Bebas Neue",
    "Bungee",
    "Caveat",
    "Unbounded",
    "Tinos",
    "Cousine",
    "Carlito",
    "Caladea",
    "EB Garamond",
    "Libre Baskerville",
    "Alegreya",
    "PT Serif",
    "Great Vibes",
    "Dancing Script",
    "Pacifico",
    "Lobster",
    "Chakra Petch", "Cinzel", "Cormorant Garamond", "Exo 2", "IBM Plex Mono",
    "JetBrains Mono", "Marcellus", "Michroma", "Mulish", "Orbitron", "Rajdhani",
    "Righteous", "Share Tech Mono", "Sora", "Space Grotesk", "Space Mono", "Syne", "Titillium Web",

)

SINGLE_WEIGHT_FAMILIES = {
    "Archivo Black",
    "Bebas Neue",
    "Bungee",
    "Great Vibes",
    "Pacifico",
    "Lobster", "Marcellus", "Michroma", "Righteous", "Share Tech Mono",
}


def slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")


def fetch(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def css_url(families=FAMILIES) -> str:
    query = "&".join(
        "family=" + urllib.parse.quote_plus(
            family if family in SINGLE_WEIGHT_FAMILIES else f"{family}:wght@400;700"
        )
        for family in families
    )
    return f"https://fonts.googleapis.com/css2?{query}&display=swap"


def download_licenses(families=FAMILIES) -> None:
    license_dir = FONT_DIR / "licenses"
    license_dir.mkdir(parents=True, exist_ok=True)
    for family in families:
        family_slug = slug(family).replace("-", "")
        candidates = (
            *(("https://raw.githubusercontent.com/googlefonts/tinos/main/OFL.txt",)
              if family == "Tinos" else ()),
            f"https://raw.githubusercontent.com/google/fonts/main/ofl/{family_slug}/OFL.txt",
            f"https://raw.githubusercontent.com/google/fonts/main/apache/{family_slug}/LICENSE.txt",
            f"https://raw.githubusercontent.com/google/fonts/main/ufl/{family_slug}/UFL.txt",
        )
        for url in candidates:
            try:
                license_text = fetch(url)
            except urllib.error.HTTPError as error:
                if error.code == 404:
                    continue
                raise
            (license_dir / f"{slug(family)}.txt").write_bytes(license_text)
            break
        else:
            raise RuntimeError(f"License file not found for {family}; package not generated")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--missing-only', action='store_true', help='Preserve existing font files and append missing families only')
    args = parser.parse_args()
    FONT_DIR.mkdir(parents=True, exist_ok=True)
    previous_source = CSS_DART.read_text() if CSS_DART.exists() else ''
    old_source = previous_source if args.missing_only else ''
    existing = set(re.findall(r"font-family: '([^']+)'", old_source))
    families = tuple(family for family in FAMILIES if family not in existing)
    if not families:
        print('All font families are already packaged'); return
    css = fetch(css_url(families)).decode("utf-8")
    blocks = re.findall(
        r"(?:/\*\s*([^*]+?)\s*\*/\s*)?@font-face\s*\{(.*?)\}",
        css,
        flags=re.DOTALL,
    )
    output_blocks: list[str] = []
    seen: set[tuple[str, str, str]] = set()
    filename_by_digest: dict[str, str] = {}

    for subset, body in blocks:
        family_match = re.search(r"font-family:\s*'([^']+)'", body)
        weight_match = re.search(r"font-weight:\s*(\d+)", body)
        url_match = re.search(r"src:\s*url\(([^)]+)\)", body)
        range_match = re.search(r"unicode-range:\s*([^;]+)", body)
        if not (family_match and weight_match and url_match):
            continue
        family = family_match.group(1)
        weight = weight_match.group(1)
        subset = subset.strip().lower() if subset else "all"
        if family not in families or subset not in {"latin", "latin-ext"}:
            continue
        key = (family, weight, subset)
        if key in seen:
            continue
        seen.add(key)

        extension = ".woff2" if url_match.group(1).endswith(".woff2") else ".ttf"
        filename = f"{slug(family)}-{weight}-{subset}{extension}"
        font_bytes = fetch(url_match.group(1))
        digest = hashlib.sha256(font_bytes).hexdigest()
        local_filename = filename_by_digest.setdefault(digest, filename)
        if local_filename == filename:
            (FONT_DIR / filename).write_bytes(font_bytes)
        else:
            duplicate_path = FONT_DIR / filename
            if duplicate_path.exists():
                duplicate_path.unlink()
        local_url = f"assets/assets/fonts/google_fonts/{local_filename}"
        css_lines = [
            "@font-face {",
            f"  font-family: '{family}';",
            "  font-style: normal;",
            f"  font-weight: {weight};",
            "  font-display: swap;",
            f"  src: url('{local_url}') format('{extension[1:]}'),",
            f"       url('{url_match.group(1)}') format('{extension[1:]}');",
        ]
        if range_match:
            css_lines.append(f"  unicode-range: {range_match.group(1).strip()};")
        css_lines.append("}")
        output_blocks.append("\n".join(css_lines))

    expected = {(family, weight) for family in families for weight in ("400", "700")}
    for family in SINGLE_WEIGHT_FAMILIES.intersection(families):
        expected.remove((family, "700"))
    actual = {(family, weight) for family, weight, _ in seen}
    missing = expected - actual
    if missing:
        raise RuntimeError(f"Missing font faces: {sorted(missing)}")

    download_licenses(families)
    dart_source = (
        "// GENERATED CODE - DO NOT EDIT BY HAND.\n"
        "// Run: python3 tool/download_google_fonts.py\n\n"
        "const String sutolLocalGoogleFontsCss = r'''\n"
        + "\n\n".join(output_blocks)
        + "\n''';\n"
    )
    if old_source:
        # Keep the existing subset selector helper after the raw CSS literal.
        new_css = dart_source.split("r'''", 1)[1].split("'''", 1)[0]
        dart_source = old_source.replace("\n''';", new_css + "\n''';", 1)
    elif previous_source and "\n''';" in previous_source:
        dart_source += previous_source.split("\n''';", 1)[1]
    CSS_DART.write_text(dart_source, encoding="utf-8")
    print(f"Downloaded {len(seen)} local font subsets to {FONT_DIR}")


if __name__ == "__main__":
    main()
