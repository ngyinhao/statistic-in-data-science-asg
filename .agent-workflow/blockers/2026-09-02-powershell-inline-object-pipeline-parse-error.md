# PowerShell rejected an inline object pipeline

## Context and symptom

While directly auditing the strict IEEE template's section and style XML, an inline `for` loop emitted `[pscustomobject]` values and attempted to pipe immediately after the loop's closing brace. PowerShell reported `ParserError: An empty pipe element is not allowed`.

## Impact and cause

The first read-only audit command did not run. The inline expression was syntactically ambiguous because the loop result was not assigned or parenthesized before piping.

## Resolution and prevention

Assign loop output to a dedicated array variable, then pipe that variable to `Format-List` or another consumer. This keeps audit logic readable and avoids PowerShell parser ambiguity in long tool commands.

## Recurrence

The same mistake recurred later that day in the five-report DOCX package audit when a `foreach` block was piped directly to `Format-Table`. The command was corrected by assigning the entire loop output to `$auditRows` and formatting that variable afterward. Future multi-file PowerShell audits should start with an explicit result variable rather than appending formatting after a loop.
