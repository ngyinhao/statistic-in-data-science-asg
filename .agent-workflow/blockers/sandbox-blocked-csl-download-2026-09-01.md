# Sandbox blocked CSL style downloads

## Context and intended action

The Markdown report package requires local IEEE and APA CSL files so Pandoc can format group and individual citations consistently.

## Observable symptom

Sandboxed PowerShell `Invoke-WebRequest` calls to the official Citation Style Language GitHub repository failed with a socket access-permission error.

## Impact

The reports could not be converted reproducibly with local citation styles until the files were downloaded.

## Confirmed cause

Outbound network access from the default command sandbox was restricted; the source URLs and destination paths were valid.

## Troubleshooting and result

The same narrowly scoped downloads were rerun with approved elevated network access and completed successfully.

## Successful workaround

Use approved external network access for `Invoke-WebRequest` when retrieving known official CSL resources. The downloaded files are stored locally under `Assignment Report/`, so later Pandoc runs do not require network access.

## Prevention

Keep the pinned CSL files with the report sources and update them deliberately from the official `citation-style-language/styles` repository when formatting requirements change.
