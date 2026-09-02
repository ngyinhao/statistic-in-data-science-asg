# BMMS2094 Assignment Plan: One Group Report and Four Individual Reports

## 1. Purpose of This Plan

This document is the working plan for a four-member BMMS2094 Statistics for Data Science assignment team. The final submission package must contain:

- **1 group report** covering the common problem, dataset, workflow, comparison of all models, SDG relevance, and overall conclusions.
- **4 individual reports**, with one report per member and one forecasting model assigned to each member.

This plan is based on the requirements and rubrics in [1. BMMS2094 Assignment.pdf](./1.%20BMMS2094%20Assignment.pdf), while also reviewing the current [NASA solar-irradiance group report](./NASA_Solar_Irradiance_Report.docx), [model research notes](./NASA_Solar_Irradiance_Model_Research.md), [R analysis script](./NASA_Solar_Irradiance_Forecasting.R), and generated analysis outputs.

## 2. Fixed Project Decisions

### 2.1 Topic and dataset

- **Topic:** Forecasting monthly solar irradiance in Kuala Lumpur.
- **Dataset:** NASA POWER monthly `ALLSKY_SFC_SW_DWN` data.
- **Period currently available:** January 2001 to December 2025.
- **Number of observations:** 300 continuous monthly observations.
- **Frequency:** Monthly, with seasonal period `m = 12`.
- **Unit:** kWh/m2/day.
- **Main SDG:** United Nations **SDG 7 - Affordable and Clean Energy**, especially Target 7.2 on increasing the share of renewable energy.
- **Required justification:** Explain how forecasting seasonal solar-resource availability can support preliminary renewable-energy planning, maintenance scheduling, storage planning, and feasibility assessment. Do not claim that irradiance is the same as electricity production.

### 2.2 Four-member model allocation

| Member | Assigned individual model | Main individual responsibility |
|---|---|---|
| Member 1: `[Name / ID]` | **SARIMA** | Stationarity, differencing, ARIMA order selection, estimation, residual diagnosis, and forecast interpretation |
| Member 2: `[Name / ID]` | **Holt-Winters** | Additive/multiplicative choice, level/trend/seasonal components, smoothing parameters, residual diagnosis, and forecast interpretation |
| Member 3: `[Name / ID]` | **ETS** | ETS error-trend-seasonal structure search, information criterion, estimated states/parameters, residual diagnosis, and forecast interpretation |
| Member 4: `[Name / ID]` | **Multiple Linear Regression (`trend` + `season`)** | Regression specification, trend and seasonal terms, coefficient interpretation, assumptions, residual diagnosis, and forecast interpretation |

The four models above are the complete set of official member-contributed models.

### 2.3 Chronological train-test ratio

Use an **80:20 chronological split** for every model.

| Partition | Observations | Dates | Percentage |
|---|---:|---|---:|
| Training set | First 240 months | January 2001 to December 2020 | 80% |
| Test set | Final 60 months | January 2021 to December 2025 | 20% |
| Total | 300 months | January 2001 to December 2025 | 100% |

#### Step-by-step split decision

**Step 1 - Identify the statistical constraint.**

The data are monthly and have an annual seasonal period of 12. Therefore, both the training and test sizes should be multiples of 12 so neither partition ends halfway through a seasonal cycle. The split must also be chronological because random shuffling would allow later observations to influence a model evaluated on earlier observations.

**Step 2 - Calculate the two main candidates.**

| Candidate | Training months | Training cycles | Test months | Test cycles | Boundary |
|---|---:|---:|---:|---:|---|
| 72:28 | 216 | 18 years | 84 | 7 years | Train ends Dec 2018; test begins Jan 2019 |
| 80:20 | 240 | 20 years | 60 | 5 years | Train ends Dec 2020; test begins Jan 2021 |

Both candidates preserve complete January-December cycles. An exact 70:30 split would use 210 training months and 90 test months, but both values contain half-year boundaries and are not divisible by 12.

**Step 3 - Determine how much training history the four models need.**

- SARIMA needs enough repeated seasonal lags to estimate ordinary and seasonal dependence reliably.
- Holt-Winters needs repeated cycles to initialize and estimate level, trend, and seasonal components.
- ETS searches across several state-space structures, so additional training observations reduce the risk of selecting a structure from too little history.
- Multiple Linear Regression (`trend` + `season`) estimates a time trend and eleven monthly effects, so more training years improve the stability of its coefficients.

The 80:20 candidate supplies 20 complete years, two more annual cycles than 72:28. This favors more stable estimation for all four model families.

**Step 4 - Determine whether the smaller 80:20 test set is still sufficient.**

The 80:20 test set contains 60 observations or five complete annual cycles. It is not a small one-season holdout. It covers every calendar month five times and is long enough to reveal whether a model maintains its trend and seasonal behavior on unseen data. Therefore, reducing the test set from seven cycles to five cycles does not make evaluation inadequate.

**Step 5 - Match the test horizon to the intended forecasting task.**

The current project ultimately discusses forecasts such as the following year, not a seven-year operational forecast. A seven-year test horizon from the 72:28 split places unusually heavy weight on very long-horizon deterioration. A five-year test remains demanding while being closer to the practical forecasting use of the project.

**Step 6 - Compare the tradeoff explicitly.**

| Decision criterion | 72:28 | 80:20 | Preferred |
|---|---|---|---|
| Complete 12-month cycles | Yes | Yes | Tie |
| Chronological integrity | Yes | Yes | Tie |
| Amount of training data | 216 months | 240 months | 80:20 |
| Number of test seasons | 7 | 5 | 72:28, but both are sufficient |
| Parameter-estimation stability | Good | Better | 80:20 |
| Test horizon aligned with practical use | Longer than needed | Still demanding and more relevant | 80:20 |
| Familiarity and ease of explanation | Less conventional | Common and easy to communicate | 80:20 |

**Step 7 - Make and document the decision.**

Select 80:20 because it preserves complete seasonal cycles, provides a substantial five-year test, and gives every model 20 years of training data. The choice is based on seasonal integrity, estimation stability, test adequacy, and forecast relevance. It is not chosen merely because 80:20 is a common rule of thumb.

#### Why the 80:20 ratio was selected

