# Cloud, Data Lake va Data Warehouse

## Vai tro

Cloud warehouse va data lake la nen tang luu tru, xu ly va phuc vu du lieu cho modern data platform. Neu SQL la ngon ngu cot loi, thi cloud storage va warehouse la noi SQL duoc chay tren du lieu lon, voi chi phi, bao mat, reliability va scale that.

Voi nguoi da quen ODI/Talend, diem chuyen doi quan trong la: du lieu khong con chi di tu database A sang database B. Du lieu hien dai thuong di qua cac layer:

```text
source systems
    -> object storage / data lake
    -> warehouse raw tables
    -> staging models
    -> curated marts
    -> BI / ML / reverse ETL / data products
```

Trong lo trinh 2026, nen chon mot cloud de hoc sau. Neu theo DataTalksClub Zoomcamp, GCP la lua chon hop ly:

- Google Cloud Storage dung lam data lake.
- BigQuery dung lam cloud data warehouse.
- IAM/service account dung de quan ly quyen.
- Cloud billing/cost dashboard dung de quan sat chi phi.

## Muc tieu can dat

Sau module nay, ban nen lam duoc:

- Giai thich data lake, data warehouse va lakehouse khac nhau the nao.
- Thiet ke raw/staging/mart layers tren cloud.
- Upload raw files len Google Cloud Storage.
- Load data tu GCS vao BigQuery.
- Tao external table va managed table.
- Chon partitioning/clustering dua tren query pattern.
- Uoc tinh va giam query cost.
- Hieu storage vs compute separation.
- Hieu OLTP vs OLAP va vi sao warehouse khong thay the app database.
- Debug query cham, query ton tien, missing partition filter, schema drift.
- Trinh bay warehouse architecture trong interview.

## Khai niem can nam

- Cloud project.
- Region/location.
- IAM.
- Service account.
- Object storage.
- Bucket.
- Prefix.
- Data lake.
- Data warehouse.
- Lakehouse.
- OLTP.
- OLAP.
- Columnar storage.
- Storage vs compute separation.
- External table.
- Managed/native table.
- Partitioning.
- Clustering.
- File format: CSV, JSON, Parquet, Avro.
- Compression.
- Schema evolution.
- BigQuery dataset/table/view.
- Query scan cost.
- Slot/compute concept.
- Data lifecycle.
- Retention.
- Encryption.

## GCP fundamentals

### Project

GCP project la boundary cho resource, billing, IAM va APIs. Moi lab nen co project rieng neu co the.

Can biet:

- Project ID la unique.
- Billing gan voi project.
- API phai duoc enable.
- IAM policy co the gan o project/dataset/bucket level.

### Region va location

Du lieu co location. BigQuery dataset va GCS bucket nen cung location neu pipeline thuong doc/ghi giua hai ben.

Trade-off:

- Single region: latency/cost tot hon trong mot vung.
- Multi-region: phu hop analytics toan vung, nhung co the dat hon va phai can than voi data residency.

Production rule:

- Khong tao bucket US, dataset EU mot cach tuy tien.
- Document location trong README.
- Can biet yeu cau compliance neu du lieu nhay cam.

### IAM va service account

Service account la identity cho machine/pipeline, khong phai nguoi dung.

Production pattern:

- Developer dung user account.
- Pipeline dung service account.
- Service account chi co quyen can thiet.
- Key file khong commit len GitHub.
- Neu co the, dung workload identity thay vi key file dai han.

Quyen hay gap:

- GCS read/write bucket.
- BigQuery job user.
- BigQuery data editor/viewer.
- Secret access neu dung secret manager.

## Architecture mindset

### Storage vs compute separation

Modern cloud data platform tach storage va compute:

- Storage: GCS, BigQuery storage, S3, ADLS.
- Compute: BigQuery execution engine, Spark, Dataproc, Dataflow, Snowflake warehouse.

Y nghia:

- Co the luu data re ma khong can compute chay lien tuc.
- Co the scale compute khi query/job nang.
- Co the cung mot data lake phuc vu nhieu engine.

Trade-off:

- De tao nhieu engine doc cung data, nhung de gay governance phuc tap.
- Neu khong co naming/versioning, lake nhanh thanh noi chua file kho debug.

### Lake vs warehouse

Data lake:

