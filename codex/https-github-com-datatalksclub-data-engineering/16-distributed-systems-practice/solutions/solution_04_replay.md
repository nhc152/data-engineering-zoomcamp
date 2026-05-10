# Solution 04 - Replay Safety

## Root Cause

Replay reprocessed events that were already published. Naive publish logic appended duplicates.

## Correct Design

Replay must be idempotent:

- use event_id unique key
- overwrite specific partitions
- publish to temp table/path then swap
- keep run metadata

## Real System Mapping

- Kafka replay by resetting offset.
- Spark backfill reading old raw files.
- Airflow/Kestra backfill rerunning dates.
- CDC resnapshot after log retention expiry.