The 80:20 ratio was selected through the following reasoning:

1. **The dataset contains 300 monthly observations.** An 80% training allocation gives `300 x 0.80 = 240` observations, while a 20% testing allocation gives `300 x 0.20 = 60` observations.
2. **Both partitions contain complete seasonal cycles.** The series has a seasonal period of 12 months. The training set contains `240 / 12 = 20` complete annual cycles, and the test set contains `60 / 12 = 5` complete annual cycles. No partition ends in the middle of a year.
3. **The split remains chronological.** The first 240 observations, January 2001-December 2020, are used for training. The final 60 observations, January 2021-December 2025, are reserved for testing. This prevents future observations from leaking into model estimation.
4. **The training set is sufficiently large for all four models.** Twenty years of data provide repeated annual patterns for estimating SARIMA seasonal lags, Holt-Winters components, ETS states, and Multiple Linear Regression (`trend` + `season`) coefficients.
5. **The test set remains sufficiently demanding.** Five unseen years cover every calendar month five times. This is enough to evaluate whether each model generalizes across repeated annual cycles rather than succeeding in only one unusual year.
6. **It balances estimation and evaluation.** A larger training set improves parameter stability, while the 60-month holdout is still long enough to calculate reliable common accuracy measures and inspect forecast deterioration.
7. **It is more appropriate than exact 70:30 for this seasonal dataset.** Exact 70:30 produces 210 training months and 90 test months. Neither is divisible by 12, so the boundary occurs halfway through an annual cycle.
8. **It is preferred over 72:28 for the project objective.** Although 72:28 also preserves full years and gives a larger test set, it removes two complete years from model training and creates a seven-year test horizon. The assignment is focused on selecting a useful forecasting model rather than evaluating an exceptionally long seven-year operational forecast.
9. **The decision is made before evaluating final test performance.** The team must not choose 80:20 because one model happens to obtain a better RMSE under that split. The ratio is chosen from the data frequency, sample size, estimation requirements, and intended forecasting use.

**Report-ready explanation:**

> An 80:20 chronological train-test split was selected for the 300-observation monthly series. This allocation uses the first 240 observations from January 2001 to December 2020 for model development and reserves the final 60 observations from January 2021 to December 2025 for out-of-sample evaluation. Because the seasonal period is 12 months, the split provides 20 complete annual cycles for training and five complete annual cycles for testing. It therefore preserves seasonal integrity, avoids future-data leakage, provides sufficient history for estimating SARIMA, Holt-Winters, ETS, and Multiple Linear Regression (`trend` + `season`) models, and retains a substantial multi-year test period. An exact 70:30 split was not used because its 210- and 90-month partitions end halfway through annual cycles. The 72:28 alternative preserves complete cycles but provides two fewer training years and creates a longer seven-year test horizon. Therefore, 80:20 offers the more suitable balance between stable parameter estimation and meaningful out-of-sample evaluation for this project.

#### Operational rules for the selected split

- Do **not** randomly shuffle the observations.
- All four members must use the same training dates, test dates, forecast horizon, actual values, and metric formulas.
- Fit and tune each model using only the training set. The test set must not influence parameter selection.
- Produce a 60-month test forecast from each training-set model and compare it with the same 60 observed test values.
- After the final comparison, refit the chosen specification on all 300 observations only if a future forecast, such as the 2026 forecast, is required.
- Clearly state that the 60-month holdout evaluates stability across five complete seasonal cycles. It is a project evaluation design, not a random machine-learning split.

## 3. Common Analysis Workflow for All Four Models

The workflow below follows the supplied model-selection diagram. The same decision sequence must be visible in the group report and followed in each individual analysis, but model-specific details must be used where ARIMA-specific steps do not apply.

### Decision-explanation standard for all reports

Every important analytical decision must be explained through the following six-part sequence:

1. **State the decision question.** Example: "Does the training series require a variance-stabilizing transformation?"
2. **List the reasonable alternatives.** Example: no transformation, logarithm, or an estimated Box-Cox transformation.
3. **Present the evidence used.** Example: time plot, seasonal plot, variance-by-level pattern, Box-Cox lambda estimate, ACF/PACF, AICc, residual plot, or test result.
4. **State the decision criterion.** Example: choose the simplest option that stabilizes variance without harming interpretability, or choose the candidate with lower training AICc subject to acceptable residual diagnostics.
5. **State and justify the selected option.** Give the exact model, parameter, split, transformation, or diagnostic setting and connect it directly to the evidence.
6. **Explain the consequence and limitation.** State how the decision affects estimation, forecasts, interpretation, comparability, or uncertainty, and acknowledge any remaining weakness.

Apply this sequence to:

- Dataset inclusion and cleaning decisions.
- Chronological train-test split.
- Seasonal frequency.
- Transformation choice.
- Trend and seasonality representation.
- SARIMA differencing and orders.
- Holt-Winters component and smoothing choices.
- ETS structure and search restrictions.
- Multiple Linear Regression (`trend` + `season`) formula.
- Residual-test lag and degrees of freedom.
- Accuracy measures and primary ranking metric.
- Final overall model selection.
- Refit and future-forecast horizon.

Avoid unsupported statements such as "80:20 was used because it is standard," "the model was selected automatically," or "the residuals are good." Each statement must be followed by the evidence, criterion, and interpretation that produced it.

### Step 1 - Plot and understand the data

Required checks and outputs:

- Plot the complete monthly time series.
- Plot or summarize the training and test periods with the split date marked.
- Identify unusual observations, missing values, duplicate dates, discontinuities, possible level changes, trend, and annual seasonality.
- Produce a calendar-month seasonal plot or monthly boxplot.
- Use STL decomposition to examine trend, seasonal, and remainder components.
- Report descriptive statistics: count, mean, standard deviation, minimum, maximum, median, and calendar-month means.
- Confirm that the seasonal frequency is 12.
- Explain whether any unusual values are genuine observations or data errors. Do not remove observations only because they look extreme.

### Step 2 - Stabilize variance if necessary

- Inspect whether seasonal variation or residual spread increases with the series level.
- Consider a Box-Cox transformation only if the plot and training data show non-constant variance.
- Estimate or justify lambda using the training set only.
- Compare transformed and untransformed diagnostics.
- Record the chosen lambda. If no transformation is used, explicitly state why it was unnecessary.
- If forecasts are back-transformed, state whether bias adjustment is used.
- Confirm that final forecasts remain physically plausible and non-negative.

