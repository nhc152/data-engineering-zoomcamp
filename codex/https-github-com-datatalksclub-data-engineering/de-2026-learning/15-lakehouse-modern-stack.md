# Lakehouse va Modern Data Stack

## Vai tro

Lakehouse la cach ket hop data lake va warehouse: luu data tren object storage nhung co table semantics nhu warehouse:

- ACID transactions.
- Schema enforcement/evolution.
- Time travel.
- Merge/upsert.
- Metadata management.
- Batch va streaming cung ghi/doc mot table.

Data Engineer khong nhat thiet phai dung lakehouse ngay tu dau, nhung nam 2026 can hieu vi sao Delta Lake, Apache Iceberg, Apache Hudi, Databricks, Snowflake external tables, BigQuery lakehouse patterns ngay cang pho bien.

## Muc tieu can dat

- Hieu data lake, warehouse, lakehouse khac nhau.
- Hieu table format la gi.
- Hieu ACID tren object storage kho vi sao.
- Biet Delta/Iceberg/Hudi giai quyet van de gi.
- Biet khi nao warehouse la du, khi nao lakehouse co loi.
- Hieu medallion architecture.
- Hieu batch/streaming unification.
- Hieu metadata catalog va governance.

## Khai niem can nam

- Data lake.
- Data warehouse.
- Lakehouse.
- Table format.
- Transaction log.
- Snapshot.
- Manifest.
- ACID.
- Time travel.
- Merge/upsert.
- Schema evolution.
- Medallion architecture.
- Catalog.
- Data governance.
- Open table formats.

## Architecture mindset

Classic lake:

```text
object storage files
  -> many folders
  -> many engines
  -> weak table guarantees
```

Warehouse:

```text
managed storage + compute
  -> strong SQL experience
  -> governance
  -> performance
  -> cost can grow
```

Lakehouse:

```text
object storage
  + table format metadata
  + transaction log/snapshots
  + compute engines
  + catalog/governance
```

Lakehouse khong phai chi la "Parquet tren S3/GCS". Parquet la file format. Lakehouse table format quan ly tap file do thanh mot table co version, transaction va metadata.

## Medallion architecture

Pho bien trong lakehouse:

```text
Bronze: raw-ish ingested data
   |
   v
Silver: cleaned, deduplicated, conformed data
   |
   v
Gold: business-ready facts, dimensions, marts
```

Mapping voi terminology khac:

- Bronze gan voi raw.
- Silver gan voi staging/clean/intermediate.
- Gold gan voi marts/serving.

Production rule:

- Bronze khong nen mat data.
- Silver phai co schema va dedup.
- Gold phai co business definitions va quality checks.

## Why lakehouse exists

Data lake truyen thong co van de:

- File overwrite khong atomic.
- Reader co the doc table dang ghi do.
- Khong co transaction log.
- Upsert kho.
- Delete/GDPR kho.
- Schema evolution kho.
- Listing file tren object storage cham.
- Nhieu engine khong dong nhat metadata.

Lakehouse table formats them metadata layer de biet:

- Snapshot nao dang active.
- File nao thuoc table.
- File nao bi delete.
- Schema hien tai la gi.
- Transaction nao da commit.

## Delta Lake, Iceberg, Hudi

### Delta Lake

Manh trong Databricks ecosystem.

Tot cho:

- ACID transaction.
- Merge/upsert.
- Time travel.
- Optimize/compaction.
- Streaming + batch.

### Apache Iceberg

Open table format rat quan trong cho multi-engine stack.

Tot cho:

- Hidden partitioning.
- Snapshot isolation.
- Schema evolution.
- Trino, Spark, Flink, Snowflake, BigQuery ecosystem integration.

### Apache Hudi

Manh cho ingestion, CDC, upsert-heavy workloads.

Tot cho:

- Incremental pulls.
- Copy-on-write / merge-on-read.
- CDC pipelines.

## Trade-offs

Lakehouse loi:

- Open storage.
- Nhieu engine cung doc.
- Chi phi storage linh hoat.
- Upsert/delete tren lake.
- Time travel va replay tot.

Lakehouse chi phi/complexity:

- Metadata/catalog phuc tap.
- Compaction/vacuum can van hanh.
- Small files van la van de.
- Engine compatibility can kiem tra.
- Governance khong tu nhien bang managed warehouse neu tu build.

Warehouse loi:

- SQL UX tot.
- Performance managed.
- Governance/permission manh.
- It van hanh hon.

Warehouse han che:

- Lock-in.
- Cost query/compute co the cao.
- Raw/semi-structured lake integration tuy platform.

## Production mindset

Lakehouse table can co owner, SLA, retention, compaction policy va schema evolution policy.

Khong nen:

- De moi team ghi truc tiep vao cung table.
- Chay vacuum/delete ma khong hieu time travel retention.
- Cho streaming ghi file nho vo han.
- Dung merge/upsert khong co unique key.
- Dung gold table lam scratch table.

Nen:

- Tach bronze/silver/gold.
- Co catalog naming convention.
- Co automated tests.
- Co compaction schedule.
- Co table health metrics.
- Co rollback/time travel playbook.

## Cost considerations

Cost lakehouse den tu:

- Object storage.
- Compute engine doc/ghi.
- Metadata operations.
- Compaction jobs.
- Small files overhead.
- Cross-region reads.
- Catalog/service charges.

Giam cost:

- Optimize file size.
- Partition/clustering theo query.
- Compact regularly.
- Vacuum expired files dung chinh sach.
- Dung materialized gold tables cho dashboard nang.
- Avoid merge qua thuong xuyen tren table qua lon neu khong can.

