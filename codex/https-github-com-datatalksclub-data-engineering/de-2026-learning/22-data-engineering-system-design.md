# Data Engineering System Design Interview Handbook

## Muc dich cua handbook

File nay la handbook system design interview cho Data Engineer. Muc tieu khong phai hoc thuoc ten tool, ma hoc cach suy nghi khi thiet ke mot data platform that:

- Hieu yeu cau business truoc khi ve architecture.
- Tach ro batch, streaming, CDC, warehouse, lakehouse, metrics, quality.
- Biet noi ve latency, throughput, cost, reliability, replay, backfill.
- Biet debug pipeline khi data sai, tre, duplicate hoac mat.
- Biet trade-off giua don gian, nhanh, reprocess duoc, va cost.

Trong phong van senior-level, cau tra loi tot khong chi la:

> Kafka -> Spark -> S3 -> Snowflake.

Cau tra loi tot phai noi duoc:

- Vi sao can Kafka?
- Event schema duoc quan ly the nao?
- Neu consumer fail thi replay ra sao?
- Neu source gui duplicate thi dedup o dau?
- Neu late event den sau 3 ngay thi metric co cap nhat khong?
- Neu query cost tang 10 lan thi toi uu o dau?
- Neu BI dashboard sai thi debug theo duong nao?

## Framework tra loi system design

Dung framework nay cho moi bai:

1. Clarify requirements.
2. Define data sources.
3. Define consumers and SLAs.
4. Estimate scale.
5. Choose architecture.
6. Define storage layers.
7. Define processing model.
8. Define data quality and contracts.
9. Define failure handling.
10. Define replay/backfill.
11. Define cost controls.
12. Define monitoring and operations.
13. Explain trade-offs.

## 1. Clarify requirements

Truoc khi ve system, hoi:

- Data source la gi?
- Data volume hien tai va tuong lai?
- Latency can thiet la bao nhieu?
- Use case la analytics, ML, fraud, reporting, operations hay compliance?
- Co can exactly-once khong, hay at-least-once + idempotency la du?
- Co can reprocess lich su khong?
- Data co PII/financial/compliance khong?
- Ai la consumer: BI, data science, product, finance, operations, customer-facing app?
- Dashboard sai trong bao lau la chap nhan duoc?

Neu bo qua requirements, architecture se thanh tool shopping.

## 2. Core concepts

### Batch

Batch xu ly data theo lo:

- hourly
- daily
- weekly
- backfill
- historical reprocessing

Dung khi:

- Latency khong qua gat.
- Can cost-efficient.
- Can logic phuc tap va de debug.
- Data co the reprocess.

Rui ro:

- Data tre.
- Backfill lon co the lam nghe warehouse/cluster.
- Neu incremental sai, co the miss data cu.

### Streaming

Streaming xu ly event gan real-time:

- clickstream
- fraud
- operational monitoring
- personalization
- real-time metrics

Dung khi:

- Can latency giay/phut.
- Event den lien tuc.
- Consumer can react nhanh.

Rui ro:

- Duplicate.
- Out-of-order events.
- Schema evolution.
- Consumer lag.
- Retry storms.
- State management phuc tap.

### CDC

CDC capture thay doi tu database:

- insert
- update
- delete

Dung khi:

- Can replicate transactional DB sang lake/warehouse.
- Muon gan real-time ma khong query truc tiep OLTP.
- Can historical change log.

Rui ro:

- Schema drift.
- Snapshot + binlog ordering.
- Delete handling.
- Primary key thay doi.
- Downstream replay.
- Source DB load.

### Lake

Data lake luu raw/semi-structured data tren object storage:

- S3
- GCS
- ADLS

Uu diem:

- Reprocess duoc.
- Storage re.
- Luu nhieu format.
- Tach storage va compute.

Nhuoc diem:

- Neu khong co governance se thanh data swamp.
- Query performance phu thuoc format, partition, metadata.
- Harder for business users.

### Warehouse

Warehouse toi uu cho analytics SQL:

- BigQuery
- Snowflake
- Redshift
- Databricks SQL

Uu diem:

- SQL-friendly.
- BI-friendly.
- Performance tot.
- Governance va access control tot.

Nhuoc diem:

- Cost query/compute co the cao.
- Raw unstructured data khong phai luc nao phu hop.
- Vendor-specific features.

### Lakehouse

Lakehouse ket hop lake storage voi warehouse-like table management:

- Delta Lake
- Apache Iceberg
- Apache Hudi

Uu diem:

