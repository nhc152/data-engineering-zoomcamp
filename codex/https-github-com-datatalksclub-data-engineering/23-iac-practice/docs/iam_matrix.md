# IAM Matrix

## Principle

Use least privilege. Do not give `Owner` or `Editor` to pipeline service accounts.

## Service Accounts

| Service Account | Purpose | Project Role | Dataset/Bucket Access |
|---|---|---|---|
| `de-dev-loader` | Load raw files/tables in dev | `roles/bigquery.jobUser` | raw dataset editor, raw bucket object admin |
| `de-dev-transformer` | Transform dev raw to marts | `roles/bigquery.jobUser` | staging/marts dataset editor |
| `de-prod-loader` | Load production raw data | `roles/bigquery.jobUser` | prod raw dataset editor, raw bucket controlled write |
| `de-prod-transformer` | Build production marts | `roles/bigquery.jobUser` | staging/marts dataset editor |
| BI group | Query marts | none or job user through BI project | marts dataset viewer |

## Forbidden Patterns

- `roles/owner` for any pipeline service account.
- `roles/editor` for convenience.
- BI users reading raw PII datasets.
- Dev service account writing to prod buckets.
- Long-lived JSON keys in GitHub.

