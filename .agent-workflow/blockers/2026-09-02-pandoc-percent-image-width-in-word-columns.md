# Pandoc percentage image width overflowed Word columns

## Context and intended action

The group report uses a one-column cover followed by a two-column Word section. Markdown figures were marked with `{width=100%}` with the intention that they fill the active column.

## Symptom and impact

The final Word render showed both figures extending through the column gutter and beyond the page edge. Plot titles and axes were clipped, even though the document's section structure was correct.

## Cause

For this DOCX conversion, Pandoc resolved the percentage image width against the page text area rather than the active Word column width. A 100% image therefore became approximately twice as wide as a single column.

## Resolution

Use an explicit physical width that is smaller than the calculated column width. With the report's Letter page, margins, and gutter, each column is about 3.47 inches wide; the figures were set to `3.25in` in Markdown.

## Prevention

- Prefer explicit inch widths for DOCX figures placed in multi-column sections.
- Calculate the usable column width from page width, margins, column count, and gutter.
- Render every page after conversion; structural XML checks cannot detect visual overflow or clipping.
