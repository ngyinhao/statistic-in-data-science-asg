# BMMS2094 Assignment Plan: One Group Report and Four Individual Reports

## 1. Purpose of This Plan

This document is the working plan for a four-member BMMS2094 Statistics for Data Science assignment team. The final submission package must contain:

- **1 group report** covering the common problem, dataset, workflow, comparison of all models, SDG relevance, and overall conclusions.
- **4 individual reports**, with one report per member and one forecasting model assigned to each member.

This plan is based on the requirements and rubrics in [1. BMMS2094 Assignment.pdf](./1.%20BMMS2094%20Assignment.pdf), while also reviewing the current [NASA solar-irradiance group report](./Assignment%20Report/Group_Report.docx), [model research notes](./NASA_Solar_Irradiance_Model_Research.md), [R analysis script](./NASA_Solar_Irradiance_Forecasting.R), the [BSM analysis helper](./NASA_Solar_Irradiance_BSM.py), and generated analysis outputs.

### 1.1 Report change-control rule

This file is the authoritative planning and consistency record for the group report and all four individual reports. **Before changing any report source or generated report file, record the proposed change in the change log below.** The entry must identify the affected report, the exact intended content change, the evidence or user decision supporting it, the files expected to change, and the checks required. Only then may the report be edited. After implementation, update the same entry with the applied status, actual files changed, validation results, and any unresolved inconsistency.

This sequence is mandatory:

1. Add a `Proposed` entry to this plan before editing a group or individual report.
2. Check the proposal against the fixed dataset, split, model allocation, metric definitions, and current evidence files.
3. Apply only the recorded report change.
4. Regenerate a Word/PDF deliverable only when the user's current request explicitly mentions regenerating, exporting, converting, or updating that generated document. Otherwise, leave generated artifacts unchanged and record generation and visual QA as pending.
5. Change the entry to `Applied and verified` for the authorized scope, listing the checks performed and any follow-up work. Do not label a generated artifact as verified when regeneration was not requested.

An entry in this plan documents scope and consistency; it does not replace any separate approval required for destructive, external, submission, or publication actions.

**Generated-report authorization rule:** report source changes do not automatically authorize DOCX or PDF regeneration. Generated report files may be created or replaced only when the user explicitly mentions that action in the current request.

### 1.2 Report change log

