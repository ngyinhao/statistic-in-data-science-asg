# Rscript unavailable for local verification

## Context and intended action

On 2026-09-01, the workflow attempted to locate `Rscript` so the modified forecasting script could be parsed or executed after adding the raw NASA POWER CSV download.

## Symptom

PowerShell `Get-Command Rscript` returned no executable.

## Impact

Calling `Rscript` by command name cannot syntax-check or rerun the analysis, so workflows that assume it is on `PATH` stop prematurely.

## Likely cause

R is installed, but its executable directory is not on the process `PATH`.

## Troubleshooting and result

- Queried the active command path for `Rscript`; no command was found.
- Reviewed the small R change directly and validated the downloaded artifact independently.
- On recurrence, searched standard Windows R installation directories and found `Rscript.exe` at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`.

## Workaround or remaining limitation

Invoke `C:\Program Files\R\R-4.6.1\bin\Rscript.exe` explicitly. The installed runtime includes the packages needed by this repository.

## Prevention

Expose the installed R `bin` directory on `PATH`, or keep the explicit executable path documented in repository workflows.
