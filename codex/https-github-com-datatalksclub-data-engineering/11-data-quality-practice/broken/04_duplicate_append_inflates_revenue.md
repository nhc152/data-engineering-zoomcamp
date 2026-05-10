# Broken Scenario 04 - Duplicate Append Inflates Revenue

## Symptom

Revenue doubles after rerunning an incremental job.

## Root Cause

The pipeline appends rows instead of merge/upsert or delete+insert partition.

## Diagnostic SQL

Run:

```text
sql/checks/03_uniqueness_checks.sql
sql/checks/06_reconciliation_checks.sql
```

## Prevention

- Unique key tests.
- Idempotent write pattern.
- Merge/upsert by business key.
- Reconciliation between raw and mart.

