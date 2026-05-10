# Broken Scenario - Older Update Overwrites Newer State

## Symptom

Order `O1002` becomes `completed` after it was already updated to `refunded`.

## Root Cause

Consumer applies events by arrival order only and does not guard with source LSN/log position.

## Impact

Out-of-order delivery corrupts current-state table.

## Fix

Current-state update must only apply if incoming source position is newer:

```sql
where current.last_source_lsn < incoming.source_lsn
```

## Prevention

- Store `last_source_lsn`.
- Apply deterministic ordering.
- Make replay sort by source position.

