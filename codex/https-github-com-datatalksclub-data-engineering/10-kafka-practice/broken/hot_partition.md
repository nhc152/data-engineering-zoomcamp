# Broken Scenario - Hot Partition

## Symptom

One partition has much higher lag than others. Adding consumers does not help enough because one hot key maps most events to one partition.

## How to Reproduce

```bash
python src/producer.py --file data/hot_partition_events.jsonl
python src/consumer.py
```

Inspect lag:

```bash
docker compose exec kafka kafka-consumer-groups.sh --bootstrap-server kafka:9092 --describe --group orders-postgres-sink
```

## Root Cause

All events use the same key:

```text
order_id = HOT-ORDER
```

Kafka keeps same-key events in the same partition to preserve ordering. That partition becomes hot.

## Fix Options

- Choose a key with better distribution if strict per-order ordering is not required.
- Split high-volume entity into subkeys if business allows.
- Increase partitions before traffic grows too much.
- Add downstream buffering/backpressure.
- Accept ordering cost if ordering is more important than parallelism.

