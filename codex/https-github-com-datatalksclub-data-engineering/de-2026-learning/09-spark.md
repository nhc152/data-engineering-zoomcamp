# Spark va Batch Processing Production-Grade

## Vai tro cua Spark

Spark la distributed compute engine dung cho batch processing va mot phan streaming/machine learning tren du lieu lon. Trong modern data platform, Spark thuong nam o giua data lake/lakehouse va warehouse:

```text
raw files / data lake
        |
        v
Spark batch jobs
        |
        v
curated parquet/delta/iceberg tables
        |
        v
warehouse / BI / ML features
```

Spark khong phai cau tra loi cho moi bai toan data. Neu du lieu vua du cho PostgreSQL, BigQuery, Snowflake, DuckDB hoac pandas thi dung Spark co the lam he thong phuc tap hon, debug kho hon va ton chi phi hon. Dung Spark khi can xu ly du lieu vuot qua mot may, can distributed join/aggregation, can doc/ghi data lake quy mo lon, hoac can chay job batch tren cluster.

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Giai thich Spark driver, executor, task, stage, job.
- Viet batch job bang DataFrame API va Spark SQL.
- Hieu lazy evaluation va DAG execution.
- Nhan dien shuffle, skew, small files, OOM.
- Chon partitioning phu hop cho input/output.
- Debug job cham bang Spark UI hoac logs.
- Biet khi nao dung broadcast join, repartition, coalesce, cache.
- Hieu Adaptive Query Execution o muc practical.
- Viet README giai thich performance trade-off cua Spark job.

## Khai niem can nam

- Driver: process dieu phoi job, build DAG, request executors, collect metadata.
- Executor: process chay tasks va giu cache data.
- Job: duoc trigger boi action nhu `count`, `write`, `collect`.
- Stage: nhom task giua cac shuffle boundary.
- Task: don vi thuc thi tren partition.
- Partition: phan data duoc xu ly boi task.
- Shuffle: di chuyen data qua network de group/join/repartition.
- Skew: mot vai partition qua lon so voi phan con lai.
- Lazy evaluation: Spark khong chay ngay khi goi transformation.
- Catalyst optimizer: optimizer cua Spark SQL/DataFrame.
- Tungsten: execution engine toi uu memory/codegen.
- AQE: Adaptive Query Execution, toi uu query luc runtime.
- Broadcast join: gui bang nho den cac executor de tranh shuffle lon.
- Small files problem: qua nhieu file nho lam planning/read overhead lon.

## Architecture mindset

### Spark khong xu ly mot table, Spark xu ly mot execution graph

Khi viet:

```python
df = spark.read.parquet("raw/orders")
result = df.groupBy("order_date").sum("amount")
result.write.parquet("curated/daily_revenue")
```

Spark khong chay ngay o dong `read` hay `groupBy`. No build logical plan. Khi gap `write`, Spark moi tao job, chia thanh stages, tasks, shuffle va output files.

Tu duy dung:

- Moi transformation co the thay doi plan.
- Moi join/groupBy co the tao shuffle.
- Moi output write co the tao nhieu file.
- Performance nam o plan, partitioning, data distribution, file layout.

### Driver la diem dieu phoi, khong phai noi chua data lon

Driver can:

- Tao SparkSession.
- Build query plan.
- Schedule tasks.
- Collect task metadata.

Driver khong nen:

- `collect()` data lon.
- Giu list hang trieu IDs trong memory.
- Tao qua nhieu small tasks/file metadata.

Driver OOM thuong den tu:

- `collect()` hoac `toPandas()` tren data lon.
- Qua nhieu file nho.
- Qua nhieu partition/task metadata.
- Broadcast bang khong that su nho.

### Executor xu ly partition

Moi executor xu ly tasks. Neu partition qua lon, task cham hoac OOM. Neu partition qua nho, overhead schedule cao. Neu partition skew, mot task keo dai trong khi cac task khac da xong.

Nguyen tac:

- Partition phai gan voi kich thuoc data va cluster.
- Khong dat partition theo cam tinh.
- Debug bang task duration, input size, shuffle read/write.