### Step 3 - Address non-stationarity or structural components

This step must be adapted by model:

- **SARIMA:** use stationarity tests such as KPSS or ADF together with plots; determine non-seasonal differencing `d` and seasonal differencing `D`; avoid over-differencing.
- **Holt-Winters:** do not difference automatically. Decide whether the model needs level, trend, damped trend, and additive or multiplicative seasonality.
- **ETS:** do not difference automatically. Allow the ETS structure to represent level, trend, damping, and seasonality; restrict the search only when supported by the data or physical reasoning.
- **Multiple Linear Regression (`trend` + `season`):** represent non-stationary movement through the regression trend variable and recurring annual movement through the seasonal indicator variables. Check whether residual correlation remains after these terms are fitted.

### Step 4 - Identify reasonable candidate specifications

#### SARIMA candidates

- Plot ACF and PACF after the chosen transformation/differencing.
- Use the ACF/PACF and seasonal lags 12, 24, and so on to propose candidate `(p,d,q)(P,D,Q)[12]` models.
- Either select orders manually or use `auto.arima()`.
- If using `auto.arima()`, record all important settings, including `seasonal`, `stepwise`, `approximation`, information criterion, drift/mean allowance, and search limits.
- Compare the automatic model with a small number of nearby, interpretable manual candidates where feasible.

#### Holt-Winters candidates

- Compare additive and multiplicative seasonality only when both are mathematically and substantively appropriate.
- Compare no-trend, trend, and damped-trend versions where supported by the implementation used.
- Allow alpha, beta, and gamma to be optimized on training data unless a fixed value has a clear justification.
- Record initialization choices and convergence warnings.
- The team must decide and lock whether Holt-Winters includes a trend. Do not combine results generated before and after changing `beta`.

#### ETS candidates

- Begin with the automatic ETS search, such as `ets(..., model = "ZZZ")`.
- Record the selected error, trend, and seasonal components, for example `ETS(M,N,A)`.
- Record whether the trend is damped and report alpha, beta, gamma, and phi when present.
- Record the information criterion used, normally AICc, and any restrictions such as additive-only models.
- Consider a small set of scientifically plausible alternatives if the automatic model leaves autocorrelation or produces implausible forecasts.

#### Multiple Linear Regression (`trend` + `season`) candidates

- Begin with a regression such as `y ~ trend + season`.
- Compare a no-trend seasonal model with the linear-trend-plus-season model using only training information.
- If justified and space permits, compare month indicators with a small Fourier seasonal basis.
- Avoid high-order polynomial trend extrapolation unless it is strongly justified and validated.
- If residual autocorrelation remains, discuss regression with ARIMA errors as a possible improvement rather than adding arbitrary lagged predictors.

### Step 5 - Fit candidates and choose a model within each family

- Fit all candidate specifications to the 240-month training set.
- Use AICc or another suitable information criterion to compare specifications **within the same model family** where applicable.
- Do not use AIC/AICc to rank SARIMA directly against Holt-Winters, ETS, or regression when their likelihoods and response treatments are not comparable.
- Keep the candidate set small, interpretable, and documented.
- Record the final specification, estimated parameters, software function, package version, warnings, and convergence status.
- Do not choose the model using the 60-month test RMSE at this stage.

### Step 6 - Diagnose residuals and loop back if necessary

For every final training-set model:

- Plot residuals over time.
- Plot the residual ACF; include PACF when useful.
- Inspect a residual histogram or Q-Q plot for serious non-normality or outliers.
- Apply a portmanteau test such as the Ljung-Box test at a justified lag, with fitted-model degrees of freedom handled correctly.
- State the null hypothesis and interpret the p-value.
- Check whether residuals are approximately zero-mean, have stable variance, and show no important remaining autocorrelation.
- Check forecast plausibility and prediction intervals.

Decision rule:

- If residuals resemble white noise and the model is stable and plausible, proceed to forecasting.
- If residuals are not approximately white noise, return to the transformation, component, differencing, order, or parameter-selection steps and fit a better candidate.
- If no candidate fully removes the issue, retain the most defensible model but disclose the remaining diagnostic limitation.

### Step 7 - Forecast and evaluate

- Generate 60 monthly point forecasts for January 2021 to December 2025.
- Include 80% and 95% prediction intervals where the model supports them.
- Calculate the same test measures for all four models: **RMSE, MAE, MAPE, MASE, and sMAPE**.
- Use **test RMSE as the primary ranking measure** and **test MAE as the secondary measure**.
- Also consider residual validity, interval behavior, stability, and physical plausibility. Do not select a numerically best model if it is diagnostically invalid or produces implausible forecasts.
- Present one common comparison table and one common forecast-versus-actual figure.
- If a future forecast is required, refit each locked model specification or the selected overall model on all 300 observations and forecast 2026. Clearly distinguish test forecasts from future forecasts.

## 4. Group Report Plan

### 4.1 Mandatory format

- **One report for the whole group.**
- **Maximum length:** 5 pages. To comply conservatively, treat the cover page as part of the five-page maximum unless the tutor confirms otherwise.
- **Template:** IEEE conference paper template.
- **References:** IEEE numbered citation and reference style.
- **Cover page:** all four names, student IDs, signatures, and contribution percentages.
- Keep the report concise, comparative, and integrated. Do not paste four individual reports together.

The required section order from the assignment brief is:

1. **Cover Page** - signatures and contribution percentage for every member.
2. **Introduction** - background, objectives, dataset, and the selected SDG number and title.
3. **Methodology** - dataset description, preprocessing, overall analytical workflow, forecasting methods, and forecast-evaluation criteria.
4. **Data Analysis** - combined results and discussion.
5. **Conclusion** - discussion, limitations, and recommendations where appropriate.
6. **References** - IEEE referencing style.

Use these six items as the report's controlling structure. An abstract and keywords are **not explicitly required by the assignment brief**. Include them only if the IEEE template being used requires them or the tutor confirms that they are expected; they must never replace or be merged into the cover page.

### 4.2 Recommended five-page budget

