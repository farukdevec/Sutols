from __future__ import annotations

import html
import json
import re
import unicodedata
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "lib" / "models" / "presentation_component_catalog.dart"
DOWNLOADS = Path("/Users/emodvc/Downloads")

SOURCES = [
    ("edebiyat-bilesenleri.md", "edebiyat", "Edebiyat"),
    ("egitim-bilesenleri.md", "egitim", "Eğitim"),
    ("genel-sunum-is-terimleri.html", "genelSunumIs", "Genel Sunum / İş"),
    ("cografya_bilesenleri.md", "cografya", "Coğrafya"),
    ("muzik_bilesenler.md", "muzik", "Müzik"),
    ("ekonomi-is-finans-bilesenleri.md", "ekonomiIsFinans", "Ekonomi / İş / Finans"),
    ("cevre_doga_bilesenleri.md", "cevreDoga", "Çevre / Doğa"),
    ("felsefe_din_bilesenler.md", "felsefeDin", "Felsefe / Din"),
    ("hukuk-bilesenleri.md", "hukuk", "Hukuk"),
    ("muhendislik-bilesenleri.md", "muhendislik", "Mühendislik"),
    ("psikoloji_bilesenler.md", "psikoloji", "Psikoloji"),
    ("tarim_gida_bilesenler.md", "tarimGida", "Tarım / Gıda"),
    ("toplum_bilesenler.md", "toplum", "Sosyal Bilimler / Toplum"),
    ("saglik_bilesenler.md", "saglik", "Sağlık / Tıp"),
    ("spor-bilesenleri.md", "spor", "Spor"),
    ("sanat_bilesenleri.md", "sanat", "Sanat"),
    ("sutol-tarih-bilesenleri.html", "tarih", "Tarih"),
    ("sutol-teknoloji-bilesenleri.md", "teknoloji", "Teknoloji / Bilgisayar"),
    ("sutol-astronomi-bilesenleri.html", "astronomi", "Astronomi"),
    ("sutol-biyoloji-bilesenleri.md", "biyoloji", "Biyoloji"),
    ("sutol-fizik-bilesenleri.md", "fizik", "Fizik"),
    ("sutol-matematik-bilesenleri.md", "matematik", "Matematik"),
    ("sutol-kimya-bilesenleri.md", "kimya", "Kimya"),
]

LOCAL_EXTRA_SOURCES = {
    "edebiyat": ROOT / "tool" / "new_components" / "edebiyat.md",
    "egitim": ROOT / "tool" / "new_components" / "egitim.md",
    "genelSunumIs": ROOT / "tool" / "new_components" / "genelSunumIs.md",
    "cografya": ROOT / "tool" / "new_components" / "cografya.md",
    "muzik": ROOT / "tool" / "new_components" / "muzik.md",
    "ekonomiIsFinans": ROOT / "tool" / "new_components" / "ekonomiIsFinans.md",
}

ASSET_PACK_SOURCES = [
    ("turizm_seyahat_bilesenler.md", "turizmSeyahat", "Turizm / Seyahat"),
    (
        "sutol-ulasim-lojistik-bilesenleri.md",
        "ulasimLojistik",
        "Ulaşım & Lojistik",
    ),
    (
        "sutol-sehir-kentsel-bilesenleri.md",
        "sehirKentsel",
        "Şehir Yaşamı & Kentsel Altyapı",
    ),
    (
        "sutol-enerji-altyapisi-bilesenleri.md",
        "enerjiAltyapisi",
        "Enerji Altyapısı",
    ),
    (
        "sutol-el-sanatlari-bilesenleri.md",
        "elSanatlari",
        "El Sanatları & Zanaat",
    ),
    ("sinema_film_bilesenler.md", "sinemaFilm", "Sinema & Film Yapımı"),
    ("oyun_bilesenler.md", "oyun", "Oyun & Eğlence Dünyası"),
    ("moda_bilesenler.md", "moda", "Moda & Stil"),
    (
        "mitoloji-fantastik-dunya-bilesenleri.md",
        "mitolojiFantastik",
        "Mitoloji & Fantastik Dünya",
    ),
    ("meteoroloji_bilesenler.md", "meteoroloji", "Meteoroloji & Hava Olayları"),
    ("havacilik_bilesenler.md", "havacilik", "Havacılık"),
    (
        "gastronomi-mutfak-bilesenleri.md",
        "gastronomi",
        "Gastronomi & Mutfak Kültürü",
    ),
    ("fotografcilik-bilesenleri.md", "fotografcilik", "Fotoğrafçılık"),
    (
        "evcil-hayvanlar-dunyasi-bilesenleri.md",
        "evcilHayvanlar",
        "Evcil Hayvanlar & Hayvan Dünyası",
    ),
]