## DataFrame API va Spark SQL

Spark co 2 cach viet chinh:

- DataFrame API: tot cho pipeline code, type-ish structure, function reuse.
- Spark SQL: tot cho logic analytics, team SQL/dbt-like, de doc voi business transform.

DataFrame example:

```python
orders = spark.read.parquet("data/raw/orders")

daily = (
    orders
    .filter("order_status in ('paid', 'completed')")
    .groupBy("order_date")
    .agg({"amount": "sum", "order_id": "count"})
)

daily.write.mode("overwrite").parquet("data/curated/daily_revenue")
```

Spark SQL example:

```python
orders.createOrReplaceTempView("orders")

daily = spark.sql("""
    select
        order_date,
        count(*) as order_count,
        sum(amount) as revenue
    from orders
    where order_status in ('paid', 'completed')
    group by order_date
""")
```

Production advice:

- Dung DataFrame API cho orchestration logic va reusable functions.
- Dung SQL cho business transform neu team quen SQL.
- Khong tron qua nhieu style trong cung mot job neu lam code kho doc.

## Lazy evaluation va DAG execution

Transformation:

- `select`
- `filter`
- `withColumn`
- `join`
- `groupBy`
- `repartition`

Action:

- `count`
- `show`
- `collect`
- `write`
- `take`

Moi action co the trigger mot job rieng. Neu goi `count()` de log, roi `write()` sau do, Spark co the tinh lai toan bo lineage neu khong cache/persist.

Anti-pattern:

```python
print(df.count())
df.write.parquet(output_path)
```

Neu `df` rat dat de tinh, co the can:

```python
df = df.persist()
print(df.count())
df.write.parquet(output_path)
df.unpersist()
```

Nhung cache khong mien phi. Cache ton memory, co the lam eviction va OOM. Chi cache khi dung lai dataset nhieu lan va chi phi recompute cao.

## Partitioning

Partition la cach Spark chia data thanh cac phan de xu ly song song.

### Input partition

Spark tao partition dua tren:

- So file input.
- Kich thuoc file.
- File format.
- Config nhu `spark.sql.files.maxPartitionBytes`.

Neu co qua nhieu file nho, Spark co qua nhieu tasks, planning cham. Neu file qua lon, tasks it va moi task nang.

### Shuffle partition

Default thuong la:

```text
spark.sql.shuffle.partitions = 200
```

Voi data nho, 200 co the qua nhieu. Voi data lon, 200 co the qua it.

Tuning:

```python
spark.conf.set("spark.sql.shuffle.partitions", "400")
```

Khong co so magic. Can dua tren:

- Data size.
- Cluster size.
- Task duration.
- Shuffle size.
- SLA.

### Repartition vs coalesce

`repartition(n)`:

- Tao shuffle.
- Co the tang/giam partition.
- Dung khi can redistribute data.

`coalesce(n)`:

- Thuong khong shuffle full.
- Chu yeu dung de giam partition.
- Co the tao partition khong deu.

Dung sai:

```python
df.coalesce(1).write.parquet("output")
```

Day la anti-pattern neu data lon. No ep mot task ghi mot file, cham va de OOM. Chi dung khi output rat nho va co ly do ro.

## Shuffle

Shuffle la mot trong nhung thu dat nhat trong Spark. No xay ra khi data can di chuyen giua executors:

- `groupBy`
- `join` khong broadcast
- `distinct`
- `dropDuplicates`
- `repartition`
- window function voi partition/order

Shuffle dat vi:

- Ghi/read disk.
- Network transfer.
- Serialization.
- Task straggler.
- Skew lam mot vai partition qua lon.

Debug shuffle:

- Xem shuffle read/write size.
- Xem stage nao ton thoi gian.
- Xem task nao cham bat thuong.
- Xem spill memory/disk.

## Join strategy

### Shuffle hash/sort-merge join

Khi hai bang lon join voi nhau, Spark can shuffle theo join key. Day la join dat.

### Broadcast join

Neu mot bang nho, Spark broadcast bang nho den executor de join local, tranh shuffle bang lon.

