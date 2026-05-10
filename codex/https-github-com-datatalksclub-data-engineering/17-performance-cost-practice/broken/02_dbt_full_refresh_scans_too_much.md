# Broken Scenario 02 - dbt Full Refresh Scans Too Much

## Symptom

Daily dbt run used to take 10 minutes. It now takes 90 minutes and scans much more data.

## Root Cause

A large fact model is rebuilt with full refresh every run.

## Evidence To Collect

- dbt run history
- warehouse query history
- model materialization
- input table size
- whether incremental key exists
- late-arriving data requirements

## Expected Fix

Use incremental model with:

- `unique_key`
- `updated_at` watermark
- lookback window
- reconciliation tests

## Trade-off

Incremental is faster and cheaper but harder to reason about than full refresh.

