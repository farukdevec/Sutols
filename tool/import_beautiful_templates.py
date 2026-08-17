#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEMPLATES_DIR = ROOT / "assets" / "templates" / "beautiful_html_templates" / "templates"
INDEX_FILE = ROOT / "assets" / "templates" / "beautiful_html_templates" / "index.json"
OUT_DART = ROOT / "lib" / "models" / "beautiful_template_catalog.dart"

CATEGORY_MAP = {
    "editorial": "yaratıcı",
    "minimal": "minimal",
    "bold": "pazarlama",
    "corporate": "kurumsal",
    "professional": "kurumsal",
    "academic": "eğitim",
    "playful": "yaratıcı",
    "tech": "kurumsal",
    "dark": "yaratıcı",
    "retro": "yaratıcı",
}

def map_category(mood_list, tone_list, formality):
    all_tags = [t.lower() for t in mood_list + tone_list]
    for tag in all_tags:
        for k, v in CATEGORY_MAP.items():
            if k in tag:
                return v
    if formality == "high":
        return "kurumsal"
    elif formality == "low":
        return "yaratıcı"
    return "minimal"

def parse_template(template_dir):
    json_path = template_dir / "template.json"
    html_path = template_dir / "template.html"
    
    if not json_path.exists():
        return None
        
    with open(json_path, "r", encoding="utf-8") as f:
        meta = json.load(f)
        
    slug = meta.get("slug", template_dir.name)
    id_clean = slug.replace("-", "_")
    if id_clean[0].isdigit():
        id_clean = f"t_{id_clean}"
        
    name = meta.get("name", slug.title()).replace("'", "\\'")
    mood = meta.get("mood", [])
    tone = meta.get("tone", [])
    formality = meta.get("formality", "medium")
    category = map_category(mood, tone, formality)
    
    palette_dict = meta.get("palette", {})
    colors = []
    if isinstance(palette_dict, dict):
        for k, v in palette_dict.items():
            if isinstance(v, str) and v.startswith("#"):
                colors.append(v.upper())
    if not colors:
        colors = ["#1E293B", "#3B82F6", "#F8FAFC"]
    colors = colors[:4]
    
    typo = meta.get("typography", {})
    heading_font = (typo.get("display") or typo.get("heading") or "Inter").replace("'", "\\'")
    body_font = (typo.get("body") or typo.get("sans") or "Inter").replace("'", "\\'")
    
    tagline = meta.get("tagline", "")
    description = tagline if tagline else meta.get("best_for", "")[:120]
    description = description.replace("'", "\\'")
    
    bg_color = colors[0] if len(colors) > 0 else "#0F172A"
    text_color = colors[-1] if len(colors) > 1 else "#F8FAFC"
    primary_accent = colors[1] if len(colors) > 1 else colors[0]
    
    layout_css = f"""/* === SUTOL BEAUTIFUL TEMPLATE: {name} ({slug}) === */
.sutol-html-stage[data-sutol-template="{id_clean}"] {{
  background-color: {bg_color} !important;
  color: {text_color} !important;
  font-family: '{body_font}', sans-serif !important;
}}

.sutol-html-stage[data-sutol-template="{id_clean}"] .sutol-text-type-title {{
  font-family: '{heading_font}', sans-serif !important;
  font-weight: 700 !important;
  color: {primary_accent} !important;
}}

.sutol-html-stage[data-sutol-template="{id_clean}"] .sutol-html-component {{
  border-color: {primary_accent} !important;
}}"""

    return {
        "id": id_clean,
        "slug": slug,
        "name": name,
        "category": category,
        "colorPalette": colors,
        "fontPair": {"heading": heading_font, "body": body_font},
        "description": description,
        "layoutCSS": layout_css
    }

def main():
    templates = []
    for tdir in sorted(TEMPLATES_DIR.iterdir()):
        if tdir.is_dir():
            res = parse_template(tdir)
            if res:
                templates.append(res)
                
    print(f"Parsed {len(templates)} templates.")
    
    dart_code = [
        "// GENERATED CODE - DO NOT EDIT BY HAND.",
        "// Generated from beautiful-html-templates library via tool/import_beautiful_templates.py",
        "",
        "import 'slide_model.dart';",
        "import 'presentation_template_catalog.dart';",
        "",
        "/// Beautiful HTML Templates Catalog (34 aesthetic templates)",
        "const List<SutolTemplateModel> beautifulTemplateCatalog = <SutolTemplateModel>["
    ]
    
    for t in templates:
        colors_str = ", ".join([f"'{c}'" for c in t["colorPalette"]])
        dart_code.append("  SutolTemplateModel(")
        dart_code.append(f"    id: '{t['id']}',")
        dart_code.append(f"    name: '{t['name']}',")
        dart_code.append(f"    category: '{t['category']}',")
        dart_code.append(f"    colorPalette: <String>[{colors_str}],")
        dart_code.append("    fontPair: <String, String>{")
        dart_code.append(f"      'heading': '{t['fontPair']['heading']}',")
        dart_code.append(f"      'body': '{t['fontPair']['body']}',")
        dart_code.append("    },")
        dart_code.append(f"    description: '{t['description']}',")
        dart_code.append(f"    layoutCSS: '''\n{t['layoutCSS']}\n''',")
        dart_code.append("  ),")
        
    dart_code.append("];")
    dart_code.append("")
    
    with open(OUT_DART, "w", encoding="utf-8") as f:
        f.write("\n".join(dart_code))
        
    print(f"Successfully generated {OUT_DART}")

if __name__ == "__main__":
    main()
