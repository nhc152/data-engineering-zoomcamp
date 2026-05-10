# Level 03 - Offset Commit Failure Modes

## Goal

Understand why commit timing matters.

## Scenarios

### Bad: commit before sink write

Run or read:

```text
broken/commit_before_sink_write.py
```

Failure:

```text
poll -> commit offset -> crash -> sink write never happens
```

Result:

- Kafka thinks event is consumed.
- PostgreSQL never receives it.
- Data loss for that consumer group.

### Safer: write sink before commit

Safe pattern:

```text
poll -> write DB idempotently -> commit offset
```

If crash happens after DB write but before offset commit:

- Kafka redelivers.
- `processed_events` catches duplicate.
- Output remains correct.

## Deliverable

Write a note explaining:

- At-most-once.
- At-least-once.
- Why idempotency is required.

