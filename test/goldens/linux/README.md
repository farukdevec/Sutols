# Linux visual references

Flutter 3.38.9 / Ubuntu GitHub runner, application source `a028d36`.
Captured by run 37889382367 after loading the bundled TTF UI fonts.
All three images were visually inspected: Turkish text, logos, controls and
the selected text frame render correctly, without Ahem squares or clipped hints.

FreeType and macOS CoreText have different glyph metrics/rasterization. Linux
uses these exact references; macOS uses the references in the parent folder.
The comparator remains exact on both platforms. Changes to layout or text
still fail, and new references require visual review. Other native operating
systems have not been accepted by this snapshot suite.
