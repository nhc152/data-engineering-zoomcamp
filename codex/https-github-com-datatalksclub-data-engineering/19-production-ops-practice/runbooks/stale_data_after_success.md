# Runbook - DAG Success But Data Stale

## Symptom

The orchestration run succeeded, but the mart is stale or missing latest source data.

## First Checks

1. Check source latest timestamp.
2. Check raw table latest timestamp.
3. Check staging latest timestamp.
4. Check fact/mart latest timestamp.
5. Compare with SLA.

## Common Causes

- Source did not deliver new data.
- Pipeline used wrong data interval.
- Staging filter removed new rows.
- Incremental watermark is stale.
- Publish gate published old partition.
- Dashboard cache is stale.

## Diagnostic Query Pattern

```sql
select
  'raw_orders' as layer,
  max(order_timestamp) as latest_timestamp
from raw.orders
union all
select
  'fct_orders',
  max(order_timestamp)
from marts.fct_orders;
```

## Mitigation

- If source stale: contact source owner and keep previous published data.
- If pipeline bug: fix logic, rebuild affected partition, rerun checks, publish.
- If dashboard cache: refresh cache and document impact.

## Prevention

- Freshness checks by layer.
- Publish gate includes freshness.
- Run metadata records data interval and max source timestamp.

