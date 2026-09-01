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
json_path <- file.path(raw_dir, "nasa_power_kl_solar_2001_2025.json")
if (!file.exists(json_path)) download.file(source_url, json_path, mode = "wb", quiet = FALSE)

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
train <- window(series, end = c(2023, 12))
test <- window(series, start = c(2024, 1))
test_h <- length(test)

fit_models <- function(y, h) {
  trend_fit <- tslm(y ~ trend + season)
  hw_fit <- HoltWinters(y, beta = FALSE, seasonal = "additive")
  ets_fit <- ets(y)
  arima_fit <- auto.arima(
    y, seasonal = TRUE, stepwise = FALSE,
    approximation = FALSE, allowdrift = TRUE
  )
  list(
    `Seasonal naive` = list(fit = NULL, fc = snaive(y, h = h), residuals = y - lag(y, -12)),
    `Trend + season` = list(fit = trend_fit, fc = forecast(trend_fit, h = h), residuals = residuals(trend_fit)),
    `Holt-Winters` = list(fit = hw_fit, fc = forecast(hw_fit, h = h), residuals = residuals(hw_fit)),
    ETS = list(fit = ets_fit, fc = forecast(ets_fit, h = h), residuals = residuals(ets_fit)),
    SARIMA = list(fit = arima_fit, fc = forecast(arima_fit, h = h), residuals = residuals(arima_fit))
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
# The current 24-month holdout reuses the models already fitted above.
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

test_dates <- monthly$date[monthly$date >= as.Date("2024-01-01")]
holdout_predictions <- do.call(rbind, lapply(names(models), function(nm) {
  data.frame(
    date = test_dates,
    actual = as.numeric(test),
    Model = nm,
    forecast = as.numeric(models[[nm]]$fc$mean),
    stringsAsFactors = FALSE
  )
}))
write.csv(holdout_predictions, file.path(output_dir, "nasa_holdout_predictions.csv"), row.names = FALSE)

diagnostics <- do.call(rbind, lapply(names(models), function(nm) {
  res <- as.numeric(na.omit(models[[nm]]$residuals))
  lag_value <- min(24L, max(3L, floor(length(res) / 5L)))
  test_result <- Box.test(res, lag = lag_value, type = "Ljung-Box")
  data.frame(
    Model = nm, Residual_n = length(res), Ljung_Box_lag = lag_value,
    Ljung_Box_statistic = unname(test_result$statistic),
    Ljung_Box_p_value = test_result$p.value,
    stringsAsFactors = FALSE
  )
}))
write.csv(diagnostics, file.path(output_dir, "nasa_residual_diagnostics.csv"), row.names = FALSE)

model_specs <- data.frame(
  Model = c("Seasonal naive", "Trend + season", "Holt-Winters", "ETS", "SARIMA"),
  Specification = c(
    "Forecast equals observation from 12 months earlier",
    paste(deparse(models[["Trend + season"]]$fit$call), collapse = " "),
    paste0("Additive Holt-Winters without trend; alpha=",
           round(models[["Holt-Winters"]]$fit$alpha, 4),
           ", gamma=", round(models[["Holt-Winters"]]$fit$gamma, 4)),
    as.character(models[["ETS"]]$fit),
    as.character(models[["SARIMA"]]$fit)
  ), stringsAsFactors = FALSE
)
write.csv(model_specs, file.path(output_dir, "nasa_model_specifications.csv"), row.names = FALSE)

best_model <- accuracy_table$Model[1]
full_models <- fit_models(series, 12L)
selected <- full_models[[best_model]]$fc
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
grid(col = "grey85")
boxplot(monthly$solar_irradiance ~ factor(format(monthly$date, "%b"), levels = month.abb),
        col = "#FDE7B0", border = "#A65300", xlab = "Month", ylab = "kWh/m2/day",
        main = "Month-of-year distribution")
dev.off()

png(file.path(figure_dir, "nasa_decomposition_diagnostics.png"), width = 1600, height = 1200, res = 180)
decomposition <- stl(series, s.window = "periodic", robust = TRUE)
par(mfrow = c(2, 2), mar = c(3.5, 4, 2.5, 1))
plot(decomposition$time.series[, "trend"], type = "l", col = "#A65300", lwd = 2,
     xlab = "Year", ylab = "Trend", main = "STL trend")
plot(decomposition$time.series[, "seasonal"], type = "l", col = "#D97706", lwd = 2,
     xlab = "Year", ylab = "Seasonal", main = "STL seasonal component")
plot(decomposition$time.series[, "remainder"], type = "h", col = "grey35",
     xlab = "Year", ylab = "Remainder", main = "STL remainder")
Acf(series, lag.max = 48, main = "Autocorrelation of solar irradiance")
dev.off()

model_colors <- c("#777777", "#0072B2", "#D55E00", "#009E73", "#CC79A7")
png(file.path(figure_dir, "nasa_test_forecasts.png"), width = 1800, height = 1000, res = 180)
plot(monthly$date, monthly$solar_irradiance, type = "l", lwd = 1.5, col = "black",
     xlab = "Month", ylab = "kWh/m2/day", main = "Holdout forecasts: January 2024-December 2025")
abline(v = as.Date("2024-01-01"), lty = 2, col = "grey40")
for (i in seq_along(models)) lines(test_dates, as.numeric(models[[i]]$fc$mean), col = model_colors[i], lwd = 2)
legend("topleft", legend = c("Observed", names(models)), col = c("black", model_colors),
       lty = 1, lwd = 2, cex = 0.75, bty = "n")
grid(col = "grey88")
dev.off()

png(file.path(figure_dir, "nasa_final_forecast.png"), width = 1800, height = 1000, res = 180)
plot(selected, main = paste("Selected model:", best_model),
     xlab = "Year", ylab = "kWh/m2/day", col = "#D97706")
grid(col = "grey88")
dev.off()

metadata <- payload$header
audit <- data.frame(
  Item = c("Source URL", "Latitude", "Longitude", "Parameter", "Unit", "Observations",
           "First month", "Last month", "Fill-value gaps", "Duplicate months",
           "Test observations", "Selected model"),
  Value = c(source_url, latitude, longitude, parameter, "kWh/m2/day", nrow(monthly),
            "2001-01", "2025-12", sum(is.na(monthly$solar_irradiance)),
            sum(duplicated(monthly$date)), test_h, best_model),
  stringsAsFactors = FALSE
)
write.csv(audit, file.path(output_dir, "nasa_data_audit.csv"), row.names = FALSE)

sink(file.path(output_dir, "nasa_analysis_summary.txt"))
cat("NASA POWER Kuala Lumpur solar irradiance forecasting\n")
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n")
print(audit, row.names = FALSE)
cat("\nDescriptive statistics\n"); print(descriptive, row.names = FALSE)
cat("\nAverage solar irradiance by month\n"); print(month_summary, row.names = FALSE)
cat("\nHoldout accuracy (ranked by RMSE)\n"); print(accuracy_table, row.names = FALSE)
cat("\nTraining versus test error multipliers (current 92:8 split)\n")
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
cat("\n2026 forecast\n"); print(forecast_table, row.names = FALSE)
sink()

cat("NASA analysis completed successfully. Selected model:", best_model, "\n")
