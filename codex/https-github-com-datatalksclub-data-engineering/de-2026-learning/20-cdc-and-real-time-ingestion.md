# CDC va Real-time Ingestion

## Vai tro

CDC va real-time ingestion la nen tang cho data platform can du lieu moi nhanh: operational analytics, realtime dashboards, fraud, personalization, search sync, reverse ETL, warehouse near-real-time.

Nhung CDC/streaming khong phai "batch nhanh hon". No co failure modes rieng:

- duplicate events
- out-of-order changes
- schema drift
- delete handling
- connector lag
- source log retention expired
- consumer replay
- exactly-once illusion

## Muc tieu can dat

- Hieu CDC architecture.
- Hieu snapshot + change stream.
- Hieu Kafka/PubSub/Kinesis ingestion.
- Biet thiet ke raw changelog, current-state table, audit history.
- Biet handle updates/deletes/schema evolution.
- Biet latency/cost/reliability trade-offs.
- Biet debug connector lag va consumer lag.

## Khai niem can nam

- CDC.
- WAL/binlog/transaction log.
- Snapshot.
- Change event.
- Insert/update/delete.
- Before/after image.
- Offset.
- LSN.
- Topic.
- Partition.
- Consumer group.
- Schema registry.
- Tombstone.
- Upsert.
- Outbox pattern.
- Dead-letter queue.

## Architecture mindset

CDC platform co 4 layer:

```text
source database
  -> capture layer
  -> durable event/changelog layer
  -> apply layer
  -> curated serving layer
```

Khong nen apply truc tiep CDC vao final marts. Nen giu raw changelog de replay va audit.

CDC output thuong tao 2 loai table:

- changelog table: moi change event la mot row
- current-state table: moi primary key la current row

## CDC reference architecture

```text
Postgres/MySQL
  -> Debezium/Datastream/DMS
  -> Kafka/PubSub/Kinesis
  -> raw changelog storage
  -> bronze CDC table
  -> silver current-state table
  -> marts
```

Managed alternatives:

- Fivetran
- Airbyte Cloud
- Stitch
- cloud-native CDC

Self-managed:

- Debezium + Kafka Connect
- custom log readers rarely recommended

## Real-time ingestion architecture

```text
application service
  -> event producer
  -> broker
  -> stream processor
  -> raw lake + realtime store + warehouse sink
```

Producer must define:

- event name
- event_id
- event timestamp
- producer timestamp
- schema version
- key
- idempotency behavior

## Production mindset

Real-time pipelines can fail silently while still "running". Monitor:

- source lag
- connector lag
- consumer lag
- DLQ count
- schema error count
- sink write latency
- event throughput
- duplicate rate
- freshness by event time and ingestion time

## Snapshot design

CDC starts with initial snapshot, then reads changes.

Risks:

- table changes during snapshot
- snapshot too large
- source DB load
- schema changes mid-snapshot
- missing deletes before stream catches up

Mitigation:

- snapshot during low traffic
- chunk snapshot by primary key
- monitor source CPU/IO
- use repeatable snapshot mechanism if supported
- validate counts/checksums

## Change event design

CDC event should include:

- source database/table
- primary key
- operation: c/u/d
- before
- after
- source timestamp
- log position
- transaction id
- ingestion timestamp

Without operation and primary key, downstream upsert/delete is fragile.

## Deletes

Delete handling options:

1. Hard delete in target.
2. Soft delete with `is_deleted`.
3. Tombstone event.
4. Keep full history in changelog.

Production recommendation:

- keep changelog immutable
- current-state table has `is_deleted`, `deleted_at` if consumers need audit
- marts decide whether to filter deleted rows

## Schema evolution

Common changes:

- add nullable column
- rename column
- change type
- remove column
- change meaning

Handling:

- schema registry
- compatibility rules
- DLQ incompatible events
- versioned consumers
- contract review for breaking changes

## Latency considerations

CDC latency components:

- source commit -> log availability
- connector polling/capture
- broker publish
- consumer processing
- sink commit

Real-time does not mean zero latency. Define SLA:

- p50 latency
- p95 latency
- max tolerated lag
- recovery time after outage

## Cost considerations

Cost drivers:

- broker retention
- event volume
- connector count
- sink merge frequency
- raw changelog storage
- streaming compute
- DLQ/replay compute

Optimization:

- micro-batch warehouse merges
- archive old events to object storage
- compact current-state tables
- filter unnecessary columns carefully
- avoid per-event warehouse writes for high-volume streams

## Failure handling

Failures:

- connector crashes
- source log retention expires
- schema incompatible
- consumer poison message
- sink unavailable
- duplicate replay
- out-of-order update

