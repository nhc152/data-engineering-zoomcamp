# Broken Scenario - Wrong Partition Overwrite

## Symptom

A backfill for `order_date=2026-05-01` deletes data for other dates.

## Root Cause

The job overwrites the table root instead of the specific partition.

Bad:

```text
overwrite data/lake/orders/
```

Expected:

```text
overwrite data/lake/orders/order_date=2026-05-01/
```

## Reproduce Safely

```bash
python src/wrong_partition_overwrite_demo.py
```

## Prevention

- Require explicit partition date.
- Validate output path before write.
- Write to temp path, then atomically publish if possible.
- Keep raw immutable so curated can be rebuilt.

