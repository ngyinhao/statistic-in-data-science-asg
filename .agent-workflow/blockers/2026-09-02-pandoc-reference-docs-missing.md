# Pandoc reference DOCX templates are missing

## Context and intended action

On 2026-09-02, the five Markdown assignment reports were being converted to Word with the repository's documented Pandoc workflow.

## Observable symptom

`Assignment Report/README.md` requires `IEEE-reference.docx` for the group report and `APA-reference.docx` for the individual reports, but neither file exists in the repository.

## Impact

Pandoc can produce valid DOCX files with its built-in reference document, but the outputs cannot automatically inherit the intended official IEEE two-column layout or the requested APA-specific Word styles.

## Likely cause

The templates are external, user-supplied artifacts and were never added to the repository.

## Troubleshooting and result

- Confirmed Pandoc 3.10 is installed.
- Confirmed the defaults, CSL, bibliography, Markdown sources, and image resources are present.
- Confirmed both reference DOCX filenames are absent from `Assignment Report/`.

## Workaround or remaining limitation

Convert with the checked-in Pandoc defaults and Pandoc's built-in Word reference document. Visually review the results, but treat final IEEE/APA submission formatting as incomplete until the appropriate reference templates are supplied and the conversion is rerun with `--reference-doc`.

## Prevention

Keep sanitized `IEEE-reference.docx` and `APA-reference.docx` files beside the Pandoc defaults, or document an approved reproducible process for generating them.
