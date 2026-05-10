# Chien luoc hoc Data Engineering 2026 va context lam viec

File nay dung de:

- Tong hop lai nhung gi da trao doi.
- Lam chien luoc hoc tap 12 tuan.
- Giu context de mo chat moi van tiep tuc duoc.
- Lam checklist hoc tung bai voi mentor.

## 1. Boi canh nguoi hoc

Nguoi hoc hien co nen tang:

- Da biet ETL.
- Da biet SQL.
- Da dung ODI va Talend de migrate/chuyen doi du lieu.
- Chua phai bat dau tu so 0.

Loi the hien tai:

- Da hieu source/target.
- Da quen mapping du lieu.
- Da biet migration flow.
- Da co cam giac ve batch job, transform, duplicate, null, data type.

Khoang trong can bu de tro thanh Data Engineer hien dai nam 2026:

- Python cho pipeline.
- Git/GitHub workflow.
- Docker va local data platform.
- Cloud storage va warehouse.
- BigQuery/GCP.
- dbt va analytics engineering.
- Orchestration bang Airflow/Kestra.
- Data modeling production.
- Data quality, observability.
- CI/CD.
- Spark/Kafka/CDC o muc co ban-thuc hanh.
- Production operations, cost, security, IaC.
- Portfolio va system design interview.

## 2. Chien luoc tong quat

Khong hoc 23 file nhu doc sach tu dau den cuoi.

Hoc theo 3 lop:

1. Core path de di lam duoc.
2. Production depth de len level.
3. Interview/portfolio de chung minh nang luc.

Nguyen tac:

- 70% thuc hanh.
- 20% doc ly thuyet.
- 10% viet README/note/portfolio.
- Moi 2-3 ngay phai co mot thu chay duoc.
- Moi cong nghe phai gan voi pipeline that.
- Sau moi module phai tra loi duoc:
  - Tool nay giai quyet van de gi?
  - Nam o dau trong architecture?
  - Input/output la gi?
  - Fail kieu gi?
  - Debug ra sao?
  - Scale/cost co van de gi?
  - Trade-off voi tool/pattern khac la gi?

## 3. Stack chinh nen hoc

Stack chinh:

- SQL.
- Python.
- Git.
- Docker.
- PostgreSQL.
- GCP.
- Google Cloud Storage.
- BigQuery.
- dbt.
- Kestra theo Zoomcamp, hoc them Airflow de phong van.
- Spark basic.
- Kafka basic.
- Data quality checks.
- GitHub Actions basic.
- Terraform basic.

Khong nen hoc lan man:

- Khong hoc AWS + GCP + Azure cung luc.
- Khong hoc Airflow + Dagster + Prefect + Kestra cung luc.
- Khong hoc Kafka + Flink + Spark Streaming cung luc.
- Khong hoc Snowflake + BigQuery + Databricks cung luc.
- Khong hoc Kubernetes qua som.

## 4. Moi truong can chuan bi

May hien tai:

- Windows 11.
- RAM 24GB.
- SSD 1TB.

May nay du de hoc nghiem tuc.

Khuyen nghi setup:

- WSL2 + Ubuntu 22.04 hoac 24.04.
- Windows Terminal.
- VS Code.
- VS Code Remote - WSL extension.
- Git.
- Docker Desktop voi WSL2 backend.
- Python 3.11 hoac 3.12.
- `uv` hoac `venv` de quan ly Python environment.
- PostgreSQL client.
- DBeaver hoac DataGrip.
- Google Cloud SDK.
- Terraform.
- Java 17 cho Spark local.

Docker Desktop:

- Memory: 10-14GB.
- CPU: 4-6 cores neu may co du.
- Disk image tren SSD, cap phat rong.

Folder khuyen nghi trong WSL:

```text
~/de-learning/
  repos/
  projects/
  datasets/
  notes/
  credentials/
```

