# Ripgrep regular expression was truncated by PowerShell quoting

## Context and intended action

After restructuring the individual reports, a verification command attempted to search several obsolete phrases and a quoted Pandoc custom-style marker using one alternation regular expression passed through PowerShell.

## Symptom and impact

Ripgrep reported `regex parse error` and `unclosed group`. The heading-order verification that preceded it completed successfully, but this secondary obsolete-text scan did not run.

## Likely cause

Embedded double quotes in the regex conflicted with the surrounding PowerShell command quoting and truncated the final alternative before ripgrep received it.

## Workaround and prevention

For literal audit phrases, use ripgrep fixed-string mode with separate `-e` patterns enclosed in PowerShell single quotes. Reserve a combined regular expression for cases that need regex semantics, and avoid nested double-quote escaping across JavaScript and PowerShell command layers.
