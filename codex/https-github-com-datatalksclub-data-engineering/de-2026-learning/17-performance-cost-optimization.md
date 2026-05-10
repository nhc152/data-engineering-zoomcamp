# Performance va Cost Optimization cho Data Engineering

## Vai tro

Performance va cost optimization khong phai viec "lam query nhanh hon" sau cung. Day la mot phan cua system design. Mot pipeline dung ve logic nhung scan qua nhieu data, full refresh qua lon, hoac streaming state tang khong kiem soat se nhanh chong thanh system kho van hanh.

Senior Data Engineer can thiet ke voi 3 cau hoi:

- Bottleneck nam o dau: ingestion, processing, storage, warehouse, serving hay orchestration?
- Chi phi tang theo bien nao: row count, column count, file count, query frequency, retention, concurrency?
- Khi scale gap 10 lan, system fail theo cach nao?

## Muc tieu can dat

- Hieu performance bottleneck trong batch, streaming, warehouse va lakehouse.
- Biet toi uu query cost trong BigQuery/Snowflake/Redshift/Postgres.
- Biet partitioning, clustering, file layout, compaction.
- Biet trade-off giua full refresh, incremental, materialization va caching.
- Biet dat cost guardrails cho data platform.
- Biet debug pipeline/query cham theo tung layer.

## Khai niem can nam

- Storage vs compute separation.
- Columnar storage.
- Partition pruning.
- Clustering/sort key.
- Query plan.
- Shuffle.
- Skew.
- Broadcast join.
- Small files problem.
- Materialized table/view.
- Autoscaling/autosuspend.
- Workload isolation.
- Cost attribution.
- Retention policy.

## Architecture mindset

Performance phai duoc xem theo end-to-end path:

```text
source -> ingestion -> raw storage -> processing -> warehouse/lakehouse -> marts -> BI/API
```

Neu dashboard cham, nguyen nhan co the khong nam o dashboard:

- mart khong aggregate dung grain
- fact table khong partition
- BI query raw table
- dbt model materialized sai
- warehouse compute bi tranh chap
- source data tao duplicate lam join no

Trong design interview, dung noi "toi se scale cluster". Hay noi:

- Toi kiem tra scan bytes.
- Toi xem partition pruning co apply khong.
- Toi xem row count truoc/sau join.
- Toi tach workload ad hoc va production.
- Toi pre-aggregate metrics co query lap lai.

## Production mindset

Production cost khong chi la tien cloud. No bao gom:

- thoi gian job
- compute contention
- on-call noise
- data latency
- developer productivity
- risk khi backfill

Optimization nen dua tren evidence:

- query history
- bytes scanned
- job duration
- warehouse credit usage
- Spark stage metrics
- Kafka lag
- dashboard query frequency

Khong toi uu som moi thu. Toi uu nhung duong chay quan trong:

- high-cost tables
- critical dashboards
- daily production DAGs
- large joins
- backfill-heavy workloads
- frequently reused transformations

## Warehouse cost optimization

### BigQuery mindset

BigQuery tinh cost chu yeu theo bytes scanned neu on-demand, hoac slot usage neu capacity. Can quan tam:

- column pruning: chon cot can dung
- partition pruning: filter dung partition column
- clustering: filter/join tren cot hay dung
- materialized results: tranh query raw lap lai
- dry run/query plan: uoc tinh cost

Anti-pattern:

```sql
select *
from raw.events
where date(event_timestamp) = date '2026-05-01';
```

Van de:

- `select *` scan tat ca cot.
- Function tren partition column co the lam mat partition pruning tuy engine/schema.

Tot hon:

```sql
select
    event_id,
    user_id,
    event_name,
    event_timestamp
from raw.events
where event_date = date '2026-05-01';
```

### Snowflake mindset

Snowflake cost den tu warehouse compute time va size. Can quan tam:

- warehouse size
- autosuspend/autoresume
- query concurrency
- micro-partition pruning
- clustering key neu can
- result cache
- materialized views

Anti-pattern:

- Warehouse luon bat 24/7.
- Mot warehouse cho tat ca workload: BI, ELT, ad hoc, backfill.
- Scale warehouse len thay vi toi uu query/model.

