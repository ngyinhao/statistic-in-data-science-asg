# `apply_patch` context mismatch in multi-file report edit

## Context and intended action

On 2026-09-02, a combined patch was prepared to add parameter-justification guidance to the report plan and four individual Markdown reports.

## Observable symptom

`apply_patch` rejected the complete patch because an expected plan line did not exactly match the current file content. No part of the combined patch was applied.

## Impact

The report revision was delayed, but existing files were not partially modified.

## Likely cause

The plan had wording or structural changes that differed from the context used to construct the patch.

## Workaround

Re-read the exact surrounding lines, divide the edit into smaller file-specific patches, and use stable nearby headings as patch anchors. Verify changes after each group of edits.

## Prevention

Before a large multi-file patch, retrieve the current exact context for every target. Prefer several focused patches when files are actively evolving.
