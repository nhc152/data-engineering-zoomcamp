# Broken Scenario 03 - Code Rollback Is Not Data Rollback

## Symptom

A bad incremental model writes wrong revenue into production table. The team reverts the code, but the table still contains wrong rows.

## Root Cause

Code rollback only changes future runs. It does not automatically undo data already written.

## Example

```text
Day 1: deploy bad model
Day 1-3: bad model writes wrong revenue
Day 4: revert code
Day 4 onward: new runs are correct
Day 1-3 data remains wrong
```

## Prevention

- Keep backups or table snapshots.
- Write to staging/green table first.
- Validate before swap.
- Have reprocess/backfill plan.
- Store run metadata.

