# Model Answer - Realtime Fraud Detection

## Pattern Choice

Event streaming.

Fraud decisions need seconds-level latency. Batch or micro-batch cannot meet the requirement.

## Architecture

```text
payment service
  -> payment events topic
  -> fraud stream processor
  -> feature/state store
  -> fraud decision store
  -> payment authorization
  -> DLQ and raw archive
```

## Volume Estimate

Assume:

- 5k events/sec average.
- 25k events/sec peak.
- Event size 2 KB.
- Around 864 GB/day raw at average before compression.

This requires partitioned topics, scalable consumers, and careful state management.

## Bottlenecks

- Broker partitions.
- Hot keys.
- Feature store lookup latency.
- Model inference latency.
- Sink write throughput.

## Reliability

- At-least-once processing.
- Idempotent decision writes by event_id/payment_id.
- DLQ for bad events.
- Lag monitoring.
- Timeout fallback policy.
- Replay from raw event archive.

## Data Quality

- Required fields.
- Schema version.
- Amount/currency validation.
- Duplicate event rate.
- DLQ count.

## Cost

- Always-on stream compute.
- Broker retention.
- State store cost.
- Raw archive retention.

## Trade-offs

This design favors low latency over simplicity. The added complexity is justified by fraud prevention value, but it requires strong observability, DLQ ownership, and idempotency.

