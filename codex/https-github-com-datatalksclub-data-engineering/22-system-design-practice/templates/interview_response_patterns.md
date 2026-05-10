# Interview Response Patterns

## Strong Opening

```text
Before choosing tools, I want to clarify latency, correctness, data mutability, volume, consumers, and replay requirements. Those determine whether this should be batch, streaming, CDC, or hybrid.
```

## When Choosing Batch

```text
Since the SLA is hourly/daily and correctness/replay matter more than sub-second latency, I would use Batch ELT. It is easier to operate, easier to backfill, and cost-efficient. I would keep raw data immutable, transform in the warehouse, and publish tested marts.
```

## When Choosing Streaming

```text
Streaming is justified because the business requires decisions within seconds. I would design for at-least-once processing with idempotent sinks, event_id deduplication, schema validation, DLQ, lag monitoring, and replay from raw events.
```

## When Choosing CDC

```text
Because the source is a mutable OLTP database and we need inserts, updates, and deletes in the warehouse, CDC is a good fit. I would store a raw changelog, build current-state tables, handle deletes explicitly, and define a resnapshot strategy.
```

## When Rejecting Over-Engineering

```text
I would not start with Kafka/Flink here because the stated SLA is daily. The added operational complexity does not buy us business value. I would start with batch and evolve to micro-batch or CDC only if freshness requirements tighten.
```

## When Discussing Trade-offs

```text
This design favors operational simplicity and replayability over low latency.
```

```text
This design favors low latency over operational simplicity, so we need stronger observability, DLQ handling, and idempotency.
```

```text
This design favors open storage and replay over warehouse-only simplicity, so we need metadata, compaction, and governance.
```

## When Discussing Failure

```text
The main failure modes are duplicate events, late arrivals, schema drift, and downstream sink failures. I would mitigate them with event IDs, schema contracts, raw retention, DLQ, and idempotent writes.
```

## When Discussing Cost

```text
The main cost drivers are always-on streaming compute, storage retention, warehouse scan bytes, and replay/backfill compute. I would control them with partitioning, aggregate marts, retention policies, job labels, and budget alerts.
```

