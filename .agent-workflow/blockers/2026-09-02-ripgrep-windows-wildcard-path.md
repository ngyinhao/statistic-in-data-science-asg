# Ripgrep rejected a Windows wildcard path argument

## Context and symptom

During the IEEE Markdown source audit, `rg` was given the literal Windows path argument `Assignment Report\Individual_Report_*.md`. It failed with `The filename, directory name, or volume label syntax is incorrect (os error 123)`.

## Impact and cause

The first search did not scan the individual Markdown files because Windows did not expand the wildcard path for ripgrep.

## Resolution and prevention

Pass the directory as the search root and use ripgrep's glob option instead, for example `rg -g 'Individual_Report_*.md' PATTERN 'Assignment Report'`. This is portable and avoids shell-dependent wildcard expansion.

## Recurrence on 2026-09-02

The same literal wildcard path was inadvertently reused while verifying the individual-report evidence edits and produced the same Windows `os error 123`. The command's other read-only checks still ran, so no files were affected. Future verification commands should use `rg -g 'Individual_Report_*.md' ... 'Assignment Report'` exclusively.

The error recurred during the later audit for cross-model comparison language because the file glob was again supplied as part of the path argument. No files were changed by the failed read-only search. The documented `-g "Individual_Report_*.md" "Assignment Report"` form succeeded immediately and remains the required workaround.

The blocker recurred while locating metric-table images across the individual reports. Supplying `Assignment Report\Individual_Report_*.md` as a positional argument again produced Windows `os error 123`; switching to the documented `-g "Individual_Report_*.md"` form completed the scan successfully.

The blocker recurred while auditing individual-report headings. The initial positional wildcard again failed with Windows `os error 123`; the replacement command using `rg -g "Individual_Report_*.md" ... "Assignment Report"` successfully scanned all four reports. No report content was changed by the failed read-only command.

The blocker recurred while locating six-metric and training-versus-test references. A positional `Assignment Report/*.md` argument produced Windows `os error 123`; subsequent searches use the report directory with `-g "*.md"`. The failed command was read-only and did not affect the analysis or reports.

During final DOCX visual QA, `Get-FileHash -LiteralPath '*-page-1.png'` failed with the same invalid-path symptom because PowerShell's `-LiteralPath` intentionally does not expand wildcards. For PowerShell cmdlets, use `-Path` when a wildcard is required, or enumerate exact paths and retain `-LiteralPath` for safety. The PNG copies had already succeeded and no artifact was affected.
