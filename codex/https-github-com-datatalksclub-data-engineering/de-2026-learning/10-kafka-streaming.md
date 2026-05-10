# Kafka va Streaming Production-Grade

## Vai tro cua Kafka

Kafka la distributed event log. No giup producer va consumer tach roi nhau, cho phep nhieu he thong doc cung mot dong event, replay event, scale consumer theo partition, va xu ly du lieu gan real-time.

Kafka khong phai database, khong phai queue don gian, va khong tu dong lam data "exactly correct". Kafka chi cung cap log co thu tu trong partition. Reliability that su nam o producer config, consumer offset handling, idempotency, schema, monitoring va operational discipline.

Kien truc pho bien:

```text
application / CDC / service
        |
        v
Kafka topic
        |
        +--> realtime consumer -> operational store
        +--> lake sink -> data lake
        +--> stream processor -> derived topic
        +--> monitoring / fraud / feature pipeline
```

## Muc tieu can dat

Sau module nay, ban nen:

- Hieu producer, broker, topic, partition, offset, consumer group.
- Giai thich ordering guarantee va gioi han cua no.
- Hieu at-least-once, at-most-once, exactly-once concept.
- Thiet ke idempotent consumer.
- Debug duplicate events, lag, retry storm, partition imbalance.
- Biet dung DLQ va replay dung cach.
- Biet anti-pattern streaming trong data platform.
- Co the noi ve trade-off giua batch va streaming trong interview.

## Khai niem can nam

- Event: mot fact da xay ra, vi du `OrderCreated`, `PaymentCaptured`.
- Topic: log logical chua events cung loai.
- Partition: phan cua topic de scale va ordering.
- Offset: vi tri event trong partition.
- Producer: service ghi event vao Kafka.
- Consumer: service doc event.
- Consumer group: nhom consumers chia partitions.
- Broker: server Kafka.
- Replication factor: so ban sao cua partition.
- Retention: thoi gian/kich thuoc Kafka giu events.
- Key: dung de chon partition va giu ordering theo entity.
- Schema Registry: quan ly schema event.
- DLQ: dead-letter queue cho event khong xu ly duoc.

## Architecture mindset

### Kafka la log, khong phai state store chinh

Kafka giu events trong thoi gian retention. No khong thay the:

- OLTP database.
- Data warehouse.
- Search index.
- Feature store.

Consumer phai build state rieng neu can query nhanh. Vi du consumer doc `orders` topic va ghi vao PostgreSQL/BigQuery/Redis.

### Partition quyet dinh scale va ordering

Moi partition co order rieng. Kafka khong dam bao global ordering tren toan topic.

Neu key la `order_id`, cac event cua cung order vao cung partition va giu order trong partition. Neu key random, ordering theo order mat. Neu key la `country`, co the skew nang vi `US` qua lon.

Chon key can dua tren:

- Entity can ordering.
- Data distribution.
- Consumer processing pattern.
- Future scaling.

### Consumer group scale theo partition

Neu topic co 6 partitions, consumer group co toi da 6 consumers active doc song song. Consumer thu 7 se idle. Tang consumers khong giup neu partition count it.

Partition count la quyet dinh architecture kho sua ve sau. Qua it thi kho scale. Qua nhieu thi overhead lon, file/log segment nhieu, rebalance phuc tap.

## Producer design

Producer can quan tam:

- Key.
- Serialization.
- Acks.
- Retries.
- Idempotent producer.
- Batching.
- Compression.
- Timeout.

Config concept:

- `acks=all`: leader doi replicas acknowledge, an toan hon.
- `enable.idempotence=true`: giam duplicate do retry producer.
- `retries`: retry loi tam thoi.
- `linger.ms`: cho them chut de batch.
- `compression.type`: snappy/lz4/zstd giam bandwidth.

Production event nen co:

- `event_id`
- `event_type`
- `event_timestamp`
- `producer`
- `schema_version`
- business key: `order_id`, `customer_id`
- payload

Khong nen gui event khong co ID. Khong co event_id thi consumer kho deduplicate.

## Consumer design

Consumer can quan tam:

- Offset commit.
- Idempotency.
- Retry.
- DLQ.
- Backpressure.
- Lag.
- Poison pill events.

At-least-once pattern:

```text
poll event
process event
write output idempotently
commit offset
```

Neu process thanh cong nhung commit offset fail, event co the duoc doc lai. Vi vay output write phai idempotent.

Sai pattern:

```text
poll event
commit offset
process event
```

Neu process fail sau commit, event bi mat doi voi consumer group.

## Delivery guarantees

### At-most-once

Commit offset truoc khi process. Co the mat data. It dung cho financial/data pipeline.

### At-least-once

Process truoc, commit sau. Co the duplicate. Day la pattern pho bien va chap nhan duoc neu consumer idempotent.

### Exactly-once myth

