# Pandoc defaults rejected top-level link-citations

## Context and intended action

All five Markdown reports were being parsed with their reusable Pandoc defaults files to verify citations, images, and document structure.

## Observable symptom

Pandoc stopped while parsing `pandoc-group.yaml` with `Unknown option "link-citations"`.

## Impact

None of the report sources could be conversion-validated through the defaults file.

## Confirmed cause

`link-citations` is Pandoc document metadata for the citation processor, not a supported top-level defaults option in the installed Pandoc version.

## Troubleshooting and result

Moved `link-citations: true` under a `metadata:` mapping in both group and individual defaults files.

## Workaround

Use:

```yaml
metadata:
  link-citations: true
```

## Prevention

Validate reusable defaults with a no-output Pandoc parse before relying on them for DOCX conversion.