```python
from pyspark.sql.functions import broadcast

result = large_orders.join(
    broadcast(small_customers),
    on="customer_id",
    how="left"
)
```

Nen broadcast khi:

- Dimension table that su nho.
- Memory executor du.
- Bang nho khong bi explode sau filter.

Khong nen broadcast khi:

- Bang "nho" van vai GB.
- Driver/executor memory yeu.
- Bang co data skew hoac bi duplicate nhieu.

### Join explosion

Spark khong sua duoc modeling sai. Neu join order-level voi item-level roi sum order amount, metric van sai. Distributed engine chi lam sai nhanh hon va dat hon.

## Skew

Skew xay ra khi mot vai key co qua nhieu rows.

Vi du:

- `customer_id = 'unknown'` chiem 40% data.
- `country = 'US'` qua lon so voi cac country khac.
- Mot merchant co hang tram trieu events.

Trieu chung:

- Stage co 199 tasks xong nhanh, 1 task chay rat lau.
- Shuffle partition size lech lon.
- Executor OOM o mot vai task.

Debug:

```python
df.groupBy("join_key").count().orderBy("count", ascending=False).show(20)
```

Fix options:

- Filter/handle key abnormal rieng.
- Salt key cho join/aggregation.
- Broadcast bang nho neu phu hop.
- Tang partition khong giai quyet tri de neu skew qua nang.
- Thay doi data model hoac pre-aggregate.

Salt join concept:

```text
large table: add salt 0..N for hot key
small table: duplicate hot key rows N times
join on key + salt
```

Day la ky thuat co chi phi, chi dung khi da prove skew la root cause.

## Small files problem

Small files lam Spark cham vi:

- Metadata listing dat.
- Qua nhieu tasks nho.
- Driver planning overhead.
- Downstream query engines cham.

Nguyen nhan:

- Ghi output partition qua chi tiet.
- Streaming micro-batch ghi nhieu file nho.
- Dung `repartition` sai.
- Moi run append them nhieu file.

Fix:

- Compact files dinh ky.
- Ghi partition theo date thay vi timestamp.
- Dieu chinh output partition count.
- Dung lakehouse table format co optimize/compaction neu co: Delta/Iceberg/Hudi.

## AQE - Adaptive Query Execution

AQE giup Spark toi uu query luc runtime:

- Coalesce shuffle partitions.
- Switch join strategy khi biet size thuc te.
- Handle skew join o mot so truong hop.

Config thuong gap:

```python
spark.conf.set("spark.sql.adaptive.enabled", "true")
spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")
spark.conf.set("spark.sql.adaptive.skewJoin.enabled", "true")
```

AQE khong thay the viec hieu data. Neu join key skew nang, modeling sai, input small files qua nhieu, AQE chi giam dau phan nao.

## Performance tuning mindset

Thu tu debug job cham:

1. Xac dinh stage cham nhat.
2. Xem co shuffle lon khong.
3. Xem task duration co skew khong.
4. Xem spill memory/disk.
5. Xem input file count va file size.
6. Xem join strategy.
7. Xem partition count.
8. Xem code co action lap lai khong.
9. Xem output co tao small files khong.

Khong nen tuning bang cach tang executor/memory ngay tu dau. Neu plan sai, them compute chi lam bill cao hon.

## Debugging slow jobs

### Case 1: Job cham do shuffle lon

Trieu chung:

- Stage groupBy/join lau.
- Shuffle write/read rat lon.
- Network/disk high.

Huong xu ly:

- Filter cot/row truoc shuffle.
- Pre-aggregate neu co the.
- Broadcast dimension nho.
- Chon join key dung.
- Loai bo cot khong can truoc join.

### Case 2: Job cham do skew

Trieu chung:

- Mot vai task rat lau.
- Mot vai executor xu ly qua nang.

Huong xu ly:

- Profile key distribution.
- Tach hot keys.
- Salt join.
- Broadcast neu co the.
- Thay doi aggregation logic.

### Case 3: Job cham do small files

Trieu chung:

- Planning lau.
- Nhieu tasks rat nho.
- Input file count qua lon.

Huong xu ly:

- Compact input.
- Tang max partition bytes neu phu hop.
- Output fewer files.
- Dung table format co optimize.

## OOM problems

Driver OOM:

- `collect()` data lon.
- `toPandas()` data lon.
- Qua nhieu files/partitions.
- Broadcast variable qua lon.

Executor OOM:

- Partition qua lon.
- Skew.
- Join/groupBy can memory lon.
- Cache qua nhieu.
- UDF tao object nhieu.

Debug OOM:

- Xem log stack trace.
- Xem executor nao fail.
- Xem stage/task fail.
- Xem input size cua task.
- Xem co spill truoc khi OOM khong.

Fix:

- Giam data truoc operation dat.
- Tang partition neu partition qua lon.
- Xu ly skew.
- Bo cache khong can.
- Tang memory chi sau khi da toi uu plan.

## Production mindset

Mot Spark job production can co:

- Input/output contract ro.
- Idempotency: chay lai khong tao duplicate.
- Partition strategy ro.
- Failure handling: output temp path hoac overwrite partition an toan.
- Logging: row count, input path, output path, runtime.
- Data quality checks.
- Backfill strategy.
- Cost monitoring.
- Small files strategy.

Pattern an toan:

```text
read raw partition date = D
validate raw
transform
write to temp path
validate output
atomic publish / overwrite target partition
record metadata
```

## Real-world failures

### Failure: collect lam crash driver

Nguyen nhan:

- Developer dung `collect()` de tao list IDs.

Tac hai:

- Driver OOM.
- Job fail truoc khi write.

Fix:

- Dung join thay vi collect list.
- Neu can list nho, limit va validate size truoc.

### Failure: Backfill tao hang trieu small files

Nguyen nhan:

- Moi ngay ghi hang ngan file nho.
- Backfill 2 nam append vao lake.

Tac hai:

- Query downstream cham.
- Metadata overhead tang.

Fix:

- Compaction sau backfill.
- Dieu chinh output partition.
- Partition theo date thich hop.

### Failure: Skew key lam job 6 gio

Nguyen nhan:

- `customer_id = null` hoac `unknown` chiem phan lon.

Fix:

- Clean key truoc join.
- Tach null/unknown path.
- Salt hot key neu can.

## Trade-offs

- Spark vs warehouse SQL: Spark linh hoat voi file/lake, warehouse de van hanh va toi uu query analytics hon.
- More partitions vs fewer partitions: nhieu partition tang parallelism nhung tang overhead.
- Cache vs recompute: cache nhanh hon neu reuse, nhung ton memory.
- Broadcast vs shuffle join: broadcast nhanh neu dimension nho, nguy hiem neu bang nho khong that su nho.
- Full refresh vs incremental: full refresh don gian, incremental nhanh hon nhung kho dung va can data quality.

## Cost considerations

Chi phi Spark den tu:

- Cluster runtime.
- So executor/memory.
- Shuffle disk/network.
- Input/output storage.
- Rerun do failure.
- Small files lam downstream ton chi phi.

Giam chi phi:

- Filter early.
- Select only needed columns.
- Dung Parquet/Delta/Iceberg thay CSV.
- Partition output theo query pattern.
- Tranh rerun toan bo neu chi can partition nho.
- Monitor job duration va data processed.

## Exercises

1. Doc CSV ecommerce, ghi Parquet partition theo `order_date`.
2. Viet job aggregate daily revenue bang DataFrame API.
3. Viet cung logic bang Spark SQL.
4. Tao join order-items-products va check grain.
5. Tao skew synthetic: 50% rows co `customer_id = 'unknown'`, debug stage cham.
6. Chay job voi va khong broadcast join, so sanh plan.
7. Tao 1000 small files, do thoi gian read, sau do compact.
8. Dung `explain()` de xem physical plan.
9. Gia lap `collect()` va viet lai bang join/distributed operation.

## Mini project

Build Spark batch pipeline:

```text
raw/orders/*.json
raw/order_items/*.json
raw/payments/*.json
        |
        v
Spark validation + cleaning
        |
        v
curated/orders_parquet partitioned by order_date
        |
        v
mart_daily_revenue
```