Kafka co exactly-once semantics trong mot so dieu kien va API nhat dinh, nhung end-to-end exactly-once giua Kafka, database, external API, warehouse la bai toan kho. Trong data engineering, nen tu duy:

- expect duplicates
- design idempotency
- use deterministic keys
- reconcile output
- monitor lag and failures

## Idempotency

Consumer idempotent nghia la xu ly lai cung mot event khong lam output sai.

Pattern:

- Dung `event_id` unique key.
- Dung upsert/merge theo business key.
- Ghi processed_events table.
- Dung natural key + version.
- Tinh aggregate theo window co reprocessing strategy.

Vi du insert an toan:

```sql
insert into processed_events (event_id, processed_at)
values (:event_id, now())
on conflict (event_id) do nothing;
```

Sau do chi ghi output neu event chua xu ly.

## Ordering

Ordering chi duoc dam bao trong mot partition. Neu can order event theo `order_id`, key phai la `order_id`.

Loi production hay gap:

- Producer key random lam event `OrderCreated` va `PaymentCaptured` vao partition khac nhau.
- Consumer nhan payment truoc order.
- Retry gui lai event cu sau event moi.

Fix:

- Chon key theo entity.
- Them event version/sequence.
- Consumer xu ly out-of-order bang state hoac buffer.
- Dung upsert voi `updated_at`/version de tranh ghi de bang record cu.

## Retry va DLQ

Khong retry vo han trong consumer loop.

Retry strategy:

- Retry nhanh cho loi tam thoi.
- Retry voi backoff.
- Sau N lan, day sang retry topic hoac DLQ.
- DLQ phai co owner va replay process.

DLQ event nen chua:

- original topic/partition/offset
- error message
- failed_at
- consumer version
- original payload

DLQ khong phai thung rac de quen. DLQ la queue can triage.

## Event replay

Kafka cho phep replay neu retention con data. Replay dung de:

- Build lai target store.
- Sua bug transform.
- Reprocess event bi loi.
- Backfill consumer moi.

Rui ro replay:

- Duplicate output neu consumer khong idempotent.
- Lam downstream overload.
- Ghi de state moi bang event cu.
- Vi pham ordering neu replay mot phan.

Truoc replay:

1. Xac dinh consumer group va offset.
2. Xac dinh output co idempotent khong.
3. Xac dinh rate limit.
4. Chay dry run hoac replay subset.
5. Monitor lag, output count, errors.

## Lag debugging

Consumer lag = latest offset - committed offset.

Lag tang co the do:

- Producer traffic tang.
- Consumer xu ly cham.
- External sink cham.
- Partition imbalance.
- Poison pill event lam consumer lap fail.
- Rebalance lien tuc.

Debug:

- Lag theo partition, khong chi total lag.
- Throughput producer vs consumer.
- Processing time per event.
- Error rate.
- Sink latency.
- Consumer restart/rebalance logs.

Fix:

- Optimize processing.
- Batch writes.
- Tang consumers neu partition du.
- Tang partitions neu can va co ke hoach.
- Tach hot key/topic.
- Fix poison pill + DLQ.

## Partition imbalance

Imbalance xay ra khi mot partition nhan qua nhieu events.

Nguyen nhan:

- Key distribution skew.
- Key null lam default/random khong nhu mong doi.
- Mot customer/merchant qua lon.

Debug:

- Count events by key.
- Lag by partition.
- Bytes in/out by partition.

Fix:

- Chon key tot hon cho topic moi.
- Split hot entity sang topic rieng neu can.
- Salt key neu ordering theo entity khong bat buoc.
- Tang partitions chi giam neu key distribution cho phep.

## Duplicate event debugging

Nguon duplicate:

- Producer retry khong idempotent.
- Network timeout sau khi broker da nhan event.
- Consumer process thanh cong nhung commit offset fail.
- Replay.
- Upstream service gui duplicate.
- CDC connector snapshot + streaming overlap.

Debug:

- Check `event_id`.
- Check topic/partition/offset.
- Check producer logs.
- Check consumer commit logs.
- Check replay history.
- Check output unique constraints.

Prevention:

- Event ID bat buoc.
- Idempotent producer.
- Idempotent consumer.
- Unique key/upsert in sink.
- Reconciliation metrics.

## Streaming anti-patterns

- Dung Kafka de thay database.
- Khong co schema/version.
- Event payload la dump ngau nhien cua table.
- Consumer ghi output khong idempotent.
- Retry vo han lam lag tang.
- Khong co DLQ.
- Khong monitor lag.
- Dung streaming cho bai toan daily batch la du.
- Key sai lam mat ordering.
- Chia qua nhieu topic nho khong co ownership.

## Production mindset

Mot streaming pipeline production can co:

- Topic naming convention.
- Schema ownership.
- Retention policy.
- Partition strategy.
- Consumer idempotency.
- Lag alert.
- DLQ process.
- Replay runbook.
- Backpressure handling.
- Data quality/reconciliation.
- Capacity planning.

