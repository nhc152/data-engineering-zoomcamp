# Incident Example - Duplicate Append Inflated Revenue

## Summary

Daily revenue for 2026-05-04 was inflated because the incremental job appended rows when rerun after a transient failure.

## Impact

- Finance dashboard showed revenue approximately 2x higher for one day.
- Business users saw incorrect daily revenue for 3 hours.
- No customer-facing system was affected.

## Timeline

- 07:00: pipeline started.
- 07:12: load task failed after partial append.
- 07:20: retry appended the same order rows again.
- 08:00: dashboard refreshed with duplicated data.
- 10:10: Finance reported mismatch.
- 10:30: duplicate check confirmed duplicate `order_id`.
- 11:00: table rebuilt for affected partition.

## Root Cause

The incremental load was append-only and not idempotent. It did not use merge/upsert or delete+insert partition.

## Detection Gap

There was no uniqueness check on `fct_orders.order_id` before dashboard publish.

## Fix

- Rebuilt affected partition.
- Added unique check for `order_id`.
- Changed load strategy to merge/upsert.

## Prevention

- Add duplicate check as publish gate.
- Add reconciliation check before dashboard refresh.
- Add runbook for retry after partial write.

