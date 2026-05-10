# Distributed Failure Runbook

## Symptom: Duplicate Rows

Check:

1. Producer retry logs.
2. Consumer retry/restart logs.
3. Offset commit timing.
4. Sink unique constraints.
5. Backfill/replay runs.

Mitigation:

- deduplicate by event_id/business key
- rebuild affected partition/table
- add idempotent write path

## Symptom: Stale Current State

Check:

1. Out-of-order events.
2. Source version/LSN.
3. Merge condition.
4. Event key/partitioning.

Mitigation:

- compare source version before update
- replay affected entity range
- add stale update rejection metric

## Symptom: Lag Keeps Growing

Check:

1. Input rate.
2. Processing rate.
3. Sink latency.
4. Poison events.
5. Hot partition/key.

Mitigation:

- scale safe bottleneck
- throttle upstream
- batch writes
- route bad events to DLQ
- repartition if key strategy is wrong

## Symptom: Replay Corrupts Output

Check:

1. Replay date/key range.
2. Target write mode.
3. Idempotency key.
4. Already-published output.
5. Run metadata.

Mitigation:

- write to temp output
- validate row counts/reconciliation
- swap or merge safely
- avoid blind append

