# Canonical DOCX renderer cannot find LibreOffice

- **Date:** 2026-09-02
- **Context and intended action:** Render `Group_Report_updated.docx` to page PNGs for mandatory visual QA after changing the STL diagnostic figure.
- **Symptom:** The packaged `render_docx.py` failed in `subprocess.run` with `FileNotFoundError: [WinError 2] The system cannot find the file specified` while starting the DOCX-to-PDF conversion command.
- **Impact:** The standard LibreOffice-based render path could not produce page images.
- **Confirmed cause:** `soffice.exe` is absent from both standard 64-bit and 32-bit LibreOffice installation paths. Poppler's `pdftoppm.exe` is available, and Microsoft Word is installed.
- **Troubleshooting:** Used the authoritative bundled Python runtime and the packaged renderer as required, then checked standard converter locations.
- **Workaround:** Export the DOCX to PDF through an invisible, read-only Microsoft Word COM session with explicit approval, then rasterize the PDF using the bundled Poppler executable. If Word automation is unavailable, perform structural DOCX checks and disclose that visual QA could not be completed.
- **Prevention:** Bundle LibreOffice with the document runtime or let `render_docx.py` detect and use Microsoft Word automation as a Windows fallback.