| Page | Planned content |
|---|---|
| Page 1 | Cover page with project title, course details, dataset, all four members, IDs, signatures, and contribution percentages |
| Page 2 | Introduction, problem statement, measurable objectives, dataset source/suitability, and SDG 7 alignment; add only a compact IEEE abstract and keywords before the Introduction if the template or tutor requires them |
| Page 3 | Common methodology: preprocessing, justified 80:20 whole-season chronological split, diagram-based workflow, four model summaries, diagnostics, and evaluation criteria |
| Page 4 | Combined data analysis: descriptive pattern, model comparison table, common forecast figure, residual evidence, and interpretation |
| Page 5 | Critical discussion, SDG implications, limitations, recommendations, conclusion, and compact IEEE references |

If the official IEEE template causes overflow, reduce repetition and move low-priority details to the individual reports. Do not shrink figures or text until they become unreadable.

### 4.3 Group-report section details

#### Cover page

Include:

- University, faculty, course code, course name, semester, and session.
- Report title focused on the real-world forecasting problem.
- Dataset name and source.
- Team/group identifiers if required.
- Four member names and student IDs.
- Signature for each member.
- Contribution percentage for each member, totaling exactly 100%.
- Submission date.

The cover page must contain only the administrative and identification details listed above. **Do not include the abstract, keywords, research summary, model-selection explanation, results, or conclusions on the cover page.** Begin the Introduction on the following page; if an IEEE abstract and keywords are required, place them on that page immediately before the Introduction.

#### Optional IEEE abstract and keywords

This is **not one of the six sections explicitly required by the assignment brief**. Include it only when required by the IEEE template being used or confirmed by the tutor. If included, place it after the cover page and before the Introduction, never within the cover-page section. Write it last and include:

- The problem and location.
- Dataset period and number of observations.
- The four compared models.
- The chronological 80:20 whole-season design and the step-by-step reason it was selected over 72:28 and exact 70:30.
- The final winning model and key regenerated test metric.
- A one-sentence practical/SDG implication.
- A careful limitation that irradiance is not electricity output.

Do not keep the current SARIMA result in the abstract unless SARIMA remains the winner after the complete 80:20 rerun.

#### Introduction

Include:

- Background on monthly solar-resource variability and why it matters.
- A clearly formulated forecasting problem.
- Two to four measurable objectives.
- Reliable NASA POWER dataset source and why 300 monthly observations are sufficient.
- Exact variable, unit, location, and time range.
- SDG 7 number, title, relevant target, and a specific explanation of the link.

Suggested objectives:

1. Validate and describe the monthly NASA POWER solar-irradiance series.
2. Fit and diagnose SARIMA, Holt-Winters, ETS, and Multiple Linear Regression (`trend` + `season`) models.
3. Compare all four models on a common 80:20 chronological test, selected after evaluating seasonal integrity, training adequacy, test adequacy, and forecast relevance, using RMSE, MAE, MAPE, MASE, and sMAPE.
4. Interpret the selected forecast for preliminary solar-resource planning and SDG 7 while acknowledging data and engineering limitations.

#### Methodology

**Proposal-stage boundary:** write this section as a plan of what will be done, not as a preview of what the data showed. It may identify the dataset, fixed sampling period, intended split, candidate models, diagnostics, decision rules, and software procedures. It must not contain observed descriptive summaries, estimated Box-Cox values, selected orders or structures, fitted coefficients, AIC/AICc outcomes, diagnostic statistics or p-values, accuracy results, forecasts, rankings, or a winning model. Move every such empirical finding to **Data Analysis/Results**. In particular, describe how transformation need will be assessed without reporting an estimated lambda in Methodology.

Include:

- Dataset extraction and preprocessing steps.
- Treatment of `YYYY13` annual-summary records and NASA fill values such as `-999`.
- Checks for missing months, duplicates, missing values, and plausible range.
- Definition of the monthly time series with frequency 12.
- Exact 80:20 dates, the requirement for complete 12-month cycles, and the step-by-step reason it is preferred over 72:28 and exact 70:30.
- A compact workflow based on the supplied seven-step diagram.
- One concise paragraph or compact table describing the four model families.
- Planned transformation assessment and training-only parameter-selection procedure, without reporting an estimated lambda or selected empirical outcome.
- Residual checks and white-noise loop.
- Common accuracy metrics and final selection rule.
- Software, R packages, and reproducibility details.

#### Data analysis and combined discussion

Include:

- One main data visualization showing trend/seasonality and the split.
- A concise descriptive summary of the series.
- One comparison table containing the four model specifications, test RMSE, MAE, MAPE, MASE, sMAPE, and Ljung-Box p-value.
- One common test forecast-versus-actual chart for all four models.
- Optional: one small residual-diagnostic panel for the selected model.
- Rank models based on regenerated 80:20 test results.
- Explain why the winning model may perform better in terms of trend, seasonality, and serial dependence.
- Discuss whether differences are practically meaningful rather than only stating the ranking.
- Note any model with non-white residuals, unstable estimates, overly wide intervals, or implausible values.
- Clearly separate training fit, test performance, and the future 2026 forecast.

#### Group-level model selection and justification

The group report is responsible for selecting **which forecasting model family will be used for the final forecast**. It is not responsible for explaining in detail how an individual SARIMA order such as `(p,d,q)(P,D,Q)[12]` was obtained. ARIMA/SARIMA order identification, including differencing and ACF/PACF interpretation, belongs in the SARIMA member's individual report. The group report may state the final fitted order in its comparison table, but it should focus on the fair comparison of the four model families and the reason for selecting the overall winner.

The overall winner must not be chosen in advance. The Methodology section should first identify the planned candidates and lock the selection rule before the January 2021-December 2025 test observations are used:

| Planned model | Reason for including it in the group comparison |
|---|---|
| **SARIMA** | Represents autocorrelation at ordinary and annual seasonal lags, which may remain after trend and seasonality are addressed. |
| **Holt-Winters** | Provides a transparent smoothing approach for an evolving level and recurring monthly seasonal pattern, with a trend component included only when supported. |
| **ETS** | Provides a state-space framework that compares error, trend, damping, and seasonal structures and produces prediction intervals. |
| **Multiple Linear Regression (`trend` + `season`)** | Uses the numerical `trend` variable and categorical `season` indicator variables to provide an interpretable representation of long-term movement and calendar-month effects. |