- Luu raw/semi-structured data.
- Reprocess duoc.
- Linh hoat schema.
- Tot cho logs, events, file dump, ML features, archive.

Data warehouse:

- Structured analytics.
- SQL performance tot.
- Governance, permission, lineage de hon.
- Phu hop BI, dashboard, KPI, marts.

Pattern thuc te:

```text
GCS raw zone
    -> BigQuery raw/external tables
    -> BigQuery staging tables/views
    -> BigQuery marts
    -> BI/dbt/semantic layer
```

### Lakehouse introduction

Lakehouse co gang ket hop lake va warehouse:

- Data nam tren object storage.
- Table format co metadata, transaction, schema evolution.
- Engine co the query nhu warehouse.

Cong nghe hay gap:

- Delta Lake.
- Apache Iceberg.
- Apache Hudi.
- Databricks.
- BigLake/BigQuery external tables o mot so use case.

Trong 3 thang dau, chi can hieu concept. Chua can hoc sau Delta/Iceberg neu chua vung warehouse va data modeling.

## GCS: Google Cloud Storage

### Vai tro cua GCS

GCS la object storage. No khong phai file system truyen thong, du nhin giong folder.

Dung de:

- Luu raw files.
- Luu parquet/csv exports.
- Luu ingestion landing zone.
- Luu backup/archive.
- Lam source cho BigQuery external table.

### Bucket va prefix

Object path thuong co dang:

```text
gs://company-data-lake/raw/orders/source=shopify/ingestion_date=2026-05-09/orders_001.json
```

Production naming pattern:

```text
gs://<company>-<env>-data-lake/
  raw/<source>/<entity>/ingestion_date=YYYY-MM-DD/
  bronze/<domain>/<entity>/dt=YYYY-MM-DD/
  silver/<domain>/<entity>/dt=YYYY-MM-DD/
  gold/<domain>/<entity>/dt=YYYY-MM-DD/
```

Khong can dung bronze/silver/gold neu team khong dung lakehouse. Nhung can co layer ro: raw, cleaned, curated.

### File format

CSV:

- De doc.
- De debug.
- Khong co schema manh.
- Cham va ton hon khi scan lon.

JSON:

- Tot cho API/events.
- Linh hoat.
- De schema drift.

Parquet:

- Columnar.
- Compression tot.
- Co schema.
- Tot cho analytics va Spark/warehouse external reads.

Production rule:

- Raw API co the giu JSON.
- Curated lake nen uu tien Parquet.
- File nho qua nhieu gay overhead. File qua lon kho parallelize.

## BigQuery

### Vai tro cua BigQuery

BigQuery la serverless cloud data warehouse. Ban khong quan ly cluster may chu. Ban quan ly:

- Dataset.
- Table/view.
- Partitioning/clustering.
- Permission.
- Query cost.
- Job history.
- Data lifecycle.

### Dataset va table

Pattern:

```text
raw_orders
staging_orders
marts_orders
```

Hoac theo dataset:

```text
raw.orders
staging.stg_orders
marts.fct_orders
marts.dim_customers
```

Khuyen nghi cho hoc va portfolio: dung dataset theo layer vi de giai thich.

### External table vs managed table

External table:

- Data nam tren GCS.
- BigQuery doc truc tiep.
- Tot de inspect raw files.
- Performance/governance co the kem managed table.

Managed/native table:

- Data duoc load vao BigQuery storage.
- Performance tot hon.
- Partition/clustering ro hon.
- Phu hop marts va dashboard.

Pattern thuc te:

- External table cho raw landing.
- Managed table cho staging/marts.

### Columnar storage

Warehouse columnar doc cot can thiet thay vi doc ca row. Vi vay:

```sql
select customer_id, order_date
from marts.fct_orders
where order_date = '2026-05-01';
```

thuong re hon:

```sql
select *
from marts.fct_orders;
```

Production habit:

- Khong `select *` tren table lon.
- Chi lay cot can dung.
- Filter partition cot som.

## OLTP vs OLAP

OLTP:

- App database nhu PostgreSQL/MySQL.
- Nhieu insert/update nho.
- Can transaction latency thap.
- Schema normalized.
- Index quan trong.

OLAP:

- Warehouse nhu BigQuery/Snowflake/Redshift.
- Query analytic tren data lon.
- Scan, aggregate, join.
- Columnar storage.
- Denormalized/star schema pho bien.