CATEGORY_COLORS = {
    "Edebiyat": ("0xFF3A1B2E", "0xFF7C2D5C", "0xFFFFB4D8"),
    "Eğitim": ("0xFF081A2F", "0xFF174A7A", "0xFF8FD3FF"),
    "Genel Sunum / İş": ("0xFF12151C", "0xFF262B38", "0xFFF5A623"),
    "Coğrafya": ("0xFF102014", "0xFF2F6B3B", "0xFFFFB84D"),
    "Müzik": ("0xFF171225", "0xFF4B2E83", "0xFFB88CFF"),
    "Ekonomi / İş / Finans": ("0xFF071B18", "0xFF17463F", "0xFF6FCF97"),
    "Çevre / Doğa": ("0xFF082015", "0xFF1E6B3A", "0xFF7EE787"),
    "Felsefe / Din": ("0xFF181323", "0xFF4B3A78", "0xFFE0C97F"),
    "Hukuk": ("0xFF17120B", "0xFF4B3720", "0xFFD8B56D"),
    "Mühendislik": ("0xFF101923", "0xFF28445F", "0xFFFF8A3D"),
    "Psikoloji": ("0xFF14152A", "0xFF4E3D8A", "0xFF9EE7D7"),
    "Tarım / Gıda": ("0xFF14200D", "0xFF496B22", "0xFFE6C75A"),
    "Sosyal Bilimler / Toplum": ("0xFF111827", "0xFF374151", "0xFF60A5FA"),
    "Sağlık / Tıp": ("0xFF081B1C", "0xFF14555E", "0xFF67E8F9"),
    "Spor": ("0xFF171B12", "0xFF4E6B25", "0xFFFFD166"),
    "Sanat": ("0xFF1D1220", "0xFF6B2E67", "0xFFFF6FAE"),
    "Tarih": ("0xFF1A1208", "0xFF5C3A18", "0xFFC9A227"),
    "Teknoloji / Bilgisayar": ("0xFF07111E", "0xFF0F3054", "0xFF40D9F0"),
    "Astronomi": ("0xFF050914", "0xFF12203A", "0xFFFFD166"),
    "Biyoloji": ("0xFF071A17", "0xFF1E4D43", "0xFF8CE0D1"),
    "Fizik": ("0xFF05070C", "0xFF111827", "0xFF5EEAD4"),
    "Matematik": ("0xFF111225", "0xFF362A68", "0xFFB88CFF"),
    "Kimya": ("0xFF07151A", "0xFF1D4B5A", "0xFF7FE3E8"),
    "Turizm / Seyahat": ("0xFF09233A", "0xFF1B6B8F", "0xFFFFC857"),
    "Ulaşım & Lojistik": ("0xFF101820", "0xFF2B4A5F", "0xFFFF8A3D"),
    "Şehir Yaşamı & Kentsel Altyapı": ("0xFF111827", "0xFF3B556D", "0xFF8FD3FF"),
    "Enerji Altyapısı": ("0xFF101A12", "0xFF4D6B2F", "0xFFFFD166"),
    "El Sanatları & Zanaat": ("0xFF1D1520", "0xFF7C3F58", "0xFFE0A24D"),
    "Sinema & Film Yapımı": ("0xFF141414", "0xFF4A4A4A", "0xFFFFD166"),
    "Oyun & Eğlence Dünyası": ("0xFF13172A", "0xFF2D6CDF", "0xFFFF6B6B"),
    "Moda & Stil": ("0xFF1F1420", "0xFF8A3D6D", "0xFFFFB3C7"),
    "Mitoloji & Fantastik Dünya": ("0xFF161326", "0xFF5B3A89", "0xFFE0C97F"),
    "Meteoroloji & Hava Olayları": ("0xFF071A2A", "0xFF2C6F9E", "0xFFBDEBFF"),
    "Havacılık": ("0xFF081827", "0xFF275A7A", "0xFF9BE7FF"),
    "Gastronomi & Mutfak Kültürü": ("0xFF20120A", "0xFF7A3E1D", "0xFFFFC857"),
    "Fotoğrafçılık": ("0xFF111111", "0xFF3D3D3D", "0xFFFFE08A"),
    "Evcil Hayvanlar & Hayvan Dünyası": ("0xFF102015", "0xFF4E6B25", "0xFFFFB86B"),
}

