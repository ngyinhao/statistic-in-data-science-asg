# Patch context changed during STL diagnostic edit

- **Date:** 2026-09-02
- **Context and intended action:** Change the NASA decomposition figure from the ACF of the original series to the ACF of the STL remainder, then update report references.
- **Symptom:** `apply_patch` reported that it could not find the expected original `Acf(series, ...)` line.
- **Impact:** The combined multi-file patch did not apply cleanly, so the remaining report-source changes had to be checked and applied separately.
- **Cause:** The R source already contained the intended `Acf(decomposition$time.series[, "remainder"], ...)` change by the time the patch was evaluated. This can occur when the working tree changes between inspection and authoring or when a multi-file patch is partially reflected.
- **Troubleshooting:** Re-read the exact lines and reviewed `git diff` before making further edits. Confirmed the R correction exists and unrelated pre-existing working-tree changes remain intact.
- **Workaround:** Apply small, file-specific patches against the current content and verify each resulting diff.
- **Prevention:** Re-read high-conflict lines immediately before patching and split independent file edits into separate patch operations.
