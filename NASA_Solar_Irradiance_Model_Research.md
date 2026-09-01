# NASA Solar-Irradiance Forecasting Models: Explanation and Tuning Guide

> **Implementation update (2026-08-18):** The Holt–Winters model in the R script now sets `beta = FALSE`, so it has no trend component. The persisted model specifications, accuracy results, diagnostics, and forecasts described below were generated before this change and must be regenerated before they represent the updated model.

## Scope and interpretation

In this repository, “solar radiative” refers to the **NASA POWER monthly solar-irradiance forecasting analysis for Kuala Lumpur**, not to physical radiative-transfer models. The response variable is NASA POWER `ALLSKY_SFC_SW_DWN`: all-sky surface shortwave solar radiation, expressed here in kWh/m²/day. NASA describes all-sky global solar radiation on a horizontal surface as the sum of direct and diffuse radiation, estimated from satellite observations with radiative-transfer methods ([NASA POWER energy-flux methodology](https://power.larc.nasa.gov/docs/methodology/energy-fluxes/)). The repository requests monthly point data for 2001–2025 at latitude 3.1390 and longitude 101.6869; NASA states that its monthly API returns parameter values by year and month and that post-2000 solar parameters are derived primarily from CERES products ([NASA POWER Monthly API](https://power.larc.nasa.gov/docs/services/api/temporal/monthly/)).

The analysis contains exactly **five forecasting models**, defined together in [`NASA_Solar_Irradiance_Forecasting.R`](NASA_Solar_Irradiance_Forecasting.R#L69-L83):

1. Seasonal naïve
2. Trend plus season regression
3. Additive Holt–Winters
4. Automatic ETS
5. Automatic seasonal ARIMA (SARIMA)

The monthly series has seasonal period `m = 12`. Models are trained through December 2023 and evaluated on the January 2024–December 2025 holdout. The repository ranks them by holdout RMSE, uses that same holdout to select the winning model label, reruns that model class on all 300 observations, and forecasts 2026 ([source lines 64–66 and 163–165](NASA_Solar_Irradiance_Forecasting.R#L64-L66)). Consequently, this is a **selection holdout**, not an untouched final test set from which to claim unbiased future performance.

## Results currently recorded in the repository

| Model | Fitted specification | Holdout RMSE | Holdout MAE | Role |
|---|---:|---:|---:|---|
| SARIMA | ARIMA(1,0,0)(2,1,0)[12] on training data | 0.2013 | 0.1617 | Selected label |
| Holt–Winters | additive; α=0.0375, β=0.0030, γ=0.1231 | 0.2106 | 0.1681 | Strong alternative |
| ETS | ETS(M,N,A) | 0.2303 | 0.1932 | State-space exponential smoothing |
| Trend + season | `y ~ trend + season` | 0.2402 | 0.2009 | Interpretable regression |
| Seasonal naïve | repeat value from 12 months earlier | 0.2870 | 0.2324 | Benchmark |

Sources: repository-generated [`nasa_model_specifications.csv`](analysis_outputs/nasa/nasa_model_specifications.csv) and [`nasa_model_accuracy.csv`](analysis_outputs/nasa/nasa_model_accuracy.csv). Error units are kWh/m²/day. The current ranking is a fair **head-to-head comparison on the same dates** because every model forecasts the same holdout observations; the forecasting authors likewise note that test-set comparisons remain valid even when candidate models use different differencing structures ([Hyndman & Athanasopoulos, seasonal ARIMA](https://otexts.com/fpp2/seasonal-arima.html)). However, because the lowest holdout RMSE determines the winner, that same RMSE is optimistically biased as an estimate of the selected model’s performance on new unseen years.

## 1. Seasonal naïve

### How it works

For seasonal period `m = 12`, each future month is forecast from the latest observed value for the same calendar month:

$$
\hat y_{T+h\mid T}=y_{T+h-12(k+1)}, \qquad k=\left\lfloor\frac{h-1}{12}\right\rfloor.
$$

Thus the February forecast repeats the latest February, the March forecast repeats the latest March, and so on. This is the formal definition given by the authors of the `forecast` package ([simple forecasting methods](https://otexts.com/fpp2/simple-methods.html)). It preserves seasonality but learns no trend, changing seasonal amplitude, or multi-year dependence.

### Tuning

This model has **no learned smoothing or regression parameters**. Its meaningful settings are:

- **Seasonal period `m`**: here fixed correctly at 12 by `ts(..., frequency = 12)`. Changing it changes which past observation is copied.
- **Forecast horizon `h`**: 24 for holdout evaluation and 12 for the final forecast. It changes how far forecasts are produced, not the fitted rule.
- **Optional drift**: not part of `snaive()` and not used here. Adding drift would make this a different benchmark and should be justified by a stable long-run trend.

Use seasonal naïve as the minimum standard that a more complex seasonal model should beat. Its holdout MASE of 0.7745 is below 1 because the code scales against average in-sample seasonal-naïve error, while the evaluated seasonal-naïve holdout happens to be easier than the average training transition.

## 2. Trend plus season regression

### How it works

The repository fits `tslm(y ~ trend + season)`, equivalent to an ordinary linear model with:

$$
y_t=\beta_0+\beta_1t+\sum_{j=2}^{12}\delta_j I(\text{month}_t=j)+\varepsilon_t.
$$

`trend` is an automatically generated linear time index and `season` is an automatically generated factor based on the time-series frequency ([official `tslm` documentation](https://pkg.robjhyndman.com/forecast/reference/tslm.html)). One month is the reference level, so the model estimates an intercept, one linear slope, and eleven month effects. Seasonal differences are fixed in absolute units and the same linear trend is extrapolated into the future.

### Tuning

There are no conventional hyperparameters in the current formula; the coefficients are estimated by ordinary least squares. Tuning means choosing the model specification:

- **Trend form**: compare no trend, linear trend (current), quadratic/piecewise trend, or a damped/nonlinear alternative. Extrapolated polynomials can become unrealistic, so judge them on rolling-origin forecasts rather than training fit.
- **Season representation**: month dummies (current) make no smoothness assumption. Fourier terms can reduce parameters but introduce the tunable number of harmonics `K`.
- **Transformation `lambda`**: `tslm` supports a fixed Box–Cox λ or `lambda = "auto"`; `biasadj = TRUE` converts back-transformed medians to approximate means ([official `tslm` documentation](https://pkg.robjhyndman.com/forecast/reference/tslm.html)). The current model uses no transformation.
- **Predictors and interventions**: cloud cover, aerosol measures, ENSO indices, or regime/step indicators can be added only if their future values are known or separately forecast. Tune inclusion using time-series cross-validation, not the final holdout.
- **Residual correlation**: OLS month effects do not model serial correlation. If residual ACF remains, use regression with ARIMA errors rather than simply adding many lags.

The present model’s strength is interpretation; its weakness is assuming a globally linear trend and an unchanging monthly pattern.

## 3. Additive Holt–Winters

### How it works

Holt–Winters updates three latent components: level `ℓ_t`, trend `b_t`, and month-specific seasonality `s_t`. For additive seasonality:

$$
\hat y_{t+h\mid t}=\ell_t+h b_t+s_{t+h-12(k+1)}.
$$

The components are updated with smoothing parameters α (level), β (trend), and γ (seasonality). Additive seasonality is appropriate when seasonal swings are roughly constant in absolute units; multiplicative seasonality is appropriate when the swing grows in proportion to the series level ([Holt–Winters method and equations](https://otexts.com/fpp2/holt-winters.html)). R’s `stats::HoltWinters()` estimates unspecified parameters by minimizing squared one-step prediction error ([official R documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/HoltWinters.html)).

### Current fit and interpretation

The exported fit has α=0.0375, β=0.0030, and γ=0.1231. These are all small:

- α=0.0375 gives little weight to the newest seasonally adjusted observation, so the level changes slowly.
- β=0.0030 makes the slope nearly fixed over time.
- γ=0.1231 updates seasonal indices modestly; the recurring monthly pattern adapts, but slowly.

This stability is consistent with a climatological monthly series, though the very small trend update should be checked against structural-change diagnostics.

### Tuning

- **Seasonality type**: compare `seasonal = "additive"` (current) with multiplicative only if seasonal amplitude clearly scales with the level and all values are positive.
- **α, β, γ**: normally let R optimize them. Manual tuning is defensible only with rolling-origin validation. Values near 1 react quickly; values near 0 smooth heavily.
- **Initial states**: `l.start`, `b.start`, `s.start`, and `start.periods` affect initialization, especially for short series. The current defaults estimate initial values from early seasons.
- **Damping**: base `HoltWinters()` as used here extrapolates trend indefinitely. A damped Holt–Winters/ETS alternative adds φ, usually between 0 and 1, to flatten long-horizon trend; the forecasting text identifies damping as a robust seasonal option ([damped Holt–Winters](https://otexts.com/fpp2/holt-winters.html)).
- **Optimization controls**: `optim.start` and `optim.control` affect numerical search, not the statistical structure. Change them for convergence problems, not to chase holdout performance.
- **Transformation and intervals**: the `forecast()` method supports Box–Cox `lambda`, `biasadj`, interval levels, and horizon `h`; the package recommends `ets()` over the legacy `HoltWinters()` interface ([official forecast method](https://pkg.robjhyndman.com/forecast/reference/forecast.HoltWinters.html)).

## 4. Automatic ETS

### How it works

ETS is an innovations state-space framework whose three letters mean **Error, Trend, Seasonal**. Each candidate has an observation equation and state-update equations, enabling a complete predictive distribution rather than only point forecasts ([ETS state-space explanation](https://otexts.com/fpp2/ets.html)). The repository calls `ets(y)` with its automatic `ZZZ` search and obtains **ETS(M,N,A)**:

- `M`: multiplicative/relative innovations;
- `N`: no trend state;
- `A`: additive monthly seasonality.

The no-trend choice means forecasts repeat an estimated seasonal cycle around an evolving level. Multiplicative error means uncertainty is expressed relative to the forecast level, while the seasonal offsets themselves remain additive.

### Tuning

The default call already performs model and parameter tuning. Important controls are documented by the package authors ([official `ets()` reference](https://pkg.robjhyndman.com/forecast/reference/ets.html)):

- **`model`**: `"ZZZ"` (current) searches error/trend/seasonal structures; specify, for example, `"ANA"` only when theory requires it.
- **`damped`**: `NULL` (current) considers damped and undamped trends where a trend exists.
- **α, β, γ, φ**: `NULL` lets the optimizer estimate level, trend, seasonal, and damping parameters. Fixing them reduces the search but needs strong justification.
- **Selection criterion `ic`**: default AICc; alternatives are AIC and BIC. AICc is appropriate for finite samples and is the current implicit choice.
- **Optimization target `opt.crit`**: default likelihood; alternatives include MSE, multi-step AMSE, residual σ, and MAE. If the operational goal is 12-month accuracy, rolling-origin validation or `amse` with a relevant `nmse` may align tuning more directly with that horizon.
- **Parameter space**: default `bounds = "both"`, lower bounds near 0, upper bounds near 1, and φ bounds 0.8–0.98. `restrict = TRUE` excludes infinite-variance models.
- **Model space**: `additive.only`, `allow.multiplicative.trend`, and a Box–Cox `lambda` control which candidates are eligible. Supplying λ forces additive-only candidates in this implementation.
- **Transformation/back-transform**: as elsewhere, tune λ using training folds and use `biasadj = TRUE` when mean rather than median forecasts are required.

The exact fitted ETS smoothing coefficients were not exported to CSV, so they should not be guessed. Export `coef(models[["ETS"]]$fit)` in a reproducible rerun if those values are required.

## 5. Automatic SARIMA

### How it works

A seasonal ARIMA model combines non-seasonal AR, differencing, and MA orders `(p,d,q)` with seasonal orders `(P,D,Q)_m`. The seasonal polynomials act at multiples of `m` and multiply the non-seasonal polynomials ([seasonal ARIMA formulation](https://otexts.com/fpp2/seasonal-arima.html)). The selected **training-period** repository model is:

$$
\text{ARIMA}(1,0,0)(2,1,0)_{12}.
$$

Interpretation:

- `p=1`: one non-seasonal autoregressive lag;
- `d=0`: no ordinary first difference;
- `q=0`: no non-seasonal moving-average term;
- `P=2`: autoregressive dependence at seasonal lags 12 and 24;
- `D=1`: one seasonal difference, `y_t-y_{t-12}`, removes the repeating annual level;
- `Q=0`: no seasonal moving-average term;
- `m=12`: monthly seasonality.

The model therefore forecasts changes relative to the same month last year using recent and seasonal autocorrelation. The fitted AR coefficients themselves were not exported and must not be inferred from the order alone.

Crucially, `fit_models(series, 12L)` reruns `auto.arima()` after the SARIMA label wins. The resulting full-data order and coefficients are not written to `nasa_model_specifications.csv`. Therefore **ARIMA(1,0,0)(2,1,0)[12] cannot be asserted to be the exact model that generated the saved 2026 forecasts**; it is the persisted training-period winner. The full-data automatic search may choose the same or a different order.

### Current automatic search

The code uses `seasonal = TRUE`, `stepwise = FALSE`, `approximation = FALSE`, and `allowdrift = TRUE`. This is an exhaustive candidate search within the function’s order limits, scored with exact (not approximated) likelihood-based information criteria. The package authors explicitly recommend `stepwise = FALSE` and `approximation = FALSE` when analyzing one series and computation time permits ([official `auto.arima()` reference](https://pkg.robjhyndman.com/forecast/reference/auto.arima.html)). By default, the function selects `d` using a unit-root procedure, `D` using seasonal strength, and other orders by AICc.

### Tuning

- **Orders**: set or constrain `d`, `D`, `max.p`, `max.q`, `max.P`, `max.Q`, and `max.order`. Broader searches increase computation and overfitting risk; narrower searches encode domain knowledge.
- **Differencing tests**: `test` controls the non-seasonal unit-root test (default KPSS); `seasonal.test` controls seasonal differencing (default seasonal-strength method). Always inspect differenced plots and avoid unnecessary differencing.
- **Criterion `ic`**: default AICc; AIC and BIC are alternatives. Compare IC only among models fitted to the same transformed/differenced response basis; use rolling-origin errors for forecasting choice.
- **Mean/drift**: `allowmean` and `allowdrift` determine whether these terms are considered when mathematically permitted. Although `allowdrift = TRUE` is set, the selected `d=0, D=1` specification does not report a drift term.
- **Transformation λ and `biasadj`**: available as for ETS. Consider λ only if variance grows with level; validate on past-origin forecasts.
- **External regressors `xreg`**: useful for physically meaningful predictors, but future regressor paths are required and their uncertainty is otherwise omitted.
- **Search/computation**: `stepwise`, `nmodels`, `approximation`, `truncate`, `parallel`, and `num.cores` tune search cost. They should not alter the target definition; exact exhaustive search is already feasible for this 300-point monthly series.
- **Estimation method**: the default uses conditional sums of squares for starting values and maximum likelihood for the final fit. Change `method` only for missing-data or convergence reasons.
- **Diagnostics**: inspect residual ACF/PACF and Ljung–Box results, parameter significance, characteristic roots, and forecast plausibility. The repository’s SARIMA Ljung–Box p-value is 0.223, but its direct `Box.test()` call does not subtract fitted-model degrees of freedom, so that p-value should be treated as approximate.

## How tuning should be performed for this project

The present two-year holdout provides a useful model comparison, but because it is also used to choose the winner it is not an untouched final performance audit. A more defensible tuning workflow is:

1. On data through December 2023, use rolling-origin cross-validation with horizons that match the decision (especially `h=12`, optionally `h=1:24`) to choose structures and hyperparameters.
2. Lock every candidate and selection rule before evaluating January 2024–December 2025 once. If that period has already influenced tuning, reserve a later period or report the result explicitly as selection performance rather than unbiased test performance.
3. Define a small, scientifically plausible candidate grid for each model class.
4. Rank primarily by horizon-appropriate RMSE/MAE and MASE; use AICc only for choosing structures within a likelihood model, not across unrelated model classes.
5. Reject candidates with implausible solar forecasts, unstable parameters, or materially autocorrelated residuals.
6. Lock the tuning choice, evaluate once on the final holdout, then refit the chosen specification to all observations for the 2026 forecast.

Recommended candidate set:

| Model | Candidate settings to validate |
|---|---|
| Seasonal naïve | `m=12` baseline only |
| Trend + season | no trend vs linear trend; month dummies vs low-order Fourier terms; optional Box–Cox |
| Holt–Winters | additive vs multiplicative seasonality; damped vs undamped trend; optimized α/β/γ |
| ETS | automatic `ZZZ`; additive-only; fixed plausible structures; default likelihood vs horizon-aligned AMSE |
| SARIMA | current exhaustive auto search; nearby manually constrained orders; alternative differencing tests; optional Box–Cox |

Because irradiance is physically non-negative, any model/interval producing materially negative forecasts should be reconsidered or fitted on a positivity-preserving scale. Conversely, transformations should not be applied automatically: the observed level is stable and seasonal amplitude should first be checked against level before choosing multiplicative seasonality or a log transform.

## Important comparability and reproducibility notes

- **Do not compare the exported training MAE/RMSE across all five models as currently calculated.** `residuals()` defaults to innovation residuals; for ETS with multiplicative errors these differ from response residuals (`observed - fitted`). The official documentation explicitly identifies multiplicative-error ETS as a case where innovation and response residuals differ ([`residuals()` reference](https://pkg.robjhyndman.com/forecast/reference/residuals.forecast.html)). This explains why ETS training errors look unusually tiny. For comparable training errors, use `residuals(fit, type = "response")` for every model.
- Holdout MAE/RMSE are comparable because the code computes every holdout error directly as actual minus point forecast.
- Save `sessionInfo()` or a lockfile with the R and `forecast` package versions. Automatic-search results can change across versions.
- Export the complete fitted parameter sets, AIC/AICc/BIC, convergence status, and chosen transformations. The current specification CSV records model structure but not ETS or ARIMA coefficients.
- Persist the **full-data refit** specification after `full_models <- fit_models(series, 12L)`. At present, only training-period specifications are saved, so the precise ETS/SARIMA structure behind the final 2026 forecast cannot be audited from exported artifacts.
- For Ljung–Box tests on fitted models, pass an appropriate `fitdf` or use `forecast::checkresiduals()` so degrees of freedom are handled explicitly.

## Bottom line

SARIMA is the current selected label because it has the lowest 2024–2025 selection-holdout RMSE (0.2013), narrowly ahead of additive Holt–Winters (0.2106). This is evidence for a strong annual cycle plus serial dependence, not proof that SARIMA will always dominate, and the winning error is not an unbiased final-test estimate. The most useful next tuning improvement is rolling-origin validation within the pre-2024 period, followed by a locked one-time future-period comparison. The final report should retain seasonal naïve as the benchmark, keep the regression for interpretability, and compare a damped ETS/Holt–Winters candidate against the current exhaustive SARIMA search. It should also persist the final full-data model specification so the 2026 generator is reproducible.

## Primary sources

- Repository implementation: [`NASA_Solar_Irradiance_Forecasting.R`](NASA_Solar_Irradiance_Forecasting.R)
- Repository model specifications: [`nasa_model_specifications.csv`](analysis_outputs/nasa/nasa_model_specifications.csv)
- Repository holdout accuracy: [`nasa_model_accuracy.csv`](analysis_outputs/nasa/nasa_model_accuracy.csv)
- [NASA POWER Monthly API](https://power.larc.nasa.gov/docs/services/api/temporal/monthly/)
- [NASA POWER energy-flux methodology](https://power.larc.nasa.gov/docs/methodology/energy-fluxes/)
- [Official `forecast` package: `tslm()`](https://pkg.robjhyndman.com/forecast/reference/tslm.html)
- [Official R documentation: `HoltWinters()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/HoltWinters.html)
- [Official `forecast` package: `ets()`](https://pkg.robjhyndman.com/forecast/reference/ets.html)
- [Official `forecast` package: `auto.arima()`](https://pkg.robjhyndman.com/forecast/reference/auto.arima.html)
- [Hyndman & Athanasopoulos: seasonal naïve](https://otexts.com/fpp2/simple-methods.html)
- [Hyndman & Athanasopoulos: Holt–Winters](https://otexts.com/fpp2/holt-winters.html)
- [Hyndman & Athanasopoulos: ETS state-space models](https://otexts.com/fpp2/ets.html)
- [Hyndman & Athanasopoulos: seasonal ARIMA](https://otexts.com/fpp2/seasonal-arima.html)