CATEGORY_ICONS = {
    "Edebiyat": "Icons.menu_book_rounded",
    "Eğitim": "Icons.school_rounded",
    "Genel Sunum / İş": "Icons.business_center_rounded",
    "Coğrafya": "Icons.public_rounded",
    "Müzik": "Icons.music_note_rounded",
    "Ekonomi / İş / Finans": "Icons.trending_up_rounded",
    "Çevre / Doğa": "Icons.eco_rounded",
    "Felsefe / Din": "Icons.psychology_alt_rounded",
    "Hukuk": "Icons.balance_rounded",
    "Mühendislik": "Icons.precision_manufacturing_rounded",
    "Psikoloji": "Icons.psychology_rounded",
    "Tarım / Gıda": "Icons.agriculture_rounded",
    "Sosyal Bilimler / Toplum": "Icons.groups_rounded",
    "Sağlık / Tıp": "Icons.medical_services_rounded",
    "Spor": "Icons.sports_soccer_rounded",
    "Sanat": "Icons.palette_rounded",
    "Tarih": "Icons.history_edu_rounded",
    "Teknoloji / Bilgisayar": "Icons.memory_rounded",
    "Astronomi": "Icons.rocket_launch_rounded",
    "Biyoloji": "Icons.biotech_rounded",
    "Fizik": "Icons.science_rounded",
    "Matematik": "Icons.functions_rounded",
    "Kimya": "Icons.science_rounded",
    "Turizm / Seyahat": "Icons.map_rounded",
    "Ulaşım & Lojistik": "Icons.local_shipping_rounded",
    "Şehir Yaşamı & Kentsel Altyapı": "Icons.location_city_rounded",
    "Enerji Altyapısı": "Icons.flash_on_rounded",
    "El Sanatları & Zanaat": "Icons.brush_rounded",
    "Sinema & Film Yapımı": "Icons.movie_rounded",
    "Oyun & Eğlence Dünyası": "Icons.videogame_asset_rounded",
    "Moda & Stil": "Icons.checkroom_rounded",
    "Mitoloji & Fantastik Dünya": "Icons.auto_awesome_rounded",
    "Meteoroloji & Hava Olayları": "Icons.cloud_rounded",
    "Havacılık": "Icons.flight_rounded",
    "Gastronomi & Mutfak Kültürü": "Icons.restaurant_rounded",
    "Fotoğrafçılık": "Icons.photo_camera_rounded",
    "Evcil Hayvanlar & Hayvan Dünyası": "Icons.pets_rounded",
}

CATEGORY_FALLBACK_TAGS = {
    "Tarih": ["tarih", "history"],
    "Astronomi": ["astronomi", "uzay", "space"],
}


@dataclass
class Component:
    enum_name: str
    id: str
    label: str
    category: str
    tags: list[str]
    description: str
    html: str


