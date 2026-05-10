# Distributed Systems cho Data Engineer

## Vai tro

Data Engineering hien dai la distributed systems duoi mot ten goi khac.

Khi ban dung Kafka, Spark, Flink, Airflow, BigQuery, Snowflake, Databricks, CDC, object storage, Kubernetes, dbt Cloud, hay bat ky cloud warehouse nao, ban dang lam viec voi cac he thong phan tan:

- Nhieu node cung xu ly data.
- Network co the cham, mat ket noi, partition.
- Message co the duplicate.
- Event co the den tre.
- Task co the retry.
- File co the duoc ghi nua chung.
- Metadata co the stale.
- Clock giua may khong dong bo tuyet doi.
- Mot phan he thong fail trong khi phan khac van chay.

Muc tieu cua file nay khong phai hoc distributed systems kieu academic. Muc tieu la hieu vi sao production data systems fail, vi sao duplicate xay ra, vi sao ordering kho, vi sao retry co the tao chaos, va vi sao "exactly-once" thuong la marketing neu khong hieu boundary.

Senior Data Engineer khong chi biet viet pipeline. Senior Data Engineer biet pipeline se fail theo nhung cach nao va thiet ke de fail co kiem soat.

## Muc tieu can dat

Sau file nay, ban nen co the:

- Giai thich CAP theorem theo ngon ngu production.
- Hieu replication, sharding va consistency trade-offs.
- Thiet ke pipeline idempotent.
- Hieu tai sao duplicates la binh thuong trong distributed systems.
- Hieu ordering guarantees cua Kafka va gioi han cua chung.
- Giai thich exactly-once myth.
- Debug retry storm, backpressure, lag, partial failure.
- Hieu Spark shuffle va failure/retry implications.
- Hieu warehouse consistency/cost implications.
- Hieu CDC ordering, snapshot va duplicate problems.
- Noi chuyen ve reliability nhu mot engineer van hanh production.

## Mental model: distributed system la gi?

Mot distributed system la mot he thong co nhieu thanh phan chay tren nhieu process/machine/network boundary, phoi hop de tao ra mot ket qua chung.

Vi du data pipeline:

```text
source database
      |
      v
CDC connector
      |
      v
Kafka brokers
      |
      v
Spark/Flink consumers
      |
      v
object storage / warehouse
      |
      v
dbt / BI marts
```

Moi mui ten la mot failure boundary. Moi boundary co the gay:

- timeout
- duplicate
- reorder
- partial write
- stale read
- inconsistent state
- lost acknowledgement
- retry

Distributed systems kho khong phai vi code kho. Kho vi ban khong bao gio chac chan 100% ben kia da lam gi sau khi network fail.

## Architecture mindset

Thiet ke distributed data system can bat dau bang cau hoi:

- Source of truth la gi?
- Business key la gi?
- He thong co chap nhan duplicate khong?
- Ordering co quan trong khong?
- Neu retry, co idempotent khong?
- Neu backfill, co ghi de data dung partition khong?
- Neu consumer chay lai, co tao duplicate output khong?
- Neu mot node fail, ai tiep tuc?
- Neu network partition, chon availability hay consistency?
- Neu downstream cham, upstream co backpressure khong?

Kien truc tot khong co nghia la khong fail. Kien truc tot la fail co the du doan, khoanh vung, replay va sua duoc.

## CAP theorem thuc dung

CAP noi rang trong mot distributed data system, khi network partition xay ra, ban phai chon giua:

- Consistency: moi read thay data moi nhat/dong nhat.
- Availability: moi request nhan duoc response.
- Partition tolerance: he thong van phai song khi network bi chia cat.

Trong cloud production, partition tolerance khong phai tuy chon. Network se fail. Vi vay luc co partition, trade-off thuc te la consistency vs availability.

```text
              network partition
                    |
        +-----------+-----------+
        |                       |
choose consistency        choose availability
reject/timeout writes     accept writes on both sides
avoid divergence          reconcile later
```

Data Engineering implications:

- Kafka uu tien availability trong nhieu cau hinh, nhung durability/consistency phu thuoc replication factor, acks, ISR.
- Warehouse thuong uu tien consistency trong transaction boundary, nhung ingestion/metadata visibility co latency.
- Object storage hien dai manh hon truoc, nhung listing/metadata, multi-writer patterns van can can than.
- CDC pipeline thuong chap nhan eventual consistency: warehouse se tre hon source.

CAP khong dung de noi "system A la CP, system B la AP" mot cach qua don gian. Production config moi la thu quyet dinh hanh vi.

## Replication

Replication la sao chep data sang nhieu node de tang durability, availability va read scalability.

Vi du Kafka topic replication:

```text
partition 0
  leader: broker 1
  replica: broker 2
  replica: broker 3
```

Khi producer ghi:

1. Ghi vao leader.
2. Leader replicate sang followers.
3. Producer nhan ack tuy cau hinh.

Trade-offs:

- Replication factor cao hon: durable hon, ton storage hon.
- `acks=all`: an toan hon, latency cao hon.
- Min in-sync replicas cao hon: consistency/durability hon, availability thap hon khi broker fail.

Replication khong tu dong loai duplicate. No chi sao chep state/log. Duplicate den tu retry, lost ack, consumer rerun, non-idempotent writes.

## Sharding va partitioning

Sharding chia data theo key de scale.

Kafka partition:

```text
topic orders
  partition 0: order_id hash -> subset A
  partition 1: order_id hash -> subset B
  partition 2: order_id hash -> subset C
```

Warehouse partition:

```text
fct_orders partition by order_date
```

Database sharding:

```text
customers shard by customer_id
```

Trade-offs:

- Scale tot hon.
- Query cross-shard kho hon.
- Rebalancing kho.
- Hot key gay skew.
- Ordering chi dam bao trong partition/shard, khong phai toan system.

Data Engineering implication:

- Kafka ordering chi trong mot partition.
- Spark data skew lam mot task cham hon tat ca task khac.
- BigQuery/Snowflake partition/clustering sai lam query scan nhieu hon.
- CDC sharding co the lam event cua cung entity den qua nhieu stream neu key sai.

## Consistency models

Consistency khong chi co strong vs eventual. Can hieu cac muc thuc dung.

### Strong consistency

Sau khi write thanh cong, read sau do thay write moi nhat.

Tot cho:

- Financial ledger.
- Inventory critical.
- Metadata transaction.

Chi phi:

- Latency cao hon.
- Availability co the giam khi partition.
- Coordination can nhieu hon.

### Eventual consistency

Neu khong co update moi, cac replica cuoi cung se hoi tu ve cung gia tri.

Tot cho:

- Analytics warehouse.
- Search index.
- Reporting data.
- Data lake curated layer.

Rui ro:

- Dashboard tre.
- User thay data khac nhau o hai he thong.
- Backfill/reconciliation can thiet.

### Read-your-writes

Client doc lai thay write cua chinh no.

Trong data platform, BI user thuong khong co guarantee nay neu ingestion async.

### Monotonic reads

Neu da thay version moi, lan sau khong nen thay version cu. Neu cache/replica khong dung, user co the thay metric "di lui".

## Eventual consistency trong DE

Analytics gan nhu luon eventual consistency:

```text
source transaction committed at 10:00
CDC captures at 10:00:05
Kafka consumer processes at 10:00:10
warehouse load finishes at 10:02
dbt mart finishes at 10:10
dashboard refreshes at 10:15
```

Neu stakeholder hoi "vi sao source co roi dashboard chua co", cau tra loi dung khong phai "pipeline fail" ngay. Can biet SLA freshness cua tung layer.

Production practice:

- Publish data freshness.
- Co `loaded_at`, `source_updated_at`.
- Co lag metrics.
- Co reconciliation window.
- Noi ro mart la near-real-time hay daily batch.

## Ordering guarantees

Ordering la mot trong nhung thu hay bi hieu sai nhat.

Kafka guarantee:

- Ordering trong mot partition.
- Khong guarantee ordering toan topic neu topic co nhieu partition.
- Cung key vao cung partition neu partitioner on dinh.

