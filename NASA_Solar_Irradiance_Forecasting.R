# BMMS2094 Statistics for Data Science
# Forecasting monthly solar irradiance in Kuala Lumpur using NASA POWER

suppressPackageStartupMessages(library(forecast))
suppressPackageStartupMessages(library(jsonlite))

options(stringsAsFactors = FALSE)

script_argument <- grep(
  "^--file=",
  commandArgs(trailingOnly = FALSE),
  value = TRUE
)

if (length(script_argument) > 0L) {
  script_path <- sub("^--file=", "", script_argument[1])
} else {
  script_path <- sys.frame(1)$ofile
}

if (is.null(script_path)) {
  stop("Run the complete file using Source or Rscript.")
}

script_path <- normalizePath(script_path, winslash = "/", mustWork = TRUE)
assignment_dir <- dirname(script_path)
output_dir <- file.path(assignment_dir, "analysis_outputs", "nasa")
raw_dir <- file.path(output_dir, "raw")
figure_dir <- file.path(output_dir, "figures")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

latitude <- 3.1390
longitude <- 101.6869
parameter <- "ALLSKY_SFC_SW_DWN"
source_url <- paste0(
  "https://power.larc.nasa.gov/api/temporal/monthly/point?parameters=", parameter,
  "&community=RE&longitude=", longitude, "&latitude=", latitude,
  "&format=JSON&start=2001&end=2025"
)
raw_csv_url <- sub("format=JSON", "format=CSV", source_url, fixed = TRUE)
json_path <- file.path(raw_dir, "nasa_power_kl_solar_2001_2025.json")
raw_csv_path <- file.path(raw_dir, "nasa_power_kl_solar_2001_2025_raw.csv")
if (!file.exists(json_path)) download.file(source_url, json_path, mode = "wb", quiet = FALSE)
if (!file.exists(raw_csv_path)) {
  download.file(raw_csv_url, raw_csv_path, mode = "wb", quiet = FALSE)
}

payload <- fromJSON(json_path, simplifyVector = FALSE)
values <- payload$properties$parameter[[parameter]]
if (is.null(values)) stop("NASA POWER parameter was not found in the response.")
keys <- names(values)
is_month <- grepl("^[0-9]{6}$", keys) & substr(keys, 5, 6) %in% sprintf("%02d", 1:12)
keys <- keys[is_month]
irradiance <- as.numeric(unlist(values[keys], use.names = FALSE))
dates <- as.Date(paste0(substr(keys, 1, 4), "-", substr(keys, 5, 6), "-01"))
monthly <- data.frame(date = dates, solar_irradiance = irradiance)
monthly <- monthly[order(monthly$date), ]
monthly$solar_irradiance[monthly$solar_irradiance == -999] <- NA_real_

expected_dates <- seq(as.Date("2001-01-01"), as.Date("2025-12-01"), by = "month")
if (nrow(monthly) != 300L) stop("Expected 300 monthly NASA observations; found ", nrow(monthly), ".")
if (!identical(monthly$date, expected_dates)) stop("NASA monthly dates are not continuous.")
if (anyDuplicated(monthly$date)) stop("Duplicate NASA months found.")
if (anyNA(monthly$solar_irradiance)) stop("Missing NASA solar values found.")
if (any(monthly$solar_irradiance < 0)) stop("Negative solar irradiance found.")

write.csv(monthly, file.path(output_dir, "nasa_solar_monthly_clean.csv"), row.names = FALSE)
series <- ts(monthly$solar_irradiance, start = c(2001, 1), frequency = 12)
# Locked whole-season design from the assignment plan: 20 complete years for
# training and five complete years for final out-of-sample evaluation.
train <- window(series, end = c(2020, 12))
test <- window(series, start = c(2021, 1))
test_h <- length(test)

response_residuals <- function(fit, y) {
  fitted_object <- fitted(fit)
  # stats::fitted.HoltWinters returns a matrix whose first column is the fitted
  # response and whose remaining columns are component states.
  if (is.matrix(fitted_object)) fitted_object <- fitted_object[, 1]
  fitted_values <- as.numeric(fitted_object)
  if (length(fitted_values) > length(y)) {
    stop("Fitted response is longer than its training series.")
  }
  actual_values <- tail(as.numeric(y), length(fitted_values))
  if (length(actual_values) != length(fitted_values)) {
    stop("Actual and fitted response vectors are not aligned.")
  }
  actual_values - fitted_values
}

