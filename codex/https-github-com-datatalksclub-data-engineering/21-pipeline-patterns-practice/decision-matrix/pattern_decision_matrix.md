# Pipeline Pattern Decision Matrix

## Summary Matrix

| Pattern | Latency | Complexity | Cost | Replay/Backfill | Correctness Risk | Best For | Avoid When |
|---|---:|---:|---:|---|---|---|---|
| Batch ELT | Hours/day | Low | Low/Medium | Easy | Incremental bugs, late data | BI, finance reporting, warehouse marts | Need sub-minute decisions |
| Batch ETL | Hours/day | Medium | Medium | Medium | Logic hidden outside warehouse | Large file processing, Spark transforms | SQL warehouse can handle transform |
| Micro-batch | Minutes | Medium | Medium | Medium | Window overlap duplicates | Near-real-time marts | True event-level response needed |
| CDC | Seconds/minutes | High | Medium/High | Hard | Deletes, ordering, schema drift | OLTP replication, current-state tables | Need business semantic events |
| Event streaming | Seconds | High | High | Hard | Duplicates, order, poison pills | Fraud, product events, operational triggers | Daily reporting only |
| Medallion | Batch or streaming | Medium/High | Medium | Good by layer | Layer boundary confusion | Lakehouse/lake quality pipeline | Small simple warehouse project |
| Lambda | Mixed | High | High | Hard | Batch/stream logic drift | Realtime + historical correctness | Team cannot maintain two paths |
| Kappa | Low | High | Medium/High | Depends on log retention | Stream correctness, replay cost | Event-first systems | Sources are not clean event logs |
| Outbox | Seconds/minutes | Medium/High | Medium | Medium | Relay lag, duplicate publish | Reliable domain events from app DB | No app team support |
| DLQ/Quarantine | N/A | Medium | Low/Medium | Good if owned | Silent data loss if ignored | Bad record isolation | Nobody owns replay |
| Fan-out | Depends | Medium/High | Medium/High | Per consumer | Contract drift | Many consumers of one source | No schema governance |
| Fan-in | Depends | High | Medium/High | Hard | Identity/semantic mismatch | Customer 360, unified payments | No canonical model or source priority |

## Decision Dimensions

### Latency

Ask:

- Does the business need seconds, minutes, hours, or daily?
- Is lower latency worth more operational complexity?

Rule:

- Daily reporting should not start with streaming.
- Sub-second fraud cannot wait for nightly batch.

### Mutability

Ask:

- Are records append-only events?
- Do records update/delete?
- Do we need current state or history?

Rule:

- Mutable OLTP tables usually need CDC or periodic snapshot.
- Immutable product events fit event streaming better.

### Replay

Ask:

- Can we rebuild outputs from raw data?
- How far back can we replay?
- Is raw data retained?

Rule:

- No replay path means the system is not production-ready.

### Correctness

Ask:

- Can downstream tolerate duplicates?
- Can events arrive out of order?
- How are deletes handled?
- Are sinks idempotent?

Rule:

- Streaming without idempotency is incomplete.

### Cost

Ask:

- Is compute always on?
- Is storage duplicated?
- How expensive is replay?
- Does dashboard query raw data repeatedly?

Rule:

- Cost follows architecture. The pattern determines the bill shape.

