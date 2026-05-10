# Exercise 03 - Realtime Fraud

## Scenario

Fraud team needs to evaluate payment events within seconds. A decision service must block suspicious transactions. Duplicate events are possible. Bad events should not block the whole stream.

## Requirements

- Latency: seconds.
- Correctness: high, but duplicates must be tolerated.
- Failure handling: DLQ required.
- Sink: fraud decision store or service.
- Replay: required for audits and model improvements.

## Tasks

1. Choose pattern.
2. Define event schema.
3. Define idempotent sink key.
4. Define DLQ schema.
5. Define replay strategy.
6. Define lag monitoring.
7. Explain operational risk.

## Expected Direction

Likely pattern:

```text
Event streaming
```

Potential support patterns:

```text
DLQ/quarantine
Fan-out to analytics/ML consumers
```

## Deliverable

Write:

```text
realtime_fraud_design.md
```