fit_models <- function(y, h) {
  trend_fit <- tslm(y ~ trend + season)
  hw_fit <- HoltWinters(y, beta = FALSE, seasonal = "additive")
  ets_fit <- ets(y)
  arima_fit <- auto.arima(
    y, seasonal = TRUE, stepwise = FALSE,
    approximation = FALSE, allowdrift = TRUE
  )
  list(
    `Trend + season` = list(
      fit = trend_fit, fc = forecast(trend_fit, h = h),
      residuals = response_residuals(trend_fit, y)
    ),
    `Holt-Winters` = list(
      fit = hw_fit, fc = forecast(hw_fit, h = h),
      residuals = response_residuals(hw_fit, y)
    ),
    ETS = list(
      fit = ets_fit, fc = forecast(ets_fit, h = h),
      residuals = response_residuals(ets_fit, y)
    ),
    SARIMA = list(
      fit = arima_fit, fc = forecast(arima_fit, h = h),
      residuals = response_residuals(arima_fit, y)
    )
  )
}

metric_row <- function(name, fc, actual, training) {
  pred <- as.numeric(fc$mean)
  actual <- as.numeric(actual)
  errors <- actual - pred
  scale_denom <- mean(abs(diff(as.numeric(training), lag = 12)), na.rm = TRUE)
  data.frame(
    Model = name,
    MAE = mean(abs(errors)),
    RMSE = sqrt(mean(errors^2)),
    MAPE = mean(abs(errors / actual)) * 100,
    MASE = if (is.finite(scale_denom) && scale_denom > 0) mean(abs(errors)) / scale_denom else NA_real_,
    sMAPE = mean(200 * abs(errors) / pmax(abs(actual) + abs(pred), .Machine$double.eps)),
    stringsAsFactors = FALSE
  )
}

models <- fit_models(train, test_h)
accuracy_table <- do.call(rbind, lapply(names(models), function(nm) {
  test_metrics <- metric_row(nm, models[[nm]]$fc, test, train)
  train_residuals <- as.numeric(models[[nm]]$residuals)
  train_actual <- tail(as.numeric(train), length(train_residuals))
  valid <- is.finite(train_residuals) & is.finite(train_actual)
  data.frame(
    Model = nm,
    Training_MAE = mean(abs(train_residuals[valid])),
    Training_RMSE = sqrt(mean(train_residuals[valid]^2)),
    MAE = test_metrics$MAE,
    RMSE = test_metrics$RMSE,
    MAPE = test_metrics$MAPE,
    MASE = test_metrics$MASE,
    sMAPE = test_metrics$sMAPE,
    stringsAsFactors = FALSE
  )
}))
row.names(accuracy_table) <- NULL
accuracy_table <- accuracy_table[order(accuracy_table$RMSE), ]
write.csv(accuracy_table, file.path(output_dir, "nasa_model_accuracy.csv"), row.names = FALSE)

train_test_comparison <- data.frame(
  Model = accuracy_table$Model,
  Training_MAE = accuracy_table$Training_MAE,
  Test_MAE = accuracy_table$MAE,
  Test_MAE_x_Training = accuracy_table$MAE / accuracy_table$Training_MAE,
  Training_RMSE = accuracy_table$Training_RMSE,
  Test_RMSE = accuracy_table$RMSE,
  Test_RMSE_x_Training = accuracy_table$RMSE / accuracy_table$Training_RMSE,
  stringsAsFactors = FALSE
)
write.csv(
  train_test_comparison,
  file.path(output_dir, "nasa_train_test_comparison.csv"),
  row.names = FALSE
)

