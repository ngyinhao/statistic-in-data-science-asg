# PowerShell native-command XML output was not normalized to one string

## Context and symptom

During read-only inspection of DOCX `document.xml`, the output from `tar -xOf` was assigned directly and then passed to `IndexOf()`/`Substring()`. PowerShell treated the native-command output as an array of lines, causing `Substring()` to fail with an index/length exception.

## Impact and cause

The first XML-context inspection did not run; no files were changed. The code assumed native output was one scalar string.

## Workaround and prevention

Normalize native multiline output before string indexing, for example `$xml = (tar -xOf file.docx word/document.xml | Out-String)`, or use a stream reader for large XML parts.
