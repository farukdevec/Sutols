#!/usr/bin/env python3
"""Download Sutol's curated Google Fonts as local latin/latin-ext WOFF2 assets."""

from __future__ import annotations

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
)

SINGLE_WEIGHT_FAMILIES = {
    "Archivo Black",
    "Bebas Neue",
    "Bungee",
    "Great Vibes",
    "Pacifico",
    "Lobster",
}


def slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")


def fetch(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read()


def css_url() -> str:
    query = "&".join(
        "family=" + urllib.parse.quote_plus(
            family if family in SINGLE_WEIGHT_FAMILIES else f"{family}:wght@400;700"
        )
        for family in FAMILIES
    )
    return f"https://fonts.googleapis.com/css2?{query}&display=swap"


def download_licenses() -> None:
    license_dir = FONT_DIR / "licenses"
    license_dir.mkdir(parents=True, exist_ok=True)
    for family in FAMILIES:
        family_slug = slug(family).replace("-", "")
        candidates = (
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
            print(f"Warning: license file not found for {family}")


def main() -> None:
    FONT_DIR.mkdir(parents=True, exist_ok=True)
    css = fetch(css_url()).decode("utf-8")
    blocks = re.findall(
        r"(?:/\*\s*([^*]+?)\s*\*/\s*)?@font-face\s*\{(.*?)\}",
        css,
        flags=re.DOTALL,
    )
    output_blocks: list[str] = []
    seen: set[tuple[str, str, str]] = set()

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
        if family not in FAMILIES or subset not in {"latin", "latin-ext"}:
            continue
        key = (family, weight, subset)
        if key in seen:
            continue
        seen.add(key)

        extension = ".woff2" if url_match.group(1).endswith(".woff2") else ".ttf"
        filename = f"{slug(family)}-{weight}-{subset}{extension}"
        (FONT_DIR / filename).write_bytes(fetch(url_match.group(1)))
        local_url = f"assets/assets/fonts/google_fonts/{filename}"
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

    expected = {(family, weight) for family in FAMILIES for weight in ("400", "700")}
    for family in SINGLE_WEIGHT_FAMILIES:
        expected.remove((family, "700"))
    actual = {(family, weight) for family, weight, _ in seen}
    missing = expected - actual
    if missing:
        raise RuntimeError(f"Missing font faces: {sorted(missing)}")

    download_licenses()
    dart_source = (
        "// GENERATED CODE - DO NOT EDIT BY HAND.\n"
        "// Run: python3 tool/download_google_fonts.py\n\n"
        "const String sutolLocalGoogleFontsCss = r'''\n"
        + "\n\n".join(output_blocks)
        + "\n''';\n"
    )
    CSS_DART.write_text(dart_source, encoding="utf-8")
    print(f"Downloaded {len(seen)} local font subsets to {FONT_DIR}")


if __name__ == "__main__":
    main()
