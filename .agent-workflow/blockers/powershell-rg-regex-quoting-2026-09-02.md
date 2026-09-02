# PowerShell altered an `rg` regex containing quoted Python code

- **Date:** 2026-09-02
- **Context and intended action:** Cross-check the STL figure reference in a Markdown report and a Python report builder.
- **Symptom:** A combined `rg` command failed with `regex parse error: unclosed group`; the displayed regex ended early at a quoted Python string.
- **Impact:** The combined cross-check did not run, although the preceding simple search successfully listed all Markdown image references.
- **Cause:** Nested double quotes in the PowerShell command altered the regex passed to `rg`.
- **Workaround:** Use separate fixed-string searches (`rg -F`) or single-quoted patterns rather than a compound regex containing source-code quotes.
- **Prevention:** Prefer `rg -F` for literal source snippets and split unrelated searches into separate commands under PowerShell.
