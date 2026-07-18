import re
import unicodedata
from pathlib import Path

CATALOG = Path("lib/models/presentation_component_catalog.dart")
NEW_LIST = Path("tool/bilesen-anahtar-kelimeleri-genisletilmis.md")

text = CATALOG.read_text(encoding="utf-8")

# Extract (category, tags-list) for every component definition.
pattern = re.compile(
    r'category:\s*"([^"]+)",\s*tags:\s*<String>\[(.*?)\]',
    re.S,
)


def norm(word: str) -> str:
    word = word.strip().lower()
    word = unicodedata.normalize("NFKD", word)
    word = "".join(ch for ch in word if not unicodedata.combining(ch))
    return word


old_by_category = {}
for cat, tags_block in pattern.findall(text):
    tags = re.findall(r'"([^"]+)"', tags_block)
    old_by_category.setdefault(cat, set()).update(norm(t) for t in tags)

new_text = NEW_LIST.read_text(encoding="utf-8")
new_by_category = {}
current = None
for line in new_text.splitlines():
    heading = re.match(r"^##\s+(.+?)\s*$", line)
    if heading:
        current = heading.group(1).strip()
        new_by_category[current] = set()
        continue
    if (
        current
        and line.strip()
        and not line.startswith("#")
        and not line.startswith(">")
    ):
        words = [norm(w) for w in line.split(",")]
        new_by_category[current].update(w for w in words if w)

# Category name alignment between dart "category" strings and md headings.
alias = {
    "Fizik": "Fizik",
    "Kimya": "Kimya",
    "Biyoloji": "Biyoloji",
    "Astronomi": "Astronomi",
    "Matematik": "Matematik",
    "Teknoloji / Bilgisayar": "Teknoloji / Bilgisayar",
    "Mühendislik": "Mühendislik",
    "Tarih": "Tarih",
    "Coğrafya": "Coğrafya",
    "Çevre / Doğa": "Çevre / Doğa",
    "Tarım / Gıda": "Tarım / Gıda",
    "Sağlık / Tıp": "Sağlık / Tıp",
    "Psikoloji": "Psikoloji",
    "Felsefe / Din": "Felsefe / Din",
    "Hukuk": "Hukuk",
    "Ekonomi / İş / Finans": "Ekonomi / İş / Finans",
    "Sosyal Bilimler / Toplum": "Sosyal Bilimler / Toplum",
    "Eğitim": "Eğitim",
    "Edebiyat": "Edebiyat",
    "Sanat": "Sanat",
    "Müzik": "Müzik",
    "Spor": "Spor",
    "Genel Sunum / İş": "Genel Sunum / İş",
}

print(
    f"{'Kategori':<28}{'Eski (kod) kelime':>18}{'Yeni liste kelime':>20}{'Ortak':>10}{'Yeni-özgün':>14}"
)
total_old = total_new = total_common = total_new_unique = 0
for cat, new_words in new_by_category.items():
    old_words = old_by_category.get(cat, set())
    common = old_words & new_words
    new_unique = new_words - old_words
    total_old += len(old_words)
    total_new += len(new_words)
    total_common += len(common)
    total_new_unique += len(new_unique)
    print(
        f"{cat:<28}{len(old_words):>18}{len(new_words):>20}{len(common):>10}{len(new_unique):>14}"
    )

print("-" * 90)
print(
    f"{'TOPLAM':<28}{total_old:>18}{total_new:>20}{total_common:>10}{total_new_unique:>14}"
)
print()
print(
    "Fizik ortak kelimeler:",
    sorted(old_by_category.get("Fizik", set()) & new_by_category.get("Fizik", set())),
)
print(
    "Kimya ortak kelimeler:",
    sorted(old_by_category.get("Kimya", set()) & new_by_category.get("Kimya", set())),
)
