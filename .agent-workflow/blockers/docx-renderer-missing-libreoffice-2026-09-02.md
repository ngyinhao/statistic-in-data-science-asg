# Canonical DOCX renderer cannot find LibreOffice

- **Date:** 2026-09-02
- **Context and intended action:** Render `Group_Report_updated.docx` to page PNGs for mandatory visual QA after changing the STL diagnostic figure.
- **Symptom:** The packaged `render_docx.py` failed in `subprocess.run` with `FileNotFoundError: [WinError 2] The system cannot find the file specified` while starting the DOCX-to-PDF conversion command.
- **Impact:** The standard LibreOffice-based render path could not produce page images.
- **Original confirmed cause:** At the time of the group-report incident, `soffice.exe` was not available to the renderer. Poppler's `pdftoppm.exe` was available, and Microsoft Word was installed.
- **Troubleshooting:** Used the authoritative bundled Python runtime and the packaged renderer as required, then checked standard converter locations.
- **Workaround:** Export the DOCX to PDF through an invisible, read-only Microsoft Word COM session with explicit approval, then rasterize the PDF using the bundled Poppler executable. If Word automation is unavailable, perform structural DOCX checks and disclose that visual QA could not be completed.
- **Prevention:** Bundle LibreOffice with the document runtime or let `render_docx.py` detect and use Microsoft Word automation as a Windows fallback.

## Updated resolution on 2026-09-02

LibreOffice later became available at `C:\Program Files\LibreOffice\program\soffice.exe`, but its directory was not on `PATH`, so `render_docx.py` continued to fail with the same `WinError 2`. Prepending `C:\Program Files\LibreOffice\program` to the task-specific process `PATH` allowed the canonical renderer to complete successfully for all four updated individual reports. Future Windows render commands should check this location and prepend it when necessary before falling back to Word COM.