- ACID tables tren object storage.
- Time travel.
- Schema evolution.
- Merge/upsert.
- Batch + streaming cung mot storage layer.

Nhuoc diem:

- Metadata/catalog phuc tap.
- Compaction/maintenance can quan ly.
- Query performance phu thuoc engine va table layout.

## 3. Architecture building blocks

### Ingestion layer

Nguon du lieu:

- application events
- OLTP database
- SaaS APIs
- files
- logs
- third-party data

Pattern:

- batch extract
- CDC
- streaming producer
- file landing
- webhook ingestion

Can thiet ke:

- authentication
- retries
- rate limits
- schema validation
- raw persistence
- idempotency key

### Raw layer

Raw layer nen giu gan voi source:

- immutable
- append-only neu co the
- co ingestion timestamp
- co source metadata
- co schema version

Muc tieu:

- replay
- audit
- debug
- reprocess khi transform sai

### Processing layer

Batch engines:

- SQL warehouse
- Spark
- dbt
- Beam

Streaming engines:

- Kafka Streams
- Flink
- Spark Structured Streaming
- Beam

Chon engine theo:

- latency
- stateful processing
- volume
- team skill
- operational complexity

### Serving layer

Serving co the la:

- warehouse marts
- OLAP store
- metrics layer
- feature store
- search/index store
- API serving DB

Khong nen ep mot storage phuc vu moi use case.

### Orchestration layer

Dung de:

- schedule
- dependencies
- retry
- backfill
- monitoring
- parameterized runs

Examples:

- Airflow
- Dagster
- Kestra
- Prefect

### Governance layer

Can co:

- catalog
- lineage
- access control
- PII classification
- retention
- audit logs
- data contracts

## 4. Clickstream architecture

### Problem

Design clickstream platform cho web/mobile app. Product team muon phan tich page views, sessions, funnels, conversion, retention. Mot so metrics can gan real-time.

### Requirements

Functional:

- Collect client events.
- Validate event schema.
- Store raw events.
- Build session, funnel, conversion metrics.
- Support BI dashboard.
- Support replay/backfill.

Non-functional:

- High throughput.
- Low latency cho realtime dashboard.
- Durable raw storage.
- Handle duplicate events.
- Handle out-of-order events.
- Cost-efficient historical queries.

### Reference architecture

```text
Web/Mobile SDK
    -> Event Collector API
    -> Kafka/Pub/Sub
    -> Raw object storage
    -> Streaming processor
    -> Realtime OLAP store
    -> Dashboard

Raw object storage
    -> Batch processing/dbt/Spark
    -> Warehouse marts
    -> BI/analytics
```

### Architecture mindset

Clickstream nen co 2 duong:

- hot path: gan real-time, phuc vu dashboard nhanh
- cold path: raw durable storage, phuc vu batch accuracy va replay

Hot path co the co approximate metrics. Cold path la source of truth cho reporting chinh thuc.

### Bottlenecks

- Collector API bi overload.
- Kafka/PubSub partition khong du.
- Consumer lag.
- Event schema thay doi khong compatible.
- Small files trong lake.
- Sessionization state qua lon.
- Dashboard query scan qua nhieu data.

### Scaling limits

- Scale collector horizontally.
- Partition event stream theo `user_id` hoac `session_id`.
- Tang partitions can plan truoc vi ordering bi anh huong.
- Streaming state can TTL.
- Raw storage partition theo event date va ingestion date.

### Failure handling

- Collector fail: client retry voi idempotency key.
- Queue fail: buffer client/server neu co the.
- Consumer fail: replay tu offset.
- Bad event: route vao dead-letter topic/table.
- Schema invalid: reject hoac quarantine.

### Latency considerations

- Client batching giam cost nhung tang latency.
- Kafka/PubSub latency thap nhung processing state co the cham.
- BI warehouse khong phai luc nao phu hop cho dashboard sub-second.

### Cost considerations

- Raw JSON de debug nhung ton storage/query cost.
- Parquet/Avro tot hon cho analytics.
- Partition dung de giam scan.
- Realtime OLAP store co compute/storage cost rieng.
- Khong query raw events truc tiep cho dashboard hang ngay neu volume lon.

### Recovery strategy

- Raw events phai duoc luu tru durable.
- Streaming output co the rebuild tu raw/queue neu retention du.
- Neu business logic session sai, backfill session table tu raw.
- Neu duplicate event, dedup bang `event_id`.

### Trade-offs

- Exactly-once streaming rat phuc tap; thuong dung at-least-once + idempotent sink.
- Realtime metrics nhanh nhung co the khac final batch metrics.
- Client-side tracking linh hoat nhung de bi adblock/network loss.
- Server-side tracking on dinh hon nhung it context UI hon.