Each member must determine and lock the specification of the assigned model using the January 2001-December 2020 training data only. After the four specifications are locked, every model must forecast the same 60 test observations from January 2021 to December 2025. Select the final forecasting model using the following hierarchy:

1. Treat diagnostic validity and physical plausibility as eligibility conditions. Flag a model if its residuals retain material autocorrelation, its estimates are unstable, or its forecasts or intervals contain implausible solar-irradiance values.
2. Among acceptable models, use **test RMSE as the primary ranking measure** because it penalizes larger forecast errors more heavily.
3. Use **test MAE as the secondary measure** because it expresses the typical absolute forecast error in the original unit and is less sensitive to a few large errors.
4. Use MAPE, MASE, and sMAPE as supporting measures rather than allowing one of them to override the declared RMSE/MAE rule without justification.
5. Compare prediction-interval behavior, stability, interpretability, and the size of the improvement over the next-best model. Discuss whether the difference is practically meaningful rather than only reporting ranks.
6. Do not select a numerically first-ranked model if its diagnostics or forecasts are unacceptable. If the lowest-RMSE model fails an eligibility condition, select the next defensible model and state the reason transparently.
7. After selection, refit the **locked specification** of the winning model to all 300 observations and use that refitted model for the 2026 forecast. Keep this future forecast separate from the 60-month test evaluation.

AIC or AICc may be used by an individual member to select specifications **within** a model family when the likelihoods and response treatments are comparable. Do not use AIC/AICc to rank SARIMA directly against Holt-Winters, ETS, or regression. The common out-of-sample test errors provide the group-level comparison.

**Report-ready Methodology wording:**

> SARIMA, Holt-Winters, ETS, and Multiple Linear Regression (`trend` + `season`) will be evaluated as complementary approaches to a monthly series with annual seasonality. SARIMA will represent dependence at ordinary and seasonal lags; Holt-Winters will represent evolving level and seasonal components through exponential smoothing; ETS will search error, trend, damping, and seasonal state-space structures; and Multiple Linear Regression will use numerical `trend` and categorical `season` variables. Each specification will be determined from the training period only and then locked before the common test period is evaluated. The final model will be selected primarily by test RMSE and secondarily by test MAE, subject to acceptable residual white-noise diagnostics, stable estimates, reasonable prediction intervals, and physically plausible forecasts. Empirical selections, estimates, diagnostic outcomes, and accuracy values will be reported in Data Analysis rather than Methodology.

**Report-ready Data Analysis wording (complete after regenerating the 80:20 results):**

> **[Model name]** was selected as the final forecasting model because it achieved the **[lowest/most competitive]** test RMSE of **[value]** and a test MAE of **[value]** on the common January 2021-December 2025 evaluation period. Its residuals **[were/were not]** approximately white noise according to the residual ACF and Ljung-Box test, its prediction intervals were **[appropriate description]**, and its forecasts remained physically plausible. Its RMSE was **[value or percentage]** lower than that of **[next-best model]**, indicating that the improvement was **[practically meaningful/modest]**. The model was therefore preferred because it provided the strongest overall combination of forecast accuracy, diagnostic validity, stability, and suitability for the observed trend, seasonality, and serial dependence.

Do not duplicate this full comparison in every individual report. Each individual report should instead justify why its assigned model was reasonable to test, explain how its own specification was selected from training data, and evaluate whether the evidence supports that model's suitability.

#### Conclusion, critical discussion, limitations, and recommendations

Include:

- A direct answer to the research objective and the selected overall model.
- Key regenerated accuracy evidence.
- What the result suggests about the series' trend, seasonal structure, and dependence.
- Explicit connection back to SDG 7 and its practical significance.
- Dataset limitations: gridded/satellite product, spatial resolution, monthly averaging, possible source changes, and lack of local ground-station validation.
- Forecast limitations: five-year or 60-month test horizon, model uncertainty, structural change, and limits of extrapolation.
- Engineering limitation: solar irradiance does not directly equal solar-panel electricity generation.
- Recommendations: update models regularly, validate against local observations, use higher-frequency data for operational planning, consider weather predictors, and use intervals in decisions.

#### References

- Use IEEE numbered in-text citations such as `[1]`.
- Use reliable primary/official sources: NASA POWER documentation, United Nations SDG sources, official R/package documentation, and a recognized forecasting textbook or peer-reviewed source.
- Ensure every in-text citation has a reference-list entry and vice versa.
- Use consistent access dates where required for web sources.

## 5. Individual Report Plan Shared by All Four Members

### 5.1 Mandatory format

- **Four separate reports**, one per member.
- **Maximum content length:** 2 pages, excluding cover page, references, and appendix where applicable.
- **Font:** Times New Roman, 12 pt.
- **References:** APA style.
- **Appendix:** programming source code for the member's model.
- Each report must clearly identify the member's own forecasting model and contribution.

### 5.2 Standard structure for every individual report

#### Cover page - excluded from the two-page content limit

Include:

- University/faculty/course details.
- Assignment and project title.
- Student name and ID.
- Group identifier.
- Assigned forecasting model.
- Dataset and submission date.

#### Page 1 - Methodology

Keep this proposal-stage section procedural. Dataset-design facts and prespecified rules are allowed, but all observed summaries, estimates, selected specifications, test statistics, fitted diagnostics, accuracy values, forecasts, and model rankings belong on Page 2 under Results, Discussion, and Conclusion.

Include:

- One-sentence problem and dataset context.
- Assigned model and a concise explanation of why it is a reasonable candidate for a monthly seasonal series; reserve the full four-model comparison and overall winner justification for the group report.
- Mathematical or conceptual model specification.
- Planned transformation assessment, without an estimated Box-Cox value.
- Exact 80:20 chronological split, its selection rationale, and seasonal frequency 12.
- Candidate-selection process following Steps 1-6 of the supplied workflow.
- Candidate specification and training-only selection procedure; report the selected specification and estimated parameters in Results.
- Software function and important arguments.
- Planned residual diagnostics and white-noise decision rule; report the diagnostic outcome in Results.
- Evaluation measures used.

