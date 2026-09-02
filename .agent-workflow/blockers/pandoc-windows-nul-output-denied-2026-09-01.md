# Pandoc could not write validation output to Windows NUL

## Context and intended action

Pandoc was being used in a parse-only validation pass for the five Markdown reports, with native output directed to the Windows `NUL` device.

## Observable symptom

Pandoc failed with `NUL: withFile: permission denied`.

## Impact

The first validation attempt stopped even though the defaults file had parsed successfully.

## Likely cause

The installed Pandoc/GHC Windows build attempted to treat `NUL` as a regular file under the restricted workspace rather than as a writable device.

## Workaround

Write Pandoc's native representation to standard output and pipe it to PowerShell `Out-Null`; this exercises parsing, citation processing, and resource resolution without filesystem output.

## Prevention

For no-artifact Pandoc validation on this Windows workspace, prefer stdout disposal over `--output NUL`.