| Date | Report(s) | Planned change and basis | Status and verification |
|---|---|---|---|
| 2026-09-04 | Group report | **Proposed.** Expand the group-report model-comparison table from RMSE, MAE, and residual p-value to the ordered columns `Model`, `Train RMSE`, `Test RMSE`, `Test MAE`, `Test MAPE`, `Test MSE`, `Test ME`, `Test MPE`, and `Ljung-Box Q(24) p`. Show training and test values only for RMSE; all other accuracy measures are test-set metrics. Explain that the train-test RMSE gap is a generalization diagnostic and possible overfitting indicator, not definitive proof of overfitting, because in-sample residual error and multi-step holdout forecast error are not directly equivalent. Keep model ranking based primarily on test RMSE. Basis: the current `nasa_model_accuracy.csv`, the manual SARIMA evidence bundle, and shared residual diagnostics. Affected models, data, metrics, figures, citations, and conclusions: the four-model accuracy table, its footnote, and nearby comparative interpretation in `Assignment Report/Group_Report.md`, plus the equivalent future DOCX table and wording in `analysis_outputs/build_reports.py`; no model fit, dataset, chronological split, evidence CSV, figure, citation, ranking, or conclusion changes. Expected files: `BMMS2094_Group_and_Individual_Report_Plan.md`, `Assignment Report/Group_Report.md`, `analysis_outputs/build_reports.py`, and the operating record. No DOCX or PDF will be regenerated or modified. Validation required: verify all displayed values against shared and manual-SARIMA accuracy and residual-diagnostic evidence; confirm only RMSE has train/test columns, the requested column order is exact, rows remain ordered by test RMSE, overfitting language is appropriately qualified, Python syntax parses, targeted source searches pass, the scoped diff preserves unrelated work, and `git diff --check` passes. | **Applied and verified for source scope.** Updated `Assignment Report/Group_Report.md`, `analysis_outputs/build_reports.py`, this plan, and the operating record. The table now uses the exact requested order and includes train/test values only for RMSE; MAE, MAPE, MSE, ME, and MPE are test-set values, followed by the lag-24 Ljung--Box p-value. All displayed values match the shared evidence with manual SARIMA substitution, and rows remain ordered SARIMA, ETS, BSM, then Holt--Winters by test RMSE. The report and builder explain that the RMSE gap is a generalization and possible-overfitting indicator rather than definitive proof, and preserve test RMSE as the primary ranking metric. Python AST parsing, builder import, evidence and row-order assertions, targeted column and wording checks, Pandoc source parsing, and `git diff --check` passed; `git diff --check` emitted line-ending warnings only. No DOCX/PDF was regenerated or modified; generated-document regeneration and visual QA remain pending explicit authorisation. Changes remain uncommitted on local `main`; nothing was pushed, merged, or deployed. |
| 2026-09-04 | Individual Report 1 (SARIMA), group report if the selected SARIMA results change, and SARIMA analysis evidence | **Proposed.** Replace the eight manually enumerated SARIMA candidates with a bounded 27-candidate training-only grid over $p,q,P\in\{0,1,2\}$ while retaining the evidence-based fixed settings $m=12$, $d=0$, $D=1$, and $Q=1$. Explain why each dimension is fixed or searched, describe the procedure as a restricted diagnostic-guided search, and select the lowest training AICc model only after convergence, lag-24 Ljung--Box, and non-negative-forecast gates. The January 2021--December 2025 actual values must not influence order selection. Affected models, data, metrics, figures, citations, and conclusions: the SARIMA candidate comparison, selected order and coefficients, residual diagnostics, holdout forecasts and accuracy, SARIMA figures, and any group comparison or conclusion that cites those results may change; the fixed 300-month dataset, 240/60 chronological split, metric definitions, other three model fits, and citations remain unchanged. Expected files: `BMMS2094_Group_and_Individual_Report_Plan.md`, `NASA_Solar_Irradiance_Forecasting.R`, `NASA_Solar_Irradiance_Model_Research.md`, `Assignment Report/Individual_Report_1_SARIMA.md`, potentially `Assignment Report/Group_Report.md`, and regenerated SARIMA/shared CSV and PNG evidence under `analysis_outputs/nasa/`. No DOCX or PDF will be regenerated. Validation required: confirm exactly 27 unique candidates and fixed/search dimensions; verify selection uses training AICc and declared gates without test-actual leakage; rerun the analysis; reconcile every changed SARIMA number and conclusion across sources; verify 60 holdout predictions, metric calculations, residual test, non-negative forecasts, figure outputs, and unchanged non-SARIMA results; review the scoped diff; and run `git diff --check`. | **Applied and verified.** Updated `NASA_Solar_Irradiance_Forecasting.R`, `NASA_Solar_Irradiance_Model_Research.md`, `Assignment Report/Individual_Report_1_SARIMA.md`, this plan, the operating record, and affected SARIMA/shared CSV and PNG evidence under `analysis_outputs/nasa/`. The real R and BSM pipeline produced 27 unique candidates: 25 converged, 19 passed the white-noise gate, 26 produced non-negative forecasts, and 18 were eligible. ARIMA$(1,0,0)(0,1,1)_{12}$ remained selected with AICc 102.2697, lag-24 Ljung--Box $p=0.1046$, test RMSE 0.2850, and test MAE 0.2198. Independent checks confirmed fixed $d=0$, $D=1$, $Q=1$, 60 unique non-negative SARIMA holdout predictions, training-only order selection, consistent Markdown/CSV evidence, and unchanged non-SARIMA rows. The group report required no edit because its selected order and reported values remained correct. `git diff --check` passed. R emitted non-fatal locale-setting warnings only. No DOCX/PDF was regenerated; existing generated reports remain stale pending separate regeneration authorisation. Changes are uncommitted on `main`; nothing was pushed, merged, or deployed. |
| 2026-09-04 | Group report, Individual Report 1 (SARIMA), and shared report/analysis guidance | **Proposed.** Restrict the project to out-of-sample model evaluation on observations with known actual values: train on January 2001-December 2020, generate only the 60 January 2021-December 2025 test predictions, and compare those predictions with actuals. Remove the 2026/full-data future-forecast requirement, narrative, code path, and report-builder dependencies because forecasts without observed outcomes cannot contribute to the requested accuracy assessment. Retain rolling-origin horizon-12 validation where it evaluates known historical observations. Affected model/conclusion: the locked SARIMA remains the selected model on unchanged holdout metrics, but no full-data refit or 2026 forecast is required; the Holt-Winters, ETS, and BSM holdout analyses and metrics remain unchanged. Affected data/metrics/figures/citations: the fixed 300-month dataset, 240/60 split, holdout predictions, actuals, accuracy metrics, test figures, residual diagnostics, and citations remain unchanged; dedicated 2026 forecast tables/figures are removed from source requirements but existing generated CSV/PNG artifacts are not deleted. Expected files: `BMMS2094_Group_and_Individual_Report_Plan.md`, `Assignment Report/Group_Report.md`, `Assignment Report/Individual_Report_1_SARIMA.md`, `Assignment Report/README.md`, `NASA_Solar_Irradiance_Model_Research.md`, `NASA_Solar_Irradiance_Forecasting.R`, and `analysis_outputs/build_reports.py`. Individual Reports 2-4 will be reviewed and changed only if they contain out-of-range forecast requirements. No DOCX/PDF, data, metric output, or existing figure will be edited or regenerated. Validation required: targeted searches across the plan, all report Markdown sources, README, research notes, R script, and report builder; confirmation that the split and 60-observation holdout protocol remain intact; confirmation that validated holdout metrics are unchanged; review of the scoped diff; and `git diff --check`. | **Applied and verified for source scope.** Updated the seven expected files and reviewed Individual Reports 2-4 without changes. Removed active 2026/full-data forecast requirements, narrative, report-builder loading/rendering, R generation, and SARIMA appendix code while retaining the January 2001-December 2020 training period, all 60 January 2021-December 2025 test predictions and actuals, validated holdout metrics, test figures, diagnostics, citations, and rolling-origin horizon-12 validation. The report builder now composes the manual SARIMA evidence with shared ETS, BSM, and Holt-Winters evidence, sorts by RMSE, reports the current ARIMA(1,0,0)(0,1,1)[12] specification, and uses only available metrics. Targeted searches found no remaining active beyond-sample forecast path outside this audit entry; the holdout CSV contains 60 unique test dates and 60 rows per model. Python AST parsing and a read-only evidence-loading smoke test passed with the expected ranking SARIMA, ETS, BSM, then Holt-Winters and SARIMA RMSE 0.2850/Ljung-Box p=0.1046; `git diff --check` passed. R was unavailable locally, so the R edit was statically reviewed but not parsed or executed. No analysis output, figure, DOCX, or PDF was changed or regenerated. Existing generated future-forecast CSV/PNG files and generated report documents remain stale pending separate cleanup or regeneration authorisation. |
| 2026-09-04 | Group and individual report planning/instructions | Remove numerical length constraints and all related guidance from this plan and the report README, including suggested content allocations, checklist items, generation checks, and historical change-log references. Basis: the user's explicit request to remove the rule and not mention it. Preserve independent requirements for concision, report structure, formatting, citations, legibility, and visual QA. Expected files: `BMMS2094_Group_and_Individual_Report_Plan.md` and `Assignment Report/README.md` only. Validation required: targeted text searches confirming the removed constraint language is absent from both files; review of the resulting diff; and `git diff --check`. | **Applied and verified.** Updated only `BMMS2094_Group_and_Individual_Report_Plan.md` and `Assignment Report/README.md` for this request. Removed the numerical constraints, suggested allocation section, related generation and checklist instructions, and historical references while retaining independent concision, structure, formatting, citation, legibility, and visual-QA requirements. Targeted searches returned no matches, the scoped diff was reviewed, and `git diff --check` passed. No report Markdown, DOCX, PDF, analysis, code, or project instruction file was changed for this request. |
| 2026-09-04 | Group report | Retain SARIMA, additive no-trend Holt-Winters, and ETS; replace trend-and-season regression with a Basic Structural Model (stochastic local level, 12-month seasonal state, irregular error, no slope); exclude STL decomposition from the report; describe the original series as broadly stable over the long run but not perfectly flat. Basis: the user's model decision, the supplied time-series and month-of-year plots, and the common 2001-2020/2021-2025 evaluation. Expected files: group-report Markdown/DOCX, references, and NASA comparison evidence. | **Applied and verified at that stage, then superseded.** The subsequent manual Box-Jenkins revision changed the current SARIMA evidence to RMSE 0.2850, MAE 0.2198, and lag-24 Ljung-Box `p=0.1046`; the current comparison retains ETS RMSE 0.2947, BSM RMSE 0.2951, and Holt-Winters RMSE 0.3101. All four produced non-negative test forecasts and passed the declared 5% Ljung-Box gate; BSM was closest to the threshold at `p=0.0670`. The DOCX generated at that earlier stage rendered cleanly, but it no longer verifies the subsequently revised Markdown source. Regeneration and visual QA of the current group source remain pending explicit authorisation, as do administrative placeholders. |
| 2026-09-04 | Individual Report 4 and report index | Replace the legacy trend-and-season regression report with a Basic Structural Model report following Section 6.4; rename the source and, only if explicitly requested, the generated deliverable to identify BSM; update the report index and model-specific references; and use only training-period evidence for specification, including only a brief model-relevant decomposition implication or necessary compact training-only extract. Expected source files include the Individual Report 4 Markdown, `Assignment Report/README.md`, relevant references, and BSM-specific figures or tables. Required checks: evidence consistency, 60 holdout forecasts, residual diagnostics, non-negative forecasts, and APA references. DOCX generation and visual inspection require a separate explicit generation request. | **Applied and verified for source files.** Removed `Individual_Report_4_Trend_Season_Regression.md`; added `Individual_Report_4_Basic_Structural_Model.md`; and updated `Assignment Report/README.md` and `pandoc-individual.yaml`. The BSM specification, three disturbance variances, convergence, 60 non-negative holdout forecasts, RMSE 0.2951, MAE 0.2370, MAPE 5.0141%, and lag-24 Ljung-Box `p=0.0670` match the current JSON/CSV evidence. Heading order, future-tense Methodology, APA configuration, and absence of legacy regression content passed source checks. The legacy regression DOCX remains unchanged; BSM DOCX generation and visual QA are pending explicit authorisation. |
| 2026-09-04 | Individual Reports 1-3 | Remove duplicated full STL graphs and any leakage-prone decomposition evidence, retaining only a brief model-relevant training-only implication or necessary compact training-only extract without changing each report's assigned model or validated results. Expected source files: the three individual Markdown files and only the supporting figures/references required by those edits. Required checks: no test-period leakage into specification choices, APA consistency, and unchanged validated metrics unless regeneration is explicitly recorded. DOCX generation and visual inspection require a separate explicit generation request. | **Applied and verified for source files.** Updated the three Markdown sources: removed Abstract/Keywords, standardised the rubric section order, shortened the shared split statement, kept Methodology in future/conditional tense, removed the duplicated STL figure from Holt-Winters and ETS, and retained only model-relevant training evidence. SARIMA's model-specific manual identification was preserved and its current RMSE 0.2850, MAE 0.2198, and Ljung-Box `p=0.1046` were verified; Holt-Winters and ETS results were unchanged. Source parsing and consistency checks passed. DOCX regeneration and visual QA remain pending explicit authorisation. |
| 2026-09-04 | Project report-generation policy | Make generated reports opt-in: changing report sources, planning, analysis, or evidence must not automatically regenerate DOCX/PDF artifacts. Generated artifacts may be created, exported, converted, or replaced only when the user's current request explicitly mentions that action. Expected files: project instructions, report plan, and report README only. | **Applied.** Updated the three instruction/planning files. No report source, DOCX, or PDF was regenerated or modified while applying this policy. |
| 2026-09-04 | Group report and all four individual reports | Revise the reporting structure to state only the selected 80:20 chronological split and dates, with a brief future-leakage rationale and sensitivity findings only when material; keep Methodology in proposal-stage future tense; use the approved SARIMA, additive no-trend Holt-Winters, ETS, and Basic Structural Model allocation; allow one concise common STL result or figure in the group report while preventing duplicated or test-period decomposition evidence in individual reports; and organise each individual report by Methodology, Data Analysis (Results and Discussion), Conclusion, References, and Appendix. Basis: the user's latest structural decisions and the assignment rubrics. Expected source/configuration files: `Assignment Report/Group_Report.md`, all four individual-report Markdown sources, `Assignment Report/README.md`, `Assignment Report/pandoc-individual.yaml`, and references or model-specific figures only where required; generated DOCX/PDF files are excluded unless separately authorised. Validation required: content and model-allocation consistency, no future-data leakage in model identification, IEEE group source structure, Times New Roman 12 pt and APA individual configuration, concise individual content, and visual inspection only if regenerated deliverables are later authorised. | **Applied and verified for the authorised source/configuration scope.** Updated `Group_Report.md`, Individual Reports 1-3, replaced the legacy Individual Report 4 Markdown with the BSM source, updated `README.md`, and changed `pandoc-individual.yaml` to APA with Times New Roman 12 pt metadata and no IEEE reference document. The group Methodology now uses future/conditional language and the concise split statement; individual reports use the rubric section order and do not duplicate the full STL graph. All Markdown sources parsed, numerical evidence checks passed, and `git diff --check` reported no content errors. No report DOCX/PDF was regenerated or visually verified; those checks remain pending explicit authorisation. |

