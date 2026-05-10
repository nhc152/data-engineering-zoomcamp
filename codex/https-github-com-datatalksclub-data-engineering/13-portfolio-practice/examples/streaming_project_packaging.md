# Example Packaging - Streaming Project

## Project Summary

Build a mini streaming order event pipeline:

```text
producer -> Kafka topic -> idempotent consumer -> PostgreSQL sink -> DLQ/replay notes
```

## Strong README Angle

This project demonstrates:

- event schema design
- topic partitioning
- producer key choice
- consumer group behavior
- at-least-once duplicate handling
- DLQ and replay thinking

## Good Trade-Offs to Explain

- Streaming gives lower latency but increases operational complexity.
- Keying by `order_id` preserves ordering per order but can create hot partitions.
- At-least-once means duplicates are expected; sink must be idempotent.
- DLQ prevents poison events from blocking the consumer but must be monitored.

## Failure Story

```text
If the consumer writes to the sink and crashes before committing the offset, Kafka may deliver the same event again. I handle this with an idempotent sink using `event_id` as a unique key.
```