### Postgres/OLTP mindset

Postgres khong phai warehouse. Dung de:

- app transactional data
- small analytics
- local lab
- operational store

Khong nen:

- chay BI nang truc tiep tren OLTP
- full table scan lien tuc tren bang production
- join analytics lon lam anh huong app

Can dung:

- indexes
- read replicas
- CDC sang warehouse
- explain analyze

## Lakehouse performance

Lakehouse cham thuong do file layout, khong chi do engine.

### Small files problem

Neu moi micro-batch ghi hang nghin file nho, query se cham vi:

- metadata overhead
- object storage listing
- task scheduling overhead
- khong doc duoc block lon hieu qua

Giai phap:

- compaction
- target file size
- batch writes
- optimize/z-order/sort
- partition hop ly

### Partition strategy

Partition tot:

- dung theo query pattern
- cardinality vua phai
- thuong la date/hour cho event data

Partition xau:

- partition theo `user_id`
- partition theo cot high-cardinality
- qua nhieu partitions nho

### Table maintenance

Lakehouse production can co scheduled jobs:

- compact small files
- vacuum old files
- update statistics
- expire snapshots
- monitor table size/file count

## Streaming performance

Streaming bottleneck thuong nam o:

- producer throughput
- broker partitions
- consumer processing
- state store
- sink throughput
- hot keys

### Partitioning

Partition key quyet dinh song song va ordering.

- Key theo `user_id`: giu ordering per user, co risk hot users.
- Key theo `order_id`: tot cho order lifecycle.
- Random key: parallel tot, mat ordering.

Trade-off:

- more partitions = more parallelism nhung more overhead
- ordering per key = less flexibility
- repartition sau nay co chi phi

### Consumer lag

Lag tang khi:

- event rate > processing rate
- sink cham
- state qua lon
- retry loop
- bad records block consumer

Debug:

- lag theo partition
- processing time per record/window
- sink write latency
- DLQ volume
- checkpoint duration

## Batch performance

Batch bottleneck:

- full refresh qua lon
- join skew
- shuffle lon
- source extraction cham
- warehouse queue
- backfill tranh compute voi production

Design tot:

- partition-level processing
- incremental load
- idempotent overwrite partition
- separate backfill compute
- pre-aggregate dimensions/facts
- run metadata

## Scaling bottlenecks

### Ingestion

Limits:

- API rate limit
- source DB CPU
- CDC log retention
- network bandwidth
- file count

Mitigation:

- incremental extraction
- CDC
- batching
- compression
- parallel extraction by partition
- backpressure

### Processing

Limits:

- memory
- shuffle
- skew
- concurrency
- inefficient SQL

Mitigation:

- pre-aggregate
- salting hot keys
- broadcast small tables
- materialize intermediate models
- partition pruning

### Serving

Limits:

- dashboard fanout
- high-cardinality filters
- ad hoc scans
- no caching

Mitigation:

- aggregate marts
- semantic layer
- cache
- query limits
- workload isolation

## Cost considerations

Cost controls nen co:

- budget alerts
- query quotas
- warehouse autosuspend
- ownership tags/labels
- cost dashboard by team/model
- retention lifecycle
- temp table cleanup
- backfill approval workflow

Cost anti-patterns:

- BI query raw events.
- Full refresh huge table daily.
- Materialize every dbt model as table.
- Keep Kafka retention for months thay vi archive to object storage.
- No compaction in lakehouse.
- No owner for expensive dashboards.

## Debugging mindset

Khi query cham:

1. Xac dinh expected output grain.
2. Xem bytes scanned / query plan.
3. Kiem tra partition filter.
4. Kiem tra select columns.
5. Kiem tra join cardinality.
6. Kiem tra duplicate keys.
7. Kiem tra materialization.
8. Xem workload contention.

Khi cost tang:

1. Tim top queries/jobs theo cost.
2. Gan owner.
3. Xem thay doi gan day.
4. Xem dashboard schedule.
5. Xem full refresh/backfill.
6. Xem raw table scans.
7. Them guardrails.