## 2. Fixed Project Decisions

### 2.1 Topic and dataset

- **Topic:** Forecasting monthly solar irradiance in Kuala Lumpur.
- **Dataset:** NASA POWER monthly `ALLSKY_SFC_SW_DWN` data.
- **Period currently available:** January 2001 to December 2025.
- **Number of observations:** 300 continuous monthly observations.
- **Frequency:** Monthly, with seasonal period `m = 12`.
- **Unit:** kWh/m2/day.
- **Main SDG:** United Nations **SDG 7 - Affordable and Clean Energy**, especially Target 7.2 on increasing the share of renewable energy.
- **Required justification:** Explain how forecasting seasonal solar-resource availability can support preliminary renewable-energy planning, maintenance scheduling, storage planning, and feasibility assessment. Do not claim that irradiance is the same as electricity production.

### 2.2 Four-member model allocation

| Member | Assigned individual model | Main individual responsibility |
|---|---|---|
| Member 1: `[Name / ID]` | **SARIMA** | Stationarity, differencing, ARIMA order selection, estimation, residual diagnosis, and forecast interpretation |
| Member 2: `[Name / ID]` | **Additive no-trend Holt-Winters** | Level and additive seasonal components, justification for omitting trend, smoothing parameters, residual diagnosis, and forecast interpretation |
| Member 3: `[Name / ID]` | **ETS** | ETS error-trend-seasonal structure search, information criterion, estimated states/parameters, residual diagnosis, and forecast interpretation |
| Member 4: `[Name / ID]` | **Basic Structural Model (BSM)** | Local-level and seasonal state specification, variance estimation, diffuse initialisation, residual diagnosis, forecast interpretation, and boundary-estimate limitations |

The four models above are the complete set of official member-contributed models.

### 2.3 Chronological train-test ratio

Use an **80:20 chronological split** for every model.

| Partition | Observations | Dates | Percentage |
|---|---:|---|---:|
| Training set | First 240 months | January 2001 to December 2020 | 80% |
| Test set | Final 60 months | January 2021 to December 2025 | 20% |
| Total | 300 months | January 2001 to December 2025 | 100% |

#### Report-facing rationale

The reports will state that an 80:20 chronological split will be used, with January 2001-December 2020 reserved for training and January 2021-December 2025 reserved for testing. Chronological order is necessary because random splitting would allow future observations to influence model development or evaluation of earlier periods, creating future-data leakage. The reports do not need to compare alternative ratios or reproduce a stepwise split-selection argument. Split-sensitivity findings may be included only when they materially change confidence in the reported model comparison or conclusion.

**Report-ready explanation:**

> The series will be divided chronologically using an 80:20 split. Observations from January 2001 to December 2020 will be used for model development, while January 2021 to December 2025 will be retained for out-of-sample evaluation. A chronological rather than random split will preserve temporal order and prevent future observations from leaking into model estimation.

#### Operational rules for the selected split

- Do **not** randomly shuffle the observations.
- All four members must use the same training dates, test dates, forecast horizon, actual values, and metric formulas.
- Fit and tune each model using only the training set. The test set must not influence parameter selection.
- Produce a 60-month test forecast from each training-set model and compare it with the same 60 observed test values.
- Do not extrapolate beyond December 2025 for this assignment. Its purpose is to evaluate accuracy by comparing the 60 test forecasts with known actual values.
- Report split-sensitivity evidence only if it materially affects confidence in the selected model or conclusion.

## 3. Common Analysis Workflow for All Four Models

The workflow below follows the supplied model-selection diagram. The same decision sequence must be visible in the group report and followed in each individual analysis, but model-specific details must be used where ARIMA-specific steps do not apply.

### Decision-explanation standard for all reports

Every important analytical decision must be explained through the following six-part sequence:

1. **State the decision question.** Example: "Does the training series require a variance-stabilizing transformation?"
2. **List the reasonable alternatives.** Example: no transformation, logarithm, or an estimated Box-Cox transformation.
3. **Present the evidence used.** Example: original time plot, calendar-month distribution, variance-by-level pattern, Box-Cox lambda estimate, ACF/PACF, AICc, residual plot, or test result.
4. **State the decision criterion.** Example: choose the simplest option that stabilizes variance without harming interpretability, or choose the candidate with lower training AICc subject to acceptable residual diagnostics.
5. **State and justify the selected option.** Give the exact model, parameter, split, transformation, or diagnostic setting and connect it directly to the evidence.
6. **Explain the consequence and limitation.** State how the decision affects estimation, forecasts, interpretation, comparability, or uncertainty, and acknowledge any remaining weakness.

### Parameter-justification and non-default modification standard

No report may present a model specification, tuning setting, or software default as self-justifying. For every structural choice or modification—including transformation, differencing, AR/MA order, seasonal period, trend inclusion or removal, damping, additive or multiplicative form, candidate-search restriction, reference category, diagnostic lag, forecast horizon, and any argument changed from its software default—the report must:

1. identify the parameter or setting and whether it was fixed, searched, or estimated;
2. state the reasonable alternatives considered;
3. cite relevant training-only evidence, such as the original time plot, calendar-month distribution, seasonal-amplitude pattern, transformation or stationarity diagnostics, ACF/PACF, candidate AICc, parameter uncertainty, rolling-origin validation, convergence, or residual diagnostics;
4. state the decision criterion and explain why the retained value or form satisfied it;
5. explain the modelling consequence and disclose any important limitation or sensitivity; and
6. name any retained software default and justify why it was appropriate instead of relying on the fact that it was the default.

Distinguish **selected settings** from **fitted parameters**. Orders, component forms, restrictions, and search options are selected analytical settings and require the evidence chain above. Numerical parameters such as AR/MA terms, smoothing coefficients, and structural disturbance variances are normally estimated jointly from the training data by likelihood or optimisation; they must not be described as if the analyst manually selected each value. For fitted parameters, state the estimation method or objective, report estimates and uncertainty where available, interpret their practical meaning, and flag boundary values, weakly supported terms, or instability. Do not invent post-hoc reasons for optimizer-produced values.

If a required specification is imposed by the assignment rather than chosen empirically, state that constraint explicitly, provide the substantive rationale that still applies, and use diagnostics or validation to evaluate its consequences. Test-period accuracy must not be used retrospectively to justify a parameter or modification that was supposed to be locked using training data.

### Numerical presentation standard for all reports

Always include a leading zero when reporting a decimal value whose absolute value is less than one. This rule applies consistently to prose, equations, tables, figure annotations, coefficients, standard errors, accuracy measures, probabilities, p-values, and threshold comparisons in both the group report and all four individual reports. Correct forms include `0.5358`, `−0.4147`, `$p=0.148$`, and `$p<0.001$`; never drop the zero immediately before the decimal point. Apply the same convention in the Markdown sources and in every generated submission document.

Apply this sequence to:

- Dataset inclusion and cleaning decisions.
- Chronological train-test split.
- Seasonal frequency.
- Transformation choice.
- Trend and seasonality representation.
- SARIMA differencing and orders.
- Holt-Winters component and smoothing choices.
- ETS structure and search restrictions.
- Basic Structural Model level, slope, seasonal, and irregular-component choices.
- Residual-test lag and degrees of freedom.
- Accuracy measures and primary ranking metric.
- Final overall model selection.
- Test-forecast horizon and its alignment with the 60 known holdout observations.

Avoid unsupported statements such as "80:20 was used because it is standard," "the model was selected automatically," or "the residuals are good." Each statement must be followed by the evidence, criterion, and interpretation that produced it.

### Step 1 - Plot and understand the data

Required checks and outputs:

- Plot the complete monthly time series.
- Plot or summarize the training and test periods with the split date marked.
- Identify unusual observations, missing values, duplicate dates, discontinuities, possible level changes, trend, and annual seasonality.
- Produce a calendar-month seasonal plot or monthly boxplot.
- Use the original time-series plot and calendar-month distribution as the main common views. The group report may include one concise STL/decomposition result or figure when it adds analytical value.
- Report descriptive statistics: count, mean, standard deviation, minimum, maximum, median, and calendar-month means.
- Confirm that the seasonal frequency is 12.
- Explain whether any unusual values are genuine observations or data errors. Do not remove observations only because they look extreme.

### Step 2 - Stabilize variance if necessary

- Inspect whether seasonal variation or residual spread increases with the series level.
- Consider a Box-Cox transformation only if the plot and training data show non-constant variance.
- Estimate or justify lambda using the training set only.
- Compare transformed and untransformed diagnostics.
- Record the chosen lambda. If no transformation is used, explicitly state why it was unnecessary.
- If forecasts are back-transformed, state whether bias adjustment is used.
- Confirm that final forecasts remain physically plausible and non-negative.

### Step 3 - Address non-stationarity or structural components

This step must be adapted by model:

- **SARIMA:** use stationarity tests such as KPSS or ADF together with plots; determine non-seasonal differencing `d` and seasonal differencing `D`; avoid over-differencing.
- **Additive no-trend Holt-Winters:** do not difference automatically. Represent the series through recursively updated level and additive seasonal components, and use training-only evidence to justify the fixed additive, no-trend form.
- **ETS:** do not difference automatically. Allow the ETS structure to represent level, trend, damping, and seasonality; restrict the search only when supported by the data or physical reasoning.
- **Basic Structural Model:** represent gradual movement through a stochastic local level and recurring annual movement through a 12-month seasonal state. Include a slope only if training-only evidence supports persistent trend extrapolation; inspect estimated disturbance variances and residual correlation.

### Step 4 - Identify reasonable candidate specifications

#### SARIMA candidates

- Plot ACF and PACF after the chosen transformation/differencing.
- Use the ACF/PACF and seasonal lags 12, 24, and so on to propose candidate `(p,d,q)(P,D,Q)[12]` models.
- Either select orders manually or use `auto.arima()`.
- If using `auto.arima()`, record all important settings, including `seasonal`, `stepwise`, `approximation`, information criterion, drift/mean allowance, and search limits.
- Compare the automatic model with a small number of nearby, interpretable manual candidates where feasible.

#### Additive no-trend Holt-Winters specification

- Treat additive seasonality and omission of trend as the assigned specification; assess their suitability using training-only seasonal-amplitude and trend evidence.
- Use multiplicative or trend-bearing variants only as documented training-only sensitivity checks when they materially affect confidence; they do not replace the assigned model in the four-model comparison.
- Allow alpha and gamma to be optimized on training data; keep `beta = FALSE` because the assigned model has no trend component.
- Record initialization choices and convergence warnings.
- Do not combine results generated before and after fixing `beta = FALSE`.

#### ETS candidates

- Begin with the automatic ETS search, such as `ets(..., model = "ZZZ")`.
- Record the selected error, trend, and seasonal components, for example `ETS(M,N,A)`.
- Record whether the trend is damped and report alpha, beta, gamma, and phi when present.
- Record the information criterion used, normally AICc, and any restrictions such as additive-only models.
- Consider a small set of scientifically plausible alternatives if the automatic model leaves autocorrelation or produces implausible forecasts.

#### Basic Structural Model candidates

- Begin with a local-level model containing a 12-month seasonal state and irregular error.
- Compare a local-linear-trend alternative only when the training plot and training-only validation support a persistent slope.
- Estimate the level, seasonal, slope when applicable, and irregular disturbance variances by maximum likelihood; do not choose their numerical values manually.
- Record the initialisation method, convergence status, estimated variances, and any parameter at or near a boundary.
- Prefer the simplest stable structure that preserves annual seasonality, passes residual checks, and avoids unsupported long-horizon trend extrapolation.

### Step 5 - Fit candidates and choose a model within each family

- Fit all candidate specifications to the 240-month training set.
- Use AICc or another suitable information criterion to compare specifications **within the same model family** where applicable.
- Do not use AIC/AICc to rank SARIMA directly against Holt-Winters, ETS, or the Basic Structural Model when their likelihoods and response treatments are not comparable.
- Keep the candidate set small, interpretable, and documented.
- Record the final specification, estimated parameters, software function, package version, warnings, and convergence status.
- Do not choose the model using the 60-month test RMSE at this stage.

### Step 6 - Diagnose residuals and loop back if necessary

For every final training-set model:

- Plot residuals over time.
- Plot the residual ACF; include PACF when useful.
- Inspect a residual histogram or Q-Q plot for serious non-normality or outliers.
- Apply a portmanteau test such as the Ljung-Box test at a justified lag, with fitted-model degrees of freedom handled correctly.
- State the null hypothesis and interpret the p-value.
- Check whether residuals are approximately zero-mean, have stable variance, and show no important remaining autocorrelation.
- Check forecast plausibility and prediction intervals.

Decision rule:

- If residuals resemble white noise and the model is stable and plausible, proceed to forecasting.
- If residuals are not approximately white noise, return to the transformation, component, differencing, order, or parameter-selection steps and fit a better candidate.
- If no candidate fully removes the issue, retain the most defensible model but disclose the remaining diagnostic limitation.

### Step 7 - Forecast and evaluate

- Generate 60 monthly point forecasts for January 2021 to December 2025.
- Include 80% and 95% prediction intervals where the model supports them.
- Calculate the same test measures for all four models: **ME, MSE, RMSE, MAE, MPE, and MAPE**. Use `actual − forecast` throughout; ME and MPE are best when closest to zero, whereas MSE, RMSE, MAE, and MAPE are best when lowest.
- For each individual report, calculate the same six measures from response-scale training residuals and from the locked test forecasts, then report **test minus training** for every measure. Express MPE and MAPE differences in percentage points and treat the comparison as descriptive because fitted residuals and multi-step holdout errors use different evaluation designs.
- Use **test RMSE as the primary ranking measure** and **test MAE as the secondary measure**.
- Also consider residual validity, interval behavior, stability, and physical plausibility. Do not select a numerically best model if it is diagnostically invalid or produces implausible forecasts.
- Present one common comparison table and one common forecast-versus-actual figure.
- Stop forecasting at December 2025. Forecasts beyond the observed test range are outside this model-accuracy evaluation because no actual values are available for comparison.

## 4. Group Report Plan

### 4.1 Mandatory format

- **One report for the whole group.**
- **Template:** IEEE conference paper template.
- **References:** IEEE numbered citation and reference style.
- **Cover page:** all four names, student IDs, signatures, and contribution percentages.
- Keep the report concise, comparative, and integrated. Do not paste four individual reports together.

The required section order from the assignment brief is:

1. **Cover Page** - signatures and contribution percentage for every member.
2. **Introduction** - background, objectives, dataset, and the selected SDG number and title.
3. **Methodology** - dataset description, preprocessing, overall analytical workflow, forecasting methods, and forecast-evaluation criteria.
4. **Data Analysis** - combined results and discussion.
5. **Conclusion** - discussion, limitations, and recommendations where appropriate.
6. **References** - IEEE referencing style.

Use these six items as the report's controlling structure. An abstract and keywords are **not explicitly required by the assignment brief**. Include them only if the IEEE template being used requires them or the tutor confirms that they are expected; they must never replace or be merged into the cover page.

### 4.2 Group-report section details

#### Cover page

Include:

- University, faculty, course code, course name, semester, and session.
- Report title focused on the real-world forecasting problem.
- Dataset name and source.
- Team/group identifiers if required.
- Four member names and student IDs.
- Signature for each member.
- Contribution percentage for each member, totaling exactly 100%.
- Submission date.

The cover page must contain only the administrative and identification details listed above. **Do not include the abstract, keywords, research summary, model-selection explanation, results, or conclusions on the cover page.** Begin the Introduction on the following page; if an IEEE abstract and keywords are required, place them on that page immediately before the Introduction.

#### Optional IEEE abstract and keywords

This is **not one of the six sections explicitly required by the assignment brief**. Include it only when required by the IEEE template being used or confirmed by the tutor. If included, place it after the cover page and before the Introduction, never within the cover-page section. Write it last and include:

- The problem and location.
- Dataset period and number of observations.
- The four compared models.
- The selected 80:20 chronological design, its training and test dates, and the brief reason temporal order is required.
- The final winning model and key regenerated test metric.
- A one-sentence practical/SDG implication.
- A careful limitation that irradiance is not electricity output.

Do not keep the current SARIMA result in the abstract unless SARIMA remains the winner after the complete 80:20 rerun.

#### Introduction

Include:

