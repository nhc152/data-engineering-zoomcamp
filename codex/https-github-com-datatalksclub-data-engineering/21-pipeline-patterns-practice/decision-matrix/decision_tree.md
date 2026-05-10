# Pipeline Pattern Decision Tree

## First Question: What Latency Is Actually Required?

```text
Daily/hourly is enough?
  yes -> Batch ELT or Batch ETL
  no -> continue

Minute-level is enough?
  yes -> Micro-batch or CDC
  no -> continue

Sub-second/seconds required?
  yes -> Event streaming, CDC, or outbox
```

## Source Type

```text
Source is OLTP database tables?
  need changes/deletes/current state -> CDC
  app can publish semantic events -> Outbox/domain events
  daily snapshot enough -> Batch ELT

Source is product/user events?
  need realtime reaction -> Event streaming
  analytics only -> Batch or micro-batch from event logs

Source is files/API?
  daily/hourly -> Batch ELT
  frequent windows -> Micro-batch
```

## Correctness Requirement

```text
Need exact financial reporting?
  prefer Batch ELT with reconciliation, or CDC with strong controls

Need operational decision quickly?
  streaming with idempotent sink, DLQ, monitoring

Need both realtime and corrected historical view?
  Lambda or streaming + batch reconciliation
```

## Team Maturity

```text
Team cannot operate Kafka/Flink/CDC yet?
  avoid streaming unless business-critical
  choose batch/micro-batch first

Team has observability, replay, idempotency, on-call?
  streaming/CDC becomes more realistic
```

## Cost Shape

```text
Compute should run only on schedule?
  batch/micro-batch

Compute must run all the time?
  streaming/CDC

Replay must be cheap?
  batch raw files and warehouse marts are easier

Replay can be expensive but latency is critical?
  event log / streaming
```

## Migration Path

Common evolution:

```text
nightly batch
  -> hourly batch
  -> micro-batch
  -> CDC for OLTP changes
  -> event streaming for business events
```

Do not jump to the final architecture before the business needs it.

