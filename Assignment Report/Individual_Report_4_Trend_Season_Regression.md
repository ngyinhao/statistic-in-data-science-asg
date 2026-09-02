---
title: "Forecasting Monthly Solar Irradiance in Kuala Lumpur"
lang: en-GB
---

::: {custom-style="Author"}
[Member 4 name]
:::

::: {custom-style="Affiliation"}
[University and faculty]  
BMMS2094 Statistics for Data Science · Student ID: [ID] · Tutorial/Group: [Identifier]  
Assigned model: Multiple linear regression (trend + season) · Submission date: [DD Month YYYY]
:::

```{=openxml}
<w:p><w:pPr><w:sectPr><w:type w:val="continuous"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1080" w:right="893" w:bottom="1440" w:left="893" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:num="1" w:space="720"/><w:docGrid w:linePitch="360"/></w:sectPr></w:pPr></w:p>
```

::: {custom-style="Abstract"}
**Abstract—**This report evaluates a multiple linear regression with deterministic trend and monthly seasonal indicators for NASA POWER surface solar irradiance in Kuala Lumpur. The model achieved test RMSE 0.2988 but failed the lag-24 residual white-noise diagnostic, limiting its suitability as a standalone forecaster.
:::

::: {custom-style="Keywords"}
**Keywords—**forecasting, linear regression, monthly seasonality, solar irradiance, time trend.
:::

# Methodology

This report proposes evaluating multiple linear regression for monthly NASA POWER solar irradiance in Kuala Lumpur [@nasa-power-monthly]. The proposed model is

$$y_t=\beta_0+\beta_1t+\sum_{j=2}^{12}\delta_jD_{j,t}+\varepsilon_t,$$

where $t$ is the numerical month index, January is the reference month, and eleven indicators represent February–December. `forecast::tslm()` creates the `trend` and `season` variables from the time-series attributes [@forecast-tslm]. Simple trend-only regression was excluded because it cannot represent recurring calendar-month effects; the trend term would estimate movement after controlling for month.

The common chronological split would use January 2001–December 2020 for fitting and January 2021–December 2025 for final testing. Both are full annual cycles; random splitting would leak future information. The need for transformation would be assessed from training data only, with response-scale modelling preferred when variance diagnostics did not justify transformation.

The proposed specification is `tslm(train ~ trend + season)`, with both components included as deliberate research design choices. A trend-only model was not considered sufficient because it cannot capture the observed annual cycle. Although a season-only model provides a useful diagnostic comparison, retaining the trend term allows the analysis to assess whether systematic movement remains after controlling for monthly seasonality. January was chosen as the reference category to avoid perfect multicollinearity; selecting a different reference month would alter the coefficient interpretation but not the fitted values. The remaining eleven monthly indicators are represented collectively as a single seasonal factor rather than evaluated individually. Ordinary least squares jointly estimates all coefficients by minimising the sum of squared residuals over the training data, so the coefficient values are determined by the data rather than manually chosen. The suitability of this specification would be assessed using coefficient uncertainty, adjusted $R^2$, residual standard error, and expanding-window validation at the practically relevant 12-month forecast horizon [@hyndman-athanasopoulos-2021].

Response residuals would be inspected over time and by ACF, followed by a lag-24 Ljung–Box test [@forecast-checkresiduals]. Lag 24 was selected to examine dependence across two complete annual cycles, with the 13 fitted regression coefficients reflected in the reference degrees of freedom. Material autocorrelation would trigger consideration of regression with ARIMA errors, while the proposed model would remain the focus. Training and test performance would be reported consistently using ME, MSE, RMSE, MAE, MPE, and MAPE, together with each test-minus-training difference. ME and MPE would be judged by closeness to zero and sign; the remaining error measures would be minimised.

# Data Analysis

**Training evidence and model identification—**The 2001–2020 time plot and STL decomposition showed a clear recurring annual pattern but only modest long-term movement. The annual pattern supported twelve-month seasonality represented by eleven indicators plus January as the reference; modest movement cautioned against claiming a strong trend. The assignment-required `trend + season` formulation was retained to estimate whether movement remained after controlling for month, while its consequences were evaluated through coefficient uncertainty, rolling-origin validation, and residual diagnostics rather than accepted as a default.