- Background on monthly solar-resource variability and why it matters.
- A clearly formulated forecasting problem.
- Two to four measurable objectives.
- Reliable NASA POWER dataset source and why 300 monthly observations are sufficient.
- Exact variable, unit, location, and time range.
- SDG 7 number, title, relevant target, and a specific explanation of the link.

Suggested objectives:

1. Validate and describe the monthly NASA POWER solar-irradiance series.
2. Fit and diagnose SARIMA, additive no-trend Holt-Winters, ETS, and a Basic Structural Model.
3. Compare all four models on the common January 2021-December 2025 holdout created by the selected 80:20 chronological split, using ME, MSE, RMSE, MAE, MPE, and MAPE.
4. Interpret the selected forecast for preliminary solar-resource planning and SDG 7 while acknowledging data and engineering limitations.

#### Methodology

**Proposal-stage boundary:** write this section consistently in future-tense `will` or conditional `would` language, even though the analysis already exists. Methodology will explain the intended procedures, decision rules, and what readers should expect the research process to do; it will not narrate completed empirical outcomes. It may identify the dataset, fixed sampling period, intended split, model families, diagnostics, decision rules, and software procedures. It must not contain observed descriptive summaries, estimated Box-Cox values, selected orders or structures, fitted coefficients, AIC/AICc outcomes, diagnostic statistics or p-values, accuracy results, forecasts, rankings, or a winning model. Move every such empirical finding to **Data Analysis/Results**. In particular, describe how transformation need will be assessed without reporting an estimated lambda in Methodology.

Include:

- Dataset extraction and preprocessing steps.
- Treatment of `YYYY13` annual-summary records and NASA fill values such as `-999`.
- Checks for missing months, duplicates, missing values, and plausible range.
- Definition of the monthly time series with frequency 12.
- One concise statement of the selected 80:20 split, the January 2001-December 2020 training dates, the January 2021-December 2025 test dates, and why chronological rather than random splitting will prevent future-data leakage. Include sensitivity findings only if they materially affect confidence.
- A compact workflow based on the supplied seven-step diagram.
- One concise paragraph or compact table describing the four model families.
- Planned transformation assessment and training-only parameter-selection procedure, without reporting an estimated lambda or selected empirical outcome.
- Residual checks and white-noise loop.
- Common accuracy metrics and final selection rule.
- Software, R packages, and reproducibility details.

#### Data analysis and combined discussion

Include:

- One main data visualization showing trend/seasonality and the split.
- Optional: one concise common STL/decomposition result or figure when it adds value; it must not be presented as training-only specification evidence if it uses the test period.
- A concise descriptive summary of the series.
- One compact comparison table containing decision-relevant accuracy and Ljung-Box evidence; retain the complete ME, MSE, RMSE, MAE, MPE, and MAPE set in the reproducible evidence files.
- One common test forecast-versus-actual chart for all four models when it remains legible.
- Optional: one small residual-diagnostic panel for the selected model.
- Rank models based on regenerated 80:20 test results.
- Explain why the winning model may perform better in terms of trend, seasonality, and serial dependence.
- Discuss whether differences are practically meaningful rather than only stating the ranking.
- Note any model with non-white residuals, unstable estimates, overly wide intervals, or implausible values.
- Clearly separate training fit from performance on the 60 known test observations.

#### Group-level model selection and justification

The group report is responsible for selecting **which forecasting model family performs best on the common test period**. It is not responsible for explaining in detail how an individual SARIMA order such as `(p,d,q)(P,D,Q)[12]` was obtained. ARIMA/SARIMA order identification, including differencing and ACF/PACF interpretation, belongs in the SARIMA member's individual report. The group report may state the final fitted order in its comparison table, but it should focus on the fair comparison of the four model families and the reason for selecting the overall winner.

The overall winner must not be chosen in advance. The Methodology section should first identify the planned candidates and lock the selection rule before the January 2021-December 2025 test observations are used:

| Planned model | Reason for including it in the group comparison |
|---|---|
| **SARIMA** | Represents autocorrelation at ordinary and annual seasonal lags, which may remain after trend and seasonality are addressed. |
| **Additive no-trend Holt-Winters** | Provides a transparent smoothing approach for an evolving level and recurring additive monthly seasonal pattern without extrapolating a trend. |
| **ETS** | Provides a state-space framework that compares error, trend, damping, and seasonal structures and produces prediction intervals. |
| **Basic Structural Model** | Represents the series as a stochastic local level, a 12-month seasonal state, and irregular error without forcing one straight trend through the full record. |

Each member must determine and lock the specification of the assigned model using the January 2001-December 2020 training data only. After the four specifications are locked, every model must forecast the same 60 test observations from January 2021 to December 2025. Select the final forecasting model using the following hierarchy:

1. Treat diagnostic validity and physical plausibility as eligibility conditions. Flag a model if its residuals retain material autocorrelation, its estimates are unstable, or its forecasts or intervals contain implausible solar-irradiance values.
2. Among acceptable models, use **test RMSE as the primary ranking measure** because it penalizes larger forecast errors more heavily.
3. Use **test MAE as the secondary measure** because it expresses the typical absolute forecast error in the original unit and is less sensitive to a few large errors.
4. Use ME and MPE to assess signed bias by closeness to zero, and use MSE and MAPE as supporting measures rather than allowing one measure to override the declared RMSE/MAE rule without justification. Because MSE and RMSE induce the same ranking, do not count them as independent votes in a composite score.
5. Compare prediction-interval behavior, stability, interpretability, and the size of the improvement over the next-best model. Discuss whether the difference is practically meaningful rather than only reporting ranks.
6. Do not select a numerically first-ranked model if its diagnostics or forecasts are unacceptable. If the lowest-RMSE model fails an eligibility condition, select the next defensible model and state the reason transparently.
7. End the analysis after selecting and interpreting the best admissible model on the 60-month test period. Do not refit for or report an unevaluable forecast beyond December 2025.

AIC or AICc may be used by an individual member to select specifications **within** a model family when the likelihoods and response treatments are comparable. Do not use AIC/AICc to rank SARIMA directly against Holt-Winters, ETS, or the Basic Structural Model. The common out-of-sample test errors provide the group-level comparison.

**Report-ready Methodology wording:**

> SARIMA, additive no-trend Holt-Winters, ETS, and a Basic Structural Model will be evaluated as complementary approaches to a monthly series with annual seasonality. SARIMA will represent dependence at ordinary and seasonal lags; Holt-Winters will represent recursively updated level and seasonal components; ETS will search error, trend, damping, and seasonal state-space structures; and the Basic Structural Model will represent a stochastic local level, 12-month seasonal state, and irregular error without a slope component. Each specification will be determined from the training period only and then locked before the common test period is evaluated. The final model will be selected primarily by test RMSE and secondarily by test MAE, subject to acceptable residual white-noise diagnostics, stable estimates, reasonable prediction intervals, and physically plausible forecasts. Empirical selections, estimates, diagnostic outcomes, and accuracy values will be reported in Data Analysis rather than Methodology.

**Current report-ready Data Analysis wording from the regenerated 80:20 results:**

> SARIMA was selected as the final forecasting model because it achieved the lowest test RMSE of 0.2850 and a test MAE of 0.2198 on the common January 2021-December 2025 evaluation period. Its lag-24 Ljung-Box p-value was 0.1046, and its test forecasts remained non-negative. Its RMSE was 0.0097 kWh/m2/day (3.30%) below ETS and 0.0101 kWh/m2/day (3.42%) below the Basic Structural Model, so the improvement was useful but remained sample-specific. SARIMA was preferred for the present sample because it provided the strongest admissible combination of accuracy, residual validity, and physical plausibility; this does not establish universal superiority.

Do not duplicate this full comparison in every individual report. Each individual report should instead justify why its assigned model was reasonable to test, explain how its own specification was selected from training data, and evaluate whether the evidence supports that model's suitability.

#### Conclusion, critical discussion, limitations, and recommendations

Include:

- A direct answer to the research objective and the selected overall model.
- Key regenerated accuracy evidence.
- What the result suggests about the series' trend, seasonal structure, and dependence.
- Explicit connection back to SDG 7 and its practical significance.
- Dataset limitations: gridded/satellite product, spatial resolution, monthly averaging, possible source changes, and lack of local ground-station validation.
- Forecast limitations: five-year or 60-month test horizon, model uncertainty, structural change, and limits of extrapolation.
- Engineering limitation: solar irradiance does not directly equal solar-panel electricity generation.
- Recommendations: update models regularly, validate against local observations, use higher-frequency data for operational planning, consider weather predictors, and use intervals in decisions.