Sai lam hay gap:

- Dung warehouse lam transactional database.
- Dung app database lam reporting warehouse cho query nang.
- Query truc tiep production OLTP cho dashboard, lam cham app.

## Partitioning

Partitioning chia table thanh cac phan lon, thuong theo date.

Nen partition khi:

- Table lon.
- Query thuong filter theo ngay.
- Data co cot date/timestamp on dinh.

Vi du:

```sql
select
    order_date,
    sum(revenue) as revenue
from marts.fct_orders
where order_date between date '2026-05-01' and date '2026-05-07'
group by order_date;
```

Query nay co partition filter tot neu table partition theo `order_date`.

Bad pattern:

```sql
select
    sum(revenue)
from marts.fct_orders;
```

Neu table rat lon, query nay scan tat ca partitions.

Trade-off:

- Partition qua nho/qua nhieu co overhead.
- Partition sai cot khong giup cost.
- Partition theo ingestion date de load de hon, nhung business query lai filter order date. Can chon theo query pattern chinh.

## Clustering

Clustering sap xep/nhom data theo cot trong partition.

Nen cluster theo:

- Cot hay filter: `customer_id`, `country`, `status`.
- Cot hay join: `product_id`, `account_id`.
- Cot co cardinality vua/cao tuy engine.

Partition vs clustering:

- Partition cat table theo block lon.
- Clustering giup prune data ben trong partition.

Pattern:

```text
partition by order_date
cluster by customer_id, order_status
```

Trade-off:

- Clustering khong mien phi. Load/maintain co overhead.
- Cluster qua nhieu cot khong chac tot.
- Phai dua tren query history, khong dua tren cam tinh.

## Cost considerations

### Query cost

BigQuery on-demand thuong tinh theo data scanned. Vi vay cost phu thuoc vao:

- So cot doc.
- Partition filter.
- File/table size.
- Compression/columnar format.
- Query co intermediate shuffle lon khong.

Cost habits:

- Xem bytes processed truoc khi chay query lon.
- Dung dry run khi can.
- Dung partition filter bat buoc cho table lon.
- Tranh `select *`.
- Tao aggregate mart cho dashboard thay vi dashboard scan fact lon moi lan.
- Dat expiration cho temp/staging tables.

### Storage cost

Storage thuong re hon compute, nhung van can quan ly:

- Raw retention bao lau?
- Co can giu moi version khong?
- File co nen compress khong?
- Data nhay cam co can xoa theo policy khong?

Pattern:

- Raw data giu 30/90/365 ngay tuy business/compliance.
- Curated marts giu lau hon neu can reporting history.
- Temp tables co expiration ngan.

### Cost traps

- Dashboard auto-refresh scan table lon moi 5 phut.
- Analyst chay `select *` tren fact table nhieu TB.
- Khong partition table daily events.
- Luu duplicate raw/staging/mart khong co lifecycle.
- Tao nhieu materialized output ma khong ai dung.

## Production mindset

### Layering

Nen co boundary ro:

- Raw: immutable hoac append-only, giu du lieu gan goc.
- Staging: typed, cleaned, deduplicated co rule.
- Intermediate: business joins/aggregations trung gian.
- Marts: tables phuc vu BI/product.

### Naming va ownership

Moi dataset/table quan trong can co:

- Owner.
- Purpose.
- Grain.
- Refresh cadence.
- SLA.
- Retention.
- PII classification neu co.

### Data lifecycle

Khong phai data nao cung giu vinh vien.

Can quyet dinh:

- Raw giu bao lau?
- Backfill can quay lai bao xa?
- GDPR/PII xoa the nao?
- Temp/intermediate tables expire khi nao?

### Security

Production warehouse phai quan tam:

- Least privilege.
- Dataset/table level permission.
- Row-level security neu can.
- Column-level masking cho PII.
- Audit logs.
- Secret management.

## Debugging mindset

### Query cham

Checklist:

1. Co scan qua nhieu bytes khong?
2. Co partition filter khong?
3. Co `select *` khong?
4. Join co lam row explosion khong?
5. Co aggregate tren raw table qua lon thay vi mart khong?
6. Clustering co phu hop query khong?

### Query ton tien bat thuong

Checklist:

1. Xem job history.
2. Xem bytes processed.
3. Tim dashboard/job lap lai nhieu lan.
4. Tim query khong filter partition.
5. Tim table/view nested qua sau.
6. Tao mart/aggregate neu query lap lai.

### Missing data

Checklist:

1. Raw file co tren GCS khong?
2. Ingestion job co load thanh cong khong?
3. External table co doc dung prefix khong?
4. Schema co drift khong?
5. Partition co duoc tao khong?
6. Downstream dbt/model co filter sai date/timezone khong?

### Schema drift

Van de:

- Source them cot moi.
- Source doi type.
- Source doi enum/status.
- JSON payload co field bat ngo.

Response:

- Raw layer nen chap nhan drift co kiem soat.
- Staging layer phai cast va fail ro neu type quan trong sai.
- Data contract cho source quan trong.
- Alert khi schema thay doi.

## Real-world failures

### Failure 1: Dashboard scan cost tang gap 10

Nguyen nhan thuong gap:

- Query bo partition filter.
- View moi join raw events table.
- BI tool refresh qua thuong xuyen.

Fix:

- Bat buoc partition filter.
- Tao daily aggregate mart.
- Set BI cache/schedule.
- Review query history hang tuan.

### Failure 2: Backfill overwrite raw data

Nguyen nhan:

- Raw path khong co ingestion_date/run_id.
- Job ghi de file cu.

Fix:

- Raw append-only.
- Path co run_id hoac ingestion timestamp.
- Reprocess tu raw sang curated.

### Failure 3: BigQuery table partition sai cot

Nguyen nhan:

- Partition theo ingestion date, trong khi query business filter order date.

Fix:

- Review query pattern.
- Tao table moi partition theo order_date.
- Migration/backfill co ke hoach.

### Failure 4: Service account qua nhieu quyen

Nguyen nhan:

- Cho owner/editor de lab chay nhanh.

Fix:

- Tach service account theo pipeline.
- Least privilege.
- Audit permission dinh ky.

## Trade-offs

### Load raw vao warehouse hay query external tu lake?

Load vao warehouse:

- Tot cho performance va governance.
- Ton storage duplicate.
- Can load job.

External table:

- Nhanh de setup.
- Giu data tren lake.
- Co the cham hon va kho kiem soat hon.

Rule:

- Raw exploration: external ok.
- Production marts: managed/native table tot hon.

### CSV hay Parquet?

CSV:

- De inspect.
- Tot cho sample nho.
- Kem cho analytics lon.

Parquet:

- Tot cho scale.
- Columnar/compressed.
- Kho doc bang mat thuong.

Rule:

- API raw co the JSON/CSV.
- Curated lake nen Parquet.

### View hay table?

View:

- Khong duplicate data.
- Luon moi.
- Moi query tinh lai, co the ton tien.

Table:

- Query nhanh/on dinh hon.
- Ton storage.
- Can refresh schedule.

Rule:

- Staging nho co the view.
- Mart dung dashboard nen materialized/table neu query nang.

## Real production warehouse patterns

### Pattern 1: Raw immutable lake

Raw file khong sua. Neu source gui sai, ghi ban moi va xu ly o staging.

### Pattern 2: Curated warehouse layers

```text
raw -> staging -> intermediate -> marts
```

Moi layer co muc dich rieng, giup debug theo boundary.

### Pattern 3: Daily partitioned facts

Fact events/orders partition theo business date hoac event date.

### Pattern 4: Aggregate marts cho BI

Dashboard khong nen moi lan scan raw/fact lon. Tao mart:

- daily revenue
- customer LTV
- product performance
- funnel conversion

### Pattern 5: Cost observability

Theo doi:

- Query cost by user/job.
- Table storage growth.
- Dashboard query frequency.
- Failed jobs.

## Exercises

### Level 1: Cloud basics

1. Tao GCP project.
2. Tao GCS bucket cung location voi BigQuery dataset.
3. Tao service account cho pipeline.
4. Cap quyen toi thieu de upload file va run BigQuery job.
5. Document project ID, bucket, dataset, region.

### Level 2: Lake to warehouse

1. Upload CSV/JSON raw data len GCS.
2. Tao external table tren raw file.
3. Load raw data vao BigQuery managed table.
4. So sanh query external vs managed table.
5. Viet README giai thich khi nao dung external.

### Level 3: Partitioning va clustering

