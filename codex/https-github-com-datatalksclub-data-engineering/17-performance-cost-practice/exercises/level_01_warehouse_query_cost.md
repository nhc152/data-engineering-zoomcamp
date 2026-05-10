# Level 01 - Warehouse Query Cost

## Goal

Practice identifying expensive warehouse query patterns.

## Tasks

1. Compare `sql/01_partition_pruning_bad.sql` and `sql/02_partition_pruning_good.sql`.
2. Compare `sql/03_column_pruning_bad.sql` and `sql/04_column_pruning_good.sql`.
3. Explain how partition pruning and column pruning reduce scanned bytes.
4. Fill `templates/before_after_metrics.md` with hypothetical metrics.

## Expected Learning

- Bytes scanned matters.
- Partition filter should use the partition column.
- `select *` is risky on large columnar tables.

## Interview Question

A BigQuery dashboard suddenly costs 10x more. What do you check first?

