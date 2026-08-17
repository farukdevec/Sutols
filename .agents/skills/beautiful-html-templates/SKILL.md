---
name: beautiful-html-templates
description: Guides the selection and adaptation of 34 high-aesthetic HTML presentation templates from zarazhangrui/beautiful-html-templates.
---

# Beautiful HTML Templates Skill Guide

This skill enables AI coding agents in **Sutols** to create stunning HTML presentation slide decks by matching user briefs (occasion & mood) against 34 hand-crafted HTML/CSS template scaffolds.

---

## 1. Core Principles & Workflow

Whenever a user requests an HTML presentation or slide deck using the template system:

### Step 1: Occasion & Mood Matching
1. Read `assets/templates/beautiful_html_templates/index.json` or query `allSutolTemplateCatalog` in Dart.
2. Match user brief against template properties:
   - **occasion**: (e.g. founder pitch, research synthesis, brand manifesto, classroom kickoff)
   - **mood / tone**: (e.g. confident & punchy, quiet & literary, warm & playful, dark & moody)
   - **formality & density**: (high, medium, low)
3. Select 3 distinct template candidates.

### Step 2: Slide Preparation Rules (Turkish Compliance)
When generating Turkish slide content, strictly enforce [slayt_hazirlama_kurallari.md](file:///c:/sutol/Sutols/.agents/rules/slayt_hazirlama_kurallari.md):
- **Terim Doğruluğu**: Harfi harfine (motamot) İngilizce çeviri yapma.
- **Dilbilgisi ve Yapı Uyum Düzeltmesi**: Devrik cümle veya yüklemsiz cümle kurma.
- **Slayt Yapısı**: Paragraf yerine **Vurgulu Başlık:** Açıklama madde imleri kullan.
- **Mantıksal Akış**: Giriş, kapsam ve ana fikir net olarak verilmelidir.

### Step 3: Template Integration in Sutols
- Use `SutolTemplateModel` IDs (e.g. `t_8_bit_orbit`, `biennale_yellow`, `neo_grid_bold`, `soft_editorial`, `sakura_chroma`).
- Templates seamlessly inject their layout CSS and color variables into `.sutol-html-stage[data-sutol-template="{templateId}"]`.
- Reference raw template HTML files at `assets/templates/beautiful_html_templates/templates/{slug}/template.html` when generating standalone web slide decks.

---

## 2. 34 Template Quick Reference

| Slug | Name | Scheme | Primary Vibe / Best For |
|---|---|---|---|
| `8-bit-orbit` | 8-Bit Orbit | Dark | Cyberpunk, gaming pitch, hackathon demo |
| `biennale-yellow` | Biennale Yellow | Light | Exhibition, museum, curatorial, Dutch-editorial |
| `block-frame` | BlockFrame | Light | Neobrutalist, creative agency, indie SaaS |
| `blue-professional` | Blue Professional | Light | Corporate executive, quarterly review, strategy |
| `bold-poster` | Bold Poster | Light | Graphic design, product launch, high-impact |
| `broadside` | Broadside | Light | Newspaper/editorial, research, long-form |
| `capsule` | Capsule | Light | Soft-modern, pill badges, app showcase |
| `cartesian` | Cartesian | Dark | Blueprint, tech architecture, devops |
| `cobalt-grid` | Cobalt Grid | Light | Graph paper, electric cobalt, technical |
| `coral` | Coral | Light | Warm coral, summer pitch, lifestyle |
| `creative-mode` | Creative Mode | Dark | Studio showcase, dark neon accent |
| `daisy-days` | Daisy Days | Light | Playful, pastel, friendly educational |
| `editorial-forest` | Editorial Forest | Light | Quiet quarterly review, forest green, serif |
| `editorial-tri-tone` | Editorial Tri-Tone | Light | Three-color high editorial, magazine style |
| `emerald-editorial` | Emerald Editorial | Light | Business magazine, Bodoni serif, double-rule |
| `grove` | Grove | Light | Botanical, sustainability, organic |
| `long-table` | Long Table | Light | Culinary, restaurant, hospitality |
| `mat` | Mat | Light | Museum matting, gallery showcase |
| `monochrome` | Monochrome | Dark/Light | Ultra-minimalist black & white, architecture |
| `neo-grid-bold` | Neo-Grid Bold | Light | Neo-brutalist, neon accent, graphic pitch |
| `peoples-platform` | People's Platform | Light | Community, social cause, public sector |
| `pin-and-paper` | Pin & Paper | Light | Handwritten Caveat, paper texture, pinned cards |
| `pink-script` | Pink Script | Light | Fashion, beauty, editorial script |
| `playful` | Playful | Light | Bright colors, rounded cards, youth brand |
| `raw-grid` | Raw Grid | Light | Wireframe aesthetic, raw structural typography |
| `retro-windows` | Retro Windows | Light | 90s OS window borders, nostalgia tech |
| `retro-zine` | Retro Zine | Light | Zine style, photocopy aesthetic, punk/indie |
| `sakura-chroma` | Sakura Chroma | Light | Japanese cassette box, JIS spec tags, rainbow |
| `scatterbrain` | Scatterbrain | Light | Brainstorming, sticky notes, dynamic ideas |
| `signal` | Signal | Dark | Terminal dark, status indicators, infra/ops |
| `soft-editorial` | Soft Editorial | Light | Warm paper, Garamond, sage & blush |
| `stencil-tablet` | Stencil & Tablet | Light | Archaeology stencil type, earth palette |
| `studio` | Studio | Light | Design agency credentials, clean grid |
| `vellum` | Vellum | Dark | Scholarly navy, gold serif, dark academic |