1. Tao fact table partition theo date.
2. Chay query co partition filter.
3. Chay query khong co partition filter.
4. So sanh bytes processed.
5. Them clustering theo customer_id/status.

### Level 4: Cost debugging

1. Viet mot query co `select *` tren table lon.
2. Rewrite chi lay cot can dung.
3. Tao aggregate mart.
4. So sanh cost giua query fact va query mart.

### Level 5: Production design

1. Ve architecture raw -> staging -> marts.
2. Dinh nghia owner/SLA/grain cho moi table.
3. Dinh nghia retention policy.
4. Dinh nghia permission model.

## Mini project

### De bai

Build cloud warehouse cho ecommerce analytics.

Input:

- Raw orders JSON/CSV.
- Raw customers CSV.
- Raw payments CSV.

Architecture:

```text
local files/API
    -> GCS raw bucket
    -> BigQuery raw dataset
    -> BigQuery staging dataset
    -> BigQuery marts dataset
    -> quality checks
```

### Yeu cau

- Bucket co naming ro.
- Raw path co ingestion date.
- BigQuery dataset chia `raw`, `staging`, `marts`.
- Fact orders partition theo `order_date`.
- Cluster theo `customer_id`.
- Co daily revenue mart.
- Co cost notes: query nao scan bao nhieu bytes.
- Co IAM notes: service account dung quyen nao.

### Dau ra

- SQL tao table.
- Script upload/load.
- README architecture.
- Screenshot/query result minh hoa partition cost.
- Data dictionary cho marts.

## Interview questions

### Concept

- Data lake khac data warehouse nhu the nao?
- Lakehouse giai quyet van de gi?
- OLTP va OLAP khac nhau nhu the nao?
- Storage vs compute separation co loi gi?
- Columnar storage giup query analytics ra sao?

### BigQuery/GCP

- BigQuery tinh query cost dua tren gi?
- External table khac managed table nhu the nao?
- Partition va clustering khac nhau ra sao?
- Khi nao nen dung partition theo ingestion date, khi nao theo event date?
- Service account la gi?

### Production

- Lam sao giam cost dashboard BigQuery?
- Lam sao debug missing partition data?
- Lam sao xu ly schema drift tu source JSON?
- Vi sao raw layer nen append-only?
- Lam sao thiet ke permission cho data warehouse?

## GitHub outputs

Toi thieu:

- `cloud/architecture.md`
- `cloud/gcs_layout.md`
- `sql/create_raw_tables.sql`
- `sql/create_partitioned_facts.sql`
- `sql/cost_comparison.sql`
- README co diagram va run commands.

Tot hon:

- Terraform cho bucket/dataset/service account.
- Script upload sample data.
- Query results minh hoa bytes scanned.
- Data lifecycle/retention notes.
- IAM least privilege notes.

## BigQuery production appendix

### Materialized views

Materialized views phu hop khi:

- Query aggregate lap lai.
- Source table lon.
- Refresh logic duoc engine ho tro.

Trade-off:

- Khong linh hoat bang table build rieng.
- Co restriction ve SQL.
- Can quan sat refresh status va cost.

### Authorized views va row/column security

Authorized view cho phep expose subset du lieu ma khong cap raw table access.

Use case:

- Analyst can xem customer metrics nhung khong xem PII.
- External partner chi xem rows/cot da filter.

Production warning:

- BI service account qua rong quyen co the bypass governance.
- Row/column policy phai duoc test bang user/group thuc, khong chi owner account.

### Load job failure modes

Common failures:

- CSV delimiter/quote issue.
- Bad records exceed threshold.
- Schema mismatch.
- Partition decorator/date sai.
- GCS permission missing.
- File compressed format khong duoc support nhu mong doi.

Runbook:

1. Inspect failed job error.
2. Identify file/object path.
3. Sample bad rows.
4. Validate schema.
5. Quarantine bad file.
6. Reload into staging table.

### Slots/reservations

BigQuery on-demand de hoc nhanh. Production lon co the can reservations/slots.

Trade-off:

- On-demand: don gian, pay per scan, de cost spike.
- Slots/reservations: predictable capacity/cost hon, can workload management.

Workload isolation:

- Separate interactive BI, scheduled transforms, backfills.
- Backfill khong nen tranh slots voi daily executive dashboards.
