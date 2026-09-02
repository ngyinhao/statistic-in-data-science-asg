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
