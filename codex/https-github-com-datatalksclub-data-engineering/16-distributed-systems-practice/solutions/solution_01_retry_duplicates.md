# Solution 01 - Retry Duplicates

## Root Cause

The producer did not receive acknowledgement for `evt-001`, so it retried. The system now sees two physical writes for one logical event.

## Why Naive Sink Is Wrong

It appends every event delivery. Duplicate delivery becomes duplicate rows.

## Correct Design

Use `event_id` or a business key as a unique constraint and upsert/insert-ignore into the sink.

## Prevention

- stable event IDs
- idempotent sink
- producer retry with bounded attempts
- duplicate monitoring

## Real System Mapping

- Kafka producer retry can duplicate logical events.
- Airflow retry can duplicate output if task appends.
- Spark retry can duplicate files without safe commit protocol.