## 5. Realtime analytics architecture

### Problem

Business muon dashboard cap nhat trong vai giay: active users, orders per minute, error rate, fraud alerts, campaign performance.

### Requirements

- Latency: seconds to minutes.
- High availability.
- Support time-window aggregations.
- Handle out-of-order events.
- Dashboard query nhanh.
- Graceful degradation khi stream bi tre.

### Reference architecture

```text
Events
  -> Kafka/PubSub
  -> Stream processor
  -> Realtime serving store
  -> Dashboard/API

Events
  -> Raw lake
  -> Batch correction
  -> Warehouse source of truth
```

Serving stores:

- ClickHouse
- Druid
- Pinot
- Elasticsearch/OpenSearch for log-like analytics
- Redis for simple counters
- BigQuery/Snowflake for minute-level but not ultra-low latency

### Bottlenecks

- Window state memory.
- High-cardinality dimensions.
- Consumer lag.
- Dashboard fanout.
- Hot keys.
- Late events forcing corrections.

### Failure handling

- Checkpoint offsets/state.
- Dead-letter invalid events.
- Idempotent writes to serving store.
- Alert on consumer lag.
- Fallback dashboard shows stale data with timestamp.

### Latency considerations

- Tumbling windows easier than sliding/session windows.
- Smaller windows increase state and write frequency.
- Late event policy must be explicit: drop, update, or correction event.

### Cost considerations

- Realtime stores can be expensive.
- Pre-aggregate common metrics.
- Limit cardinality.
- TTL raw hot data if cold data exists in lake.
- Avoid storing every dimension in realtime serving layer.

### Recovery strategy

- Replay from Kafka retention for short outages.
- Rebuild from raw lake for longer outages.
- Batch reconciliation corrects realtime approximations.

### Trade-offs

- Low latency vs exact correctness.
- Pre-aggregation vs flexible ad hoc query.
- Long retention in Kafka vs cheaper object storage.
- Stateful streaming power vs operational complexity.

## 6. CDC ingestion platform

### Problem

Design CDC platform replicate changes from many OLTP databases into warehouse/lakehouse.

### Requirements

- Capture inserts, updates, deletes.
- Initial snapshot + continuous changes.
- Minimal source DB impact.
- Schema evolution support.
- Exactly-once-like downstream behavior.
- Replay/backfill.
- Auditability.

### Reference architecture

```text
OLTP DB
  -> CDC connector
  -> Kafka/PubSub topics
  -> Raw changelog storage
  -> Stream/batch apply
  -> Bronze/Silver tables
  -> Warehouse marts
```

Common tools:

- Debezium
- Kafka Connect
- Datastream
- DMS
- Fivetran/Airbyte for managed extraction

### Architecture mindset

CDC is not just "copy table". It is a log of change events. Downstream must understand:

- operation type
- primary key
- before/after values
- transaction ordering
- delete events
- schema version
- source timestamp vs ingestion timestamp

### Bottlenecks

- Source DB transaction log retention.
- Connector lag.
- Large initial snapshot.
- Schema change during snapshot.
- Hot tables with high update rate.
- Downstream merge cost.

### Scaling limits

- Split connectors by database/table.
- Use topic partitioning by primary key.
- Avoid too many small tables creating operational overhead.
- Large merge operations in warehouse can be expensive.

### Failure handling

- Connector offset checkpointing.
- Snapshot resume.
- Dead-letter incompatible schema.
- Alert on replication lag.
- Validate row counts/checksums.

### Latency considerations

- CDC latency includes source log delay, connector poll, broker, apply job.
- Warehouse merge frequency trades latency for cost.
- Micro-batch every minute can be cheaper than per-event apply.

### Cost considerations

- Storing full changelog increases storage but enables audit/replay.
- Frequent merges are expensive.
- Compaction needed for lakehouse tables.
- Managed CDC tools cost more but reduce ops burden.

### Recovery strategy

- Keep raw changelog immutable.
- Rebuild current-state table from changelog.
- For corrupted downstream table, truncate and replay from raw changelog.
- If source log retention expired, need new snapshot.

### Trade-offs

- Managed CDC vs self-hosted Debezium.
- Low-latency apply vs batch merge cost.
- Store only latest state vs full history.
- Delete hard-delete vs soft-delete with tombstone.

## 7. Warehouse architecture

### Problem

Design enterprise warehouse for analytics, finance reporting, product metrics, and BI.

