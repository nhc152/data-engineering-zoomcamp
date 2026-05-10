# Incident 02 - Backfill Corrupts Current Mart

## Timeline

```text
10:00 Developer started 90-day backfill
10:15 Backfill wrote directly to published mart
10:25 Dashboard revenue changed for current month unexpectedly
10:40 Publish gate was bypassed
11:30 Team restored table from backup/time travel
12:00 Incident mitigated
```

## Impact

Finance dashboard showed inconsistent current-month revenue. Trust in published mart was reduced.

## Root Cause

Backfill wrote directly to published table without temp table, validation, or publish gate.

## Detection Gap

No backfill safety checklist was required.

## Immediate Fix

Restored previous published partitions and reran backfill into temp tables.

## Prevention

- Require backfill plan.
- Build temp table first.
- Validate before publish.
- Record publish events.
- Require owner approval for finance marts.

