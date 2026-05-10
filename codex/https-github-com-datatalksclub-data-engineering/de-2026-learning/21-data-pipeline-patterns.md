# Data Pipeline Patterns

## Vai tro

Data pipeline pattern la nhung cach thiet ke lap lai trong production. Neu biet pattern, ban khong can moi lan gap bai toan moi lai bat dau tu tool. Ban se hoi:

- Day la batch, streaming, CDC hay hybrid?
- Data mutable hay immutable?
- Can full refresh hay incremental?
- Co late-arriving data khong?
- Output la fact, dimension, mart, feature hay operational sync?
- Recovery/replay nam o dau?

## Muc tieu can dat

- Nhan dien pipeline patterns thong dung.
- Biet trade-off cua moi pattern.
- Biet failure modes va recovery.
- Biet chon pattern theo latency, volume, correctness va cost.
- Biet noi trong system design interview theo pattern.

## Khai niem can nam

- ETL.
- ELT.
- Batch.
- Micro-batch.
- Streaming.
- CDC.
- Lambda architecture.
- Kappa architecture.
- Medallion architecture.
- Bronze/Silver/Gold.
- Fan-out.
- Fan-in.
- Idempotency.
- Replay.
- Backfill.
- Dead-letter queue.

## Pattern 1: Batch ELT

```text
source -> extract/load raw -> warehouse -> SQL/dbt transform -> marts
```

Dung khi:

- analytics/reporting
- latency hourly/daily
- logic SQL-heavy
- cost can kiem soat

Bottlenecks:

- full refresh lon
- source extraction delay
- warehouse queue
- bad incremental logic

Failure handling:

- raw immutable
- rerun by date
- dbt tests
- atomic publish

Trade-offs:

- De debug.
- Cost-friendly.
- Latency cao hon streaming.

## Pattern 2: Batch ETL

```text
source -> processing engine -> transformed output -> warehouse/lake
```

Dung khi:

- transform can Spark/Python
- data qua lon de load raw vao warehouse truoc
- file processing

Risks:

- business logic nam ngoai warehouse kho lineage
- hard to audit neu raw khong duoc luu

Production recommendation:

- van luu raw first neu co the
- output co metadata/run_id
- transformation versioned

## Pattern 3: CDC to Warehouse

```text
OLTP -> CDC -> changelog -> current-state tables -> marts
```

Dung khi:

- source DB thay doi lien tuc
- can near-real-time analytics
- khong muon query OLTP

Failure modes:

- log retention expired
- schema drift
- delete ignored
- out-of-order updates

Recovery:

- replay changelog
- resnapshot
- reconcile counts

## Pattern 4: Event streaming

```text
producer -> broker -> stream processor -> realtime sink + raw archive
```

Dung khi:

- low latency
- event-driven consumers
- operational decisions

Risks:

- duplicate
- late/out-of-order events
- consumer lag
- poison messages

Production requirement:

- event_id
- schema registry
- DLQ
- lag monitoring
- replay archive

## Pattern 5: Micro-batch

```text
events/files -> small time windows -> batch processing -> target
```

Dung khi:

- latency minute-level du
- streaming complexity khong can
- warehouse merge per minute/hour

Trade-off:

- don gian hon streaming
- latency cao hon true streaming
- cost tot hon per-event writes

## Pattern 6: Medallion architecture

```text
bronze -> silver -> gold
```

Bronze:

- raw or lightly processed
- replay source

Silver:

- cleaned
- deduped
- conformed

Gold:

- business-ready
- marts/features/metrics

Failure handling:

- rebuild silver from bronze
- rebuild gold from silver
- quality gates between layers

## Pattern 7: Lambda architecture

```text
batch path -> accurate historical view
streaming path -> low-latency view
serving layer combines both
```

Dung khi:

- need low latency and historical correctness

Downside:

- duplicate logic in batch and streaming
- hard to keep consistent

## Pattern 8: Kappa architecture

```text
event log -> stream processor -> serving tables
```

Dung khi:

- all data is event log
- replay stream can rebuild state

Downside:

- long replay can be expensive
- not all sources are clean event logs

## Pattern 9: Outbox pattern

```text
app transaction -> outbox table -> relay -> broker
```

Dung khi:

- app needs reliable event publish tied to DB transaction

Benefits:

- avoid dual-write inconsistency
- event generated from committed transaction

Risks:

- outbox table growth
- relay lag
- duplicate publish, consumers must be idempotent

## Pattern 10: Dead-letter and quarantine

```text
bad records -> DLQ/quarantine -> inspect -> fix/replay
```

Dung khi:

- bad records should not block all good data
- need audit and recovery

Design:

- include error reason
- include raw payload
- include schema version
- include retry count
- include owner/route

## Pattern 11: Fan-out

```text
one source -> multiple consumers
```

Examples:

- event topic consumed by fraud, analytics, ML
- CDC stream consumed by warehouse and search index

Risks:

- schema change affects many consumers
- unclear ownership
- duplicate transformations

Mitigation:

- contracts
- schema registry
- consumer isolation
- catalog

## Pattern 12: Fan-in

```text
multiple sources -> unified model
```

Examples:

- payments from multiple providers
- events from web/iOS/Android
- customer data from CRM/app/support

