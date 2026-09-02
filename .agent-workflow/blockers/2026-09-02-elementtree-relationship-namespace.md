# ElementTree emitted an undeclared relationship namespace

## Context and intended action

On 2026-09-02, a reusable Pandoc reference DOCX was derived from the supplied IEEE-style Word reference by editing `word/document.xml` with Python's `xml.etree.ElementTree`. The derived reference was then used to generate `Assignment Report/Group_Report.docx`.

## Symptom

An XML structural audit of the generated report failed with:

`XMLSyntaxError: Namespace prefix ns2 for id on footerReference is not defined`

The generated `word/document.xml` contained a footer relationship attribute written as `ns2:id` without a corresponding `xmlns:ns2` declaration.

## Impact

The DOCX ZIP package was created, but its main document XML was malformed. Structural inspection and standards-compliant DOCX consumers could reject the file.

## Cause

The transformation script registered the WordprocessingML `w` namespace but did not register the Office relationships namespace. ElementTree therefore rewrote relationship attributes with an unstable prefix that was not safely declared in the serialized root.

## Resolution

Register `http://schemas.openxmlformats.org/officeDocument/2006/relationships` as the `r` namespace before parsing and serializing the XML. Rebuild the reference DOCX and all outputs that used it, then validate every XML part in the final package.

## Prevention

- Register every namespace used by attributes or elements before serializing OOXML.
- Parse all XML parts in generated Office packages as a validation gate.
- Do not rely only on whether Microsoft Word can open a DOCX; also validate package XML structurally.
