# Broken Scenario 01 - Pipeline Success but Dashboard Wrong

## Symptom

The daily pipeline is green, but Finance reports revenue is too high.

## Likely Causes

- Join explosion duplicated revenue.
- Duplicate append created duplicate orders.
- Refund/cancelled orders not excluded.
- Dashboard queries raw table instead of mart.

## Diagnostic SQL

Run:

```text
sql/checks/03_uniqueness_checks.sql
sql/checks/06_reconciliation_checks.sql
```

## Expected Response

Do not trust job status alone. Check data:

- row count
- duplicate keys
- revenue reconciliation
- business rule filters

