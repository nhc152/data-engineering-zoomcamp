# Broken Scenario - Accepted Values Test Fails

## Symptom

`dbt test` fails because a status value is not in the accepted list.

## Common Causes

- Source introduced new status.
- Staging model did not normalize casing/whitespace.
- Business enum changed without data contract update.

## Diagnostic

```sql
select distinct order_status
from raw.orders;
```

## Fix

- Normalize in staging.
- Decide whether new value is valid.
- Update accepted values through review.

