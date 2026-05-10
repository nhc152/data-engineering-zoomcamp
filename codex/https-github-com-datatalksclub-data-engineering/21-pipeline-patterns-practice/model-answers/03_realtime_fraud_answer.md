# Model Answer - Realtime Fraud

## Recommended Pattern

Event streaming with DLQ and idempotent sink.

## Why

Fraud decisions must happen within seconds. Batch or micro-batch is too slow. Streaming is justified despite higher operational complexity.

## Architecture

```text
payment service
  -> payment events topic
  -> fraud stream processor
  -> fraud decision store
  -> DLQ for bad events
  -> raw archive for replay/audit
```

## Required Controls

- `event_id`.
- Schema version.
- Idempotent sink writes.
- Consumer lag monitoring.
- DLQ with owner.
- Replay path from raw archive.

## Failure Modes

- Poison pill event blocks consumer.
- Duplicate event causes duplicate decision.
- Lag increases during traffic spike.
- Model/service dependency timeout.

## Trade-off Language

Streaming is operationally harder, but fraud has a latency requirement that justifies it. The design must explicitly handle duplicates, DLQ, lag, and replay.