#### Page 2 - Results, discussion, and conclusion

Include:

- A compact actual-versus-forecast figure or a model-specific diagnostic figure.
- A small table of the model's RMSE, MAE, MAPE, MASE, sMAPE, and Ljung-Box result.
- Interpretation of forecast pattern and intervals.
- Brief comparison with the other group models without duplicating the full group discussion.
- Summary of model strengths and weaknesses.
- Model-specific limitations.
- Evidence-based recommendation and possible improvement.
- A short conclusion directly answering whether the assigned model is suitable.

#### References - excluded from the two-page content limit

- Use APA in-text citations and an APA reference list.
- Cite official model documentation and at least one authoritative forecasting source.
- Cite NASA POWER and the relevant dataset documentation.

#### Appendix - excluded where applicable

- Include only the member's relevant, reproducible source code.
- Show data input, split, model fitting, diagnostics, forecasting, and metric calculation.
- Do not paste unrelated code for all four models into every appendix.
- Add comments, package names/versions, and a random-seed statement if any stochastic procedure is introduced.

## 6. Model-Specific Individual Report Requirements

### 6.1 Individual Report 1 - SARIMA

#### Methodology must include

- Definition of `(p,d,q)(P,D,Q)[12]`.
- Planned use of plots to assess trend and seasonality; report the observed patterns in Results.
- Variance/transformation assessment procedure, without an estimated lambda or empirical outcome.
- Stationarity-assessment procedure using plots and a suitable unit-root test; report the outcome in Results.
- Procedure and criteria for choosing `d` and `D`; report the chosen values in Results.
- Planned ACF/PACF assessment at ordinary and seasonal lags; report its interpretation in Results.
- Manual candidate process or complete `auto.arima()` settings.
- Candidate-order search, AICc criterion, and drift/mean rules; report the selected order, coefficients, standard errors, and AICc in Results.
- Planned residual ACF and Ljung-Box test with appropriate fitted degrees of freedom.
- Prespecified loop-back rule if residual autocorrelation remains; report whether it was triggered in Results.

#### Results and discussion must include

- 60-month test forecast and accuracy metrics.
- Forecast intervals and any physically implausible values.
- Interpretation of seasonal differencing and AR/MA effects.
- Strength: captures serial dependence and seasonal lag structure.
- Limitations: order-search uncertainty, risk of over-differencing, long-horizon uncertainty, and sensitivity to structural change.
- Recommendation: consider nearby manual orders, rolling-origin validation, transformations, or regressors if justified.

### 6.2 Individual Report 2 - Holt-Winters

#### Methodology must include

- Explanation of level, trend, and seasonal components.
- Criteria for choosing additive versus multiplicative seasonality; report the choice and evidence in Results.
- Criteria for including or damping a trend; report the fitted decision in Results.
- Parameters to be estimated (alpha, beta if used, and gamma) and the initialization method; report fitted values in Results.
- Planned interpretation of small or large smoothing values after estimation.
- Training-only optimization procedure.
- Planned residual ACF and Ljung-Box procedure; report the result in Results.
- Prespecified handling of any optimization or convergence warning; report encountered warnings in Results.

#### Results and discussion must include

- 60-month test forecast and accuracy metrics.
- Interpretation of how quickly level and seasonality adapt.
- Comparison with the other model classes.
- Strength: transparent seasonal smoothing and adaptability.
- Limitations: fixed seasonal form, possible trend extrapolation, and sensitivity to additive/multiplicative choice.
- Recommendation: test damped trend, alternative seasonality, or ETS when the basic Holt-Winters structure is restrictive.

Important current-work correction:

- The R script now sets `beta = FALSE`, while some stored specifications and results were generated before that change. Regenerate the Holt-Winters specification, metrics, diagnostics, figures, and forecasts together. Do not report stale alpha/beta/gamma values.

### 6.3 Individual Report 3 - ETS

#### Methodology must include

- Explanation of the ETS letters: error, trend, and seasonal components.
- Automatic search space and selection criterion, normally AICc.
- Candidate ETS structures and the selection rule; report the selected structure in Results only after the rerun.
- Rules for considering absent, present, or damped trend; report the selected trend form in Results.
- Parameters to be estimated (alpha, beta, gamma, and phi where applicable); report their fitted values in Results.
- Criteria for transformation and additive-only restrictions; report any applied restriction in Results.
- Explanation of how ETS differs from the classical Holt-Winters implementation.
- Planned residual ACF and Ljung-Box procedure; report the result in Results.

#### Results and discussion must include

- 60-month test forecast and common accuracy metrics.
- Interpretation of the selected error/trend/seasonal structure.
- Prediction-interval behavior.
- Strength: principled state-space model selection and probabilistic forecasting.
- Limitations: automatic choice can be difficult to explain, and multiplicative-error residuals require careful interpretation.
- Recommendation: compare automatic ETS with plausible constrained structures and persist the full final specification.

Important current-work correction:

- Use comparable response-scale forecast errors. Do not compare multiplicative ETS innovation residual errors directly with response residual errors from other models.

### 6.4 Individual Report 4 - Multiple Linear Regression (`trend + season`)

The individual report must use multiple linear regression with both a numerical time trend and categorical monthly seasonal indicators. The lack of a visually obvious trend does not by itself require the trend term to be omitted: the coefficient estimates the underlying linear movement after controlling for recurring month-to-month differences. The simple linear regression `y ~ trend` is excluded because it ignores the obvious seasonal pattern, and the season-only specification is not used for the required model comparison.

| Model | R formula | Statistical form | Justification |
|---|---|---|---|
| **Trend + season** | `y ~ trend + season` | $y_t=\beta_0+\beta_1t+\sum_{j=2}^{12}\delta_jD_{j,t}+\varepsilon_t$ | Represents long-term linear movement while controlling for the recurring monthly pattern. |

#### Required modelling procedure

1. Use the time-series plot, monthly seasonal plot or boxplot, and STL decomposition to describe the strength and direction of the trend and the monthly seasonal pattern.
2. Fit the required model to the 240-month training series:

   ```r
   trend_season <- tslm(train ~ trend + season)
   ```

