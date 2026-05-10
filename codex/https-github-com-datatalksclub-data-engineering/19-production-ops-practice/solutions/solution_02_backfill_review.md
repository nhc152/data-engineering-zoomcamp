# Solution Example - Backfill Review

## Why Blind Append Is Unsafe

Blind append can duplicate rows when backfill is rerun. It also cannot safely update existing records or remove incorrect records.

## Safer Strategy

Use temp table then publish:

```text
build temp partition/table
  -> validate
  -> compare old vs new
  -> approve
  -> replace affected partitions
  -> record publish event
```

## Required Checks

- duplicate primary key check
- row count by partition
- revenue reconciliation
- freshness
- old vs new metric comparison
- cost actual vs estimate

## Rollback

Keep old partitions during rollback window. If issue appears, restore previous partitions and mark publish event as rolled back.