Vi du:

```text
customer C001 events -> partition 2 -> ordered
customer C002 events -> partition 0 -> ordered
global ordering across C001 and C002 -> not guaranteed
```

CDC implications:

- Updates cua cung primary key can di cung partition neu muon preserve order.
- Snapshot event va change event co the interleave.
- Multi-table transaction ordering kho hon single table ordering.

Spark implications:

- Distributed processing khong giu order mac dinh.
- `order by` global rat dat.
- Output file order khong nen duoc coi la deterministic.

Warehouse implications:

- Table khong co row order neu khong `order by`.
- Incremental merge phai dung key va timestamp/version, khong dua vao load order.

## Exactly-once myth

"Exactly-once" thuong khong co nghia la "khong bao gio duplicate trong toan bo pipeline".

No thuong co nghia hep:

- Exactly-once processing trong mot engine boundary.
- Exactly-once write voi transactional sink cu the.
- Idempotent producer + transaction trong Kafka.
- State update va offset commit atomic trong mot framework.

Nhung end-to-end pipeline co nhieu boundary:

```text
API -> Kafka -> Spark -> object storage -> warehouse -> dbt mart
```

Neu API timeout sau khi source da commit, client retry tao duplicate. Kafka khong biet do la duplicate business event neu key/id khong dung.

Neu Spark ghi file thanh cong nhung fail truoc khi commit metadata, rerun co the tao orphan files.

Neu warehouse insert thanh cong nhung orchestrator task timeout, retry insert lan nua co the duplicate neu khong co merge key.

Production truth:

- At-least-once + idempotent sink la pattern thuc te pho bien.
- Exactly-once can duoc dinh nghia theo boundary.
- Business key va dedup logic quan trong hon slogan.

## Idempotency

Idempotent nghia la chay cung mot operation nhieu lan van cho cung ket qua cuoi.

Non-idempotent:

```sql
insert into fct_orders
select * from staging_orders;
```

Chay 2 lan tao duplicate.

Idempotent hon:

```sql
merge into fct_orders target
using staging_orders source
on target.order_id = source.order_id
when matched then update set ...
when not matched then insert ...;
```

Idempotency trong DE:

- Use business key.
- Use deterministic dedup.
- Write partition overwrite co kiem soat.
- Use temp table then swap.
- Commit offset sau khi sink commit.
- Checkpoint state.
- Make retries safe.

Neu pipeline khong idempotent, retry la nguy hiem.

## Stateless vs stateful

Stateless task:

- Doc input.
- Tao output.
- Khong phu thuoc memory/history local.
- De scale/retry.

Stateful task:

- Can giu offset, aggregation state, watermark, cache, session state.
- Kho scale/retry hon.

Kafka consumer stateless neu moi message doc va upsert theo key. Stateful neu aggregate rolling 5 phut, join stream-stream, track dedup keys.

Spark batch co state tam trong shuffle/cache. Structured Streaming co checkpoint/state store.

Production implication:

- Stateless de deploy hon.
- Stateful can checkpoint, recovery, compaction, state size monitoring.
- Lost state co the gay duplicate hoac missing output.

## Distributed failures

He thong phan tan fail theo kieu partial:

- Producer nghi write fail, broker da nhan.
- Consumer nghi write success, warehouse timeout.
- Spark executor fail, task rerun.
- Network partition lam node A khong thay node B.
- Object storage write file thanh cong, metadata commit fail.
- Orchestrator task timeout, underlying job van chay.
- CDC connector restart tu offset cu.

Vi network khong dang tin, ban khong biet remote operation co thanh cong hay khong neu timeout.

Day la nguon goc cua duplicates.

## Network partitions

Network partition la khi cac node khong lien lac duoc voi nhau, nhung mot so node van song.

Trong data systems:

- Kafka broker bi tach khoi cluster.
- Spark executor mat ket noi driver.
- Database replica khong sync duoc.
- CDC connector khong connect duoc source.
- Orchestrator khong nhan status cua job.

Response phu thuoc thiet ke:

- Stop writes de giu consistency.
- Accept writes va reconcile sau.
- Elect leader moi.
- Retry voi backoff.
- Fail fast va alert.

Khong co lua chon nao mien phi.

## Retry storms

Retry storm xay ra khi nhieu client/task cung retry lien tuc luc downstream dang yeu.

```text
warehouse slow
  -> 100 tasks timeout
  -> all retry immediately
  -> warehouse receives 300 requests
  -> slower
  -> more timeout
  -> more retry
```

Retry khong co backoff co the bien incident nho thanh outage.

Production practice:

- Exponential backoff.
- Jitter.
- Retry budget.
- Circuit breaker.
- Queue/backpressure.
- Distinguish transient vs permanent errors.
- Do not retry data validation failures blindly.

## Backpressure

Backpressure la co che lam upstream cham lai khi downstream khong theo kip.

Khong co backpressure:

```text
source emits 100k events/s
consumer handles 20k events/s
lag grows
memory grows
timeouts grow
system fails
```

Co backpressure:

```text
downstream slow
  -> consumer reduces pull rate
  -> queue absorbs temporarily
  -> alert on lag
  -> autoscale or shed load
```

Kafka implication:

- Consumer lag la tin hieu quan trong.
- Retention phai du de consumer catch up.
- Backfill co the can separate consumer group.

Spark implication:

- Shuffle spill, task time, input rate can show pressure.
- Structured Streaming can throttle max offsets per trigger.

Warehouse implication:

- Too many concurrent loads/queries can saturate slots/warehouse.
- Queueing and workload management matter.

## Replay systems

Replay la kha nang xu ly lai data tu log/raw source.

Tot khi:

- Raw immutable.
- Kafka retention du dai.
- CDC offsets/checkpoints duoc quan ly.
- Sink idempotent.
- Schema versions duoc giu.
- Business logic versioned.

Replay nguy hiem khi:

- Output append-only khong dedup.
- Old code va new schema khong compatible.
- Backfill overwrite wrong partition.
- External side effects khong idempotent.

Replay architecture:

```text
immutable source log/raw files
        |
        v
deterministic transform code
        |
        v
idempotent sink keyed by business key + partition
```

## Consensus basics

Consensus la co che de nhieu node dong y ve mot state/order trong dieu kien failure.

Ban khong can implement Raft/Paxos de lam DE, nhung can hieu vi sao coordination dat.

Consensus dung cho:

- Leader election.
- Metadata commit.
- Distributed locks.
- Cluster membership.
- Transaction coordination.

Systems:

- Kafka dung controller/quorum mechanisms cho metadata/leadership.
- ZooKeeper/etcd/Consul dung cho coordination.
- Lakehouse transaction log can atomic commit semantics.

Trade-off:

- Consensus tang correctness.
- Consensus tang latency/complexity.
- Neu coordination layer fail, ca platform co the bi anh huong.

## Coordination problems

Coordination kho vi nhieu workers cung muon lam viec tren cung resource.

Vi du:

- Hai jobs cung overwrite mot partition.
- Hai consumers cung write cung order_id.
- Hai backfills cung update watermark.
- Mot scheduler trigger duplicate DAG run.
- Streaming job va batch backfill cung ghi gold table.

Patterns:

- Single writer per table/partition.
- Transactional table format.
- Lease/lock voi timeout.
- Idempotent merge.
- Partition-level ownership.
- Separate staging output then atomic publish.

## Kafka implications

### Duplicates

Kafka co the deliver duplicate neu consumer process message nhung fail truoc khi commit offset. Sau restart, message duoc doc lai.

Fix:

- Idempotent sink.
- Dedup by event_id/business key.
- Commit offset sau khi sink commit.
- Use transactions only khi hieu boundary.

### Ordering

Ordering chi trong partition. Chon key sai la mat ordering cho entity.

Neu order updates key by random UUID moi lan, updates cua cung order co the vao nhieu partition va out-of-order.

### Lag

Lag khong phai luc nao cung xau. Lag xau khi vi pham SLA hoac retention sap het.

Debug lag:

- Input rate tang?
- Consumer error/retry?
- Downstream slow?
- Partition skew?
- Rebalance lien tuc?
- Message size tang?

## Spark implications

Spark la distributed compute. Loi thuong gap:

- Data skew: mot key qua lon lam mot task cham.
- Shuffle failure: network/disk spill/executor lost.
- Non-deterministic output order.
- Task retry ghi duplicate neu sink khong idempotent.
- `collect()` keo data ve driver lam crash.

Spark job mindset:

- Transformation nen deterministic.
- Output write nen transactional hoac partition overwrite co kiem soat.
- Avoid side effects trong map/foreach neu khong idempotent.
- Monitor stage/task skew.
- Understand checkpointing for streaming.

## Warehouse implications

Cloud warehouse la distributed system duoc managed.

Ban van can hieu:

- Query scan phan tan tren nhieu workers.
- Concurrent queries tranh tai nguyen.
- Metadata/catalog co consistency boundary.
- Load jobs co retry/idempotency concerns.
- Partition/clustering anh huong scan va shuffle.
- Merge tren bang lon co the rat dat.

Incident pho bien:

- Orchestrator timeout nhung warehouse query van chay, retry tao hai query nang.
- Incremental insert append duplicate vi khong co merge key.
- Dashboard query khong filter partition lam cost tang dot bien.
- Many small files external table lam query cham.

## CDC implications

CDC doc change log tu database. No gan voi distributed systems vi phai preserve order va state.

Van de:

- Snapshot + streaming changes overlap.
- Delete events bi bo qua.
- Update event den out-of-order.
- Connector restart tu offset cu.
- Schema change pha consumer.
- Transaction multi-table kho preserve trong warehouse.

CDC production design:

- Co primary key.
- Co operation type: insert/update/delete.
- Co source LSN/binlog position.
- Co source timestamp va ingestion timestamp.
- Sink merge theo key.
- Delete handling ro: hard delete, soft delete, tombstone.
- Snapshot boundary ro.

## Real production incidents

### Incident 1: duplicate revenue sau timeout

Orchestrator submit warehouse insert. Query thanh cong nhung network timeout lam task bi mark failed. Retry chay lai insert append, revenue gap doi.

Root cause:

- Non-idempotent insert.
- Timeout status khong xac dinh remote success/failure.

Fix:

- Use merge/upsert.
- Use job idempotency key neu warehouse ho tro.
- Write to temp table then atomic replace partition.
- Reconciliation check sau load.

### Incident 2: Kafka consumer lag va retention het

Downstream warehouse cham 12 gio. Consumer lag tang, Kafka retention 24 gio. Weekend traffic tang lam lag vuot retention, messages bi expire truoc khi consumer doc.

Root cause:

- Retention khong du cho worst-case recovery.
- Khong alert theo lag time vs retention.
- Downstream khong co backpressure/scale plan.

Fix:

- Alert on consumer lag time.
- Tang retention.
- Autoscale consumers.
- Batch load sink.
- Separate replay path tu raw archive.

### Incident 3: out-of-order CDC update

Update customer tier `silver -> gold -> platinum`. Events den warehouse out-of-order, mart hien thi `gold` thay vi `platinum`.

Root cause:

- Merge khong compare source version/LSN.
- Kafka key khong dam bao cung customer vao cung partition.

Fix:

- Partition by customer_id.
- Include source_lsn/source_updated_at.
- Merge only if source version newer.
- Add test for stale updates.

### Incident 4: retry storm vao source database

API extraction job fail do rate limit. 200 tasks retry immediate, source API bi overload va ban IP.

Root cause:

- No exponential backoff.
- No global rate limit.
- Retry permanent/rate-limit errors nhu transient network errors.

Fix:

- Backoff + jitter.
- Respect Retry-After.
- Central rate limiter.
- Retry budget.
- Dead-letter/quarantine.

### Incident 5: Spark backfill overwrite live data

Backfill job va daily streaming job cung ghi partition hom nay. Backfill overwrite partition dang co live updates.

Root cause:

- No partition ownership.
- No coordination.
- Same output path for backfill and live.

Fix:

- Pause live writer for affected partitions.
- Write backfill to temp path.
- Validate then atomic swap.
- Use table format transaction.
- Document backfill runbook.

## Debugging distributed failures

### Step 1: Xac dinh boundary fail

Hoi:

- Fail o source, transport, compute, sink, metadata hay orchestrator?
- Operation co the da thanh cong du task bao fail khong?
- Co retry nao da chay khong?

### Step 2: Kiem tra identity va idempotency

- Event_id/business key la gi?
- Sink co unique constraint/merge key khong?
- Output co duplicate key khong?
- Retry co an toan khong?

### Step 3: Kiem tra ordering va watermark

- Events co source version/LSN khong?
- Update cu co overwrite update moi khong?
- Watermark co bo sot late data khong?

### Step 4: Kiem tra pressure

- Kafka lag?
- Spark task skew?
- Warehouse queue?
- API rate limit?
- Object storage file count?

### Step 5: Reconcile

- Source count vs sink count.
- Sum amount source vs fact.
- Max source_updated_at vs loaded_at.
- Duplicate keys.
- Missing deletes.

## Operational mindset

Senior DE van hanh distributed systems bang metrics va runbook, khong bang cam giac.

Metrics can co:

- Freshness.
- Lag.
- Throughput.
- Error rate.
- Retry count.
- Dead-letter count.
- Duplicate count.
- Late event count.
- Watermark.
- Query cost.
- File count.
- Task duration/skew.

Runbook can co:

- Khi lag tang thi lam gi.
- Khi duplicate xuat hien thi query nao.
- Khi backfill thi pause job nao.
- Khi schema drift thi quarantine ra sao.
- Khi replay thi reset offset/checkpoint nhu the nao.
- Khi warehouse timeout thi check remote job status o dau.

## Architecture diagrams

### At-least-once pipeline with idempotent sink

```text
Kafka topic
    |
    v
consumer reads message
    |
    v
merge into warehouse by business_key
    |
    v
commit offset after successful merge
```

If consumer fails before offset commit, message is processed again. Because sink uses merge by key, output remains correct.

### Non-idempotent retry failure

```text
task starts insert
    |
    v
warehouse insert succeeds
    |
    v
network timeout before task receives success
    |
    v
orchestrator retries
    |
    v
same rows inserted again
```

### Backpressure model

```text
producer -> queue/log -> consumers -> warehouse
              |
              v
          lag metric
              |
              v
       throttle / scale / alert
```

### CDC ordering model

```text
database WAL/binlog
      |
      v
CDC connector emits events with source_lsn
      |
      v
Kafka partitioned by primary key
      |
      v
sink merge only if incoming source_lsn is newer
```

## Trade-offs

### Strong consistency vs availability

Strong consistency:

- Tot cho correctness.
- Cham hon.
- Co the reject request khi partition.

Availability:

- He thong tiep tuc nhan write.
- Can reconcile.
- Co the co conflict/duplicate/stale reads.

### Ordering vs throughput

Global ordering:

- De reason hon.
- Kho scale.
- Bottleneck.

Partitioned ordering:

- Scale tot.
- Can key dung.
- Cross-key ordering khong co.

### Retry vs fail fast

Retry:

- Tot cho transient failures.
- Nguy hiem neu operation khong idempotent.
- Co the tao storm.

Fail fast:

- Tot cho permanent/data quality errors.
- Can alert va manual action.

### Batch vs streaming

Batch:

- De debug/replay.
- Latency cao.
- Cost predictable hon.

Streaming:

- Latency thap.
- State/order/retry phuc tap hon.
- Can lag/backpressure/checkpoint.

## Exercises

1. Mo ta mot pipeline ban da tung lam theo cac boundary: source, transport, compute, sink, orchestrator.
2. Tim 3 diem co the tao duplicate trong pipeline do.
3. Thiet ke idempotent sink cho orders.
4. Giai thich Kafka ordering neu key la `order_id` vs random UUID.
5. Mo phong orchestrator timeout sau warehouse insert va viet fix bang merge.
6. Thiet ke alert cho consumer lag gan retention limit.
7. Viet runbook cho retry storm.
8. Viet CDC merge logic dung `source_lsn` hoac `source_updated_at`.
9. Giai thich khi nao backfill nen pause live pipeline.
10. Liet ke metrics can monitor cho Spark streaming job.