Khong nen de code chinh trong `/mnt/c/...` neu chay Docker/WSL nhieu, vi co the cham va gap loi permission. Nen de trong filesystem Ubuntu.

## 5. Tai lieu da tao trong repo

Bo tai lieu chinh:

```text
de-2026-learning/
  README.md
  00-roadmap-3-months.md
  01-sql.md
  02-python.md
  03-git-linux-workflow.md
  04-docker.md
  05-cloud-warehouse-lake.md
  06-orchestration.md
  07-dbt.md
  08-data-modeling.md
  09-spark.md
  10-kafka-streaming.md
  11-data-quality-observability.md
  12-cicd-testing-production.md
  13-portfolio-interview.md
  14-storage-file-format.md
  15-lakehouse-modern-stack.md
  16-distributed-systems-for-de.md
  17-performance-cost-optimization.md
  18-governance-security.md
  19-production-operations.md
  20-cdc-and-real-time-ingestion.md
  21-data-pipeline-patterns.md
  22-data-engineering-system-design.md
  23-infrastructure-as-code.md
```

Lab da tao:

```text
01-sql-practice/
```

Lab SQL co:

- Docker Compose PostgreSQL.
- Ecommerce schema.
- Seed data.
- Bad data co chu dich.
- Staging models.
- Marts.
- Quality checks.
- Incremental examples.
- Interview debugging scenarios.
- Exercises level 01-07.

Luu y: moi truong hien tai chua co Docker CLI, nen chua smoke test container trong chat. Khi hoc tren may ca nhan co Docker, chay theo README cua `01-sql-practice`.

## 6. Lo trinh hoc 12 tuan

### Tuan 1: SQL production mindset

Hoc:

- `01-sql.md`
- `01-sql-practice/README.md`
- `01-sql-practice/exercises/level_01_foundation.md`
- `01-sql-practice/exercises/level_02_joins_grain.md`

Muc tieu:

- Chay duoc PostgreSQL lab.
- Hieu raw vs staging vs marts.
- Debug duplicate.
- Debug join explosion.
- Giai thich grain.

Dau ra GitHub:

- Repo/folder SQL lab.
- Query quality checks.
- Note ve join explosion va grain.

### Tuan 2: SQL window, modeling, incremental

Hoc:

- `01-sql.md`
- `01-sql-practice/exercises/level_03_window_functions.md`
- `01-sql-practice/exercises/level_04_modeling.md`
- `01-sql-practice/exercises/level_05_incremental.md`
- `01-sql-practice/exercises/level_06_debugging.md`

Muc tieu:

- Deduplicate bang `row_number`.
- Build fact/dimension.
- Hieu append vs merge/upsert.
- Hieu watermark va late-arriving data.

Dau ra:

- `staging/`, `marts/`, `quality/`, `incremental/`.
- README giai thich loi duplicate va late-arriving.

### Tuan 3: Python ingestion

Hoc:

- `02-python.md`
- Phan config, API ingestion, error handling, logging, idempotency.

Project:

```text
CSV/API -> Python -> PostgreSQL
```

Muc tieu:

- Viet ingestion script.
- Co `.env.example`.
- Co logging.
- Co retry co gioi han.
- Co idempotency hoac duplicate prevention.

Dau ra:

- Python project co `src/`, `tests/`, README.

### Tuan 4: Git, Docker, local platform

Hoc:

- `03-git-linux-workflow.md`
- `04-docker.md`

Project:

```text
Python ingestion + PostgreSQL + Docker Compose
```

Muc tieu:

- Chay Postgres bang Docker Compose.
- Dockerize Python script.
- Dung Git workflow sach.
- README co command chay lai.

Dau ra:

- `docker-compose.yml`.
- `Dockerfile`.
- `.env.example`.
- README setup/run/debug.

### Tuan 5: Cloud warehouse

Hoc:

- `05-cloud-warehouse-lake.md`
- `14-storage-file-format.md` doc chon loc.

