# Group report two-column formatting contract

## Reference

- Authoritative visual reference: `C:\Dev\statistic-in-data-science-asg\NASA_Solar_Irradiance_Report.docx`
- SHA-256: `2836B09E6E9C057AD78B91EDEDDDD66667124D81C0A4AA97F1EE82740AC669ED`
- Pandoc reference derivative: `C:\Dev\statistic-in-data-science-asg\Assignment Report\IEEE-reference.docx`
- Derivative SHA-256: `FA811C7A7875E0DC96639873FD0C5350C800CD7A0C1732B3888C3AC5C8A4AB00`
- The derivative preserves the source package and styles while setting every reference section to two columns so Pandoc's selected final section is deterministic.
- Rendered page count: 4
- Section count: 2
- Evidence: `template-reference-word-render/`, `template-style-evidence.json`, and the packaged section XML inspection performed on 2026-09-02.

## Page system

- US Letter portrait: 12,240 x 15,840 DXA.
- Margins: left/right 979 DXA (0.680 in), top 936 DXA (0.650 in), bottom 893 DXA (0.620 in).
- Section 1: one column, new-page boundary after the cover.
- Section 2: two equal columns with a 300 DXA (0.208 in) gutter.
- Body header: compact course/report identifier; body footer: centered Arabic page number.
- Every body element remains in the two-column flow. Wide comparisons are split into compact column-width tables instead of introducing a one-column section.

## Typography and components

- Primary family: Times New Roman.
- Cover: centered university/course/report hierarchy, prominent report title, restrained navy accent, metadata and contribution table, centered footer.
- Body: compact conference density; justified serif body; dark navy, bold, uppercase Roman-numeral section headings; italic centered figure captions.
- Tables: thin black rules, compact rows, pale blue header fill, bold centered headers, numeric columns centered or right aligned.
- Figures: fit within the active column unless intentionally placed in a full-width section; captions remain attached to figures.

## Content flow and slots

- Preserve the Markdown report's title metadata, cover placeholders, contribution table, four main sections, two figures, comparison table, and IEEE bibliography.
- The Markdown source remains the content authority. The reference controls only Word page geometry, columns, typography, headers/footers, and table/figure treatment.
- The cover-to-body raw OpenXML next-page break is the only section transition in the Markdown. The reference DOCX supplies the final two-column body section.

## Package preservation and fidelity gates

- The reference DOCX remains unchanged; it is consumed only through Pandoc `reference-doc` behavior.
- The generated report must contain one one-column cover section followed by a two-column body; all tables and figures must remain within the active column width.
- No clipping, overlapping text, broken tables, missing figures, missing citations, stranded headings, or unintended blank pages.
- Every generated page must be rendered through Microsoft Word export and inspected because LibreOffice is unavailable in this workspace.
