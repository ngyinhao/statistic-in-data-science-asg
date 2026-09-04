# NASA Solar-Irradiance Forecasting Models: Explanation and Tuning Guide

## Scope and interpretation

In this repository, “solar radiative” refers to the **NASA POWER monthly solar-irradiance forecasting analysis for Kuala Lumpur**, not to physical radiative-transfer models. The response variable is NASA POWER `ALLSKY_SFC_SW_DWN`: all-sky surface shortwave solar radiation, expressed here in kWh/m²/day. NASA describes all-sky global solar radiation on a horizontal surface as the sum of direct and diffuse radiation, estimated from satellite observations with radiative-transfer methods ([NASA POWER energy-flux methodology](https://power.larc.nasa.gov/docs/methodology/energy-fluxes/)). The repository requests monthly point data for 2001–2025 at latitude 3.1390 and longitude 101.6869; NASA states that its monthly API returns parameter values by year and month and that post-2000 solar parameters are derived primarily from CERES products ([NASA POWER Monthly API](https://power.larc.nasa.gov/docs/services/api/temporal/monthly/)).

The analysis contains exactly **four forecasting models**, defined together in [`NASA_Solar_Irradiance_Forecasting.R`](NASA_Solar_Irradiance_Forecasting.R#L69-L83):

1. Trend plus season regression
2. Additive Holt–Winters
3. Automatic ETS
4. Manually identified seasonal ARIMA (SARIMA)

The monthly series has seasonal period `m = 12`. Models are trained through December 2020 and evaluated only on the 60 known observations in the January 2021–December 2025 holdout. SARIMA order identification uses only the training sample, and its order is locked before this holdout is examined. No forecast is required beyond December 2025 because the project is assessing model accuracy against observed actual values.

## Results currently recorded in the repository

| Model | Fitted specification | Holdout RMSE | Holdout MAE | Role |
|---|---:|---:|---:|---|
| SARIMA | ARIMA(1,0,0)(0,1,1)[12] on training data | 0.2850 | 0.2198 | Manually selected and locked |
| Holt–Winters | additive without trend; α=0.0307, γ=0.1223 | 0.2109 | 0.1685 | Strong alternative |
| ETS | ETS(M,N,A) | 0.2303 | 0.1932 | State-space exponential smoothing |
| Trend + season | `y ~ trend + season` | 0.2402 | 0.2009 | Interpretable regression |

Sources: repository-generated [`nasa_model_specifications.csv`](analysis_outputs/nasa/nasa_model_specifications.csv) and [`nasa_model_accuracy.csv`](analysis_outputs/nasa/nasa_model_accuracy.csv). Error units are kWh/m²/day. The current ranking is a fair **head-to-head comparison on the same dates** because every model forecasts the same holdout observations; the forecasting authors likewise note that test-set comparisons remain valid even when candidate models use different differencing structures ([Hyndman & Athanasopoulos, seasonal ARIMA](https://otexts.com/fpp2/seasonal-arima.html)). However, because the lowest holdout RMSE determines the winner, that same RMSE is optimistically biased as an estimate of the selected model’s performance on new unseen years.

## 1. Trend plus season regression

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

## 2. Additive Holt–Winters

### How it works

The configured Holt–Winters model updates two latent components: level `ℓ_t` and month-specific seasonality `s_t`. With `beta = FALSE`, it excludes a trend component. For additive seasonality:

$$
\hat y_{t+h\mid t}=\ell_t+s_{t+h-12(k+1)}.
$$

The components are updated with smoothing parameters α (level) and γ (seasonality). Additive seasonality is appropriate when seasonal swings are roughly constant in absolute units; multiplicative seasonality is appropriate when the swing grows in proportion to the series level ([Holt–Winters method and equations](https://otexts.com/fpp2/holt-winters.html)). R’s `stats::HoltWinters()` estimates unspecified parameters by minimizing squared one-step prediction error ([official R documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/HoltWinters.html)).

### Current fit and interpretation

The regenerated fit has α=0.0307 and γ=0.1223. Both are small:

- α=0.0307 gives little weight to the newest seasonally adjusted observation, so the level changes slowly.
- γ=0.1223 updates seasonal indices modestly; the recurring monthly pattern adapts, but slowly.

This stability is consistent with a climatological monthly series. The no-trend specification should still be checked against structural-change diagnostics.

### Tuning

- **Seasonality type**: compare `seasonal = "additive"` (current) with multiplicative only if seasonal amplitude clearly scales with the level and all values are positive.
- **α and γ**: normally let R optimize them. Manual tuning is defensible only with rolling-origin validation. Values near 1 react quickly; values near 0 smooth heavily. Reintroducing β would change the candidate to a trend model.
- **Initial states**: `l.start`, `b.start`, `s.start`, and `start.periods` affect initialization, especially for short series. The current defaults estimate initial values from early seasons.
- **Damping**: base `HoltWinters()` as used here extrapolates trend indefinitely. A damped Holt–Winters/ETS alternative adds φ, usually between 0 and 1, to flatten long-horizon trend; the forecasting text identifies damping as a robust seasonal option ([damped Holt–Winters](https://otexts.com/fpp2/holt-winters.html)).
- **Optimization controls**: `optim.start` and `optim.control` affect numerical search, not the statistical structure. Change them for convergence problems, not to chase holdout performance.
- **Transformation and intervals**: the `forecast()` method supports Box–Cox `lambda`, `biasadj`, interval levels, and horizon `h`; the package recommends `ets()` over the legacy `HoltWinters()` interface ([official forecast method](https://pkg.robjhyndman.com/forecast/reference/forecast.HoltWinters.html)).

## 3. Automatic ETS

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

## 4. Manually identified SARIMA

### How it works

A seasonal ARIMA model combines non-seasonal AR, differencing, and MA orders `(p,d,q)` with seasonal orders `(P,D,Q)_m`. The seasonal polynomials act at multiples of `m` and multiply the non-seasonal polynomials ([seasonal ARIMA formulation](https://otexts.com/fpp2/seasonal-arima.html)). The selected **training-period** repository model is:

$$
\text{ARIMA}(1,0,0)(0,1,1)_{12}.
$$

Interpretation:

- `p=1`: one non-seasonal autoregressive lag, proposed by the lag-1 ACF/PACF pattern;
- `d=0`: no ordinary first difference;
- `q=0`: no non-seasonal moving-average term;
- `P=0`: added seasonal AR terms did not improve AICc enough to justify their complexity;
- `D=1`: one seasonal difference, `y_t-y_{t-12}`, removes the repeating annual level;
- `Q=1`: one seasonal moving-average term, proposed by the seasonal ACF cut-off;
- `m=12`: monthly seasonality.

The model forecasts changes relative to the same month last year using recent autoregressive dependence and annual-lag error correction. On the training sample, AR1 was 0.2087 and SMA1 was -0.9554; both were estimated by likelihood after the order was chosen.

The order is locked before holdout evaluation. The training fit is then used to produce the 60 January 2021--December 2025 forecasts that are compared with observed actual values.

### Current manual identification

The code does not call `auto.arima()`. It fixes $m=12$ from the monthly sampling frequency; assesses transformation from the training plot, annual mean--standard-deviation relationship, and Guerrero estimate; sets $D=1$ from persistent annual ACF and seasonal-strength evidence; sets $d=0$ from the stable seasonally differenced series and KPSS evidence; and fixes $Q=1$ from the seasonal ACF cut-off. Because the ordinary lag-1 ACF and PACF are both significant but do not uniquely distinguish AR from MA structure, the restricted diagnostic-guided search tests $p,q\in\{0,1,2\}$. The seasonal PACF evidence similarly motivates $P\in\{0,1,2\}$. Their Cartesian product gives exactly 27 unique models, covering absent, first-order, and nearby second-order components without claiming to search every possible SARIMA order. Each candidate is fitted explicitly with `forecast::Arima()` on the same response basis and ranked by training AICc, subject to convergence, a lag-24 Ljung--Box residual gate, and non-negative 60-step candidate forecasts. Holdout actual values do not enter this order selection. ARIMA(1,0,0)(0,1,1)[12] had the lowest eligible AICc (102.2697) and passed the residual gate ($p=0.1046$).

### Tuning

- **Orders**: set or constrain `d`, `D`, `max.p`, `max.q`, `max.P`, `max.Q`, and `max.order`. Broader searches increase computation and overfitting risk; narrower searches encode domain knowledge.
- **Differencing tests**: `test` controls the non-seasonal unit-root test (default KPSS); `seasonal.test` controls seasonal differencing (default seasonal-strength method). Always inspect differenced plots and avoid unnecessary differencing.
- **Criterion `ic`**: default AICc; AIC and BIC are alternatives. Compare IC only among models fitted to the same transformed/differenced response basis; use rolling-origin errors for forecasting choice.
- **Mean/drift**: `allowmean` and `allowdrift` determine whether these terms are considered when mathematically permitted. Although `allowdrift = TRUE` is set, the selected `d=0, D=1` specification does not report a drift term.
- **Transformation λ and `biasadj`**: available as for ETS. Consider λ only if variance grows with level; validate on past-origin forecasts.
- **External regressors `xreg`**: useful for physically meaningful predictors, but future regressor paths are required and their uncertainty is otherwise omitted.
- **Search/computation**: `stepwise`, `nmodels`, `approximation`, `truncate`, `parallel`, and `num.cores` tune automated-search cost. The present implementation instead evaluates every model within its declared 27-candidate bounded grid; it is exhaustive within that grid, not across all possible SARIMA orders.
- **Estimation method**: the default uses conditional sums of squares for starting values and maximum likelihood for the final fit. Change `method` only for missing-data or convergence reasons.
- **Diagnostics**: inspect residual ACF/PACF and Ljung–Box results, parameter significance, characteristic roots, and forecast plausibility. The selected SARIMA's lag-24 Ljung–Box test uses two fitted-model degrees of freedom and gives $p=0.1046$.

## How tuning should be performed for this project

The present five-year holdout provides a useful model comparison, but because it is also used to choose the winner it is not an untouched final performance audit. A more defensible tuning workflow is:

1. On data through December 2023, use rolling-origin cross-validation with horizons that match the decision (especially `h=12`, optionally `h=1:24`) to choose structures and hyperparameters.
2. Lock every candidate and selection rule before evaluating January 2024–December 2025 once. If that period has already influenced tuning, reserve a later period or report the result explicitly as selection performance rather than unbiased test performance.
3. Define a small, scientifically plausible candidate grid for each model class.
4. Report ME, MSE, RMSE, MAE, MPE, and MAPE on the common horizon. Rank primarily by horizon-appropriate RMSE/MAE, use ME/MPE to diagnose signed bias, and use AICc only for choosing structures within a likelihood model, not across unrelated model classes.
5. Reject candidates with implausible solar forecasts, unstable parameters, or materially autocorrelated residuals.
6. Lock the tuning choice and evaluate once on the final holdout. Stop at December 2025 so that every reported forecast can be compared with an actual observation.

Recommended candidate set:

| Model | Candidate settings to validate |
|---|---|
| Trend + season | no trend vs linear trend; month dummies vs low-order Fourier terms; optional Box–Cox |
| Holt–Winters | additive vs multiplicative seasonality; damped vs undamped trend; optimized α/β/γ |
| ETS | automatic `ZZZ`; additive-only; fixed plausible structures; default likelihood vs horizon-aligned AMSE |
| SARIMA | manual ACF/PACF candidate set; alternative differencing and Box--Cox decisions; rolling-origin sensitivity |

Because irradiance is physically non-negative, any model/interval producing materially negative forecasts should be reconsidered or fitted on a positivity-preserving scale. Conversely, transformations should not be applied automatically: the observed level is stable and seasonal amplitude should first be checked against level before choosing multiplicative seasonality or a log transform.

## Important comparability and reproducibility notes

- **Do not compare the exported training MAE/RMSE across all four models as currently calculated.** `residuals()` defaults to innovation residuals; for ETS with multiplicative errors these differ from response residuals (`observed - fitted`). The official documentation explicitly identifies multiplicative-error ETS as a case where innovation and response residuals differ ([`residuals()` reference](https://pkg.robjhyndman.com/forecast/reference/residuals.forecast.html)). This explains why ETS training errors look unusually tiny. For comparable training errors, use `residuals(fit, type = "response")` for every model.
- Holdout MAE/RMSE are comparable because the code computes every holdout error directly as actual minus point forecast.
- Save `sessionInfo()` or a lockfile with the R and `forecast` package versions. Automatic-search results can change across versions.
- Export the complete fitted parameter sets, AIC/AICc/BIC, convergence status, and chosen transformations. The current specification CSV records model structure but not ETS or ARIMA coefficients.
- Persist the locked **training specification**, its 60 holdout forecasts, and the matching actual values so the accuracy calculation remains reproducible.
- For Ljung–Box tests on fitted models, pass an appropriate `fitdf` or use `forecast::checkresiduals()` so degrees of freedom are handled explicitly.

## Bottom line

The training-only Box--Jenkins process selected ARIMA(1,0,0)(0,1,1)[12] by AICc and residual diagnostics. On the fixed January 2021--December 2025 test period, it achieved RMSE 0.2850 and MAE 0.2198. This supports a strong annual cycle plus serial dependence, not universal SARIMA superiority. Rolling-origin sensitivity and alternative transformation decisions remain useful extensions. Forecasting beyond the observed test range is not part of this model-accuracy assessment.

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
- [Hyndman & Athanasopoulos: Holt–Winters](https://otexts.com/fpp2/holt-winters.html)
- [Hyndman & Athanasopoulos: ETS state-space models](https://otexts.com/fpp2/ets.html)
- [Hyndman & Athanasopoulos: seasonal ARIMA](https://otexts.com/fpp2/seasonal-arima.html)