Project:

```text
local/API -> GCS raw -> BigQuery raw/staging/mart
```

Muc tieu:

- Upload raw data len GCS.
- Load vao BigQuery.
- Tao partitioned table.
- So sanh query co/khong co partition filter.
- Ghi note ve cost.

Dau ra:

- SQL BigQuery.
- Architecture diagram.
- Cost notes.

### Tuan 6: dbt

Hoc:

- `07-dbt.md`

Project:

```text
BigQuery/Postgres raw -> dbt staging -> intermediate -> marts -> tests
```

Muc tieu:

- Tao dbt project.
- Dung `source()` va `ref()`.
- Tao staging, intermediate, marts.
- Them unique, not null, relationships, accepted values tests.
- Generate docs.

Dau ra:

- dbt project.
- `schema.yml`.
- Docs/lineage screenshot neu co.

### Tuan 7: Data modeling

Hoc:

- `08-data-modeling.md`

Project:

- Hoan thien data model cho ecommerce.

Muc tieu:

- Grain cua moi bang ro.
- Co `dim_customers`, `dim_products`, `fct_orders`, `fct_order_items`.
- Co metric definitions.
- Co reconciliation.

Dau ra:

- `docs/data_model.md`.
- `docs/metric_definitions.md`.
- ERD/mermaid diagram.

### Tuan 8: Orchestration, quality, CI

Hoc:

- `06-orchestration.md`
- `11-data-quality-observability.md`
- `12-cicd-testing-production.md`

Project:

```text
daily orchestrated pipeline
  -> ingestion
  -> load raw
  -> dbt build
  -> quality checks
  -> runbook
```

Muc tieu:

- Co DAG/flow Kestra hoac Airflow.
- Co retry policy.
- Co backfill 3 ngay.
- Co quality checks.
- Co CI co ban.

Dau ra:

- DAG/flow.
- `RUNBOOK.md`.
- GitHub Actions workflow neu co.

### Tuan 9: Spark mini lab

Hoc:

- `09-spark.md`
- `14-storage-file-format.md`

Lab:

```text
CSV/JSON -> Spark -> Parquet partitioned output
```

Muc tieu:

- Hieu DataFrame API.
- Hieu lazy evaluation.
- Hieu partition, shuffle, skew, small files.
- Biet doc Spark UI o muc co ban.

Dau ra:

- Spark job.
- README ve shuffle/skew/small files.

### Tuan 10: Kafka va CDC mini lab

Hoc:

- `10-kafka-streaming.md`
- `20-cdc-and-real-time-ingestion.md`

Lab:

```text
producer -> Kafka topic -> consumer -> PostgreSQL sink
```

Muc tieu:

- Hieu topic, partition, offset, consumer group.
- Xu ly duplicate bang event_id.
- Hieu DLQ, replay, lag.
- Hieu CDC: snapshot, change event, deletes, schema evolution.

Dau ra:

- Kafka Docker Compose.
- Producer/consumer.
- README ve duplicate, offset, replay.

### Tuan 11: Production platform mindset

Hoc:

- `16-distributed-systems-for-de.md`
- `17-performance-cost-optimization.md`
- `18-governance-security.md`
- `19-production-operations.md`
- `21-data-pipeline-patterns.md`
- `23-infrastructure-as-code.md`

Muc tieu:

- Biet noi ve reliability, cost, security, governance.
- Biet debug retry storm, cost spike, lag spike, stale data.
- Biet IaC/Terraform o muc thiet ke.

Dau ra:

- Production readiness checklist.
- Cost/debug runbook.
- IAM matrix.
- Terraform design notes.

### Tuan 12: Portfolio va interview

Hoc:

- `13-portfolio-interview.md`
- `22-data-engineering-system-design.md`

Muc tieu:

- Polish project chinh.
- Viet README production-grade.
- Tap ke chuyen project.
- Tap system design.

