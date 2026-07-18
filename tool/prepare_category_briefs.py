import json
import re
from pathlib import Path

CATALOG = Path("lib/models/presentation_component_catalog.dart")
text = CATALOG.read_text(encoding="utf-8")

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

pattern = re.compile(
    r'kind:\s*PresentationComponentKind\.(\w+?)(\d{2}),\s*id:\s*"([^"]*)",\s*label:\s*"([^"]*)",\s*category:\s*"([^"]+)",'
    r'\s*tags:\s*<String>\[(.*?)\],\s*description:\s*"([^"]*(?:\\.[^"]*)*)",\s*html:\s*r?\'\'\'(.*?)\'\'\'',
    re.S,
)

class_regex = re.compile(r'class="(sutol-[a-z]+-?\d{2})')

by_category = {}
for match in pattern.finditer(text):
    enum_prefix, num, comp_id, label, category, tags_block, description, html = (
        match.groups()
    )
    tags = re.findall(r'"([^"]+)"', tags_block)
    class_match = class_regex.search(html)
    class_prefix = class_match.group(1) if class_match else None
    entry = {
        "num": int(num),
        "label": label,
        "tags": tags,
        "class_prefix": class_prefix,
        "description": description,
    }
    by_category.setdefault(category, []).append(entry)

briefs = []
for filename, enum_prefix, category in SOURCES:
    items = sorted(by_category.get(category, []), key=lambda x: x["num"])
    class_prefixes = [i["class_prefix"] for i in items if i["class_prefix"]]
    common_prefix = None
    if class_prefixes:
        stems = set()
        for cp in class_prefixes:
            stem = re.sub(r"-?\d{2}$", "", cp)
            stems.add(stem)
        common_prefix = sorted(stems, key=lambda s: -len(s))[0] if stems else None
    briefs.append(
        {
            "downloads_file": filename,
            "category": category,
            "enum_prefix": enum_prefix,
            "class_prefix_stem": common_prefix,
            "existing_count": len(items),
            "existing_labels": [i["label"] for i in items],
            "existing_tags_sample": sorted(set(t for i in items for t in i["tags"]))[
                :40
            ],
        }
    )

out = Path("tool/category_briefs.json")
out.write_text(json.dumps(briefs, ensure_ascii=False, indent=2), encoding="utf-8")
for b in briefs:
    print(
        f"{b['category']:<28} count={b['existing_count']:<3} prefix_stem={b['class_prefix_stem']}"
    )
