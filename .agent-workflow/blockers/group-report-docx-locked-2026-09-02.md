# `Group_Report.docx` could not be overwritten

- **Date:** 2026-09-02
- **Context and intended action:** Rebuild the group Word report after correcting the STL diagnostic to use the ACF of the STL remainder.
- **Symptom:** Pandoc failed while writing `Assignment Report/Group_Report.docx` with `withBinaryFile: permission denied`.
- **Impact:** The corrected report could not replace the existing DOCX in place.
- **Likely cause:** The original DOCX may be open or otherwise locked by Word. A first attempt to write a new sibling filename was also denied inside the managed command sandbox, indicating a second permission boundary for the external Pandoc process.
- **Troubleshooting:** The Markdown source, figure, Pandoc executable, defaults file, and output directory were all readable. `Group_Report_updated.docx` did not pre-exist. Retrying the new sibling output with narrowly scoped command approval succeeded.
- **Workaround:** Generate a clearly named sibling file, `Group_Report_updated.docx`, with approved Pandoc execution and visually verify that artifact. Replace the original later after closing the application holding the lock.
- **Prevention:** Close the target DOCX before rebuilding, or make report-generation scripts automatically fall back to an `_updated` output when an in-place write is denied.

## Recurrence: individual report rebuild

- **Date:** 2026-09-02
- **Context:** Rebuilding all four individual Word reports after adding training-only time-series/STL identification evidence.
- **Symptom:** Pandoc failed on `Individual_Report_1_SARIMA.docx` with the same `withBinaryFile: permission denied` error before proceeding to the remaining reports.
- **Impact:** The existing individual DOCX could not be replaced safely in place.
- **Additional evidence:** As in the earlier group-report incident, the first sandboxed attempt to create a new `_updated.docx` sibling was also denied. This confirms a separate external-process write boundary in addition to the lock on the original.
- **Workaround:** Preserve the originals and generate `_updated.docx` siblings for all four reports using narrowly approved Pandoc execution, then render and verify those copies. Close open Word documents before a later in-place replacement.

## Recurrence: report-version archive cleanup

- **Date:** 2026-09-02
- **Context:** Enforcing the rule that `Assignment Report/` contains one current canonical DOCX for the group report and each of the four individual reports, with superseded deliverables stored in `Assignment Report/Old Versions/`.
- **Symptom:** `Move-Item` could not move `Individual_Report_1_SARIMA.docx`, reporting that the file was in use by another process. The subsequent rename of its newer sibling correctly failed because the canonical destination still existed.
- **Impact:** Reports 2-4 were archived and promoted successfully, but Report 1 temporarily still has both the old canonical file and the newer `_with_training_evidence` sibling in the parent folder.
- **Troubleshooting result:** Destination paths were validated as children of `Assignment Report/`, and no archive destination collision existed. The same file had already produced an in-place Pandoc permission error earlier, strengthening the conclusion that an application lock is the cause.
- **Remaining limitation/workaround:** Close `Individual_Report_1_SARIMA.docx` in Word or any preview/editor that holds it, then move it to `Old Versions/Individual_Report_1_SARIMA_old_version_2026-09-02.docx` and rename the newer sibling to the canonical filename.
- **Prevention:** Close report DOCX files before generation or archive promotion. Generate a temporary sibling, verify it, then archive and promote it only after confirming the canonical file is not locked.
