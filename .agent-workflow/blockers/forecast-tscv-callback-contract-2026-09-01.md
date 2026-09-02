# forecast::tsCV callback must return a forecast object

## Context and intended action

The NASA analysis script was extended to export rolling-origin cross-validation evidence for the required `trend + season` regression at horizon 12.

## Observable symptom

The R rerun stopped with `Error in fc$mean : $ operator is invalid for atomic vectors` and a call stack ending in `tsCV`.

## Impact

The regenerated 80:20 analysis could not reach the report-output stage.

## Confirmed cause

The custom `tsCV` callback returned only the atomic forecast-mean vector. `forecast::tsCV()` expects the callback to return a forecast object and internally accesses its `$mean` component.

## Troubleshooting and result

The callback was changed from `forecast(..., h = h)$mean` to `forecast(..., h = h)`.

## Workaround

Return the complete forecast object from custom forecast functions passed to `forecast::tsCV()`.

## Prevention

When adding rolling-origin validation, verify callback contracts against the package API and run a minimal one-origin smoke test before the full analysis.
