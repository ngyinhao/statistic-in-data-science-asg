---
title: "Basic Structural Model for Monthly Solar Irradiance"
author: "[Member 4 name]"
lang: en-GB
---

[University and faculty]\\
BMMS2094 Statistics for Data Science · Student ID: [ID] · Tutorial/Group: [Identifier]\\
Assigned model: Basic Structural Model · Submission date: [DD Month YYYY]

# Methodology

This report will evaluate a Basic Structural Model (BSM) for monthly NASA POWER surface solar irradiance in Kuala Lumpur [@nasa-power-monthly]. The model will represent the observation as

$$y_t=\mu_t+\gamma_t+\varepsilon_t,\qquad \mu_t=\mu_{t-1}+\eta_t,$$

where $\mu_t$ will denote a stochastic local level, $\gamma_t$ a zero-sum seasonal state over 12 months, and $\varepsilon_t$ and $\eta_t$ mutually independent irregular and level disturbances. A persistent slope will be omitted unless training-only evidence supports sustained trend extrapolation. A local-linear-trend alternative will be considered only as a sensitivity check. This structure will allow gradual level movement and annual recurrence without imposing a single straight trend [@hyndman-athanasopoulos-2021].

The common 80:20 chronological split will use January 2001--December 2020 for estimation and January 2021--December 2025 for testing. Chronological splitting will preserve forecast order and prevent future observations from informing model identification. Training plots and calendar-month distributions will guide the level, seasonal, and slope choices. Transformation will be considered only if training-scale variation warrants it; otherwise, estimation will remain on the original kWh/m²/day scale.

Candidate structures will be estimated by maximum likelihood with exact diffuse initialisation using `statsmodels` [@seabold-perktold-2010]. Convergence, AIC and BIC, estimated disturbance variances, training-only residual behaviour, and physical plausibility will determine whether the primary specification is retained. Variances close to zero will be treated as boundary estimates rather than evidence of a materially evolving state. The first complete seasonal cycle will be excluded from residual diagnostics to limit diffuse-start effects. Remaining response residuals will be inspected over time and by ACF, followed by a lag-24 Ljung--Box test using the fitted parameter count. Material autocorrelation will trigger specification review.

After the structure is locked, 60 monthly forecasts will be compared with the test observations using ME, MSE, RMSE, MAE, MPE, and MAPE under the `actual − forecast` error convention. RMSE will be primary, MAE secondary, and ME/MPE will indicate bias direction. Forecasts will also be checked for non-negative point values.

# Data Analysis (Results and Discussion)

Training-only evidence supported a stochastic local level, stochastic 12-month seasonal state, and irregular error without a slope. Maximum-likelihood estimation with exact diffuse initialisation converged. The estimated disturbance variances were $\sigma^2_{\varepsilon}=0.0779814$, $\sigma^2_{\eta}=0.00004955$, and $\sigma^2_{\gamma}=2.98\times10^{-12}$. The very small seasonal variance is a boundary estimate: after initialisation, the annual seasonal pattern behaved approximately as fixed rather than changing materially. The small but non-zero level variance allowed gradual adaptation without forced linear extrapolation.

| Metric | Training | Test | Test − training |
|---|---:|---:|---:|
| ME (kWh/m²/day) | 0.0068 | −0.0906 | −0.0974 |
| MSE ((kWh/m²/day)²) | 0.0918 | 0.0871 | −0.0047 |
| RMSE (kWh/m²/day) | 0.3029 | 0.2951 | −0.0078 |
| MAE (kWh/m²/day) | 0.2364 | 0.2370 | 0.0007 |
| MPE | −0.2366% | −2.1818% | −1.9452 pp |
| MAPE | 5.0029% | 5.0141% | 0.0112 pp |

The locked model produced all 60 forecasts for January 2021--December 2025, and every point forecast was non-negative. Test RMSE was 0.2951 and MAE was 0.2370 kWh/m²/day; MAPE was 5.0141%. Negative test ME and MPE indicate average overforecasting under the declared error convention. Training and test errors remain descriptive rather than directly equivalent because diffuse-start months were excluded from the training calculations and the test values are multi-step forecasts.

After excluding the first 12 diffuse-initialisation months, 228 residuals were tested. The lag-24 Ljung--Box statistic was 31.418 with three fitted degrees of freedom and $p=0.0670$, so residual white noise was not rejected at 5%. The result is nevertheless close to the threshold and should not be interpreted as strong evidence of independence. The model's strengths are gradual local-level adaptation, an explicit seasonal state, coherent uncertainty, and avoidance of a forced global trend. Its main limitations are the near-threshold residual result, effectively zero seasonal disturbance variance, and sensitivity of structural states to specification and initialisation.

# Conclusion

The local-level seasonal BSM was suitable for this test period: it converged, generated non-negative forecasts, achieved RMSE 0.2951 and MAE 0.2370, and passed the declared residual gate narrowly. Its structural interpretation is useful, but the boundary seasonal variance and $p=0.0670$ diagnostic require caution. Future work should compare the local-level and local-linear-trend forms using training-only evidence, apply rolling-origin validation, and test whether a fixed seasonal component provides equivalent or more stable forecasts. The output estimates solar-resource availability, not photovoltaic electricity generation without engineering conversion factors.

# References

::: {#refs}
:::

# Appendix

## Appendix A: Reproducible BSM Code

Canonical source: `../NASA_Solar_Irradiance_BSM.py`. The following extract reproduces the locked structure and its diagnostic treatment; no random procedure is used.

```python
import numpy as np
import pandas as pd
from statsmodels.stats.diagnostic import acorr_ljungbox
from statsmodels.tsa.statespace.structural import UnobservedComponents

monthly = pd.read_csv(
    "../analysis_outputs/nasa/nasa_solar_monthly_clean.csv",
    parse_dates=["date"],
)
train = monthly.loc[monthly["date"] < "2021-01-01", "solar_irradiance"]
test = monthly.loc[monthly["date"] >= "2021-01-01", "solar_irradiance"]

model = UnobservedComponents(
    train,
    level=True,
    stochastic_level=True,
    seasonal=12,
    irregular=True,
    use_exact_diffuse=True,
)
initial = model.fit(method="powell", maxiter=2000, disp=False)
fit = model.fit(start_params=initial.params, method="lbfgs", maxiter=2000, disp=False)

forecast = fit.get_forecast(steps=len(test))
point = np.asarray(forecast.predicted_mean)
residuals = train.to_numpy()[12:] - np.asarray(fit.fittedvalues)[12:]
diagnostic = acorr_ljungbox(
    residuals, lags=[24], model_df=len(fit.params), return_df=True
)
```
