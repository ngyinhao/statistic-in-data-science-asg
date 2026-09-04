"""Fit and audit the Basic Structural Model used in the NASA group report.

The script is intentionally additive: it reads the already-audited monthly NASA
series and the existing three-model evidence, then replaces only the retired
trend-and-season rows when ``--apply`` is supplied.  Without ``--apply`` it
prints the fitted BSM evidence and does not write files.
"""

from __future__ import annotations

import argparse
import json
import sys
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
import statsmodels
from scipy.sparse import SparseEfficiencyWarning
from statsmodels.stats.diagnostic import acorr_ljungbox
from statsmodels.tsa.statespace.structural import UnobservedComponents


ROOT = Path(__file__).resolve().parent
OUTPUT_DIR = ROOT / "analysis_outputs" / "nasa"
MODEL_NAME = "Basic structural model"
RETIRED_MODEL = "Trend + season"


def fit_bsm(values: pd.Series):
    """Fit the pre-declared local-level plus seasonal structural model."""
    model = UnobservedComponents(
        values.astype(float),
        level=True,
        stochastic_level=True,
        seasonal=12,
        irregular=True,
        use_exact_diffuse=True,
    )
    # Powell gives stable variance estimates for this short monthly series;
    # L-BFGS then refines the same likelihood solution.
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", SparseEfficiencyWarning)
        initial = model.fit(method="powell", maxiter=2000, disp=False)
    return model.fit(
        start_params=initial.params,
        method="lbfgs",
        maxiter=2000,
        disp=False,
    )


def metrics(actual: np.ndarray, predicted: np.ndarray) -> dict[str, float]:
    errors = actual - predicted
    percentage_errors = errors / actual
    return {
        "ME": float(np.mean(errors)),
        "MSE": float(np.mean(errors**2)),
        "RMSE": float(np.sqrt(np.mean(errors**2))),
        "MAE": float(np.mean(np.abs(errors))),
        "MPE": float(np.mean(percentage_errors) * 100),
        "MAPE": float(np.mean(np.abs(percentage_errors)) * 100),
    }


def model_evidence(monthly: pd.DataFrame) -> dict:
    train = monthly.loc[monthly["date"] < "2021-01-01"].copy()
    test = monthly.loc[monthly["date"] >= "2021-01-01"].copy()
    if len(train) != 240 or len(test) != 60:
        raise ValueError(f"Expected a 240/60 split; found {len(train)}/{len(test)}")

    fit = fit_bsm(train["solar_irradiance"])
    forecast = fit.get_forecast(steps=len(test))
    forecast_mean = np.asarray(forecast.predicted_mean, dtype=float)
    forecast_ci = np.asarray(forecast.conf_int(alpha=0.05), dtype=float)
    forecast_ci80 = np.asarray(forecast.conf_int(alpha=0.20), dtype=float)

    fitted = np.asarray(fit.fittedvalues, dtype=float)
    actual_train = train["solar_irradiance"].to_numpy(dtype=float)
    # A structural seasonal model has diffuse initial states.  Exclude the
    # first complete seasonal cycle from in-sample accuracy and diagnostics.
    initialization_months = max(12, int(getattr(fit, "nobs_diffuse", 0)))
    usable = (
        np.arange(len(actual_train)) >= initialization_months
    ) & np.isfinite(fitted)
    residuals = actual_train[usable] - fitted[usable]
    parameter_count = len(fit.params)
    lb = acorr_ljungbox(
        residuals,
        lags=[24],
        model_df=parameter_count,
        return_df=True,
    ).iloc[0]

    test_metrics = metrics(test["solar_irradiance"].to_numpy(dtype=float), forecast_mean)
    training_metrics = metrics(actual_train[usable], fitted[usable])
    converged = bool(fit.mle_retvals.get("converged", False))

    return {
        "fit": fit,
        "train": train,
        "test": test,
        "forecast_mean": forecast_mean,
        "forecast_ci80": forecast_ci80,
        "forecast_ci95": forecast_ci,
        "residuals": residuals,
        "initialization_months": initialization_months,
        "parameter_count": parameter_count,
        "training_metrics": training_metrics,
        "test_metrics": test_metrics,
        "ljung_box_statistic": float(lb["lb_stat"]),
        "ljung_box_p_value": float(lb["lb_pvalue"]),
        "converged": converged,
        "nonnegative": bool(np.all(forecast_mean >= 0)),
    }


