# Windows `rg` quoted wildcard path failure

## Context and intended action

On 2026-09-02, the report-review workflow attempted to search headings and metric terms across all `Assignment Report/Individual_Report_*.md` files with one `rg` command.

## Observable symptom

Ripgrep returned Windows error 123 for the quoted path containing `*`: “The filename, directory name, or volume label syntax is incorrect.” The separately named group-report file was still searched.

## Impact

The combined search did not inspect the individual report files, so the report comparison had to use a different enumeration method.

## Likely cause

On this Windows/PowerShell setup, the quoted wildcard was passed to `rg` as a literal path rather than expanded into matching filenames.

## Troubleshooting and workaround

Enumerate matching files with `Get-ChildItem` and pipe the resolved file objects or full paths into `Select-String`, or search the containing directory and restrict matches with `-g 'Individual_Report_*.md'`.

## Prevention

Prefer `rg -g 'Individual_Report_*.md' PATTERN 'Assignment Report'` for future repository searches. Avoid passing a quoted wildcard as a positional Windows path to `rg`.
