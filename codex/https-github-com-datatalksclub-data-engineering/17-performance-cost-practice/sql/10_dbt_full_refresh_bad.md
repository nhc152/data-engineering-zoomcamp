# Bad Pattern - dbt Full Refresh Scans Too Much

## Symptom

Daily dbt job cost increases sharply as fact table grows.

## Bad Command

```bash
dbt run --full-refresh --select fct_orders
```

## Why It Is Expensive

Full refresh rebuilds the whole model, not only changed partitions or updated rows.

## Safer Alternatives

- Incremental model with `unique_key`.
- Partition-aware incremental strategy.
- Lookback window for late-arriving data.
- Full refresh only during controlled backfill/rebuild.

## Required Guardrail

Full refresh of large models should require explicit approval and cost estimate.

