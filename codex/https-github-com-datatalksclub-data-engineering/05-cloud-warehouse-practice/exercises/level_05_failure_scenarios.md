# Level 05 - Failure Scenarios

## Goal

Practice diagnosing production warehouse failures.

## Scenarios

1. `broken/01_location_mismatch.md`
2. `broken/02_full_table_scan.sql`
3. `broken/03_over_permissioned_service_account.md`
4. `broken/04_raw_overwrite_backfill.md`
5. `broken/05_schema_drift_load_failure.md`

## Tasks

For each scenario:

1. Describe symptom.
2. Identify root cause.
3. Write diagnostic command/query.
4. Propose fix.
5. Propose prevention.

## Expected Output

Create your own notes:

```text
notes/cloud_warehouse_failure_review.md
```

Include one section per failure.

## Interview Practice

Be ready to answer:

- A BigQuery query suddenly costs 10x more. What do you check?
- GCS file exists but BigQuery external table returns zero rows. What do you check?
- Service account has project Owner. Why is that bad?
- A backfill overwrote raw files. How do you recover?