![Training-only time series and STL components used for model identification.](../analysis_outputs/nasa/figures/nasa_training_identification.png){width=3.20in}

```{=openxml}
<w:p><w:r><w:br w:type="column"/></w:r></w:p>
```

Ordinary least squares jointly fitted the 13 coefficients; none was manually chosen. The model had adjusted $R^2=0.5358$ ($R^2=0.5591$; residual SE=0.2817). Relative to the deliberately defined January baseline, March was +0.6468 and December was −0.4147 kWh/m²/day, showing interpretable seasonal contrasts. The trend was +0.000381 per month (SE=0.000263, $p=0.148$); its uncertainty does not support strong long-run movement, but the term was retained because the assignment specification requires trend after seasonal control. The 12-month validation horizon represents one planning year; expanding-window validation over 217 origins yielded RMSE=0.3545 and MAE=0.2681. At lag 24, with 13 fitted coefficients accounted for, Ljung–Box gave $Q=32.622$, $p<0.001$, providing evidence that the fixed formula needs a serial-error extension.

| Metric | Training | Test | Test − training |
|---|---:|---:|---:|
| ME (kWh/m²/day) | 0.0000 | −0.0989 | −0.0989 |
| MSE ((kWh/m²/day)²) | 0.0751 | 0.0893 | 0.0142 |
| RMSE (kWh/m²/day) | 0.2740 | 0.2988 | 0.0248 |
| MAE (kWh/m²/day) | 0.2116 | 0.2414 | 0.0298 |
| MPE | −0.3457% | −2.3584% | −2.0127 pp |
| MAPE | 4.4952% | 5.1093% | 0.6141 pp |

The lag-24 Ljung–Box p-value was 0.0006. The negative test ME and MPE indicate average overforecasting under the `actual − forecast` convention. Training–test differences are descriptive because fitted residuals and multi-step holdout errors come from different evaluation settings.

![Trend-plus-season regression test forecasts with 95% intervals.](../analysis_outputs/nasa/figures/nasa_trend_season_test_forecast.png){width=3.20in}

Regression achieved test RMSE 0.2988 and produced non-negative point forecasts. Its strength is direct interpretation: recurring month effects explain substantial variation, while the small uncertain trend prevents an exaggerated long-run claim. Its main weakness is decisive residual autocorrelation; fixed month effects and a linear trend do not capture remaining temporal dependence. Fixed linear extrapolation and homoscedastic independent-error assumptions are additional limitations.

# Conclusion

The specified regression is useful descriptively but is not adequate as a standalone forecaster: RMSE was 0.2988 and MAE was 0.2414, yet the lag-24 Ljung–Box test rejected residual white noise. Its deliberately retained trend and month indicators provide direct interpretation, but the uncertain trend and remaining serial correlation limit the fixed formula. Regression with ARIMA errors is the primary recommended extension, with Fourier seasonality, structural-change terms, robust variance checks, and rolling-origin validation as additional checks. Any irradiance forecast remains a solar-resource estimate, not photovoltaic electricity output.

# References

::: {#refs}
:::

# Appendix

## Appendix A: Reproducible Regression Code

Canonical source: `../NASA_Solar_Irradiance_Forecasting.R`. No random procedure is used.

![Regression training response residuals and residual ACF.](../analysis_outputs/nasa/figures/nasa_trend_season_diagnostics.png){width=3.20in}

```r
train <- window(series, end = c(2020, 12))
test  <- window(series, start = c(2021, 1))

trend_season <- tslm(train ~ trend + season)
reg_fc <- forecast(trend_season, h = length(test), level = c(80, 95))
reg_res <- as.numeric(train) - as.numeric(fitted(trend_season))
Box.test(reg_res, lag = 24, type = "Ljung-Box",
         fitdf = length(coef(trend_season)))

cv_fun <- function(y, h) forecast(tslm(y ~ trend + season), h = h)
cv_h12 <- tsCV(train, cv_fun, h = 12)[, 12]
metric_row("Trend + season", reg_fc, test, train)
```
