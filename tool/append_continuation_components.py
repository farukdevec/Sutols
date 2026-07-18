from __future__ import annotations

import json
import re

from import_components import (
    ROOT,
    OUT,
    Component,
    component_dom_name,
    dart_string,
    enum_name,
    parse_markdown,
    slug,
)

SOURCE_DIR = ROOT / "tool" / "continuation_components"
CATALOG_MARKER = "// Continuation component pack: downloads-2026-07-08\n"

CONTINUATION_SOURCES = [
    ("tarih_bilesenleri.md", "tarih", "Tarih"),
    ("sutol-turizm-bilesenleri.md", "turizmSeyahat", "Turizm / Seyahat"),
    ("sutol-teknoloji-bilesenleri.md", "teknoloji", "Teknoloji / Bilgisayar"),
    ("sutol-kimya-bilesenleri.md", "kimya", "Kimya"),
    ("sutol-biyoloji-bilesenleri.md", "biyoloji", "Biyoloji"),
    ("spor-bilesenleri.md", "spor", "Spor"),
    ("sanat_bilesenleri.md", "sanat", "Sanat"),
    ("saglik_bilesenler.md", "saglik", "Sağlık / Tıp"),
    ("matematik_bilesenleri.md", "matematik", "Matematik"),
    ("fizik-bilesenleri.md", "fizik", "Fizik"),
    ("astronomi_bilesenler.md", "astronomi", "Astronomi"),
]


def current_enum_names(source: str) -> list[str]:
    match = re.search(
        r"enum PresentationComponentKind \{\n(.*?)\n\}",
        source,
        flags=re.S,
    )
    if not match:
        raise ValueError("Could not find PresentationComponentKind enum")
    return re.findall(r"^\s*([A-Za-z]\w*),", match.group(1), flags=re.M)


def next_number(enum_names: list[str], prefix: str) -> int:
    pattern = re.compile(rf"^{re.escape(prefix)}(\d+)$")
    numbers = [
        int(match.group(1))
        for name in enum_names
        if (match := pattern.match(name)) is not None
    ]
    return (max(numbers) if numbers else 0) + 1


def renumber_components(
    components: list[Component],
    *,
    prefix: str,
    category: str,
    start: int,
) -> list[Component]:
    result: list[Component] = []
    for offset, component in enumerate(
        sorted(components, key=lambda item: item.enum_name),
        start,
    ):
        result.append(
            Component(
                enum_name=enum_name(prefix, offset),
                id=f"{slug(category)}-{offset:02d}-{slug(component.label)}",
                label=component.label,
                category=category,
                tags=component.tags,
                description=component.description,
                html=component.html,
            )
        )
    return result


def definition_block(component: Component) -> str:
    tags = ", ".join(json.dumps(tag, ensure_ascii=False) for tag in component.tags)
    return "\n".join(
        [
            "  PresentationComponentDefinition(",
            f"    kind: PresentationComponentKind.{component.enum_name},",
            f"    id: {json.dumps(component.id, ensure_ascii=False)},",
            f"    label: {json.dumps(component.label, ensure_ascii=False)},",
            f"    category: {json.dumps(component.category, ensure_ascii=False)},",
            f"    tags: <String>[{tags}],",
            f"    description: {json.dumps(component.description, ensure_ascii=False)},",
            f"    html: {dart_string(component.html)},",
            "  ),",
        ]
    )


def insert_once(source: str, marker: str, insertion: str) -> str:
    if marker not in source:
        raise ValueError(f"Could not find marker: {marker[:80]}")
    return source.replace(marker, f"{insertion}{marker}", 1)


def insert_after_index(source: str, start: int, marker: str, insertion: str) -> str:
    index = source.find(marker, start)
    if index == -1:
        raise ValueError(f"Could not find marker after index {start}: {marker[:80]}")
    return source[:index] + insertion + source[index:]


def main() -> None:
    source = OUT.read_text(encoding="utf-8")
    if CATALOG_MARKER in source:
        print("Continuation component pack already appended")
        return

    enum_names = current_enum_names(source)
    existing_names = set(enum_names)

    additions: list[Component] = []
    for filename, prefix, category in CONTINUATION_SOURCES:
        path = SOURCE_DIR / filename
        if not path.exists():
            raise FileNotFoundError(path)
        start = next_number(enum_names, prefix)
        parsed = parse_markdown(path, prefix, category)
        renumbered = renumber_components(
            parsed,
            prefix=prefix,
            category=category,
            start=start,
        )
        new_components = [
            component
            for component in renumbered
            if component.enum_name not in existing_names
        ]
        print(f"{path.relative_to(ROOT)}: {len(new_components)}")
        additions.extend(new_components)
        enum_names.extend(component.enum_name for component in new_components)
        existing_names.update(component.enum_name for component in new_components)

    if not additions:
        print("No new continuation components to append")
        return

    enum_lines = "".join(f"  {component.enum_name},\n" for component in additions)
    library_lines = "".join(
        f"  PresentationComponentKind.{component.enum_name},\n"
        for component in additions
    )
    definition_lines = "\n".join(definition_block(component) for component in additions)
    definition_lines = f"{definition_lines}\n"
    dom_lines = "".join(
        "    case PresentationComponentKind."
        f"{component.enum_name}:\n"
        f"      return '{component_dom_name(component.enum_name)}';\n"
        for component in additions
    )

    source = insert_once(
        source,
        "}\n\nclass PresentationComponentDefinition",
        enum_lines,
    )
    source = insert_once(
        source,
        "];\n\nconst List<PresentationComponentDefinition> "
        "presentationComponentDefinitions",
        library_lines,
    )
    source = insert_once(
        source,
        "];\n\nfinal Map<PresentationComponentKind, "
        "PresentationComponentDefinition>",
        definition_lines,
    )
    dom_start = source.index("String presentationComponentDomName")
    source = insert_after_index(
        source,
        dom_start,
        "  }\n}\n\nList<String> presentationComponentCategories",
        dom_lines,
    )

    source = source.replace(
        "// ignore_for_file: prefer_single_quotes\n",
        f"// ignore_for_file: prefer_single_quotes\n{CATALOG_MARKER}",
        1,
    )

    OUT.write_text(source, encoding="utf-8")
    print(f"Appended {len(additions)} components to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
