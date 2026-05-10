# Storage va File Format cho Data Engineer

## Vai tro

Storage va file format la nen mong cua data platform. Nhieu pipeline cham, ton tien, kho backfill, kho debug khong phai vi SQL kem, ma vi data duoc luu sai cach:

- File qua nho.
- File qua lon.
- Dung CSV cho analytics quy mo lon.
- Partition sai cot.
- Khong giu raw data.
- Khong co schema evolution strategy.
- Khong co naming convention.

Data Engineer can hieu storage khong chi o muc "luu file len cloud". Can hieu data duoc doc nhu the nao, engine scan cot nao, file split ra sao, metadata quan trong the nao, va chi phi xuat hien o dau.

## Muc tieu can dat

- Hieu khac nhau giua object storage, database storage va warehouse storage.
- Biet khi nao dung CSV, JSON, Parquet, Avro, ORC.
- Hieu row-based vs columnar format.
- Hieu compression, predicate pushdown, column pruning.
- Thiet ke partition layout cho data lake.
- Debug small files problem.
- Hieu schema evolution va data contract o muc storage.
- Biet trade-off giua raw, curated va serving layers.

## Khai niem can nam

- Object storage.
- File format.
- Row-oriented vs columnar.
- Compression.
- Splittable files.
- Schema-on-read.
- Schema-on-write.
- Partitioning.
- Bucketing/clustering concept.
- Metadata.
- Predicate pushdown.
- Column pruning.
- Small files problem.
- Compaction.
- Schema evolution.
- Data layout.

## Architecture mindset

Mot data lake tot khong chi la bucket chua file. No la mot he thong co contract:

```text
source systems
      |
      v
raw zone: immutable source-like files
      |
      v
clean zone: typed, deduplicated, normalized files
      |
      v
curated zone: analytics-ready parquet tables
      |
      v
warehouse / lakehouse / serving marts
```

Nguyen tac:

- Raw data nen immutable.
- Clean layer nen co schema ro.
- Curated layer nen toi uu cho query pattern.
- Serving layer nen gan voi business use case.

Neu raw data bi overwrite tuy tien, ban mat kha nang reprocess. Neu curated layer khong co partition strategy, query se cham va ton tien. Neu khong co metadata, engine khong biet file nao can doc.

## File format mindset

### CSV

Tot cho:

- Human-readable.
- Export/import don gian.
- Dataset nho.

Kem cho:

- Data type.
- Nested data.
- Compression/query efficiency.
- Schema evolution.

Rui ro:

- Timestamp parse sai.
- Comma/quote/newline lam vo row.
- NULL va empty string khong ro.
- Moi query phai parse text lai tu dau.

### JSON

Tot cho:

- API response.
- Semi-structured raw events.
- Nested payload.

Kem cho:

- Analytics scan lon.
- Type consistency.
- Cost neu query truc tiep tren file lon.

Dung JSON tot nhat o raw layer. Sau do normalize sang Parquet cho analytics.

### Avro

Tot cho:

- Streaming.
- Kafka/CDC.
- Schema registry.
- Row-oriented serialization.

Avro phu hop voi event pipelines vi schema nam gan voi record va schema evolution duoc quan ly tot hon JSON thuan.

### Parquet

Tot cho:

- Analytics.
- Column pruning.
- Compression.
- Big data engines: Spark, Trino, DuckDB, BigQuery external table.

Parquet la lua chon mac dinh cho curated lake data.

Vi sao Parquet nhanh:

- Columnar: chi doc cot can dung.
- Compression tot vi du lieu cung cot thuong giong nhau.
- Metadata giup skip row groups.
- Predicate pushdown giup bo qua data khong can.

### ORC

Tuong tu Parquet, pho bien trong ecosystem Hive/Hadoop. Neu stack hien tai khong yeu cau ORC, Parquet thuong la lua chon thuc dung hon.

## Row vs columnar

Row-based format doc ca record:

```text
row1: order_id, customer_id, amount, status
row2: order_id, customer_id, amount, status
```

Columnar format luu theo cot:

```text
order_id:    O1, O2, O3
customer_id: C1, C2, C1
amount:      10, 20, 15
status:      paid, paid, cancelled
```

Analytics query thuong chi can mot so cot:

```sql
select order_date, sum(amount)
from orders
where order_date >= date '2026-01-01'
group by order_date;
```

