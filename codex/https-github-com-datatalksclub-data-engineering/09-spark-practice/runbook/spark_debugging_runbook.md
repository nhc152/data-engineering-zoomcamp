# Spark Debugging Runbook

## Incident: Spark Job Is Slow

### Triage

1. Identify the slow stage.
2. Check whether the stage has shuffle read/write.
3. Check task duration distribution.
4. Check input size per task.
5. Check spill, GC time, and executor memory.
6. Check whether one key is skewed.
7. Check whether job is reading many small files.

### Common Causes

- Large shuffle.
- Skewed key.
- Too many partitions.
- Too few partitions.
- Bad join strategy.
- Recomputing lineage due to repeated actions.
- Small files.

### Fix Options

- Broadcast small dimension.
- Pre-aggregate before join.
- Repartition by better key.
- Salt skewed key.
- Isolate hot key.
- Compact small files.
- Tune `spark.sql.shuffle.partitions`.
- Cache only if reused and memory allows.

## Incident: Driver OOM

### Common Causes

- `collect()` on large data.
- `toPandas()` on large data.
- Huge broadcast table.
- Too many input files/tasks.

### Fix

- Keep computation distributed.
- Use aggregations instead of collecting IDs.
- Use `limit()` for samples.
- Reduce file count.
- Avoid broadcasting large tables.

## Incident: Output Data Missing After Backfill

### Common Causes

- `mode("overwrite")` used on whole table path.
- Partition overwrite mode misconfigured.
- Backfill filtered wrong date.

### Fix

- Use partitioned writes.
- Use dynamic partition overwrite carefully.
- Write to temp path, validate, then publish.
- Add row count checks per partition.

## Incident: Too Many Small Files

### Symptoms

- Downstream queries slow before processing data.
- File listing is slow.
- Spark creates many tasks with tiny input.

### Fix

- Compact files.
- Control output partitions.
- Avoid over-repartitioning.
- Use appropriate partition columns.