## Real-world failures

- Dashboard auto-refresh moi 1 phut query raw events 30 ngay.
- dbt model doi tu incremental sang table full refresh.
- Backfill 2 nam chay cung warehouse voi production BI.
- Spark job join skew tai mot customer enterprise lam stage treo.
- Lakehouse streaming job tao millions small files.
- CDC connector lag vuot source log retention, bat buoc resnapshot.

## Trade-offs

- Full refresh don gian, cost cao.
- Incremental re hon, logic phuc tap hon.
- View it storage, query lap lai dat.
- Table nhanh cho BI, can build va storage.
- Realtime nhanh, operational cost cao.
- Batch cham hon, de debug va reprocess hon.
- Large warehouse nhanh hon, co the che giau model thiet ke kem.

## Exercises

1. Lay mot fact table lon, viet 3 query: bad, improved, optimized.
2. So sanh `select *` va column pruning.
3. Thiet ke partition/clustering cho `fct_orders`.
4. Tim join explosion bang row count before/after join.
5. Chuyen full refresh sang incremental.
6. Viet cost review checklist cho dbt PR.
7. Thiet ke workload isolation cho BI, ELT, ad hoc, backfill.

## Mini project

Build cost-optimized ecommerce warehouse:

- raw orders, order_items, payments
- staging clean/dedup
- fct_orders partition by order_date
- mart_daily_revenue pre-aggregated
- quality checks
- README giai thich performance/cost decisions

Yeu cau:

- Co query naive va optimized.
- Co row count diagnostics.
- Co cost guardrail rules.
- Co backfill plan khong pha production.

## Interview questions

- Lam sao toi uu query cost trong BigQuery?
- Partition va clustering khac nhau nhu the nao?
- Khi nao materialize table thay vi view?
- Small files problem la gi?
- Spark shuffle bottleneck debug sao?
- Consumer lag tang thi debug o dau?
- Full refresh va incremental trade-off gi?
- Lam sao giam cost dashboard BI?
- Workload isolation la gi?

## GitHub outputs

- `performance/optimized_queries.sql`
- `performance/bad_queries.sql`
- `performance/query_review_checklist.md`
- `performance/cost_controls.md`
- README co architecture va trade-offs.

## Production upgrade: investigation templates

### Cost spike case study

Symptom:

- BigQuery/Snowflake bill tang 3x trong 24h.

Evidence to collect:

- Top queries by cost.
- User/service account.
- Query text hash.
- Bytes scanned.
- Runtime.
- Schedule/dashboard source.
- Tables scanned.

Diagnosis examples:

- Dashboard refresh every 5 minutes scans fact table.
- dbt full refresh accidentally ran on 3-year history.
- Missing partition filter after model refactor.
- Analyst used `select *` from wide table.

Fix:

- Add partition filter.
- Create aggregate mart.
- Reduce dashboard refresh.
- Add query guardrail or budget alert.
- Add dbt selector to avoid full refresh of heavy models.

### Unit economics per pipeline

Moi pipeline production nen co cost unit:

```text
cost per daily run
cost per GB ingested
cost per million events
cost per dashboard refresh
cost per backfill day
```

Khi data tang 10x, ban can biet chi phi tang tuyen tinh hay dot bien.

### Query profile interpretation

Warehouse:

- bytes scanned high -> partition/column pruning issue.
- shuffle/spill high -> join/aggregation issue.
- queue time high -> resource contention.

Spark:

- long tail tasks -> skew.
- high spill -> memory/partition issue.
- many small tasks -> small files/partition count issue.

Kafka:

- lag growing -> consumer throughput < producer rate.
- one partition lagging -> key skew.
- rebalance loop -> consumer instability.

### Autoscaling failure

Autoscaling khong sua moi van de.

Failure modes:

- Source/sink rate limit, scale consumer cung khong nhanh hon.
- Partition count qua it, them consumers khong co tac dung.
- Warehouse queue do concurrency limit, retry lam te hon.
- Spark dynamic allocation cham khi job co burst ngan.

Lesson:

- Scale bottleneck, khong scale blindly.
- Measure throughput per stage.
 
