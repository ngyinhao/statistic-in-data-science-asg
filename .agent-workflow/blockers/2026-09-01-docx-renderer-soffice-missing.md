# DOCX renderer cannot find LibreOffice

## Context and intended action

On 2026-09-01, the document workflow attempted to render `NASA_Solar_Irradiance_Report.docx` to page PNGs for final visual QA after regenerating the report.

## Symptom

The bundled `render_docx.py` failed while starting its PDF conversion command with `FileNotFoundError: [WinError 2] The system cannot find the file specified`.

## Impact

The canonical DOCX-to-PNG render gate cannot run through its normal LibreOffice path, although the DOCX itself is generated successfully.

## Cause

`soffice.exe` is not available on `PATH` or in the standard LibreOffice installation directory. The bundled Poppler `pdftoppm.exe` is present, so the missing PDF converter is the blocking dependency.

## Troubleshooting and result

- Confirmed that `pdftoppm.exe` exists in the bundled workspace runtime.
- Searched the standard LibreOffice and bundled-runtime directories; no `soffice.exe` was found.
- On 2026-09-02, a Pandoc-generated DOCX also caused `render_docx.py` to report `Page size not found in section properties`. The renderer then attempted its PDF-based fallback and failed again with `FileNotFoundError: [WinError 2]`, consistent with the already-confirmed missing `soffice.exe` dependency.

## Workaround or remaining limitation

Use an installed Microsoft Word COM export to create a PDF, then rasterize that PDF with the bundled Poppler tool. If Word automation is unavailable, perform structural DOCX checks and disclose that visual QA could not be completed.

## Prevention

Bundle LibreOffice with the workspace document runtime or expose a supported DOCX-to-PDF converter path to `render_docx.py` on Windows.
