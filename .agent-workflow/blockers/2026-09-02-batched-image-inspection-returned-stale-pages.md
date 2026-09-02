# Batched image inspection returned stale or mismatched page previews

## Context and intended action

On 2026-09-02, the four individual report DOCX files were rendered and several page PNGs were passed to `view_image` together for visual QA.

## Observable symptom

The batched preview showed stale or mismatched first-page images for the Holt–Winters and linear-regression reports: titles appeared missing and author blocks appeared shifted outside the page. Viewing those same PNG paths individually immediately displayed complete, correctly positioned pages. This recurred even after copying the files to unique basenames.

## Impact

A batched visual review could incorrectly attribute cached or mismatched previews to the DOCX layout and trigger unnecessary document edits or rebuilds.

## Likely cause

The evidence points to the multi-image inspection path returning stale or mismatched image content. Earlier suspicion of concurrent LibreOffice interference was disproved when the exact same generated files displayed correctly in individual `view_image` calls.

## Troubleshooting and result

- Confirmed title text structurally inside each DOCX.
- Confirmed the affected PNGs had fresh timestamps.
- Re-rendered into fresh output directories.
- Viewed each suspect PNG individually; the complete title and author block appeared correctly.
- Inspected every final page individually before delivery.

## Workaround

Use a fresh output directory for the shipping-gate pass and inspect suspect or critical pages with one `view_image` call per image. Do not diagnose layout defects from a batched multi-image preview until the exact file is opened individually.

## Prevention

Add reliable identity metadata to batched image previews or disable result caching across files with repeated page names. Retain structural title checks as a secondary validation.

## Related QA recurrence

After restoring the known-good two-page DOCX versions, a QA copy loop incorrectly assumed the earlier flawed rebuild's three-page count and attempted to copy `page-3.png`. The renderer had correctly produced only pages 1–2, so PowerShell reported four missing-path errors; the eight real PNGs were unaffected. Final QA scripts should enumerate the renderer's actual `page-*.png` outputs per document rather than carrying page-count assumptions between versions.
