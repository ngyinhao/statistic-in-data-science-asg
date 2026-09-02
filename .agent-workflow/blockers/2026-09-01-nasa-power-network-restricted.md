# NASA POWER download blocked by restricted network

## Context and intended action

On 2026-09-01, the workflow attempted to download the unmodified CSV response from the NASA POWER Monthly API into `analysis_outputs/nasa/raw/` so the repository would contain the source data before cleaning.

## Symptom

`curl.exe` exited with code 1 and reported that it could not connect to `power.larc.nasa.gov` on port 443.

## Impact

The raw CSV could not be fetched during the initial sandboxed command, although the R workflow could still be updated to request it on future runs.

## Likely cause

The workspace runs with restricted network access. The failure occurred immediately and is consistent with the sandbox blocking outbound HTTPS rather than an API response error.

## Troubleshooting and result

- Confirmed that the existing raw JSON and API URL target the same NASA POWER monthly point endpoint.
- Retained a direct CSV endpoint by changing only the API `format` parameter from `JSON` to `CSV`.
- Retried the download outside the restricted network sandbox, subject to approval.

## Workaround or remaining limitation

Use an approved network-enabled command for the initial fetch. Once the CSV exists, the R script leaves it intact and does not re-download or clean it.

## Prevention

For future reproducibility runs that need a fresh NASA response, allow outbound HTTPS access to `power.larc.nasa.gov` or run the R script in an environment with network access. Keep the raw API response separate from derived clean data.
