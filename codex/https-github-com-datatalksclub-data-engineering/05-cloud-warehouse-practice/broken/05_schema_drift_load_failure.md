# Broken Scenario 05 - Schema Drift Breaks Load Job

## Symptom

The May 2 orders file has a new column `coupon_code`. A strict load job expecting the original orders schema fails or silently ignores fields depending on configuration.

File:

```text
data/orders_schema_drift.csv
```

## Why It Matters

Schema drift can:

- Break load jobs.
- Create nullable columns unexpectedly.
- Hide business changes.
- Make downstream marts inconsistent.

## Diagnostic

Compare headers:

```bash
head -n 1 data/orders.csv
head -n 1 data/orders_schema_drift.csv
```

## Production Response

- Detect schema changes before load.
- Decide whether new columns are allowed.
- Update staging model deliberately.
- Add data contract for important sources.