Dau ra:

- 1 project chinh hoan chinh.
- 2 mini labs: Spark va Kafka.
- GitHub profile/co README tot.

## 7. Cach hoc moi file

Moi file hoc theo thu tu:

1. Doc `Vai tro`.
2. Doc `Muc tieu can dat`.
3. Doc `Architecture mindset`.
4. Lam `Exercises`.
5. Doc `Real-world failures`.
6. Viet 5-10 bullet:
   - fail kieu gi
   - debug sao
   - prevention sao
7. Ap dung vao project.
8. Cuoi cung doc `Interview questions`.

Khong nen:

- Doc het roi moi lam.
- Copy tutorial ma khong hieu architecture.
- Lam project khong README.
- Bo qua debugging va data quality.

## 8. Project portfolio chinh

Project chinh nen la:

```text
API/CSV
  -> Python ingestion
  -> raw storage
  -> warehouse
  -> dbt staging/intermediate/marts
  -> data quality checks
  -> orchestration
  -> CI
  -> README + runbook
```

README phai co:

- Problem.
- Architecture.
- Tech stack.
- Data source.
- Data model va grain.
- Pipeline flow.
- Setup.
- How to run.
- Data quality checks.
- Incremental/backfill strategy.
- Failure handling.
- Cost/scaling notes.
- Trade-offs.
- Future improvements.

## 9. Cach lam viec voi mentor trong chat moi

Khi mo chat moi, co the paste doan sau:

```text
Toi dang hoc Data Engineering 2026. Background cua toi: da biet ETL, SQL, ODI, Talend va migrate du lieu. Muc tieu: trong 12 tuan build duoc portfolio Data Engineer hien dai.

Toi co bo tai lieu de-2026-learning tu 01 den 23 va lab 01-sql-practice. Chien luoc hoc la:
- Core path: SQL, Python, Git/Linux, Docker, Cloud Warehouse.
- Modern stack: Orchestration, dbt, Data Modeling, Data Quality, CI/CD.
- Scale: Spark, Kafka, Storage/File Format, Lakehouse, CDC.
- Production: Distributed Systems, Performance/Cost, Governance/Security, Production Ops, Pipeline Patterns, IaC.
- Portfolio/interview: Portfolio + System Design.

Nguyen tac hoc: 70% thuc hanh, 20% doc, 10% README/note. Moi 2-3 ngay phai co thu chay duoc. Moi bai can hoc theo: vai tro -> architecture -> exercises -> failures -> debug notes -> project -> interview.

Hay mentor toi theo tung buoi hoc. Dung phong cach Senior Data Engineer: production-first, debugging-first, trade-off-first. Dung hoi/toi uu qua nhieu ly thuyet truoc khi co bai tap chay duoc.
```

## 10. Buoi hoc tiep theo nen bat dau

Buoi tiep theo nen bat dau voi:

```text
Tuan 1 - Bai 1: SQL foundation va 01-sql-practice setup
```

Muc tieu buoi dau:

- Mo `01-sql.md`.
- Mo `01-sql-practice/README.md`.
- Cai Docker neu chua co.
- Chay PostgreSQL lab.
- Inspect raw tables.
- Chay level 01 foundation.
- Viet note ve raw row count vs business entity count.

Neu Docker chua setup xong, buoi dau tap trung setup WSL2 + Docker + VS Code.

## 11. Mentor commitment

Vai tro mentor mong muon:

- Huong dan tung buoi hoc.
- Khong chi giai thich ly thuyet.
- Bat buoc gan voi bai tap va project.
- Neu bai lam sai, review theo production mindset.
- Dat cau hoi nhu phong van that.
- Yeu cau viet README, runbook, debugging notes.
- Giu focus, tranh hoc lan man.

Trang thai hien tai:

- Da co roadmap.
- Da co tai lieu.
- Da co SQL lab.
- San sang bat dau hoc tung bai.

