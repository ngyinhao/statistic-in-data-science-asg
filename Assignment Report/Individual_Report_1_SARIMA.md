---
title: "Forecasting Monthly Solar Irradiance in Kuala Lumpur"
lang: en-GB
---

::: {custom-style="Author"}
[Member 1 name]
:::

::: {custom-style="Affiliation"}
[University and faculty]  
BMMS2094 Statistics for Data Science · Student ID: [ID] · Tutorial/Group: [Identifier]  
Assigned model: Seasonal ARIMA · Submission date: [DD Month YYYY]
:::

```{=openxml}
<w:p><w:pPr><w:sectPr><w:type w:val="continuous"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1080" w:right="893" w:bottom="1440" w:left="893" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:num="1" w:space="720"/><w:docGrid w:linePitch="360"/></w:sectPr></w:pPr></w:p>
```

::: {custom-style="Abstract"}
**Abstract—**This report evaluates seasonal ARIMA for monthly NASA POWER surface solar irradiance in Kuala Lumpur using a fixed 240-month training period and 60-month test period. The selected ARIMA(0,0,2)(2,1,1)~12~ model achieved RMSE 0.2928 and passed the lag-24 residual white-noise test.
:::

::: {custom-style="Keywords"}
**Keywords—**forecasting, NASA POWER, SARIMA, seasonal differencing, solar irradiance.
:::

# Methodology

This report proposes evaluating SARIMA for monthly Kuala Lumpur solar irradiance (kWh/m²/day) from NASA POWER [@nasa-power-monthly]. SARIMA is a reasonable candidate because it can represent ordinary and annual-lag dependence after differencing. A seasonal model is written as ARIMA$(p,d,q)(P,D,Q)_{12}$, where $p/q$ and $P/Q$ are ordinary/seasonal AR and MA orders, while $d/D$ are ordinary/seasonal differences [@hyndman-athanasopoulos-2021].

The observations were to be split chronologically into a January 2001–December 2020 training period and a January 2021–December 2025 test period. Both contain complete 12-month cycles; random splitting was rejected to prevent future leakage. An exact 70:30 split breaks annual boundaries, while 72:28 sacrifices two additional training years. The need for a variance-stabilising transformation would be assessed using training data only, with the response scale preferred when diagnostics did not justify transformation and direct interpretation remained important.

Training plots, monthly summaries, STL decomposition, and stationarity diagnostics would guide ordinary and seasonal differencing. KPSS-guided `ndiffs()` and seasonal-strength `nsdiffs()` would inform $d$ and $D$; zero, ordinary, seasonal, and combined differencing were the alternatives, with the smallest orders that removed supported non-stationarity preferred to avoid over-differencing. `seasonal=TRUE` and period 12 were fixed because the data are monthly and exhibit an annual cycle. `auto.arima()` would search seasonal orders by AICc [@hyndman-khandakar-2008]. `stepwise=FALSE` and `approximation=FALSE` deliberately replace faster defaults with an exhaustive, exact-likelihood search because 240 observations make the additional computation manageable and reduce the risk that a shortcut determines the order. `allowdrift=TRUE` keeps drift eligible rather than forcing it; AICc may retain it only when supported after differencing. Orders and search settings are analytical choices, whereas the AR/MA coefficients are jointly estimated from the training likelihood rather than manually selected.

Response residuals would be assessed over time, by ACF, and with a lag-24 Ljung–Box test using fitted degrees of freedom [@forecast-checkresiduals]. Material residual autocorrelation would trigger a loop back to model identification. Training and test performance would be reported consistently using ME, MSE, RMSE, MAE, MPE, and MAPE, together with each test-minus-training difference. RMSE would remain primary and MAE secondary; ME and MPE would be interpreted by closeness to zero and sign.

# Data Analysis

**Training evidence and model identification—**The 2001–2020 time plot and STL decomposition showed a strong recurring annual pattern, approximately stable seasonal amplitude, and comparatively modest long-term movement. Training-only diagnostics recommended no ordinary difference ($d=0$) and one seasonal difference ($D=1$): $d=0$ preserved level information when ordinary differencing was unnecessary, while $D=1$ removed the supported annual non-stationarity at lag 12. The response scale was retained because seasonal amplitude was broadly stable in absolute units and a transformation was not sufficiently supported. This evidence established differencing and transformation before order selection.

![Training-only time series and STL components used for model identification.](../analysis_outputs/nasa/figures/nasa_training_identification.png){width=3.20in}