#### References

- Use IEEE numbered in-text citations such as `[1]`.
- Use reliable primary/official sources: NASA POWER documentation, United Nations SDG sources, official R/package documentation, and a recognized forecasting textbook or peer-reviewed source.
- Ensure every in-text citation has a reference-list entry and vice versa.
- Use consistent access dates where required for web sources.

## 5. Individual Report Plan Shared by All Four Members

### 5.1 Mandatory format

- **Four separate reports**, one per member.
- **Font:** Times New Roman, 12 pt.
- **References:** APA style.
- **Appendix:** programming source code for the member's model.
- Each report must clearly identify the member's own forecasting model and contribution.

### 5.2 Standard structure for every individual report

Every individual-report Markdown file must use the following five top-level sections in this exact order after the cover material:

1. `# Methodology`
2. `# Data Analysis (Results and Discussion)`
3. `# Conclusion`
4. `# References`
5. `# Appendix`

The Data Analysis (Results and Discussion) and Conclusion sections must remain separate. Model identification, fitted results, diagnostics, forecasts, accuracy measures, critical interpretation, strengths, and limitations belong in Data Analysis. The final suitability judgement, concise summary, limitations carried into the decision, and recommendation belong in Conclusion. References and Appendix must be explicit Markdown headings rather than styled text blocks. Keep the main content concise without prescribing how much material belongs in each section.

#### Cover page

Include:

- University/faculty/course details.
- Assignment and project title.
- Student name and ID.
- Group identifier.
- Assigned forecasting model.
- Dataset and submission date.

#### Methodology

Keep this proposal-stage section procedural and concise. It will use future-tense `will` or conditional `would` language even though the analysis already exists, because it explains intended procedures and reader expectations rather than completed outcomes. Dataset-design facts and prespecified rules are allowed, but all observed summaries, estimates, selected specifications, test statistics, fitted diagnostics, accuracy values, forecasts, and model rankings belong under Data Analysis (Results and Discussion).

Include:

- One-sentence problem and dataset context.
- Assigned model and a concise explanation of why it is a reasonable candidate for a monthly seasonal series; reserve the full four-model comparison and overall winner justification for the group report.
- Mathematical or conceptual model specification.
- One short shared-protocol statement that the 80:20 chronological split will use January 2001-December 2020 for training and January 2021-December 2025 for testing, and that temporal order will prevent future-data leakage. Do not repeat the group report's fuller split discussion; mention sensitivity only if it materially affects this model's interpretation.
- Planned transformation assessment, without an estimated Box-Cox value or empirical outcome.
- Model-specific specification and training-only selection procedure; report the selected specification and estimated parameters in Data Analysis.
- Parameter-justification procedure: identify which settings will be fixed, searched, or estimated; list meaningful alternatives; and state the training-only evidence and criterion used for every non-default modification. Retained software defaults must also be named and justified.
- Planned implementation, including the software function and only the important settings or arguments.
- Planned residual diagnostics and white-noise decision rule; report the diagnostic outcome in Data Analysis.
- Planned common evaluation measures and forecast procedure, without reporting results.

#### Individual-report evidence-ordering rule

This rule applies to the four **individual reports**, not to the group report's internal section order. Each individual report must distinguish the prespecified decision process from the empirical evidence and outcome:

1. **Methodology defines the decision rule in future tense.** State which training-only plots, diagnostics, candidate specifications, and formal criteria will be used. For example, specify that additive seasonality would be favoured when seasonal amplitude is approximately constant in response units, whereas multiplicative seasonality would be considered when amplitude changes proportionally with the series level. Do not state the observed pattern, selected form, fitted parameter values, or test outcome here.
2. **Data Analysis begins with model identification.** Before presenting the selected specification or parameter estimates, show or summarise the January 2001-December 2020 original time-series plot and calendar-month distribution and explain how they informed the assigned model. Use a compact training-only version of these plots where space permits.
3. **State the decision immediately after its evidence.** Link the observed training pattern and any formal criterion to the selected model form, then present fitted parameters, residual diagnostics, test forecasts, accuracy, and critical interpretation in Data Analysis. Place the final suitability judgement and recommendations in the separate Conclusion section.
4. **Do not use the test period for identification.** The complete-series plots may remain in the group report for retrospective description, but evidence used to lock an individual specification must exclude January 2021-December 2025.
5. **Assign STL ownership without duplication.** The group report may show one concise common STL/decomposition result or figure when it adds value. Individual reports should not repeat that full graph. Each individual report should mention only the training-only decomposition implication relevant to its assigned model and may include a compact training-only, model-specific extract only when it is necessary to support a specification decision. Whole-series or test-period decomposition must never be used to justify model specification.

**Technical warning about the current figures:** if `analysis_outputs/nasa/figures/nasa_decomposition_diagnostics.png` or the STL portion of `nasa_training_identification.png` contains January 2021-December 2025, it may be used only as concise retrospective group-level description, not as evidence that determined a model specification. Any decomposition evidence used for individual model identification must be regenerated or verified as training-only.

The intended individual-report sequence is therefore:

> Methodology → Data Analysis (Results and Discussion: training-only evidence → selected specification and parameters → residual diagnostics → test forecast and accuracy → critical interpretation) → Conclusion → References → Appendix.

#### Data Analysis (Results and Discussion)

Include:

- A short opening model-identification paragraph based only on the training period, followed by the selected specification. The evidence must precede the specification it supports.
- A concise parameter-rationale paragraph or table linking each selected structural setting and non-default modification to its training-only evidence and decision criterion. Separately state how numerical coefficients were estimated and interpret the important estimates; do not imply that fitted coefficients were manually chosen.
- A compact training-only original time-series, calendar-month view, or model-specific identification extract when necessary. Do not repeat the full common STL graph from the group report.
- A compact actual-versus-forecast figure or a model-specific diagnostic figure.
- A small table containing training, test, and test-minus-training values for the model's ME, MSE, RMSE, MAE, MPE, and MAPE, followed by the Ljung-Box result.
- Interpretation of forecast pattern and intervals.
- Model-specific context only; do not rank the assigned model against the other group models or duplicate the group comparison.
- Summary of model strengths and weaknesses.
- Model-specific limitations.
- Critical interpretation of model-specific strengths, limitations, and possible improvements without duplicating the full group ranking.

#### Conclusion

- Directly state whether the assigned model is suitable for the research forecasting task.
- Give a concise evidence-based summary, the limitations that qualify the judgement, and the model-specific recommendation.
- Do not introduce new results or reproduce the group report's cross-model ranking.

#### References

- Use APA in-text citations and an APA reference list.
- Cite official model documentation and at least one authoritative forecasting source.
- Cite NASA POWER and the relevant dataset documentation.

#### Appendix - excluded where applicable

- Include only the member's relevant, reproducible source code.
- Show data input, split, model fitting, diagnostics, forecasting, and metric calculation.
- Do not paste unrelated code for all four models into every appendix.
- Add comments, package names/versions, and a random-seed statement if any stochastic procedure is introduced.

## 6. Model-Specific Individual Report Requirements

### 6.1 Individual Report 1 - SARIMA

#### Methodology must include

- Definition of `(p,d,q)(P,D,Q)[12]`.
- Planned use of plots to assess trend and seasonality; report the observed patterns in Data Analysis.
- Variance/transformation assessment procedure, without an estimated lambda or empirical outcome.
- Stationarity-assessment procedure using plots and a suitable unit-root test; report the outcome in Data Analysis.
- Procedure and criteria for choosing `d` and `D`; report the chosen values in Data Analysis.
- Planned ACF/PACF assessment at ordinary and seasonal lags; report its interpretation in Data Analysis.
- Manual candidate process or complete `auto.arima()` settings.
- Candidate-order search, AICc criterion, and drift/mean rules; report the selected order, coefficients, standard errors, and AICc in Data Analysis.
- Planned residual ACF and Ljung-Box test with appropriate fitted degrees of freedom.
- Prespecified loop-back rule if residual autocorrelation remains; report whether it was triggered in Data Analysis.

#### Data Analysis must include

- 60-month test forecast and accuracy metrics.
- Forecast intervals and any physically implausible values.
- Interpretation of seasonal differencing and AR/MA effects.
- Strength: captures serial dependence and seasonal lag structure.
- Limitations: order-search uncertainty, risk of over-differencing, long-horizon uncertainty, and sensitivity to structural change.
- Recommendation: consider nearby manual orders, rolling-origin validation, transformations, or regressors if justified.

### 6.2 Individual Report 2 - Additive No-Trend Holt-Winters

#### Methodology must include

