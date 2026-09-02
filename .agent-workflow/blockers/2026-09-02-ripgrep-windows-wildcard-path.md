# Ripgrep rejected a Windows wildcard path argument

## Context and symptom

During the IEEE Markdown source audit, `rg` was given the literal Windows path argument `Assignment Report\Individual_Report_*.md`. It failed with `The filename, directory name, or volume label syntax is incorrect (os error 123)`.

## Impact and cause

The first search did not scan the individual Markdown files because Windows did not expand the wildcard path for ripgrep.

## Resolution and prevention

Pass the directory as the search root and use ripgrep's glob option instead, for example `rg -g 'Individual_Report_*.md' PATTERN 'Assignment Report'`. This is portable and avoids shell-dependent wildcard expansion.
