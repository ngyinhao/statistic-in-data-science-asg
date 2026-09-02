# `pdftotext` unavailable in PowerShell environment

## Context and intended action

On 2026-09-01, the assignment PDF needed to be checked against the Markdown group-report plan. The intended read-only workflow used `pdfinfo` for metadata and `pdftotext -layout` for text extraction.

## Observable symptom

`pdfinfo` succeeded, but PowerShell reported that `pdftotext` was not recognized as a cmdlet, function, script file, or executable program.

## Impact

Direct command-line text extraction with Poppler is unavailable from the current `PATH`. PDF verification must use the bundled workspace runtime, a Python PDF library, or rendered page images.

## Likely cause

The environment exposes `pdfinfo` but does not expose a `pdftotext` executable on `PATH`, suggesting an incomplete or differently packaged Poppler installation.

## Troubleshooting and result

- Confirmed that `pdfinfo` can read the six-page PDF.
- The chained `pdftotext` command failed before extraction.

## Workaround

Use the Codex bundled workspace dependencies and extract text through `pypdf` or `pdfplumber`. For layout-sensitive verification, render the relevant page to an image and inspect it visually.

## Prevention

- Load the bundled document/PDF runtime before PDF work on this Windows environment.
- Check the resolved paths of both `pdfinfo` and `pdftotext` before assuming the full Poppler toolset is available.