### Requirements

- Reliable daily/hourly reporting.
- SQL-friendly.
- Clear raw/staging/mart layers.
- Governance and access control.
- Cost visibility.
- Data quality checks.
- Backfill support.

### Reference architecture

```text
Sources
  -> Ingestion
  -> Raw layer
  -> Staging models
  -> Intermediate models
  -> Fact/dimension marts
  -> Semantic/metrics layer
  -> BI/Reverse ETL/ML
```

### Warehouse layers

Raw:

- source-like
- immutable or append-only
- minimally transformed

Staging:

- renamed columns
- cast types
- normalized statuses
- deduped source records

Intermediate:

- reusable business logic
- joins/aggregations too complex for staging

Marts:

- facts
- dimensions
- business metrics
- dashboard-ready tables

### Bottlenecks

- Overloaded transformation DAG.
- Large joins without partition filters.
- Poor model layering.
- BI users querying raw tables.
- Metric definitions duplicated.
- Warehouse compute contention.

### Scaling limits

- Partition large fact tables.
- Cluster/sort on common filters.
- Pre-aggregate heavy marts.
- Separate dev/prod warehouses or compute pools.
- Materialize expensive models.

### Failure handling

- dbt tests or SQL checks fail fast.
- Downstream marts should not publish partial data.
- Use atomic table swaps when possible.
- Keep previous successful version for rollback.

### Latency considerations

- Finance reporting may accept daily.
- Product analytics may need hourly.
- Operational dashboards may need near-real-time.
- Do not force all consumers into same latency/cost profile.

### Cost considerations

- Track query cost by user/team/model.
- Avoid `select *` on wide tables.
- Partition filters required for large tables.
- Materialize only when repeated query cost justifies it.
- Expire temporary tables.

### Recovery strategy

- Rebuild marts from staging/raw.
- Backfill by partition date.
- Maintain run metadata.
- Reconcile source vs target after recovery.

### Trade-offs

- Many small marts: easier ownership but more duplication.
- One giant table: easy BI but expensive and unclear grain.
- View materialization cheap storage but expensive repeated query.
- Table materialization faster query but higher storage/build cost.

## 8. Lakehouse architecture

### Problem

Design a lakehouse for batch analytics, ML, CDC, and large-scale historical data using object storage.

### Requirements

- Store raw and curated data.
- Support ACID table updates.
- Support schema evolution.
- Support time travel.
- Support batch and streaming.
- Efficient query performance.
- Cost-effective storage.

### Reference architecture

```text
Sources
  -> Raw landing zone
  -> Bronze tables
  -> Silver cleaned tables
  -> Gold marts/features
  -> BI/ML/warehouse sync

Catalog + table format + compute engines
```

Table formats:

- Delta Lake
- Iceberg
- Hudi

Compute:

- Spark
- Flink
- Trino
- Databricks
- Snowflake external tables
- BigQuery external/BigLake patterns

### Architecture mindset

Lakehouse quality depends on table maintenance:

- compaction
- vacuum/retention
- metadata cleanup
- clustering/z-order/sorting
- schema governance
- partition strategy

Without maintenance, lakehouse becomes slow and unreliable.

### Bottlenecks

- Too many small files.
- Bad partitioning.
- Metadata explosion.
- Compaction backlog.
- Concurrent writes.
- Slow object storage listing.
- Query engines reading too many files.

### Scaling limits

- Partition only on useful, low/medium-cardinality columns.
- Compact small files.
- Use table statistics.
- Separate raw append and curated merge workloads.
- Avoid high-frequency tiny commits.

### Failure handling

- ACID commit log protects partial writes.
- Time travel can rollback bad writes.
- Failed compaction should be retryable.
- Corrupt files need quarantine and rebuild.

### Latency considerations

- Streaming to lakehouse works but requires careful checkpointing.
- Very low latency dashboards may need OLAP serving store.
- Micro-batch lakehouse is often pragmatic.

### Cost considerations

- Storage cheap, compute can be expensive.
- Bad file layout increases query cost.
- Compaction costs compute but saves query cost.
- Time travel retention increases storage.

### Recovery strategy

- Rollback table version.
- Rebuild silver/gold from bronze.
- Replay streaming from checkpoint or source offsets.
- Restore deleted files if retention allows.

### Trade-offs

- Lakehouse open format vs managed warehouse simplicity.
- Flexibility vs operational burden.
- Cheap storage vs query tuning complexity.
- Long time travel vs storage cost.

## 9. Streaming architecture

### Requirements

