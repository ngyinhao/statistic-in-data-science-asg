# Circular Normal style made generated DOCX files unreadable in Word

## Context and intended action

The normalized IEEE reference was adapted for Pandoc by cloning the template's `Body Text` style into Pandoc's expected `Normal` style. Five reports generated from that reference passed ZIP/XML parsing and section audits.

## Observable symptom

Microsoft Word refused to open the first generated report during render QA and reported: `The file appears to be corrupted.` No PDF or page images could be produced.

## Impact

All five first-pass IEEE outputs were structurally parseable but unusable in Word and therefore failed the required render gate.

## Cause

The cloned `Body Text` style retained `<w:basedOn w:val="Normal"/>` after its style ID was changed to `Normal`. This made the `Normal` style inherit from itself, creating a circular style definition that Word rejected.

## Resolution

When cloning `Body Text` to `Normal`, remove its `w:basedOn` element. Rebuild the Pandoc reference and regenerate every dependent output before rendering again.

## Further evidence and final workaround

After removing the circular `basedOn` link, Word still rejected the ElementTree-rewritten reference, while it continued to open the untouched strict template successfully. This showed that the direct XML reserialization introduced at least one additional Word-level incompatibility not detected by XML parsing.

The reliable workaround is to discard the XML-rewritten derivative, create a fresh transitional copy with Microsoft Word `SaveAs2`, and apply the two-column, `Normal`, `Title`, and `Caption` adaptations through Word's own document model. This preserves a Word-valid package and avoids reserializing the template's complex OOXML.

## Prevention

- When renaming or cloning Word styles, audit `basedOn`, `next`, and `link` references for self-references or dangling IDs.
- For strict IEEE templates with complex namespaces, prefer Word-model normalization and style edits over whole-part XML reserialization.
- Validate generated DOCX files by opening them in Word, not only by parsing XML.
- Treat a successful ZIP/XML audit as necessary but insufficient for Office-package validity.