Yeu cau:

- Input co duplicate order versions.
- Deduplicate bang window function.
- Aggregate item/payment truoc khi join.
- Output Parquet partitioned by `order_date`.
- Log input row count, output row count, duplicate count.
- Co README giai thich partition, shuffle, join strategy.
- Co section "known failure modes".

## Interview questions

- Driver va executor khac nhau nhu the nao?
- Spark lazy evaluation la gi?
- Transformation va action khac nhau ra sao?
- Shuffle la gi va vi sao dat?
- Skew la gi, debug nhu the nao?
- Broadcast join khi nao nen dung?
- Vi sao `collect()` nguy hiem?
- Small files problem la gi?
- AQE giup gi va khong giup gi?
- Khi nao khong nen dung Spark?
- Mot Spark job cham, ban debug theo thu tu nao?
- Executor OOM va driver OOM khac nhau ra sao?

## GitHub outputs

Repo Spark nen co:

- `src/jobs/` chua Spark jobs.
- `src/lib/` chua reusable transforms.
- `tests/` cho transform logic nho.
- `docker-compose.yml` hoac local Spark setup.
- `sample_data/` nho, khong commit data lon.
- `README.md` co architecture va run command.
- `PERFORMANCE_NOTES.md` ghi partition strategy, shuffle, join strategy.
- `RUNBOOK.md` ghi cach debug job fail/cham.

## Production upgrade: Spark UI va tuning decision tree

### Cluster/resource manager context

Spark job co the chay tren:

- Local mode: hoc va test nho.
- Dataproc/EMR: managed cluster.
- Kubernetes: container-native, phu hop platform mature.
- Standalone/YARN: gap trong enterprise cu.

Architecture decision:

- Short ad-hoc job: ephemeral cluster.
- Recurring heavy pipeline: tuned cluster/job template.
- Multi-tenant platform: workload isolation va quota quan trong hon raw speed.

### Executor sizing

Sizing sai gay OOM, GC cao hoac cluster idle.

Can can bang:

- Executor memory.
- Executor cores.
- Number of executors.
- Shuffle partitions.
- Input file size.

Rule thuc dung:

- Qua nhieu cores/executor co the lam GC/shuffle contention.
- Qua it memory gay spill/OOM.
- Qua nhieu small executors tang overhead.
- Tune dua tren Spark UI, khong doan.

### Spark UI incident walkthrough

Symptom:

- Job chay 2 gio, truoc day 20 phut.

Triage trong Spark UI:

1. Stage nao chiem thoi gian lon nhat?
2. Task duration co skew khong: mot vai task rat lau?
3. Shuffle read/write tang dot bien khong?
4. Spill memory/disk co cao khong?
5. GC time co cao khong?
6. Input records/bytes co tang khong?
7. Failed/retried tasks co nhieu khong?

Interpretation:

- Long tail tasks -> skew.
- High shuffle write/read -> groupBy/join/repartition expensive.
- High spill -> memory pressure hoac partition qua lon.
- High GC -> executor memory/object pressure.
- Many failed tasks -> bad node, bad file, OOM, flaky storage.

### Tuning decision tree

```text
Job slow?
  -> one/few tasks slow? skew handling
  -> all tasks slow? input size/query logic/resource
  -> high shuffle? reduce wide transformations, pre-aggregate, broadcast small table
  -> high spill? increase memory or partitions, reduce row width
  -> many small files? compact
  -> OOM driver? avoid collect, reduce metadata/listing, use distributed ops
```

### Checkpointing va speculative execution

Checkpointing:

- Cat lineage dai.
- Huu ich cho iterative/stateful jobs.
- Ton storage va write cost.

Speculative execution:

- Chay duplicate task cho straggler.
- Co the giup khi node cham.
- Co the ton compute gap doi neu skew logic that su.

### File commit protocols

Production write failures hay do partial output:

- Task fail sau khi ghi mot phan.
- Job retry de lai temp files.
- Object store rename khong atomic nhu HDFS.

Operational lesson:

- Dung output committer phu hop object store.
- Write to temp path + publish marker.
- Avoid readers consuming incomplete output.