```{=openxml}
<w:p><w:r><w:br w:type="column"/></w:r></w:p>
```

The exhaustive exact-likelihood search compared admissible seasonal orders by AICc and selected ARIMA$(0,0,2)(2,1,1)_{12}$ (AICc=105.397); thus $p=0,q=2,P=2,Q=1$ came from a declared training criterion, not software defaults. Although drift was allowed, the selected model contained neither mean nor drift, consistent with seasonal differencing and weak long-run movement. Likelihood optimisation jointly fitted MA1=0.2248 (SE=0.0678), MA2=0.0903 (0.0696), SAR1=−0.0086 (0.0870), SAR2=−0.1301 (0.0824), and SMA1=−0.8869 (0.0959); these values were estimated, not manually chosen. The large seasonal MA estimate represents strong annual-lag error correction, whereas uncertain SAR estimates make nearby-order sensitivity checks important. Lag 24 examines two annual cycles, with five fitted coefficients deducted in the Ljung–Box reference distribution. The result, $Q=23.577$, $p=0.213$, did not trigger an order modification.

| Metric | Training | Test | Test − training |
|---|---:|---:|---:|
| ME (kWh/m²/day) | 0.0090 | −0.0566 | −0.0657 |
| MSE ((kWh/m²/day)²) | 0.0762 | 0.0857 | 0.0096 |
| RMSE (kWh/m²/day) | 0.2760 | 0.2928 | 0.0169 |
| MAE (kWh/m²/day) | 0.2048 | 0.2245 | 0.0197 |
| MPE | −0.1289% | −1.4643% | −1.3355 pp |
| MAPE | 4.3441% | 4.7346% | 0.3905 pp |

The lag-24 Ljung–Box p-value was 0.2129. The negative test ME and MPE indicate average overforecasting under the `actual − forecast` convention. Training–test differences are descriptive because fitted residuals and multi-step holdout errors come from different evaluation settings.

![SARIMA test forecasts with 95% intervals.](../analysis_outputs/nasa/figures/nasa_sarima_test_forecast.png){width=3.20in}

SARIMA achieved test RMSE 0.2928 and MAE 0.2245, passed the residual gate, and produced non-negative point forecasts. These results support its suitability for the observed series and test period. Strengths are its direct treatment of seasonal differencing and lag dependence and its well-behaved residuals. Limitations include order-search uncertainty, possible sensitivity to transformation and structural change, weakening precision at long horizons, and limited substantive interpretability of interacting MA/SAR terms.

The locked order was re-estimated—not merely copied—on all 300 observations for 2026. Updated coefficients were MA1=0.2126, MA2=0.1008, SAR1=−0.0013, SAR2=−0.0774, and SMA1=−0.9343. Point forecasts ranged from 4.2238 (December) to 5.2472 (March), consistent with the observed seasonal cycle.

# Conclusion

SARIMA is suitable and is the defensible final model for this sample: it achieved RMSE 0.2928 and MAE 0.2245, while the lag-24 Ljung–Box result did not reject residual white noise. Its evidence-based seasonal differencing and AICc-selected lag structure are strengths, but uncertain seasonal AR estimates and possible order sensitivity remain limitations. Nearby manual orders, rolling-origin validation, Box–Cox alternatives, and weather regressors should therefore be tested before operational use. Irradiance forecasts do not directly predict photovoltaic electricity generation.

# References

::: {#refs}
:::

# Appendix

## Appendix A: Reproducible SARIMA Code

Canonical source: `../NASA_Solar_Irradiance_Forecasting.R`. No random procedure is used, so no random seed is required.

![SARIMA training response residuals and residual ACF.](../analysis_outputs/nasa/figures/nasa_sarima_diagnostics.png){width=3.20in}

```r
train <- window(series, end = c(2020, 12))
test  <- window(series, start = c(2021, 1))

sarima_fit <- auto.arima(
  train, seasonal = TRUE, stepwise = FALSE,
  approximation = FALSE, allowdrift = TRUE
)
sarima_fc <- forecast(sarima_fit, h = length(test), level = c(80, 95))
response_residuals <- as.numeric(train) - as.numeric(fitted(sarima_fit))
Box.test(response_residuals, lag = 24, type = "Ljung-Box",
         fitdf = length(coef(sarima_fit)))
metric_row("SARIMA", sarima_fc, test, train)
```