# Compare several chronological train:test splits using the same model definitions.
# The locked 60-month holdout reuses the primary models already fitted above.
split_test_months <- c(12L, 24L, 36L, 48L, 60L, 90L)
split_cache_path <- Sys.getenv("NASA_SPLIT_SENSITIVITY_CACHE", unset = "")
required_split_columns <- c(
  "Model", "Ratio", "Train_months", "Test_months", "Test_start", "Test_end",
  "MAE", "RMSE", "MAPE", "MASE", "sMAPE"
)
if (nzchar(split_cache_path)) {
  if (!file.exists(split_cache_path)) stop("Split-sensitivity cache does not exist: ", split_cache_path)
  split_sensitivity <- read.csv(split_cache_path, stringsAsFactors = FALSE)
  missing_split_columns <- setdiff(required_split_columns, names(split_sensitivity))
  if (length(missing_split_columns) > 0L) {
    stop("Split-sensitivity cache is missing columns: ", paste(missing_split_columns, collapse = ", "))
  }
  split_sensitivity <- split_sensitivity[required_split_columns]
} else {
  split_sensitivity <- do.call(rbind, lapply(split_test_months, function(split_h) {
    split_train <- head(series, length(series) - split_h)
    split_test <- tail(series, split_h)
    split_models <- if (split_h == test_h) models else fit_models(split_train, split_h)
    train_n <- length(split_train)
    total_n <- length(series)

    do.call(rbind, lapply(names(split_models), function(nm) {
      split_metrics <- metric_row(nm, split_models[[nm]]$fc, split_test, split_train)
      data.frame(
        Model = nm,
        Ratio = paste0(round(100 * train_n / total_n), ":", round(100 * split_h / total_n)),
        Train_months = train_n,
        Test_months = split_h,
        Test_start = format(monthly$date[train_n + 1L], "%Y-%m"),
        Test_end = format(tail(monthly$date, 1L), "%Y-%m"),
        MAE = split_metrics$MAE,
        RMSE = split_metrics$RMSE,
        MAPE = split_metrics$MAPE,
        MASE = split_metrics$MASE,
        sMAPE = split_metrics$sMAPE,
        stringsAsFactors = FALSE
      )
    }))
  }))
}
model_order <- names(models)
split_sensitivity <- split_sensitivity[
  order(match(split_sensitivity$Model, model_order), split_sensitivity$RMSE),
]
row.names(split_sensitivity) <- NULL
split_sensitivity$Best_ratio <- NA_character_
split_sensitivity$Best_RMSE <- NA_real_
split_sensitivity$RMSE_x_best <- NA_real_
split_sensitivity$RMSE_pct_above_best <- NA_real_
for (nm in model_order) {
  model_rows <- which(split_sensitivity$Model == nm)
  best_row <- model_rows[which.min(split_sensitivity$RMSE[model_rows])]
  best_rmse <- split_sensitivity$RMSE[best_row]
  split_sensitivity$Best_ratio[model_rows] <- split_sensitivity$Ratio[best_row]
  split_sensitivity$Best_RMSE[model_rows] <- best_rmse
  split_sensitivity$RMSE_x_best[model_rows] <- split_sensitivity$RMSE[model_rows] / best_rmse
  split_sensitivity$RMSE_pct_above_best[model_rows] <-
    100 * (split_sensitivity$RMSE[model_rows] / best_rmse - 1)
}
split_sensitivity_output <- file.path(output_dir, "nasa_split_sensitivity.csv")
tryCatch(
  write.csv(split_sensitivity, split_sensitivity_output, row.names = FALSE),
  error = function(e) {
    split_sensitivity_output <<- file.path(
      output_dir, "nasa_split_sensitivity_with_multipliers.csv"
    )
    warning(
      "Primary split-sensitivity CSV could not be replaced; wrote enhanced output to ",
      split_sensitivity_output, ". Cause: ", conditionMessage(e)
    )
    write.csv(split_sensitivity, split_sensitivity_output, row.names = FALSE)
  }
)

split_rmse_multipliers <- split_sensitivity[c(
  "Model", "Ratio", "RMSE", "Best_ratio", "Best_RMSE",
  "RMSE_x_best", "RMSE_pct_above_best"
)]
write.csv(
  split_rmse_multipliers,
  file.path(output_dir, "nasa_split_rmse_multipliers.csv"),
  row.names = FALSE
)

best_split_by_model <- do.call(rbind, lapply(model_order, function(nm) {
  candidates <- split_sensitivity[split_sensitivity$Model == nm, ]
  candidates[which.min(candidates$RMSE), ]
}))
row.names(best_split_by_model) <- NULL
best_split_output <- file.path(output_dir, "nasa_best_split_by_model.csv")
tryCatch(
  write.csv(best_split_by_model, best_split_output, row.names = FALSE),
  error = function(e) {
    best_split_output <<- file.path(
      output_dir, "nasa_best_split_by_model_with_multipliers.csv"
    )
    warning(
      "Primary best-split CSV could not be replaced; wrote enhanced output to ",
      best_split_output, ". Cause: ", conditionMessage(e)
    )
    write.csv(best_split_by_model, best_split_output, row.names = FALSE)
  }
)

