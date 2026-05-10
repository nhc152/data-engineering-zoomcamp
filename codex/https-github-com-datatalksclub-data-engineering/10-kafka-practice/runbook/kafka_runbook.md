# Kafka Runbook

## Incident: Consumer Lag Increasing

### Triage

1. Check consumer group lag.
2. Identify which partition has lag.
3. Check consumer logs.
4. Check poison pill/DLQ count.
5. Check sink database latency.
6. Check hot key distribution.

### Commands

```bash
docker compose exec kafka kafka-consumer-groups.sh --bootstrap-server kafka:9092 --describe --group orders-postgres-sink
```

## Incident: Poison Pill Blocks Consumer

### Triage

1. Identify error in consumer logs.
2. Check event payload.
3. Send invalid event to DLQ after retry limit.
4. Commit original offset after DLQ write.
5. Continue processing.

## Incident: Duplicate Output

### Triage

1. Check if event was redelivered.
2. Check `processed_events`.
3. Check sink unique constraints.
4. Check offset commit timing.

### Fix

- Add event_id uniqueness.
- Use transactional DB write.
- Commit Kafka offset only after DB commit.

## Incident: DLQ Growing

### Triage

1. Count DLQ events.
2. Group by error message.
3. Identify whether bad data or code bug.
4. Fix root cause.
5. Replay small batch.

