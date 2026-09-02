# PowerShell rejected direct pipeline after foreach statement

## Context and intended action

A read-only QA command was estimating body word counts for the five Markdown reports.

## Observable symptom

PowerShell raised `An empty pipe element is not allowed` at the pipe placed immediately after a `foreach` statement.

## Impact

The word-count QA check did not run on the first attempt; no files were changed.

## Cause

The statement-form `foreach (...) { ... }` was used as though its output could be piped directly in that command context.

## Workaround

Accumulate objects in an array inside the loop, then pipe the completed array to `Format-Table`.

## Prevention

Use `ForEach-Object` for pipeline-native iteration or explicitly collect statement-loop results before piping.

## Recurrence on 2026-09-02

The same statement-form `foreach (...) { ... } | Format-Table` pattern was reused while counting rendered pages for the four updated individual reports and produced the same parser error. No files were changed. The validated fix remains to collect objects in an array and pipe the completed array afterward.

A second recurrence occurred during read-only DOCX XML inspection when a statement-form loop was again followed directly by `| Format-Table`. It produced the same parser error and changed no files. This repeated failure confirms that inspection snippets should initialize `$rows = @()`, append inside the loop, and format `$rows` only after the loop closes.
