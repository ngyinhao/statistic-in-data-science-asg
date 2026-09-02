# Default Python lacks `python-docx`

- **Date:** 2026-09-02
- **Context and intended action:** Inspect paragraph text and figure captions inside generated DOCX reports to diagnose a reportedly missing STL decomposition graph.
- **Symptom:** Running a short Python script with `from docx import Document` failed with `ModuleNotFoundError: No module named 'docx'`.
- **Impact:** The DOCX could not be inspected through the convenient `python-docx` API in the default Python environment.
- **Likely cause:** The shell's default Python installation does not include the `python-docx` package, even though the repository's report generator imports it. The reports were likely generated in a different Python environment.
- **Troubleshooting:** Confirmed that the import fails in the default `python` selected by the current PowerShell session.
- **Workaround:** Inspect DOCX files as ZIP archives and read `word/document.xml` plus relationship/media entries directly with PowerShell and .NET compression/XML APIs. For generation, locate and use the configured workspace Python runtime before considering dependency installation.
- **Prevention:** Document the intended Python interpreter or add a reproducible environment specification and a small environment check for report-generation dependencies.