def replace_model_row(path: Path, row: dict, preferred_order: list[str]) -> None:
    table = pd.read_csv(path)
    table = table.loc[~table["Model"].isin([RETIRED_MODEL, MODEL_NAME])].copy()
    table = pd.concat([table, pd.DataFrame([row])], ignore_index=True)
    order = {name: index for index, name in enumerate(preferred_order)}
    table["_order"] = table["Model"].map(order).fillna(len(order))
    table = table.sort_values("_order").drop(columns="_order")
    table.to_csv(path, index=False)


def apply_updates(evidence: dict) -> None:
    fit = evidence["fit"]
    training = evidence["training_metrics"]
    testing = evidence["test_metrics"]
    order = ["SARIMA", "ETS", MODEL_NAME, "Holt-Winters"]

    accuracy_row = {"Model": MODEL_NAME}
    accuracy_row.update({f"Training_{key}": value for key, value in training.items()})
    accuracy_row.update(testing)
    replace_model_row(OUTPUT_DIR / "nasa_model_accuracy.csv", accuracy_row, order)

    diagnostics_row = {
        "Model": MODEL_NAME,
        "Residual_n": len(evidence["residuals"]),
        "Ljung_Box_lag": 24,
        "Fit_df": evidence["parameter_count"],
        "Ljung_Box_statistic": evidence["ljung_box_statistic"],
        "Ljung_Box_p_value": evidence["ljung_box_p_value"],
        "Residual_mean": float(np.mean(evidence["residuals"])),
        "Residual_sd": float(np.std(evidence["residuals"], ddof=1)),
        "White_noise_at_5pct": evidence["ljung_box_p_value"] > 0.05,
    }
    replace_model_row(OUTPUT_DIR / "nasa_residual_diagnostics.csv", diagnostics_row, order)

    specification = (
        "Basic structural model: stochastic local level, stochastic seasonal component "
        "(period 12), and irregular error; no slope component; exact diffuse "
        f"initialisation; statsmodels maximum likelihood; {evidence['initialization_months']} "
        "initial months excluded from in-sample residual diagnostics"
    )
    specs_row = {
        "Model": MODEL_NAME,
        "Specification": specification,
        "AIC": float(fit.aic),
        "AICc": np.nan,
        "BIC": float(fit.bic),
        "Converged": evidence["converged"],
    }
    replace_model_row(OUTPUT_DIR / "nasa_model_specifications.csv", specs_row, order)

    parameters = pd.read_csv(OUTPUT_DIR / "nasa_model_parameters.csv")
    parameters = parameters.loc[
        ~parameters["Model"].isin([RETIRED_MODEL, MODEL_NAME])
    ].copy()
    bsm_parameters = pd.DataFrame(
        {
            "Model": MODEL_NAME,
            "Parameter": list(fit.param_names),
            "Estimate": np.asarray(fit.params, dtype=float),
            "Standard_error": np.asarray(fit.bse, dtype=float),
            "P_value": np.asarray(fit.pvalues, dtype=float),
        }
    )
    parameters = pd.concat([parameters, bsm_parameters], ignore_index=True)
    parameters["_order"] = parameters["Model"].map({name: i for i, name in enumerate(order)}).fillna(len(order))
    parameters = parameters.sort_values(["_order", "Parameter"]).drop(columns="_order")
    parameters.to_csv(OUTPUT_DIR / "nasa_model_parameters.csv", index=False)

    predictions = pd.read_csv(OUTPUT_DIR / "nasa_holdout_predictions.csv")
    predictions = predictions.loc[
        ~predictions["Model"].isin([RETIRED_MODEL, MODEL_NAME])
    ].copy()
    prediction_columns = [
        "date", "actual", "Model", "forecast", "lower_80", "upper_80",
        "lower_95", "upper_95",
    ]
    predictions = predictions[prediction_columns]
    bsm_predictions = pd.DataFrame(
        {
            "date": evidence["test"]["date"].dt.strftime("%Y-%m-%d"),
            "actual": evidence["test"]["solar_irradiance"].to_numpy(dtype=float),
            "Model": MODEL_NAME,
            "forecast": evidence["forecast_mean"],
            "lower_80": evidence["forecast_ci80"][:, 0],
            "upper_80": evidence["forecast_ci80"][:, 1],
            "lower_95": evidence["forecast_ci95"][:, 0],
            "upper_95": evidence["forecast_ci95"][:, 1],
        }
    )
    pd.concat([predictions, bsm_predictions], ignore_index=True)[prediction_columns].to_csv(
        OUTPUT_DIR / "nasa_holdout_predictions.csv", index=False
    )

    accuracy = pd.read_csv(OUTPUT_DIR / "nasa_model_accuracy.csv")
    diagnostics = pd.read_csv(OUTPUT_DIR / "nasa_residual_diagnostics.csv")
    selection = accuracy.merge(
        diagnostics[["Model", "Ljung_Box_p_value", "White_noise_at_5pct"]], on="Model"
    )
    nonnegative = {
        name: bool(group["forecast"].ge(0).all())
        for name, group in pd.read_csv(OUTPUT_DIR / "nasa_holdout_predictions.csv").groupby("Model")
    }
    selection["Nonnegative_test_forecasts"] = selection["Model"].map(nonnegative)
    selection["Eligible"] = selection["White_noise_at_5pct"] & selection["Nonnegative_test_forecasts"]
    selection = selection.sort_values(["RMSE", "MAE"], ascending=True).reset_index(drop=True)
    eligible = selection.index[selection["Eligible"]]
    selected_index = int(eligible[0]) if len(eligible) else 0
    selection["Selected"] = selection.index == selected_index
    selection.to_csv(OUTPUT_DIR / "nasa_model_selection.csv", index=False)

    summary_path = OUTPUT_DIR / "nasa_bsm_summary.json"
    summary = {
        "model": MODEL_NAME,
        "specification": specification,
        "training_period": "2001-01 to 2020-12",
        "test_period": "2021-01 to 2025-12",
        "training_metrics": training,
        "test_metrics": testing,
        "residual_diagnostics": {
            "n": len(evidence["residuals"]),
            "lag": 24,
            "fit_df": evidence["parameter_count"],
            "statistic": evidence["ljung_box_statistic"],
            "p_value": evidence["ljung_box_p_value"],
            "white_noise_at_5pct": evidence["ljung_box_p_value"] > 0.05,
        },
        "nonnegative_test_forecasts": evidence["nonnegative"],
        "converged": evidence["converged"],
        "parameters": dict(zip(fit.param_names, map(float, fit.params))),
    }
    summary_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

    versions_path = OUTPUT_DIR / "nasa_software_versions.csv"
    versions = pd.read_csv(versions_path)
    versions = versions.loc[~versions["Software"].isin(["Python", "statsmodels"])].copy()
    versions = pd.concat(
        [
            versions,
            pd.DataFrame(
                [
                    {"Software": "Python", "Version": sys.version.split()[0]},
                    {"Software": "statsmodels", "Version": statsmodels.__version__},
                ]
            ),
        ],
        ignore_index=True,
    )
    versions.to_csv(versions_path, index=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="write BSM evidence into NASA outputs")
    args = parser.parse_args()

    monthly = pd.read_csv(OUTPUT_DIR / "nasa_solar_monthly_clean.csv", parse_dates=["date"])
    expected = pd.date_range("2001-01-01", "2025-12-01", freq="MS")
    if len(monthly) != 300 or not monthly["date"].equals(pd.Series(expected)):
        raise ValueError("NASA monthly series is not the expected continuous 300-month sequence")
    if monthly["solar_irradiance"].isna().any() or monthly["solar_irradiance"].lt(0).any():
        raise ValueError("NASA monthly series contains missing or negative values")

    evidence = model_evidence(monthly)
    public = {
        "model": MODEL_NAME,
        "training_metrics": evidence["training_metrics"],
        "test_metrics": evidence["test_metrics"],
        "ljung_box_p_value": evidence["ljung_box_p_value"],
        "white_noise_at_5pct": evidence["ljung_box_p_value"] > 0.05,
        "nonnegative_test_forecasts": evidence["nonnegative"],
        "converged": evidence["converged"],
        "parameters": dict(zip(evidence["fit"].param_names, map(float, evidence["fit"].params))),
    }
    print(json.dumps(public, indent=2))
    if args.apply:
        apply_updates(evidence)


if __name__ == "__main__":
    main()
