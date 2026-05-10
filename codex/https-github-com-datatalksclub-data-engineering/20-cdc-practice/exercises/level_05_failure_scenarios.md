# Level 05 - Failure Scenarios

## Goal

Practice CDC production failure diagnosis.

## Scenarios

1. `broken/wal_retention_expired.md`
2. `broken/delete_events_ignored.md`
3. `broken/schema_rename_breaks_downstream.md`
4. `broken/offset_committed_before_sink_write.md`
5. `broken/older_update_overwrites_newer_state.md`

## Tasks

For each scenario:

1. Describe symptom.
2. Identify root cause.
3. Explain data correctness impact.
4. Propose recovery.
5. Propose prevention.

## Expected Output

Create:

```text
notes/cdc_failure_review.md
```

