# Broken Scenario - Uniqueness Test Fails

## Symptom

`dbt test` fails on `unique` for an order or customer key.

## Common Causes

- Raw source sends multiple versions of the same business key.
- Staging model forgot to deduplicate.
- Incremental model appended instead of merged.

## Diagnostic

```sql
select
    order_id,
    count(*) as row_count
from raw.orders
group by order_id
having count(*) > 1;
```

## Fix

Deduplicate in staging with `row_number()` and deterministic ordering.

