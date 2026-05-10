# Level 05 - Failure Scenarios

## Goal

Practice production-style storage failure diagnosis.

## Scenarios

1. `broken/wrong_partition_overwrite.md`
2. `broken/small_files_slow_planning.md`
3. `broken/schema_drift_breaks_downstream.md`
4. `broken/raw_json_deleted.md`
5. `broken/compression_tradeoff.md`

## Tasks

For each scenario:

1. Describe the symptom.
2. Identify the likely root cause.
3. Propose diagnostic commands.
4. Propose a fix.
5. Propose prevention.

## Expected Output

Create notes:

```text
notes/storage_failure_review.md
```

## Interview Practice

Be ready to answer:

- Why is Parquet better than CSV for analytics?
- What is predicate pushdown?
- What is column pruning?
- What is the small files problem?
- How do you handle schema drift?
- Why should raw data be immutable?