## Mini project

Design distributed data pipeline cho ecommerce:

```text
Postgres orders DB
    |
    v
CDC connector
    |
    v
Kafka topic partitioned by order_id
    |
    v
Spark Structured Streaming
    |
    v
Lakehouse silver orders table
    |
    v
Warehouse gold fct_orders
    |
    v
BI dashboard
```

Yeu cau:

- Define source of truth.
- Define business key.
- Define ordering guarantee.
- Define duplicate handling.
- Define retry policy.
- Define backpressure strategy.
- Define replay strategy.
- Define CDC delete handling.
- Define idempotent sink.
- Define monitoring metrics.
- Define backfill runbook.

Deliverables:

- Architecture diagram.
- Failure mode table.
- Idempotency design.
- Monitoring and alerting plan.
- Replay/backfill runbook.
- Cost and scaling considerations.

## Interview questions

- CAP theorem co y nghia gi trong data pipelines?
- Eventual consistency la gi trong warehouse reporting?
- Kafka co guarantee ordering nhu the nao?
- Tai sao exactly-once thuong la marketing?
- Idempotency la gi va vi sao quan trong?
- Tai sao retry co the tao duplicate?
- Retry storm la gi va tranh ra sao?
- Backpressure la gi?
- CDC pipeline co nhung loi production nao?
- Spark task retry co the gay side effect gi?
- Network timeout khac application error nhu the nao?
- Khi nao can consensus/coordination?
- Sharding trade-off la gi?
- Consumer lag nen debug nhu the nao?
- Lam sao thiet ke replay an toan?

## GitHub outputs

- `distributed-pipeline-design.md`.
- Architecture diagrams.
- Failure mode and mitigation table.
- Idempotency checklist.
- Retry and backpressure policy.
- CDC merge strategy.
- Replay/backfill runbook.
- Monitoring dashboard spec.

## Core lesson

## Production appendix: clock skew, leases va mini failure simulator

### Clock skew

Distributed systems khong nen assume moi machine co cung clock chinh xac.

Data engineering impact:

- Event ordering by processing timestamp can be wrong.
- Freshness checks can false alarm.
- Windowing by event time vs processing time matters.

Mitigation:

- Prefer source event time for business semantics.
- Track ingestion time separately.
- Use watermarks for late data.

### Leases va fencing tokens

Lease cho phep mot worker giu quyen tam thoi. Fencing token ngan old worker ghi sau khi lease expired.

Failure:

- Worker A pause do GC/network, lease expired.
- Worker B takes lease.
- Worker A resumes and writes stale output.

Fix:

- Every write includes fencing token/version.
- Sink rejects stale token.

### Mini failure simulator ideas

1. Duplicate retry:
   - Simulate sink write success then offset commit fail.
   - Show idempotent key prevents duplicate.

2. Out-of-order events:
   - Send update version 2 before version 1.
   - Merge by version/LSN, not arrival time.

3. Stale read:
   - Read replica lag behind primary.
   - Show dashboard/current-state mismatch.

4. Retry storm:
   - 20 workers retry API 503 without jitter.
   - Add backoff+jitter and compare request rate.

Distributed systems khong fail theo cach don gian. Chung fail bang partial success, timeout, duplicate, stale state, out-of-order events va retry bat ngo.

Data Engineer gioi khong co ao tuong "pipeline se chay dung neu code dung". Data Engineer gioi thiet ke pipeline voi gia dinh:

- network se fail
- task se retry
- message se duplicate
- event se den tre
- ordering se bi gioi han
- sink co the da ghi du task bao fail
- backfill se can chay lai

Tu do, thiet ke dung se la:

- idempotent
- observable
- replayable
- cost-aware
- partition-aware
- failure-aware
- co runbook

Day la khac biet giua lam data pipeline va lam data infrastructure.