def normalize_spaces(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def strip_accents(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    return "".join(ch for ch in normalized if not unicodedata.combining(ch))


def slug(value: str) -> str:
    value = strip_accents(value).lower()
    value = re.sub(r"[^a-z0-9]+", "-", value).strip("-")
    return value or "component"


def dart_string(value: str) -> str:
    if "'''" not in value and not value.endswith("'"):
        return "r'''" + value + "'''"
    return json.dumps(value, ensure_ascii=False)


def enum_name(prefix: str, number: int) -> str:
    return f"{prefix}{number:02d}"


def parse_tags(raw: str | None) -> list[str]:
    if not raw:
        return []
    raw = re.sub(r"<[^>]+>", "", raw)
    raw = raw.replace("**", "")
    parts = re.split(r"[,;•|]", raw)
    return [normalize_spaces(p) for p in parts if normalize_spaces(p)]


def clean_component_html(source: str) -> str:
    source = html.unescape(source).strip()
    source = re.sub(r"^```html\s*", "", source.strip(), flags=re.I)
    source = re.sub(r"\s*```$", "", source.strip())
    return source.strip()


def parse_markdown(path: Path, prefix: str, default_category: str) -> list[Component]:
    text = path.read_text(encoding="utf-8")
    heading = re.compile(r"^##\s+Bileşen\s+(\d+)\s*:\s*(.+?)\s*$", re.M)
    matches = list(heading.finditer(text))
    result: list[Component] = []
    for index, match in enumerate(matches):
        number = int(match.group(1))
        title = normalize_spaces(match.group(2))
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        block = text[start:end]

        code_match = re.search(r"```html\s*(.*?)\s*```", block, flags=re.S | re.I)
        if not code_match:
            continue
        category_match = re.search(r"\*\*Kategori:\*\*\s*([^\n]+)", block)
        tags_match = re.search(r"\*\*Etiketler(?: \(.*?\))?:\*\*\s*([^\n]+)", block)
        desc_match = re.search(r"\*\*Açıklama:\*\*\s*([^\n]+)", block)
        category = (
            normalize_spaces(category_match.group(1))
            if category_match
            else default_category
        )
        result.append(
            Component(
                enum_name=enum_name(prefix, number),
                id=f"{slug(default_category)}-{number:02d}-{slug(title)}",
                label=title,
                category=category,
                tags=parse_tags(tags_match.group(1) if tags_match else ""),
                description=normalize_spaces(desc_match.group(1))
                if desc_match
                else f"{category} kategorisi için animasyonlu HTML bileşeni.",
                html=clean_component_html(code_match.group(1)),
            )
        )
    return result


def balanced_div_from(text: str, start: int) -> str | None:
    tag = re.compile(r"</?div\b[^>]*>", re.I)
    depth = 0
    for m in tag.finditer(text, start):
        token = m.group(0)
        if token.startswith("</"):
            depth -= 1
            if depth == 0:
                return text[start : m.end()]
        else:
            depth += 1
    return None


def parse_html_catalog(
    path: Path, prefix: str, default_category: str
) -> list[Component]:
    text = path.read_text(encoding="utf-8")
    result: list[Component] = []

    h2s_all = re.findall(
        r"<h2[^>]*>\s*(?:Bileşen\s*)?(\d+)\s*[:.)-]?\s*(.*?)\s*</h2>",
        text,
        flags=re.S | re.I,
    )
    titles_by_number = {
        int(num): normalize_spaces(re.sub(r"<[^>]+>", "", html.unescape(title)))
        for num, title in h2s_all
    }

    card_re = re.compile(r'<div\b[^>]*class=["\']sutol-card["\'][^>]*>', re.I)
    for card_match in card_re.finditer(text):
        card = balanced_div_from(text, card_match.start())
        if not card:
            continue
        stage_match = re.search(
            r'<div\b[^>]*class=["\']sutol-stage["\'][^>]*>(.*?)</div>\s*<div\b[^>]*class=["\']sutol-meta["\']',
            card,
            flags=re.S | re.I,
        )
        if not stage_match:
            continue
        source = clean_component_html(stage_match.group(1))
        root_match = re.search(
            r'class=["\'][^"\']*sutol-[a-z0-9-]*?(\d{2})-[a-z0-9-]*[^"\']*["\']',
            source,
            flags=re.I,
        )
        if not root_match:
            continue
        number = int(root_match.group(1))
        name_match = re.search(
            r'<div\b[^>]*class=["\']name["\'][^>]*>(.*?)</div>', card, flags=re.S | re.I
        )
        tags_match = re.search(
            r'<div\b[^>]*class=["\']tags["\'][^>]*>(.*?)</div>', card, flags=re.S | re.I
        )
        raw_label = (
            normalize_spaces(re.sub(r"<[^>]+>", "", html.unescape(name_match.group(1))))
            if name_match
            else f"Bileşen {number}"
        )
        title = re.sub(r"^\d+\.\s*", "", raw_label).strip()
        tags = parse_tags(
            re.sub(r"<[^>]+>", "", html.unescape(tags_match.group(1)))
            if tags_match
            else ""
        )
        result.append(
            Component(
                enum_name=enum_name(prefix, number),
                id=f"{slug(default_category)}-{number:02d}-{slug(title)}",
                label=title,
                category=default_category,
                tags=tags,
                description=f"{default_category} kategorisi için animasyonlu HTML bileşeni.",
                html=source,
            )
        )

    if result:
        return sorted(result, key=lambda c: c.enum_name)

    pre_blocks = re.findall(r"<pre[^>]*>(.*?)</pre>", text, flags=re.S | re.I)
    for pre in pre_blocks:
        source = clean_component_html(pre)
        if not source.startswith("<div"):
            continue
        root_match = re.search(
            r'class=["\'][^"\']*sutol-[a-z0-9-]*?(\d{2})-[a-z0-9-]*[^"\']*["\']',
            source,
            flags=re.I,
        )
        if not root_match:
            continue
        number = int(root_match.group(1))
        if any(c.enum_name == enum_name(prefix, number) for c in result):
            continue
        title = titles_by_number.get(number, f"Bileşen {number}")
        result.append(
            Component(
                enum_name=enum_name(prefix, number),
                id=f"{slug(default_category)}-{number:02d}-{slug(title)}",
                label=title,
                category=default_category,
                tags=[title, *CATEGORY_FALLBACK_TAGS.get(default_category, [])],
                description=f"{default_category} kategorisi için animasyonlu HTML bileşeni.",
                html=source,
            )
        )

    if result:
        return sorted(result, key=lambda c: c.enum_name)

    root_re = re.compile(
        r'<div\b[^>]*class=["\'][^"\']*sutol-[a-z0-9-]*?(\d{2})-[a-z0-9-]*[^"\']*["\'][^>]*>',
        re.I,
    )
    for match in root_re.finditer(text):
        number = int(match.group(1))
        source = balanced_div_from(text, match.start())
        if not source:
            continue
        if any(c.enum_name == enum_name(prefix, number) for c in result):
            continue
        title = titles_by_number.get(number, f"Bileşen {number}")
        result.append(
            Component(
                enum_name=enum_name(prefix, number),
                id=f"{slug(default_category)}-{number:02d}-{slug(title)}",
                label=title,
                category=default_category,
                tags=[title, *CATEGORY_FALLBACK_TAGS.get(default_category, [])],
                description=f"{default_category} kategorisi için animasyonlu HTML bileşeni.",
                html=clean_component_html(source),
            )
        )
    return sorted(result, key=lambda c: c.enum_name)


def component_dom_name(enum_value: str) -> str:
    return re.sub(r"([A-Z])", lambda m: "-" + m.group(1).lower(), enum_value)


def generate(components: list[Component]) -> str:
    lines: list[str] = []
    lines.append("// GENERATED CODE - DO NOT EDIT BY HAND.")
    lines.append("// Run: python3 tool/import_components.py")
    lines.append("// ignore_for_file: prefer_single_quotes")
    lines.append("")
    lines.append("import 'package:flutter/material.dart';")
    lines.append("")
    lines.append("enum PresentationComponentKind {")
    for c in components:
        lines.append(f"  {c.enum_name},")
    lines.append("}")
    lines.append("")
    lines.append("class PresentationComponentDefinition {")
    lines.append("  const PresentationComponentDefinition({")
    lines.append("    required this.kind,")
    lines.append("    required this.id,")
    lines.append("    required this.label,")
    lines.append("    required this.category,")
    lines.append("    required this.tags,")
    lines.append("    required this.description,")
    lines.append("    required this.html,")
    lines.append("  });")
    lines.append("")
    lines.append("  final PresentationComponentKind kind;")
    lines.append("  final String id;")
    lines.append("  final String label;")
    lines.append("  final String category;")
    lines.append("  final List<String> tags;")
    lines.append("  final String description;")
    lines.append("  final String html;")
    lines.append("}")
    lines.append("")
    lines.append(
        "const List<PresentationComponentKind> presentationComponentLibraryKinds ="
    )
    lines.append("    <PresentationComponentKind>[")
    for c in components:
        lines.append(f"  PresentationComponentKind.{c.enum_name},")
    lines.append("];")
    lines.append("")
    lines.append(
        "const List<PresentationComponentDefinition> presentationComponentDefinitions ="
    )
    lines.append("    <PresentationComponentDefinition>[")
    for c in components:
        lines.append("  PresentationComponentDefinition(")
        lines.append(f"    kind: PresentationComponentKind.{c.enum_name},")
        lines.append(f"    id: {json.dumps(c.id, ensure_ascii=False)},")
        lines.append(f"    label: {json.dumps(c.label, ensure_ascii=False)},")
        lines.append(f"    category: {json.dumps(c.category, ensure_ascii=False)},")
        tags = ", ".join(json.dumps(t, ensure_ascii=False) for t in c.tags)
        lines.append(f"    tags: <String>[{tags}],")
        lines.append(
            f"    description: {json.dumps(c.description, ensure_ascii=False)},"
        )
        lines.append(f"    html: {dart_string(c.html)},")
        lines.append("  ),")
    lines.append("];")
    lines.append("")
    lines.append(
        "final Map<PresentationComponentKind, PresentationComponentDefinition>"
    )
    lines.append("    _presentationComponentDefinitionByKind =")
    lines.append(
        "        <PresentationComponentKind, PresentationComponentDefinition>{"
    )
    lines.append("  for (final definition in presentationComponentDefinitions)")
    lines.append("    definition.kind: definition,")
    lines.append("};")
    lines.append("")
    lines.append(
        "final Map<String, List<PresentationComponentDefinition>>"
    )
    lines.append("    _presentationComponentDefinitionsByCategory = () {")
    lines.append(
        "  final index = <String, List<PresentationComponentDefinition>>{};"
    )
    lines.append("  for (final definition in presentationComponentDefinitions) {")
    lines.append(
        "    index.putIfAbsent(definition.category, () => <PresentationComponentDefinition>[]).add(definition);"
    )
    lines.append("  }")
    lines.append("  return <String, List<PresentationComponentDefinition>>{")
    lines.append("    for (final entry in index.entries)")
    lines.append(
        "      entry.key: List<PresentationComponentDefinition>.unmodifiable(entry.value),"
    )
    lines.append("  };")
    lines.append("}();")
    lines.append("")
    lines.append("final List<String> _presentationComponentCategories =")
    lines.append(
        "    List<String>.unmodifiable(_presentationComponentDefinitionsByCategory.keys);"
    )
    lines.append("")
    lines.append("PresentationComponentDefinition presentationComponentDefinition(")
    lines.append("  PresentationComponentKind kind,")
    lines.append(") =>")
    lines.append("    _presentationComponentDefinitionByKind[kind]!;")
    lines.append("")
    lines.append("String presentationComponentLabel(PresentationComponentKind kind) =>")
    lines.append("    presentationComponentDefinition(kind).label;")
    lines.append("")
    lines.append(
        "String presentationComponentSubtitle(PresentationComponentKind kind) {"
    )
    lines.append("  final definition = presentationComponentDefinition(kind);")
    lines.append("  final tags = definition.tags.take(4).join(', ');")
    lines.append("  return tags.isEmpty ? definition.description : tags;")
    lines.append("}")
    lines.append("")
    lines.append(
        "String presentationComponentCategory(PresentationComponentKind kind) =>"
    )
    lines.append("    presentationComponentDefinition(kind).category;")
    lines.append("")
    lines.append("String presentationComponentHtml(PresentationComponentKind kind) =>")
    lines.append("    presentationComponentDefinition(kind).html;")
    lines.append("")
    lines.append("bool presentationComponentHasHtml(PresentationComponentKind kind) =>")
    lines.append("    presentationComponentDefinition(kind).html.trim().isNotEmpty;")
    lines.append("")
    lines.append("IconData presentationComponentIcon(PresentationComponentKind kind) {")
    lines.append("  switch (presentationComponentCategory(kind)) {")
    for category, icon in CATEGORY_ICONS.items():
        lines.append(f"    case {json.dumps(category, ensure_ascii=False)}:")
        lines.append(f"      return {icon};")
    lines.append("    default:")
    lines.append("      return Icons.auto_awesome_rounded;")
    lines.append("  }")
    lines.append("}")
    lines.append("")
    lines.append(
        "bool presentationComponentIsSticker(PresentationComponentKind kind) => false;"
    )
    lines.append("")
    lines.append(
        "bool presentationComponentIsAssetPack(PresentationComponentKind kind) => true;"
    )
    lines.append("")
    lines.append("List<Color> presentationComponentPreviewColors(")
    lines.append("  PresentationComponentKind kind,")
    lines.append(") {")
    lines.append("  switch (presentationComponentCategory(kind)) {")
    for category, colors in CATEGORY_COLORS.items():
        lines.append(f"    case {json.dumps(category, ensure_ascii=False)}:")
        lines.append("      return const <Color>[")
        for color in colors:
            lines.append(f"        Color({color}),")
        lines.append("      ];")
    lines.append("    default:")
    lines.append("      return const <Color>[")
    lines.append("        Color(0xFF060914),")
    lines.append("        Color(0xFF11162A),")
    lines.append("        Color(0xFFFFD166),")
    lines.append("      ];")
    lines.append("  }")
    lines.append("}")
    lines.append("")
    lines.append(
        "String presentationComponentDomName(PresentationComponentKind kind) {"
    )
    lines.append("  switch (kind) {")
    for c in components:
        lines.append(f"    case PresentationComponentKind.{c.enum_name}:")
        lines.append(f"      return '{component_dom_name(c.enum_name)}';")
    lines.append("  }")
    lines.append("}")
    lines.append("")
    lines.append("List<String> presentationComponentCategories() {")
    lines.append("  return _presentationComponentCategories;")
    lines.append("}")
    lines.append("")
    lines.append(
        "List<PresentationComponentDefinition> presentationComponentDefinitionsForCategory("
    )
    lines.append("  String category,")
    lines.append(") =>")
    lines.append(
        "    _presentationComponentDefinitionsByCategory[category] ??"
    )
    lines.append("    const <PresentationComponentDefinition>[];")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    components: list[Component] = []
    for filename, prefix, category in SOURCES:
        path = DOWNLOADS / filename
        if not path.exists():
            raise FileNotFoundError(path)
        parsed = (
            parse_markdown(path, prefix, category)
            if path.suffix == ".md"
            else parse_html_catalog(path, prefix, category)
        )
        print(f"{filename}: {len(parsed)}")
        components.extend(parsed)

        extra_path = LOCAL_EXTRA_SOURCES.get(prefix)
        if extra_path is not None and extra_path.exists():
            extra_parsed = parse_markdown(extra_path, prefix, category)
            print(f"{extra_path.relative_to(ROOT)}: {len(extra_parsed)}")
            components.extend(extra_parsed)

    asset_pack_dir = ROOT / "tool" / "asset_pack_components"
    for filename, prefix, category in ASSET_PACK_SOURCES:
        path = asset_pack_dir / filename
        if not path.exists():
            raise FileNotFoundError(path)
        parsed = parse_markdown(path, prefix, category)
        print(f"{path.relative_to(ROOT)}: {len(parsed)}")
        components.extend(parsed)

    seen = set()
    for c in components:
        if c.enum_name in seen:
            raise ValueError(f"Duplicate enum name: {c.enum_name}")
        seen.add(c.enum_name)
    OUT.write_text(generate(components), encoding="utf-8")
    print(f"Wrote {OUT.relative_to(ROOT)} with {len(components)} components")


if __name__ == "__main__":
    main()