- Explanation of the level and additive seasonal components and the deliberate absence of a trend component.
- Planned training-only assessment that will justify additive rather than multiplicative seasonality; report the evidence in Data Analysis.
- Planned training-only assessment that will justify omitting trend rather than including or damping it; report the evidence in Data Analysis.
- Parameters to be estimated (alpha and gamma) and the initialization method; state that `beta = FALSE` is fixed and report fitted values in Data Analysis.
- Planned interpretation of small or large smoothing values after estimation.
- Training-only optimization procedure.
- Planned residual ACF and Ljung-Box procedure; report the result in Data Analysis.
- Prespecified handling of any optimization or convergence warning; report encountered warnings in Data Analysis.

#### Data Analysis must include

- 60-month test forecast and accuracy metrics.
- Interpretation of how quickly level and seasonality adapt.
- Model-specific interpretation only; leave the full cross-model comparison and ranking to the group report.
- Strength: transparent seasonal smoothing and adaptability.
- Limitations: fixed additive seasonal form, inability to extrapolate a sustained trend, and sensitivity to the fixed component choices.
- Recommendation: use trend-bearing or alternative-seasonality variants only as sensitivity checks, or consider ETS when the assigned structure is too restrictive.

Current evidence alignment:

- The R script and stored specification now agree on `beta = FALSE` with fitted `alpha = 0.0273` and `gamma = 0.1366`. The corresponding metrics and diagnostics were retained in the revised source. Any future analytical rerun must regenerate the specification, parameters, metrics, diagnostics, figures, and forecasts together so they remain synchronized.

### 6.3 Individual Report 3 - ETS

#### Methodology must include

- Explanation of the ETS letters: error, trend, and seasonal components.
- Automatic search space and selection criterion, normally AICc.
- Candidate ETS structures and the selection rule; report the selected structure in Data Analysis only after the rerun.
- Rules for considering absent, present, or damped trend; report the selected trend form in Data Analysis.
- Parameters to be estimated (alpha, beta, gamma, and phi where applicable); report their fitted values in Data Analysis.
- Criteria for transformation and additive-only restrictions; report any applied restriction in Data Analysis.
- Explanation of how ETS differs from the classical Holt-Winters implementation.
- Planned residual ACF and Ljung-Box procedure; report the result in Data Analysis.

#### Data Analysis must include

- 60-month test forecast and common accuracy metrics.
- Interpretation of the selected error/trend/seasonal structure.
- Prediction-interval behavior.
- Strength: principled state-space model selection and probabilistic forecasting.
- Limitations: automatic choice can be difficult to explain, and multiplicative-error residuals require careful interpretation.
- Recommendation: compare automatic ETS with plausible constrained structures and persist the full final specification.

Important current-work correction:

- Use comparable response-scale forecast errors. Do not compare multiplicative ETS innovation residual errors directly with response residual errors from other models.

### 6.4 Individual Report 4 - Basic Structural Model (BSM)

The individual report must evaluate a structural state-space model that represents observed irradiance as a latent level, a 12-month seasonal component, and irregular error. The selected group specification omits a slope state, allowing gradual level movement without forcing a single straight line through the full series:

$$
y_t=\mu_t+\gamma_t+\varepsilon_t,\qquad
\mu_t=\mu_{t-1}+\eta_t,
$$

where $\mu_t$ is the stochastic local level, $\gamma_t$ is the seasonal state constrained over a 12-month cycle, and $\varepsilon_t$ and $\eta_t$ are irregular and level disturbances. The relevant disturbance variances are estimated by maximum likelihood rather than selected manually.

#### Required modelling procedure

1. Use the training-only original time-series plot and calendar-month distribution to describe long-run movement, shorter rises and falls, annual recurrence, and seasonal amplitude.
2. Treat a local-level-plus-seasonal model as the primary candidate. Consider a local-linear-trend alternative only as a documented training-only sensitivity check; do not add a slope merely because the series is not perfectly flat.
3. Fit the model to January 2001-December 2020 using exact diffuse initialisation and maximum likelihood, recording software version, convergence, AIC/BIC where applicable, and all estimated disturbance variances.
4. Exclude the diffuse-initialisation period from response-residual diagnostics. For the current 12-month seasonal model, exclude at least the first complete seasonal cycle and state the exact number removed.
5. Inspect the residual plot, residual ACF, and lag-24 Ljung-Box result using the fitted parameter count. Loop back if material autocorrelation remains.
6. Lock the structural specification before forecasting January 2021-December 2025. Use those 60 observations only for final evaluation.
7. Flag disturbance variances close to zero as boundary estimates. Explain that a near-zero seasonal variance means the initial seasonal pattern behaves approximately as fixed rather than materially evolving.

#### Methodology must include

- Observation and state equations, with definitions of the level, seasonal, slope if considered, and irregular components.
- Justification for the local-level specification and omission of a persistent slope using training-only evidence.
- Transformation assessment procedure, without an estimated lambda or empirical outcome.
- Maximum-likelihood estimation and exact diffuse initialisation.
- Candidate-comparison and convergence criteria.
- Planned handling of diffuse-start residuals and the lag-24 Ljung-Box test.
- Common 60-month forecast and accuracy-measure procedure.

#### Data Analysis must include

- The selected structural specification and estimated disturbance variances.
- Convergence result and any boundary estimates.
- 60-month test forecast and the common ME, MSE, RMSE, MAE, MPE, and MAPE measures.
- Current verified results: RMSE 0.2951, MAE 0.2370, MAPE 5.0141%, and lag-24 Ljung-Box `p=0.0670` after excluding the first 12 diffuse-initialisation months.
- Confirmation that all test forecasts were non-negative.
- Strength: gradual local-level adaptation, explicit seasonal state, coherent forecast uncertainty, and no forced global straight-line trend.
- Limitations: the residual result is close to the 5% threshold, the seasonal disturbance variance is effectively zero, and structural state estimates remain sensitive to specification and initialisation.
- Recommendation: compare local-level and local-linear-trend candidates using training-only evidence, conduct rolling-origin validation, and test whether a fixed seasonal component gives equivalent or more stable performance.

## 7. Common Tables, Figures, and Files to Produce

### 7.1 Shared group outputs

1. Data audit table.
2. Descriptive-statistics table.
3. Complete-series plot with train-test split.
4. Seasonal/monthly distribution plot.
5. Optional: one concise common STL/decomposition result or figure when it adds value.
6. One model-specification table for all four models.
7. One common 80:20 whole-season accuracy table.
8. One residual-diagnostics table with Ljung-Box results.
9. One common 60-month forecast-versus-actual figure when legible.

### 7.2 Individual outputs

Each member must produce:

- Concise training-only identification evidence and model-specific interpretation; mention only the relevant decomposition implication and include a compact STL extract only when necessary.
- Final model specification and parameter table.
- Model-specific residual plot and ACF.
- Ljung-Box result.
- Model-specific test forecast table.
- Model-specific test forecast-versus-actual figure.
- Accuracy row using the group's common metric function.
- Reproducible code appendix.

### 7.3 Reproducibility files

Maintain one shared folder containing:

- Raw downloaded NASA response.
- Clean monthly dataset.
- Shared preprocessing code.
- Shared split definition.
- One model script or clearly separated script section per member.
- Combined accuracy/diagnostic CSV files.
- Final figures used in reports.
- R `sessionInfo()` or package-version record.
- A data dictionary explaining date and irradiance fields.

## 8. Required Changes to the Current Work

Current status and required follow-up before final submission:

1. [x] **Use the selected 80:20 chronological split**: January 2001-December 2020 training and January 2021-December 2025 testing, preserving temporal order to prevent future-data leakage.
2. [x] **Update the group report to the four approved models**: SARIMA, additive no-trend Holt-Winters, ETS, and the Basic Structural Model.
3. [x] **Regenerate and validate the common group evidence.** SARIMA remains the selected model after the common test; its advantage over ETS and BSM is modest.
4. [x] **Keep common decomposition evidence concise.** The current group report omits STL; a future revision may add one concise common STL/decomposition result or figure if it adds value and fits, while individual reports must not duplicate it or use test-period decomposition for specification.
5. [ ] **Regenerate and visually inspect the IEEE group DOCX after the latest source revision.** The earlier render does not verify the current Markdown; generation remains pending explicit authorisation.
6. [x] **Replace the Individual Report 4 source and report index** with a Basic Structural Model report using Section 6.4. The legacy regression DOCX remains pending until generated-document replacement is explicitly authorised.
7. [x] **Remove or revise duplicated or leakage-prone STL evidence in individual reports**; retain only a brief model-relevant implication or a necessary compact training-only extract.
8. [ ] **Consolidate the reproducible analysis workflow.** The main R script still contains legacy trend-and-season regression sections; running it alone can restore inconsistent evidence. Integrate or explicitly sequence the Python BSM helper before treating the workflow as final.
9. [x] **Strengthen model-selection justification** inside each individual report without duplicating the group comparison.
10. [ ] **Verify individual report APA citations, figures, legibility, and visual layout** after every regenerated deliverable.
11. [ ] **Replace all administrative placeholders** for names, IDs, signatures, dates, group number, faculty/university, and contribution percentages.