- Durable event transport.
- Low-latency processing.
- Backpressure handling.
- Ordering where needed.
- State management.
- Replay.
- Observability.

### Reference architecture

```text
Producers
  -> Event broker
  -> Stream processors
  -> Sinks
       -> lake
       -> warehouse
       -> realtime store
       -> alerting system
```

### Design decisions

Broker:

- Kafka for strong ecosystem and partition control.
- Pub/Sub/Kinesis for managed cloud operations.

Serialization:

- JSON for simplicity.
- Avro/Protobuf for schema and compactness.

Processing:

- Stateless map/filter is simple.
- Stateful windows/joins require checkpoints and state store.

Sinks:

- Idempotent sinks are critical.
- Upsert sinks need keys.
- Append sinks need downstream dedup.

### Bottlenecks

- Hot partitions.
- Slow consumers.
- Large state.
- Sink throughput.
- Serialization overhead.
- Network.

### Failure handling

- Producer retry with idempotency.
- Consumer retry with dead-letter queue.
- Offset commit after successful sink write.
- Checkpoint streaming state.
- Alert on lag.

### Recovery strategy

- Replay from broker retention.
- Rebuild from raw event archive.
- Reset consumer group offsets carefully.
- Reprocess stateful job from checkpoint or from scratch.

### Trade-offs

- Ordering vs parallelism.
- Large broker retention vs object storage archive.
- Exactly-once claims vs operational reality.
- Rich stream processing vs simpler micro-batch.

## 10. Batch architecture

### Requirements

- Reliable scheduled processing.
- Large historical processing.
- Backfill by date.
- Cost-efficient compute.
- Clear run status.
- Data quality gates.

### Reference architecture

```text
Sources/raw lake
  -> Orchestrator
  -> Batch compute
  -> Warehouse/lakehouse tables
  -> Quality checks
  -> Publish marts
```

### Bottlenecks

- One large daily job blocks all downstream.
- Skewed joins.
- Large shuffle.
- Warehouse queue contention.
- Backfill competes with production jobs.

### Failure handling

- Retry transient failures.
- Fail fast on data quality.
- Use partition-level writes.
- Avoid partial publish.
- Keep run metadata.

### Recovery strategy

- Re-run affected partition.
- Backfill date range.
- Rebuild table from raw.
- Restore previous table version.

### Trade-offs

- Full refresh simpler but costly.
- Incremental cheaper but harder.
- Hourly batch lower latency but more orchestration overhead.
- Daily batch simpler but staler.

## 11. Event-driven systems

### Problem

Use events to trigger downstream actions: order created, payment captured, account updated, file arrived.

### Requirements

- Decouple producers and consumers.
- Support multiple consumers.
- Durable event delivery.
- Handle retries and duplicates.
- Enforce event contracts.

### Architecture mindset

Events should represent business facts, not internal implementation noise.

Good event:

- `OrderPaid`
- `CustomerCreated`
- `PaymentRefunded`

Weak event:

- `DatabaseRowChanged` for business consumers without semantic meaning

### Bottlenecks

- Too many event types without ownership.
- Schema changes break consumers.
- Consumers assume ordering across partitions.
- Duplicate processing.
- No event catalog.

### Failure handling

- Dead-letter topics.
- Idempotent consumers.
- Versioned schemas.
- Consumer-owned retries.
- Poison message quarantine.

### Trade-offs

- Event-driven is scalable but harder to trace.
- Synchronous API is simpler but tightly coupled.
- Semantic events are clean but require product/domain alignment.
- CDC events are easy to capture but less business-friendly.

## 12. Reliability design

### Reliability principles

- Raw data must be durable.
- Pipelines must be idempotent.
- Metrics must have owners.
- Quality checks must run before publish.
- Backfill must be a first-class workflow.
- Monitoring must cover data, not just jobs.

### Reliability patterns

Idempotent write:

- Same input run twice gives same output.
- Use merge/upsert or overwrite partition.

Atomic publish:

- Build temp table.
- Validate.
- Swap/rename to production.

Quarantine:

- Bad records do not block all good data.
- But bad record counts must alert.

Circuit breaker:

- Stop downstream publish if data anomaly is severe.

Run metadata:

- run_id
- source window
- row counts
- status
- started_at/finished_at

### Failure modes

- Source sends duplicate.
- Source schema changes.
- Orchestrator retries non-idempotent task.
- Warehouse query partially updates table.
- Backfill overwrites current data.
- Late data changes historical metrics.
- Consumer lag grows silently.

## 13. Scaling bottlenecks

### Ingestion bottlenecks

