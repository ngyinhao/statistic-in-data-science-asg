# Manual SARIMA operating record - 2026-09-04

- Starting state: branch `main`, tracking `origin/main`, with existing user and concurrent-task changes in report sources, NASA model outputs, `analysis_outputs/build_reports.py`, EV artifacts, and BSM files.
- Protected work: all pre-existing modifications and deletions were preserved. Shared NASA outputs were not regenerated in the main checkout because a concurrent BSM task had modified them.
- Scope: replace `auto.arima()` with a training-only manual Box--Jenkins identification process; document each SARIMA parameter decision; regenerate exact manual SARIMA evidence in an isolated temporary copy; update the SARIMA individual report and only the SARIMA values in the concurrently edited group report.
- Independent checks: manual candidates were fitted with R 4.6.1 and `forecast` 9.0.2. ARIMA(1,0,0)(0,1,1)[12] had the lowest training AICc (102.2697), passed the lag-24 Ljung--Box gate (`p=0.1046`), and achieved test RMSE 0.2850 and MAE 0.2198.
- Validation warning: the complete isolated pipeline emitted the pre-existing Holt--Winters optimisation warning twice; the manual SARIMA candidate fits converged and their outputs were unaffected.
- Word deliverable: not regenerated or replaced, following the user's instruction. A temporary draft created before that instruction was removed.
- Returned state: local changes only. No commit, push, pull request, merge, deployment, migration, or production change was performed.
