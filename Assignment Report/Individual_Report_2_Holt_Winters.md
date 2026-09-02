---
title: "Additive Holt–Winters Forecasting of Monthly Solar Irradiance"
lang: en-GB
---

::: {custom-style="Author"}
[Member 2 name]
:::

::: {custom-style="Affiliation"}
[University and faculty]  
BMMS2094 Statistics for Data Science · Student ID: [ID] · Tutorial/Group: [Identifier]  
Assigned model: Additive Holt–Winters · Submission date: [DD Month YYYY]
:::

```{=openxml}
<w:p><w:pPr><w:sectPr><w:type w:val="continuous"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1080" w:right="893" w:bottom="1440" w:left="893" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:num="1" w:space="720"/><w:docGrid w:linePitch="360"/></w:sectPr></w:pPr></w:p>
```

::: {custom-style="Abstract"}
**Abstract—**This report evaluates additive Holt–Winters forecasting without a trend for monthly NASA POWER surface solar irradiance in Kuala Lumpur. The model preserved the annual cycle, passed residual diagnostics, and achieved test RMSE 0.3101, but ranked fourth among the compared methods.
:::

::: {custom-style="Keywords"}
**Keywords—**additive seasonality, exponential smoothing, forecasting, Holt–Winters, solar irradiance.
:::

# Methodology

This report proposes evaluating Holt–Winters exponential smoothing for monthly NASA POWER solar irradiance in Kuala Lumpur [@nasa-power-monthly]. The method recursively updates level and month-specific seasonal states; a trend state is optional. Additive and multiplicative seasonality would be considered according to whether seasonal amplitude was stable in absolute units or proportional to the series level [@hyndman-athanasopoulos-2021].

The chronological design would use January 2001–December 2020 for training and January 2021–December 2025 for testing. Both partitions contain complete annual cycles, whereas random splitting would leak future data and exact 70:30 would break seasonal boundaries. The need for transformation would be assessed from training diagnostics only, with response-scale modelling preferred for interpretability and direct error comparison when transformation was unnecessary.

Training plots and STL decomposition would inform the seasonal form and whether a trend component was warranted. R would optimise the applicable level, trend, and seasonal smoothing parameters by minimising one-step squared errors, using documented initialisation. The fitted parameter values, their interpretation, and any convergence warning would be presented in the results.

Response residuals would be inspected over time and by ACF, followed by a lag-24 Ljung–Box test with the appropriate fitted degrees of freedom [@forecast-checkresiduals]. Material remaining autocorrelation would trigger reconsideration of the specification. Common test measures would be calculated only after the model was locked from training data.

# Results, Discussion, and Conclusion

Training evidence supported `HoltWinters(train, beta=FALSE, seasonal="additive")`. The fitted smoothing values were α=0.0273 and γ=0.1366; β was absent because trend smoothing was disabled. At lag 24 with two fitted smoothing degrees of freedom, the Ljung–Box result was $Q=28.852$, $p=.149$, so residual white noise was not rejected.

| Test metric | Value |
|---|---:|
| RMSE (kWh/m²/day) | 0.3101 |
| MAE (kWh/m²/day) | 0.2464 |
| MAPE | 5.2213% |
| MASE | 0.8300 |
| sMAPE | 5.1149% |
| Ljung–Box p-value | 0.1491 |

![Holt–Winters test forecasts with 95% intervals.](../analysis_outputs/nasa/figures/nasa_holt_winters_test_forecast.png){width=3.20in}

Holt–Winters reproduced the annual cycle, yielded non-negative point forecasts, and passed residual diagnostics, but ranked fourth on RMSE and MAE. Its RMSE was about 5.9% higher than SARIMA's. Slow adaptation helps suppress noise but may lag changes over a five-year forecast; fixed additive seasonality can also be restrictive. Conversely, the method is transparent and computationally simple.

The model is statistically acceptable but was not the best final forecaster for this test period. Future work should compare a damped-trend formulation, multiplicative seasonality only if variance scales with level, transformation alternatives, and ETS structures under rolling-origin validation. For operational planning, the seasonal resource pattern is useful, but solar irradiance must not be interpreted as electricity production without engineering conversion factors.

::: {custom-style="Heading 5"}
References
:::

::: {#refs}
:::

::: {custom-style="Heading 5"}
Appendix A: Reproducible Holt–Winters Code
:::

Canonical source: `../NASA_Solar_Irradiance_Forecasting.R`. No random procedure is used.

![Holt–Winters training response residuals and residual ACF.](../analysis_outputs/nasa/figures/nasa_holt_winters_diagnostics.png){width=3.20in}

```r
train <- window(series, end = c(2020, 12))
test  <- window(series, start = c(2021, 1))

hw_fit <- HoltWinters(train, beta = FALSE, seasonal = "additive")
hw_fc <- forecast(hw_fit, h = length(test), level = c(80, 95))
hw_fitted <- fitted(hw_fit)[, 1]
hw_actual <- tail(as.numeric(train), length(hw_fitted))
hw_response_residuals <- hw_actual - as.numeric(hw_fitted)
Box.test(hw_response_residuals, lag = 24,
         type = "Ljung-Box", fitdf = 2)
metric_row("Holt-Winters", hw_fc, test, train)
```
