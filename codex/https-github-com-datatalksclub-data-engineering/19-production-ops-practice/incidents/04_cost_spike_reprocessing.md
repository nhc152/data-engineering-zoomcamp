# Incident 04 - Cost Spike During Reprocessing

## Timeline

```text
09:00 Backfill launched for 2 years of history
09:30 Warehouse cost alert fired
10:00 Team found full-table scans in dbt model
10:30 Backfill paused
14:00 Query optimized with partition filters
Next day Backfill resumed in monthly batches
```

## Impact

Daily warehouse cost exceeded expected budget by 3x.

## Root Cause

Backfill was launched without cost estimate and queries did not prune partitions.

## Detection Gap

No cost gate before large backfill.

## Immediate Fix

Paused backfill and rewrote query with partition filters.

## Prevention

- Require cost estimate.
- Backfill in smaller batches.
- Dry run large queries.
- Use owner labels.
- Monitor cost per run.

