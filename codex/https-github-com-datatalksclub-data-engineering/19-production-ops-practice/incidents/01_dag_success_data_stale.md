# Incident 01 - DAG Success But Data Stale

## Timeline

```text
06:00 Pipeline started
06:20 Pipeline succeeded
07:05 Finance reported missing orders
07:15 Data Engineering confirmed raw source latest timestamp was stale
08:00 Source team confirmed API delay
09:10 Source recovered
09:40 Pipeline rerun and mart published
```

## Impact

`mart_daily_revenue` missed orders for the previous business day. Finance dashboard showed incomplete revenue for 2 hours 35 minutes.

## Root Cause

Pipeline monitored task success but did not enforce source freshness at publish time.

## Detection Gap

No freshness publish gate existed.

## Immediate Fix

Reran pipeline after source recovered.

## Prevention

- Add source freshness SLI.
- Add publish gate blocking stale data.
- Alert source owner when freshness breaches.
- Record max source timestamp in run metadata.

