# `Group_Report.docx` could not be overwritten

- **Date:** 2026-09-02
- **Context and intended action:** Rebuild the group Word report after correcting the STL diagnostic to use the ACF of the STL remainder.
- **Symptom:** Pandoc failed while writing `Assignment Report/Group_Report.docx` with `withBinaryFile: permission denied`.
- **Impact:** The corrected report could not replace the existing DOCX in place.
- **Likely cause:** The original DOCX may be open or otherwise locked by Word. A first attempt to write a new sibling filename was also denied inside the managed command sandbox, indicating a second permission boundary for the external Pandoc process.
- **Troubleshooting:** The Markdown source, figure, Pandoc executable, defaults file, and output directory were all readable. `Group_Report_updated.docx` did not pre-exist. Retrying the new sibling output with narrowly scoped command approval succeeded.
- **Workaround:** Generate a clearly named sibling file, `Group_Report_updated.docx`, with approved Pandoc execution and visually verify that artifact. Replace the original later after closing the application holding the lock.
- **Prevention:** Close the target DOCX before rebuilding, or make report-generation scripts automatically fall back to an `_updated` output when an in-place write is denied.
