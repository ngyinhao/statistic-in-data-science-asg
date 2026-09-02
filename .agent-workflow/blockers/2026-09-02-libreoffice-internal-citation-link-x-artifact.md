# LibreOffice rendered internal citation hyperlinks with visible X artifacts

## Context and intended action

The four Pandoc-generated individual DOCX reports were rendered through LibreOffice for final visual QA.

## Symptom and impact

An unexplained visible `X` appeared immediately after some citations at paragraph endings and before a display equation. The Markdown and `document.xml` contained no literal X at those locations, so the reports were visually defective despite structurally correct text.

## Cause and troubleshooting

The individual Pandoc defaults enabled `metadata.link-citations: true`, producing internal `w:hyperlink` anchors for citation numbers. A controlled SARIMA rebuild with `-M link-citations=false` removed every visible X while preserving citation numbers and ordinary reference-list URLs. This isolates the artifact to LibreOffice's rendering of those internal citation links in the current IEEE DOCX template.

## Workaround and prevention

Set `link-citations: false` in `pandoc-individual.yaml` for LibreOffice-verified individual reports. Reference URLs remain clickable, while citation numbers are plain text. Re-enable internal citation links only after testing the exact Word/LibreOffice conversion path.
