# Level 05 - Lag and Hot Partition

## Goal

Understand partition imbalance and consumer lag.

## Tasks

1. Produce hot partition events.
2. Run one consumer.
3. Inspect consumer group lag.
4. Start a second consumer in another terminal.
5. Observe whether more consumers fully solve the hot key.

## Commands

```bash
python src/producer.py --file data/hot_partition_events.jsonl
docker compose exec kafka kafka-consumer-groups.sh --bootstrap-server kafka:9092 --describe --group orders-postgres-sink
```

## Expected Learning

- Same key maps to same partition.
- Ordering and parallelism are a trade-off.
- More consumers do not help if one partition is hot.

