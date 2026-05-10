# Compaction Policy

## Purpose

Compaction reduces small files and improves query planning/read performance.

## Why Small Files Happen

- Streaming writes micro-batches.
- Many small partitions.
- Frequent upserts.
- Low-volume sources writing too often.

## Symptoms

- Queries spend time listing/planning files.
- Metadata operations become slow.
- Table has thousands of tiny files.
- Costs increase due to many file reads.

## Policy

For production tables:

- Monitor file count and average file size.
- Compact bronze/silver streaming tables regularly.
- Compact gold tables before heavy BI usage windows.
- Avoid compaction during high-write periods.
- Keep compaction idempotent and observable.

## Example Thresholds

These are starting points, not universal rules:

```text
If average file size < 32 MB and file count > 1000 per partition, schedule compaction.
Aim for 128 MB - 512 MB files for large analytic tables.
```

## Trade-offs

Compaction improves reads but costs compute.

Do not compact blindly:

- very small tables
- cold/archive tables
- tables with no query pressure