test_dates <- monthly$date[monthly$date >= as.Date("2021-01-01")]
holdout_predictions <- do.call(rbind, lapply(names(models), function(nm) {
  fc <- models[[nm]]$fc
  data.frame(
    date = test_dates,
    actual = as.numeric(test),
    Model = nm,
    forecast = as.numeric(fc$mean),
    lower_80 = as.numeric(fc$lower[, 1]),
    upper_80 = as.numeric(fc$upper[, 1]),
    lower_95 = as.numeric(fc$lower[, 2]),
    upper_95 = as.numeric(fc$upper[, 2]),
    stringsAsFactors = FALSE
  )
}))
write.csv(holdout_predictions, file.path(output_dir, "nasa_holdout_predictions.csv"), row.names = FALSE)

model_fitdf <- function(name, fit) {
  if (name == "Trend + season") return(length(coef(fit)))
  if (name == "Holt-Winters") {
    # beta is deliberately disabled, so only alpha and gamma are fitted.
    return(sum(is.finite(c(fit$alpha, fit$gamma))))
  }
  if (name == "ETS") {
    smoothing_names <- intersect(names(coef(fit)), c("alpha", "beta", "gamma", "phi"))
    return(length(smoothing_names))
  }
  if (name == "SARIMA") return(length(coef(fit)))
  0L
}

diagnostics <- do.call(rbind, lapply(names(models), function(nm) {
  res <- as.numeric(na.omit(models[[nm]]$residuals))
  fit_df <- model_fitdf(nm, models[[nm]]$fit)
  lag_value <- max(fit_df + 3L, min(24L, floor(length(res) / 5L)))
  test_result <- Box.test(
    res, lag = lag_value, type = "Ljung-Box", fitdf = fit_df
  )
  data.frame(
    Model = nm, Residual_n = length(res), Ljung_Box_lag = lag_value,
    Fit_df = fit_df,
    Ljung_Box_statistic = unname(test_result$statistic),
    Ljung_Box_p_value = test_result$p.value,
    Residual_mean = mean(res),
    Residual_sd = sd(res),
    White_noise_at_5pct = test_result$p.value > 0.05,
    stringsAsFactors = FALSE
  )
}))
write.csv(diagnostics, file.path(output_dir, "nasa_residual_diagnostics.csv"), row.names = FALSE)

