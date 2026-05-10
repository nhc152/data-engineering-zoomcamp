# IAM Matrix

Use least privilege. Avoid granting `Owner` or broad `Editor` to pipeline service accounts.

## Identities

| Identity | Purpose |
|---|---|
| Human developer | Run setup and inspect resources |
| `de-lab-loader` service account | Upload/read raw files and run BigQuery load/query jobs |
| BI user/group | Read marts only |

## Recommended IAM

| Resource | Identity | Role | Reason |
|---|---|---|---|
| Project | Human developer | `roles/bigquery.admin` for lab only | Create datasets/tables while learning |
| Project | Service account | `roles/bigquery.jobUser` | Run BigQuery jobs |
| Raw dataset | Service account | `roles/bigquery.dataEditor` | Create/load raw tables |
| Staging dataset | Service account | `roles/bigquery.dataEditor` | Create staging views |
| Marts dataset | Service account | `roles/bigquery.dataEditor` | Create marts |
| GCS bucket | Service account | `roles/storage.objectAdmin` for lab | Upload/read lab files |
| Marts dataset | BI group | `roles/bigquery.dataViewer` | Query analytics marts |

## Production Notes

For production, reduce further:

- Separate loader and transformer service accounts.
- Avoid object admin if read-only is enough.
- Give BI users marts-only access.
- Mask or restrict PII columns.
- Use dataset-level roles instead of project-wide roles where possible.

## Anti-patterns

- Pipeline service account has project `Owner`.
- BI users can read raw PII data.
- Everyone can write to raw bucket.
- Long-lived JSON keys stored in GitHub.
- No audit of service account permissions.

