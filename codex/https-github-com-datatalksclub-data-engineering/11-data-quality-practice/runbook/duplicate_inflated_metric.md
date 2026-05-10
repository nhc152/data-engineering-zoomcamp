# Runbook - Duplicate Inflated Metric

## Symptoms

Revenue, order count, or customer count is higher than expected.

## Triage

1. Check duplicate keys in fact table.
2. Check whether incremental job appended duplicates.
3. Check join cardinality.
4. Check raw vs mart reconciliation.
5. Check recent retries/backfills.

## SQL

Run:

```text
sql/checks/03_uniqueness_checks.sql
sql/checks/06_reconciliation_checks.sql
```

## Mitigation

- Stop dashboard publish if metric is business-critical.
- Rebuild affected partition.
- Use merge/upsert or delete+insert partition.

## Prevention

- Unique key checks.
- Idempotent writes.
- Reconciliation before publish.

