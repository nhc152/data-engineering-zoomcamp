# Solution - Least Privilege IAM

For this lab:

| Resource | Role |
|---|---|
| Project | `roles/bigquery.jobUser` |
| Raw dataset | `roles/bigquery.dataEditor` |
| Staging dataset | `roles/bigquery.dataEditor` |
| Marts dataset | `roles/bigquery.dataEditor` |
| GCS bucket | `roles/storage.objectAdmin` |

Avoid:

- Project `Owner`.
- Project `Editor`.
- Raw dataset access for BI users.
- Long-lived keys in GitHub.

Production improvement:

- Separate service accounts for ingestion, transformation, and BI.
- Prefer workload identity where possible.
- Review IAM regularly.

