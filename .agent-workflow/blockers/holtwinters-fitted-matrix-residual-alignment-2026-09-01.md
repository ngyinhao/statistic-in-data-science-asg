# Holt-Winters fitted matrix caused residual misalignment

## Context and intended action

The existing NASA solar-irradiance R script was updated to calculate comparable response residuals for all four models before regenerating the locked 80:20 report evidence.

## Observable symptom

The first rerun emitted warnings that the objects used in `actual_values - fitted_values` and the subsequent finite-value mask had incompatible lengths. The run was stopped after the warning was reproducible.

## Impact

Training-error metrics and residual diagnostics could be recycled or otherwise calculated against misaligned vectors, invalidating the report evidence.

## Confirmed cause

`stats::fitted.HoltWinters()` returns a matrix. Its first column is the fitted response, while the remaining columns contain component states. Flattening the full matrix with `as.numeric()` incorrectly treated all columns as fitted responses.

## Troubleshooting and result

- Observed the length-mismatch warnings during the first 80:20 rerun.
- Reviewed the shared response-residual helper and the Holt-Winters fitted-object behavior.
- Updated the helper to select the first matrix column before numeric conversion.

## Workaround

When a fitted object is matrix-shaped, use its first column as the fitted response before subtracting it from the aligned tail of the observed training series.

## Prevention

Add an assertion in future revisions that every response-residual vector has a length no greater than its training series and that paired actual/fitted vectors have identical lengths before metrics are calculated.