Voi columnar format, engine khong can doc email, address, payload lon neu query khong dung.

## Partitioning

Partitioning la cach chia data thanh folder/file theo cot:

```text
orders/
  order_date=2026-05-01/
  order_date=2026-05-02/
  order_date=2026-05-03/
```

Partition tot khi:

- Query thuong filter theo cot do.
- Cardinality vua phai.
- Partition size khong qua nho.

Partition xau:

- Partition theo `customer_id` neu co hang trieu customer.
- Partition theo timestamp den phut/giay.
- Partition theo cot hiem khi filter.

Nguyen tac:

- Chon partition theo access pattern, khong theo cam tinh.
- Date partition la mac dinh tot cho event/order/log data.
- Neu query theo date + customer, partition theo date va cluster/bucket theo customer.

## Small files problem

Small files la mot trong nhung loi production rat pho bien.

Vi du:

```text
orders/order_date=2026-05-01/part-000001.parquet 20 KB
orders/order_date=2026-05-01/part-000002.parquet 18 KB
...
orders/order_date=2026-05-01/part-050000.parquet 22 KB
```

Tac hai:

- Engine ton thoi gian list/open file.
- Metadata overhead lon.
- Spark job tao qua nhieu task nho.
- Query latency tang.
- Cloud storage API cost tang.

Nguyen nhan:

- Streaming ghi micro-batch qua nho.
- Spark repartition sai.
- Moi event ghi mot file.
- Backfill chia qua manh.

Fix:

- Compaction job.
- Dieu chinh batch size.
- Coalesce/repartition hop ly.
- Dung lakehouse table format co optimize/compaction.

## Compression

Compression giam storage va IO, nhung ton CPU decompress.

Pho bien:

- Snappy: nhanh, compression vua, hay dung voi Parquet.
- Gzip: nen tot hon, cham hon, khong luon splittable tuy format.
- Zstd: compression tot, ngay cang pho bien.

Production mindset:

- Analytics format thuong dung Parquet + Snappy/Zstd.
- Log raw co the gzip neu chi archive.
- Dung benchmark voi workload that neu data lon.

## Schema evolution

Data thay doi theo thoi gian:

- Them cot.
- Doi type.
- Rename cot.
- Xoa cot.
- Doi meaning cua cot.

Them cot thuong de xu ly. Doi type va rename la nguy hiem.

Vi du incident:

```text
payment_amount: numeric -> string
```

Pipeline van ingest duoc JSON raw, nhung curated Parquet fail cast. Dashboard revenue mat data trong 6 gio.

Operational response:

- Alert schema drift.
- Quarantine bad records.
- Giu raw data de reprocess.
- Update contract voi source owner.
- Them test accepted type/range.

## Cost considerations

Chi phi storage va query den tu:

- So byte luu tru.
- So byte scan.
- So luong file/list operations.
- Data egress.
- Compute time.
- Warehouse slot/cluster time.

Giam cost:

- Dung Parquet thay CSV cho analytics.
- Select cot can dung.
- Partition theo query pattern.
- Compact small files.
- Xoa/temp expire data tam.
- Tach raw archive va curated serving.
- Theo doi table/file khong co owner.

## Debugging mindset

Khi query cham:

1. Query co scan qua nhieu partition khong?
2. Query co `select *` khong?
3. File format la CSV/JSON hay Parquet?
4. Co qua nhieu small files khong?
5. Filter co apply duoc predicate pushdown khong?
6. Cot filter co dung type khong hay bi cast?
7. Data co bi skew theo partition khong?

Khi data sai:

1. Raw co dung khong?
2. Clean layer cast co mat du lieu khong?
3. Partition path co khop cot trong file khong?
4. Schema thay doi tu source khong?
5. Backfill co overwrite sai partition khong?

## Real-world failures

### Failure 1: overwrite nham partition

Job backfill ngay `2026-05-01` nhung parameter date rong, overwrite ca table curated.

Prevention:

- Require explicit partition filter.
- Dry-run affected partitions.
- Write to temp path then swap.
- Backup/snapshot critical table.

### Failure 2: query cost tang gap 20 lan

Team them query dashboard dung `select *` tren external CSV raw table. Moi refresh scan hang TB.

Prevention:

- Curated Parquet table.
- Authorized marts.
- Query cost monitoring.
- Review dashboard SQL.

