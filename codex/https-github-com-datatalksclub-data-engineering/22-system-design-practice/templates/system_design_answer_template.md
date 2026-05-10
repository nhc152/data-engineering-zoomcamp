# System Design Answer Template

Use this template before reading model answers.

## 1. Problem Summary

What are we designing?

```text
Design ...
```

## 2. Clarifying Questions

Ask at least 8:

- What are the data sources?
- What is the expected latency?
- What is the current and future volume?
- Who consumes the data?
- Is this analytics, ML, operations, finance, fraud, compliance?
- Is data mutable or append-only?
- Do we need deletes?
- Do we need replay/backfill?
- Does the data contain PII or financial data?
- What happens if the dashboard/model is wrong?
- What freshness SLA is required?
- What cost constraints exist?

## 3. Assumptions

Write explicit assumptions:

```text
- Events: ...
- Volume: ...
- Latency: ...
- Retention: ...
- Consumers: ...
- Accuracy requirements: ...
```

## 4. Volume Estimation

Use:

```text
events_per_day =
avg_event_size =
raw_gb_per_day =
peak_events_per_second =
retention_days =
storage_required =
```

## 5. Pattern Choice

Choose one or more:

- Batch ELT.
- Batch ETL.
- CDC.
- Event streaming.
- Micro-batch.
- Medallion.
- Lambda.
- Kappa.
- Outbox.

Explain why:

```text
I choose ... because ...
I do not choose ... because ...
```

## 6. Architecture

Draw or describe:

```text
source -> ingestion -> raw -> processing -> serving -> consumers
```

## 7. Storage Design

Define:

- raw layer
- staging/silver layer
- marts/gold layer
- retention
- partitioning
- file/table format

## 8. Processing Design

Define:

- batch/streaming/CDC processing
- idempotency
- deduplication
- late data
- deletes
- schema evolution

## 9. Serving Design

Define:

- warehouse marts
- realtime store
- feature store
- dashboard tables
- APIs if needed

## 10. Data Quality

Checks:

- freshness
- row count
- uniqueness
- referential integrity
- accepted values
- reconciliation
- anomaly detection

## 11. Reliability

Design:

- retry
- DLQ/quarantine
- idempotent writes
- backpressure
- replay
- backfill
- run metadata
- alerting

## 12. Bottlenecks

Identify:

- source rate limit
- broker partitions
- warehouse scan cost
- Spark shuffle
- CDC lag
- state store size
- dashboard query concurrency

## 13. Cost

Discuss:

- always-on compute
- storage growth
- query scan cost
- replay cost
- dashboard refresh frequency
- retention

## 14. Trade-offs

Use concrete language:

```text
This design favors ... over ...
The main risk is ...
I would start simple with ... and evolve to ... when ...
```

## 15. Final Summary

Close with:

```text
This architecture meets the latency requirement by ...
It meets reliability by ...
It controls cost by ...
The biggest trade-off is ...
```

