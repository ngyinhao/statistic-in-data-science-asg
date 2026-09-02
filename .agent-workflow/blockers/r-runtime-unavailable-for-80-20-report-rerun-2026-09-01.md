# R runtime unavailable for required 80:20 report rerun

## Context and intended action

While preparing the BMMS2094 group and individual report sources, the analysis needed to be regenerated with the plan's locked 80:20 chronological split (training: January 2001-December 2020; testing: January 2021-December 2025). The intended action was to run `NASA_Solar_Irradiance_Forecasting.R` and use its regenerated specifications, parameters, residual diagnostics, forecasts, and accuracy tables in the reports.

## Observable symptom

PowerShell's `Get-Command Rscript -ErrorAction SilentlyContinue` initially returned no executable. The current script also still defined its main fit with training through December 2023 and testing from January 2024, so its primary exported tables remained based on the old 92:8 design.

## Impact

The repository's split-sensitivity CSV contains common 80:20 accuracy metrics for all four models, but the primary specification and residual-diagnostic CSV files describe the old split. Exact 80:20 fitted parameters, corrected response residual diagnostics, model-specific forecast tables/figures, and a defensible final winner cannot be asserted from the current artifacts alone.

## Likely cause

Rscript was not available on the current process `PATH`. R was later found at the standard installation path `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`. The analysis script had also not yet been converted from the old primary split to the plan's locked 80:20 design.

## Troubleshooting performed

- Inspected `NASA_Solar_Irradiance_Forecasting.R` and confirmed the main split is still January 2001-December 2023 versus January 2024-December 2025.
- Inspected `analysis_outputs/nasa/nasa_split_sensitivity.csv` and confirmed that it contains 80:20 accuracy values.
- Inspected `nasa_model_specifications.csv` and `nasa_residual_diagnostics.csv` and confirmed that they reflect the old training period.
- Queried PowerShell for `Rscript`; no executable was initially resolved through `PATH`.
- Checked standard R installation directories and found R 4.6.1 under `C:\Program Files\R`.

## Workaround and remaining limitation

Use the discovered absolute Rscript path for the current run. The user added the correct R `bin` directory to the user `PATH`; newly started terminals and Codex processes should resolve `Rscript` after the Environment Variables dialogs are saved. The existing analysis script is being updated and rerun rather than replaced.

## Prevention and future workflow

1. Install R and ensure `Rscript` is on `PATH` before report generation.
2. Change the script's primary split to end training at December 2020 and begin testing at January 2021.
3. Export response-scale residuals consistently, corrected Ljung-Box degrees of freedom, complete model coefficients, convergence status, and each model's 60-month forecasts.
4. Persist the full-data refit specification used for any 2026 forecast.
5. Add a preflight check that refuses to build final reports unless the audit table reports 60 test observations and the expected split dates.
