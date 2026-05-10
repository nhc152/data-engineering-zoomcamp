# Policy - No Owner Service Accounts

## Rule

Pipeline service accounts must not have:

- `roles/owner`
- `roles/editor`

## Allowed Examples

- `roles/bigquery.jobUser`
- dataset-level BigQuery data roles
- bucket-level Storage object roles
- Secret Manager access to specific secrets only

## Why

Over-permissioned service accounts can delete data, change IAM, access PII, and increase blast radius during incidents.