Risks:

- inconsistent semantics
- duplicate entities
- identity resolution
- source priority rules

Mitigation:

- canonical model
- source precedence
- matching rules
- data quality checks

## Architecture mindset

Chon pattern dua tren:

- latency
- data mutability
- volume
- correctness need
- replay need
- team skill
- cost
- operational complexity

Neu system design answer chi noi tool ma khong noi pattern, cau tra loi se yeu.

## Production mindset

Moi pattern can:

- source contract
- idempotency
- run metadata
- quality checks
- observability
- recovery path
- ownership

Pattern khong production-ready neu khong co replay/backfill.

## Debugging mindset

Debug theo pattern:

- Batch ELT: check source row count, partitions, dbt lineage, tests.
- CDC: check connector lag, changelog, deletes, ordering.
- Streaming: check lag, DLQ, state, sink.
- Medallion: check layer boundary where bad data first appears.
- Fan-in: check source-specific mappings and identity rules.

## Real-world failures

- Lambda architecture batch/stream logic drift, dashboard hien 2 so khac nhau.
- Outbox relay publish duplicate, consumer khong idempotent.
- Fan-in customer model merge sai 2 nguoi khac nhau.
- Micro-batch window overlap tao duplicate.
- DLQ ton tai nhung khong ai monitor, mat data hang tuan.

## Trade-offs

- Batch simple vs streaming low latency.
- CDC generic vs semantic events clean.
- Lambda accurate + realtime vs duplicate logic.
- Kappa simpler conceptually vs replay cost.
- Medallion clean layers vs more tables/jobs.
- Quarantine keeps pipeline moving vs hides quality issues if not monitored.

## Cost considerations

- Streaming cost lien tuc.
- Batch cost theo schedule/backfill.
- CDC cost theo connector + storage changelog + merge.
- Medallion tang storage nhung giam recomputation.
- Fan-out co the duplicate processing cost.
- Pre-aggregation giam serving cost nhung tang build cost.

## Exercises

1. Map ecommerce analytics vao Batch ELT pattern.
2. Map fraud detection vao streaming pattern.
3. Map OLTP replication vao CDC pattern.
4. Compare Lambda vs Kappa cho clickstream.
5. Design DLQ schema.
6. Design outbox event for order paid.
7. Write failure handling for fan-in payments.

## Mini project

Design pipeline pattern catalog for a company:

- orders CDC
- clickstream events
- daily finance reporting
- realtime fraud
- customer 360 fan-in
- lakehouse medallion

For each:

- pattern
- why chosen
- failure modes
- quality checks
- replay/backfill
- cost risk

## Interview questions

- ETL va ELT khac nhau nhu the nao?
- Lambda vs Kappa architecture?
- Medallion architecture giai quyet van de gi?
- Khi nao dung CDC thay vi API polling?
- Outbox pattern la gi?
- DLQ nen chua gi?
- Fan-in identity resolution kho o dau?
- Micro-batch trade-off gi?

## GitHub outputs

- `patterns/pipeline_pattern_catalog.md`
- `patterns/dlq_schema.sql`
- `patterns/outbox_order_paid.md`
- `patterns/failure_modes.md`
- `patterns/replay_strategy.md`

## Production upgrade: pattern decision matrix

| Pattern | Latency | Complexity | Cost | Replay | Correctness risk | Best for |
| --- | --- | --- | --- | --- | --- | --- |
| Batch ELT | hours/day | low | low/medium | easy | late data/incremental bugs | BI, reporting |
| Micro-batch | minutes | medium | medium | medium | boundary duplicates | near-real-time marts |
| CDC | seconds/minutes | high | medium/high | hard | ordering/deletes/schema | DB replication |
| Event streaming | seconds | high | high | hard | duplicates/order/DLQ | product events |
| Outbox | seconds/minutes | medium/high | medium | medium | app integration | reliable domain events |
| Lambda | mixed | high | high | hard | two logic paths diverge | strict realtime + batch |
| Kappa | low | high | medium/high | replay dependent | stream correctness | event-first systems |

### Decision tree

```text
Need sub-minute latency?
  yes -> streaming/event/CDC
  no -> batch ELT is probably enough

Source is operational DB and need changes?
  yes -> CDC or outbox

Need business domain event semantics?
  yes -> outbox/domain events
  no -> CDC may be enough

Can tolerate duplicates and build idempotent sink?
  no -> avoid streaming until correctness design is ready
```

### Migration path

Common evolution:

```text
nightly batch
  -> hourly micro-batch
  -> CDC for core tables
  -> event streaming for product/domain events
```

Do not jump to Kafka/Flink just because it is modern. Latency requirements, team maturity and correctness risk should drive architecture.

### Anti-patterns by use case

- Streaming for daily dashboard with no freshness need.
- CDC without delete handling.
- Batch append without idempotency.
- DLQ without replay owner.
- Lambda with batch and streaming logic diverging.
- Fan-out to many consumers without schema contract.

### Failure mode comparison

Batch failures are usually visible and replayable. Streaming failures can silently accumulate lag, duplicate side effects or poison pills. CDC failures can corrupt current state if deletes/order are mishandled. Choose pattern by failure mode you can operate, not by diagram appeal.