Handling:

- checkpoint offsets
- DLQ bad messages
- alert on lag
- idempotent upsert by primary key + source position
- replay from raw changelog
- resnapshot when log gap unrecoverable

## Recovery strategy

If connector down but log retained:

- resume from last offset.

If log expired:

- resnapshot affected tables.

If downstream current-state corrupt:

- truncate/rebuild from changelog.

If changelog corrupt:

- re-extract from source if possible, else restore backup.

## Trade-offs

- CDC gives low-latency DB replication but couples to database schema.
- Semantic events are cleaner but require app engineering work.
- Kafka self-managed flexible but ops-heavy.
- Managed ingestion lower ops but vendor cost/limitations.
- Per-event merge low latency but expensive.
- Micro-batch merge cheaper but more latency.

## Debugging mindset

Connector lag:

1. Check source log position.
2. Check connector task health.
3. Check broker publish errors.
4. Check schema errors.
5. Check sink throughput.
6. Check large transaction/table.

Consumer lag:

1. Check partitions with high lag.
2. Check hot keys.
3. Check processing time.
4. Check sink latency.
5. Check DLQ/poison messages.

Data mismatch:

1. Compare source count vs current-state count.
2. Check deletes.
3. Check duplicate primary keys.
4. Check event ordering.
5. Replay a single key history.

## Real-world failures

- CDC connector paused, source WAL expired, required full resnapshot.
- Delete events ignored, warehouse showed deleted users as active.
- Schema rename interpreted as new nullable column, downstream metric silently wrong.
- Consumer committed offset before sink write, data loss after crash.
- Out-of-order update overwrote newer record with older value.

## Exercises

1. Design CDC event schema for orders table.
2. Model changelog and current-state tables.
3. Write upsert logic for insert/update/delete.
4. Design DLQ handling for bad schema event.
5. Create replay plan for corrupted current-state table.
6. Compare CDC vs API polling vs semantic events.

## Mini project

Build CDC design document for ecommerce:

- sources: orders, customers, payments
- CDC event schema
- raw changelog table design
- current-state table design
- delete handling
- schema evolution policy
- lag monitoring
- replay/resnapshot plan

## Interview questions

- CDC la gi?
- Snapshot va change stream khac nhau nhu the nao?
- Debezium event can co fields nao?
- Delete handling trong CDC ra sao?
- Khi source log retention expire thi lam gi?
- Exactly-once trong CDC co that khong?
- CDC vs semantic events trade-off?
- Lam sao rebuild current-state table?

## GitHub outputs

- `cdc/cdc_architecture.md`
- `cdc/order_change_event_schema.json`
- `cdc/current_state_merge.sql`
- `cdc/delete_handling.md`
- `cdc/replay_plan.md`

## Production upgrade: CDC correctness playbook

### Debezium-style envelope mental model

CDC event thuong co:

```text
before: row before change
after: row after change
op: c/u/d/r
source: database, table, lsn/binlog position
ts_ms: event timestamp
transaction metadata
```

Why it matters:

- `op=d` can delete or tombstone downstream state.
- Snapshot records (`op=r`) khac live changes.
- LSN/binlog position giup ordering/recovery.

### Snapshot locking va consistency

Initial snapshot co rui ro:

- Lock source table qua lau.
- Snapshot read khong consistent voi live changes.
- Snapshot keo dai lam WAL/binlog retention bi ap luc.

Production choices:

- Low-traffic snapshot window.
- Incremental snapshot if supported.
- Monitor source DB load.
- Coordinate with DBA/app team.

### WAL/binlog retention

CDC connector down qua lau co the miss logs neu retention qua ngan.

Runbook:

1. Check connector lag.
2. Check oldest retained WAL/binlog.
3. If logs gone, stop connector.
4. Resnapshot affected tables.
5. Reconcile target state.

### Deletes va tombstones

Delete handling options:

- Hard delete downstream.
- Soft delete with `is_deleted`.
- Keep history in SCD2/event log.
- Tombstone compacted topic.

Trade-off:

- Hard delete mirrors source but loses audit/history.
- Soft delete safer for analytics but must be filtered.

### Out-of-order LSN/SCN

CDC consumers should not assume arrival order equals transaction order across partitions.

Mitigation:

- Key by primary key for per-key ordering.
- Use source position for ordering/replay.
- Merge current state by latest source timestamp/LSN.
- Handle duplicate change events idempotently.

### Resnapshot strategy

When target corrupt:

- Identify affected table/key range/time window.
- Pause downstream publish if necessary.
- Snapshot into shadow table.
- Compare row count/checksum.
- Swap or merge corrected state.
- Resume connector from known position.
