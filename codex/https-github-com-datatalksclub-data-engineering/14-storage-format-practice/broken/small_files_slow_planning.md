# Broken Scenario - Small Files Slow Query Planning

## Symptom

Queries are slow before actual data processing begins. File listing and planning take too long.

## Root Cause

The pipeline writes thousands of tiny files per partition.

Common causes:

- Streaming writes without compaction.
- Too many Spark partitions.
- Partitioning by high-cardinality column.
- Micro-batches too frequent.

## Diagnostic

```bash
find data/lake/orders_small_files -name "*.parquet" | wc -l
find data/lake/orders_compacted -name "*.parquet" | wc -l
```

PowerShell:

```powershell
(Get-ChildItem .\data\lake\orders_small_files -Recurse -Filter *.parquet).Count
(Get-ChildItem .\data\lake\orders_compacted -Recurse -Filter *.parquet).Count
```

## Prevention

- Compact files.
- Choose target file size.
- Tune writer partition count.
- Avoid overly granular partition keys.

