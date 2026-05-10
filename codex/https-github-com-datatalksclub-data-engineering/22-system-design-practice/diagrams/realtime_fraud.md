# Diagram - Realtime Fraud Detection

```mermaid
flowchart LR
  A["Payment Service"] --> B["Payment Events Topic"]
  B --> C["Fraud Stream Processor"]
  C --> D["Feature/State Store"]
  C --> E["Fraud Decision Store"]
  C --> F["DLQ"]
  B --> G["Raw Event Archive"]
  E --> H["Payment Authorization Flow"]
```

## Bottlenecks

- Broker partitions.
- Feature lookup latency.
- Stream processor state size.
- Downstream decision store write latency.

## Reliability

- Event ID.
- Idempotent decision writes.
- DLQ and replay.
- Lag monitoring.
- Timeout fallback policy.