## Debugging mindset

Khi lakehouse query sai:

1. Snapshot nao dang duoc doc?
2. Job co commit thanh cong khong?
3. Co concurrent writers khong?
4. Schema co thay doi khong?
5. Partition/file metadata co stale khong?
6. Co files orphan khong?
7. Reader engine co support table feature do khong?

Khi query cham:

1. File count/size ra sao?
2. Partition pruning co hoat dong khong?
3. Statistics co du khong?
4. Merge-on-read co doc qua nhieu delta/log files khong?
5. Co can optimize/compact khong?

## Real production incidents

### Incident 1: Vacuum xoa data can time travel

Team chay vacuum retention 0 gio de giam storage. Sau do phat hien gold table sai va can rollback ve snapshot cu, nhung file da bi xoa.

Lesson:

- Retention policy la reliability feature, khong chi la storage cleanup.
- Critical tables can rollback window.
- Vacuum can require approval.

### Incident 2: CDC merge duplicate vi key sai

CDC stream co composite key `(order_id, line_id)`, nhung merge chi dung `order_id`. Ket qua order co nhieu line bi overwrite sai.

Lesson:

- Merge key phai khop grain.
- CDC can event ordering va operation type.
- Test duplicate key truoc merge.

### Incident 3: Multi-engine incompatibility

Spark ghi table voi feature moi, Trino version cu khong doc duoc.

Lesson:

- Table format version va engine support phai duoc quan ly.
- Upgrade compatibility test la bat buoc.

## Exercises

1. Mo ta su khac nhau giua Parquet file va Iceberg/Delta table.
2. Thiet ke bronze/silver/gold cho ecommerce.
3. Viet policy cho schema evolution.
4. Viet policy cho compaction va vacuum.
5. Mo phong CDC upsert va xac dinh merge key.
6. Thiet ke rollback plan khi gold table sai.

## Mini project

Design lakehouse architecture cho ecommerce analytics:

```text
Postgres CDC
    |
    v
Kafka / landing files
    |
    v
Bronze lakehouse tables
    |
    v
Silver conformed tables
    |
    v
Gold facts, dimensions, marts
    |
    v
BI / ML / reverse ETL
```

Yeu cau:

- Chon table format: Delta, Iceberg hoac Hudi.
- Giai thich ly do chon.
- Dinh nghia grain bronze/silver/gold.
- Mo ta merge/upsert strategy.
- Mo ta partition strategy.
- Mo ta compaction/vacuum policy.
- Mo ta rollback/time travel strategy.
- Mo ta data quality gates.

## Interview questions

- Lakehouse khac data lake nhu the nao?
- Parquet co phai lakehouse khong?
- Delta/Iceberg/Hudi giai quyet van de gi?
- ACID tren object storage kho o diem nao?
- Time travel dung de lam gi?
- Merge-on-read va copy-on-write trade-off la gi?
- Khi nao warehouse tot hon lakehouse?
- Khi nao lakehouse dang overkill?
- CDC vao lakehouse can canh giac dieu gi?
- Vacuum/retention co rui ro gi?

## GitHub outputs

- `lakehouse-architecture.md`.
- Diagram bronze/silver/gold.
- Table design document.
- Merge key and CDC strategy.
- Compaction/vacuum policy.
- Cost considerations.
- Incident runbook for rollback.

## Production upgrade: table metadata architecture

### Why table formats exist

Plain Parquet folders lack:

- Transaction log.
- Snapshot history.
- Atomic commits.
- Schema evolution rules.
- Efficient file pruning metadata.
- Safe concurrent writes.

Lakehouse table formats add metadata layer so engines can treat object storage more like transactional tables.

### Delta vs Iceberg vs Hudi decision lens

Delta Lake:

- Strong Databricks ecosystem.
- Transaction log straightforward.
- Good for teams standardized on Databricks.

Iceberg:

- Strong open table format adoption across engines.
- Snapshot/manifest architecture.
- Good multi-engine lakehouse direction.

Hudi:

- Strong CDC/upsert orientation.
- Copy-on-write and merge-on-read options.
- Useful where streaming ingestion/upserts are central.

Decision factors:

- Which compute engines must read/write?
- Do you need heavy upserts/CDC?
- Who manages catalog?
- What is the compaction/vacuum operational burden?
- What skills does the team have?

### Metadata files, manifests, snapshots

Iceberg-style mental model:

```text
table
  -> current snapshot
  -> manifest list
  -> manifests
  -> data files
```

Why it matters:

- Snapshot isolation enables consistent reads.
- Metadata pruning avoids listing huge folders.
- Too many metadata files can degrade planning time.

### Concurrent writers

Failure mode:

- Two pipelines merge into same table/partition.
- One commit succeeds, another conflicts.

Mitigation:

- Optimistic concurrency retry with bounded attempts.
- Partition/job ownership.
- Serialize writes for high-conflict tables.
- Idempotent merge keys.

### Copy-on-write vs merge-on-read

Copy-on-write:

- Reads faster/simpler.
- Writes/updates more expensive.

Merge-on-read:

- Writes faster for updates.
- Reads may merge base + delta/log files.
- Needs compaction scheduling.

Trade-off is workload-dependent: read-heavy BI favors COW; heavy CDC/upserts may favor MOR.

### Compaction/vacuum operations

Compaction is not optional at scale.

Runbook:

1. Monitor small file count.
2. Compact by partition.
3. Avoid compacting active hot partitions too aggressively.
4. Validate row counts after compaction.
5. Vacuum only after retention window.

Risk:

- Vacuum too soon breaks time travel or streaming readers.
- Compaction competes with production jobs for compute.
