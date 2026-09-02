# IEEE conference report formatting contract

## Reference

- Authoritative retained reference: `C:\Dev\statistic-in-data-science-asg\conference-template-letter.docx`
- Retained reference SHA-256: `4589779A1A74782DC5A7A657A9907F243C9DD54510CB6C154ACAF24CC9079852`
- Pandoc reference derivative: `C:\Dev\statistic-in-data-science-asg\Assignment Report\IEEE-conference-reference.docx`
- Pandoc reference derivative SHA-256: `0BA7D98929ABF22A06489E85724557374968EFE6A751C53F5F222CDC706749D9`
- Reference page count: 3
- Reference section count: 7 (title, author-grid, body, and template demonstration transitions)
- Visual evidence: `%TEMP%\codex-conference-template-distill\reference-page-1.png` through `reference-page-3.png`
- The retained reference uses strict ISO OOXML namespaces. Microsoft Word is used to save a transitional working copy; the retained file remains unchanged.

## Page system

- US Letter portrait: 612 x 792 points (8.5 x 11 inches).
- Margins: top 54 pt (0.75 in), bottom 72 pt (1.00 in), left/right approximately 44.65 pt (0.62 in).
- IEEE paper body: two equal columns, 18 pt (0.25 in) gutter, approximately 3.38 inches per column.
- Title and author/affiliation block: full width at the top of the first page, followed by a continuous transition to two-column text.
- No independent cover page and no page-number footer.
- The reference derivative forces a continuous final section and disables first/even-page header/footer variants so the title and two-column body share page 1.

## Typography and components

- Times New Roman throughout.
- Paper title: source `paper title` style, 24 pt, centred.
- Author: source `Author` style, 11 pt, centred.
- Affiliation: source `Affiliation` style, centred.
- Body: source `Body Text` treatment, 10 pt, justified, approximately 0.20-inch first-line indent and compact paragraph rhythm.
- Heading 1: centred IEEE component heading using uppercase Roman-numeral labels supplied by the Markdown.
- Heading 2: left-aligned italic subordinate heading.
- Abstract: compact justified run-in label and text; keywords follow in the same IEEE first-page region.
- Figure captions: source `figure caption` treatment, 8 pt, below figures.
- References: IEEE numeric citations and compact reference-list typography.
- Source code: 7 pt Courier New, left aligned, with no first-line indent or justified spacing.
- Tables and figures stay inside one column unless explicitly authorized otherwise. For these reports, no body table or figure spans both columns.
- A reusable Pandoc Lua filter assigns column-specific relative widths to 2-, 3-, 4-, and 5-column tables so metric labels and numeric values remain readable inside one IEEE column.

## Content flow and slots

- Each output begins with a descriptive paper title, author placeholder(s), affiliation/course metadata, abstract, and keywords.
- Group report retains the member contribution information as a compact column-width body table.
- Individual reports retain student, ID, tutorial/group, assigned model, dataset, and submission-date placeholders in the author/affiliation block.
- Main sections use explicit IEEE Roman numerals. References and appendices remain unnumbered component headings.
- Existing numerical results, citations, figures, equations, code, and caveats remain content-authoritative.

## Package adaptation and fidelity gates

- The strict retained template is never modified.
- The Pandoc reference derivative is created and adjusted through Microsoft Word's document model. It preserves the normalized template styles and page geometry, sets the default/final section to two columns, maps Pandoc's `Title`, `Normal`, and `Caption` roles to the corresponding IEEE source treatments, and removes template instructional content from outputs by using Pandoc reference-doc semantics.
- Generated outputs must contain one full-width title section followed by a two-column body on the same first page.
- Every table and figure must fit within the active column. Explicit figure width is 3.20 inches unless a smaller value is required during QA.
- No template guidance text, copyright placeholder, funding placeholder, clipping, overlap, broken tables, missing citations, unintended blank pages, or one-column body sections may remain.
- Every page of every final DOCX must be rendered in Microsoft Word and visually inspected because the bundled renderer cannot process the strict retained source and LibreOffice is unavailable.
