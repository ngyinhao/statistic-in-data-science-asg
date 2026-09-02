---
title: "ETS State-Space Forecasting of Monthly Solar Irradiance"
lang: en-GB
---

::: {custom-style="Author"}
[Member 3 name]
:::

::: {custom-style="Affiliation"}
[University and faculty]  
BMMS2094 Statistics for Data Science · Student ID: [ID] · Tutorial/Group: [Identifier]  
Assigned model: Error–Trend–Seasonal state-space model · Submission date: [DD Month YYYY]
:::

```{=openxml}
<w:p><w:pPr><w:sectPr><w:type w:val="continuous"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1080" w:right="893" w:bottom="1440" w:left="893" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:num="1" w:space="720"/><w:docGrid w:linePitch="360"/></w:sectPr></w:pPr></w:p>
```

::: {custom-style="Abstract"}
**Abstract—**This report evaluates an ETS state-space model for monthly NASA POWER surface solar irradiance in Kuala Lumpur. Automatic selection produced ETS(A,N,A), which achieved test RMSE 0.2947 and passed the declared residual diagnostic threshold, placing a close second to SARIMA.
:::

::: {custom-style="Keywords"}
**Keywords—**ETS, exponential smoothing, forecasting, state space, solar irradiance.
:::

# Methodology

This report proposes evaluating ETS for the monthly Kuala Lumpur NASA POWER irradiance series [@nasa-power-monthly]. ETS identifies the observation error, trend, and seasonal state forms in that order and provides coherent point forecasts and intervals. It generalises classical exponential smoothing by selecting among state-space structures with a likelihood-based criterion [@hyndman-athanasopoulos-2021].

The chronological design would use January 2001–December 2020 for training and January 2021–December 2025 for a single final test. Complete annual cycles were retained to protect seasonal estimation, while random splitting and half-year boundaries were rejected. Transformation would be assessed using training data only, with a common response scale preferred when diagnostics did not require otherwise.

The unrestricted automatic call `ets(train)` would search the standard ETS error, trend, damping, and seasonal structures. AICc would be used only to compare candidates within the ETS family, not against unrelated model likelihoods. The selected structure, smoothing coefficients, and any applicable damping parameter would be reported and interpreted in the results.

To preserve cross-model comparability, diagnostics would use response residuals (`observed − fitted`) rather than multiplicative innovations [@forecast-residuals]. Residual time plots, ACF, and a lag-24 Ljung–Box test with the applicable fitted degrees of freedom would determine whether a specification loop-back was needed.

# Results, Discussion, and Conclusion

The automatic search selected ETS(A,N,A), with additive errors, no trend, and additive seasonality (AICc=729.156). The fitted smoothing coefficients were α=0.02036 and γ=0.0001005; β and damping φ did not apply. At lag 24 with two fitted smoothing degrees of freedom, Ljung–Box gave $Q=32.326$, $p=.072$, so residual white noise was not rejected at 5%, although the result warrants monitoring.

| Test metric | Value |
|---|---:|
| RMSE (kWh/m²/day) | 0.2947 |
| MAE (kWh/m²/day) | 0.2351 |
| MAPE | 4.9673% |
| MASE | 0.7920 |
| sMAPE | 4.8996% |
| Ljung–Box p-value | 0.0720 |

![ETS test forecasts with 95% intervals.](../analysis_outputs/nasa/figures/nasa_ets_test_forecast.png){width=3.20in}

ETS ranked second. Its RMSE exceeded SARIMA by only 0.0019 kWh/m²/day (0.65%), so performance was practically very close; its MAE was 0.0106 higher. Strengths include a transparent selected structure, probabilistic intervals, and stable additive seasonality. Limitations are the near-boundary γ estimate, a residual p-value close to 0.05, limited explanation of automatic selection, and vulnerability to structural change when seasonal states barely update.

ETS(A,N,A) is suitable and a strong alternative, but SARIMA was retained under the declared primary/secondary ranking. Recommended extensions are constrained ETS comparisons, rolling-origin evaluation, Box–Cox sensitivity analysis, and forecast combinations. Forecast intervals should accompany planning decisions, and irradiance should not be equated with electricity output.

::: {custom-style="Heading 5"}
References
:::

::: {#refs}
:::

::: {custom-style="Heading 5"}
Appendix A: Reproducible ETS Code
:::

Canonical source: `../NASA_Solar_Irradiance_Forecasting.R`. No random procedure is used.

![ETS training response residuals and residual ACF.](../analysis_outputs/nasa/figures/nasa_ets_diagnostics.png){width=3.20in}

```r
train <- window(series, end = c(2020, 12))
test  <- window(series, start = c(2021, 1))

ets_fit <- ets(train) # automatic ZZZ search; AICc selection
ets_fc <- forecast(ets_fit, h = length(test), level = c(80, 95))
ets_response_residuals <-
  as.numeric(train) - as.numeric(fitted(ets_fit))
ets_fitdf <- length(intersect(
  names(coef(ets_fit)), c("alpha", "beta", "gamma", "phi")
))
Box.test(ets_response_residuals, lag = 24,
         type = "Ljung-Box", fitdf = ets_fitdf)
metric_row("ETS", ets_fc, test, train)
```