3. Report adjusted $R^2$, coefficient estimates and uncertainty, and rolling-origin cross-validation with a horizon relevant to the project, especially `h = 12`.
4. Inspect the residual plot, residual ACF, and Ljung-Box result. Seasonal spikes at lags 12 or 24 indicate that the annual pattern has not been adequately represented.
5. Interpret the trend coefficient even if it is small or statistically uncertain; do not claim a strong trend unless its estimate and uncertainty support that conclusion.
6. Lock `y ~ trend + season` before using the January 2021-December 2025 test data. Use the common 60-month test period only for final evaluation.
7. If material residual autocorrelation remains, discuss Multiple Linear Regression with ARIMA errors as the next extension.

The report must include the model formula, adjusted $R^2$, training-period cross-validated RMSE and MAE, Ljung-Box p-value, and the final test-period accuracy measures. It should state clearly that the model retains the trend term while allowing the results to show that the estimated trend may be weak.

#### Methodology must include

- Equation for the trend-and-season multiple linear regression model.
- Definition of the numerical `trend` index, the categorical `season` variable, its 11 indicators, and the reference month.
- Justification for retaining both `trend` and `season` in the specified regression formula.
- Transformation assessment procedure, without an estimated lambda or empirical outcome.
- Coefficient-estimation method and key assumptions.
- Planned assessment of coefficient uncertainty without relying only on p-values; report estimates and uncertainty in Results.
- Training-period rolling-origin validation procedure; report its results in Results.
- Planned residual ACF and Ljung-Box test to assess remaining time dependence; report the outcome in Results.
- Prespecified criterion for considering regression with ARIMA errors; report the resulting decision in Results.

#### Results and discussion must include

- 60-month test forecast and common accuracy metrics.
- Interpretation of the retained trend coefficient and monthly seasonal effects.
- Explanation that simple linear regression was excluded because it cannot represent the recurring monthly pattern.
- Strength: direct interpretation of the time trend and monthly effects.
- Limitations appropriate to the selected formula, including fixed seasonal effects, fixed linear extrapolation, correlated residuals, or unrealistic long-horizon trend where relevant.
- Recommendation: consider Fourier seasonality, structural-change terms, or regression with ARIMA errors when supported by training-only validation and residual evidence.

## 7. Common Tables, Figures, and Files to Produce

### 7.1 Shared group outputs

1. Data audit table.
2. Descriptive-statistics table.
3. Complete-series plot with train-test split.
4. Seasonal/monthly distribution plot.
5. STL decomposition figure.
6. One model-specification table for all four models.
7. One common 80:20 whole-season accuracy table.
8. One residual-diagnostics table with Ljung-Box results.
9. One common 60-month forecast-versus-actual figure.
10. One future forecast table/figure if a 2026 forecast remains part of the project.

### 7.2 Individual outputs

Each member must produce:

- Final model specification and parameter table.
- Model-specific residual plot and ACF.
- Ljung-Box result.
- Model-specific test forecast table.
- Model-specific test forecast-versus-actual figure.
- Accuracy row using the group's common metric function.
- Reproducible code appendix.

### 7.3 Reproducibility files

Maintain one shared folder containing:

- Raw downloaded NASA response.
- Clean monthly dataset.
- Shared preprocessing code.
- Shared split definition.
- One model script or clearly separated script section per member.
- Combined accuracy/diagnostic CSV files.
- Final figures used in reports.
- R `sessionInfo()` or package-version record.
- A data dictionary explaining date and irradiance fields.

## 8. Required Changes to the Current Work

The existing materials are a useful foundation, but the following items must change before final submission:

1. **Replace the 92:8 split with the justified 80:20 chronological split** in the script, narrative, tables, figures, abstract, discussion, and conclusion.
2. **Regenerate every model output** using training through December 2020 and testing from January 2021 through December 2025.
3. **Do not retain the current claim that SARIMA is the winner.** Select the winner only after the complete 80:20 rerun.
4. **Regenerate Holt-Winters results after locking its specification.** Current notes warn that `beta = FALSE` was introduced after some outputs were produced.
5. **Export full fitted parameters** for ETS and SARIMA, including the final full-data refit if a 2026 forecast is produced.
6. **Use response residuals consistently** when training residual errors are compared, especially for multiplicative-error ETS.
7. **Correct Ljung-Box degrees of freedom** by using an appropriate `fitdf` or a function such as `checkresiduals()`.
8. **Apply the supplied residual white-noise loop** to all four models, not only SARIMA.
9. **Convert the group report to the official IEEE conference template.** The current report uses an IEEE-like numbered structure but must be checked against the actual template.
10. **Strengthen model-selection justification** inside each individual report instead of only listing the fitted function.
11. **Create four separate APA individual reports**; they do not yet exist as final deliverables.
12. **Keep group and individual content distinct.** The group report compares models; each individual report demonstrates deep understanding of one assigned model.
13. **Update citations and references** so the group report uses IEEE while every individual report uses APA.
14. **Verify all page limits and visual layout** after export to PDF.
15. **Replace all placeholders** for names, IDs, signatures, dates, group number, and contribution percentages.

Preliminary warning: existing split-sensitivity files contain an earlier 80:20 run, but those results are planning evidence only. They must not be pasted into the final reports because the Holt-Winters implementation and other reproducibility corrections require a complete rerun of all four models under the locked workflow.

## 9. Team Work Allocation Beyond the Four Models

To support fair peer evaluation, assign shared responsibilities in addition to the model work.

| Responsibility | Suggested owner | Required evidence |
|---|---|---|
| Data acquisition, cleaning, and audit | Member 1 with Member 4 review | Raw file, clean CSV, audit log |
| Common plotting and descriptive analysis | Member 4 with Member 2 review | Scripts and final figures |
| Shared metrics and result integration | Member 3 with Member 1 review | Common metric function and comparison CSV |
| IEEE group-report assembly and references | Member 2 with all-member review | IEEE source file/PDF and citation check |
| Final consistency and reproducibility audit | Group leader plus all members | Signed checklist and rerun confirmation |
| Presentation integration | All four members | One coherent deck and rehearsed transitions |

The cover-page percentages must reflect actual work. Keep a short contribution log with dates, tasks, outputs, and review actions.

## 10. Execution Schedule and Gates