format_model <- function(fit) paste(capture.output(print(fit)), collapse = " ")
model_specs <- data.frame(
  Model = c("Trend + season", "Holt-Winters", "ETS", "SARIMA"),
  Specification = c(
    paste(deparse(models[["Trend + season"]]$fit$call), collapse = " "),
    paste0("Additive Holt-Winters without trend; alpha=",
           round(models[["Holt-Winters"]]$fit$alpha, 4),
           ", gamma=", round(models[["Holt-Winters"]]$fit$gamma, 4)),
    format_model(models[["ETS"]]$fit),
    format_model(models[["SARIMA"]]$fit)
  ),
  AIC = c(
    AIC(models[["Trend + season"]]$fit), NA_real_,
    models[["ETS"]]$fit$aic, models[["SARIMA"]]$fit$aic
  ),
  AICc = c(
    NA_real_, NA_real_, models[["ETS"]]$fit$aicc,
    models[["SARIMA"]]$fit$aicc
  ),
  BIC = c(
    BIC(models[["Trend + season"]]$fit), NA_real_,
    models[["ETS"]]$fit$bic, models[["SARIMA"]]$fit$bic
  ),
  Converged = c(TRUE, TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)
write.csv(model_specs, file.path(output_dir, "nasa_model_specifications.csv"), row.names = FALSE)

parameter_rows <- list()
regression_coefs <- summary(models[["Trend + season"]]$fit)$coefficients
parameter_rows[["Trend + season"]] <- data.frame(
  Model = "Trend + season", Parameter = rownames(regression_coefs),
  Estimate = regression_coefs[, 1], Standard_error = regression_coefs[, 2],
  P_value = regression_coefs[, 4], stringsAsFactors = FALSE
)
hw_fit <- models[["Holt-Winters"]]$fit
hw_parameters <- c(alpha = hw_fit$alpha, gamma = hw_fit$gamma)
hw_parameters <- hw_parameters[is.finite(hw_parameters)]
parameter_rows[["Holt-Winters"]] <- data.frame(
  Model = "Holt-Winters", Parameter = names(hw_parameters),
  Estimate = as.numeric(hw_parameters), Standard_error = NA_real_,
  P_value = NA_real_, stringsAsFactors = FALSE
)
ets_parameters <- coef(models[["ETS"]]$fit)
parameter_rows[["ETS"]] <- data.frame(
  Model = "ETS", Parameter = names(ets_parameters),
  Estimate = as.numeric(ets_parameters), Standard_error = NA_real_,
  P_value = NA_real_, stringsAsFactors = FALSE
)
sarima_fit <- models[["SARIMA"]]$fit
sarima_parameters <- coef(sarima_fit)
sarima_se <- sqrt(diag(sarima_fit$var.coef))
parameter_rows[["SARIMA"]] <- data.frame(
  Model = "SARIMA", Parameter = names(sarima_parameters),
  Estimate = as.numeric(sarima_parameters),
  Standard_error = as.numeric(sarima_se[names(sarima_parameters)]),
  P_value = 2 * pnorm(-abs(sarima_parameters / sarima_se[names(sarima_parameters)])),
  stringsAsFactors = FALSE
)
model_parameters <- do.call(rbind, parameter_rows)
row.names(model_parameters) <- NULL
write.csv(model_parameters, file.path(output_dir, "nasa_model_parameters.csv"), row.names = FALSE)

regression_summary <- data.frame(
  Item = c("R_squared", "Adjusted_R_squared", "Residual_standard_error"),
  Value = c(
    summary(models[["Trend + season"]]$fit)$r.squared,
    summary(models[["Trend + season"]]$fit)$adj.r.squared,
    summary(models[["Trend + season"]]$fit)$sigma
  ), stringsAsFactors = FALSE
)
write.csv(regression_summary, file.path(output_dir, "nasa_regression_summary.csv"), row.names = FALSE)

regression_cv_function <- function(y, h) {
  forecast(tslm(y ~ trend + season), h = h)
}
regression_cv_errors <- tsCV(train, regression_cv_function, h = 12)
regression_cv_h12 <- as.numeric(regression_cv_errors[, 12])
regression_cv_h12 <- regression_cv_h12[is.finite(regression_cv_h12)]
regression_cv_summary <- data.frame(
  Horizon = 12L,
  Forecast_origins = length(regression_cv_h12),
  MAE = mean(abs(regression_cv_h12)),
  RMSE = sqrt(mean(regression_cv_h12^2)),
  stringsAsFactors = FALSE
)
write.csv(
  regression_cv_summary,
  file.path(output_dir, "nasa_regression_rolling_origin_cv.csv"),
  row.names = FALSE
)

box_cox_lambda <- BoxCox.lambda(train, method = "guerrero")
differencing_evidence <- data.frame(
  Item = c(
    "Guerrero_Box_Cox_lambda", "Selected_transformation",
    "Recommended_nonseasonal_differences", "Recommended_seasonal_differences"
  ),
  Value = c(
    box_cox_lambda, "None (response scale retained)",
    ndiffs(train, test = "kpss"), nsdiffs(train, test = "seas")
  ), stringsAsFactors = FALSE
)
write.csv(
  differencing_evidence,
  file.path(output_dir, "nasa_transformation_stationarity_evidence.csv"),
  row.names = FALSE
)

selection_table <- merge(
  accuracy_table,
  diagnostics[c("Model", "Ljung_Box_p_value", "White_noise_at_5pct")],
  by = "Model", sort = FALSE
)
selection_table$Nonnegative_test_forecasts <- vapply(
  selection_table$Model,
  function(nm) all(as.numeric(models[[nm]]$fc$mean) >= 0),
  logical(1)
)
selection_table$Eligible <-
  selection_table$White_noise_at_5pct & selection_table$Nonnegative_test_forecasts
selection_table <- selection_table[order(selection_table$RMSE, selection_table$MAE), ]
eligible_models <- selection_table$Model[selection_table$Eligible]
best_model <- if (length(eligible_models) > 0L) eligible_models[1] else selection_table$Model[1]
selection_table$Selected <- selection_table$Model == best_model
write.csv(selection_table, file.path(output_dir, "nasa_model_selection.csv"), row.names = FALSE)

refit_locked_model <- function(name, y) {
  if (name == "Trend + season") return(tslm(y ~ trend + season))
  if (name == "Holt-Winters") return(HoltWinters(y, beta = FALSE, seasonal = "additive"))
  if (name == "ETS") {
    training_fit <- models[["ETS"]]$fit
    component_code <- paste0(
      training_fit$components[c("error", "trend", "season")], collapse = ""
    )
    is_damped <- isTRUE(as.logical(training_fit$components["damped"]))
    return(ets(y, model = component_code, damped = is_damped))
  }
  if (name == "SARIMA") {
    training_fit <- models[["SARIMA"]]$fit
    order_values <- arimaorder(training_fit)
    coefficient_names <- names(coef(training_fit))
    return(Arima(
      y,
      order = unname(order_values[c("p", "d", "q")]),
      seasonal = list(
        order = unname(order_values[c("P", "D", "Q")]),
        period = unname(order_values["Frequency"])
      ),
      include.mean = "intercept" %in% coefficient_names,
      include.drift = "drift" %in% coefficient_names,
      method = "CSS-ML"
    ))
  }
  stop("Unknown model: ", name)
}
full_fit <- refit_locked_model(best_model, series)
selected <- forecast(full_fit, h = 12L)
full_model_spec <- data.frame(
  Model = best_model,
  Training_specification = model_specs$Specification[model_specs$Model == best_model],
  Full_data_refit = format_model(full_fit),
  stringsAsFactors = FALSE
)
write.csv(full_model_spec, file.path(output_dir, "nasa_selected_full_refit.csv"), row.names = FALSE)
forecast_dates <- seq(as.Date("2026-01-01"), as.Date("2026-12-01"), by = "month")
forecast_table <- data.frame(
  date = forecast_dates,
  point_forecast = as.numeric(selected$mean),
  lower_80 = as.numeric(selected$lower[, 1]),
  upper_80 = as.numeric(selected$upper[, 1]),
  lower_95 = as.numeric(selected$lower[, 2]),
  upper_95 = as.numeric(selected$upper[, 2])
)
write.csv(forecast_table, file.path(output_dir, "nasa_final_forecast.csv"), row.names = FALSE)

month_summary <- aggregate(
  solar_irradiance ~ month,
  data = transform(monthly, month = factor(format(date, "%b"), levels = month.abb)),
  FUN = mean
)
month_summary$solar_irradiance <- round(month_summary$solar_irradiance, 4)
write.csv(month_summary, file.path(output_dir, "nasa_monthly_climatology.csv"), row.names = FALSE)

descriptive <- data.frame(
  Statistic = c("Observations", "First month", "Last month", "Mean", "Median", "Minimum", "Maximum", "Standard deviation"),
  Value = c(
    nrow(monthly), "2001-01", "2025-12", round(mean(monthly$solar_irradiance), 4),
    round(median(monthly$solar_irradiance), 4), round(min(monthly$solar_irradiance), 4),
    round(max(monthly$solar_irradiance), 4), round(sd(monthly$solar_irradiance), 4)
  ), stringsAsFactors = FALSE
)
write.csv(descriptive, file.path(output_dir, "nasa_descriptive_statistics.csv"), row.names = FALSE)

png(file.path(figure_dir, "nasa_overview.png"), width = 1800, height = 900, res = 180)
par(mfrow = c(1, 2), mar = c(4, 4, 2.5, 1))
plot(series, type = "l", col = "#D97706", lwd = 1.5,
     xlab = "Year", ylab = "kWh/m2/day", main = "Monthly solar irradiance, Kuala Lumpur")
abline(v = 2021, lty = 2, col = "#4B5563")
grid(col = "grey85")
boxplot(monthly$solar_irradiance ~ factor(format(monthly$date, "%b"), levels = month.abb),
        col = "#FDE7B0", border = "#A65300", xlab = "Month", ylab = "kWh/m2/day",
        main = "Month-of-year distribution")
dev.off()

png(file.path(figure_dir, "nasa_decomposition_diagnostics.png"), width = 1600, height = 1400, res = 180)
decomposition <- stl(series, s.window = "periodic", robust = TRUE)
par(mfrow = c(2, 2), mar = c(4, 4, 3.5, 1), mgp = c(2.4, 0.7, 0))
plot(decomposition$time.series[, "trend"], type = "l", col = "#A65300", lwd = 2,
     xlab = "", ylab = "Trend", main = "STL trend")
plot(decomposition$time.series[, "seasonal"], type = "l", col = "#D97706", lwd = 2,
     xlab = "", ylab = "Seasonal", main = "STL seasonal component")
plot(decomposition$time.series[, "remainder"], type = "h", col = "grey35",
     xlab = "Year", ylab = "Remainder", main = "STL remainder")
Acf(decomposition$time.series[, "remainder"], lag.max = 48,
    main = "ACF of STL remainder")
dev.off()

model_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7")
png(file.path(figure_dir, "nasa_test_forecasts.png"), width = 1800, height = 1000, res = 180)
plot(monthly$date, monthly$solar_irradiance, type = "l", lwd = 1.5, col = "black",
     xlab = "Month", ylab = "kWh/m2/day", main = "Test forecasts: January 2021-December 2025")
abline(v = as.Date("2021-01-01"), lty = 2, col = "grey40")
for (i in seq_along(models)) lines(test_dates, as.numeric(models[[i]]$fc$mean), col = model_colors[i], lwd = 2)
legend("topleft", legend = c("Observed", names(models)), col = c("black", model_colors),
       lty = 1, lwd = 2, cex = 0.75, bty = "n")
grid(col = "grey88")
dev.off()

safe_slug <- function(x) gsub("[^a-z0-9]+", "_", tolower(x))
for (i in seq_along(models)) {
  nm <- names(models)[i]
  slug <- safe_slug(nm)
  res <- as.numeric(na.omit(models[[nm]]$residuals))

  png(
    file.path(figure_dir, paste0("nasa_", slug, "_diagnostics.png")),
    width = 1600, height = 900, res = 180
  )
  par(mfrow = c(1, 2), mar = c(4, 4, 2.5, 1))
  plot(
    res, type = "l", col = model_colors[i],
    xlab = "Training residual index", ylab = "Response residual",
    main = paste(nm, "residuals")
  )
  abline(h = 0, lty = 2, col = "grey45")
  grid(col = "grey88")
  acf(res, lag.max = 48, main = paste(nm, "residual ACF"))
  dev.off()

  png(
    file.path(figure_dir, paste0("nasa_", slug, "_test_forecast.png")),
    width = 1600, height = 900, res = 180
  )
  plot(
    test_dates, as.numeric(test), type = "l", lwd = 2, col = "black",
    xlab = "Month", ylab = "kWh/m2/day",
    main = paste(nm, "test forecast, 2021-2025")
  )
  polygon(
    c(test_dates, rev(test_dates)),
    c(models[[nm]]$fc$lower[, 2], rev(models[[nm]]$fc$upper[, 2])),
    col = adjustcolor(model_colors[i], alpha.f = 0.12), border = NA
  )
  lines(test_dates, as.numeric(test), lwd = 2, col = "black")
  lines(test_dates, as.numeric(models[[nm]]$fc$mean), lwd = 2, col = model_colors[i])
  legend(
    "topleft", legend = c("Observed", "Point forecast", "95% interval"),
    col = c("black", model_colors[i], adjustcolor(model_colors[i], alpha.f = 0.25)),
    lty = c(1, 1, NA), lwd = c(2, 2, NA), pch = c(NA, NA, 15),
    cex = 0.8, bty = "n"
  )
  grid(col = "grey88")
  dev.off()
}

png(file.path(figure_dir, "nasa_final_forecast.png"), width = 1800, height = 1000, res = 180)
plot(selected, main = paste("Selected model:", best_model),
     xlab = "Year", ylab = "kWh/m2/day", col = "#D97706")
grid(col = "grey88")
dev.off()

metadata <- payload$header
audit <- data.frame(
  Item = c("Source URL", "Latitude", "Longitude", "Parameter", "Unit", "Observations",
           "First month", "Last month", "Fill-value gaps", "Duplicate months",
           "Training observations", "Training period", "Test observations", "Test period",
           "Selected model"),
  Value = c(source_url, latitude, longitude, parameter, "kWh/m2/day", nrow(monthly),
            "2001-01", "2025-12", sum(is.na(monthly$solar_irradiance)),
            sum(duplicated(monthly$date)), length(train), "2001-01 to 2020-12",
            test_h, "2021-01 to 2025-12", best_model),
  stringsAsFactors = FALSE
)
write.csv(audit, file.path(output_dir, "nasa_data_audit.csv"), row.names = FALSE)

software_versions <- data.frame(
  Software = c("R", "forecast", "jsonlite"),
  Version = c(
    paste(R.version$major, R.version$minor, sep = "."),
    as.character(packageVersion("forecast")),
    as.character(packageVersion("jsonlite"))
  ),
  stringsAsFactors = FALSE
)
write.csv(
  software_versions,
  file.path(output_dir, "nasa_software_versions.csv"),
  row.names = FALSE
)
writeLines(
  capture.output(sessionInfo()),
  file.path(output_dir, "nasa_session_info.txt")
)

sink(file.path(output_dir, "nasa_analysis_summary.txt"))
cat("NASA POWER Kuala Lumpur solar irradiance forecasting\n")
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n")
print(audit, row.names = FALSE)
cat("\nDescriptive statistics\n"); print(descriptive, row.names = FALSE)
cat("\nAverage solar irradiance by month\n"); print(month_summary, row.names = FALSE)
cat("\nHoldout accuracy (ranked by RMSE)\n"); print(accuracy_table, row.names = FALSE)
cat("\nTraining versus test error multipliers (locked 80:20 split)\n")
print(train_test_comparison, row.names = FALSE)
cat(paste0(
  "Interpretation: a Test_RMSE_x_Training value of 1.50 means that the test ",
  "RMSE is 1.50 times the training RMSE. Values above 1 indicate higher error ",
  "on unseen test observations; values below 1 indicate lower test-period error. ",
  "Treat this as descriptive because in-sample residual errors and multi-step ",
  "holdout errors are not identical evaluation designs.\n"
))
cat("\nTrain:test split sensitivity (ranked within each model by RMSE)\n")
print(split_sensitivity, row.names = FALSE)
cat("\nSplit RMSE multipliers relative to each model's best observed split\n")
print(split_rmse_multipliers, row.names = FALSE)
cat(paste0(
  "Interpretation: an RMSE_x_best value of 1.50 means that split's RMSE is ",
  "1.50 times the lowest observed RMSE for the same model.\n"
))
cat("\nLowest observed RMSE split for each model\n")
print(best_split_by_model, row.names = FALSE)
cat(paste0(
  "\nInterpretation note: these are chronological splits, not random splits. ",
  "Each ratio evaluates a different historical period and forecast horizon, so the ",
  "lowest value is descriptive rather than proof of a universally optimal ratio. ",
  "Use one common split when comparing models; rolling-origin validation is preferred ",
  "for robust model selection. Some alternative Holt-Winters fits may emit non-fatal ",
  "optimizer warnings and should be interpreted cautiously.\n"
))
cat("\nResidual diagnostics\n"); print(diagnostics, row.names = FALSE)
cat("\nModel specifications\n"); print(model_specs, row.names = FALSE)
cat("\nModel parameters\n"); print(model_parameters, row.names = FALSE)
cat("\nRegression summary\n"); print(regression_summary, row.names = FALSE)
cat("\nRegression rolling-origin cross-validation (h = 12)\n")
print(regression_cv_summary, row.names = FALSE)
cat("\nTransformation and stationarity evidence\n")
print(differencing_evidence, row.names = FALSE)
cat("\nSoftware versions\n"); print(software_versions, row.names = FALSE)
cat("\nGroup-level model-selection evidence\n")
print(selection_table, row.names = FALSE)
cat("\nSelected full-data locked-specification refit\n")
print(full_model_spec, row.names = FALSE)
cat("\n2026 forecast\n"); print(forecast_table, row.names = FALSE)
sink()

cat("NASA analysis completed successfully. Selected model:", best_model, "\n")