## 9. Team Work Allocation Beyond the Four Models

To support fair peer evaluation, assign shared responsibilities in addition to the model work.

| Responsibility | Suggested owner | Required evidence |
|---|---|---|
| Data acquisition, cleaning, and audit | Member 1 with Member 4 review | Raw file, clean CSV, audit log |
| Common plotting and descriptive analysis | Member 4 with Member 2 review | Scripts and final figures |
| Shared metrics and result integration | Member 3 with Member 1 review | Common metric function and comparison CSV |
| IEEE group-report assembly and references | Member 2 with all-member review | IEEE source file/PDF and citation check |
| Final consistency and reproducibility audit | Group leader plus all members | Signed checklist and rerun confirmation |
| Presentation integration | All four members | One coherent deck and rehearsed transitions |

The cover-page percentages must reflect actual work. Keep a short contribution log with dates, tasks, outputs, and review actions.

## 10. Execution Schedule and Gates

### Phase 1 - Lock the design

- Confirm all four names/IDs and model assignments.
- Confirm the selected 80:20 split and its exact training and test dates, and document why chronological order prevents future-data leakage; record sensitivity findings only if material.
- Lock variable definition, unit, frequency, metrics, and the January 2021-December 2025 test horizon.
- Lock the additive no-trend Holt-Winters specification and its training-only justification procedure.

**Gate:** No member begins final writing until the shared design is documented.

### Phase 2 - Build the common data foundation

- Re-download or verify the raw NASA data.
- Run data-quality checks.
- Create the exact training and test objects.
- Produce the shared plots and descriptive statistics.

**Gate:** All members receive identical clean data and split objects.

### Phase 3 - Complete individual model workflows

- Each member follows Steps 1-7.
- Each member records candidates, final parameters, diagnostics, and limitations.
- Each member loops back if residuals are not white noise.
- Each member exports standardized predictions and metrics.

**Gate:** A model is not ready for comparison without a saved specification, diagnostics, 60 test forecasts, and metric row.

### Phase 4 - Integrate and select the overall model

- Merge all predictions by date.
- Recalculate metrics through one shared function.
- Produce the common comparison table and figure.
- Select the overall model using test RMSE, MAE, diagnostics, stability, intervals, and physical plausibility.
- Conclude from the common 60-month test comparison; do not add a forecast beyond the available actual observations.

**Gate:** All reported numbers must trace to regenerated CSV files.

### Phase 5 - Write reports

- Draft the group report in IEEE format.
- Draft four individual reports in Times New Roman 12 pt with APA references.
- Keep the group report comparative and the individual reports model-specific.
- Complete code appendices.
- Before changing any report, first add or update its proposed entry in the Section 1.2 report change log; after validation, complete that same entry with the applied result.

**Gate:** Every rubric criterion is explicitly addressed.

### Phase 6 - Quality assurance and submission

- Export all five reports to PDF.
- Check figure/table legibility, captions, citations, numbering, and grammar.
- Cross-check every number against regenerated output files.
- Complete the group-report assessment-summary Excel sheet.
- Complete AI Usage Disclosure forms individually.
- Complete Peer Evaluation forms individually and keep them confidential.
- Obtain signatures and verify contribution percentages total 100%.

**Gate:** Group leader submits only after all filenames and required attachments are verified.

## 11. Rubric-Based Final Checklists

### 11.1 Group report checklist

- [ ] Problem is clearly formulated.
- [ ] Objectives are measurable.
- [ ] Dataset is recent, reliable, relevant, and sufficiently long.
- [ ] Dataset source and suitability are justified.
- [ ] SDG 7 is strongly integrated, not merely mentioned.
- [ ] Preprocessing is complete and reproducible.
- [ ] The selected 80:20 chronological design, January 2001-December 2020 training period, January 2021-December 2025 test period, and future-leakage rationale are stated concisely; only material sensitivity findings are added.
- [ ] All four forecasting methods are correctly explained.
- [ ] Model assumptions and diagnostics are reported.
- [ ] All models use the same test dates and metrics.
- [ ] Analysis includes effective tables, figures, and statistical evidence.
- [ ] Any STL/decomposition evidence follows the ownership rule: at most one concise common result or figure, with no test-period evidence used to justify specification.
- [ ] Models are critically compared.
- [ ] Conclusion includes SDG implications, limitations, and evidence-based recommendations.
- [ ] IEEE conference template is followed consistently.
- [ ] IEEE citations and references are complete and accurate.
- [ ] Every decimal value with absolute value less than one includes a leading zero, including coefficients, errors, p-values, and thresholds.
- [ ] Cover page contains four names, IDs, signatures, and percentages totaling 100%.

### 11.2 Individual report checklist for each member

- [ ] Assigned model is clearly identified.
- [ ] Top-level sections appear in this exact order: Methodology, Data Analysis (Results and Discussion), Conclusion, References, Appendix.
- [ ] Methodology uses future-tense or conditional language and contains procedures and expectations rather than empirical outcomes.
- [ ] The shared split protocol is acknowledged once, briefly, without repeating the group report's split discussion.
- [ ] Model specification, parameters, and implementation are technically correct.
- [ ] Model selection is justified using the supplied workflow.
- [ ] Training-only decisions are separated from test evaluation.
- [ ] Residual ACF and Ljung-Box results are interpreted.
- [ ] The white-noise loop is followed or remaining problems are disclosed.
- [ ] Test results use the common 80:20 dates and metrics.
- [ ] Data Analysis critically interprets the results rather than merely displaying them.
- [ ] Conclusion includes summary, model-specific limitations, and recommendations.
- [ ] APA writing, in-text citations, and references are consistent.
- [ ] Every decimal value with absolute value less than one includes a leading zero, including coefficients, errors, p-values, and thresholds.
- [ ] Cover page, references, and code appendix are present and separated.
- [ ] Appendix contains only relevant and reproducible code.

### 11.3 Presentation and peer-evaluation readiness

- [ ] Each member can explain the assigned model, parameters, diagnostics, and findings.
- [ ] Each member understands the whole project and why the final model was selected.
- [ ] Each member can explain why chronological splitting is required.
- [ ] Each member can answer questions about ME, MSE, RMSE, MAE, MPE, MAPE, AICc, and Ljung-Box testing.
- [ ] Presentation transitions are rehearsed and coherent.
- [ ] Work is completed on time and contribution evidence is retained.

## 12. Submission Package and Naming

The group leader must collect and submit:

1. One group-report PDF.
2. Four individual-report PDFs.
3. The completed `BMMS2094 Assignment Assessment` Excel summary sheet with the group report.

Use the assignment's required naming pattern, replacing placeholders with the actual tutorial/group and student information:

- Group report: `RDS2S1G3_Group5_GroupLeaderName.pdf`
- Group assessment sheet: `RDS2S1G3_Group5_GroupLeaderName.xlsx`
- Individual report 1: `RDS2S1G3_Group5_Member1Name.pdf`
- Individual report 2: `RDS2S1G3_Group5_Member2Name.pdf`
- Individual report 3: `RDS2S1G3_Group5_Member3Name.pdf`
- Individual report 4: `RDS2S1G3_Group5_Member4Name.pdf`

Each student must also submit individually through Google Classroom:

- AI Usage Disclosure Form.
- Peer Evaluation Form for Group Work.

Peer evaluations must remain confidential between each student and the tutor.

## 13. Definition of Done

The assignment is complete only when:

- One IEEE group report and four APA individual reports exist as final PDFs.
- The entire analysis has been regenerated with the selected 80:20 chronological split using January 2001-December 2020 for training and January 2021-December 2025 for testing.
- Every member has one distinct model contribution.
- The group report contains a fair common comparison of SARIMA, additive no-trend Holt-Winters, ETS, and the Basic Structural Model.
- Each individual report demonstrates deep technical understanding of its assigned model.
- Residual diagnostics and the white-noise decision loop are documented for all four models.
- All results, claims, tables, figures, and forecasts match reproducible output files.
- Formatting, citations, file names, forms, signatures, and submission attachments have all been checked.