## Cost considerations

Chi phi Kafka den tu:

- Broker count va storage.
- Network throughput.
- Retention dai.
- Replication factor.
- Partition count qua cao.
- Consumer compute.
- Downstream sink writes.

Giam chi phi:

- Retention dung nhu cau.
- Compression.
- Batch producer/consumer writes.
- Khong tao topic/partition vo toi va.
- Archive long-term vao data lake thay vi Kafka retention qua dai.

## Exercises

1. Tao topic `orders` voi 3 partitions.
2. Viet producer gui event co `event_id`, `order_id`, `event_type`.
3. Key event theo `order_id`.
4. Viet consumer ghi vao PostgreSQL bang upsert.
5. Gia lap consumer crash sau process truoc commit, chung minh duplicate duoc handle.
6. Tao duplicate event va debug bang event_id.
7. Tao hot key va quan sat lag partition.
8. Day event sai schema vao DLQ.
9. Reset offset va replay subset.

## Mini project

Build mini streaming order pipeline:

```text
order-service producer
        |
        v
Kafka topic: ecommerce.orders
        |
        v
consumer
        |
        v
PostgreSQL orders_current + processed_events
```

Yeu cau:

- Event co schema version.
- Producer key = `order_id`.
- Consumer idempotent bang `event_id`.
- Sink dung upsert.
- Co DLQ topic/file cho event loi.
- Co metrics: consumed count, duplicate count, error count, lag.
- README giai thich delivery guarantee va replay.

## Interview questions

- Kafka topic va partition la gi?
- Offset la gi?
- Consumer group scale nhu the nao?
- Kafka dam bao ordering o muc nao?
- At-least-once co van de gi?
- Exactly-once co thuc te end-to-end khong?
- Lam sao consumer idempotent?
- DLQ dung khi nao?
- Consumer lag tang, debug ra sao?
- Partition imbalance xu ly the nao?
- Replay event can canh bao gi?
- Khi nao nen dung batch thay vi streaming?

## GitHub outputs

Repo streaming nen co:

- `docker-compose.yml` chay Kafka va Postgres.
- `producer/` co producer code.
- `consumer/` co idempotent consumer.
- `sql/` co sink schema va unique constraints.
- `README.md` co architecture, delivery guarantee, replay guide.
- `RUNBOOK.md` co lag/debug/DLQ handling.
- `sample_events/` co valid va invalid events.

## Production upgrade: streaming correctness matrix

### Consumer failure matrix

Streaming correctness phu thuoc thu tu: process message, write sink, commit offset.

```text
Case A: process fail before sink write
  -> safe to retry if no side effect.

Case B: sink write succeeds, offset commit fails
  -> message will be reprocessed; sink must be idempotent.

Case C: offset commit succeeds, sink write fails
  -> data loss unless transaction/outbox pattern protects it.

Case D: poison pill always fails
  -> consumer stuck unless DLQ/quarantine policy exists.
```

Rule:

- Commit offset only after sink write success.
- Sink writes must be idempotent by event_id/business key.
- DLQ must preserve original payload, topic, partition, offset, error, timestamp.

### Consumer rebalancing

Rebalance xay ra khi:

- Consumer join/leave group.
- Consumer slow heartbeat.
- Deployment rolling restart.
- Partition count changes.

Problems:

- Processing pause during rebalance.
- Same message may be processed again.
- Long processing time can trigger rebalance loop.

Mitigation:

- Tune max poll interval/session timeout.
- Keep processing batches bounded.
- Use cooperative rebalancing if supported.
- Make consumer idempotent.

### Schema registry depth

Production Kafka nen co schema contract:

- Avro/Protobuf/JSON Schema.
- Compatibility mode: backward, forward, full.
- Schema versioning.
- Producer validation.
- Consumer compatibility tests.

Failure mode:

- Producer adds required field without default.
- Consumer deploy older version and crashes.

Prevention:

- Schema compatibility checks in CI.
- Contract ownership.
- DLQ for invalid payload.

### Event-time vs processing-time

Event-time:

- Time event happened.
- Correct for business metrics.
- Late/out-of-order data possible.

Processing-time:

- Time consumer processed event.
- Easier operationally.
- Can distort metrics when lag spikes.

Watermarking:

- Defines how long system waits for late events.
- Too short: drops late valid events.
- Too long: high state/cost/latency.

### DLQ replay policy

DLQ without replay plan is a trash bin.

Replay checklist:

1. Identify root cause fixed.
2. Validate payload/schema.
3. Decide replay order.
4. Ensure sink idempotency.
5. Replay with throttling.
6. Monitor lag/error rate.
7. Record incident notes.

### Compacted topics

Compacted topic keeps latest value per key.

Use cases:

- Current customer profile.
- Feature flags/config.
- Dimension-like streams.

Risks:

- Tombstones delete keys.
- Consumers starting from beginning see changelog, not event history.
- Key design is critical.