### Failure 3: small files tu streaming

Kafka consumer ghi Parquet moi 5 giay, tao hang tram nghin file/ngay.

Prevention:

- Buffer theo size/time.
- Compaction schedule.
- Lakehouse optimize.
- Monitor file count/partition.

## Exercises

1. Lay mot CSV lon, convert sang Parquet, so sanh dung luong file.
2. Query 3 cot tu CSV va Parquet, so sanh thoi gian/bytes scan neu engine ho tro.
3. Tao partition theo date va query co/khong co date filter.
4. Mo phong small files bang cach ghi 1000 file nho, sau do compact.
5. Tao schema drift: cot numeric thanh string, viet query detect bad records.
6. Viet README naming convention cho data lake.

## Mini project

Build mot curated lake layout cho ecommerce:

```text
data/
  raw/
    orders/ingestion_date=YYYY-MM-DD/*.json
    payments/ingestion_date=YYYY-MM-DD/*.json
  clean/
    orders/order_date=YYYY-MM-DD/*.parquet
    payments/payment_date=YYYY-MM-DD/*.parquet
  curated/
    fct_orders/order_date=YYYY-MM-DD/*.parquet
```

Yeu cau:

- Raw immutable.
- Clean co schema typed.
- Curated co grain ro.
- Co partition strategy.
- Co compaction note.
- Co schema evolution policy.
- Co cost optimization section.

## Interview questions

- Vi sao Parquet phu hop cho analytics hon CSV?
- Predicate pushdown la gi?
- Column pruning la gi?
- Partition sai gay van de gi?
- Small files problem la gi va fix ra sao?
- Schema-on-read va schema-on-write khac nhau nhu the nao?
- Khi nao nen giu raw JSON?
- Compaction co rui ro gi?
- Neu source doi type cot, pipeline nen xu ly sao?
- Lam sao giam cost tren data lake?

## GitHub outputs

- `data-layout.md` mo ta raw/clean/curated zones.
- Script convert CSV/JSON sang Parquet.
- Query/demo so sanh scan cost.
- File `schema-evolution-policy.md`.
- File `compaction-notes.md`.
- README co architecture, partition strategy, cost considerations.

## Production upgrade: Parquet internals va object-store failures

### Parquet internals

Parquet khong chi la "columnar file". No co:

- Row groups.
- Column chunks.
- Pages.
- Min/max statistics.
- Dictionary encoding.
- Compression per column chunk.

Predicate pushdown phu thuoc vao statistics. Neu file ghi khong co stats tot, engine co the scan nhieu hon.

Operational implication:

- Sort data theo common filter columns co the giup pruning.
- Row group size qua nho tang overhead.
- Row group qua lon giam parallelism va pruning.

### Compression codecs

Common choices:

- Snappy: fast, balanced, common default.
- ZSTD: compression tot hon, CPU cao hon.
- Gzip: tot cho text, splittability/analytics trade-off kem hon.

Rule:

- Analytics lakehouse: Snappy/ZSTD thuong tot.
- Cold archive: compression cao hon co the dang.
- Benchmark voi workload that, khong chon theo cam tinh.

### Avro vs Protobuf vs JSON

Avro:

- Tot cho Kafka/schema registry.
- Schema evolution mature.

Protobuf:

- Compact, typed, tot cho services.
- Can governance schema.

JSON:

- De debug.
- Flexible.
- Runtime errors/schema drift nhieu.

### Object store consistency va listing bottleneck

Object store khong giong local filesystem.

Problems:

- Listing millions of files cham/dat.
- Rename khong atomic nhu HDFS.
- Partial writes co the bi reader thay neu publish sai.
- Permission/path mistakes kho debug.

Production pattern:

- Partition path ro.
- Avoid too many small files.
- Write temp -> validate -> publish marker.
- Use table format/catalog de tranh listing raw folders qua nhieu.

### Corrupt file/debugging

Symptom:

- Spark/warehouse fail khi doc mot partition.

Triage:

1. Identify exact file path.
2. Check file size 0 bytes/partial.
3. Read file alone.
4. Compare schema with neighboring files.
5. Quarantine bad file.
6. Reprocess from raw/source.

Prevention:

- Checksums/row counts.
- Atomic publish pattern.
- Quarantine folder.
- Schema validation before publish.
