# Solution 04 - Prevent Dev Writes to Prod

## Controls

- Separate service accounts.
- Separate projects or buckets.
- Environment-specific config.
- CI rule: dev branches cannot target prod project/bucket.
- Labels and audit logs.

## Detection

- Audit logs show principal writing objects.
- Bucket object names include unexpected env/run IDs.
- Data quality checks detect test records.

## Response

Quarantine data, remove bad config, rotate credentials if needed, and add guardrails.