- API rate limits.
- Source DB load.
- Broker partitions.
- File count explosion.

Mitigation:

- incremental extraction
- CDC
- batching
- partitioning
- backpressure

### Processing bottlenecks

- skewed keys
- large joins
- shuffle
- state size
- inefficient SQL

Mitigation:

- pre-aggregate
- broadcast small dimensions
- repartition carefully
- materialize intermediate tables
- optimize table layout

### Storage bottlenecks

- small files
- bad partitioning
- metadata explosion
- unbounded retention

Mitigation:

- compaction
- partition pruning
- lifecycle policies
- table maintenance

### Serving bottlenecks

- dashboard fanout
- high-cardinality filters
- no cache
- too much ad hoc access to raw

Mitigation:

- aggregate marts
- semantic layer
- cache
- workload isolation
- query limits

## 14. Cost optimization

### Cost levers

Storage:

- compression
- Parquet/ORC
- lifecycle retention
- delete temp data

Compute:

- right-size clusters/warehouses
- autosuspend
- materialize expensive repeated queries
- avoid unnecessary full refresh

Query:

- partition filters
- column pruning
- clustering
- pre-aggregation

Streaming:

- retention tuning
- partition count
- state TTL
- batch sink writes

### Cost anti-patterns

- BI dashboard queries raw event table directly.
- Every dbt model materialized as table.
- Full refresh of huge facts daily.
- Kafka retention used as long-term archive.
- Lakehouse never compacts files.
- No ownership for expensive queries.

## 15. Data quality architecture

### Layers of quality

At ingestion:

- schema validation
- required fields
- event version
- malformed records to quarantine

At staging:

- type casting
- deduplication
- accepted values
- primary key checks

At marts:

- referential integrity
- metric reconciliation
- freshness
- volume anomaly
- business rules

At serving:

- dashboard freshness indicator
- metric owner
- certified dataset

### Quality dimensions

- completeness
- uniqueness
- freshness
- validity
- consistency
- accuracy

### Operational design

Every critical dataset should have:

- owner
- SLA
- source contract
- tests
- lineage
- incident runbook
- backfill procedure

### Failure handling

- Warn for minor anomalies.
- Block publish for severe anomalies.
- Quarantine invalid records.
- Alert owner with context and sample rows.

## 16. Replay and backfill systems

### Why replay matters

Replay/backfill is required when:

- business logic changes
- bug corrupts output
- late data arrives
- source fixes historical data
- new metric needs history
- downstream table lost/corrupted

### Replay architecture

```text
Raw immutable data
  -> parameterized processing by date/key range
  -> temp output
  -> validation
  -> atomic publish
```

### Backfill requirements

- Select date range.
- Isolate from production jobs.
- Track run metadata.
- Validate row counts and metrics.
- Avoid overwriting newer data incorrectly.
- Throttle to control cost.

### Backfill disasters

- Backfill uses current dimension values for historical facts.
- Backfill overwrites production table without validation.
- Backfill triggers downstream alerts for every historical partition.
- Backfill consumes all warehouse compute.
- Backfill misses late-arriving source data because watermark is wrong.

### Recovery strategy

- Back up affected partitions.
- Reprocess into temp tables.
- Compare old vs new.
- Publish partition by partition.
- Keep audit log of changed partitions.

## 17. Real design scenario: Uber analytics pipeline

### Problem

Design analytics pipeline for Uber-like ride platform.

Use cases:

- trips completed by city
- driver utilization
- rider funnel
- surge pricing analysis
- cancellations
- real-time marketplace monitoring

### Requirements

- Trip events from mobile/backend.
- Payment and settlement data.
- Driver/rider dimension changes.
- Realtime operational dashboards.
- Daily finance-grade reporting.
- Historical backfill.

### Architecture

```text
Mobile/backend events
  -> Kafka/PubSub
  -> raw event lake
  -> realtime stream processing
  -> operational metrics store

OLTP trip/payment DB
  -> CDC
  -> raw changelog
  -> warehouse/lakehouse silver tables
  -> facts/dimensions
  -> BI/finance marts
```

### Key facts and dimensions

Facts:

- `fct_trips`
- `fct_trip_events`
- `fct_payments`
- `fct_driver_online_sessions`

Dimensions:

- `dim_drivers`
- `dim_riders`
- `dim_city`
- `dim_vehicle`

### Bottlenecks

- High event volume.
- Location pings too large for warehouse raw querying.
- Late trip state changes.
- Payment reconciliation.
- City/timezone handling.

### Trade-offs

