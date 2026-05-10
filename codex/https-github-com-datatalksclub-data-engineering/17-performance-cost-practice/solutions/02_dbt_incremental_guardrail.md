# Solution 02 - dbt Incremental Guardrail

## Fix

Convert large full-refresh fact models to incremental where appropriate.

Required design:

- unique key
- `updated_at` watermark
- lookback window
- data tests
- periodic controlled full refresh if needed

## Trade-off

Full refresh is simpler and safer for small data. Incremental is cheaper for large data but can miss late-arriving changes if designed poorly.

## Guardrail

Require approval for:

```bash
dbt run --full-refresh --select large_fact_model
```

Approval should include:

- estimated bytes scanned
- affected downstream models
- expected runtime
- rollback/reprocess plan

