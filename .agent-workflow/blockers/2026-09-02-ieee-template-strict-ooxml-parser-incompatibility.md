# IEEE conference template is incompatible with transitional OOXML parsers

## Context and intended action

On 2026-09-02, `conference-template-letter.docx` was supplied as the authoritative reference for regenerating the group and four individual reports in IEEE conference format. The document workflow attempted read-only rendering, section auditing, and style auditing using the bundled document runtime.

## Observable symptoms

- `render_docx.py` reported `RuntimeError: Section properties not found in document.xml`, then could not fall back to LibreOffice because the conversion executable is unavailable.
- Both `section_audit.py` and `style_lint.py` failed through `python-docx` with `KeyError: no relationship of type 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument'`.

## Impact

The standard `python-docx`-based inspection path cannot open or audit this template. Template distillation must use direct OOXML inspection and a Word-rendered copy or normalized derivative.

## Likely cause

The template package uses strict or otherwise non-transitional OOXML namespace/relationship identifiers, while the bundled parser expects the transitional Office relationship URI and standard WordprocessingML namespace.

## Recovery approach

- Inspect the ZIP package, relationships, section properties, styles, and tables directly without modifying the source.
- Render the untouched template through installed Microsoft Word for visual evidence.
- If Pandoc cannot consume the strict package reliably, create a normalized derivative by opening and saving a copy in Word, keeping the supplied template byte-for-byte unchanged.
- Use the normalized derivative as the Pandoc reference and verify all generated documents visually and structurally.

The first normalized-reference adaptation also exposed a separate circular-style issue; see `2026-09-02-docx-circular-normal-style.md` for that generation-specific failure.

## Prevention

Detect strict OOXML relationship and WordprocessingML namespaces before invoking `python-docx`. Route strict packages through direct XML inspection or a Word-normalization copy first.