- Realtime marketplace metrics can be approximate.
- Finance trip revenue must be batch reconciled.
- Location stream may go to specialized geospatial/OLAP storage, not only warehouse.

### Failure handling

- CDC replay for trip/payment state.
- Event dedup by event_id.
- Quality checks for trip lifecycle validity.
- Reconcile completed trips vs payments.

## 18. Real design scenario: Ecommerce warehouse

### Requirements

- Orders, customers, products, inventory, payments.
- Daily revenue dashboard.
- Customer LTV.
- Product performance.
- Refund/cancellation handling.
- Finance reconciliation.

### Architecture

```text
Shop database CDC/API
  -> raw layer
  -> staging
  -> dim_customers/dim_products
  -> fct_orders/fct_order_items/fct_payments
  -> marts
  -> BI
```

### Bottlenecks

- Orders to order_items join explosion.
- Product category changes causing historical reporting issues.
- Refunds arriving days later.
- Payment provider reconciliation.

### Reliability

- Dedup raw orders by order_id + updated_at.
- Model refunds explicitly.
- Use SCD2 for product category if historical category matters.
- Reconcile gross item amount vs captured/refunded payment.

### Cost

- Partition facts by order_date/payment_date.
- Cluster by customer_id/product_id.
- Pre-aggregate daily revenue.
- Limit BI access to marts, not raw.

## 19. Real design scenario: Realtime fraud pipeline

### Requirements

- Score transactions in seconds.
- Use recent user/device/payment behavior.
- Alert/block suspicious transactions.
- Store features and decisions for audit.
- Reprocess history for model evaluation.

### Architecture

```text
Transaction event
  -> Kafka/PubSub
  -> stream feature computation
  -> feature store / low-latency store
  -> fraud model/rules engine
  -> decision topic
  -> audit lake/warehouse
```

### Bottlenecks

- Low latency requirement.
- Stateful features by user/card/device.
- Hot users/devices.
- Model service latency.
- Exactly-once decision semantics.

### Failure handling

- If model unavailable, fallback rules.
- If feature store stale, degrade decision with lower confidence.
- All decisions written to audit log.
- Replay events for model backtesting.

### Trade-offs

- Blocking fraud requires low latency but may false-positive.
- More features improve accuracy but increase latency.
- Synchronous scoring easier to enforce but creates dependency.
- Asynchronous scoring more scalable but may detect after transaction.

## 20. Real design scenario: CDC ingestion platform

### Requirements

- Ingest 100+ tables from multiple OLTP DBs.
- Support initial snapshot and continuous replication.
- Deliver to lakehouse and warehouse.
- Handle schema changes.
- Provide monitoring and replay.

### Architecture

```text
Source DBs
  -> CDC connectors
  -> broker topics per table
  -> raw changelog storage
  -> bronze CDC tables
  -> silver current-state tables
  -> marts
```

### Operational design

- Connector per database or bounded group of tables.
- Topic naming convention.
- Schema registry.
- Lag monitoring.
- DLQ for incompatible events.
- Table onboarding checklist.

### Recovery

- If connector down within log retention: resume.
- If log retention expired: resnapshot affected tables.
- If downstream corrupted: replay raw changelog.

## 21. Real design scenario: Lakehouse platform

### Requirements

- Central storage for raw, cleaned, and curated data.
- Support BI, ML, and data science.
- Open table format.
- Large historical datasets.
- Batch and streaming ingestion.

### Architecture

```text
Object storage
  -> bronze
  -> silver
  -> gold
Catalog
  -> permissions
  -> discovery
Compute engines
  -> Spark/Flink/Trino/warehouse integration
```

### Design decisions

- Choose Iceberg/Delta/Hudi.
- Choose catalog.
- Define table maintenance.
- Define partition strategy.
- Define access policy.

### Bottlenecks

- Small files.
- Too many partitions.
- Metadata scaling.
- Concurrent writes.
- Unclear ownership.

### Reliability

- ACID table format.
- Time travel.
- Compaction jobs.
- Data quality gates.
- Table version rollback.

## 22. Real design scenario: Metrics platform

### Problem

Company has inconsistent metrics. Revenue in finance dashboard differs from product dashboard.

### Requirements

- Central metric definitions.
- Consistent dimensions.
- Governed access.
- BI and API consumption.
- Versioned metrics.
- Tests and lineage.

### Architecture

```text
Warehouse marts
  -> semantic/metrics layer
  -> BI tools
  -> metrics API
  -> notebooks/experiments
```

### Design

- Define canonical facts and dimensions.
- Define metric owner.
- Define metric formula.
- Define allowed dimensions.
- Define freshness SLA.
- Define tests.

