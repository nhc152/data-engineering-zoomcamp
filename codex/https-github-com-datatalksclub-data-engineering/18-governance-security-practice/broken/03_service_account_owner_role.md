# Broken Scenario 03 - Service Account Has Owner Role

## Symptom

Pipeline service account has project Owner.

## Risk

The pipeline can:

- change IAM
- delete buckets/tables
- read Restricted data not needed
- write to unrelated datasets
- create public resources

## Correct Pattern

Split service accounts:

- `svc-ingestion-orders`: write raw orders only
- `svc-transform-dbt`: read raw/staging, write marts
- `svc-bi-dashboard`: read curated marts only

Grant dataset/bucket scoped roles where possible.

