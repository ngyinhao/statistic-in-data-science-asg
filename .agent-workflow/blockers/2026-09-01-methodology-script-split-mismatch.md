# Methodology and R script use different train-test periods

## Context and intended action

The repository methodology was inspected to determine the required procedure for selecting a SARIMA specification and the final forecasting model.

## Observable symptom

- `BMMS2094_Group_and_Individual_Report_Plan.md` locks an 80:20 chronological split: January 2001-December 2020 for training and January 2021-December 2025 for testing (240/60 observations).
- `NASA_Solar_Irradiance_Forecasting.R` currently defines training through December 2023 and testing from January 2024 (276/24 observations).
- Existing exported accuracy and selected-model results therefore come from a different evaluation design than the report plan requires.

## Impact

The current exported winner, accuracy values, diagnostics, and 2026 refit cannot be presented as the final results of the locked 80:20 methodology. Doing so would make the report's stated method inconsistent with its evidence.

## Likely cause

The report plan was revised to an 80:20 whole-season split after the analysis script and outputs had been generated for a two-year holdout.

## Troubleshooting and evidence

- Inspected the methodology requirements and SARIMA-specific requirements in the report plan.
- Inspected the `train`, `test`, `auto.arima()`, accuracy-ranking, residual-diagnostic, and final-refit logic in the R script.
- Confirmed that the script ranks models using the 2024-2025 holdout and that its direct Ljung-Box call does not specify fitted-model degrees of freedom.

## Workaround / remaining limitation

Treat all existing model rankings as provisional planning evidence. Before writing final results, update the script to the locked 80:20 dates, correct residual degrees of freedom, rerun every model under identical conditions, and regenerate all tables and figures. R execution may also depend on resolving the separately documented `rscript-unavailable` blocker.

## Prevention

- Define the split dates once as named configuration values and reuse them in plots, summaries, fitting, and output labels.
- Add an assertion that the training and test lengths equal 240 and 60 and are divisible by 12.
- Export the split dates and final full-data model specification alongside accuracy results.
- Add a pre-report consistency check comparing documented dates with generated audit metadata.