### Bottlenecks

- Teams bypass semantic layer.
- Metrics computed differently in dashboards.
- Dimensions have inconsistent grain.
- Slowly changing dimensions not handled.

### Failure handling

- Certified metrics only for executive reporting.
- Metric diff checks after changes.
- Lineage alerts for upstream changes.
- Rollback metric definitions.

### Trade-offs

- Central governance vs team autonomy.
- Semantic layer flexibility vs complexity.
- Precomputed metrics vs dynamic query.

## 23. Interview answer templates

### Template: design a batch warehouse

1. Clarify sources, consumers, latency, scale.
2. Land raw data immutably.
3. Build staging to clean/dedup.
4. Build facts/dimensions with clear grain.
5. Build marts/semantic layer.
6. Add quality checks before publish.
7. Add orchestration, retries, backfill.
8. Add cost controls and monitoring.
9. Explain trade-offs.

### Template: design a streaming pipeline

1. Clarify latency and correctness.
2. Define event schema and keys.
3. Use broker for durable transport.
4. Add stream processor.
5. Choose serving store.
6. Archive raw events.
7. Handle duplicates/out-of-order.
8. Add lag monitoring and DLQ.
9. Define replay strategy.

### Template: design CDC platform

1. Clarify databases/tables/volume.
2. Initial snapshot + change stream.
3. Store immutable changelog.
4. Build current-state tables.
5. Handle deletes and schema evolution.
6. Monitor replication lag.
7. Support replay/resnapshot.
8. Reconcile row counts.

## 24. Senior-level trade-off language

Use this kind of phrasing:

- "I would separate hot path and cold path because realtime dashboards need low latency, while financial reporting needs correctness and replayability."
- "I would store raw immutable data first so downstream logic bugs can be fixed by reprocessing instead of asking the source to resend."
- "I would not chase exactly-once everywhere. I would design at-least-once ingestion with idempotent writes and deterministic deduplication."
- "I would avoid letting BI query raw events directly because it creates cost, performance, and semantic consistency problems."
- "I would use updated_at watermark with lookback for mutable source data, because event date filters miss late-arriving updates."

## 25. Questions interviewer may ask

- How do you design for replay?
- How do you handle duplicate events?
- How do you handle late-arriving data?
- How do you prevent join explosion?
- How do you reduce warehouse cost?
- How do you monitor data freshness?
- What happens if Kafka is down?
- What happens if CDC connector falls behind?
- How do you recover from a bad dbt model?
- How do you handle schema evolution?
- When do you choose batch over streaming?
- When do you need lakehouse instead of warehouse?
- How do you ensure metric consistency?
- How do you backfill 2 years of data safely?

## 26. Final checklist for any DE system design

## 27. Estimation worksheet

Use numbers early. A senior answer without capacity estimate feels like architecture theater.

### Input estimation

```text
events_per_second:
avg_event_size_bytes:
peak_multiplier:
retention_days:
daily_raw_gb = eps * avg_size * 86400 / 1024^3
peak_eps = eps * peak_multiplier
```

Example:

```text
5,000 events/sec * 1 KB * 86,400 sec = about 432 GB/day raw
peak 5x = 25,000 events/sec
30-day retention = about 13 TB raw before compression
```

### Kafka partition estimate

Estimate by:

- target throughput per partition.
- ordering key.
- consumer parallelism.
- future growth.

Do not choose 3 partitions randomly. Explain trade-off: too few limits parallelism; too many increases overhead and rebalance complexity.

### Warehouse estimate

Estimate:

- GB/day ingested.
- fact table growth.
- common query scan size.
- partition strategy.
- dashboard refresh frequency.

### Interview follow-up traps

Common traps:

- "What if traffic grows 10x?"
- "What if events arrive late?"
- "How do you replay one day?"
- "What if Kafka is down?"
- "What if dashboard is wrong but pipeline succeeded?"
- "How do you control cost?"

Good answer pivots from diagram to operation: bottleneck, failure mode, mitigation, trade-off.

- [ ] Requirements clarified.
- [ ] Latency target stated.
- [ ] Data volume estimated.
- [ ] Source systems identified.
- [ ] Raw durable storage included.
- [ ] Processing model justified.
- [ ] Storage/serving layer justified.
- [ ] Data quality checks included.
- [ ] Failure handling included.
- [ ] Replay/backfill included.
- [ ] Cost controls included.
- [ ] Monitoring included.
- [ ] Trade-offs explained.
- [ ] Operational ownership included.
