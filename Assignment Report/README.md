# Assignment Report sources

## Change-control requirement

Before editing or regenerating any group or individual report, first add a `Proposed` entry to Section 1.2, **Report change log**, in [`BMMS2094_Group_and_Individual_Report_Plan.md`](../BMMS2094_Group_and_Individual_Report_Plan.md). After applying and validating the recorded scope, update that same entry to `Applied and verified`. The project-level `AGENTS.md` makes this sequence mandatory for future report work.

Do not regenerate or replace a report DOCX or PDF unless the user's current request explicitly mentions regenerating, exporting, converting, or updating the generated document. Editing Markdown, analysis, evidence, or the report plan alone does not authorize document generation; record it as pending instead.

Transition status as of 2026-09-04: the group report and individual-report sources now use SARIMA, additive no-trend Holt-Winters, ETS, and a Basic Structural Model. Existing report DOCX files were not regenerated after these source revisions and must be treated as stale until generation is explicitly authorised. In particular, `Individual_Report_4_Trend_Season_Regression.docx` is a legacy artifact and must not be submitted as the fourth-model report.

Forecasting scope: models are trained on January 2001–December 2020 and evaluated only on the 60 known observations from January 2021–December 2025. The report sources do not require a 2026 or other beyond-sample forecast because accuracy cannot be assessed without actual values.

This folder contains the five Markdown report sources required by the BMMS2094 plan:

1. `Group_Report.md` — one IEEE-style group report.
2. `Individual_Report_1_SARIMA.md` — Member 1, Times New Roman 12 pt with APA citations.
3. `Individual_Report_2_Holt_Winters.md` — Member 2, Times New Roman 12 pt with APA citations.
4. `Individual_Report_3_ETS.md` — Member 3, Times New Roman 12 pt with APA citations.
5. `Individual_Report_4_Basic_Structural_Model.md` — Member 4, Times New Roman 12 pt with APA citations.

## Report version policy

Keep exactly one current Word deliverable for each of the five reports in this folder, using these canonical filenames:

1. `Group_Report.docx`
2. `Individual_Report_1_SARIMA.docx`
3. `Individual_Report_2_Holt_Winters.docx`
4. `Individual_Report_3_ETS.docx`
5. `Individual_Report_4_Basic_Structural_Model.docx`

Before replacing any current Word deliverable, move the existing file into `Old Versions/` and rename it by appending `_old_version_YYYY-MM-DD` before `.docx`. If more than one version is archived on the same date, append `_2`, `_3`, and so on. New versions must use the canonical filename and must not include labels such as `updated`, `final`, `new`, or `with_training_evidence`.

Markdown sources, conversion configuration, and the IEEE reference template are supporting files rather than additional report versions.

Each individual report must evaluate only its assigned model. Do not rank it against, describe its performance relative to, or select it over another group member's model; cross-model comparison belongs only in the group report.

Numerical results must agree with the current model evidence under the locked 80:20 chronological design. The R workflow supplies the SARIMA, Holt-Winters, and ETS results; the BSM source is `../NASA_Solar_Irradiance_BSM.py`, with its audit summary in `../analysis_outputs/nasa/nasa_bsm_summary.json`. Replace every bracketed administrative placeholder before submission.

## IEEE Word conversion

Markdown does not itself impose all Word geometry and styles. The supplied `../conference-template-letter.docx` is the authoritative IEEE US-letter template. `IEEE-conference-reference.docx` is its Pandoc-compatible normalized derivative; `pandoc-group.yaml` selects it for the group report. Run:

```powershell
pandoc 'Group_Report.md' `
  --defaults 'pandoc-group.yaml' `
  -o 'Group_Report.docx'
```

Pandoc applies numbered IEEE citations through `ieee.csl`; the reference DOCX controls Word styles and page geometry. The Markdown supplies a full-width title/author section followed by a continuous two-column body. All body tables and figures must stay within one column.

## Individual Word conversion

Individual reports require Times New Roman 12 pt and APA referencing. `pandoc-individual.yaml` selects `apa.csl` and records the required font metadata; the generated Word styles must also be checked against these requirements during authorised generation and visual QA. Run, for example:

```powershell
pandoc 'Individual_Report_1_SARIMA.md' `
  --defaults 'pandoc-individual.yaml' `
  -o 'Individual_Report_1_SARIMA.docx'
```

Repeat for the other three individual files.

The current DOCX files have not been regenerated from the revised Markdown sources. When generation is explicitly authorised, archive each replaced document under the version policy, verify the group document against the IEEE template, verify each individual document against Times New Roman 12 pt and APA requirements, and create `Individual_Report_4_Basic_Structural_Model.docx` in place of the legacy regression deliverable.

## Required final checks

- Replace names, IDs, group/tutorial identifiers, signatures, contribution percentages, university/faculty details, semester/session, and submission date.
- Ensure four group contributions total exactly 100%.
- Regenerate the analysis before changing any reported number.
- Do not describe irradiance as photovoltaic electricity output.
- Inspect all PDF exports visually for formatting, legibility, and completeness.