### Phase 1 - Lock the design

- Confirm all four names/IDs and model assignments.
- Confirm the exact 80:20 dates and document the full comparison against 72:28 and exact 70:30.
- Lock variable definition, unit, frequency, metrics, and forecast horizons.
- Lock the Holt-Winters trend/seasonality specification-selection procedure.

**Gate:** No member begins final writing until the shared design is documented.

### Phase 2 - Build the common data foundation

- Re-download or verify the raw NASA data.
- Run data-quality checks.
- Create the exact training and test objects.
- Produce the shared plots and descriptive statistics.

**Gate:** All members receive identical clean data and split objects.

### Phase 3 - Complete individual model workflows

- Each member follows Steps 1-7.
- Each member records candidates, final parameters, diagnostics, and limitations.
- Each member loops back if residuals are not white noise.
- Each member exports standardized predictions and metrics.

**Gate:** A model is not ready for comparison without a saved specification, diagnostics, 90 forecasts, and metric row.

### Phase 4 - Integrate and select the overall model

- Merge all predictions by date.
- Recalculate metrics through one shared function.
- Produce the common comparison table and figure.
- Select the overall model using test RMSE, MAE, diagnostics, stability, intervals, and physical plausibility.
- Refit the locked specification on the full series if producing a 2026 forecast.

**Gate:** All reported numbers must trace to regenerated CSV files.

### Phase 5 - Write reports

- Draft the group report in IEEE format.
- Draft four individual reports in Times New Roman 12 pt with APA references.
- Keep the group report comparative and the individual reports model-specific.
- Complete code appendices.

**Gate:** Every rubric criterion is explicitly addressed.

### Phase 6 - Quality assurance and submission

- Export all five reports to PDF.
- Check page counts, figure/table legibility, captions, citations, numbering, and grammar.
- Cross-check every number against regenerated output files.
- Complete the group-report assessment-summary Excel sheet.
- Complete AI Usage Disclosure forms individually.
- Complete Peer Evaluation forms individually and keep them confidential.
- Obtain signatures and verify contribution percentages total 100%.

**Gate:** Group leader submits only after all filenames and required attachments are verified.

## 11. Rubric-Based Final Checklists

### 11.1 Group report checklist

- [ ] Problem is clearly formulated.
- [ ] Objectives are measurable.
- [ ] Dataset is recent, reliable, relevant, and sufficiently long.
- [ ] Dataset source and suitability are justified.
- [ ] SDG 7 is strongly integrated, not merely mentioned.
- [ ] Preprocessing is complete and reproducible.
- [ ] The 80:20 chronological design is justified step by step using seasonal integrity, training adequacy, test adequacy, and forecast relevance.
- [ ] All four forecasting methods are correctly explained.
- [ ] Model assumptions and diagnostics are reported.
- [ ] All models use the same test dates and metrics.
- [ ] Analysis includes effective tables, figures, and statistical evidence.
- [ ] Models are critically compared.
- [ ] Conclusion includes SDG implications, limitations, and evidence-based recommendations.
- [ ] IEEE conference template is followed consistently.
- [ ] IEEE citations and references are complete and accurate.
- [ ] Cover page contains four names, IDs, signatures, and percentages totaling 100%.
- [ ] Report does not exceed five pages.

### 11.2 Individual report checklist for each member

- [ ] Assigned model is clearly identified.
- [ ] Model specification, parameters, and implementation are technically correct.
- [ ] Model selection is justified using the supplied workflow.
- [ ] Training-only decisions are separated from test evaluation.
- [ ] Residual ACF and Ljung-Box results are interpreted.
- [ ] The white-noise loop is followed or remaining problems are disclosed.
- [ ] Test results use the common 80:20 dates and metrics.
- [ ] Results are critically interpreted, not merely displayed.
- [ ] Conclusion includes summary, model-specific limitations, and recommendations.
- [ ] APA writing, in-text citations, and references are consistent.
- [ ] Main content is no more than two pages.
- [ ] Cover page, references, and code appendix are present and separated.
- [ ] Appendix contains only relevant and reproducible code.

### 11.3 Presentation and peer-evaluation readiness

- [ ] Each member can explain the assigned model, parameters, diagnostics, and findings.
- [ ] Each member understands the whole project and why the final model was selected.
- [ ] Each member can explain why chronological splitting is required.
- [ ] Each member can answer questions about RMSE, MAE, MAPE, MASE, sMAPE, AICc, and Ljung-Box testing.
- [ ] Presentation transitions are rehearsed and coherent.
- [ ] Work is completed on time and contribution evidence is retained.

## 12. Submission Package and Naming

The group leader must collect and submit:

1. One group-report PDF.
2. Four individual-report PDFs.
3. The completed `BMMS2094 Assignment Assessment` Excel summary sheet with the group report.

Use the assignment's required naming pattern, replacing placeholders with the actual tutorial/group and student information:

- Group report: `RDS2S1G3_Group5_GroupLeaderName.pdf`
- Group assessment sheet: `RDS2S1G3_Group5_GroupLeaderName.xlsx`
- Individual report 1: `RDS2S1G3_Group5_Member1Name.pdf`
- Individual report 2: `RDS2S1G3_Group5_Member2Name.pdf`
- Individual report 3: `RDS2S1G3_Group5_Member3Name.pdf`
- Individual report 4: `RDS2S1G3_Group5_Member4Name.pdf`

Each student must also submit individually through Google Classroom:

- AI Usage Disclosure Form.
- Peer Evaluation Form for Group Work.

Peer evaluations must remain confidential between each student and the tutor.

## 13. Definition of Done

The assignment is complete only when:

- One IEEE group report and four APA individual reports exist as final PDFs.
- The entire analysis has been regenerated with the justified 80:20 chronological split using complete 12-month cycles.
- Every member has one distinct model contribution.
- The group report contains a fair common comparison of SARIMA, Holt-Winters, ETS, and Multiple Linear Regression (`trend` + `season`).
- Each individual report demonstrates deep technical understanding of its assigned model.
- Residual diagnostics and the white-noise decision loop are documented for all four models.
- All results, claims, tables, figures, and forecasts match reproducible output files.
- Page limits, formatting, citations, file names, forms, signatures, and submission attachments have all been checked.
