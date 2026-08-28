# Sutol

![Sutol wordmark](assets/images/sutols_wordmark.webp)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Platform](https://img.shields.io/badge/Platform-Flutter%20Web-0F766E?style=flat)](#setup)

Sutol is a Flutter Web-based presentation builder that generates editable HTML presentations from titles and body text. It analyzes content through keyword and similarity matching, selects suitable backgrounds and visual components, and delivers the result as a fully editable presentation project.

> [!NOTE]
> The automatic generation flow runs locally with deterministic rules and does not depend on an external AI service.

## Live Demo

No public demo is linked to this repository yet. You can run the app locally using the setup steps below. If you deploy it later, this section is the right place to add the demo URL.

## Preview

<p align="center">
  <img src="assets/readme/preview-desktop.png" alt="Sutol editor desktop preview" width="1200" />
</p>

<p align="center">
  <img src="assets/readme/preview-presentation.png" alt="Sutol presentation preview" width="1200" />
</p>

<p align="center">
  <img src="assets/readme/preview-mobile.png" alt="Sutol mobile preview" width="260" />
</p>

## Contents

- [Highlights](#highlights)
- [How It Works](#how-it-works)
- [Technology](#technology)
- [Project Structure](#project-structure)
- [Setup](#setup)
- [Testing and Verification](#testing-and-verification)
- [Usage Notes](#usage-notes)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [Turkish Version](#turkish-version)
- [License](#license)

## Highlights

- **Automatic presentation generation:** Builds page layout, background, and components from title and body text.
- **Smart matching:** Uses keyword and similarity-based matching for Turkish and English content.
- **Editable HTML output:** Generated presentations are HTML-based and can be deeply customized in the editor.
- **Large component catalog:** Different backgrounds, visuals, and stage components can be used by topic.
- **Presentation editor:** Page layout, effects, reveal steps, hotspots, and speaker notes are managed in one place.
- **Presentation mode:** Full-screen display, keyboard navigation, and zoom support are included.
- **Project save and restore:** Work can be exported as a Sutol JSON project file and reopened later.
- **Export options:** Presentations can be downloaded as a single HTML file or saved as PDF through the browser print flow.

## How It Works

1. Select **Create Presentation** from the home screen.
2. Enter a title and body text for each slide; add more pages if needed.
3. Click **Generate Presentation** to skip empty pages and analyze the content.
4. The app chooses a suitable background, layout, and visual components for each page.
5. The generated presentation is refined in the editor, previewed, and exported in the desired format.

Simplified data flow:

```text
Title + Body Text
      │
      ▼
PresentationAutoBuilder
  ├─ keyword and similarity analysis
  ├─ background selection
  └─ component and layout selection
      │
      ▼
SlideModel
      │
      ▼
HtmlPresentationEditorPage
  ├─ PresentationPreviewPage       → presentation mode
  ├─ PresentationExportBuilder     → HTML / PDF export
  └─ PresentationProjectCodec      → Sutol JSON project file
```

## Technology

- **Flutter Web**
- **Dart**
- **Firebase**
  - Authentication
  - Firestore
  - Firebase AI
- **Local services**
  - project save and load
  - content matching
  - HTML export
  - full-screen and sharing flows

## Project Structure

```text
lib/
├── main.dart
├── models/
│   ├── presentation_component_catalog.dart
│   ├── presentation_template_catalog.dart
│   └── slide_model.dart
├── services/
│   ├── presentation_auto_builder.dart
│   ├── presentation_export_builder.dart
│   ├── presentation_keyword_catalog.dart
│   ├── presentation_project_codec.dart
│   └── presentation_service.dart
├── state/
│   └── presentation_controller.dart
└── ui/
    ├── home_page.dart
    ├── ai_draft_page.dart
    ├── html_presentation_editor_page.dart
    ├── presentation_editor_page.dart
    ├── presentation_preview_page.dart
    └── widgets/
        └── html_stage/
test/
├── presentation_auto_builder_test.dart
├── presentation_controller_test.dart
└── presentation_project_codec_test.dart
tool/
└── content generation, categorization, and validation tools
web/
└── Flutter Web bootstrap files
```

## Setup

### Requirements

- Flutter SDK `>=3.5.0 <4.0.0`
- Chrome or a current Chromium-based browser
- Optional: Python 3 for serving the production build locally

Install dependencies:

```bash
flutter pub get
```

Run the app in development mode:

```bash
flutter run -d chrome
```

Build the production web bundle:

```bash
flutter build web
```

Serve the build locally:

```bash
python3 -m http.server 8080 --directory build/web
```

Then open `http://localhost:8080`.

## Testing and Verification

Check code formatting:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Run static analysis:

```bash
flutter analyze
```

Run unit tests:

```bash
flutter test
```

Verify the web build:

```bash
flutter build web
```

Recommended manual checks:

- Verify matching behavior for Turkish, English, and typo-heavy text.
- Confirm that empty input does not proceed to the editor and shows a warning.
- Test moving, resizing, and deleting text and components.
- Exercise undo/redo, reveal, hotspots, speaker notes, and effects.
- Save a Sutol JSON file and load it again.
- Open the HTML export in a new tab; confirm that the PDF option starts the browser print flow.

## Usage Notes

Core keyboard shortcuts in presentation mode:

| Key | Action |
|---|---|
| `→`, `Page Down`, `Space` | Next reveal step or slide |
| `←`, `Page Up`, `Backspace` | Previous reveal step or slide |
| `F` | Toggle full screen |
| `Z`, `+` | Toggle zoom |
| `P`, `N` | Toggle speaker notes panel |
| `Esc` | Exit presentation mode |

In the editor, use `Ctrl/Cmd + Z` to undo and `Ctrl + Y` or `Cmd + Shift + Z` to redo.

## Known Limitations

- Content analysis is keyword and similarity based; it does not use a contextual model.
- Fuzzy matching can be stricter for short words to reduce false positives.
- PDF export relies on the browser print flow.
- Save/load and export workflows are primarily designed for the web target.
- MP4 or direct video export is not supported yet.

## Contributing

Before submitting a change:

1. Run `dart format --output=none --set-exit-if-changed lib test`.
2. Make sure `flutter analyze` and `flutter test` pass cleanly.
3. Add or update tests for new behavior.
4. Write commit messages that clearly describe the purpose of the change.

## Turkish Version

For the Turkish README, see [README.md](README.md).

## License

No root license file has been declared for this repository yet. Please get permission from the project owner before using or distributing the source code. The helper project under `sutol-model-proxy/` is covered by its own license and usage terms.
